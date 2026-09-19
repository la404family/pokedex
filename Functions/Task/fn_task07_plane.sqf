if (!isServer) exitWith {};

private _tank = missionNamespace getVariable ["LL_Task07_TargetTank", objNull];
if (isNull _tank || !alive _tank) exitWith {};

[_tank] spawn {
    params ["_tank"];
    
    private _spawnPos = getPos _tank getPos [4000, random 360];
    _spawnPos set [2, 600];
    
    private _planeGroup = createGroup [west, true];
    private _plane = createVehicle ["B_Plane_Fighter_01_F", _spawnPos, [], 0, "FLY"];
    _plane setDir (_plane getDir _tank);
    _plane setVelocityModelSpace [0, 250, 0];
    _plane allowDamage false;
    
    private _pilot = _planeGroup createUnit ["B_Fighter_Pilot_F", _spawnPos, [], 0, "NONE"];
    _pilot moveInDriver _plane;
    _pilot allowDamage false;
    
    _planeGroup setCombatMode "BLUE";
    _planeGroup setBehaviour "CARELESS";
    
    _plane flyInHeight 600;
    
    private _wp = _planeGroup addWaypoint [getPos _tank, 0];
    _wp setWaypointType "MOVE";
    
    private _timeout = time + 180;
    
    // Wait until plane is at good missile range (1500m)
    waitUntil { sleep 0.2; !alive _tank || !alive _plane || !alive _pilot || (_plane distance2D _tank < 1500) || time > _timeout };
    
    if (alive _plane && alive _pilot && alive _tank) then {
        
        // Function to spawn and guide a missile
        private _fnc_fireMissile = {
            params ["_plane", "_tank", "_offsetX"];
            private _missile = createVehicle ["Missile_AGM_02_F", [0,0,0], [], 0, "FLY"];
            _missile setPosASL (AGLToASL (_plane modelToWorld [_offsetX, 0, -2]));
            _missile setVectorDirAndUp [vectorDir _plane, vectorUp _plane];
            _missile setVelocity (velocity _plane);
            
            [_missile, _tank] spawn {
                params ["_missile", "_tank"];
                while {alive _missile && alive _tank} do {
                    private _tPos = getPosASL _tank;
                    _tPos set [2, (_tPos select 2) + 1.5];
                    private _mPos = getPosASL _missile;
                    if (_mPos distance _tPos < 10) exitWith {};
                    
                    private _dir = _mPos vectorFromTo _tPos;
                    private _speed = (vectorMagnitude (velocity _missile)) + 20;
                    if (_speed > 400) then { _speed = 400; };
                    
                    _missile setVectorDirAndUp [_dir, [0,1,0]];
                    _missile setVelocity (_dir vectorMultiply _speed);
                    sleep 0.05;
                };
                
                // Failsafe
                if (alive _tank && !alive _missile) then { _tank setDamage 1; };
            };
        };
        
        // Fire 2 missiles (left and right wing)
        [_plane, _tank, -4] spawn _fnc_fireMissile;
        sleep 0.5;
        [_plane, _tank, 4] spawn _fnc_fireMissile;
        
    };
    
    if (alive _plane && alive _pilot) then {
        while {(count (waypoints _planeGroup)) > 0} do { deleteWaypoint ((waypoints _planeGroup) select 0); };

        private _exitPos = getPos _plane getPos [8000, getDir _plane];
        _exitPos set [2, 1500];
        private _wpExit = _planeGroup addWaypoint [_exitPos, 0];
        _wpExit setWaypointType "MOVE";
        _planeGroup setCurrentWaypoint _wpExit;
        _plane flyInHeight 1500;
        
        [_plane] spawn {
            params ["_plane"];
            sleep 25;
            if (!isNull _plane) then { 
                { deleteVehicle _x } forEach (crew _plane);
                deleteVehicle _plane; 
            };
        };
    };
};
