if (!hasInterface) exitWith {};

if (isNil "LL_fnc_task07_addActionLogic") then {
    LL_fnc_task07_addActionLogic = {
        params [["_unit", objNull, [objNull]]];

        if (isNull _unit || { _unit getVariable ["LL_Task07_Action_Added", false] }) exitWith {};
        _unit setVariable ["LL_Task07_Action_Added", true, false];

        _unit addAction [
            format ["<t color='#FFFF00'>%1</t>", localize "STR_LL_Task_07_Action_CAS"],
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                
                if (missionNamespace getVariable ["LL_Task07_PlaneTriggered", false]) exitWith {};
                missionNamespace setVariable ["LL_Task07_PlaneTriggered", true, true];
                
                _target removeAction _actionId;
                
                [] remoteExec ["LL_fnc_task07_plane", 2];
            },
            [],
            1.5,
            true,
            true,
            "",
            "private _tank = missionNamespace getVariable ['LL_Task07_TargetTank', objNull]; !isNull _tank && {alive _tank} && {(_this distance _tank) < 200} && {!(missionNamespace getVariable ['LL_Task07_PlaneTriggered', false])}"
        ];
    };
};

[] spawn {
    private _lastPlayer = objNull;
    while {
        !(missionNamespace getVariable ["LL_Task07_PlaneTriggered", false]) && 
        { missionNamespace getVariable ["LL_g_taskInProgress", false] }
    } do {
        waitUntil { 
            sleep 1; 
            (player != _lastPlayer && { !isNull player }) || 
            (missionNamespace getVariable ["LL_Task07_PlaneTriggered", false]) ||
            !(missionNamespace getVariable ["LL_g_taskInProgress", false])
        };
        
        if (!(missionNamespace getVariable ["LL_Task07_PlaneTriggered", false]) && { missionNamespace getVariable ["LL_g_taskInProgress", false] }) then {
            _lastPlayer = player;
            [_lastPlayer] call LL_fnc_task07_addActionLogic;
        };
    };
};
