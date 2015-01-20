//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2014
//==============================================================================

class DH_JagdpanzerIVL70Cannon extends DH_ROTankCannon;

defaultproperties
{
    InitialTertiaryAmmo=15
    TertiaryProjectileClass=class'DH_Vehicles.DH_JagdpanzerIVL70CannonShellHE'
    SecondarySpread=0.001200
    ManualRotationsPerSecond=0.025000
    PoweredRotationsPerSecond=0.025000
    bIsAssaultGun=true
    GunMantletArmorFactor=8.000000
    GunMantletSlope=40.000000
    FrontArmorFactor=8.000000
    RightArmorFactor=8.000000
    LeftArmorFactor=8.000000
    RearArmorFactor=8.000000
    FrontArmorSlope=40.000000
    RightArmorSlope=40.000000
    LeftArmorSlope=40.000000
    RearArmorSlope=40.000000
    FrontLeftAngle=293.000000
    FrontRightAngle=67.000000
    RearRightAngle=113.000000
    RearLeftAngle=247.000000
    ReloadSoundOne=sound'Vehicle_reloads.Reloads.STUG_III_reload_01'
    ReloadSoundTwo=sound'Vehicle_reloads.Reloads.STUG_III_reload_02'
    ReloadSoundThree=sound'Vehicle_reloads.Reloads.STUG_III_reload_03'
    ReloadSoundFour=sound'Vehicle_reloads.Reloads.STUG_III_reload_04'
    CannonFireSound(0)=SoundGroup'Vehicle_Weapons.Panther.75mm_VL_fire01'
    CannonFireSound(1)=SoundGroup'Vehicle_Weapons.Panther.75mm_VL_fire02'
    CannonFireSound(2)=SoundGroup'Vehicle_Weapons.Panther.75mm_VL_fire03'
    ProjectileDescriptions(0)="APCBC"
    ProjectileDescriptions(1)="APCR"
    ProjectileDescriptions(2)="HE"
    RangeSettings(1)=100
    RangeSettings(2)=200
    RangeSettings(3)=300
    RangeSettings(4)=400
    RangeSettings(5)=500
    RangeSettings(6)=600
    RangeSettings(7)=700
    RangeSettings(8)=800
    RangeSettings(9)=900
    RangeSettings(10)=1000
    RangeSettings(11)=1100
    RangeSettings(12)=1200
    RangeSettings(13)=1300
    RangeSettings(14)=1400
    RangeSettings(15)=1500
    RangeSettings(16)=1600
    RangeSettings(17)=1700
    RangeSettings(18)=1800
    RangeSettings(19)=1900
    RangeSettings(20)=2000
    RangeSettings(21)=2200
    RangeSettings(22)=2400
    RangeSettings(23)=2600
    RangeSettings(24)=2800
    RangeSettings(25)=3000
    MinCommanderHitHeight=18.0 // note there is no other collision box (e.g. mantlet) so every hit on the jagdpanzer IV cannon is actually a hit on commander's collision box
    VehHitpoints(0)=(PointRadius=9.000000,PointScale=1.000000,PointBone="com_player",PointOffset=(X=-1.000000,Z=-1.000000))
    YawBone="Turret"
    YawStartConstraint=-3000.000000
    YawEndConstraint=3000.000000
    PitchBone="Turret"
    PitchUpLimit=15000
    PitchDownLimit=45000
    WeaponFireAttachmentBone="Barrel"
    GunnerAttachmentBone="Commander_attachment"
    WeaponFireOffset=10.000000
    FireInterval=7.000000
    EffectEmitterClass=class'ROEffects.TankCannonFireEffect'
    FireSoundVolume=512.000000
    RotateSound=sound'Vehicle_Weapons.Turret.manual_gun_traverse'
    FireForce="Explosion05"
    ProjectileClass=class'DH_Vehicles.DH_JagdpanzerIVL70CannonShell'
    ShakeRotMag=(Z=50.000000)
    ShakeRotRate=(Z=1000.000000)
    ShakeRotTime=4.000000
    ShakeOffsetMag=(Z=1.000000)
    ShakeOffsetRate=(Z=100.000000)
    ShakeOffsetTime=10.000000
    AIInfo(0)=(bLeadTarget=true,WarnTargetPct=0.750000,RefireRate=0.500000)
    AIInfo(1)=(bLeadTarget=true,WarnTargetPct=0.750000,RefireRate=0.015000)
    CustomPitchUpLimit=2731
    CustomPitchDownLimit=64653
    MaxPositiveYaw=1820
    MaxNegativeYaw=-1820
    bLimitYaw=true
    BeginningIdleAnim="Overlay_Idle"
    InitialPrimaryAmmo=35
    InitialSecondaryAmmo=5
    PrimaryProjectileClass=class'DH_Vehicles.DH_JagdpanzerIVL70CannonShell'
    SecondaryProjectileClass=class'DH_Vehicles.DH_JagdpanzerIVL70CannonShellAPCR'
    Mesh=SkeletalMesh'DH_Jagdpanzer4_anm.jagdpanzer4L70_turret_ext'
    Skins(0)=texture'DH_VehiclesGE_tex4.ext_vehicles.jagdpanzeriv_body_camo1'
    Skins(1)=texture'DH_VehiclesGE_tex4.int_vehicles.jagdpanzeriv_body_int'
    Skins(2)=texture'DH_VehiclesGE_tex4.int_vehicles.jagdpanzeriv_body_int'
    SoundVolume=130
    SoundRadius=200.000000
}
