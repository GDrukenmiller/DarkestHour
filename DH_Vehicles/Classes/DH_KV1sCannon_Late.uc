//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2019
//==============================================================================

class DH_KV1sCannon_Late extends DH_KV1sCannon; //KV-1s entered service in 1942, 76mm subcaliber ammo was only adopted in 1943, so i am making 2 different versions

defaultproperties
{
    TertiaryProjectileClass=class'DH_Vehicles.DH_T3476CannonShellAPCR'
	InitialTertiaryAmmo=4
	MaxTertiaryAmmo=6
    nProjectileDescriptions(2)="BR-350P"
    ProjectileDescriptions(2)="APCR"
}
