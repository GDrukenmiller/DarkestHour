//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2019
//==============================================================================

class DH_ShermanCannon_M4A3E8_Fury extends DH_ShermanCannon_M4A3E8;

var StaticMesh StowageStaticMesh;

simulated function PostBeginPlay()
{
    local DHDecoAttachment StowageAttachment;

    super.PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        StowageAttachment = Spawn(class'DHDecoAttachment', self);

        if (StowageAttachment != none)
        {
            StowageAttachment.SetStaticMesh(StowageStaticMesh);
            AttachToBone(StowageAttachment, 'turret');
        }
    }
}

defaultproperties
{
    StowageStaticMesh=StaticMesh'DH_ShermanM4A3E8_stc.turret.turret_stowage'
}
