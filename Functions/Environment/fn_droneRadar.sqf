params ["_drone"];
if (!hasInterface) exitWith {};
if (isNil "_drone" || {isNull _drone}) exitWith {};

[_drone] spawn {
    params ["_drone"];
    private _tracked = [];

    while {alive _drone} do {
        sleep 1;

        private _enemies = allUnits select { side group _x in [east, independent, civilian] && {alive _x} };

        for "_i" from (count _tracked - 1) to 0 step -1 do {
            private _item = _tracked select _i;
            private _u = _item select 0;
            private _m = _item select 1;

            if (!alive _u || !(_u in _enemies)) then {
                deleteMarkerLocal _m;
                _tracked deleteAt _i;
            } else {
                _m setMarkerPosLocal (getPos _u);
            };
        };

        {
            private _u = _x;
            private _found = false;
            {
                if ((_x select 0) == _u) exitWith { _found = true; };
            } forEach _tracked;

            if (!_found) then {
                private _m = format ["LL_mrk_%1_%2", clientOwner, floor(random 1000000)];
                createMarkerLocal [_m, getPos _u];
                _m setMarkerShapeLocal "ICON";
                _m setMarkerTypeLocal "o_inf";

                private _color = "ColorEAST";
                if (side group _u == independent) then { _color = "ColorGUER"; };
                if (side group _u == civilian) then { _color = "ColorCIV"; };
                _m setMarkerColorLocal _color;

                _m setMarkerSizeLocal [0.6, 0.6];
                _tracked pushBack [_u, _m];
            };
        } forEach _enemies;
    };

    {
        deleteMarkerLocal (_x select 1);
    } forEach _tracked;
};
