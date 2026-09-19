params [["_unit", objNull, [objNull]], ["_forcedLang", "", [""]]];

if (isNull _unit || !alive _unit) exitWith {};

private _hasUVO = missionNamespace getVariable [
    "LL_hasUVO",
    isClass (configFile >> "CfgPatches" >> "uvo_main")
    || isClass (configFile >> "CfgPatches" >> "UVO_main")
    || isClass (configFile >> "CfgPatches" >> "UVO")
    || isClass (configFile >> "CfgPatches" >> "uvo_sounds")
    || isClass (configFile >> "CfgPatches" >> "UVO_Sounds")
    || isClass (configFile >> "CfgPatches" >> "uvo")
    || !isNil "uvo_main_fnc_add"
    || !isNil "uvo_main_fnc_speak"
    || !isNil "UVO_fnc_add"
    || !isNil "UVO_fnc_speak"
    || !isNil "uvo_main_voices"
];

if (!_hasUVO) exitWith {};

private _hasExpanded = missionNamespace getVariable [
    "LL_hasUVO_Expanded",
    isClass (configFile >> "CfgPatches" >> "UVO_Expanded")
    || isClass (configFile >> "CfgPatches" >> "uvo_expanded")
    || isClass (configFile >> "CfgPatches" >> "UVO_factions_plus")
    || isClass (configFile >> "CfgPatches" >> "uvo_factions_plus")
    || isClass (configFile >> "CfgPatches" >> "UVO_AET_AIO")
    || isClass (configFile >> "CfgPatches" >> "uvo_aet_aio")
    || isClass (configFile >> "CfgPatches" >> "UVO_RHS")
    || isClass (configFile >> "CfgPatches" >> "uvo_rhs")
    || isClass (configFile >> "CfgPatches" >> "UVO_voices_expanded")
    || isClass (configFile >> "CfgPatches" >> "uvo_voices_expanded")
    || isClass (configFile >> "CfgPatches" >> "uvo_voices")
];

private _voice = "";

if (_forcedLang != "") then {
    _voice = _forcedLang;
} else {
    private _side = side group _unit;
    if (_side == east || _side == independent || _side == civilian) then {
        if (_hasExpanded) then {
            private _candidates = ["Persian", "Arabic", "PERSIAN", "ARABIC", "EAST"];
            private _valid = _candidates select {
                !isNil { missionNamespace getVariable ("UVO_voice_" + _x) } || isClass (configFile >> ("UVO_voice_" + _x))
            };
            if (count _valid > 0) then {
                _voice = selectRandom _valid;
            } else {
                _voice = "EAST";
            };
        } else {
            _voice = "EAST";
        };
    } else {
        if (_side == west) then {
            if (_hasExpanded) then {
                private _candidates = ["French", "FRENCH", "FR", "WEST"];
                private _valid = _candidates select {
                    !isNil { missionNamespace getVariable ("UVO_voice_" + _x) } || isClass (configFile >> ("UVO_voice_" + _x))
                };
                if (count _valid > 0) then {
                    _voice = selectRandom _valid;
                } else {
                    _voice = "WEST";
                };
            } else {
                _voice = "WEST";
            };
        } else {
            _voice = "WEST";
        };
    };
};

_unit setVariable ["UVO_voice", _voice, true];
_unit setVariable ["UVO_Voice", _voice, true];
_unit setVariable ["UVO_Language", _voice, true];
_unit setVariable ["UVO_Type", _voice, true];
_unit setVariable ["uvo_voice", _voice, true];
_unit setVariable ["uvo_language", _voice, true];
_unit setVariable ["uvo_type", _voice, true];
_unit setVariable ["UVO_suppressBuffer", 0, true];
_unit setVariable ["UVO_allowDeathShouts", true, true];

if (!isNil "uvo_main_fnc_add") then {
    [_unit, _voice] call uvo_main_fnc_add;
} else {
    if (!isNil "UVO_fnc_add") then {
        [_unit, _voice] call UVO_fnc_add;
    };
};
