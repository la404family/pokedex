if (!hasInterface) exitWith {};

if (player != missionNamespace getVariable ["player_0", objNull]) exitWith {};

[player, "Support_Ammo"] call BIS_fnc_addCommMenuItem;
[player, "Support_Vehicle"] call BIS_fnc_addCommMenuItem;
[player, "Support_Extract"] call BIS_fnc_addCommMenuItem;
[player, "Support_CAS"] call BIS_fnc_addCommMenuItem;
