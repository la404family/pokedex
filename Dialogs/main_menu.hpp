class RscText
{
    deletable = 0;
    fade = 0;
    access = 0;
    type = 0;
    idc = -1;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = {1, 1, 1, 1};
    text = "";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0.037;
    w = 0.3;
    style = 0;
    shadow = 1;
    colorShadow[] = {0, 0, 0, 0.5};
    font = "RobotoCondensed";
    SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    linespacing = 1;
    tooltipColorBox[] = {1, 1, 1, 1};
    tooltipColorText[] = {1, 1, 1, 1};
    tooltipColorColor[] = {0, 0, 0, 1};
};

class RscCheckBox
{
    idc = -1;
    type = 77;
    style = 0;
    checked = 0;
    x = "0.375 * safezoneW + safezoneX";
    y = "0.36 * safezoneH + safezoneY";
    w = "0.025 * safezoneW";
    h = "0.04 * safezoneH";
    color[] = {1, 1, 1, 0.7};
    colorFocused[] = {1, 1, 1, 1};
    colorHover[] = {1, 1, 1, 1};
    colorPressed[] = {1, 1, 1, 1};
    colorDisabled[] = {1, 1, 1, 0.2};
    colorBackground[] = {0, 0, 0, 0};
    colorBackgroundFocused[] = {0, 0, 0, 0};
    colorBackgroundHover[] = {0, 0, 0, 0};
    colorBackgroundPressed[] = {0, 0, 0, 0};
    colorBackgroundDisabled[] = {0, 0, 0, 0};
    textureChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
    textureUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
    textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
    textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
    textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
    textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
    texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
    texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
    textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
    textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
    tooltipColorText[] = {1, 1, 1, 1};
    tooltipColorBox[] = {1, 1, 1, 1};
    tooltipColorShade[] = {0, 0, 0, 0.65};
    soundEnter[] = {"", 0.1, 1};
    soundPush[] = {"", 0.1, 1};
    soundClick[] = {"", 0.1, 1};
    soundEscape[] = {"", 0.1, 1};
};

class RscButton
{
    deletable = 0;
    fade = 0;
    type = 1;
    text = "";
    colorText[] = {1, 1, 1, 1};
    colorDisabled[] = {0.4, 0.4, 0.4, 1};
    colorBackground[] = {0.2, 0.2, 0.2, 1};
    colorBackgroundDisabled[] = {0.3, 0.3, 0.3, 1};
    colorBackgroundActive[] = {0, 0.5, 0.8, 1};
    colorFocused[] = {0, 0.5, 0.8, 1};
    colorShadow[] = {0, 0, 0, 0};
    colorBorder[] = {0, 0, 0, 1};
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
    style = 2;
    x = 0;
    y = 0;
    w = 0.095589;
    h = 0.039216;
    shadow = 2;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    borderSize = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
};

class RscListBox
{
    deletable = 0;
    fade = 0;
    type = 5;
    rowHeight = 0.04;
    colorText[] = {1, 1, 1, 1};
    colorDisabled[] = {1, 1, 1, 0.25};
    colorScrollbar[] = {1, 0, 0, 0};
    colorSelect[] = {1, 1, 1, 1};
    colorSelect2[] = {1, 1, 1, 1};
    colorSelectBackground[] = {0.15, 0.4, 0.7, 1};
    colorSelectBackground2[] = {0.15, 0.4, 0.7, 1};
    colorBackground[] = {0, 0, 0, 0.3};
    soundSelect[] = {"\A3\ui_f\data\sound\RscCombo\soundSelect", 0.1, 1};
    arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
    arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
    wholeRow = 1;
    style = 16;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    shadow = 0;
    colorShadow[] = {0, 0, 0, 0.5};
    period = 1.2;
    maxHistoryDelay = 1;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    class ListScrollBar
    {
        color[] = {1, 1, 1, 1};
        autoScrollEnabled = 1;
    };
};

class RscCombo
{
    deletable = 0;
    fade = 0;
    type = 4;
    wholeHeight = 0.3;
    colorSelect[] = {1, 1, 1, 1};
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0.08, 0.1, 0.14, 0.9};
    colorSelectBackground[] = {0.15, 0.4, 0.7, 1};
    colorScrollbar[] = {1, 0, 0, 1};
    colorDisabled[] = {1, 1, 1, 0.25};
    colorPicture[] = {1, 1, 1, 1};
    colorPictureSelected[] = {1, 1, 1, 1};
    colorPictureDisabled[] = {1, 1, 1, 0.25};
    colorPictureRight[] = {1, 1, 1, 1};
    colorPictureRightSelected[] = {1, 1, 1, 1};
    colorPictureRightDisabled[] = {1, 1, 1, 0.25};
    colorTextRight[] = {1, 1, 1, 1};
    colorSelectRight[] = {1, 1, 1, 1};
    colorSelect2Right[] = {1, 1, 1, 1};
    tooltipColorBox[] = {1, 1, 1, 1};
    tooltipColorText[] = {1, 1, 1, 1};
    tooltipColorColor[] = {0, 0, 0, 1};
    soundSelect[] = {"\A3\ui_f\data\sound\RscCombo\soundSelect", 0.1, 1};
    soundExpand[] = {"\A3\ui_f\data\sound\RscCombo\soundExpand", 0.1, 1};
    soundCollapse[] = {"\A3\ui_f\data\sound\RscCombo\soundCollapse", 0.1, 1};
    maxHistoryDelay = 1;
    class ComboScrollBar
    {
        color[] = {1, 1, 1, 1};
    };
    style = 0;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.12;
    h = 0.035;
    arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
    arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
    wholeRow = 0;
};

class RscPicture
{
    deletable = 0;
    fade = 0;
    access = 0;
    type = 0;
    idc = -1;
    style = 48;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = {1, 1, 1, 1};
    font = "RobotoCondensed";
    sizeEx = 0;
    lineSpacing = 0;
    text = "";
    fixedWidth = 0;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.15;
};



class RscMapControl
{
    deletable = 0;
    fade = 0;
    access = 0;
    type = 100;
    idc = -1;
    style = 48;
    colorBackground[] = {0.969, 0.957, 0.949, 1};
    colorOutside[] = {0, 0, 0, 1};
    colorText[] = {0, 0, 0, 1};
    colorSea[] = {0.467, 0.631, 0.851, 0.5};
    colorForest[] = {0.624, 0.78, 0.388, 0.5};
    colorForestBorder[] = {0, 0, 0, 0};
    colorRocks[] = {0, 0, 0, 0.3};
    colorRocksBorder[] = {0, 0, 0, 0};
    colorLevels[] = {0.286, 0.176, 0.094, 0.5};
    colorMainCountlines[] = {0.572, 0.354, 0.188, 0.5};
    colorCountlines[] = {0.572, 0.354, 0.188, 0.25};
    colorMainCountlinesWater[] = {0.491, 0.577, 0.702, 0.6};
    colorCountlinesWater[] = {0.491, 0.577, 0.702, 0.3};
    colorPowerLines[] = {0.1, 0.1, 0.1, 1};
    colorRailWay[] = {0.8, 0.2, 0, 1};
    colorNames[] = {0.1, 0.1, 0.1, 0.9};
    colorInactive[] = {1, 1, 1, 0.5};
    colorTracks[] = {0.84, 0.76, 0.65, 0.15};
    colorTracksFill[] = {0.84, 0.76, 0.65, 1};
    colorRoads[] = {0.7, 0.7, 0.7, 1};
    colorRoadsFill[] = {1, 1, 1, 1};
    colorMainRoads[] = {0.9, 0.5, 0.3, 1};
    colorMainRoadsFill[] = {1, 0.6, 0.4, 1};
    colorGrid[] = {0.1, 0.1, 0.1, 0.6};
    colorGridMap[] = {0.1, 0.1, 0.1, 0.6};
    font = "TahomaB";
    sizeEx = 0.04;
    fontLabel = "RobotoCondensed";
    sizeExLabel = 0.02;
    fontGrid = "TahomaB";
    sizeExGrid = 0.02;
    fontUnits = "RobotoCondensed";
    sizeExUnits = 0.02;
    fontNames = "RobotoCondensed";
    sizeExNames = 0.02;
    fontInfo = "RobotoCondensed";
    sizeExInfo = 0.02;
    fontLevel = "TahomaB";
    sizeExLevel = 0.02;
    text = "#(argb,8,8,3)color(1,1,1,1)";
    ptsPerSquareSea = 5;
    ptsPerSquareTxt = 20;
    ptsPerSquareWd = 10;
    ptsPerSquareAtr = 10;
    ptsPerSquareExp = 10;
    ptsPerSquareObj = 10;
    ptsPerSquareCLn = 10;
    ptsPerSquareCost = 10;
    ptsPerSquareFor = 10;
    ptsPerSquareForL = 10;
    ptsPerSquareForEdge = 10;
    ptsPerSquareRoad = 10;
    ptsPerSquareMainRoad = 10;
    ptsPerSquareTree = 10;
    ptsPerSquareBusStop = 10;
    scaleMin = 0.001;
    scaleMax = 1.0;
    scaleDefault = 0.16;
    showCountLines = 0;
    showCountourInterval = 0;
    showTile = 1;
    showMapBorder = 0;
    showMarkers = 1;
    maxLevelsOfAlphaScale = 2;
    maxSatelliteAlpha = 0.85;
    alphaFadeStartScale = 0.15;
    alphaFadeEndScale = 0.29;
    fontFullHTML = "RobotoCondensed";
    widthRailWay = 1;
    widthMainRoad = 2;
    widthRoad = 1;
    widthTrack = 1;
    widthCountLines = 1;
    class CustomMark
    {
        icon = "\A3\ui_f\data\map\mapcontrol\custommark_ca.paa";
        size = 18;
        importance = 1;
        color[] = {1, 1, 1, 1};
        coefMin = 1;
        coefMax = 1;
    };
    class Legend
    {
        x = 0;
        y = 0;
        w = 0.1;
        h = 0.1;
        font = "RobotoCondensed";
        sizeEx = 0.02;
        colorBackground[] = {1, 1, 1, 0.5};
        color[] = {0, 0, 0, 1};
    };
    class ActiveMarker
    {
        color[] = {0.3, 0.1, 0.9, 1};
        size = 50;
    };
    class Command
    {
        icon = "\A3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
        size = 18;
        importance = 1;
        color[] = {1, 1, 1, 1};
        coefMin = 1;
        coefMax = 1;
    };
    class WayPoint
    {
        icon = "\A3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 18;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class WaypointCompleted
    {
        icon = "\A3\ui_f\data\map\mapcontrol\waypointcompleted_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 18;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Bunker
    {
        icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Fortress
    {
        icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Fountain
    {
        icon = "\A3\ui_f\data\map\mapcontrol\fountain_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 11;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Shipwreck
    {
        icon = "\A3\ui_f\data\map\mapcontrol\shipwreck_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Wreck
    {
        icon = "\A3\ui_f\data\map\mapcontrol\wreck_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Bush
    {
        icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = 14;
        importance = 0.2;
        coefMin = 0.25;
        coefMax = 1;
    };
    class BusStop
    {
        icon = "\A3\ui_f\data\map\mapcontrol\busstop_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 12;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Cross
    {
        icon = "\A3\ui_f\data\map\mapcontrol\cross_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 0.7;
        coefMin = 0.25;
        coefMax = 1;
    };
    class Church
    {
        icon = "\A3\ui_f\data\map\mapcontrol\church_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Chapel
    {
        icon = "\A3\ui_f\data\map\mapcontrol\chapel_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Fuelstation
    {
        icon = "\A3\ui_f\data\map\mapcontrol\fuelstation_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Hospital
    {
        icon = "\A3\ui_f\data\map\mapcontrol\hospital_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Lighthouse
    {
        icon = "\A3\ui_f\data\map\mapcontrol\lighthouse_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Power
    {
        icon = "\A3\ui_f\data\map\mapcontrol\power_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class PowerSolar
    {
        icon = "\A3\ui_f\data\map\mapcontrol\powersolar_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class PowerWave
    {
        icon = "\A3\ui_f\data\map\mapcontrol\powerwave_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class PowerWind
    {
        icon = "\A3\ui_f\data\map\mapcontrol\powerwind_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Quay
    {
        icon = "\A3\ui_f\data\map\mapcontrol\quay_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Quarry
    {
        icon = "\A3\ui_f\data\map\mapcontrol\quarry_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 14;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Task
    {
        icon = "\A3\ui_f\data\map\mapcontrol\taskIcon_ca.paa";
        color[] = {1, 1, 1, 1};
        iconCreated = "\A3\ui_f\data\map\mapcontrol\taskIconCreated_ca.paa";
        iconCanceled = "\A3\ui_f\data\map\mapcontrol\taskIconCanceled_ca.paa";
        iconDone = "\A3\ui_f\data\map\mapcontrol\taskIconDone_ca.paa";
        iconFailed = "\A3\ui_f\data\map\mapcontrol\taskIconFailed_ca.paa";
        colorCreated[] = {1, 1, 1, 1};
        colorCanceled[] = {0.7, 0.7, 0.7, 1};
        colorDone[] = {0.7, 1, 0.7, 1};
        colorFailed[] = {1, 0.7, 0.7, 1};
        size = 16;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Rock
    {
        icon = "\A3\ui_f\data\map\mapcontrol\rock_ca.paa";
        color[] = {0.1, 0.1, 0.1, 0.8};
        size = 12;
        importance = 0.5;
        coefMin = 0.25;
        coefMax = 1;
    };
    class Ruin
    {
        icon = "\A3\ui_f\data\map\mapcontrol\ruins_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Ruins
    {
        icon = "\A3\ui_f\data\map\mapcontrol\ruins_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class SmallTree
    {
        icon = "\A3\ui_f\data\map\mapcontrol\something_ca.paa";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = 12;
        importance = 0.6;
        coefMin = 0.25;
        coefMax = 1;
    };
    class Stack
    {
        icon = "\A3\ui_f\data\map\mapcontrol\stack_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 20;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Tree
    {
        icon = "\A3\ui_f\data\map\mapcontrol\something_ca.paa";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = 12;
        importance = 0.9;
        coefMin = 0.25;
        coefMax = 1;
    };
    class TacticalPing
    {
        icon = "\A3\ui_f\data\map\mapcontrol\custommark_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 18;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Tourism
    {
        icon = "\A3\ui_f\data\map\mapcontrol\tourist_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Tourist
    {
        icon = "\A3\ui_f\data\map\mapcontrol\tourist_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Transmitter
    {
        icon = "\A3\ui_f\data\map\mapcontrol\transmitter_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class ViewPoint
    {
        icon = "\A3\ui_f\data\map\mapcontrol\viewtower_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class ViewTower
    {
        icon = "\A3\ui_f\data\map\mapcontrol\viewtower_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class WaterTower
    {
        icon = "\A3\ui_f\data\map\mapcontrol\watertower_ca.paa";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class LineMarker
    {
        lineDistanceMin = 3e-005;
        lineLengthMin = 5;
        lineWidthThick = 0.014;
        lineWidthThin = 0.008;
        textureComboBoxColor = "#(argb,8,8,3)color(1,1,1,1)";
    };
};

class Refour_Main_Menu_Dialog
{
    idd = 7000;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground
    {
        class FullScreenBackground: RscText
        {
            idc = -1;
            x = safezoneX;
            y = safezoneY;
            w = safezoneW;
            h = safezoneH;
            colorBackground[] = {0.04, 0.06, 0.09, 0.96};
        };

        class TopHeaderBar: RscText
        {
            idc = -1;
            text = "$STR_MAIN_MENU_TITLE";
            x = safezoneX;
            y = safezoneY;
            w = safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0.1, 0.25, 0.45, 1};
            style = 0x02;
            sizeEx = 0.04;
        };

        class LeftPanelBg: RscText
        {
            idc = -1;
            x = safezoneX + (0.02 * safezoneW);
            y = safezoneY + (0.08 * safezoneH);
            w = 0.30 * safezoneW;
            h = 0.78 * safezoneH;
            colorBackground[] = {0.08, 0.10, 0.13, 0.85};
        };

        class MiddlePanelBg: RscText
        {
            idc = -1;
            x = safezoneX + (0.34 * safezoneW);
            y = safezoneY + (0.08 * safezoneH);
            w = 0.30 * safezoneW;
            h = 0.78 * safezoneH;
            colorBackground[] = {0.08, 0.10, 0.13, 0.85};
        };

        class RightPanelBg: RscText
        {
            idc = -1;
            x = safezoneX + (0.66 * safezoneW);
            y = safezoneY + (0.08 * safezoneH);
            w = 0.32 * safezoneW;
            h = 0.78 * safezoneH;
            colorBackground[] = {0.08, 0.10, 0.13, 0.85};
        };
    };

    class controls
    {
        class MissionListHeader: RscText
        {
            idc = -1;
            text = "$STR_MAIN_MENU_OBJECTIVES";
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.10 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.15, 0.3, 0.5, 1};
        };

        // --- TÂCHES OBLIGATOIRES ---
        class CB_Man1: RscCheckBox {
            idc = 7100;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.14 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Man1: RscText {
            idc = -1;
            text = "$STR_TASK_MAN1";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.14 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.6, 0.6, 0.6, 1};
        };

        class CB_Man2: RscCheckBox {
            idc = 7101;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.17 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Man2: RscText {
            idc = -1;
            text = "$STR_TASK_MAN2";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.17 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.6, 0.6, 0.6, 1};
        };

        class CB_Man3: RscCheckBox {
            idc = 7102;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.20 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Man3: RscText {
            idc = -1;
            text = "$STR_TASK_MAN3";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.20 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.6, 0.6, 0.6, 1};
        };

        class DividerMandatory: RscText {
            idc = -1;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.235 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.002 * safezoneH;
            colorBackground[] = {1, 1, 1, 0.2};
        };

        // --- TÂCHES OPTIONNELLES ---
        class CB_Opt1: RscCheckBox {
            idc = 7110;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.25 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt1: RscText {
            idc = -1;
            text = "$STR_TASK_OPT1";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.25 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class CB_Opt2: RscCheckBox {
            idc = 7111;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.28 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt2: RscText {
            idc = -1;
            text = "$STR_TASK_OPT2";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.28 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class CB_Opt3: RscCheckBox {
            idc = 7112;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.31 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt3: RscText {
            idc = -1;
            text = "$STR_TASK_OPT3";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.31 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class CB_Opt4: RscCheckBox {
            idc = 7113;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.34 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt4: RscText {
            idc = -1;
            text = "$STR_TASK_OPT4";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.34 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class CB_Opt5: RscCheckBox {
            idc = 7114;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.37 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt5: RscText {
            idc = -1;
            text = "$STR_TASK_OPT5";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.37 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class CB_Opt6: RscCheckBox {
            idc = 7115;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.40 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt6: RscText {
            idc = -1;
            text = "$STR_TASK_OPT6";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.40 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class CB_Opt7: RscCheckBox {
            idc = 7116;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.43 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt7: RscText {
            idc = -1;
            text = "$STR_TASK_OPT7";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.43 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class CB_Opt8: RscCheckBox {
            idc = 7117;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.46 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt8: RscText {
            idc = -1;
            text = "$STR_TASK_OPT8";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.46 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class CB_Opt9: RscCheckBox {
            idc = 7118;
            x = safezoneX + (0.03 * safezoneW);
            y = safezoneY + (0.49 * safezoneH);
            w = 0.015 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class Txt_Opt9: RscText {
            idc = -1;
            text = "$STR_TASK_OPT9";
            x = safezoneX + (0.05 * safezoneW);
            y = safezoneY + (0.49 * safezoneH);
            w = 0.26 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class EnvHeader: RscText
        {
            idc = -1;
            text = "$STR_LABEL_ENVIRONMENT";
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.10 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.15, 0.3, 0.5, 1};
        };

        class LabelTime: RscText
        {
            idc = -1;
            text = "$STR_LABEL_TIME";
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.14 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class ComboTime: RscCombo
        {
            idc = 7200;
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.165 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.035 * safezoneH;
            onLBSelChanged = "['UPDATE_ENV_PREVIEW', _this] spawn LL_fnc_spawn_main_menu;";
        };

        class LabelClouds: RscText
        {
            idc = -1;
            text = "$STR_LABEL_CLOUDS";
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.205 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class ComboClouds: RscCombo
        {
            idc = 7201;
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.23 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.035 * safezoneH;
            onLBSelChanged = "['UPDATE_ENV_PREVIEW', _this] spawn LL_fnc_spawn_main_menu;";
        };

        class LabelFog: RscText
        {
            idc = -1;
            text = "$STR_LABEL_FOG";
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.27 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class ComboFog: RscCombo
        {
            idc = 7202;
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.295 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.03 * safezoneH;
            onLBSelChanged = "['UPDATE_ENV_PREVIEW', _this] spawn LL_fnc_spawn_main_menu;";
        };

        class LabelVehicle: RscText
        {
            idc = -1;
            text = "$STR_LABEL_VEHICLE_SELECT";
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.335 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class ComboVehicle: RscCombo
        {
            idc = 7204;
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.36 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.03 * safezoneH;
            onLBSelChanged = "['SELECT_VEHICLE', _this] spawn LL_fnc_spawn_main_menu;";
        };

        class VehicleCameraHeader: RscText
        {
            idc = -1;
            text = "$STR_LABEL_VEHICLE_CAM";
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.40 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.025 * safezoneH;
            colorBackground[] = {0.15, 0.3, 0.5, 1};
        };

        class VehicleCameraScreen: RscPicture
        {
            idc = 7203;
            text = "#(argb,512,512,1)r2t(rendertarget8,1.0)";
            x = safezoneX + (0.35 * safezoneW);
            y = safezoneY + (0.43 * safezoneH);
            w = 0.28 * safezoneW;
            h = 0.435 * safezoneH;
        };

        class TacticalHeader: RscText
        {
            idc = -1;
            text = "$STR_LABEL_TACTICAL_DEPLOYMENT";
            x = safezoneX + (0.67 * safezoneW);
            y = safezoneY + (0.10 * safezoneH);
            w = 0.30 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.15, 0.3, 0.5, 1};
        };

        class LabelLocation: RscText
        {
            idc = -1;
            text = "$STR_DEPLOYMENT_SECTOR";
            x = safezoneX + (0.67 * safezoneW);
            y = safezoneY + (0.14 * safezoneH);
            w = 0.30 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class LocationCombo: RscCombo
        {
            idc = 7300;
            x = safezoneX + (0.67 * safezoneW);
            y = safezoneY + (0.17 * safezoneH);
            w = 0.30 * safezoneW;
            h = 0.035 * safezoneH;
            onLBSelChanged = "['UPDATE_MAP'] call LL_fnc_spawn_main_menu;";
        };

        class LabelInsertion: RscText
        {
            idc = -1;
            text = "$STR_INSERTION_VECTOR";
            x = safezoneX + (0.67 * safezoneW);
            y = safezoneY + (0.22 * safezoneH);
            w = 0.30 * safezoneW;
            h = 0.025 * safezoneH;
        };
        class InsertionCombo: RscCombo
        {
            idc = 7301;
            x = safezoneX + (0.67 * safezoneW);
            y = safezoneY + (0.25 * safezoneH);
            w = 0.30 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class MapPreview: RscMapControl
        {
            idc = 7302;
            x = safezoneX + (0.67 * safezoneW);
            y = safezoneY + (0.30 * safezoneH);
            w = 0.30 * safezoneW;
            h = 0.54 * safezoneH;
            showMarkers = 1;
        };

        class ButtonLaunch: RscButton
        {
            idc = -1;
            text = "$STR_MAIN_MENU_LAUNCH";
            x = safezoneX + (0.43 * safezoneW);
            y = safezoneY + (0.88 * safezoneH);
            w = 0.18 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0.15, 0.6, 0.25, 1};
            sizeEx = 0.035;
            action = "['LAUNCH'] call LL_fnc_spawn_main_menu;";
        };
    };
};
