// fn_initLoadout.sqf - Optimized for Solo
private _vests = [
    "CUP_V_JPC_medical_coy","CUP_V_JPC_tl_coy","CUP_V_JPC_weapons_coy",
    "CUP_V_JPC_communicationsbelt_coy","CUP_V_JPC_Fastbelt_coy","CUP_V_JPC_lightbelt_coy",
    "CUP_V_JPC_medicalbelt_coy","CUP_V_JPC_tlbelt_coy","CUP_V_JPC_weaponsbelt_coy"
];
private _helmets = [
    "CUP_H_OpsCore_Tan_SF","CUP_H_OpsCore_Tan","CUP_H_OpsCore_Tan_NohS",
    "CUP_H_OpsCore_Grey_SF","CUP_H_OpsCore_Grey","CUP_H_OpsCore_Grey_NohS"
];
private _backpacks = ["CUP_B_AssaultPack_Coyote","B_AssaultPack_cbr","B_Kitbag_cbr"];
private _uniforms = [
    "CUP_U_B_USMC_MCCUU_des_gloves","CUP_U_B_USMC_MCCUU_des_roll_2",
    "CUP_U_B_USMC_MCCUU_des_roll_2_gloves","CUP_U_B_USMC_MCCUU_des_roll_pads",
    "CUP_U_B_USMC_MCCUU_des_roll_2_pads_gloves","CUP_U_B_USMC_MCCUU_des_pads",
    "CUP_U_B_USMC_MCCUU_des_pads_gloves","CUP_U_B_USMC_MCCUU_des_roll",
    "CUP_U_B_USMC_MCCUU_des_roll_gloves","CUP_U_B_USMC_MCCUU_des_roll_pads",
    "CUP_U_B_USMC_MCCUU_des_roll_pads_gloves","CUP_U_B_USMC_MCCUU_des"
];
private _goggles = [
    "CUP_G_Tan_Scarf_Shades_GPSCombo_Beard","CUP_G_Tan_Scarf_Shades_GPS_Beard",
    "CUP_G_Tan_Scarf_GPS","CUP_G_TK_RoundGlasses_blk","CUP_G_Oakleys_Drk",
    "CUP_G_Scarf_Face_Tan","G_Aviator","CUP_G_ESS_KHK_Scarf_Tan_GPS_Beard",
    "CUP_G_ESS_KHK_Facewrap_Tan","G_Bandana_khk"
];

private _squad = [
    missionNamespace getVariable ["player_0", objNull],
    missionNamespace getVariable ["player_1", objNull],
    missionNamespace getVariable ["player_2", objNull],
    missionNamespace getVariable ["player_3", objNull],
    missionNamespace getVariable ["player_4", objNull],
    missionNamespace getVariable ["player_5", objNull]
] select { !isNull _x };

{
    private _unit = _x;
    private _loadout = getUnitLoadout _unit;
    
    // Select new random cosmetic gear
    private _newUniform = selectRandom _uniforms;
    private _newVest = selectRandom _vests;
    private _newHelmet = selectRandom _helmets;
    private _newGoggles = selectRandom _goggles;
    
    // Update Uniform (index 3) while keeping its items
    if (count (_loadout select 3) > 0) then {
        (_loadout select 3) set [0, _newUniform];
    } else {
        _loadout set [3, [_newUniform, []]];
    };

    // Update Vest (index 4) while keeping its items
    if (count (_loadout select 4) > 0) then {
        (_loadout select 4) set [0, _newVest];
    } else {
        _loadout set [4, [_newVest, []]];
    };
    
    // For Backpack, randomize it. If they don't have one, give them an empty one.
    private _newBackpack = selectRandom _backpacks;
    if (count (_loadout select 5) > 0) then {
        (_loadout select 5) set [0, _newBackpack];
    } else {
        _loadout set [5, [_newBackpack, []]];
    };

    // Update Headgear (index 6)
    _loadout set [6, _newHelmet];
    
    // Update Goggles (index 7)
    _loadout set [7, _newGoggles];
    
    // Apply safely
    _unit setUnitLoadout _loadout;
    
    // Appliquer le badge RACS (Légion Étrangère)
    [_unit] call LL_fnc_badgeManager;

} forEach _squad;
