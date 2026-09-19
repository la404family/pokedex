params [
    ["_type",     "CAS",   [""]],
    ["_pos",      [0,0,0], [[]]],
    ["_caller",   objNull, [objNull]],
    ["_priority", 1,       [0]]
];

if (isNull _caller) then { _caller = player; };

if (_type == "CAS" && { time < (missionNamespace getVariable ["TAG_CAS_Cooldown_Until", 0]) }) exitWith {
    private _rem = ceil ((missionNamespace getVariable ["TAG_CAS_Cooldown_Until", 0]) - time);
    ["STR_LL_Heli_Dispatch_Cooldown", [_rem]] call LL_fnc_radioMessage;
};

if (_type == "VEHICULE" && { missionNamespace getVariable ["TAG_VehicleSupport_Delivered", false] }) exitWith {
    ["STR_LL_Heli_Dispatch_VehicleAlready"] call LL_fnc_radioMessage;
};

private _state   = missionNamespace getVariable ["LL_HELI_state",    "IDLE"];
private _curPrio = missionNamespace getVariable ["LL_HELI_priority", 0];
private _curType = missionNamespace getVariable ["LL_HELI_type",     ""];

private _interruptibleStates = ["APPROACHING", "CAS", "DELIVERING", "DEPLOYING", "RTB", "RTB_WITH_CARGO"];

private _typePriority = switch (_type) do {
    case "EMBARQUEMENT": { 2 };
    default              { 1 };
};

if (_priority < _typePriority) then { _priority = _typePriority; };

switch (true) do {

    case (_state == "IDLE"): {
        private _approveMsgKey = switch (_type) do {
            case "LIVRAISON":    { "STR_LL_Heli_Dispatch_Approve_LIVRAISON" };
            case "VEHICULE":     { "STR_LL_Heli_Dispatch_Approve_VEHICULE" };
            case "CAS":          { "STR_LL_Heli_Dispatch_Approve_CAS" };
            case "EMBARQUEMENT": { "STR_LL_Heli_Dispatch_Approve_EMBARQUEMENT" };
            default              { "STR_LL_Heli_Dispatch_Approve_DEFAULT" };
        };
        [_approveMsgKey] call LL_fnc_radioMessage;

        if (_type == "VEHICULE") then {
            missionNamespace setVariable ["TAG_VehicleSupport_Delivered", true, true];
        };

        missionNamespace setVariable ["LL_HELI_pending", [_type, _pos, _caller, _priority], false];
    };

    case (_priority > _curPrio && { _state in _interruptibleStates }): {
        private _abortMsgKey = switch (_curType) do {
            case "CAS":          { "STR_LL_Heli_Dispatch_Abort_CAS" };
            case "LIVRAISON":    { "STR_LL_Heli_Dispatch_Abort_LIVRAISON" };
            case "VEHICULE":     { "STR_LL_Heli_Dispatch_Abort_VEHICULE" };
            default              { "STR_LL_Heli_Dispatch_Abort_DEFAULT" };
        };
        [_abortMsgKey] call LL_fnc_radioMessage;

        private _newMsgKey = switch (_type) do {
            case "EMBARQUEMENT": { "STR_LL_Heli_Dispatch_New_EMBARQUEMENT" };
            default              { "STR_LL_Heli_Dispatch_New_DEFAULT" };
        };
        [_newMsgKey] call LL_fnc_radioMessage;

        missionNamespace setVariable ["LL_HELI_abort",   true,                              false];
        missionNamespace setVariable ["LL_HELI_pending", [_type, _pos, _caller, _priority], false];
    };

    default {
        private _denyMsgKey = switch (true) do {
            case (_type == "EMBARQUEMENT" && _curType == "EMBARQUEMENT"): { "STR_LL_Heli_Dispatch_Deny_EMBARQUEMENT" };
            case (_type == "CAS"): { "STR_LL_Heli_Dispatch_Deny_CAS" };
            case (_type == "LIVRAISON"): { "STR_LL_Heli_Dispatch_Deny_LIVRAISON" };
            case (_type == "VEHICULE"): { "STR_LL_Heli_Dispatch_Deny_VEHICULE" };
            default { "STR_LL_Heli_Dispatch_Deny_DEFAULT" };
        };
        if (_type == "EMBARQUEMENT" && _curType == "EMBARQUEMENT") then {
            [_denyMsgKey] call LL_fnc_radioMessage;
        } else {
            [_denyMsgKey, [_curType]] call LL_fnc_radioMessage;
        };
    };
};
