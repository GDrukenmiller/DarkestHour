//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2015
//==============================================================================

class DH_USSquadMGAutumn extends DH_US_Autumn_Infantry;

defaultproperties
{
    MyName="Squad Machine-Gunner"
    AltName="Squad Machine-Gunner"
    Article="a "
    PluralName="Squad Machine-Gunners"
    MenuImage=texture'DHUSCharactersTex.Icons.IconSMG'
    Models(0)="US_AutumnInf1"
    Models(1)="US_AutumnInf2"
    Models(2)="US_AutumnInf3"
    Models(3)="US_AutumnInf4"
    Models(4)="US_AutumnInf5"
    bIsGunner=true
    SleeveTexture=texture'DHUSCharactersTex.Sleeves.US_sleeves'
    PrimaryWeapons(0)=(Item=class'DH_Weapons.DH_BARWeapon',Amount=6,AssociatedAttachment=class'DH_Weapons.DH_M1CarbineAmmoPouch')
    Headgear(0)=class'DH_USPlayers.DH_AmericanHelmet1stEMa'
    Headgear(1)=class'DH_USPlayers.DH_AmericanHelmet1stEMb'
    bCarriesMGAmmo=false
    PrimaryWeaponType=WT_SMG
    Limit=2
}
