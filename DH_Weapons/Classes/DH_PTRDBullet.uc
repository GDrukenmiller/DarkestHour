//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2016
//==============================================================================

class DH_PTRDBullet extends DHBullet;

// General
var     vector          LaunchLocation;
var     byte            HitCount;                // how many times we have hit something
var     bool            bDebuggingText;

// Penetration/deflection
var     float           DHPenetrationTable[11];
var     float           ShellDiameter;           // to assist in T/d calculations
var     sound           VehicleHitSound;
var()   class<Emitter>  ShellHitVehicleEffectClass;

// Damage
var   class<DamageType> ShellImpactDamage;
var     int             ImpactDamage;

// Shatter
var     bool            bShatterProne;           // assists with shatter gap calculations
var()   class<Emitter>  ShellShatterEffectClass; // effect for this shell shattering against a vehicle
var     sound           ShatterVehicleHitSound;  // sound of this shell shattering on the vehicle
var     sound           ShatterSound[4];         // sound of the round exploding

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    LaunchLocation = Location;
}

simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    // Bit of a hack, bCollideActors gets replicated too soon so we don't get the hitwall call client side to do our hit effects
    if (HitCount == 0 && !bCollideActors && Level.NetMode == NM_Client)
    {
        SetCollision(true, true);
    }
}

// Borrowed from AB: just using a standard linear interpolation equation here
simulated function float GetPenetration(vector Distance)
{
    local float MeterDistance, PenetrationNumber;

    MeterDistance = VSize(Distance) / 60.352;

    if      (MeterDistance < 100.0)  PenetrationNumber = (DHPenetrationTable[0]  + (100.0  - MeterDistance) * (DHPenetrationTable[0] - DHPenetrationTable[1])  / 100.0);
    else if (MeterDistance < 250.0)  PenetrationNumber = (DHPenetrationTable[1]  + (250.0  - MeterDistance) * (DHPenetrationTable[0] - DHPenetrationTable[1])  / 150.0);
    else if (MeterDistance < 500.0)  PenetrationNumber = (DHPenetrationTable[2]  + (500.0  - MeterDistance) * (DHPenetrationTable[1] - DHPenetrationTable[2])  / 250.0);
    else if (MeterDistance < 750.0)  PenetrationNumber = (DHPenetrationTable[3]  + (750.0  - MeterDistance) * (DHPenetrationTable[2] - DHPenetrationTable[3])  / 250.0);
    else if (MeterDistance < 1000.0) PenetrationNumber = (DHPenetrationTable[4]  + (1000.0 - MeterDistance) * (DHPenetrationTable[3] - DHPenetrationTable[4])  / 250.0);
    else if (MeterDistance < 1250.0) PenetrationNumber = (DHPenetrationTable[5]  + (1250.0 - MeterDistance) * (DHPenetrationTable[4] - DHPenetrationTable[5])  / 250.0);
    else if (MeterDistance < 1500.0) PenetrationNumber = (DHPenetrationTable[6]  + (1500.0 - MeterDistance) * (DHPenetrationTable[5] - DHPenetrationTable[6])  / 250.0);
    else if (MeterDistance < 1750.0) PenetrationNumber = (DHPenetrationTable[7]  + (1750.0 - MeterDistance) * (DHPenetrationTable[6] - DHPenetrationTable[7])  / 250.0);
    else if (MeterDistance < 2000.0) PenetrationNumber = (DHPenetrationTable[8]  + (2000.0 - MeterDistance) * (DHPenetrationTable[7] - DHPenetrationTable[8])  / 250.0);
    else if (MeterDistance < 2500.0) PenetrationNumber = (DHPenetrationTable[9]  + (2500.0 - MeterDistance) * (DHPenetrationTable[8] - DHPenetrationTable[9])  / 500.0);
    else if (MeterDistance < 3000.0) PenetrationNumber = (DHPenetrationTable[10] + (3000.0 - MeterDistance) * (DHPenetrationTable[9] - DHPenetrationTable[10]) / 500.0);
    else PenetrationNumber = DHPenetrationTable[10];

    return PenetrationNumber;

}

// DH CODE: returns (T/d) for APC/APCBC shells
simulated function float GetOverMatch (float ArmorFactor, float ShellDiameter)
{
    return ArmorFactor / ShellDiameter;
}

defaultproperties
{
    bShatterProne=true
    BallisticCoefficient=0.675
    Speed=60956.0
    MaxSpeed=60956.0
    SpeedFudgeScale=0.7
    ShellDiameter=1.45
    Tag="B-32"
    ImpactDamage=125
    ShellImpactDamage=class'DH_Weapons.DH_PTRDBulletShellDamageAP'
    MyDamageType=class'DH_Weapons.DH_PTRDDamType'
    Damage=125.0
    DHPenetrationTable[0]=3.5  // 100
    DHPenetrationTable[1]=2.4  // 250
    DHPenetrationTable[2]=1.5  // 500
    DHPenetrationTable[3]=1.0  // 750
    DHPenetrationTable[4]=0.0  // 1000
    DHPenetrationTable[5]=0.0  // 1250
    DHPenetrationTable[6]=0.0  // 1500
    DHPenetrationTable[7]=0.0  // 1750
    DHPenetrationTable[8]=0.0  // 2000
    DHPenetrationTable[9]=0.0  // 2500
    DHPenetrationTable[10]=0.0 // 3000
    VehicleDeflectSound=SoundGroup'ProjectileSounds.Bullets.PTRD_deflect'
    VehicleHitSound=SoundGroup'ProjectileSounds.Bullets.PTRD_penetrate'
    ShellHitVehicleEffectClass=class'ROEffects.TankAPHitPenetrateSmall'
    //Compile error  ShellShatterEffectClass=class'DH_Effects.DH_TankAPShellShatterSmall'
    ShatterVehicleHitSound=SoundGroup'ProjectileSounds.cannon_rounds.HE_deflect'
    ShatterSound(0)=SoundGroup'ProjectileSounds.cannon_rounds.OUT_HE_explode01'
    ShatterSound(1)=SoundGroup'ProjectileSounds.cannon_rounds.OUT_HE_explode02'
    ShatterSound(2)=SoundGroup'ProjectileSounds.cannon_rounds.OUT_HE_explode03'
    ShatterSound(3)=SoundGroup'ProjectileSounds.cannon_rounds.OUT_HE_explode04'
    bDebuggingText=false
}
