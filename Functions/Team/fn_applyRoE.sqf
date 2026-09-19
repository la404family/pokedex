params [
    ["_grp", grpNull, [grpNull]],
    ["_combatMode", "YELLOW", [""]],
    ["_behaviour", "AWARE", [""]],
    ["_speedMode", "NORMAL", [""]],
    ["_formation", "WEDGE", [""]],
    ["_unitPos", "AUTO", [""]],
    ["_disableAutocombat", false, [true]],
    ["_name", "NORMAL", [""]]
];

if (isNull _grp) exitWith {};

_grp setCombatMode _combatMode;
_grp setBehaviourStrong _behaviour;
_grp setSpeedMode _speedMode;
_grp setFormation _formation;

{
    if (!isPlayer _x && { alive _x } && { vehicle _x == _x }) then {
        
        if (_name != "DEFEND" && _name != "FORCE_REGROUP") then {
            _x doFollow leader _grp;
            _x enableAI "TARGET";
            _x enableAI "AUTOTARGET";
        };

        if (_unitPos == "MIDDLE") then {
            _x setUnitPos _unitPos;
        } else {
            _x setUnitPosWeak _unitPos;
        };

        if (_disableAutocombat) then {
            _x disableAI "AUTOCOMBAT";
            _x disableAI "SUPPRESSION";
        } else {
            _x enableAI "AUTOCOMBAT";
            _x enableAI "SUPPRESSION";
        };
        
        if (_name == "DEFEND") then {
            doStop _x;
            _x enableAI "TARGET";
            _x enableAI "AUTOTARGET";
        };

        _x setVariable ["LL_CurrentRoE", _name, false];
    };
} forEach (units _grp);

_grp setVariable ["LL_CurrentRoE", _name, false];

if (_name == "FORCE_REGROUP") then {
    {
        if (!isPlayer _x && { alive _x } && { vehicle _x == _x }) then {
            _x disableAI "TARGET";
            _x disableAI "AUTOTARGET";
            _x doFollow leader _grp;
        };
    } forEach (units _grp);
    
    [_grp] spawn {
        params ["_grp"];
        private _leader = leader _grp;
        private _timeout = time + 40;
        
        waitUntil {
            sleep 1;
            if (isNull _grp) exitWith { true };
            if (_grp getVariable ["LL_CurrentRoE", ""] != "FORCE_REGROUP") exitWith { true };
            
            private _aiUnits = (units _grp) select { !isPlayer _x && alive _x && vehicle _x == _x };
            if (count _aiUnits == 0) exitWith { true };
            
            private _allGathered = true;
            {
                if (_x distance _leader > 8) then { _allGathered = false; };
            } forEach _aiUnits;
            
            _allGathered || time > _timeout
        };
        
        if (!isNull _grp && { _grp getVariable ["LL_CurrentRoE", ""] == "FORCE_REGROUP" }) then {
            [_grp, "YELLOW", "AWARE", "NORMAL", "WEDGE", "AUTO", false, "NORMAL"] call LL_fnc_applyRoE;
        };
    };
};
