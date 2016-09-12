//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2016
//==============================================================================

class DH_PPS43BashDamType extends DHWeaponBashDamageType
    abstract;

defaultproperties
{
    WeaponClass=class'DH_Weapons.DH_PPS43Weapon'
    DeathString="%o was smacked with %k's PPS43."
    FemaleSuicide="%o turned the gun on herself."
    MaleSuicide="%o turned the gun on himself."
    GibModifier=0.0
    KDamageImpulse=400.0
}
