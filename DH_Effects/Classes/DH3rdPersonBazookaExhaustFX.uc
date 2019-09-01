//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2019
//==============================================================================

class DH3rdPersonBazookaExhaustFX extends Emitter;

defaultproperties
{
    //AutoDestroy=true
    //bLightChanged=true
    //bNoDelete=false
    //LifeSpan=8.0
    //Style=STY_Masked
    //bHardAttach=true

    bLightChanged=True
    AutoDestroy=True
    Style=STY_Masked
    bUnlit=true
    bDirectional=True
    bNoDelete=false
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=true
    bHardAttach=true
    LifeSpan=8.0

//    bUnlit=False
//    bNoDelete=False
//    bHardAttach=True
//  RemoteRole=ROLE_None
//  Physics=PHYS_None
//  bBlockActors=False
//  CullDistance=20000.0
//  Style=STY_Additive

    bSelected=True

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=192,G=192,R=192))
        MaxParticles=15
        Opacity=0.50
        Name="Smoke"
        StartLocationOffset=(X=-20.000000)
        StartLocationRange=(X=(Min=-5.000000,Max=5.000000))
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
        InitialParticlesPerSecond=50000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.explosions.LSmoke1'
        LifetimeRange=(Min=2.500000,Max=3.500000)
        StartVelocityRange=(X=(Min=-300.000000,Max=-1500.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=1.000000,Max=5.000000),Y=(Min=1.000000,Max=5.000000),Z=(Min=1.000000,Max=5.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.125000,RelativeVelocity=(X=0.200000,Y=0.200000,Z=0.200000))
        VelocityScale(2)=(RelativeTime=1.000000)
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(X=100.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.500000
        FadeOutStartTime=0.098000
        FadeInEndTime=0.080000
        MaxParticles=10
        Name="rear flash"
        StartLocationOffset=(X=-50.000000)
        StartLocationShape=PTLS_Sphere
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=8.000000)
        StartSizeRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=3.000000,Max=5.000000),Z=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'Effects_Tex.explosions.impact_2frame'
        TextureUSubdivisions=2
        TextureVSubdivisions=1
        LifetimeRange=(Min=0.200000,Max=0.300000)
        StartVelocityRange=(X=(Min=-200.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'
/*
    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(X=100.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.500000
        FadeOutStartTime=0.098000
        FadeInEndTime=0.080000
        MaxParticles=8
        Name="exhaust"
        StartLocationOffset=(X=-50.000000)
        StartLocationShape=PTLS_Sphere
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=8.000000)
        StartSizeRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=3.000000,Max=5.000000),Z=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'Effects_Tex.Weapons.PTRDmuzzle_2frame'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.200000,Max=0.300000)
        StartVelocityRange=(X=(Min=-200.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter2'
*/
    Begin Object Class=BeamEmitter Name=BeamEmitter0
        BeamDistanceRange=(Min=2.000000,Max=200.000000)
        DetermineEndPointBy=PTEP_Velocity
        RotatingSheets=3
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.040000
        FadeOutStartTime=0.060000
        FadeInEndTime=0.007500
        MaxParticles=8
        UseRotationFrom=PTRS_Actor
        StartSizeRange=(X=(Max=200.000000),Y=(Max=200.000000),Z=(Max=200.000000))
        Texture=Texture'DH_FX_Tex.Effects.Spotlight'
        LifetimeRange=(Min=0.100000,Max=0.300000)
        StartVelocityRange=(X=(Min=-400.000000,Max=-200.000000))
    End Object
    Emitters(2)=BeamEmitter'BeamEmitter0'
}
