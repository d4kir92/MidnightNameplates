local _, MidnightNameplates = ...
local NAME = true
local DEBUFFS = true
local DEBUFF_BACKGROUND = false
local onlyPlayerDebuffs = true
local widthBars = {}
local heightBars = {}
local fontSizes = {}
fontSizes[80] = 8
fontSizes[90] = 11
fontSizes[100] = 13
fontSizes[110] = 15
fontSizes[120] = 17
fontSizes[130] = 19
fontSizes[140] = 21
fontSizes[150] = 23
fontSizes[160] = 25
fontSizes[170] = 26
fontSizes[180] = 28
fontSizes[190] = 30
fontSizes[200] = 32
fontSizes[210] = 33
fontSizes[220] = 35
fontSizes[230] = 37
fontSizes[240] = 39
function MidnightNameplates:SetName(plate, unit)
    local fs = fontSizes[MNNP["BARWIDTH"]] or 50
    local n = MidnightNameplates:ClampText(UnitName(unit) or "?", fs)
    if plate.MINA_NAME and plate.MINA_NAME.TEXT then
        plate.MINA_NAME.TEXT:SetText(n)
    end
end

function MidnightNameplates:WidthBars()
    return widthBars
end

function MidnightNameplates:HeightBars()
    return heightBars
end

function MidnightNameplates:AddFrameBar(parent, name, w, h, level)
    if parent[name] ~= nil then
        MidnightNameplates:INFO("[AddFrameBar] Already Exists", name)

        return
    end

    parent[name] = CreateFrame("Frame", name, parent)
    parent[name]:SetPoint("CENTER", parent, "CENTER", 0, 0)
    parent[name]:SetSize(w, h)
    parent[name]:SetFrameLevel(level)
end

function MidnightNameplates:AddStatusBar(parent, name, w, h, level)
    if parent[name] ~= nil then
        MidnightNameplates:INFO("[AddStatusBar] Already Exists", name)

        return
    end

    parent[name] = CreateFrame("StatusBar", name, parent)
    parent[name]:SetPoint("CENTER", parent, "CENTER", 0, 0)
    parent[name]:SetSize(w, h)
    parent[name]:SetFrameLevel(level)
end

function MidnightNameplates:AddFontString(parent, name, w, h, r, g, b, fontSize, layer, template)
    if parent[name] ~= nil then
        MidnightNameplates:INFO("[AddFontString] Already Exists", name)

        return
    end

    parent[name] = parent:CreateFontString(name, layer, template)
    parent[name]:SetSize(w, h)
    parent[name]:SetTextColor(r, g, b)
    parent[name]:SetText("")
    MidnightNameplates:SetFontSize(parent[name], fontSize)
end

function MidnightNameplates:AddTexture(parent, name, texture, layer, sublevel)
    if parent[name] ~= nil then
        MidnightNameplates:INFO("[AddTexture] Already Exists", name)

        return
    end

    parent[name] = parent:CreateTexture(name, layer)
    parent[name]:SetTexture(texture)
    parent[name]:SetAllPoints(parent)
    parent[name]:SetDrawLayer(layer, sublevel)
end

function MidnightNameplates:ClampText(text, max_length)
    if string.len(text) > max_length then
        return string.sub(text, 1, max_length) .. "..."
    else
        return text
    end
end

function MidnightNameplates:FormatTime(sec)
    if sec >= 60 then
        return string.format("%dm", math.floor(sec / 60))
    else
        return string.format("%d", sec)
    end
end

function MidnightNameplates:IconOnUpdate(sel, elapsed)
    if not sel.expirationTime then return end
    local remain = sel.expirationTime - GetTime()
    if remain >= 0 then
        sel.text:SetText(MidnightNameplates:FormatTime(remain))
    else
        sel:SetScript("OnUpdate", nil)
        sel:Hide()
    end
end

local oldTarget = nil
function MidnightNameplates:UpdateTarget(plate, unit)
    if not UnitIsUnit(unit, "target") then return end
    if oldTarget and oldTarget.MINA_TARGET and oldTarget.MINA_TARGET.Texture then
        oldTarget.MINA_TARGET.Texture:Hide()
    end

    if not plate or not plate.MINA_TARGET or not plate.MINA_TARGET.Texture then return end
    plate.MINA_TARGET.Texture:Show()
    oldTarget = plate
end

function MidnightNameplates:UpdateDebuffs(plate, unit)
    if not plate or not plate.MINA_DEBUFFS then return end
    local frame = plate.MINA_DEBUFFS
    for _, icon in ipairs(frame.icons) do
        icon:SetScript("OnUpdate", nil)
        icon:Hide()
    end

    local shown = 0
    local index = 1
    repeat
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, "HARMFUL")
        if not aura then break end
        if ((not onlyPlayerDebuffs) or (aura.sourceUnit == "player")) and aura.expirationTime > 0 then
            shown = shown + 1
            if shown > MNNP["MAXDEBUFFS"] then break end
            local icon = frame.icons[shown]
            if not icon then
                icon = CreateFrame("Frame", nil, frame)
                icon:SetSize(16, 16)
                icon:SetPoint("CENTER")
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetAllPoints(true)
                icon.texture:SetTexture(136243)
                icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
                icon.cooldown:SetAllPoints(true)
                icon.cooldown:SetDrawEdge(false)
                icon.cooldown:SetReverse(true)
                icon.cooldown:SetHideCountdownNumbers(true)
                icon.text = icon:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
                icon.text:SetPoint("CENTER", icon, "CENTER", 0, 0)
                icon.text:SetTextColor(1, 1, 1)
                MidnightNameplates:SetFontSize(icon.text, 7, "OUTLINE")
                icon.amount = icon:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
                icon.amount:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
                icon.amount:SetTextColor(1, 1, 1)
                MidnightNameplates:SetFontSize(icon.amount, 5, "OUTLINE")
                icon:ClearAllPoints()
                if shown == 1 then
                    icon:SetPoint("LEFT", frame, "LEFT", 0, 0)
                else
                    icon:SetPoint("LEFT", frame.icons[shown - 1], "RIGHT", 2, 0)
                end

                frame.icons[shown] = icon
            end

            icon.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
            icon.texture:SetTexture(aura.icon)
            if aura.applications > 0 then
                icon.amount:SetText(aura.applications)
            else
                icon.amount:SetText("")
            end

            icon.expirationTime = aura.expirationTime
            icon:Show()
            icon:SetScript(
                "OnUpdate",
                function(sel, time)
                    MidnightNameplates:IconOnUpdate(sel, time)
                end
            )
        end

        index = index + 1
    until not aura
end

function MidnightNameplates:UpdateHealth(plate, unit)
    if UnitSelectionColor then
        local r, g, b = UnitSelectionColor(unit)
        plate.MINA_HP:SetStatusBarColor(r, g, b, 1)
    end

    local hp, max = UnitHealth(unit), UnitHealthMax(unit)
    if max == nil or max <= 0 then
        plate.MINA_TARGET:Hide()
        plate.MINA_HP.MINA_HP_BR:Hide()
        plate.MINA_HP:Hide()
        plate.MINA_HPTEXT.TEXT_CUR:SetText("")
        plate.MINA_HPTEXT.TEXT_PER:SetText("")

        return
    end

    plate.MINA_HP:SetMinMaxValues(0, max)
    plate.MINA_HP:SetValue(hp)
    if false then
        plate.MINA_HPTEXT.TEXT_CUR:SetText(string.format("%d", hp))
    end

    plate.MINA_HPTEXT.TEXT_PER:SetText(string.format("%0.0f%%", hp / max * 100))
    plate.MINA_TARGET:Show()
    plate.MINA_HP.MINA_HP_BR:Show()
    plate.MINA_HP:Show()
end

function MidnightNameplates:ShowPowerBar(plate)
    if plate == nil then return end
    if plate.MINA == nil then return end
    if plate.MINA_CB and plate.MINA_CB.unit then
        MidnightNameplates:UpdatePower(plate, plate.MINA_CB.unit)
    end
end

function MidnightNameplates:HidePowerBar(plate)
    if plate == nil then return end
    if plate.MINA == nil then return end
    plate.MINA_PO:Hide()
    plate.MINA_PO.MINA_POTEXT.TEXT_CUR:SetText("")
    plate.MINA_PO.MINA_POTEXT.TEXT_PER:SetText("")
end

function MidnightNameplates:UpdatePower(plate, unit)
    if not MNNP["POWERBAR"] then
        MidnightNameplates:HidePowerBar(plate)

        return
    end

    local _, powerToken = UnitPowerType(unit)
    if powerToken then
        local color = PowerBarColor[powerToken]
        if color then
            plate.MINA_PO:SetStatusBarColor(color.r, color.g, color.b, 1)
        end
    end

    local po, max = UnitPower(unit), UnitPowerMax(unit)
    if max == nil or max <= 0 then
        MidnightNameplates:HidePowerBar(plate)

        return
    end

    plate.MINA_PO:SetMinMaxValues(0, max)
    plate.MINA_PO:SetValue(po)
    plate.MINA_PO.MINA_POTEXT.TEXT_CUR:SetText(string.format("%d", po))
    plate.MINA_PO.MINA_POTEXT.TEXT_PER:SetText(string.format("%0.0f%%", po / max * 100))
    plate.MINA_PO:Show()
end

function MidnightNameplates:ShowCastBar(plate)
    if plate == nil then return end
    if plate.MINA == nil then return end
    if plate.MINA_CB and plate.MINA_CB.unit then
        local spell, _, _, startTime, endTime = UnitCastingInfo(plate.MINA_CB.unit)
        if spell then
            plate.MINA_CB:Show()
            plate.MINA_CB.MINA_CBTEXT.TEXT_NAME:SetText(spell)
            plate.MINA_CB:SetMinMaxValues(startTime, endTime)
            plate.MINA_CB:SetValue(GetTime() * 1000)
        end
    end
end

function MidnightNameplates:HideCastBar(plate)
    if plate == nil then return end
    if plate.MINA == nil then return end
    if plate.MINA_CB then
        plate.MINA_CB.MINA_CBTEXT.TEXT_CUR:SetText("")
        plate.MINA_CB:Hide()
    end
end

function MidnightNameplates:AddUF(np)
    if not np.MINA then
        MidnightNameplates:AddFrameBar(np, "MINA", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 1)
        tinsert(widthBars, np.MINA)
        tinsert(heightBars, np.MINA)
        -- HP
        if true then
            MidnightNameplates:AddStatusBar(np, "MINA_HP", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 2)
            tinsert(widthBars, np.MINA_HP)
            tinsert(heightBars, np.MINA_HP)
            np.MINA_HP:SetMinMaxValues(0, 100)
            np.MINA_HP:SetValue(50)
            if true then
                np.MINA_HP:SetStatusBarTexture("Interface\\AddOns\\MidnightNameplates\\media\\bar-fill")
                np.MINA_HP:SetStatusBarColor(1, 0, 0, 1)
                np.MINA_HP:GetStatusBarTexture():SetMask("Interface\\AddOns\\MidnightNameplates\\media\\bar-mask")
                np.MINA_HP:GetStatusBarTexture():SetHorizTile(false)
            else
                np.MINA_HP:SetColorFill(1, 0, 0, 1)
            end

            MidnightNameplates:AddTexture(np.MINA_HP, "HP_BG", "Interface\\AddOns\\MidnightNameplates\\media\\bar-bg", "BACKGROUND")
            if true then
                MidnightNameplates:AddFrameBar(np.MINA_HP, "MINA_HP_BR", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 10)
                tinsert(widthBars, np.MINA_HP.MINA_HP_BR)
                tinsert(heightBars, np.MINA_HP.MINA_HP_BR)
                MidnightNameplates:AddTexture(np.MINA_HP.MINA_HP_BR, "Texture", "Interface\\AddOns\\MidnightNameplates\\media\\bar-border", "OVERLAY")
                np.MINA_HP.MINA_HP_BR.Texture:SetVertexColor(0.5, 0.5, 0.5)
            end

            if true then
                MidnightNameplates:AddFrameBar(np, "MINA_TARGET", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 20)
                tinsert(widthBars, np.MINA_TARGET)
                tinsert(heightBars, np.MINA_TARGET)
                MidnightNameplates:AddTexture(np.MINA_TARGET, "Texture", "Interface\\AddOns\\MidnightNameplates\\media\\bar-target", "OVERLAY")
                np.MINA_TARGET.Texture:Hide()
            end

            if true then
                MidnightNameplates:AddFrameBar(np, "MINA_HPTEXT", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 30)
                tinsert(widthBars, np.MINA_HPTEXT)
                tinsert(heightBars, np.MINA_HPTEXT)
                MidnightNameplates:AddFontString(np.MINA_HPTEXT, "TEXT_CUR", MNNP["BARWIDTH"], 9, 1, 1, 1, 9, "OVERLAY", "GameFontNormalSmall")
                tinsert(widthBars, np.MINA_HPTEXT.TEXT_CUR)
                np.MINA_HPTEXT.TEXT_CUR:SetJustifyH("RIGHT")
                MidnightNameplates:AddFontString(np.MINA_HPTEXT, "TEXT_PER", MNNP["BARWIDTH"], 9, 1, 1, 1, 9, "OVERLAY", "GameFontNormalSmall")
                tinsert(widthBars, np.MINA_HPTEXT.TEXT_PER)
                np.MINA_HPTEXT.TEXT_PER:SetJustifyH("RIGHT")
                if true then
                    np.MINA_HPTEXT.TEXT_PER:SetPoint("BOTTOMRIGHT", np.MINA_HPTEXT, "TOPRIGHT", 0, -1)
                else
                    np.MINA_HPTEXT.TEXT_PER:SetPoint("RIGHT", np.MINA_HPTEXT, "RIGHT", 0, 0)
                end
            end

            if true then
                MidnightNameplates:AddTexture(np.MINA_HP, "TYP", nil, "ARTWORK")
                np.MINA_HP.TYP:SetAtlas("nameplates-icon-elite-gold")
                np.MINA_HP.TYP:SetSize(16, 16)
                np.MINA_HP.TYP:ClearAllPoints()
                np.MINA_HP.TYP:SetPoint("RIGHT", np.MINA_HP, "LEFT", -2, 0)
            end
        end

        -- POWER
        if true then
            MidnightNameplates:AddStatusBar(np, "MINA_PO", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 2)
            tinsert(widthBars, np.MINA_PO)
            tinsert(heightBars, np.MINA_PO)
            np.MINA_PO:SetMinMaxValues(0, 100)
            np.MINA_PO:SetValue(50)
            np.MINA_PO:ClearAllPoints()
            np.MINA_PO:SetPoint("TOP", np.MINA_HP, "BOTTOM", 0, 0)
            if true then
                np.MINA_PO:SetStatusBarTexture("Interface\\AddOns\\MidnightNameplates\\media\\bar-fill")
                np.MINA_PO:SetStatusBarColor(1, 0, 0, 1)
                np.MINA_PO:GetStatusBarTexture():SetMask("Interface\\AddOns\\MidnightNameplates\\media\\bar-mask")
                np.MINA_PO:GetStatusBarTexture():SetHorizTile(false)
            else
                np.MINA_PO:SetColorFill(1, 0, 0, 1)
            end

            MidnightNameplates:AddTexture(np.MINA_PO, "MINA_PO_BG", "Interface\\AddOns\\MidnightNameplates\\media\\bar-bg", "BACKGROUND")
            if true then
                MidnightNameplates:AddFrameBar(np.MINA_PO, "MINA_PO_BR", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 10)
                tinsert(widthBars, np.MINA_PO.MINA_PO_BR)
                tinsert(heightBars, np.MINA_PO.MINA_PO_BR)
                MidnightNameplates:AddTexture(np.MINA_PO.MINA_PO_BR, "Texture", "Interface\\AddOns\\MidnightNameplates\\media\\bar-border", "OVERLAY")
                np.MINA_PO.MINA_PO_BR.Texture:SetVertexColor(0.5, 0.5, 0.5)
            end

            if true then
                MidnightNameplates:AddFrameBar(np.MINA_PO, "MINA_POTEXT", MNNP["BARWIDTH"], 9, 30)
                tinsert(widthBars, np.MINA_PO.MINA_POTEXT)
                MidnightNameplates:AddFontString(np.MINA_PO.MINA_POTEXT, "TEXT_CUR", MNNP["BARWIDTH"], 9, 1, 1, 1, 7, "OVERLAY", "GameFontNormalSmall")
                tinsert(widthBars, np.MINA_PO.TEXT_CUR)
                np.MINA_PO.MINA_POTEXT.TEXT_CUR:SetJustifyH("LEFT")
                np.MINA_PO.MINA_POTEXT.TEXT_CUR:SetPoint("LEFT", np.MINA_POTEXT, "LEFT", 4, 0)
                MidnightNameplates:AddFontString(np.MINA_PO.MINA_POTEXT, "TEXT_PER", MNNP["BARWIDTH"], 9, 1, 1, 1, 7, "OVERLAY", "GameFontNormalSmall")
                tinsert(widthBars, np.MINA_PO.TEXT_PER)
                np.MINA_PO.MINA_POTEXT.TEXT_PER:SetJustifyH("RIGHT")
                np.MINA_PO.MINA_POTEXT.TEXT_PER:SetPoint("RIGHT", np.MINA_PO.MINA_POTEXT, "RIGHT", -4, 0)
            end
        end

        -- CASTBAR
        if true then
            MidnightNameplates:AddStatusBar(np, "MINA_CB", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 2)
            tinsert(widthBars, np.MINA_CB)
            tinsert(heightBars, np.MINA_CB)
            np.MINA_CB:SetMinMaxValues(0, 100)
            np.MINA_CB:SetValue(0)
            np.MINA_CB:ClearAllPoints()
            np.MINA_CB:SetPoint("TOP", np.MINA_PO, "BOTTOM", 0, 0)
            np.MINA_CB:SetScript(
                "OnUpdate",
                function(sel, elapsed)
                    if not MNNP["CASTBAR"] then
                        MidnightNameplates:HideCastBar(np)

                        return
                    end

                    if sel.unit == nil then return end
                    local name = UnitChannelInfo(sel.unit)
                    if name then
                        local _, _, icon, _, endTime, _, _, notInterruptible = UnitChannelInfo(sel.unit)
                        if endTime then
                            if notInterruptible then
                                sel.Shield:Show()
                            else
                                sel.Shield:Hide()
                            end

                            local currentTime = GetTime() * 1000
                            sel:SetValue(currentTime)
                            sel.MINA_CBTEXT.TEXT_CUR:SetText(string.format("%0.1f", (endTime - currentTime) / 1000) .. "s")
                            sel.Icon:SetTexture(icon)
                        else
                            MidnightNameplates:HideCastBar(np)
                        end
                    else
                        local _, _, icon, _, endTime, _, _, notInterruptible = UnitCastingInfo(sel.unit)
                        if endTime then
                            if notInterruptible then
                                sel.Shield:Show()
                            else
                                sel.Shield:Hide()
                            end

                            local currentTime = GetTime() * 1000
                            sel:SetValue(currentTime)
                            sel.MINA_CBTEXT.TEXT_CUR:SetText(string.format("%0.1f", (endTime - currentTime) / 1000) .. "s")
                            sel.Icon:SetTexture(icon)
                        else
                            MidnightNameplates:HideCastBar(np)
                        end
                    end
                end
            )

            if true then
                np.MINA_CB:SetStatusBarTexture("Interface\\AddOns\\MidnightNameplates\\media\\bar-fill")
                np.MINA_CB:SetStatusBarColor(1, 1, 0, 1)
                np.MINA_CB:GetStatusBarTexture():SetMask("Interface\\AddOns\\MidnightNameplates\\media\\bar-mask")
                np.MINA_CB:GetStatusBarTexture():SetHorizTile(false)
            else
                np.MINA_CB:SetColorFill(1, 0, 0, 1)
            end

            MidnightNameplates:AddTexture(np.MINA_CB, "MINA_CB_BG", "Interface\\AddOns\\MidnightNameplates\\media\\bar-bg", "BACKGROUND")
            if true then
                MidnightNameplates:AddFrameBar(np.MINA_CB, "MINA_CB_BR", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 10)
                tinsert(widthBars, np.MINA_CB.MINA_CB_BR)
                tinsert(heightBars, np.MINA_CB.MINA_CB_BR)
                MidnightNameplates:AddTexture(np.MINA_CB.MINA_CB_BR, "Texture", "Interface\\AddOns\\MidnightNameplates\\media\\bar-border", "OVERLAY")
                np.MINA_CB.MINA_CB_BR.Texture:SetVertexColor(0.5, 0.5, 0.5)
            end

            if true then
                MidnightNameplates:AddFrameBar(np.MINA_CB, "MINA_CBTEXT", MNNP["BARWIDTH"], 9, 30)
                tinsert(widthBars, np.MINA_CB.MINA_CBTEXT)
                MidnightNameplates:AddFontString(np.MINA_CB.MINA_CBTEXT, "TEXT_CUR", MNNP["BARWIDTH"], 9, 1, 1, 1, 7, "OVERLAY", "GameFontNormalSmall")
                tinsert(widthBars, np.MINA_CB.TEXT_CUR)
                np.MINA_CB.MINA_CBTEXT.TEXT_CUR:SetJustifyH("RIGHT")
                np.MINA_CB.MINA_CBTEXT.TEXT_CUR:SetPoint("RIGHT", np.MINA_CB.MINA_CBTEXT, "RIGHT", -4, 0)
                MidnightNameplates:AddFontString(np.MINA_CB.MINA_CBTEXT, "TEXT_NAME", MNNP["BARWIDTH"], 9, 1, 1, 1, 7, "OVERLAY", "GameFontNormalSmall")
                tinsert(widthBars, np.MINA_CB.MINA_CBTEXT.TEXT_NAME)
                np.MINA_CB.MINA_CBTEXT.TEXT_NAME:SetJustifyH("CENTER")
                np.MINA_CB.MINA_CBTEXT.TEXT_NAME:SetPoint("CENTER", np.MINA_CB.MINA_CBTEXT, "CENTER", 0, 0)
            end

            if true then
                MidnightNameplates:AddTexture(np.MINA_CB, "Shield", nil, "ARTWORK", 1)
                np.MINA_CB.Shield:SetAtlas("ui-castingbar-shield")
                np.MINA_CB.Shield:SetSize(16, 16)
                np.MINA_CB.Shield:ClearAllPoints()
                np.MINA_CB.Shield:SetPoint("RIGHT", np.MINA_CB, "LEFT", -2, -2)
            end

            if true then
                MidnightNameplates:AddTexture(np.MINA_CB, "Icon", nil, "ARTWORK", 2)
                np.MINA_CB.Icon:SetSize(10, 10)
                np.MINA_CB.Icon:ClearAllPoints()
                np.MINA_CB.Icon:SetPoint("CENTER", np.MINA_CB.Shield, "CENTER", 0, 1)
            end

            np.MINA_CB:Hide()
        end

        -- NAME
        if NAME then
            MidnightNameplates:AddFrameBar(np, "MINA_NAME", MNNP["BARWIDTH"], MNNP["BARHEIGHT"], 30)
            tinsert(widthBars, np.MINA_NAME)
            tinsert(heightBars, np.MINA_NAME)
            MidnightNameplates:AddFontString(np.MINA_NAME, "TEXT", MNNP["BARWIDTH"], 9, 1, 1, 1, 9, "OVERLAY", "GameFontNormalSmall")
            tinsert(widthBars, np.MINA_NAME.TEXT)
            np.MINA_NAME.TEXT:SetJustifyH("LEFT")
            np.MINA_NAME.TEXT:ClearAllPoints()
            if true then
                np.MINA_NAME.TEXT:SetPoint("BOTTOMLEFT", np.MINA_NAME, "TOPLEFT", 0, -1)
            else
                np.MINA_NAME.TEXT:SetPoint("LEFT", np.MINA_NAME, "LEFT", 0, 0)
            end
        end

        -- DEBUFFS
        if DEBUFFS then
            MidnightNameplates:AddFrameBar(np, "MINA_DEBUFFS", MNNP["BARWIDTH"], 16, 30)
            tinsert(widthBars, np.MINA_DEBUFFS)
            if true then
                np.MINA_DEBUFFS:SetPoint("BOTTOMLEFT", np.MINA_NAME, "TOPLEFT", 0, 8)
            else
                np.MINA_DEBUFFS:SetPoint("BOTTOMLEFT", np.MINA_HP, "TOPLEFT", 0, 0)
            end

            np.MINA_DEBUFFS:SetSize(MNNP["BARWIDTH"], 16)
            np.MINA_DEBUFFS.icons = {}
            if DEBUFF_BACKGROUND then
                MidnightNameplates:AddTexture(np.MINA_DEBUFFS, "MINA_DEBUFFS_BG", nil, "BACKGROUND")
                np.MINA_DEBUFFS.MINA_DEBUFFS_BG:SetColorTexture(0.1, 0.1, 0.1, 0.5)
            end
        end
    end
end

local npnpc = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npnpc, "NAME_PLATE_CREATED")
MidnightNameplates:OnEvent(
    npnpc,
    function(sel, event, plate, ...)
        if plate == nil then return end
        MidnightNameplates:AddUF(plate)
    end, "npnpc"
)

local npua = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npua, "UNIT_AURA")
MidnightNameplates:OnEvent(
    npua,
    function(sel, event, unit, ...)
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate == nil then return end
        if plate.MINA == nil then return end
        MidnightNameplates:UpdateDebuffs(plate, unit)
    end, "npua"
)

local npuh = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npuh, "UNIT_HEALTH")
MidnightNameplates:OnEvent(
    npuh,
    function(sel, event, unit, ...)
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate == nil then return end
        if plate.MINA == nil then return end
        MidnightNameplates:UpdateHealth(plate, unit)
    end, "npuh"
)

local npup = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npup, "UNIT_MANA")
MidnightNameplates:RegisterEvent(npup, "UNIT_POWER")
MidnightNameplates:RegisterEvent(npup, "UNIT_POWER_UPDATE")
MidnightNameplates:OnEvent(
    npup,
    function(sel, event, unit, ...)
        if not MNNP["POWERBAR"] then return end
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate == nil then return end
        if plate.MINA == nil then return end
        MidnightNameplates:UpdatePower(plate, unit)
    end, "npup"
)

local npnpua = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npnpua, "NAME_PLATE_UNIT_ADDED")
MidnightNameplates:OnEvent(
    npnpua,
    function(sel, event, unit, ...)
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate == nil then return end
        if plate.MINA == nil then return end
        plate.UnitFrame:Hide()
        plate.MINA:Show()
        MidnightNameplates:UpdateHealth(plate, unit)
        MidnightNameplates:UpdatePower(plate, unit)
        MidnightNameplates:UpdateDebuffs(plate, unit)
        MidnightNameplates:UpdateTarget(plate, unit)
        plate.MINA_CB.unit = unit
        if plate.MINA_HP then
            local classification = UnitClassification(unit)
            if classification == "elite" then
                plate.MINA_HP.TYP:SetAtlas("nameplates-icon-elite-gold")
                plate.MINA_HP.TYP:Show()
            elseif classification == "rare" or classification == "rareelite" then
                plate.MINA_HP.TYP:SetAtlas("nameplates-icon-elite-silver")
                plate.MINA_HP.TYP:Show()
            else
                plate.MINA_HP.TYP:Hide()
            end
        end

        MidnightNameplates:SetName(plate, unit)
    end, "npnpua"
)

local npunu = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npunu, "UNIT_NAME_UPDATE")
MidnightNameplates:OnEvent(
    npunu,
    function(sel, event, unit, ...)
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate == nil then return end
        if plate.MINA == nil then return end
        MidnightNameplates:SetName(plate, unit)
    end, "npunu"
)

local npnpur = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npnpur, "NAME_PLATE_UNIT_REMOVED")
MidnightNameplates:OnEvent(
    npnpur,
    function(sel, event, unit, ...)
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate == nil then return end
        if plate.MINA == nil then return end
        plate.MINA:Hide()
    end, "npnpur"
)

local npptc = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npptc, "PLAYER_TARGET_CHANGED")
MidnightNameplates:OnEvent(
    npptc,
    function(sel, event, ...)
        local plate = C_NamePlate.GetNamePlateForUnit("target")
        MidnightNameplates:UpdateTarget(plate, "target")
    end, "npptc"
)

local npsc = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npsc, "UNIT_SPELLCAST_STOP")
MidnightNameplates:RegisterEvent(npsc, "UNIT_SPELLCAST_INTERRUPTED")
MidnightNameplates:RegisterEvent(npsc, "UNIT_SPELLCAST_CHANNEL_STOP")
MidnightNameplates:OnEvent(
    npsc,
    function(sel, event, unit, ...)
        if not MNNP["CASTBAR"] then return end
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate == nil then return end
        if plate.MINA == nil then return end
        plate.MINA_CB:Hide()
    end, "npsc"
)

local npscs = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npscs, "UNIT_SPELLCAST_START")
MidnightNameplates:OnEvent(
    npscs,
    function(sel, event, unit, ...)
        if not MNNP["CASTBAR"] then return end
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        MidnightNameplates:ShowCastBar(plate)
    end, "npscs"
)

local npsccs = CreateFrame("Frame")
MidnightNameplates:RegisterEvent(npsccs, "UNIT_SPELLCAST_CHANNEL_START")
MidnightNameplates:RegisterEvent(npsccs, "UNIT_SPELLCAST_CHANNEL_UPDATE")
MidnightNameplates:OnEvent(
    npsccs,
    function(sel, event, unit, ...)
        if not MNNP["CASTBAR"] then return end
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate == nil then return end
        if plate.MINA == nil then return end
        local spell, _, _, startTime, endTime = UnitChannelInfo(unit)
        if spell then
            plate.MINA_CB:Show()
            plate.MINA_CB.MINA_CBTEXT.TEXT_NAME:SetText(spell)
            plate.MINA_CB:SetMinMaxValues(startTime, endTime)
            plate.MINA_CB:SetValue(GetTime() * 1000)
        end
    end, "npsccs"
)
