if (!isServer) exitWith {};

params [
    ["_spawnCenter", objNull, [objNull, []]],
    ["_spawnSide", civilian, [civilian]],
    ["_maxUnits", 30, [0]],
    ["_spawnRadius", 500, [0]]
];

private _PATROL_DIST = 200;
private _refPos = [];

if (typeName _spawnCenter == "OBJECT") then {
    if (isNull _spawnCenter) exitWith {};
    _refPos = getPosATL _spawnCenter;
} else {
    if (count _spawnCenter == 0) exitWith {};
    _refPos = _spawnCenter;
};

if (count _refPos == 0) exitWith {};

private _buildings = nearestObjects [_refPos, ["House","Building"], _spawnRadius];
if (count _buildings == 0) exitWith {};

private _isEnemy = (_spawnSide == east || _spawnSide == opfor || _spawnSide == independent);
private _spawnedUnits = 0;

{
    if (_spawnedUnits >= _maxUnits) exitWith {};
    
    private _bPosList = _x buildingPos -1;
    if (count _bPosList > 0) then {
        private _bPos = selectRandom _bPosList;
        _bPos set [2, (_bPos select 2) + 0.5];
        
        private _grp = createGroup _spawnSide;
        private _class = if (_spawnSide == civilian) then { "C_man_1" } else { "O_G_Soldier_F" };
        
        private _unit = _grp createUnit [_class, _bPos, [], 0, "NONE"];
        _unit setPosASL (AGLToASL _bPos);
        
        // Ratio 5 à 10% de femmes
        private _isFemale = (random 1) < 0.10;
        
        [_unit, _isFemale, _isEnemy] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
        
        [_grp, getPosATL _unit, _PATROL_DIST] call BIS_fnc_taskPatrol;
        
        _spawnedUnits = _spawnedUnits + 1;
    };
} forEach _buildings;
