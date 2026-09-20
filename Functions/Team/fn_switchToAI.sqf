params [
    ["_deadUnit", objNull, [objNull]]
];

private _group = group _deadUnit;
private _livingAI = (units _group) select { alive _x && {!isPlayer _x} };

if (count _livingAI > 0) then {
    private _targetAI = selectRandom _livingAI;
    
    selectPlayer _targetAI;
    _group selectLeader _targetAI;
    
    titleCut ["", "BLACK FADED", 999];
    
    [_targetAI, _group] spawn {
        params ["_targetAI", "_group"];
        
        sleep 1.5;
        
        _group selectLeader _targetAI;
        
        titleCut ["", "BLACK IN", 2];
        
        [_targetAI] call LL_fnc_addRoeActions;
    };
} else {
    ["MissionFailed", false] call BIS_fnc_endMission;
};
