if (!isServer) exitWith {};

private _veh = missionNamespace getVariable ["vehicule_team", objNull];
if (isNull _veh) exitWith {};

clearWeaponCargoGlobal _veh;
clearMagazineCargoGlobal _veh;
clearItemCargoGlobal _veh;
clearBackpackCargoGlobal _veh;

private _weaponsMap = createHashMap;

private _units = [];
for "_i" from 0 to 5 do {
    private _u = missionNamespace getVariable [format ["player_%1", _i], objNull];
    if (!isNull _u && {alive _u}) then {
        _units pushBack _u;
    };
};

{
    private _weaponsToCheck = [];
    if (primaryWeapon _x != "") then { _weaponsToCheck pushBack [primaryWeapon _x, primaryWeaponMagazine _x] };
    if (secondaryWeapon _x != "") then { _weaponsToCheck pushBack [secondaryWeapon _x, secondaryWeaponMagazine _x] };
    if (handgunWeapon _x != "") then { _weaponsToCheck pushBack [handgunWeapon _x, handgunMagazine _x] };

    {
        _x params ["_w", "_mArray"];
        if (!(_w in _weaponsMap)) then {
            private _mag = "";
            if (count _mArray > 0) then { 
                _mag = _mArray select 0; 
            } else {
                private _c2 = [_w] call BIS_fnc_compatibleMagazines;
                if (count _c2 > 0) then { _mag = _c2 select 0; };
            };
            if (_mag != "") then {
                _weaponsMap set [_w, _mag];
            };
        };
    } forEach _weaponsToCheck;
} forEach _units;

{
    private _weapon = _x;
    private _mag = _y;
    _veh addWeaponCargoGlobal [_weapon, 1];
    _veh addMagazineCargoGlobal [_mag, 8];
} forEach _weaponsMap;

_veh addItemCargoGlobal ["FirstAidKit", 12];
_veh addMagazineCargoGlobal ["HandGrenade", 6];
_veh addMagazineCargoGlobal ["SmokeShell", 6];
_veh addMagazineCargoGlobal ["SmokeShellGreen", 2];
_veh addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
