//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2016
//==============================================================================

class DH_30calFire extends DHMGAutomaticFire;

defaultproperties
{
    FireEndSound=SoundGroup'DH_WeaponSounds.30Cal.30cal_FireEnd01'
    AmbientFireSoundRadius=750.0
    AmbientFireSound=SoundGroup'DH_WeaponSounds.30Cal.30cal_FireLoop01'
    AmbientFireVolume=255
    PackingThresholdTime=0.12
    ProjSpawnOffset=(X=25.0)
    FAProjSpawnOffset=(X=-145.0,Y=-15.0,Z=-15.0)
    bUsesTracers=true
    TracerFrequency=5
    TracerProjectileClass=class'DH_30CalTracerBullet'
    FireIronAnim="Shoot_Loop"
    FireIronLoopAnim="Shoot_Loop"
    FireIronEndAnim="Shoot_End"
    MaxVerticalRecoilAngle=500
    MaxHorizontalRecoilAngle=250
    RecoilRate=0.04
    ShellEjectClass=class'ROAmmo.ShellEject1st762x54mm'
    ShellIronSightOffset=(X=15.0,Z=-6.0)
    ShellRotOffsetIron=(Pitch=-1500)
    FireAnim="Shoot_Loop"
    FireLoopAnim="Shoot_Loop"
    FireEndAnim="Shoot_End"
    TweenTime=0.0
    FireRate=0.12
    AmmoClass=class'DH_Weapons.DH_30CalAmmo'
    ShakeRotMag=(X=25.0,Y=25.0,Z=25.0)
    ShakeRotRate=(X=5000.0,Y=5000.0,Z=5000.0)
    ShakeRotTime=1.75
    ShakeOffsetMag=(X=3.0,Y=1.0,Z=3.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=2.0
    ProjectileClass=class'DH_Weapons.DH_30calBullet'
    BotRefireRate=0.99
    WarnTargetPct=0.9
    FlashEmitterClass=class'ROEffects.MuzzleFlash1stMG'
    AimError=1800.0
    Spread=125.0
    SpreadStyle=SS_Random
}
