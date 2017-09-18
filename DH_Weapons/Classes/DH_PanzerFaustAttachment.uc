//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2017
//==============================================================================

class DH_PanzerFaustAttachment extends DHRocketWeaponAttachment;

defaultproperties
{
    Mesh=SkeletalMesh'Weapons3rd_anm.Panzerfaust'
    Skins(0)=Texture'Weapons3rd_tex.German.Panzerfaust_world'
    EmptyMesh=SkeletalMesh'Weapons3rd_anm.Panzerfaust_empty'
    MenuImage=Texture'InterfaceArt_tex.Menu_weapons.PanzerFaust'
    mMuzFlashClass=class'ROEffects.RO3rdPersonPanzerfaustFX'
    MuzzleBoneName="tip"

    PA_MovementAnims(0)="stand_jogF_faust"
    PA_MovementAnims(1)="stand_jogB_faust"
    PA_MovementAnims(2)="stand_jogL_faust"
    PA_MovementAnims(3)="stand_jogR_faust"
    PA_MovementAnims(4)="stand_jogFL_faust"
    PA_MovementAnims(5)="stand_jogFR_faust"
    PA_MovementAnims(6)="stand_jogBL_faust"
    PA_MovementAnims(7)="stand_jogBR_faust"
    PA_CrouchAnims(0)="crouch_walkF_faust"
    PA_CrouchAnims(1)="crouch_walkB_faust"
    PA_CrouchAnims(2)="crouch_walkL_faust"
    PA_CrouchAnims(3)="crouch_walkR_faust"
    PA_CrouchAnims(4)="crouch_walkFL_faust"
    PA_CrouchAnims(5)="crouch_walkFR_faust"
    PA_CrouchAnims(6)="crouch_walkBL_faust"
    PA_CrouchAnims(7)="crouch_walkBR_faust"
    PA_ProneAnims(0)="prone_crawlF_faust"
    PA_ProneAnims(1)="prone_crawlB_faust"
    PA_ProneAnims(2)="prone_crawlL_faust"
    PA_ProneAnims(3)="prone_crawlR_faust"
    PA_ProneAnims(4)="prone_crawlFL_faust"
    PA_ProneAnims(5)="prone_crawlFR_faust"
    PA_ProneAnims(6)="prone_crawlBL_faust"
    PA_ProneAnims(7)="prone_crawlBR_faust"
    PA_ProneIronAnims(0)="prone_slowcrawlF_faust"
    PA_ProneIronAnims(1)="prone_slowcrawlB_faust"
    PA_ProneIronAnims(2)="prone_slowcrawlL_faust"
    PA_ProneIronAnims(3)="prone_slowcrawlR_faust"
    PA_ProneIronAnims(4)="prone_slowcrawlL_faust"
    PA_ProneIronAnims(5)="prone_slowcrawlR_faust"
    PA_ProneIronAnims(6)="prone_slowcrawlB_faust"
    PA_ProneIronAnims(7)="prone_slowcrawlB_faust"
    PA_WalkAnims(0)="stand_walkFhip_faust"
    PA_WalkAnims(1)="stand_walkBhip_faust"
    PA_WalkAnims(2)="stand_walkLhip_faust"
    PA_WalkAnims(3)="stand_walkRhip_faust"
    PA_WalkAnims(4)="stand_walkFLhip_faust"
    PA_WalkAnims(5)="stand_walkFRhip_faust"
    PA_WalkAnims(6)="stand_walkBLhip_faust"
    PA_WalkAnims(7)="stand_walkBRhip_faust"
    PA_WalkIronAnims(0)="stand_walkFiron_faust"
    PA_WalkIronAnims(1)="stand_walkBiron_faust"
    PA_WalkIronAnims(2)="stand_walkLiron_faust"
    PA_WalkIronAnims(3)="stand_walkRiron_faust"
    PA_WalkIronAnims(4)="stand_walkFLiron_faust"
    PA_WalkIronAnims(5)="stand_walkFRiron_faust"
    PA_WalkIronAnims(6)="stand_walkBLiron_faust"
    PA_WalkIronAnims(7)="stand_walkBRiron_faust"
    PA_SprintAnims(0)="stand_sprintF_faust"
    PA_SprintAnims(1)="stand_sprintB_faust"
    PA_SprintAnims(2)="stand_sprintL_faust"
    PA_SprintAnims(3)="stand_sprintR_faust"
    PA_SprintAnims(4)="stand_sprintFL_faust"
    PA_SprintAnims(5)="stand_sprintFR_faust"
    PA_SprintAnims(6)="stand_sprintBL_faust"
    PA_SprintAnims(7)="stand_sprintBR_faust"
    PA_SprintCrouchAnims(0)="crouch_sprintF_faust"
    PA_SprintCrouchAnims(1)="crouch_sprintB_faust"
    PA_SprintCrouchAnims(2)="crouch_sprintL_faust"
    PA_SprintCrouchAnims(3)="crouch_sprintR_faust"
    PA_SprintCrouchAnims(4)="crouch_sprintFL_faust"
    PA_SprintCrouchAnims(5)="crouch_sprintFR_faust"
    PA_SprintCrouchAnims(6)="crouch_sprintBL_faust"
    PA_SprintCrouchAnims(7)="crouch_sprintBR_faust"
    PA_TurnRightAnim="stand_turnRhip_faust"
    PA_TurnLeftAnim="stand_turnLhip_faust"
    PA_TurnIronRightAnim="stand_turnRiron_faust"
    PA_TurnIronLeftAnim="stand_turnLiron_faust"
    PA_CrouchTurnIronRightAnim="crouch_turnRiron_faust"
    PA_CrouchTurnIronLeftAnim="crouch_turnRiron_faust"
    PA_ProneTurnRightAnim="prone_turnR_faust"
    PA_ProneTurnLeftAnim="prone_turnL_faust"
    PA_StandToProneAnim="StandtoProne_faust"
    PA_CrouchToProneAnim="CrouchtoProne_faust"
    PA_ProneToStandAnim="PronetoStand_faust"
    PA_ProneToCrouchAnim="PronetoCrouch_faust"
    PA_DiveToProneStartAnim="prone_divef_faust"
    PA_DiveToProneEndAnim="prone_diveend_faust"
    PA_CrouchTurnRightAnim="crouch_turnR_faust"
    PA_CrouchTurnLeftAnim="crouch_turnL_faust"
    PA_CrouchIdleRestAnim="crouch_idle_faust"
    PA_IdleCrouchAnim="crouch_idle_faust"
    PA_IdleRestAnim="stand_idlehip_faust"
    PA_IdleWeaponAnim="stand_idlehip_faust"
    PA_IdleIronRestAnim="stand_idleiron_faust"
    PA_IdleIronWeaponAnim="stand_idleiron_faust"
    PA_IdleCrouchIronWeaponAnim="crouch_idleiron_faust"
    PA_IdleProneAnim="prone_idle_faust"
    PA_ReloadAnim="stand_reload_faust"
    PA_ProneReloadAnim="prone_reload_faust"
    PA_ReloadEmptyAnim="reload_k98"
    PA_ProneReloadEmptyAnim="prone_reload_faust"
    PA_ProneIdleRestAnim="prone_idle_faust"
    PA_Fire="stand_shootiron_faust"
    PA_IronFire="stand_shootiron_faust"
    PA_CrouchFire="crouch_shoot_faust"
    PA_ProneFire="prone_shoot_faust"
    PA_MoveStandFire(0)="stand_shootiron_faust"
    PA_MoveStandFire(1)="stand_shootiron_faust"
    PA_MoveStandFire(2)="stand_shootLRiron_faust"
    PA_MoveStandFire(3)="stand_shootLRiron_faust"
    PA_MoveStandFire(4)="stand_shootFLiron_faust"
    PA_MoveStandFire(5)="stand_shootFRiron_faust"
    PA_MoveStandFire(6)="stand_shootFRiron_faust"
    PA_MoveStandFire(7)="stand_shootFLiron_faust"
    PA_MoveCrouchFire(0)="crouch_shootF_faust"
    PA_MoveCrouchFire(1)="crouch_shootF_faust"
    PA_MoveCrouchFire(2)="crouch_shootLR_faust"
    PA_MoveCrouchFire(3)="crouch_shootLR_faust"
    PA_MoveCrouchFire(4)="crouch_shootF_faust"
    PA_MoveCrouchFire(5)="crouch_shootF_faust"
    PA_MoveCrouchFire(6)="crouch_shootF_faust"
    PA_MoveCrouchFire(7)="crouch_shootF_faust"
    PA_MoveWalkFire(0)="stand_shootFwalk_faust"
    PA_MoveWalkFire(1)="stand_shootFwalk_faust"
    PA_MoveWalkFire(2)="stand_shootLRwalk_faust"
    PA_MoveWalkFire(3)="stand_shootLRwalk_faust"
    PA_MoveWalkFire(4)="stand_shootFLwalk_faust"
    PA_MoveWalkFire(5)="stand_shootFRwalk_faust"
    PA_MoveWalkFire(6)="stand_shootFRwalk_faust"
    PA_MoveWalkFire(7)="stand_shootFLwalk_faust"
    PA_MoveStandIronFire(0)="stand_shootiron_faust"
    PA_MoveStandIronFire(1)="stand_shootiron_faust"
    PA_MoveStandIronFire(2)="stand_shootLRiron_faust"
    PA_MoveStandIronFire(3)="stand_shootLRiron_faust"
    PA_MoveStandIronFire(4)="stand_shootFLiron_faust"
    PA_MoveStandIronFire(5)="stand_shootFRiron_faust"
    PA_MoveStandIronFire(6)="stand_shootFRiron_faust"
    PA_MoveStandIronFire(7)="stand_shootFLiron_faust"
    PA_AltFire="stand_idlestrike_kar"
    PA_CrouchAltFire="stand_idlestrike_kar"
    PA_ProneAltFire="prone_idlestrike_bayo"
    PA_FireLastShot="stand_shoothip_faust"
    PA_IronFireLastShot="stand_shootiron_faust"
    PA_CrouchFireLastShot="crouch_shoot_faust"
    PA_ProneFireLastShot="prone_shoot_faust"
    WA_Idle="idle_faust"
    WA_Fire="idle_faust"
    PA_AirStillAnim="jump_mid_kar"
    PA_AirAnims(0)="jumpF_mid_kar"
    PA_AirAnims(1)="jumpB_mid_kar"
    PA_AirAnims(2)="jumpL_mid_kar"
    PA_AirAnims(3)="jumpR_mid_kar"
    PA_TakeoffStillAnim="jump_takeoff_kar"
    PA_TakeoffAnims(0)="jumpF_takeoff_kar"
    PA_TakeoffAnims(1)="jumpB_takeoff_kar"
    PA_TakeoffAnims(2)="jumpL_takeoff_kar"
    PA_TakeoffAnims(3)="jumpR_takeoff_kar"
    PA_LandAnims(0)="jumpF_land_kar"
    PA_LandAnims(1)="jumpB_land_kar"
    PA_LandAnims(2)="jumpL_land_kar"
    PA_LandAnims(3)="jumpR_land_kar"
    PA_DodgeAnims(0)="jumpF_mid_kar"
    PA_DodgeAnims(1)="jumpB_mid_kar"
    PA_DodgeAnims(2)="jumpL_mid_kar"
    PA_DodgeAnims(3)="jumpR_mid_kar"
}
