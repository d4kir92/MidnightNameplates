local _, MidnightNameplates = ...
local MNNPSetup = CreateFrame("FRAME", "MNNPSetup")
MidnightNameplates:RegisterEvent(MNNPSetup, "PLAYER_LOGIN")
MNNPSetup:SetScript(
    "OnEvent",
    function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            MNNP = MNNP or {}
            MidnightNameplates:SetVersion(136142, "0.1.18")
            MidnightNameplates:SetAddonOutput("MidnightNameplates", 136142)
            MidnightNameplates:AddSlash("mina", MidnightNameplates.ToggleSettings)
            MidnightNameplates:AddSlash("mnnp", MidnightNameplates.ToggleSettings)
            MidnightNameplates:AddSlash("MidnightNameplates", MidnightNameplates.ToggleSettings)
            local mmbtn = nil
            MidnightNameplates:CreateMinimapButton(
                {
                    ["name"] = "MidnightNameplates",
                    ["icon"] = 136142,
                    ["var"] = mmbtn,
                    ["dbtab"] = MNNP,
                    ["vTT"] = {{"M|cff3FC7EBidnight|rN|cff3FC7EBameplates|r", "v|cff3FC7EB" .. MidnightNameplates:GetVersion()}, {MidnightNameplates:Trans("LID_LEFTCLICK"), MidnightNameplates:Trans("LID_OPENSETTINGS")}, {MidnightNameplates:Trans("LID_RIGHTCLICK"), MidnightNameplates:Trans("LID_HIDEMINIMAPBUTTON")}},
                    ["funcL"] = function()
                        MidnightNameplates:ToggleSettings()
                    end,
                    ["funcR"] = function()
                        MidnightNameplates:SV(MNNP, "SHOWMINIMAPBUTTON", false)
                        MidnightNameplates:HideMMBtn("MidnightNameplates")
                        MidnightNameplates:MSG("Minimap Button is now hidden.")
                    end,
                    ["dbkey"] = "SHOWMINIMAPBUTTON"
                }
            )

            MidnightNameplates:InitSettings()
        end
    end
)

local mn_settings = nil
function MidnightNameplates:ToggleSettings()
    if mn_settings then
        if mn_settings:IsShown() then
            mn_settings:Hide()
        else
            mn_settings:Show()
        end
    end
end

function MidnightNameplates:InitSettings()
    MNNP = MNNP or {}
    if MNNP["BARWIDTH"] == nil then
        MNNP["BARWIDTH"] = 140
    end

    if MNNP["BARHEIGHT"] == nil then
        MNNP["BARHEIGHT"] = 9
    end

    if MNNP["SHOWLEVEL"] == nil then
        MNNP["SHOWLEVEL"] = true
    end

    if MNNP["POWERBAR"] == nil then
        MNNP["POWERBAR"] = true
    end

    if MNNP["CASTBAR"] == nil then
        MNNP["CASTBAR"] = true
    end

    MNNP["MAXDEBUFFS"] = MNNP["MAXDEBUFFS"] or 5
    MNNP["FONTSIZE"] = MNNP["FONTSIZE"] or 2
    mn_settings = MidnightNameplates:CreateWindow(
        {
            ["name"] = "MidnightNameplates",
            ["pTab"] = {"CENTER"},
            ["sw"] = 520,
            ["sh"] = 520,
            ["title"] = format("M|cff3FC7EBidnight|rN|cff3FC7EBameplates|r v|cff3FC7EB%s", MidnightNameplates:GetVersion())
        }
    )

    local x = 15
    local y = 10
    MidnightNameplates:SetAppendX(x)
    MidnightNameplates:SetAppendY(y)
    MidnightNameplates:SetAppendParent(mn_settings)
    MidnightNameplates:SetAppendTab(MNNP)
    MidnightNameplates:AppendCategory("GENERAL")
    MidnightNameplates:AppendCheckbox(
        "SHOWMINIMAPBUTTON",
        MidnightNameplates:GetWoWBuild() ~= "RETAIL",
        function()
            if MidnightNameplates:GV(MNNP, "SHOWMINIMAPBUTTON", MidnightNameplates:GetWoWBuild() ~= "RETAIL") then
                MidnightNameplates:ShowMMBtn("MidnightNameplates")
            else
                MidnightNameplates:HideMMBtn("MidnightNameplates")
            end
        end
    )

    MidnightNameplates:AppendCategory("NAMEPLATE")
    MidnightNameplates:AppendSlider(
        "BARWIDTH",
        140,
        80,
        240,
        10,
        0,
        function(sel, val)
            for i, v in ipairs(MidnightNameplates:WidthBars()) do
                v:SetWidth(val)
            end

            for i, plate in ipairs(C_NamePlate.GetNamePlates()) do
                MidnightNameplates:SetName(plate, plate.namePlateUnitToken)
            end
        end, "BARWIDTH"
    )

    MidnightNameplates:AppendSlider(
        "BARHEIGHT",
        9,
        3,
        20,
        1,
        0,
        function(sel, val)
            for i, v in ipairs(MidnightNameplates:HeightBars()) do
                v:SetHeight(val)
            end
        end, "BARHEIGHT"
    )

    MidnightNameplates:AppendSlider(
        "FONTSIZE",
        2,
        1,
        10,
        1,
        0,
        function(sel, val)
            MidnightNameplates:UpdateFontObjects(val)
            for i, plate in ipairs(C_NamePlate.GetNamePlates()) do
                MidnightNameplates:SetName(plate, plate.namePlateUnitToken)
            end
        end, "BARHEIGHT"
    )

    MidnightNameplates:AppendSlider("MAXDEBUFFS", 5, 1, 9, 1, 0, function(sel, val) end, "MAXDEBUFFS")
    MidnightNameplates:AppendCheckbox(
        "SHOWLEVEL",
        true,
        function(sel, val)
            for i, plate in ipairs(C_NamePlate.GetNamePlates()) do
                MidnightNameplates:SetName(plate, plate.namePlateUnitToken)
            end
        end
    )

    MidnightNameplates:AppendCheckbox(
        "POWERBAR",
        true,
        function(sel, val)
            for i, plate in ipairs(C_NamePlate.GetNamePlates()) do
                if val then
                    MidnightNameplates:ShowPowerBar(plate)
                else
                    MidnightNameplates:HidePowerBar(plate)
                end
            end
        end
    )

    MidnightNameplates:AppendCheckbox(
        "CASTBAR",
        true,
        function(sel, val)
            for i, plate in ipairs(C_NamePlate.GetNamePlates()) do
                if val then
                    MidnightNameplates:ShowCastBar(plate)
                else
                    MidnightNameplates:HideCastBar(plate)
                end
            end
        end
    )
end
