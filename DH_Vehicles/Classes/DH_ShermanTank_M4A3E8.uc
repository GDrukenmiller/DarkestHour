//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2019
//==============================================================================
// M4A3E8/M4A3(76)W HVSS (Easy Eight) - Upgraded with widetrack Horizontal
// Volute Spring Suspension (HVSS), fitted with the 76mm M1 cannon.
//==============================================================================

class DH_ShermanTank_M4A3E8 extends DH_ShermanTank_M4A376W;

defaultproperties
{
    Mesh=SkeletalMesh'DH_ShermanM4A3E8_anm.body_ext'
    VehicleNameString="Sherman M4A3E8 "

    VehicleHudImage=Texture'DH_ShermanM4A3E8_tex.Menu.body'
    VehicleHudTurret=TexRotator'DH_ShermanM4A3E8_tex.Menu.turret_look'
    VehicleHudTurretLook=TexRotator'DH_ShermanM4A3E8_tex.Menu.turret_rot'
    SpawnOverlay(0)=Texture'DH_ShermanM4A3E8_tex.Menu.sherman_m4a3e8'

    PassengerWeapons(0)=(WeaponPawnClass=class'DH_Vehicles.DH_ShermanCannonPawn_M4A3E8')
    PassengerWeapons(1)=(WeaponPawnClass=class'DH_Vehicles.DH_ShermanMountedMGPawn_M4A3E8')

    DriverPositions(0)=(PositionMesh=SkeletalMesh'DH_ShermanM4A3E8_anm.body_int',TransitionUpAnim="Overlay_Out",ViewPitchUpLimit=1,ViewPitchDownLimit=65535,ViewPositiveYawLimit=5500,ViewNegativeYawLimit=-5500,bDrawOverlays=true)
    DriverPositions(1)=(PositionMesh=SkeletalMesh'DH_ShermanM4A3E8_anm.body_int',TransitionUpAnim="driver_hatch_open",TransitionDownAnim="Overlay_In",ViewPitchUpLimit=3000,ViewPitchDownLimit=61922,ViewPositiveYawLimit=0,ViewNegativeYawLimit=-5500)
    DriverPositions(2)=(PositionMesh=SkeletalMesh'DH_ShermanM4A3E8_anm.body_int',TransitionDownAnim="driver_hatch_close",ViewPitchUpLimit=5000,ViewPitchDownLimit=65000,ViewPositiveYawLimit=16000,ViewNegativeYawLimit=-16000,bExposed=true)

    PassengerPawns(0)=(AttachBone="body",DrivePos=(X=-80.0,Y=-60.0,Z=105.0),DriveRot=(Yaw=-16384),DriveAnim="VHalftrack_Rider4_idle")
    PassengerPawns(1)=(AttachBone="body",DrivePos=(X=-110.0,Y=-30.0,Z=160.0),DriveRot=(Yaw=-16384),DriveAnim="crouch_idle_binoc")
    PassengerPawns(2)=(AttachBone="body",DrivePos=(X=-100.0,Y=40.0,Z=160.0),DriveRot=(Yaw=16384),DriveAnim="crouch_idle_binoc")
    PassengerPawns(3)=(AttachBone="body",DrivePos=(X=-80.0,Y=60.0,Z=105.0),DriveRot=(Yaw=16384),DriveAnim="VHalftrack_Rider5_idle")

    DrivePos=(X=0,Y=0,Z=0)

    DamagedTrackAttachBone="body"
    DamagedTrackStaticMeshLeft=StaticMesh'DH_ShermanM4A3E8_stc.body.tracks_L'
    DamagedTrackStaticMeshRight=StaticMesh'DH_ShermanM4A3E8_stc.body.tracks_R'

    LeftTreadIndex=2
    RightTreadIndex=3

    ExhaustPipes(0)=(ExhaustPosition=(X=-170,Y=-30,Z=0))
    ExhaustPipes(1)=(ExhaustPosition=(X=-170,Y=30,Z=0))

    Skins(0)=Texture'DH_ShermanM4A3E8_tex.body_ext'
    Skins(1)=Texture'DH_ShermanM4A3E8_tex.wheels_ext'
    Skins(2)=Texture'DH_ShermanM4A3E8_tex.tread'
    Skins(3)=Texture'DH_ShermanM4A3E8_tex.tread'
    Skins(4)=FinalBlend'DH_ShermanM4A3E8_tex.body_int_fb'

    LeftTreadPanDirection=(Pitch=1,Yaw=0,Roll=0)
    RightTreadPanDirection=(Pitch=1,Yaw=0,Roll=0)

    LeftLeverBoneName="lever.L"
    RightLeverBoneName="lever.R"

    DestroyedVehicleMesh=StaticMesh'DH_ShermanM4A3E8_stc.Destroyed.m4a3e8_destroyed'

    LeftWheelBones(0)="wheel.L.001"
    LeftWheelBones(1)="wheel.L.002"
    LeftWheelBones(2)="wheel.L.003"
    LeftWheelBones(3)="wheel.L.004"
    LeftWheelBones(4)="wheel.L.005"
    LeftWheelBones(5)="wheel.L.006"
    LeftWheelBones(6)="wheel.L.007"
    LeftWheelBones(7)="wheel.L.008"
    LeftWheelBones(8)="wheel.L.009"
    LeftWheelBones(9)="wheel.L.010"
    LeftWheelBones(10)="wheel.L.011"
    LeftWheelBones(11)="wheel.L.012"
    LeftWheelBones(12)="wheel.L.013"
    RightWheelBones(0)="wheel.R.001"
    RightWheelBones(1)="wheel.R.002"
    RightWheelBones(2)="wheel.R.003"
    RightWheelBones(3)="wheel.R.004"
    RightWheelBones(4)="wheel.R.005"
    RightWheelBones(5)="wheel.R.006"
    RightWheelBones(6)="wheel.R.007"
    RightWheelBones(7)="wheel.R.008"
    RightWheelBones(8)="wheel.R.009"
    RightWheelBones(9)="wheel.R.010"
    RightWheelBones(10)="wheel.R.011"
    RightWheelBones(11)="wheel.R.012"
    RightWheelBones(12)="wheel.R.013"

    FireAttachBone="driver_attachment"

    // Physics wheels
    Begin Object Class=SVehicleWheel Name=LF_Steering
        bPoweredWheel=true
        SteerType=VST_Steered
        BoneName="steer.L.F"
        BoneRollAxis=AXIS_Y
        WheelRadius=32.0
        bLeftTrack=true
    End Object
    Wheels(0)=SVehicleWheel'DH_Vehicles.DH_ShermanTank_M4A3E8.LF_Steering'
    Begin Object Class=SVehicleWheel Name=RF_Steering
        bPoweredWheel=true
        SteerType=VST_Steered
        BoneName="steer.R.F"
        BoneRollAxis=AXIS_Y
        WheelRadius=32.0
    End Object
    Wheels(1)=SVehicleWheel'DH_Vehicles.DH_ShermanTank_M4A3E8.RF_Steering'
    Begin Object Class=SVehicleWheel Name=LR_Steering
        bPoweredWheel=true
        SteerType=VST_Inverted
        BoneName="steer.L.B"
        BoneRollAxis=AXIS_Y
        WheelRadius=32.0
        bLeftTrack=true
    End Object
    Wheels(2)=SVehicleWheel'DH_Vehicles.DH_ShermanTank_M4A3E8.LR_Steering'
    Begin Object Class=SVehicleWheel Name=RR_Steering
        bPoweredWheel=true
        SteerType=VST_Inverted
        BoneName="steer.R.B"
        BoneRollAxis=AXIS_Y
        WheelRadius=32.0
    End Object
    Wheels(3)=SVehicleWheel'DH_Vehicles.DH_ShermanTank_M4A3E8.RR_Steering'
    Begin Object Class=SVehicleWheel Name=Left_Drive_Wheel
        bPoweredWheel=true
        BoneName="drive.L"
        BoneRollAxis=AXIS_Y
        WheelRadius=32.0
        bLeftTrack=true
    End Object
    Wheels(4)=SVehicleWheel'DH_Vehicles.DH_ShermanTank_M4A3E8.Left_Drive_Wheel'
    Begin Object Class=SVehicleWheel Name=Right_Drive_Wheel
        bPoweredWheel=true
        BoneName="drive.R"
        BoneRollAxis=AXIS_Y
        WheelRadius=32.0
    End Object
    Wheels(5)=SVehicleWheel'DH_Vehicles.DH_ShermanTank_M4A3E8.Right_Drive_Wheel'
}
