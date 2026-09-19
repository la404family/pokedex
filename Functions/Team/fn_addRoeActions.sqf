if (!hasInterface) exitWith {};

params [["_unit", objNull, [objNull]]];

if (isNull _unit || { _unit getVariable ["LL_Action_Roe_Added", false] }) exitWith {};
_unit setVariable ["LL_Action_Roe_Added", true, false];

private _cond = "alive _target && { leader group _target == _target }";

_unit addAction [
    format ["<t color='#00FF00'>%1</t>", localize "STR_LL_RoeAction_Infiltration"],
    { ([group (_this select 1)] + (_this select 3)) call LL_fnc_applyRoE; },
    ["BLUE", "STEALTH", "LIMITED", "STAG COLUMN", "AUTO", true, "STEALTH"],
    7.3, false, true, "", _cond
];

_unit addAction [
    format ["<t color='#00FF00'>%1</t>", localize "STR_LL_RoeAction_Reset"],
    { ([group (_this select 1)] + (_this select 3)) call LL_fnc_applyRoE; },
    ["YELLOW", "AWARE", "NORMAL", "WEDGE", "AUTO", false, "NORMAL"],
    7.2, false, true, "", _cond
];

_unit addAction [
    format ["<t color='#00FF00'>%1</t>", localize "STR_LL_RoeAction_Defend"],
    { ([group (_this select 1)] + (_this select 3)) call LL_fnc_applyRoE; },
    ["YELLOW", "AWARE", "NORMAL", "DIAMOND", "AUTO", false, "DEFEND"],
    7.15, false, true, "", _cond
];

_unit addAction [
    format ["<t color='#00FF00'>%1</t>", localize "STR_LL_RoeAction_ForceRegroup"],
    { ([group (_this select 1)] + (_this select 3)) call LL_fnc_applyRoE; },
    ["BLUE", "AWARE", "FULL", "FILE", "AUTO", true, "FORCE_REGROUP"],
    7.1, false, true, "", _cond
];

_unit addAction [
    format ["<t color='#00FF00'>%1</t>", localize "STR_LL_RoeAction_Assault"],
    { ([group (_this select 1)] + (_this select 3)) call LL_fnc_applyRoE; },
    ["RED", "AWARE", "FULL", "WEDGE", "AUTO", true, "ASSAULT"],
    7.0, false, true, "", _cond
];
