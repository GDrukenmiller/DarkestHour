//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2020
//==============================================================================

class DH_M1CarbineWeapon extends DHSemiAutoWeapon;

defaultproperties
{
    ItemName="M1 Carbine"
    SwayModifyFactor=0.55 // -0.35  because it was a very light carbine
    FireModeClass(0)=class'DH_Weapons.DH_M1CarbineFire'
    FireModeClass(1)=class'DH_Weapons.DH_M1CarbineMeleeFire'
    AttachmentClass=class'DH_Weapons.DH_M1CarbineAttachment'
    PickupClass=class'DH_Weapons.DH_M1CarbinePickup'

    Mesh=SkeletalMesh'DH_M1Carbine_1st.M1Carbine'
    Skins(3)=shader'DH_Weapon_tex.Spec_Maps.M1GarandAmmo_s' // TODO: ammo specularity shader isn't used in the anim mesh & should be added there
    HighDetailOverlay=shader'DH_Weapon_tex.Spec_Maps.SMG.M1Carbine_s'
    bUseHighDetailOverlayIndex=true
    HighDetailOverlayIndex=2

    IronSightDisplayFOV=20.0
    FreeAimRotationSpeed=7.0

    MaxNumPrimaryMags=12
    InitialNumPrimaryMags=12

    PutDownAnim="putaway"
    IdleEmptyAnim="idle_empty"
    IronIdleEmptyAnim="iron_idle_empty"
}
