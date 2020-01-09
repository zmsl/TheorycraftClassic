local _TOOLTIPTAB = 1
local _BUTTONTEXTTAB = 2
local _ADVANCEDTAB = 3
--local _MITIGATIONTAB = 4
local _, class = UnitClass("player")
TheoryCraft_NotStripped = true
local function findpattern(text, pattern, start)
	if (text and pattern and (string.find(text, pattern, start))) then
		return string.sub(text, string.find(text, pattern, start))
	else
		return ""
	end
end

TheoryCraft_SetUpButton = function (parentname, type, specialid)
	oldbutton = getglobal(parentname)
	if not oldbutton then return end
	newbutton = getglobal(parentname.."_TCText")
	if newbutton then return end
	oldbutton:CreateFontString(parentname.."_TCText", "ARTWORK");
	oldbutton.oldupdatescript = oldbutton:GetScript("OnUpdate")
	oldbutton:SetScript("OnUpdate", TheoryCraft_ButtonUpdate)
	newbutton = getglobal(parentname.."_TCText")
	newbutton:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	newbutton:SetPoint("TOPLEFT", oldbutton, "TOPLEFT", 0, 0)
	newbutton:SetPoint("BOTTOMRIGHT", oldbutton, "BOTTOMRIGHT", 0, 0)
	newbutton.type = type
	newbutton.specialid = specialid
	newbutton:Show()
end

local function round(arg1, decplaces)
	if (decplaces == nil) then decplaces = 0 end
	if arg1 == nil then arg1 = 0 end
	return string.format ("%."..decplaces.."f", arg1)
end

local function AddMods(mult, mod, all, healing, damage, school, prefix, suffix, pre2)
	local tmp = TheoryCraft_GetStat("All"..mod)*mult
	if tmp ~= 0 then
		if all ~= "DONT" then
			TheoryCraftAddMod(all, prefix..tmp..suffix)
		end
	end
	tmp = TheoryCraft_GetStat("Healing"..mod)*mult
	if tmp ~= 0 then
		TheoryCraftAddMod(healing, prefix..tmp..suffix)
	end
	tmp = TheoryCraft_GetStat("Damage"..mod)*mult
	if tmp ~= 0 then
		TheoryCraftAddMod(damage, prefix..tmp..suffix)
	end
	if pre2 == nil then pre2 = "" end
	for k,v in pairs(TheoryCraft_PrimarySchools) do
		tmp = TheoryCraft_GetStat(v.name..mod)*mult
		if tmp ~= 0 then
			TheoryCraftAddMod(pre2..v.name..school, prefix..tmp..suffix)
		end
	end
end

function TheoryCraft_Combo1Click()
	local optionID = self:GetID()
	UIDropDownMenu_SetSelectedID(TheoryCrafttryfirst, optionID)
	TheoryCraft_Settings["tryfirst"] = self.value
	TheoryCraft_DeleteTable(TheoryCraft_UpdatedButtons)
end

function TheoryCraft_Combo2Click()
	local optionID = self:GetID()
	UIDropDownMenu_SetSelectedID(TheoryCrafttrysecond, optionID)
	TheoryCraft_Settings["trysecond"] = self.value
	TheoryCraft_DeleteTable(TheoryCraft_UpdatedButtons)
end

function TheoryCraft_Combo3Click()
	local optionID = self:GetID()
	UIDropDownMenu_SetSelectedID(TheoryCrafttryfirstsfg, optionID)
	TheoryCraft_Settings["tryfirstsfg"] = self.value
	TheoryCraft_DeleteTable(TheoryCraft_UpdatedButtons)
end

function TheoryCraft_Combo4Click()
	local optionID = self:GetID()
	UIDropDownMenu_SetSelectedID(TheoryCrafttrysecondsfg, optionID)
	TheoryCraft_Settings["trysecondsfg"] = self.value
	TheoryCraft_DeleteTable(TheoryCraft_UpdatedButtons)
end
local info = {}

local function formattext(a, field, places)
	if places == nil then
		places = 0
	end
	if (field == "averagedam") or (field == "averageheal") then
		if TheoryCraft_Settings["dontcrit"] then
			field = field.."nocrit"
		end
	end
	if a[field] == nil then
		return nil
	end
	if (field == "maxoomdam") or (field == "maxoomdamremaining") or (field == "maxoomdamfloored") or
	   (field == "maxoomheal") or (field == "maxoomhealremaining") or (field == "maxoomhealfloored") then
		return round(a[field]/1000*10^places)/10^places.."k"
	end
	return round(a[field]*10^places)/10^places
end

function TheoryCraft_AddButtonText()

	local newbutton, oldbutton
	local setupbutton = TheoryCraft_SetUpButton
	function TheoryCraft_Nurfed_ActionButton_OnUpdate(elapsed)
		TheoryCraft_Data["oldNurfed"](elapsed)
		setupbutton(this:GetName(), "Normal")
	end
	if SpellButton1 then
		for i = 1,12 do setupbutton("SpellButton"..i, "SpellBook") end
	end
	if M1BarButton1 then
		for i = 1,18 do setupbutton("M1BarButton"..i, "Normal") end
		for i = 1,18 do setupbutton("M2BarButton"..i, "Normal") end
		for i = 1,18 do setupbutton("M3BarButton"..i, "Normal") end
	end
	if DAB_ActionButton_1 then
		for i = 1,120 do setupbutton("DAB_ActionButton_"..i, "Discord") end
	end
	if FlexBarButton1 then
		for i = 1,120 do setupbutton("FlexBarButton"..i, "Normal") end
	end
	if Nurfed_ActionButton1 then
		for i = 1,120 do setupbutton("Nurfed_ActionButton"..i, "Normal") end
	end
	if CT_ActionButton1 then
		for i = 1,12 do setupbutton("CT_ActionButton"..i, "Special", 12+i) end
		for i = 1,12 do setupbutton("CT2_ActionButton"..i, "Special", 24+i) end
		for i = 1,12 do setupbutton("CT3_ActionButton"..i, "Special", 36+i) end
		for i = 1,12 do setupbutton("CT4_ActionButton"..i, "Special", 48+i) end
	end
	if Gypsy_ActionButton1 then
		for i = 1,12 do setupbutton("Gypsy_ActionButton"..i, "Gypsy") end
	end
	if GB_MiniSpellbook_Spell_1 then
		for i = 1,40 do setupbutton("GB_MiniSpellbook_Spell_"..i, "GBMiniSpellBook") end
	end
	if GB_PlayerBar_Button_1 then
		for i = 1,20 do setupbutton("GB_PlayerBar_Button_"..i, "GBButton") end
		for i = 1,20 do setupbutton("GB_PartyBar1_Button_"..i, "GBButton") end
		for i = 1,20 do setupbutton("GB_PartyBar2_Button_"..i, "GBButton") end
		for i = 1,20 do setupbutton("GB_PartyBar3_Button_"..i, "GBButton") end
		for i = 1,20 do setupbutton("GB_PartyBar4_Button_"..i, "GBButton") end
		for i = 1,20 do setupbutton("GB_FriendlyTargetBar_Button_"..i, "GBButton") end
		for i = 1,20 do setupbutton("GB_HostileTargetBar_Button_"..i, "GBButton") end
		for i = 1,20 do setupbutton("GB_LowestHealthBar_Button_"..i, "GBButton") end
		for i = 1,6 do setupbutton("GB_RaidBar_Button_"..i, "GBButton") end
	end
	if ActionButton1 then
		for i = 1,12 do setupbutton("ActionButton"..i, "Flippable") end
		for i = 1,12 do setupbutton("MultiBarRightButton"..i, "Special", 24+i) end
		for i = 1,12 do setupbutton("MultiBarLeftButton"..i, "Special", 36+i) end
		for i = 1,12 do setupbutton("MultiBarBottomRightButton"..i, "Special", 48+i) end
		for i = 1,12 do setupbutton("MultiBarBottomLeftButton"..i, "Special", 60+i) end
		for i = 1,12 do setupbutton("BonusActionButton"..i, "Bonus") end
	end
end


function TheoryCraft_ButtonUpdate(this, ...)
	if this.oldupdatescript then
		this.oldupdatescript(this, ...)
	end
	if (TheoryCraft_Settings["framebyframe"] or UnitAffectingCombat("player")) and TheoryCraft_UpdatedThisRound then
		return
	end
	local i = this:GetName().."_TCText"
	local buttontext = getglobal(i)

	if (buttontext.fontsize ~= TheoryCraft_Settings["FontSize"]) or
	   (buttontext.fontpath ~= TheoryCraft_Settings["FontPath"]) then
		buttontext.fontsize = TheoryCraft_Settings["FontSize"]
		buttontext.fontpath = TheoryCraft_Settings["FontPath"]
		buttontext:SetFont(TheoryCraft_Settings["FontPath"], buttontext.fontsize, "OUTLINE")
	end
	if (buttontext.colr ~= TheoryCraft_Settings["ColR"]) or
	   (buttontext.colg ~= TheoryCraft_Settings["ColG"]) or
	   (buttontext.colb ~= TheoryCraft_Settings["ColB"]) or
	   (buttontext.colr2 ~= TheoryCraft_Settings["ColR2"]) or
	   (buttontext.colg2 ~= TheoryCraft_Settings["ColG2"]) or
	   (buttontext.colb2 ~= TheoryCraft_Settings["ColB2"]) then
		buttontext.colr = TheoryCraft_Settings["ColR"]
		buttontext.colg = TheoryCraft_Settings["ColG"]
		buttontext.colb = TheoryCraft_Settings["ColB"]
		buttontext.colr2 = TheoryCraft_Settings["ColR2"]
		buttontext.colg2 = TheoryCraft_Settings["ColG2"]
		buttontext.colb2 = TheoryCraft_Settings["ColB2"]
		TheoryCraft_UpdatedButtons[i] = nil
	end
	if (buttontext.buttontextx ~= TheoryCraft_Settings["buttontextx"]) or (buttontext.buttontexty ~= TheoryCraft_Settings["buttontexty"]) then
		buttontext.buttontextx = TheoryCraft_Settings["buttontextx"]
		buttontext.buttontexty = TheoryCraft_Settings["buttontextx"]
		buttontext:ClearAllPoints()
		buttontext:SetPoint("TOPLEFT", this, "TOPLEFT", -TheoryCraft_Settings["buttontextx"], -TheoryCraft_Settings["buttontexty"])
		buttontext:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", -TheoryCraft_Settings["buttontextx"], -TheoryCraft_Settings["buttontexty"])
	end
	if (buttontext.align == nil) or
	   ((buttontext.align == 1) and (not TheoryCraft_Settings["alignleft"])) or
	   ((buttontext.align == 2) and (not TheoryCraft_Settings["alignright"])) or
	   ((buttontext.align == 3) and (TheoryCraft_Settings["alignleft"] or TheoryCraft_Settings["alignright"])) then
		buttontext:SetJustifyV("MIDDLE")
		if TheoryCraft_Settings["alignleft"] then
			buttontext.align = 1
			buttontext:SetJustifyH("LEFT")
		elseif TheoryCraft_Settings["alignright"] then
			buttontext.align = 2
			buttontext:SetJustifyH("RIGHT")
		else
			buttontext.align = 3
			buttontext:SetJustifyH("CENTER")
		end
	end

	if buttontext.type == "Discord" then
		local actionid = this:GetActionID()
		if buttontext.actionbutton ~= actionid then
			TheoryCraft_UpdatedButtons[i] = nil
			buttontext.actionbutton = actionid
		end
	end
	if TheoryCraft_UpdatedButtons[i] then
		if TheoryCraft_Data["reporttimes"] then
			if TheoryCraft_Settings["framebyframe"] then
				Print("As TC is set to frame by frame mode, only one tooltip needs to be regenerated per frame.")
				local timetaken = round(TheoryCraft_Data["timetaken"]*1000)
				Print("This takes approximately: "..timetaken.." milliseconds. One button will be generated per frame at this speed until all have been regenerated.  It will not cause noticeable lag.")
			else
				Print("TheoryCraft has to generate: "..TheoryCraft_Data["buttonsgenerated"].." tooltips whenever you or your target change in a way that'll modify at least one tooltip.")
				local timetaken = round(TheoryCraft_Data["timetaken"]*1000)
				Print("This takes approximately: "..timetaken.." milliseconds. Keep in mind that WoW's timer is only accurate to 1ms, making this not entirely reliable.")
				if tonumber(timetaken) < 50 then
					Print("This will *not* result in noticeable frame skip, so it would be best to leave frame by frame disabled.")
				else
					Print("This will result in noticeable frame skip, and so you may want to consider setting TC to frame by frame mode. This mode is enabled by default whilst in combat. Alternatively you could reduce the number of buttons showing button text.")
				end
			end
			TheoryCraft_Data["reporttimes"] = nil
		end
		return
	else
		TheoryCraft_UpdatedThisRound = true
--		Counter = (Counter or 0) + 1
--		Print(Counter)
		TheoryCraft_UpdatedButtons[i] = true
		if not TheoryCraft_Settings["buttontext"] then
			buttontext:Hide()
			return
		end

		local tryfirst, trysecond, spelldata
		if buttontext.type == "SpellBook" then
			local id = getglobal(this:GetName().."SpellName"):GetText()
			local id2 = getglobal(this:GetName().."SubSpellName"):GetText()
			if (not (getglobal(this:GetName().."SpellName"):IsShown())) or (id == nil) then
				buttontext:Hide()
				id = nil
			end
			if id then
				id2 = tonumber(findpattern(id2, "%d+"))
				if id2 == nil then id2 = 0 end
				spelldata = TheoryCraft_GetSpellDataByName(id, id2)
			end
		elseif buttontext.type == "GBMiniSpellBook" then
			local spellname, spellrank = GetSpellName(buttontext.ID, "BOOKTYPE_SPELL");
			if spellname then
				spellrank = tonumber(findpattern(spellrank, "%d+"))
				if spellrank == nil then spellrank = 0 end
				spelldata = TheoryCraft_GetSpellDataByName(spellname, spellrank)
			end
		elseif buttontext.type == "GBButton" then
			local name = GB_Settings[GB_INDEX][buttontext:GetParent():GetParent().index].Button[buttontext:GetParent():GetID()].name;
			local rank = GB_Settings[GB_INDEX][buttontext:GetParent():GetParent().index].Button[buttontext:GetParent():GetID()].rank;
			if name then
				rank = tonumber(findpattern(rank, "%d+"))
				if rank == nil then rank = 0 end
				spelldata = TheoryCraft_GetSpellDataByName(name, rank)
			end
		elseif buttontext.type == "Normal" then
			TCTooltip:SetOwner(UIParent,"ANCHOR_NONE")
			TCTooltip:SetAction(buttontext:GetParent():GetID())
			spelldata = TheoryCraft_GetSpellDataByFrame(TCTooltip)
		elseif buttontext.type == "Flippable" then
			TCTooltip:SetOwner(UIParent,"ANCHOR_NONE")
			TCTooltip:SetAction(buttontext:GetParent():GetID()+(CURRENT_ACTIONBAR_PAGE-1)*NUM_ACTIONBAR_BUTTONS)
			spelldata = TheoryCraft_GetSpellDataByFrame(TCTooltip)
		elseif buttontext.type == "Special" then
			TCTooltip:SetOwner(UIParent,"ANCHOR_NONE")
			TCTooltip:SetAction(buttontext.specialid)
			spelldata = TheoryCraft_GetSpellDataByFrame(TCTooltip)
		elseif buttontext.type == "Discord" then
			TCTooltip:SetOwner(UIParent,"ANCHOR_NONE")
			TCTooltip:SetAction(buttontext.actionbutton)
			spelldata = TheoryCraft_GetSpellDataByFrame(TCTooltip)
		elseif buttontext.type == "Gypsy" then
			TCTooltip:SetOwner(UIParent,"ANCHOR_NONE")
			TCTooltip:SetAction(Gypsy_ActionButton_GetPagedID (this))
			spelldata = TheoryCraft_GetSpellDataByFrame(TCTooltip)
		elseif buttontext.type == "Bonus" then
			TCTooltip:SetOwner(UIParent,"ANCHOR_NONE")
			if ( CURRENT_ACTIONBAR_PAGE==1 ) then
				TCTooltip:SetAction(this:GetID() + ((NUM_ACTIONBAR_PAGES+GetBonusBarOffset()-1)*NUM_ACTIONBAR_BUTTONS))
				spelldata = TheoryCraft_GetSpellDataByFrame(TCTooltip)
			else
				TCTooltip:SetAction(this:GetID() + ((CURRENT_ACTIONBAR_PAGE-1)*NUM_ACTIONBAR_BUTTONS))
				spelldata = TheoryCraft_GetSpellDataByFrame(TCTooltip)
			end
		end
		if spelldata then
			tryfirst = formattext(spelldata, TheoryCraft_Settings["tryfirst"], TheoryCraft_Settings["tryfirstsfg"])
			if tryfirst then
				buttontext:SetText(tryfirst)
				buttontext:SetTextColor(buttontext.colr, buttontext.colg, buttontext.colb)
				buttontext:Show()
				if getglobal(this:GetName().."Name") then getglobal(this:GetName().."Name"):Hide() end
				if getglobal(buttontext:GetParent():GetName().."_Rank") then getglobal(buttontext:GetParent():GetName().."_Rank"):Hide() end
			else
				trysecond = formattext(spelldata, TheoryCraft_Settings["trysecond"], TheoryCraft_Settings["trysecondsfg"])
				if trysecond then
					buttontext:SetText(trysecond)
					buttontext:SetTextColor(buttontext.colr2, buttontext.colg2, buttontext.colb2)
					if getglobal(this:GetName().."Name") then getglobal(this:GetName().."Name"):Hide() end
					if getglobal(buttontext:GetParent():GetName().."_Rank") then getglobal(buttontext:GetParent():GetName().."_Rank"):Hide() end
					buttontext:Show()
				else
					if getglobal(this:GetName().."Name") then getglobal(this:GetName().."Name"):Show() end
					if getglobal(buttontext:GetParent():GetName().."_Rank") then getglobal(buttontext:GetParent():GetName().."_Rank"):Show() end
					buttontext:Hide()
				end
			end
		else
			if getglobal(this:GetName().."Name") then getglobal(this:GetName().."Name"):Show() end
			buttontext:Hide()
		end
	end
end