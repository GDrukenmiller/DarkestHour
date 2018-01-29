//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2017
//==============================================================================

class DH_USMortarObserver2ndR extends DH_US_2ndRangersBattalion;

defaultproperties
{
    bIsMortarObserver=true
    MyName="Artillery Observer"
    AltName="Artillery Observer"
    Article="a "
    PluralName="Artillery Observers"
    PrimaryWeapons(0)=(Item=class'DH_Weapons.DH_M1CarbineWeapon',AssociatedAttachment=class'DH_Weapons.DH_M1CarbineAmmoPouch')
    PrimaryWeapons(1)=(Item=class'DH_Weapons.DH_M1GarandWeapon',AssociatedAttachment=class'DH_Weapons.DH_M1GarandAmmoPouch')
    Grenades(0)=(Item=class'DH_Weapons.DH_M1GrenadeWeapon')
    GivenItems(0)="DH_Equipment.DHBinocularsItem"
    Headgear(0)=class'DH_USPlayers.DH_AmericanHelmet2ndREMa'
    Headgear(1)=class'DH_USPlayers.DH_AmericanHelmet2ndREMb'
    Limit=1
}
