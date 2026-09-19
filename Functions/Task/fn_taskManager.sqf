params [["_mode", "init", [""]]];

if (!isServer) exitWith {};

if (_mode == "init") exitWith {
    missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    missionNamespace setVariable ["LL_g_lastTask", "", true];
};

if (_mode == "REQUEST") exitWith {
    if (missionNamespace getVariable ["LL_g_taskInProgress", false]) exitWith {
        if (missionNamespace getVariable ["DEBUG_MODE", true]) then {
        };
    };

    private _availableTasks = [];

    _availableTasks pushBack "task00";
    _availableTasks pushBack "task01";
    _availableTasks pushBack "task02";
    _availableTasks pushBack "task03";
    _availableTasks pushBack "task04";
    _availableTasks pushBack "task05";
    _availableTasks pushBack "task06";
    _availableTasks pushBack "task07";

    private _lastTask = missionNamespace getVariable ["LL_g_lastTask", ""];

    private _validTasks = _availableTasks;
    if (count _availableTasks > 1 && _lastTask != "") then {
        _validTasks = _availableTasks select { _x != _lastTask };
    };

    if (count _validTasks > 0) then {
        private _selectedTask = selectRandom _validTasks;

        missionNamespace setVariable ["LL_g_lastTask", _selectedTask, true];
        missionNamespace setVariable ["LL_g_taskInProgress", true, true];

        private _fnc = missionNamespace getVariable ["LL_fnc_" + _selectedTask, {}];

        if (_fnc isNotEqualTo {}) then {
            if (missionNamespace getVariable ["DEBUG_MODE", true]) then {
            };

            [_selectedTask, _fnc] spawn {
                params ["_selectedTask", "_fnc"];

                ["init"] spawn _fnc;

                waitUntil { 
                    sleep 2; 
                    !(missionNamespace getVariable ["LL_g_taskInProgress", false]) 
                };

                [] spawn LL_fnc_extraction;
            };

        } else {
            if (missionNamespace getVariable ["DEBUG_MODE", true]) then {
            };
            missionNamespace setVariable ["LL_g_taskInProgress", false, true];
        };
    } else {
        if (missionNamespace getVariable ["DEBUG_MODE", true]) then {
        };
    };
};
