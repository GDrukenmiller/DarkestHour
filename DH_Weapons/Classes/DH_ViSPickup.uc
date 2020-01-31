//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2019
//==============================================================================

class DH_ViSPickup extends DHWeaponPickup;

defaultproperties
{
    InventoryType=class'DH_Weapons.DH_ViSWeapon'
    StaticMesh=StaticMesh'DH_ViS_stc.Weapons.ViS'
    CollisionRadius=15.0 // as is a pistol, which is small
}
