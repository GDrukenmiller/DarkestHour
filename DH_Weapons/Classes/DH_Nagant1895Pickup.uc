//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2019
//==============================================================================

class DH_Nagant1895Pickup extends DHWeaponPickup;

defaultproperties
{
    InventoryType=class'DH_Weapons.DH_Nagant1895Weapon'
    StaticMesh=StaticMesh'DH_M1895_stc.Weapons.m1895'
    CollisionRadius=15.0 // as is a pistol, which is small
}
