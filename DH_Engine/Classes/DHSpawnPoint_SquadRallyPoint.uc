//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2018
//==============================================================================

class DHSpawnPoint_SquadRallyPoint extends DHSpawnPointBase
    notplaceable;

#exec OBJ LOAD FILE=..\StaticMeshes\DH_Construction_stc.usx

var DHSquadReplicationInfo SRI;                 // Convenience variable to access the SquadReplicationInfo.
var int SquadIndex;                             // The squad index of the squad that owns this rally point.
var int RallyPointIndex;                        // The index into SRI.RallyPoints.
var int SpawnsRemaining;                        // The amount of spawns remaining on the rally point.

// Creation
var float CreatedTimeSeconds;                   // The time (relative to Level.TimeSeconds) that this rally point was created
var sound CreationSound;                        // Sound that is played when the squad rally point is first placed.

// Establishment
var int   EstablishmentRadiusInMeters;          // The distance, in meters, that squadmates and enemies must be within to influence the EstablishmentCounter.
var float EstablishmentStartTimeSeconds;        // The value of Level.TimeSeconds when this rally point began Establishment.
var float EstablishmentCounter;                 // Running counter to keep track of Establishment status.
var float EstablishmentCounterThreshold;        // The value that EstablishmentCounter must reach for the rally point to be "established".

// Overrun
var int   OverrunRadiusInMeters;                // The distance, in meters, that enemies must be within to immediately overrun a rally point.
var float OverrunMinimumTimeSeconds;            // The number of seconds a rally point must be "alive" for in order to be overrun by enemies. (To stop squad rally points being used as "enemy radar".

// Abandonment
var bool bCanSendAbandonmentWarningMessage;     // Whether or not we should send the abandonment message the next time the squad rally point has no teammates nearby while establishing

// Accrual timer (used for adding available spawns at regular intervals)
var int SpawnAccrualTimer;
var int SpawnAccrualThreshold;

// Health
var int Health;

// Instigator
var DHPlayer InstigatorController;

// Metrics
var DHMetricsRallyPoint MetricsObject;

// Objective
var ROObjective Objective;
var bool bIsInActiveObjective;
var int InActiveObjectivePenaltySeconds;

replication
{
    reliable if (bNetDirty && Role == ROLE_Authority)
        SquadIndex, RallyPointIndex, SpawnsRemaining, bIsInActiveObjective;
}

function Reset()
{
    // TODO: set destroyed reason?
    Destroy();
}

function PostBeginPlay()
{
    local int i;

    super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        SRI = DarkestHourGame(Level.Game).SquadReplicationInfo;

        CreatedTimeSeconds = Level.TimeSeconds;

        if (SRI == none)
        {
            Destroy();
        }

        PlaySound(CreationSound, SLOT_None, 4.0,, 60.0,, true);

        if (GRI != none)
        {
            for (i = 0; i < arraycount(GRI.Objectives); ++i)
            {
                if (GRI.Objectives[i] != none && GRI.Objectives[i].WithinArea(self))
                {
                    // We'll make a bold assumption that it's not really possible
                    // to be in multiple objectives at once and just stop at one.
                    Objective = GRI.Objectives[i];
                    break;
                }
            }
        }
    }
}

auto state Constructing
{
    function Timer()
    {
        local int SquadmateCount;
        local int EnemyCount;
        local bool bIsBeingAbandoned;

        global.Timer();

        GetPlayerCountsWithinRadius(default.EstablishmentRadiusInMeters, SquadIndex, SquadmateCount, EnemyCount);

        EstablishmentCounter -= EnemyCount;
        EstablishmentCounter += SquadmateCount;

        if (bCanSendAbandonmentWarningMessage && SquadmateCount == 0)
        {
            // "A newly created squad rally point is being abandoned!"
            SRI.BroadcastSquadLocalizedMessage(GetTeamIndex(), SquadIndex, SRI.SquadMessageClass, 58);

            bCanSendAbandonmentWarningMessage = false;
        }
        else if (SquadmateCount > 0)
        {
            bCanSendAbandonmentWarningMessage = true;
        }

        if (SquadmateCount == 0 && EnemyCount == 0)
        {
            // No one is around to establish the rally point, start depleting the counter.
            bIsBeingAbandoned = true;
            EstablishmentCounter -= 1;
        }

        if (EstablishmentCounter >= default.EstablishmentCounterThreshold)
        {
            // Rally point exceeded the Establishment counter threshold. This
            // rally point is now established!
            GotoState('Active');
        }
        else if (EstablishmentCounter <= 0)
        {
            // Delay destruction of the rally point so it can't be used as enemy radar.
            if (Level.TimeSeconds - EstablishmentStartTimeSeconds > default.OverrunMinimumTimeSeconds)
            {
                // "A squad rally point failed to be established."
                SRI.BroadcastSquadLocalizedMessage(GetTeamIndex(), SquadIndex, SRI.SquadMessageClass, 55);

                if (MetricsObject != none)
                {
                    if (bIsBeingAbandoned)
                    {
                        MetricsObject.DestroyedReason = REASON_Abandoned;
                    }
                    else
                    {
                        MetricsObject.DestroyedReason = REASON_Encroached;
                    }
                }

                Destroy();
            }
        }
    }

Begin:
    EstablishmentStartTimeSeconds = Level.TimeSeconds;
}

function Timer()
{
    local int OverrunningEnemiesCount;

    super.Timer();

    GetPlayerCountsWithinRadius(OverrunRadiusInMeters,,, OverrunningEnemiesCount);

    // Destroy the rally point immediately if there are enemies within a
    // very short distance.
    if (OverrunningEnemiesCount >= 1)
    {
        // "A squad rally point has been overrun by enemies."
        SRI.BroadcastSquadLocalizedMessage(GetTeamIndex(), SquadIndex, SRI.SquadMessageClass, 54);

        if (MetricsObject != none)
        {
            MetricsObject.DestroyedReason = REASON_Overrun;
        }

        Destroy();
    }

    // Update the "in active objective" status.
    bIsInActiveObjective = Objective != none && Objective.IsActive();
}

state Active
{
    event BeginState()
    {
        SetIsActive(true);

        AwardScoreOnEstablishment();

        UpdateAppearance();

        if (MetricsObject != none)
        {
            MetricsObject.IsEstablished = true;
        }
    }
}

function OnOverrunByEncroachment()
{
    // "A squad rally point has been overrun by enemies."
    SRI.BroadcastSquadLocalizedMessage(GetTeamIndex(), SquadIndex, SRI.SquadMessageClass, 54);

    if (MetricsObject != none)
    {
        MetricsObject.DestroyedReason = REASON_Encroached;
    }

    Destroy();
}

function SetIsActive(bool bIsActive)
{
    super.SetIsActive(bIsActive);

    if (SRI != none && bIsActive)
    {
        SRI.OnSquadRallyPointActivated(self);
    }
}

simulated function bool CanSpawnWithParameters(DHGameReplicationInfo GRI, int TeamIndex, int RoleIndex, int SquadIndex, int VehiclePoolIndex, optional bool bSkipTimeCheck)
{
    if (!super.CanSpawnWithParameters(GRI, TeamIndex, RoleIndex, SquadIndex, VehiclePoolIndex, bSkipTimeCheck))
    {
        return false;
    }

    if (self.SquadIndex != SquadIndex)
    {
        return false;
    }

    if (SpawnsRemaining == 1)
    {
        // TODO: must be SL to use; where are we gonna get this from? a PRI??
    }

    return true;
}

simulated function bool IsVisibleTo(int TeamIndex, int RoleIndex, int SquadIndex, int VehiclePoolIndex)
{
    return super.IsVisibleTo(TeamIndex, RoleIndex, SquadIndex, VehiclePoolIndex) && self.SquadIndex == SquadIndex;
}

function OnPawnSpawned(Pawn P)
{
    SpawnsRemaining -= 1;

    if (InstigatorController != none &&
        InstigatorController != P.Controller &&
        InstigatorController.GetTeamNum() == GetTeamIndex() &&
        InstigatorController.GetSquadIndex() == SquadIndex)
    {
        InstigatorController.ReceiveScoreEvent(class'DHScoreEvent_SquadRallyPointSpawn'.static.Create());
    }

    if (MetricsObject != none)
    {
        ++MetricsObject.SpawnCount;
    }

    if (SpawnsRemaining <= 0)
    {
        // "A squad rally point has been exhausted."
        SRI.BroadcastSquadLocalizedMessage(GetTeamIndex(), SquadIndex, SRI.SquadMessageClass, 46);

        if (MetricsObject != none)
        {
            MetricsObject.DestroyedReason = REASON_Exhausted;
        }

        Destroy();
    }
}

function OnSpawnKill(Pawn VictimPawn, Controller KillerController)
{
    if (KillerController != none && KillerController.GetTeamNum() != GetTeamIndex())
    {
        // "A squad rally point has been overrun by enemies."
        SRI.BroadcastSquadLocalizedMessage(GetTeamIndex(), SquadIndex, SRI.SquadMessageClass, 54);

        if (MetricsObject != none)
        {
            MetricsObject.DestroyedReason = REASON_SpawnKill;
        }

        Destroy();
    }
}

function UpdateAppearance()
{
    local DarkestHourGame G;
    local DH_LevelInfo.EAlliedNation AlliedNation;
    local StaticMesh NewStaticMesh;

    G = DarkestHourGame(Level.Game);

    if (G != none && G.DHLevelInfo != none)
    {
        AlliedNation = G.DHLevelInfo.AlliedNation;
    }

    if (IsActive())
    {
        switch (GetTeamIndex())
        {
        case AXIS_TEAM_INDEX:
            NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.GER_backpack_established';
            break;
        case ALLIES_TEAM_INDEX:
            switch (AlliedNation)
            {
            case NATION_Britain:
                NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.BRIT_backpack_established';
                break;
            case NATION_Canada:
                NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.CAN_backpack_established';
                break;
            case NATION_USSR:
                NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.RUS_backpack_established';
                break;
            default:
                NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.USA_backpack_established';
                break;
            }
        default:
            break;
        }
    }
    else
    {
        switch (GetTeamIndex())
        {
        case AXIS_TEAM_INDEX:
            NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.GER_backpack';
            break;
        case ALLIES_TEAM_INDEX:
            switch (AlliedNation)
            {
            case NATION_Britain:
                NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.BRIT_backpack';
                break;
            case NATION_Canada:
                NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.CAN_backpack';
                break;
            case NATION_USSR:
                NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.RUS_backpack';
                break;
            default:
                NewStaticMesh = StaticMesh'DH_Construction_stc.Backpacks.USA_backpack';
                break;
            }
        default:
            break;
        }
    }

    SetStaticMesh(NewStaticMesh);
}

function OnTeamIndexChanged()
{
    UpdateAppearance();
}

simulated function string GetMapText()
{
    return string(SpawnsRemaining);
}

simulated function int GetSpawnTimePenalty()
{
    local int SpawnTimePenalty;

    SpawnTimePenalty = BaseSpawnTimePenalty;

    if (bIsEncroachedUpon)
    {
        SpawnTimePenalty += EncroachmentSpawnTimePenalty;
    }

    if (bIsInActiveObjective)
    {
        SpawnTimePenalty += InActiveObjectivePenaltySeconds;
    }

    return SpawnTimePenalty;
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    if (EventInstigator == none || EventInstigator.GetTeamNum() == GetTeamIndex())
    {
        // You cannot damage your own rally points.
        return;
    }

    Health -= Damage;

    if (Health <= 0)
    {
        // "A squad rally point has been destroyed."
        SRI.BroadcastSquadLocalizedMessage(GetTeamIndex(), SquadIndex, SRI.SquadMessageClass, 68);

        if (MetricsObject != none)
        {
            MetricsObject.DestroyedReason = REASON_Damaged;
        }

        Destroy();
    }
}

// Give nearby squadmates points for helping establish the rally point.
function AwardScoreOnEstablishment()
{
    local Pawn P;
    local DHPlayer PC;
    local DHPlayerReplicationInfo PRI;
    local int EstablisherCount;

    EstablisherCount = 1;

    foreach RadiusActors(class'Pawn', P, class'DHUnits'.static.MetersToUnreal(EstablishmentRadiusInMeters))
    {
        if (P != none && !P.bDeleteMe && P.Health > 0 && P.PlayerReplicationInfo != none && P.GetTeamNum() == GetTeamIndex())
        {
            PC = DHPlayer(P.Controller);

            if (PC != none)
            {
                PRI = DHPlayerReplicationInfo(PC.PlayerReplicationInfo);

                // Don't award the SL himself, he gets his own award.
                if (PRI != none && !PRI.IsSquadLeader() && PC.GetSquadIndex() == SquadIndex)
                {
                    PC.ReceiveScoreEvent(class'DHScoreEvent_SquadRallyPointEstablishedAssist'.static.Create());

                    ++EstablisherCount;
                }
            }
        }
    }

    if (MetricsObject != none)
    {
        MetricsObject.EstablisherCount = EstablisherCount;
    }
}

function Destroyed()
{
    super.Destroyed();

    if (MetricsObject != none)
    {
        MetricsObject.DestroyedAt = class'DateTime'.static.Now(self);
    }
}

defaultproperties
{
    SpawnPointStyle="DHRallyPointButtonStyle"

    StaticMesh=StaticMesh'DH_Construction_stc.Backpacks.USA_backpack'
    DrawType=DT_StaticMesh
    TeamIndex=-1
    SquadIndex=-1
    RallyPointIndex=-1
    CreationSound=Sound'Inf_Player.Gibimpact.Gibimpact'

    bCanBeEncroachedUpon=true
    EncroachmentRadiusInMeters=50
    EncroachmentPenaltyMax=30
    EncroachmentPenaltyBlockThreshold=15
    EncroachmentPenaltyOverrunThreshold=30
    EncroachmentSpawnTimePenalty=15
    EncroachmentEnemyCountMin=3
    EncroachmentPenaltyForgivenessPerSecond=5
    bCanEncroachmentOverrun=true

    InActiveObjectivePenaltySeconds=10

    OverrunRadiusInMeters=15
    EstablishmentRadiusInMeters=25
    EstablishmentCounterThreshold=15
    OverrunMinimumTimeSeconds=15
    SpawnAccrualThreshold=30
    bHidden=false
    bCanSendAbandonmentWarningMessage=true
    bCombatSpawn=true
    SpawnRadius=60.0
    SpawnLocationOffset=(Z=52)
    SpawnProtectionTime=1.0
    SpawnKillProtectionTime=8.0
    bShouldTraceCheckSpawnLocations=true
    Health=150
    bShouldDelegateTimer=true
    bCanBeDamaged=true
    bBlockZeroExtentTraces=true
    bBlockNonZeroExtentTraces=false
    bBlockProjectiles=true
    bCollideActors=true
    bCollideWorld=false
    bBlockActors=true
    bBlockKarma=false
}

