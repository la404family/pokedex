if (!hasInterface) exitWith {};

_this spawn {
    params [["_radioParam", objNull, [objNull]], ["_netId", "", [""]], ["_varName", "", [""]]];

    private _radio = _radioParam;
    if (isNull _radio) then {
        private _timeout = time + 30;
        waitUntil {
            sleep 0.5;
            if (_netId != "") then { _radio = objectFromNetId _netId; };
            if (isNull _radio && _varName != "") then { _radio = missionNamespace getVariable [_varName, objNull]; };
            !isNull _radio || time > _timeout
        };
    };

    if (isNull _radio) exitWith {};

    _radio addAction [
        format ["<t color='#FFFF00'>%1</t>", localize "STR_LL_Task_03_Action"],
        {
            params ["_target", "_caller", "_actionId"];
            _target removeAction _actionId;
            ["plant", [_target, _caller]] remoteExec ["LL_fnc_task03", 2];
        },
        nil,
        6,
        true,
        true,
        "",
        "alive _target && _this distance _target < 4 && (_target getVariable ['LL_Task_Status', 'WAIT']) == 'WAIT'",
        4
    ];
};
