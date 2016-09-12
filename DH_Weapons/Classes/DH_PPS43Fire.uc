//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2016
//==============================================================================

class DH_PPS43Fire extends DHFastAutoFire;

defaultproperties
{
    FireEndSound=SoundGroup'Inf_Weapons.pps43.pps43_fire_end'
    AmbientFireSoundRadius=750.0
    AmbientFireSound=SoundGroup'Inf_Weapons.pps43.pps43_fire_loop'
    AmbientFireVolume=255
    //compile error  ServerProjectileClass=class'DH_Weapons.DH_PPS43Bullet_S'
    ProjSpawnOffset=(X=25.0)
    FAProjSpawnOffset=(X=-20.0)
    FireIronAnim="Iron_Shoot_Loop"
    FireIronLoopAnim="Iron_Shoot_Loop"
    FireIronEndAnim="Iron_Shoot_End"
    MaxVerticalRecoilAngle=675
    MaxHorizontalRecoilAngle=120
    RecoilRate=0.05
    ShellEjectClass=class'ROAmmo.ShellEject1st762x25mm'
    ShellIronSightOffset=(X=15.0)
    ShellRotOffsetIron=(Pitch=5000)
    PreFireAnim="Shoot1_start"
    FireAnim="Shoot_Loop"
    FireLoopAnim="Shoot_Loop"
    FireEndAnim="Shoot_End"
    TweenTime=0.0
    FireRate=0.0857
    AmmoClass=class'ROAmmo.PPS43Ammo'
    ShakeRotMag=(X=50.0,Y=50.0,Z=150.0)
    ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
    ShakeRotTime=0.5
    ShakeOffsetMag=(X=3.0,Y=1.0,Z=3.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=1.0
    ProjectileClass=class'DH_Weapons.DH_PPS43Bullet'
    BotRefireRate=0.99
    WarnTargetPct=0.9
    FlashEmitterClass=class'ROEffects.MuzzleFlash1stPPSH'
    SmokeEmitterClass=class'ROEffects.ROMuzzleSmoke'
    AimError=1200.0
    Spread=340.0
    SpreadStyle=SS_Random
}
