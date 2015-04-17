//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2015
//==============================================================================

class DHSpawnManager extends SVehicleFactory;

enum ESpawnPointType
{
    ESPT_Infantry,
    ESPT_Vehicles,
    ESPT_Both
};

enum ESpawnPointMethod
{
    ESPM_Hints,
    ESPM_Radius
};

struct VehiclePool
{
    var() name              Tag;
    var() class<ROVehicle>  VehicleClass;
    var() bool              bIsInitiallyActive;
    var() float             RespawnTime;                //respawn interval in seconds
    var() byte              MaxSpawns;                  //how many vehicles can be spawned from this pool
    var() byte              MaxActive;                  //how many vehicles from this pool can be active at once

    var() name              OnActivatedEvent;           //event to trigger when pool is activated (also gets triggered when initially activated)
    var() name              OnDeactivatedEvent;         //event to trigger when pool is deactivated (does NOT get triggered when initially deactivated)
    var() name              OnDepletedEvent;            //event to trigger when pool has been depleted (SpawnCount meets or exceeds MaxSpawns)
    var() name              OnDepleteActivatePool;      //vehicle pool to activate when this pool has been depleted (uses pool tag)
    var() name              OnVehicleDestroyedEvent;    //event to trigger when vehicle from this pool is destroyed
    var() name              OnVehicleSpawnedEvent;      //event to trigger when vehicle from this pool is spawned

    var bool                bIsActive;
    var float               NextAvailableTime;          //the next time a vehicle from this pool can be spawned
    var byte                SpawnCount;                 //count of vehicles spawned from this pool
    var byte                ActiveCount;                //count of active vehicles spawn from this pool
};

var const byte SpawnError_None;
var const byte SpawnError_Fatal;
var const byte SpawnError_MaxVehicles;
var const byte SpawnError_Cooldown;
var const byte SpawnError_SpawnLimit;
var const byte SpawnError_ActiveLimit;
var const byte SpawnError_PoolInactive;
var const byte SpawnError_SpawnInactive;
var const byte SpawnError_Blocked;
var const byte SpawnError_Failed;
var const byte SpawnError_BadTeamPool;
var const byte SpawnError_BadTeamSpawnPoint;
var const byte SpawnError_TryToDriveFailed;
var const byte SpawnError_BadSpawnType;
var const byte SpawnError_PawnSpawnFailed;
var const byte SpawnError_IncorrectRole;
var const byte SpawnError_SpawnPointsDontMatch;

var const byte SpawnPointType_Infantry;
var const byte SpawnPointType_Vehicles;

var localized array<string> SpawnErrorStrings;

const SPAWN_POINTS_MAX = 64;
const VEHICLE_POOLS_MAX = 32;
const SPAWN_VEHICLES_MAX = 8;

var(Vehicles) array<VehiclePool>        VehiclePools;
var(Vehicles) byte                      MaxTeamVehicles[2];

var class<LocalMessage>                 VehicleDestroyedMessageClass;

var private byte                        TeamVehicleCounts[2];
var private array<ROVehicle>            Vehicles;
var private array<Vehicle>              SpawnVehicles;
var private array<DHSpawnPoint>         SpawnPoints;
var private DHGameReplicationInfo       GRI;
var private config bool                 bDebug;

function PostBeginPlay()
{
    local int i, j;
    local DHSpawnPoint SP;
    local bool bIsVehiclePoolValid;

    super.PostBeginPlay();

    GRI = DHGameReplicationInfo(Level.Game.GameReplicationInfo);

    if (GRI == none)
    {
        Warn("DHGameReplicationInfo is none");

        return;
    }

    foreach AllActors(class'DHSpawnPoint', SP)
    {
        if (SpawnPoints.Length >= SPAWN_POINTS_MAX)
        {
            Warn("DHSpawnPoint count exceeds" @ SPAWN_POINTS_MAX);

            break;
        }

        SpawnPoints[SpawnPoints.Length] = SP;
    }

    //Update GameReplicationInfo
    for (i = 0; i < SpawnPoints.Length; ++i)
    {
        GRI.SetSpawnPointIsActive(i, SpawnPoints[i].bIsInitiallyActive);
    }

    for (i = 0; i < VehiclePools.Length; ++i)
    {
        if (VehiclePools[i].VehicleClass == none)
        {
            VehiclePools.Remove(i--, 1);

            continue;
        }

        bIsVehiclePoolValid = true;

        // Vehicle pools must have a unique VehicleClass
        for (j = i - 1; j >= 0; --j)
        {
            if (VehiclePools[i].VehicleClass == VehiclePools[j].VehicleClass)
            {
                // Vehicle class already exists, mark as non-unique
                bIsVehiclePoolValid = false;
            }
        }

        if (!bIsVehiclePoolValid)
        {
            Warn("VehiclePools[" $ i $ "].VehicleClass (" $ VehiclePools[i].VehicleClass $ ") is not unique and will be removed!");

            // Remove VehiclePool from the list
            VehiclePools.Remove(i--, 1);

            continue;
        }

        SetPoolIsActive(i, VehiclePools[i].bIsInitiallyActive);

        UpdatePoolReplicationInfo(i);
    }

    for (i = 0; i < arraycount(GRI.MaxTeamVehicles); ++i)
    {
        GRI.MaxTeamVehicles[i] = MaxTeamVehicles[i];
    }
}

function Reset()
{
    local int i;

    for (i = 0; i < SpawnPoints.Length; ++i)
    {
        SetSpawnPointIsActive(i, SpawnPoints[i].bIsInitiallyActive);
    }

    Vehicles.Length = 0;

    super.Reset();
}

function Timer()
{
}

function UpdatePoolReplicationInfo(byte PoolIndex)
{
    GRI.SetVehiclePoolVehicleClass(PoolIndex, VehiclePools[PoolIndex].VehicleClass);
    GRI.SetVehiclePoolIsActive(PoolIndex, VehiclePools[PoolIndex].bIsActive);
    GRI.SetVehiclePoolSpawnsRemaining(PoolIndex, GetPoolSpawnsRemaining(PoolIndex));
    GRI.SetVehiclePoolNextAvailableTime(PoolIndex, VehiclePools[PoolIndex].NextAvailableTime);
    GRI.SetVehiclePoolActiveCount(PoolIndex, VehiclePools[PoolIndex].ActiveCount);
    GRI.SetVehiclePoolMaxActives(PoolIndex, VehiclePools[PoolIndex].MaxActive);
}

function DrySpawnVehicle(DHPlayer C, out vector SpawnLocation, out rotator SpawnRotation, out byte SpawnError)
{
    local DHSpawnPoint SP;

    SpawnError = SpawnError_Fatal;

    if (C == none)
    {
        return;
    }

    //Check spawn point
    SpawnError = GetSpawnPointError(C, ESPT_Vehicles);

    if (SpawnError != SpawnError_None)
    {
        return;
    }

    SP = SpawnPoints[C.SpawnPointIndex];

    if (SP == none)
    {
        SpawnError = SpawnError_Fatal;

        return;
    }

    //Check vehicle pool
    SpawnError = GetVehiclePoolError(C, SP);

    if (SpawnError != SpawnError_None)
    {
        return;
    }

    switch (SP.Method)
    {
        case ESPM_Hints:
            if (!GetSpawnLocation(SP, SP.VehicleLocationHints, VehiclePools[C.VehiclePoolIndex].VehicleClass.default.CollisionRadius * 1.25, SpawnLocation, SpawnRotation))
            {
                SpawnError = SpawnError_Blocked;

                return;
            }
        case ESPM_Radius:
            //TODO: do a proper radius check
            SpawnLocation = SP.Location;
            SpawnRotation = SP.Rotation;
    }

    SpawnError = SpawnError_None;
}

function bool GetSpawnLocation(DHSpawnPoint SP, array<DHLocationHint> LocationHints, float CollisionRadius, out vector SpawnLocation, out rotator SpawnRotation)
{
    local Pawn P;
    local array<int> LocationHintIndices;
    local int LocationHintIndex;
    local int i;
    local bool bIsBlocked;

    //Scramble location hint indices so we don't use the same ones repeatedly
    LocationHintIndices = class'DHLib'.static.CreateIndicesArray(LocationHints.Length);
    class'DHLib'.static.FisherYatesShuffle(LocationHintIndices);

    //Initialize with invalid index
    LocationHintIndex = -1;

    for (i = 0; i < LocationHintIndices.Length; ++i)
    {
        bIsBlocked = false;

        foreach RadiusActors(class'Pawn', P, CollisionRadius, LocationHints[LocationHintIndices[i]].Location)
        {
            //Found a blocking actor
            bIsBlocked = true;

            break;
        }

        if (!bIsBlocked)
        {
            //Location hint not blocked
            LocationHintIndex = LocationHintIndices[i];

            break;
        }
    }

    if (LocationHintIndex == -1)
    {
        //No usable location hint found, so use spawn point itself
        SpawnLocation = SP.Location;
        SpawnRotation = SP.Rotation;
    }
    else
    {
        SpawnLocation = LocationHints[LocationHintIndex].Location;
        SpawnRotation = LocationHints[LocationHintIndex].Rotation;
    }

    return true;
}

function SpawnPlayer(DHPlayer C, out byte SpawnError)
{
    if (C == none)
    {
        return;
    }

    if (C.VehiclePoolIndex != 255) // Vehicle Pool
    {
        if (bDebug)
        {
            Log("Attempting to spawn Vehicle at VP Index:" @ C.VehiclePoolIndex @ "SP:" @ C.SpawnPointIndex @ "(" $ VehiclePools[C.VehiclePoolIndex].VehicleClass.default.VehicleNameString $ ")" @ "SP.IsActive:" @ GRI.IsSpawnPointActive(GRI.GetSpawnPoint(C.SpawnPointIndex)));
        }

        SpawnVehicle(C, SpawnError);
    }
    else if (C.SpawnVehicleIndex != 255) // Spawn Vehicle
    {
        if (bDebug)
        {
            Log("Attempting to spawn Infantry at SpawnVehicleIndex" @ C.SpawnVehicleIndex);
        }

        SpawnPlayerAtSpawnVehicle(C, SpawnError);
    }
    else if (SpawnPoints[C.SpawnPointIndex] != none) // Spawn point
    {
        if (bDebug)
        {
            Log("Attempting to spawn Infantry at SP" @ C.SpawnPointIndex @ "(" $ SpawnPoints[C.SpawnPointIndex].SpawnPointName $ ")");
        }

        SpawnInfantry(C, SpawnError);
    }

    // We have a pawn so lets edit ammo and fade from black
    if (DHPawn(C.Pawn) != none)
    {
        DHPawn(C.Pawn).SetAmmoAmount(C.SpawnAmmoAmount);

        if (C.VehiclePoolIndex != 255) // Vehicle spawn
        {
            C.ClientFadeFromBlack(0.0, true); // Black out, the fade will start when the pawn is put back into the vehicle
            C.SetTimer(1.0, false); // Tell the player to check after 1 second to re enter the vehicle and fade from black
        }
        else
        {
            C.ClientFadeFromBlack(2.0);
        }
    }
}

function ROVehicle SpawnVehicle(DHPlayer C, out byte SpawnError)
{
    local ROVehicle V;
    local vector SpawnLocation;
    local rotator SpawnRotation;
    local DarkestHourGame G;

    G = DarkestHourGame(Level.Game);

    SpawnError = SpawnError_IncorrectRole;

    if (!ROPlayerReplicationInfo(C.PlayerReplicationInfo).RoleInfo.bCanBeTankCrew && VehiclePools[C.VehiclePoolIndex].VehicleClass.default.bMustBeTankCommander)
    {
        return none;
    }

    SpawnError = SpawnError_Fatal;

    if (C == none || C.Pawn != none)
    {
        return none;
    }

    DrySpawnVehicle(C, SpawnLocation, SpawnRotation, SpawnError);

    if (SpawnError != SpawnError_None)
    {
        return none;
    }

    // This calls old restartplayer (spawn in black room) and avoids reinforcment subtraction (because we will subtract later)
    G.DeployRestartPlayer(C, false, true);

    // Make sure player has a pawn
    if (C.Pawn == none)
    {
        Warn("Pawn does not exist!!!! NO PLAYER WAS SPAWNED OR SOMETHING!!!!");

        return none;
    }
    else
    {
        V = Spawn(VehiclePools[C.VehiclePoolIndex].VehicleClass,,, SpawnLocation, SpawnRotation);

        if (V == none)
        {
            SpawnError = SpawnError_Failed;

            return none;
        }

        if (V.IsA('DHWheeledVehicle'))
        {
            DHWheeledVehicle(V).ServerStartEngine();
        }
        else if (V.IsA('DHTreadCraft'))
        {
            DHTreadCraft(V).ServerStartEngine();
        }
    }

    if(!V.TryToDrive(C.Pawn))
    {
        // Try to drive function failed, lets destroy the vehicle
        V.Destroy();

        // Lets slay the player, so they aren't stuck in the black room
        C.Pawn.Suicide();

        SpawnError = SpawnError_TryToDriveFailed;

        return none;
    }
    else
    {
        V.KDriverLeave(true); // Force leave the vehicle to update the position
        C.SpawnVehicle = V; // Set controller SpawnVehicle to be used for delayed re-entry

        //ParentFactory must be set after any calls to Destroy are made so that
        //VehicleDestroyed is not called in the event that TryToDrive fails
        V.ParentFactory = self;

        //Add vehicle to vehicles array
        Vehicles[Vehicles.Length] = V;

        //Increment team vehicle count
        ++TeamVehicleCounts[V.default.VehicleTeam];

        --GRI.MaxTeamVehicles[V.default.VehicleTeam];

        //Update pool properties
        SetPoolNextAvailableTime(C.VehiclePoolIndex, GRI.ElapsedTime + VehiclePools[C.VehiclePoolIndex].RespawnTime);
        SetPoolActiveCount(C.VehiclePoolIndex, VehiclePools[C.VehiclePoolIndex].ActiveCount + 1);
        SetPoolSpawnCount(C.VehiclePoolIndex, VehiclePools[C.VehiclePoolIndex].SpawnCount + 1);

        if (VehiclePools[C.VehiclePoolIndex].OnVehicleSpawnedEvent != '')
        {
            //Trigger OnVehicleSpawned event
            TriggerEvent(VehiclePools[C.VehiclePoolIndex].OnVehicleSpawnedEvent, none, none);
        }
    }

    return V;
}

function Pawn SpawnPlayerAtSpawnVehicle(DHPlayer C, out byte SpawnError)
{
    local DarkestHourGame G;
    local Vehicle V;
    local int i;
    local array<int> ExitPositionIndices;
    local vector Offset;

    G = DarkestHourGame(Level.Game);

    if (G == none)
    {
        return none;
    }

    V = SpawnVehicles[C.SpawnVehicleIndex];

    if (V == none)
    {
        return none;
    }

    // Spawn pawn in black room
    if (C.Pawn == none)
    {
        G.DeployRestartPlayer(C, false, true);
    }

    if (C.Pawn == none)
    {
        return none;
    }

    Offset = C.Pawn.default.CollisionHeight * vect(0.0, 0.0, 0.5);

    // Check if we can spawn at the vehicle
    if (GRI.CanSpawnAtVehicle(C.SpawnVehicleIndex, C))
    {
        ExitPositionIndices = class'DHLib'.static.CreateIndicesArray(V.ExitPositions.Length);
        class'DHLib'.static.FisherYatesShuffle(ExitPositionIndices);

        // Attempt to spawn at exit positions
        for (i = 0; i < ExitPositionIndices.Length; ++i)
        {
            if (TeleportPlayer(C, V.Location + (V.ExitPositions[ExitPositionIndices[i]] >> V.Rotation) + Offset, V.Rotation))
            {
                return C.Pawn;
            }
        }

        // All exit positions were blocked, attempt to just get in the vehicle
        if (!V.TryToDrive(C.Pawn))
        {
            C.Pawn.Suicide();

            return none;
        }
    }
    else
    {
        Warn("Cannot spawn at vehicle");

        C.Pawn.Suicide();
    }

    return C.Pawn;
}

function Pawn SpawnPawn(Controller C, vector SpawnLocation, rotator SpawnRotation)
{
    local DarkestHourGame G;
    local class<Pawn> DefaultPlayerClass;

    G = DarkestHourGame(Level.Game);

    if (G == none)
    {
        return none;
    }

    if (C.PreviousPawnClass != none && C.PawnClass != C.PreviousPawnClass)
    {
        G.BaseMutator.PlayerChangedClass(C);
    }

    if (C.PawnClass != none)
    {
        C.Pawn = Spawn(C.PawnClass,,, SpawnLocation, SpawnRotation);
    }

    if (C.Pawn == none)
    {
        DefaultPlayerClass = G.GetDefaultPlayerClass(C);

        C.Pawn = Spawn(DefaultPlayerClass,,, SpawnLocation, SpawnRotation);
    }

    if (C.Pawn == none)
    {
        // Hard spawning the player at the spawn location failed, most likely because spawn fucntion was blocked
        // Try again with black room spawn and teleport them to spawn location
        G.DeployRestartPlayer(C, false, true);

        //DeployRestartPlayer(Controller C, optional bool bHandleReinforcements, optional bool bUseOldRestart)

        if (C.Pawn != none)
        {
            if (TeleportPlayer(C, SpawnLocation, SpawnRotation))
            {
                return C.Pawn; // Return out as we used old spawn system and don't need to do anything else in this function
            }
            else
            {
                // Teleport failed, the pawn is still in the black room, lets slay them
                C.Pawn.Suicide();
            }
        }
    }

    if (C.Pawn == none)
    {
        Warn("Couldn't spawn player of type" @ C.PawnClass @ "at" @ SpawnLocation);

        C.GotoState('Dead');

        if (PlayerController(C) != none)
        {
            PlayerController(C).ClientGotoState('Dead', 'Begin');
        }

        return none;
    }

    if (PlayerController(C) != none)
    {
        PlayerController(C).TimeMargin = -0.1;
    }

    C.Pawn.LastStartTime = Level.TimeSeconds;
    C.PreviousPawnClass = C.Pawn.Class;
    C.Possess(C.Pawn);
    C.PawnClass = C.Pawn.Class;
    C.Pawn.PlayTeleportEffect(true, true);
    C.ClientSetRotation(C.Pawn.Rotation);

    G.AddDefaultInventory(C.Pawn);

    return C.Pawn;
}

function bool TeleportPlayer(Controller C, vector SpawnLocation, rotator SpawnRotation)
{
    if (C == none)
    {
        Warn(self @ "Teleport failed: no controller passed");

        return false;
    }

    if (C.Pawn != none && C.Pawn.SetLocation(SpawnLocation))
    {
        C.Pawn.SetRotation(SpawnRotation);
        C.Pawn.SetViewRotation(SpawnRotation);
        C.Pawn.ClientSetRotation(SpawnRotation);
        return true;
    }
    else
    {
        Warn(self @ "Teleport failed for" @ C.Pawn.GetHumanReadableName());

        return false;
    }
}

function byte GetSpawnPointError(DHPlayer C, ESpawnPointType SpawnPointType)
{
    local DHSpawnPoint SP;

    if (C.SpawnPointIndex >= SpawnPoints.Length)
    {
        Warn("[DHSM] Fatal error in DrySpawnInfantry (either invalid indices passed in or pool's VehicleClass is none)");

        return SpawnError_Fatal;
    }

    SP = SpawnPoints[C.SpawnPointIndex];

    if (SP == none || (SP.Type != ESPT_Both && SP.Type != SpawnPointType))
    {
        Warn("[DHSM] Fatal error, requested spawn point is null or incorrect type");

        return SpawnError_Fatal;
    }

    if (C.GetTeamNum() != SP.TeamIndex)
    {
        Warn("[DHSM] Spawn point team index (" $ SP.TeamIndex $ ") does not match player's (" $ C.GetTeamNum() $ ")");

        return SpawnError_BadTeamSpawnPoint;
    }

    if (!GRI.IsSpawnPointIndexActive(C.SpawnPointIndex))
    {
        Warn("[DHSM] Spawn point" @ C.SpawnPointIndex @ "is inactive");

        return SpawnError_SpawnInactive;
    }

    if (SP.Type != ESPT_Both && SP.Type != SpawnPointType)
    {
        Warn("Spawnpoint types do not match");

        return SpawnError_SpawnPointsDontMatch;
    }

    return SpawnError_None;
}

function byte GetVehiclePoolError(DHPlayer C, DHSpawnPoint SP)
{
    if (C == none)
    {
        return SpawnError_Fatal;
    }

    if (C.VehiclePoolIndex >= VEHICLE_POOLS_MAX || VehiclePools[C.VehiclePoolIndex].VehicleClass == none)
    {
        Warn("[DHSM] Fatal error in DrySpawn (either invalid indices passed in or pool's VehicleClass is none)");

        return SpawnError_Fatal;
    }

    if (SP == none || (SP.Type != ESPT_Both && SP.Type != ESPT_Vehicles))
    {
        Warn("[DHSM] Fatal error, requested spawn point is null or incorrect type");

        return SpawnError_Fatal;
    }

    if (TeamVehicleCounts[VehiclePools[C.VehiclePoolIndex].VehicleClass.default.VehicleTeam] >= MaxTeamVehicles[VehiclePools[C.VehiclePoolIndex].VehicleClass.default.VehicleTeam])
    {
        Warn("[DHSM] Max vehicles (" $ MaxTeamVehicles[VehiclePools[C.VehiclePoolIndex].VehicleClass.default.VehicleTeam] $ ") reached for team" @ VehiclePools[C.VehiclePoolIndex].VehicleClass.default.VehicleTeam);

        return SpawnError_MaxVehicles;
    }

    if (!VehiclePools[C.VehiclePoolIndex].bIsActive)
    {
        Warn("[DHSM]" @ VehiclePools[C.VehiclePoolIndex].VehicleClass @ "pool is inactive");

        return SpawnError_PoolInactive;
    }

    if (Level.TimeSeconds < VehiclePools[C.VehiclePoolIndex].NextAvailableTime)
    {
        Warn("[DHSM] Cooldown on" @ VehiclePools[C.VehiclePoolIndex].VehicleClass @ "pool:" @ VehiclePools[C.VehiclePoolIndex].NextAvailableTime - Level.TimeSeconds);

        return SpawnError_Cooldown;
    }

    if (VehiclePools[C.VehiclePoolIndex].SpawnCount >= VehiclePools[C.VehiclePoolIndex].MaxSpawns)
    {
        Warn("[DHSM]" @ VehiclePools[C.VehiclePoolIndex].VehicleClass @ "pool is at max spawns (" $ VehiclePools[C.VehiclePoolIndex].MaxSpawns $ ")");

        return SpawnError_SpawnLimit;
    }

    if (VehiclePools[C.VehiclePoolIndex].ActiveCount >= VehiclePools[C.VehiclePoolIndex].MaxActive)
    {
        Warn("[DHSM]" @ VehiclePools[C.VehiclePoolIndex].VehicleClass @ "pool is at active limit (" $ VehiclePools[C.VehiclePoolIndex].MaxActive $ ")");

        return SpawnError_ActiveLimit;
    }

    return SpawnError_None;
}

function DrySpawnInfantry(DHPlayer C, out vector SpawnLocation, out rotator SpawnRotation, out byte SpawnError)
{
    local DHSpawnPoint SP;

    SpawnError = SpawnError_Fatal;

    if (C == none)
    {
        return;
    }

    //Spawn point sanity check
    SpawnError = GetSpawnPointError(C, ESPT_Infantry);

    if (SpawnError != SpawnError_None)
    {
        return;
    }

    SP = SpawnPoints[C.SpawnPointIndex];

    if (SP == none)
    {
        SpawnError = SpawnError_Fatal;

        return;
    }

    switch (SP.Method)
    {
        case ESPM_Hints:
            if (!GetSpawnLocation(SP, Sp.InfantryLocationHints, class'DHPawn'.default.CollisionRadius, SpawnLocation, SpawnRotation))
            {
                SpawnError = SpawnError_Blocked;

                return;
            }

            break;
        case ESPM_Radius:
            SpawnLocation = SP.Location;
            SpawnRotation = SP.Rotation;

            break;
    }

    SpawnError = SpawnError_None;
}

function SpawnInfantry(DHPlayer C, out byte SpawnError)
{
    local DHPawn P;
    local vector SpawnLocation;
    local rotator SpawnRotation;

    SpawnError = SpawnError_Fatal;

    if (C == none || C.Pawn != none)
    {
        return;
    }

    DrySpawnInfantry(C, SpawnLocation, SpawnRotation, SpawnError);

    if (SpawnError != SpawnError_None)
    {
        return;
    }

    P = DHPawn(SpawnPawn(C, SpawnLocation, SpawnRotation));

    if (P == none)
    {
        SpawnError = SpawnError_PawnSpawnFailed;

        return;
    }

    SpawnError = SpawnError_None;
}

event VehicleDestroyed(Vehicle V)
{
    local int i;
    local Controller C;

    super.VehicleDestroyed(V);

    //Removes the destroyed vehicle from the managed vehicles
    for (i = Vehicles.Length - 1; i >= 0; --i)
    {
        if (V == Vehicles[i])
        {
            //Decrement team vehicle count
            --TeamVehicleCounts[Vehicles[i].VehicleTeam];

            ++GRI.MaxTeamVehicles[Vehicles[i].VehicleTeam];

            //Remove vehicle from vehicles array
            Vehicles.Remove(i, 1);

            break;
        }
    }

    //Removes 1 from the count of vehicles in the pool
    for (i = 0; i < VehiclePools.Length; ++i)
    {
        if (V.class == VehiclePools[i].VehicleClass)
        {
            SetPoolActiveCount(i, VehiclePools[i].ActiveCount - 1);

            if (!IsPoolInfinite(i))
            {
                for (C = Level.ControllerList; C != none; C = C.NextController)
                {
                    if (C.GetTeamNum() == VehiclePools[i].VehicleClass.default.VehicleTeam)
                    {
                        C.BroadcastLocalizedMessage(VehicleDestroyedMessageClass,,,, V);
                    }
                }
            }

            if (VehiclePools[i].OnVehicleDestroyedEvent != '')
            {
                TriggerEvent(VehiclePools[i].OnVehicleDestroyedEvent, none, none);
            }

            if (GetPoolSpawnsRemaining(i) <= 0)
            {
                if (VehiclePools[i].OnDepletedEvent != '')
                {
                    TriggerEvent(VehiclePools[i].OnDepletedEvent, none, none);
                }

                if (VehiclePools[i].OnDepleteActivatePool != '')
                {
                    SetPoolIsActiveByTag(VehiclePools[i].OnDepleteActivatePool, true);
                }
            }

            break;
        }
    }

    // Attempt to remove vehicle from spawn vehicles
    RemoveSpawnVehicle(V);
}

//==============================================================================
// Spawn Point Functions
//==============================================================================

private function GetSpawnPointIndicesByTag(name SpawnPointTag, out array<byte> SpawnPointIndices)
{
    local int i;

    for (i = 0; i < SpawnPoints.Length; ++i)
    {
        if (SpawnPoints[i].Tag == SpawnPointTag)
        {
            SpawnPointIndices[SpawnPointIndices.Length] = i;
        }
    }
}

private function SetSpawnPointIsActive(byte SpawnPointIndex, bool bIsActive)
{
    GRI.SetSpawnPointIsActive(SpawnPointIndex, bIsActive);
}

function SetSpawnPointIsActiveByTag(name SpawnPointTag, bool bIsActive)
{
    local int i;
    local array<byte> SpawnPointIndices;

    GetSpawnPointIndicesByTag(SpawnPointTag, SpawnPointIndices);

    for (i = 0; i < SpawnPointIndices.Length; ++i)
    {
        SetSpawnPointIsActive(SpawnPointIndices[i], bIsActive);
    }
}

function ToggleSpawnPointIsActiveByTag(name SpawnPointTag)
{
    local int i;
    local array<byte> SpawnPointIndices;

    GetSpawnPointIndicesByTag(SpawnPointTag, SpawnPointIndices);

    for (i = 0; i < SpawnPointIndices.Length; ++i)
    {
        SetSpawnPointIsActive(SpawnPointIndices[i], !GRI.IsSpawnPointIndexActive(i));
    }
}

//==============================================================================
// Pool Functions
//==============================================================================

private function GetPoolIndicesByTag(name PoolTag, out array<byte> PoolIndices)
{
    local int i;

    for (i = 0; i < VehiclePools.Length; ++i)
    {
        if (VehiclePools[i].Tag == PoolTag)
        {
            PoolIndices[PoolIndices.Length] = i;
        }
    }
}

private function SetPoolNextAvailableTime(byte PoolIndex, float NextAvailableTime)
{
    VehiclePools[PoolIndex].NextAvailableTime = NextAvailableTime;
    GRI.SetVehiclePoolNextAvailableTime(PoolIndex, NextAvailableTime);
}

private function SetPoolActiveCount(byte PoolIndex, byte ActiveCount)
{
    VehiclePools[PoolIndex].ActiveCount = ActiveCount;
    GRI.SetVehiclePoolActiveCount(PoolIndex, ActiveCount);
}

private function byte GetPoolSpawnsRemaining(byte PoolIndex)
{
    if (VehiclePools[PoolIndex].MaxSpawns == 255)
    {
        return 255;
    }

    return VehiclePools[PoolIndex].MaxSpawns - VehiclePools[PoolIndex].SpawnCount;
}

private function SetPoolSpawnCount(byte PoolIndex, byte SpawnCount)
{
    VehiclePools[PoolIndex].SpawnCount = SpawnCount;
    GRI.SetVehiclePoolSpawnsRemaining(PoolIndex, GetPoolSpawnsRemaining(PoolIndex));
}

private function SetPoolMaxSpawns(byte PoolIndex, byte MaxSpawns)
{
    VehiclePools[PoolIndex].MaxSpawns = MaxSpawns;
    GRI.SetVehiclePoolSpawnsRemaining(PoolIndex, GetPoolSpawnsRemaining(PoolIndex));
}

private function SetPoolMaxActive(byte PoolIndex, byte MaxActive)
{
    VehiclePools[PoolIndex].MaxActive = MaxActive;
    GRI.SetVehiclePoolMaxActives(PoolIndex, VehiclePools[PoolIndex].MaxActive);
}

private function AddPoolMaxActive(byte PoolIndex, byte Value)
{
    VehiclePools[PoolIndex].MaxActive += Value;
    GRI.SetVehiclePoolMaxActives(PoolIndex, VehiclePools[PoolIndex].MaxActive);
}

private function AddPoolMaxSpawns(byte PoolIndex, byte Value)
{
    VehiclePools[PoolIndex].MaxSpawns += Value;
    GRI.SetVehiclePoolSpawnsRemaining(PoolIndex, GetPoolSpawnsRemaining(PoolIndex));
}

private function SetPoolIsActive(int PoolIndex, bool bIsActive)
{
    if (VehiclePools[PoolIndex].bIsActive == bIsActive)
    {
        //no change
        return;
    }

    VehiclePools[PoolIndex].bIsActive = bIsActive;
    GRI.SetVehiclePoolIsActive(PoolIndex, bIsActive);

    if (bIsActive)
    {
        if (VehiclePools[PoolIndex].OnActivatedEvent != '')
        {
            TriggerEvent(VehiclePools[PoolIndex].OnActivatedEvent, none, none);
        }
    }
    else
    {
        if (VehiclePools[PoolIndex].OnDeactivatedEvent != '')
        {
            TriggerEvent(VehiclePools[PoolIndex].OnDeactivatedEvent, none, none);
        }
    }
}

function AddPoolMaxSpawnsByTag(name PoolTag, int Value)
{
    local int i;
    local array<byte> PoolIndices;

    GetPoolIndicesByTag(PoolTag, PoolIndices);

    for (i = 0; i < PoolIndices.Length; ++i)
    {
        AddPoolMaxSpawns(PoolIndices[i], Value);
    }
}

function SetPoolMaxSpawnsByTag(name PoolTag, byte MaxSpawns)
{
    local int i;
    local array<byte> PoolIndices;

    GetPoolIndicesByTag(PoolTag, PoolIndices);

    for (i = 0; i < PoolIndices.Length; ++i)
    {
        SetPoolMaxSpawns(PoolIndices[i], MaxSpawns);
    }
}

function AddPoolMaxActiveByTag(name PoolTag, byte Value)
{
    local int i;
    local array<byte> PoolIndices;

    GetPoolIndicesByTag(PoolTag, PoolIndices);

    for (i = 0; i < PoolIndices.Length; ++i)
    {
        AddPoolMaxActive(PoolIndices[i], Value);
    }
}

function SetPoolMaxActiveByTag(name PoolTag, byte Value)
{
    local int i;
    local array<byte> PoolIndices;

    GetPoolIndicesByTag(PoolTag, PoolIndices);

    for (i = 0; i < PoolIndices.Length; ++i)
    {
        SetPoolMaxActive(PoolIndices[i], Value);
    }
}

function SetPoolIsActiveByTag(name PoolTag, bool bIsActive)
{
    local int i;
    local array<byte> PoolIndices;

    GetPoolIndicesByTag(PoolTag, PoolIndices);

    for (i = 0; i < PoolIndices.Length; ++i)
    {
        SetPoolIsActive(PoolIndices[i], bIsActive);
    }
}

function TogglePoolIsActiveByTag(name PoolTag)
{
    local int i;
    local array<byte> PoolIndices;

    GetPoolIndicesByTag(PoolTag, PoolIndices);

    for (i = 0; i < PoolIndices.Length; ++i)
    {
        SetPoolIsActive(PoolIndices[i], !VehiclePools[PoolIndices[i]].bIsActive);
    }
}

function bool IsPoolInfinite(byte PoolIndex)
{
    return VehiclePools[PoolIndex].MaxSpawns == 255;
}

function int GetVehiclePoolCount()
{
    return VehiclePools.Length;
}

function int GetSpawnPointCount()
{
    return SpawnPoints.Length;
}

static function string GetSpawnErrorString(int SpawnError)
{
    //TODO: return correct spawn error strings
    switch (SpawnError)
    {
        case default.SpawnError_None:
        case default.SpawnError_Fatal:
        case default.SpawnError_MaxVehicles:
        case default.SpawnError_Cooldown:
        case default.SpawnError_SpawnLimit:
        case default.SpawnError_ActiveLimit:
        case default.SpawnError_PoolInactive:
        case default.SpawnError_SpawnInactive:
        case default.SpawnError_Blocked:
        case default.SpawnError_Failed:
        case default.SpawnError_BadTeamPool:
        case default.SpawnError_BadTeamSpawnPoint:
        case default.SpawnError_TryToDriveFailed:
        case default.SpawnError_SpawnPointsDontMatch:
            return "ERROR";
    }
}

//==============================================================================
// Spawn Vehicle Functions
//==============================================================================

function bool AddSpawnVehicle(Vehicle V)
{
    local int i;

    if (SpawnVehicles.Length >= SPAWN_VEHICLES_MAX)
    {
        Warn(V @ "could not be added to SpawnVehicles, exceeded limit of" @ SPAWN_VEHICLES_MAX);

        return false;
    }

    i = GRI.AddSpawnVehicle(V, SpawnVehicles.Length);

    if (i == -1)
    {
        Warn(V @ "could not be added to the GRI's SpawnVehicles");

        return false;
    }

    SpawnVehicles[SpawnVehicles.Length] = V;

    return true;
}

function RemoveSpawnVehicle(Vehicle V)
{
    local int i;

    for (i = 0; i < SpawnVehicles.Length; ++i)
    {
        if (SpawnVehicles[i] == V)
        {
            SpawnVehicles.Remove(i, 1);

            break;
        }
    }

    GRI.RemoveSpawnVehicle(V);
}

function int GetSpawnVehicleCount()
{
    return SpawnVehicles.Length;
}

defaultproperties
{
    bDirectional=false
    DrawScale=3.0
    SpawnError_None=0
    SpawnError_Fatal=1
    SpawnError_MaxVehicles=2
    SpawnError_Cooldown=3
    SpawnError_SpawnLimit=4
    SpawnError_ActiveLimit=5
    SpawnError_PoolInactive=6
    SpawnError_SpawnInactive=7
    SpawnError_Blocked=8
    SpawnError_Failed=9
    SpawnError_BadTeamPool=10
    SpawnError_BadTeamSpawnPoint=11
    SpawnError_TryToDriveFailed=12
    SpawnError_BadSpawnType=13
    SpawnError_IncorrectRole=14
    SpawnError_SpawnPointsDontMatch=15
    MaxTeamVehicles(0)=32
    MaxTeamVehicles(1)=32
    VehicleDestroyedMessageClass=class'DHVehicleDestroyedMessage'
    bDebug=false
    SpawnPointType_Infantry=0
    SpawnPointType_Vehicles=1
}

