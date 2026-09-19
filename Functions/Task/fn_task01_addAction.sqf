if (!hasInterface) exitWith {};

_this spawn {
    params [
        ["_corpseParam", objNull, [objNull]],
        ["_corpseNetId", "", [""]],
        ["_corpseVar", "", [""]],
        ["_docParam", objNull, [objNull]],
        ["_docNetId", "", [""]],
        ["_docVar", "", [""]]
    ];

    private _corpse = _corpseParam;
    if (isNull _corpse) then {
        private _timeout = time + 30;
        waitUntil {
            sleep 0.5;
            if (_corpseNetId != "") then { _corpse = objectFromNetId _corpseNetId; };
            if (isNull _corpse && _corpseVar != "") then { _corpse = missionNamespace getVariable [_corpseVar, objNull]; };
            !isNull _corpse || time > _timeout
        };
    };

    private _doc = _docParam;
    if (isNull _doc) then {
        private _timeoutDoc = time + 30;
        waitUntil {
            sleep 0.5;
            if (_docNetId != "") then { _doc = objectFromNetId _docNetId; };
            if (isNull _doc && _docVar != "") then { _doc = missionNamespace getVariable [_docVar, objNull]; };
            !isNull _doc || time > _timeoutDoc
        };
    };

    if (isNull _corpse && isNull _doc) exitWith {};

    private _actionCode = {
        params ["_target", "_caller", "_actionId", "_customArgs"];
        _customArgs params ["_corpseObj", "_docObj"];

        if (missionNamespace getVariable ["LL_Task01_ActionTriggered", false]) exitWith {};
        missionNamespace setVariable ["LL_Task01_ActionTriggered", true, true];

        if (!isNull _corpseObj) then { removeAllActions _corpseObj; };
        if (!isNull _docObj) then { removeAllActions _docObj; };

        _caller playActionNow "PutDown";

        private _itemDoc = "";
        {
            if (isClass (configFile >> "CfgWeapons" >> _x)) exitWith { _itemDoc = _x; };
        } forEach ["Item_Document_01_F", "Document_01_F", "Item_File1_F", "Item_File2_F", "Item_FilePhotos_F", "Item_Document", "ItemMap"];

        if (_itemDoc != "") then {
            if (_caller canAdd _itemDoc) then {
                _caller addItem _itemDoc;
            } else {
                _caller addItemToUniform _itemDoc;
            };
        };

        if (!isNull _docObj) then {
            deleteVehicle _docObj;
        };

        ["collect", [_corpseObj, _docObj]] remoteExec ["LL_fnc_task01", 2];
    };

    if (!isNull _corpse) then {
        _corpse addAction [
            format ["<t color='#FFFF00'>%1</t>", localize "STR_LL_Task_01_Action"],
            _actionCode,
            [_corpse, _doc],
            10,
            true,
            true,
            "",
            "_this distance _target < 4",
            4
        ];
    };

    if (!isNull _doc) then {
        _doc addAction [
            format ["<t color='#FFFF00'>%1</t>", localize "STR_LL_Task_01_Action"],
            _actionCode,
            [_corpse, _doc],
            10,
            true,
            true,
            "",
            "_this distance _target < 4",
            4
        ];
    };
};
