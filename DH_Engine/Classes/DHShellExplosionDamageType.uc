//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2017
//==============================================================================

class DHShellExplosionDamageType extends ROTankShellExplosionDamage
    abstract;

defaultproperties
{
    DeathString="%o was blown up by %k's cannon shell."
    MaleSuicide="%o was blown up his own cannon shell."
    FemaleSuicide="%o was blown up by her own cannon shell."
    VehicleMomentumScaling=1.3
    KDamageImpulse=5000.0
    KDeathVel=300.0
    KDeathUpKick=60.0
    KDeadLinZVelScale=0.002
    KDeadAngVelScale=0.003
    HumanObliterationThreshhold=265
}
