params [
    ["_type",     "SURVEILLANCE", [""]],
    ["_pos",      [0,0,0],        [[]]],
    ["_caller",   objNull,        [objNull]]
];

if (isNull _caller) then { _caller = player; };

if (missionNamespace getVariable ["LL_Drone_Jammed", false]) exitWith {
    ["STR_Drone_Jammed"] call LL_fnc_radioMessage;
};

if (missionNamespace getVariable ["LL_Drone_Active", false]) exitWith {
    ["STR_Drone_AlreadyActive_Wait"] call LL_fnc_radioMessage;
};

["STR_Drone_EnRoute", [round (_pos select 0), round (_pos select 1)]] call LL_fnc_radioMessage;

missionNamespace setVariable ["LL_DRONE_pending", [_type, _pos, _caller], false];
