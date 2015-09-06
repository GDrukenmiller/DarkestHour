//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2015
//==============================================================================

class DHVehicleMG extends ROMountedTankMG
    abstract;

// General
var  DHVehicleMGPawn  MGPawn;         // just a reference to the DH MG pawn actor, for convenience & to avoid lots of casts
var     bool    bMatchSkinToVehicle;  // option to automatically match MG skin zero to vehicle skin zero (e.g. for gunshield), avoiding need for separate MGPawn & MG classes

// Ammo & firing
var     class<Projectile> TracerProjectileClass; // replaces DummyTracerClass as tracer is now a real bullet that damages, not just a client-only effect, so old name was misleading
var     byte    TracerFrequency;      // how often a tracer is loaded in (as in: 1 in the value of TracerFrequency)
var     byte    NumMags;              // number of mags carried for this MG (use byte for more efficient replication)
var     sound   NoAmmoSound;          // 'dry fire' sound when trying to fire empty MG

// MG collision static mesh (Matt: new col mesh actor allows us to use a col static mesh with a VehicleWeapon)
var     DHCollisionMeshActor    CollisionMeshActor;
var     StaticMesh              CollisionStaticMesh; // specify a valid static mesh in MG's default props & the col static mesh will automatically be used

// Stuff for fire effects - Ch!cKeN
var     VehicleDamagedEffect        HullMGFireEffect;
var     class<VehicleDamagedEffect> FireEffectClass;
var     name                        FireAttachBone;
var     vector                      FireEffectOffset;

// Reloading
struct  ReloadStage
{
    var  sound  Sound;
    var  float  Duration;
};

enum  EReloadState
{
    MG_Empty,
    MG_ReloadedPart1,
    MG_ReloadedPart2,
    MG_ReloadedPart3,
    MG_ReloadedPart4,
    MG_ReadyToFire,
    MG_Waiting, // put waiting at end of list, as ReloadSounds array then matches ReloadState numbering, & also "ReloadState < MG_ReadyToFire" conveniently signifies MG is reloading
};

var     array<ReloadStage>  ReloadSounds;         // sounds for multi-part reload (optional durations, as servers often use 'index' sound files without actual sounds, breaking MG reload)
var     EReloadState        ReloadState;          // the stage of MG reload or readiness (similar to a tank cannon)
var     bool                bReloadPaused;        // MG reload has been paused
var     name                HUDOverlayReloadAnim; // reload animation to play if the MG uses a HUDOverlay

replication
{
    // Variables the server will replicate to the client that owns this actor
    reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
        NumMags;

    // Variables the server will replicate to all clients
//  reliable if (bNetDirty && Role == ROLE_Authority)
//      bOnFire; // Matt: removed this variable

    // Functions the server can call on the client that owns this actor
    reliable if (Role == ROLE_Authority)
        ClientSetReloadState;
}

///////////////////////////////////////////////////////////////////////////////////////
//  ********************** ACTOR INITIALISATION & DESTRUCTION  ********************  //
///////////////////////////////////////////////////////////////////////////////////////

// Matt: modified to attach new collision static mesh actor, if one has been specified
simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    if (CollisionStaticMesh != none)
    {
        CollisionMeshActor = AttachCollisionMesh(CollisionStaticMesh, YawBone); // attach to MG's yaw bone, so col mesh turns with MG

        if (CollisionMeshActor != none)
        {
            // Remove all collision from this VehicleWeapon class (instead let col mesh actor handle collision detection)
            SetCollision(false, false); // bCollideActors & bBlockActors both false
            bBlockZeroExtentTraces = false;
            bBlockNonZeroExtentTraces = false;
            bBlockHitPointTraces = false;
            bProjTarget = false;
        }
    }
}

// Matt: new function to do any extra set up in the MG classes (called from MG pawn) - can be subclassed to do any vehicle specific setup
// Crucially, we know that we have MGPawn & its VehicleBase when this function gets called, so we can reliably do stuff that needs those actors
// Includes option to automatically match MG skin(s) to vehicle skin(s), e.g. for gunshield, avoiding need for separate MGPawn & MG classes
simulated function InitializeMG(DHVehicleMGPawn MGPwn)
{
    if (MGPwn != none)
    {
        MGPawn = MGPwn;

        if (Role < ROLE_Authority)
        {
            SetOwner(MGPawn);
            Instigator = MGPawn;
        }

        if (DHArmoredVehicle(MGPawn.VehicleBase) != none)
        {
            // Set the vehicle's HullMG reference - normally unused but can be useful
            DHArmoredVehicle(MGPawn.VehicleBase).HullMG = self;

            // If vehicle is burning, start the MG hatch fire effect
            if (DHArmoredVehicle(MGPawn.VehicleBase).bOnFire && Level.NetMode != NM_DedicatedServer)
            {
                StartMGFire();
            }
        }

        // Match MG skin zero to vehicle skin zero, e.g. for gunshield
        if (bMatchSkinToVehicle)
        {
            Skins[0] = MGPawn.VehicleBase.Skins[0];
        }
    }
    else
    {
        Warn("ERROR:" @ Tag @ "somehow spawned without an owning DHVehicleMGPawn, so lots of things are not going to work!");
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//  ***************************** KEY ENGINE EVENTS  ******************************  //
///////////////////////////////////////////////////////////////////////////////////////

// Matt: no longer use Tick, as MG hatch fire effect is now triggered on net client from Vehicle's PostNetReceive()
// Let's disable Tick altogether to save unnecessary processing
simulated function Tick(float DeltaTime)
{
    Disable('Tick');
}

// Multi-stage MG reload similar to a tank cannon, but implemented differently to optimise (runs independently on server & owning net client)
simulated function Timer()
{
    // If already reached final reload stage, always complete reload, regardless of circumstances
    // Reason: final reload sound will have played, so may be confusing if player cannot fire, especially if would need to unbutton to complete an apparently completed reload
    if (ReloadState == ReloadSounds.Length)
    {
        ReloadState = MG_ReadyToFire;
        bReloadPaused = false;

        if (Role == ROLE_Authority)
        {
            MainAmmoCharge[0] = InitialPrimaryAmmo;
        }
    }
    else if (ReloadState < ReloadSounds.Length)
    {
        // For earlier reload stages, we only proceed if we have a player in a position where he can reload
        if (!bReloadPaused && MGPawn != none && MGPawn.Controller != none && MGPawn.CanReload())
        {
            // Play reloading sound for this stage, if there is one (if MG uses a HUD reload animation, it will usually play its own sound through animation notifies)
            // Only played locally & not broadcast by server to other players, as is not worth the network load just for a reload sound
            if (ReloadSounds[ReloadState].Sound != none && MGPawn.IsLocallyControlled())
            {
                PlaySound(ReloadSounds[ReloadState].Sound, SLOT_Misc, 2.0, , 150.0,, false);
            }

            // Set next timer based on duration of current reload sound (use reload duration if specified, otherwise try & get the sound duration)
            if (ReloadSounds[ReloadState].Duration > 0.0)
            {
                SetTimer(ReloadSounds[ReloadState].Duration, false);
            }
            else
            {
                SetTimer(GetSoundDuration(ReloadSounds[ReloadState].Sound), false);
            }

            // Move to next reload state
            ReloadState = EReloadState(ReloadState + 1);
        }
        // Otherwise pause the reload, including stopping any HUD reload animation
        else
        {
            bReloadPaused = true;

            if (MGPawn != none && MGPawn.HUDOverlay != none)
            {
                MGPawn.HUDOverlay.StopAnimating();
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//  *********************************** FIRING ************************************  //
///////////////////////////////////////////////////////////////////////////////////////

// Modified to optimise & shorten by removing lots of redundancy for an MG, which doesn't have different round types or alt fire
event bool AttemptFire(Controller C, bool bAltFire)
{
    if (FireCountdown <= 0.0 && Role == ROLE_Authority)
    {
        // Have ammo - fire
        if (ConsumeAmmo(0))
        {
            CalcWeaponFire(bAltFire);

            if (bCorrectAim)
            {
                WeaponFireRotation = AdjustAim(bAltFire);
            }

            if (Spread > 0.0)
            {
                WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand() * FRand() * Spread);
            }

            If (Instigator != none)
            {
                Instigator.MakeNoise(1.0);
            }

            FireCountdown = FireInterval;
            Fire(C);
            AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

            return true;
        }

        // Out of ammo - cease fire
        if (MGPawn != none)
        {
            MGPawn.ClientVehicleCeaseFire(bAltFire);
        }
    }

    return false;
}

// Matt: modified to spawn either normal bullet OR tracer, based on proper shot count, not simply time elapsed since last shot
state ProjectileFireMode
{
    function Fire(Controller C)
    {
        // Modulo operator (%) divides rounds previously fired by tracer frequency & returns the remainder - if it divides evenly (result = 0) then it's time to fire a tracer
        if (bUsesTracers && ((InitialPrimaryAmmo - MainAmmoCharge[0] - 1) % TracerFrequency == 0.0))
        {
            SpawnProjectile(TracerProjectileClass, false);
        }
        else
        {
            SpawnProjectile(ProjectileClass, false);
        }
    }
}

// Modified to remove the Super in ROVehicleWeapon to remove calling UpdateTracer, now we spawn either a normal bullet OR tracer (see ProjectileFireMode)
simulated function FlashMuzzleFlash(bool bWasAltFire)
{
    super(VehicleWeapon).FlashMuzzleFlash(bWasAltFire);
}

// Modified to stop 'phantom' firing effects (muzzle flash & tracers) from continuing if player has moved to an invalid firing position while holding down fire button
// Also to enable muzzle flash when hosting a listen server, which the original code misses out
simulated function OwnerEffects()
{
    if (MGPawn != none && MGPawn.CanFire())
    {
        super.OwnerEffects();

        if (Level.NetMode == NM_ListenServer && AmbientEffectEmitter != none) // added so we get muzzle flash when hosting a listen server
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }
    }
    else
    {
        MGPawn.ClientVehicleCeaseFire(bIsAltFire); // stops flash & tracers if player has moved to invalid firing position while holding down fire
    }
}

// Modified to try to start a reload if MG is empty
function CeaseFire(Controller C, bool bWasAltFire)
{
    super.CeaseFire(C, bWasAltFire);

    if (!HasAmmo(0))
    {
        TryToReload();
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//  ****************************** AMMO & RELOADING *******************************  //
///////////////////////////////////////////////////////////////////////////////////////

// Modified to handle MG magazines
function bool GiveInitialAmmo()
{
    local bool bDidResupply;

    if (NumMags != default.NumMags)
    {
        bDidResupply = true;
    }

    MainAmmoCharge[0] = InitialPrimaryAmmo;
    MainAmmoCharge[1] = InitialSecondaryAmmo;
    AltAmmoCharge = InitialAltAmmo;
    NumMags = default.NumMags;

    return bDidResupply;
}

// New function (in VehicleWeapon class) to use DH's new incremental resupply system
function bool ResupplyAmmo()
{
    if (NumMags < default.NumMags)
    {
        ++NumMags;

        // If MG is out of ammo & waiting to reload & we have a player on the MG, try to start a reload
        if (!HasAmmo(0) && ReloadState == MG_Waiting && Instigator != none && Instigator.Controller != none)
        {
            TryToReload();
        }

        return true;
    }

    return false;
}

// New function to start a reload or resume a previously paused reload
simulated function TryToReload(optional bool bIgnoreViewTransition, optional bool bSkipClientSetReloadState)
{
    local bool bStateChanged;

    // Need to start a new reload
    if (ReloadState >= MG_ReadyToFire)
    {
        if (Role == ROLE_Authority) // a new reload can't be started by a net client
        {
            // Start a reload, if we have a spare mag & a player in a position where he can reload
            if (NumMags > 0 && MGPawn != none && MGPawn.CanReload(bIgnoreViewTransition))
            {
                NumMags--;
                ReloadState = MG_Empty;
                ProgressReload();
                bStateChanged = true;
            }
            // Otherwise make sure loading state is waiting (for a player in reloading position or a resupply)
            else if (ReloadState == MG_ReadyToFire)
            {
                ReloadState = MG_Waiting;
                bStateChanged = true;
            }

            // If state changed & actor not locally controlled (dedicated server, or listen server with MG controlled by another player), pass new state to client (unless flagged not to)
            if (bStateChanged && !bSkipClientSetReloadState && !MGPawn.IsLocallyControlled())
            {
                ClientSetReloadState(ReloadState);
            }
        }
    }
    // Resume a paused reload
    else if (bReloadPaused)
    {
        ProgressReload();
    }
}

// New server-to-client function to pass reload state & to start/resume clientside reload process if relevant
simulated function ClientSetReloadState(EReloadState NewState)
{
    if (Role < ROLE_Authority)
    {
        ReloadState = NewState;

        // If MG is in the middle of a reload
        if (ReloadState < MG_ReadyToFire)
        {
            // Start/resume reloading, as we have a player in a position to reload
            // If server starts new reload on unbuttoning, may be possible that net client is still in state ViewTransition when it receives this replicated function call
            // If so, CanReload would return false & reload would be paused on client, but a split second later client would leave ViewTransition & reload would be resumed
            if (MGPawn != none && MGPawn.CanReload())
            {
                ProgressReload();
            }
            // Otherwise the reload is paused
            else
            {
                bReloadPaused = true;
            }
        }
    }
}

// New function to start or resume a reload, including playing any HUD overlay reload animation
simulated function ProgressReload()
{
    local float ReloadSecondsElapsed, TotalReloadDuration;
    local int   i;

    // Make sure reload isn't set to paused & start a reload timer
    bReloadPaused = false;
    SetTimer(0.05, false);

    // If MG uses a HUD reload animation, play it
    if (MGPawn != none && MGPawn.HUDOverlay != none && MGPawn.HUDOverlay.HasAnim(HUDOverlayReloadAnim))
    {
        MGPawn.HUDOverlay.PlayAnim(HUDOverlayReloadAnim);

        // If we're resuming a paused reload, move the animation to where it left off (add up the previous stage durations)
        if (ReloadState > MG_Empty)
        {
            for (i = 0; i < ReloadSounds.Length; ++i)
            {
                if (i < ReloadState)
                {
                    ReloadSecondsElapsed += ReloadSounds[i].Duration;
                }

                TotalReloadDuration += ReloadSounds[i].Duration;
            }

            if (ReloadSecondsElapsed > 0.0)
            {
                MGPawn.HUDOverlay.SetAnimFrame(ReloadSecondsElapsed / TotalReloadDuration);
            }
        }
    }
}

// Modified to return false if MG is not loaded
simulated function bool ReadyToFire(bool bAltFire)
{
    return ReloadState == MG_ReadyToFire && super.ReadyToFire(bAltFire);
}

// Modified to handle MG magazines
simulated function int GetNumMags()
{
    return NumMags;
}

///////////////////////////////////////////////////////////////////////////////////////
//  ******************  SETUP, UPDATE, CLEAN UP, MISCELLANEOUS  *******************  //
///////////////////////////////////////////////////////////////////////////////////////

// Modified to include Skins array (so no need to add manually in each subclass) & to add extra material properties (note the Supers are empty)
static function StaticPrecache(LevelInfo L)
{
    local int i;

    for (i = 0; i < default.Skins.Length; ++i)
    {
        L.AddPrecacheMaterial(default.Skins[i]);
    }

    L.AddPrecacheMaterial(default.hudAltAmmoIcon);

    if (default.HighDetailOverlay != none)
    {
        L.AddPrecacheMaterial(default.HighDetailOverlay);
    }
}

// Modified to add extra material properties (note the Super in Actor already pre-caches the Skins array)
simulated function UpdatePrecacheMaterials()
{
    super.UpdatePrecacheMaterials();

    Level.AddPrecacheMaterial(hudAltAmmoIcon);

    if (HighDetailOverlay != none)
    {
        Level.AddPrecacheMaterial(HighDetailOverlay);
    }
}

// Modified to enforce use of rotation relative to vehicle (bPCRelativeFPRotation), to use yaw limits from DriverPositions in a multi position MG,
// & so we don't limit view yaw if in behind view
simulated function int LimitYaw(int yaw)
{
    if (!bLimitYaw || (Instigator != none && Instigator.IsHumanControlled() && PlayerController(Instigator.Controller).bBehindView))
    {
        return yaw;
    }

    if (MGPawn != none && MGPawn.DriverPositions.Length > 0)
    {
        return Clamp(yaw, MGPawn.DriverPositions[MGPawn.DriverPositionIndex].ViewNegativeYawLimit, MGPawn.DriverPositions[MGPawn.DriverPositionIndex].ViewPositiveYawLimit);
    }

    return Clamp(yaw, MaxNegativeYaw, MaxPositiveYaw);
}

// Matt: deprecated functions - return false just in case they get called
simulated function bool HitDriverArea(vector HitLocation, vector Momentum)
{
    return false;
}

simulated function bool HitDriver(vector HitLocation, vector Momentum)
{
    return false;
}

// Matt: modified to avoid calling TakeDamage on Driver, as shell & bullet's ProcessTouch now call it directly on the Driver if he was hit
// Note that shell's ProcessTouch also now calls TD() on VehicleWeapon instead of Vehicle itself
// For a vehicle MG this is not counted as a hit on vehicle itself, but we could add any desired functionality here or in subclasses, e.g. shell could wreck MG
// Note that if calling a damage function & DamageType.bDelayedDamage, we need to call SetDelayedDamageInstigatorController(InstigatedBy.Controller) on the relevant pawn
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    // Fix for suicide death messages
    if (DamageType == class'Suicided')
    {
        DamageType = class'ROSuicided';
        MGPawn.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
    }
    else if (DamageType == class'ROSuicided')
    {
        MGPawn.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
    }
}

// New function to start an MG hatch fire effect - all fires now triggered from vehicle base, so don't need MG's Tick() constantly checking for a fire
simulated function StartMGFire()
{
    if (HullMGFireEffect == none && Level.NetMode != NM_DedicatedServer)
    {
        HullMGFireEffect = Spawn(FireEffectClass);
    }

    if (HullMGFireEffect != none)
    {
        AttachToBone(HullMGFireEffect, FireAttachBone);
        HullMGFireEffect.SetRelativeLocation(FireEffectOffset);
        HullMGFireEffect.UpdateDamagedEffect(true, 0.0, false, false);
    }
}

// New function to spawn, attach & align a collision static mesh actor
simulated function DHCollisionMeshActor AttachCollisionMesh(StaticMesh ColStaticMesh, name AttachBone, optional class<DHCollisionMeshActor> ColMeshActorClass)
{
    local DHCollisionMeshActor ColMeshActor;

    if (ColMeshActorClass == none)
    {
        ColMeshActorClass = class'DHCollisionMeshActor';
    }

    ColMeshActor = Spawn(ColMeshActorClass, self); // vital that this VehicleWeapon owns the col mesh actor

    if (ColMeshActor != none)
    {
        // Attach col mesh actor to specified attachment bone, so the col mesh will move with the relevant part of the MG mesh
        ColMeshActor.bHardAttach = true;
        AttachToBone(ColMeshActor, AttachBone);

        // The Col mesh will have been modelled on the MG mesh's origin, but is now centred on the attachment bone, so reposition it to align with MG mesh
        ColMeshActor.SetRelativeLocation((Location - GetBoneCoords(AttachBone).Origin) << Rotation);

        // Finally set the static mesh for the col mesh actor (may be none, if using a subclass of DHCollisionMeshActor & that already specifies a static mesh)
        if (ColStaticMesh != none)
        {
            ColMeshActor.SetStaticMesh(ColStaticMesh);
        }
    }

    return ColMeshActor;
}

// Modified to add extra stuff
simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (CollisionMeshActor != none)
    {
        CollisionMeshActor.Destroy(); // not actually an effect, but convenient to add here
    }

    if (HullMGFireEffect != none)
    {
        HullMGFireEffect.Kill();
    }
}

defaultproperties
{
    ReloadState=MG_ReadyToFire
    ReloadSounds[0]=(Sound=sound'DH_Vehicle_Reloads.Reloads.MG34_ReloadHidden01',Duration=1.105) // default is MG34 reload sounds, as is used by most vehicles, even allies
    ReloadSounds[1]=(Sound=sound'DH_Vehicle_Reloads.Reloads.MG34_ReloadHidden02',Duration=2.413)
    ReloadSounds[2]=(Sound=sound'DH_Vehicle_Reloads.Reloads.MG34_ReloadHidden03',Duration=1.843)
    ReloadSounds[3]=(Sound=sound'DH_Vehicle_Reloads.Reloads.MG34_ReloadHidden04',Duration=1.314)
    NoAmmoSound=sound'Inf_Weapons_Foley.Misc.dryfire_rifle'
    FireAttachBone="mg_pitch"
    FireEffectOffset=(X=10.0,Y=0.0,Z=5.0)
    FireEffectClass=class'ROEngine.VehicleDamagedEffect'
    YawStartConstraint=0 // revert to defaults from VehicleWeapon, as MGs such as the StuH don't work with the values from ROMountedTankMG
    YawEndConstraint=65535
}
