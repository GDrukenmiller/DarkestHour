//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2015
//==============================================================================

class DH_USEngineer506101st extends DH_US_506PIR;

defaultproperties
{
    MyName="Combat Engineer"
    AltName="Combat Engineer"
    Article="a "
    PluralName="Combat Engineers"
    MenuImage=texture'DHUSCharactersTex.Icons.ABEng'
    Models(0)="US_506101AB1"
    Models(1)="US_506101AB2"
    Models(2)="US_506101AB3"
    SleeveTexture=texture'DHUSCharactersTex.Sleeves.USAB_sleeves'
    PrimaryWeapons(0)=(Item=class'DH_Weapons.DH_M1CarbineWeapon',Amount=6,AssociatedAttachment=class'DH_Weapons.DH_M1CarbineAmmoPouch')
    PrimaryWeapons(1)=(Item=class'DH_Weapons.DH_GreaseGunWeapon',Amount=6,AssociatedAttachment=class'DH_Weapons.DH_ThompsonAmmoPouch')
    SecondaryWeapons(0)=(Item=class'DH_Weapons.DH_ColtM1911Weapon',Amount=1)
    Grenades(0)=(Item=class'DH_Weapons.DH_M1GrenadeWeapon',Amount=2)
    Grenades(1)=(Item=class'DH_Equipment.DH_USSmokeGrenadeWeapon',Amount=1)
    GivenItems(0)="DH_Equipment.DHWireCuttersItem"
    Headgear(0)=class'DH_USPlayers.DH_AmericanHelmet506101stEMa'
    Headgear(1)=class'DH_USPlayers.DH_AmericanHelmet506101stEMb'
    PrimaryWeaponType=WT_SemiAuto
    Limit=3
}
