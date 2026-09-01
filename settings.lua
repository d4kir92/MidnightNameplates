local _, MidnightNameplates = ...
local mn_settings = nil
local DEFAULT_WIDTH = 520
local DEFAULT_HEIGHT = 520
local MNNPSetup = CreateFrame("FRAME", "MNNPSetup")
MidnightNameplates:RegisterEvent(MNNPSetup, "PLAYER_LOGIN")
MNNPSetup:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        MNNP = MNNP or {}
        MidnightNameplates:SetVersion(136142, "0.1.41")
        MidnightNameplates:SetAddonOutput("MidnightNameplates", 136142)
        MidnightNameplates:AddSlash("mina", MidnightNameplates.ToggleSettings)
        MidnightNameplates:AddSlash("mnnp", MidnightNameplates.ToggleSettings)
        MidnightNameplates:AddSlash("MidnightNameplates", MidnightNameplates.ToggleSettings)
        MidnightNameplates:CreateMinimapButton({
            ["name"] = "MidnightNameplates",
            ["icon"] = 136142,
            ["dbtab"] = MNNP,
            ["vTT"] = {{"MidnightNameplates", "v" .. MidnightNameplates:GetVersion()}, {MidnightNameplates:Trans("LID_LEFTCLICK"), MidnightNameplates:Trans("LID_OPENSETTINGS")}, {MidnightNameplates:Trans("LID_RIGHTCLICK"), MidnightNameplates:Trans("LID_HIDEMINIMAPBUTTON")}},
            ["funcL"] = function() MidnightNameplates:ToggleSettings() end,
            ["funcR"] = function()
                MidnightNameplates:SV(MNNP, "SHOWMINIMAPBUTTON", false)
                MidnightNameplates:HideMMBtn("MidnightNameplates")
                MidnightNameplates:MSG("Minimap Button is now hidden.")
            end,
            ["dbkey"] = "SHOWMINIMAPBUTTON"
        })

        MidnightNameplates:InitSettings()
    end
end)

function MidnightNameplates:ToggleSettings()
    if mn_settings == nil then return end
    mn_settings:Toggle()
end

local function GetCollapsed(key)
    if key == nil then return nil end
    if type(MNNP) ~= "table" then return nil end
    if type(MNNP["COLLAPSED"]) ~= "table" then return nil end

    return MNNP["COLLAPSED"][key]
end

local function SetCollapsed(key, collapsed)
    if key == nil then return end
    if type(MNNP) ~= "table" then return end
    if type(MNNP["COLLAPSED"]) ~= "table" then MNNP["COLLAPSED"] = {} end
    if collapsed then
        MNNP["COLLAPSED"][key] = true
    else
        MNNP["COLLAPSED"][key] = nil
    end
end

local function ForEachPlate(func)
    if C_NamePlate == nil then return end
    if C_NamePlate.GetNamePlates == nil then return end
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        if plate and plate.MINA then
            local unit = plate.namePlateUnitToken
            if unit == nil and plate.MINA_CB then unit = plate.MINA_CB.unit end
            func(plate, unit)
        end
    end
end

local function UpdateNames()
    ForEachPlate(function(plate, unit) MidnightNameplates:SetName(plate, unit) end)
end

local function AddCategory(key, level)
    mn_settings:AddCategory({
        ["label"] = "LID_" .. key,
        ["key"] = key,
        ["search"] = key,
        ["level"] = level
    })
end

local function AddCheckbox(key, default, func)
    mn_settings:AddCheckbox({
        ["label"] = "LID_" .. key,
        ["search"] = key,
        ["value"] = MidnightNameplates:GV(MNNP, key, default),
        ["func"] = function(value)
            MidnightNameplates:SV(MNNP, key, value)
            if func then func(value) end
        end
    })
end

local function AddSlider(key, default, min, max, step, decimals, func)
    mn_settings:AddSlider({
        ["label"] = "LID_" .. key,
        ["search"] = key,
        ["value"] = MidnightNameplates:GV(MNNP, key, default),
        ["min"] = min,
        ["max"] = max,
        ["step"] = step,
        ["decimals"] = decimals,
        ["func"] = function(value)
            MidnightNameplates:SV(MNNP, key, value)
            if func then func(value) end
        end
    })
end

function MidnightNameplates:InitSettings()
    MNNP = MNNP or {}
    if MNNP["SHOWMINIMAPBUTTON"] == nil then MNNP["SHOWMINIMAPBUTTON"] = MidnightNameplates:GetWoWBuild() ~= "RETAIL" end
    if MNNP["BARWIDTH"] == nil then MNNP["BARWIDTH"] = 140 end
    if MNNP["BARHEIGHT"] == nil then MNNP["BARHEIGHT"] = 9 end
    if MNNP["FONTSIZE"] == nil then MNNP["FONTSIZE"] = 2 end
    if MNNP["SHOWLEVEL"] == nil then MNNP["SHOWLEVEL"] = true end
    if MNNP["TARGETARROWS"] == nil then MNNP["TARGETARROWS"] = false end
    if MNNP["POWERBAR"] == nil then MNNP["POWERBAR"] = true end
    if MNNP["CASTBAR"] == nil then MNNP["CASTBAR"] = true end
    if MNNP["MAXDEBUFFS"] == nil then MNNP["MAXDEBUFFS"] = 5 end
    mn_settings = MidnightNameplates:CreateUIWindow({
        ["name"] = "MidnightNameplatesSettings",
        ["pTab"] = {"CENTER"},
        ["width"] = MidnightNameplates:GV(MNNP, "WINDOWWIDTH", DEFAULT_WIDTH),
        ["height"] = MidnightNameplates:GV(MNNP, "WINDOWHEIGHT", DEFAULT_HEIGHT),
        ["minWidth"] = 360,
        ["minHeight"] = 240,
        ["onResize"] = function(width, height)
            MidnightNameplates:SV(MNNP, "WINDOWWIDTH", width)
            MidnightNameplates:SV(MNNP, "WINDOWHEIGHT", height)
        end,
        ["getCollapsed"] = function(key) return GetCollapsed(key) end,
        ["setCollapsed"] = function(key, collapsed) SetCollapsed(key, collapsed) end,
        ["title"] = format("|T136142:16:16:0:0|t MidnightNameplates v%s", MidnightNameplates:GetVersion())
    })

    mn_settings:SuspendLayout()
    mn_settings:AddSearch()
    AddCategory("GENERAL")
    AddCheckbox("SHOWMINIMAPBUTTON", MidnightNameplates:GetWoWBuild() ~= "RETAIL", function(value)
        if value then
            MidnightNameplates:ShowMMBtn("MidnightNameplates")
        else
            MidnightNameplates:HideMMBtn("MidnightNameplates")
        end
    end)

    AddCategory("NAMEPLATE")
    AddCategory("SIZE", 2)
    AddSlider("BARWIDTH", 140, 80, 240, 10, 0, function(value)
        for _, bar in ipairs(MidnightNameplates:WidthBars()) do
            bar:SetWidth(value)
        end

        UpdateNames()
    end)

    AddSlider("BARHEIGHT", 9, 3, 20, 1, 0, function(value)
        for _, bar in ipairs(MidnightNameplates:HeightBars()) do
            bar:SetHeight(value)
        end
    end)

    AddCategory("TEXT", 2)
    AddSlider("FONTSIZE", 2, 1, 10, 1, 0, function(value)
        MidnightNameplates:UpdateFontObjects(value)
        UpdateNames()
    end)

    AddCheckbox("SHOWLEVEL", true, function() UpdateNames() end)
    AddCategory("TARGET", 2)
    AddCheckbox("TARGETARROWS", false, function()
        ForEachPlate(function(plate)
            if plate.MINA_TARGET then MidnightNameplates:UpdateArrows(plate) end
        end)
    end)

    AddCategory("BARS")
    AddCheckbox("POWERBAR", true, function(value)
        ForEachPlate(function(plate, unit)
            if value then
                MidnightNameplates:ShowPowerBar(plate)
                if unit then MidnightNameplates:UpdatePower(plate, unit) end
            else
                MidnightNameplates:HidePowerBar(plate)
            end
        end)
    end)

    AddCheckbox("CASTBAR", true, function(value)
        ForEachPlate(function(plate)
            if value then
                MidnightNameplates:ShowCastBar(plate)
            else
                MidnightNameplates:HideCastBar(plate)
            end
        end)
    end)

    AddCategory("AURAS")
    AddSlider("MAXDEBUFFS", 5, 1, 9, 1, 0, function()
        ForEachPlate(function(plate, unit)
            if unit then MidnightNameplates:UpdateDebuffs(plate, unit) end
        end)
    end)

    mn_settings:ResumeLayout()
end
