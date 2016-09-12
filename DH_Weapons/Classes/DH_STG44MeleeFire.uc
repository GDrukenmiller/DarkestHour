//==============================================================================
// Darkest Hour: Europe '44-'45
// Darklight Games (c) 2008-2016
//==============================================================================

class DH_STG44MeleeFire extends DHMeleeFire;

defaultproperties
{
    DamageType=class'DH_Weapons.DH_STG44BashDamType'
    TraceRange=75.0
    BashBackAnim="bash_pullback"
    BashHoldAnim="bash_hold"
    BashAnim="bash_attack"
    BashFinishAnim="bash_return"
    BotRefireRate=0.25
    AimError=800.0
}
