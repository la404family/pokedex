params [
    ["_deadUnit", objNull, [objNull]]
];

private _allPlayersVars = ["player_0", "player_1", "player_2", "player_3", "player_4", "player_5"];
private _livingUnits = [];

{
    private _u = missionNamespace getVariable [_x, objNull];
    if (!isNull _u && { alive _u && _u != _deadUnit }) then {
        _livingUnits pushBack _u;
    };
} forEach _allPlayersVars;

if (count _livingUnits > 0) then {
    private _targetAI = selectRandom _livingUnits;
    
    selectPlayer _targetAI;
    private _group = group _targetAI;
    _group selectLeader _targetAI;
    
    titleCut ["", "BLACK FADED", 999];
    
    [_targetAI, _group] spawn {
        params ["_targetAI", "_group"];
        sleep 1.5;
        _group selectLeader _targetAI;
        titleCut ["", "BLACK IN", 2];
        [_targetAI] call LL_fnc_addRoeActions;
        [] call LL_fnc_initSupport;
    };
} else {
    [_deadUnit] spawn {
        params ["_deadUnit"];
        
        private _cam = "camera" camCreate (getPosATL _deadUnit);
        _cam camSetTarget _deadUnit;
        _cam cameraEffect ["internal", "BACK"];
        _cam camSetRelPos [0, -5, 3];
        _cam camCommit 0;
        
        titleCut ["", "BLACK OUT", 4];
        sleep 4;
        
        failMission "LOSER";
    };
};
