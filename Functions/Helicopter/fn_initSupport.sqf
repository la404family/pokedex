if (!hasInterface) exitWith {};
if (isNull player || !alive player) exitWith {};

private _existingIDs = player getVariable ["LL_support_commIDs", []];
{
    [player, _x] call BIS_fnc_removeCommMenuItem;
} forEach _existingIDs;

private _newIDs = [];

_newIDs pushBack ([player, "Support_Ammo"] call BIS_fnc_addCommMenuItem);
_newIDs pushBack ([player, "Support_Vehicle"] call BIS_fnc_addCommMenuItem);
_newIDs pushBack ([player, "Support_Extract"] call BIS_fnc_addCommMenuItem);
_newIDs pushBack ([player, "Support_CAS"] call BIS_fnc_addCommMenuItem);
_newIDs pushBack ([player, "Support_Drone"] call BIS_fnc_addCommMenuItem);

player setVariable ["LL_support_commIDs", _newIDs];
