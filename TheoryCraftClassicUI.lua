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

function TheoryCraft_SetTalent(name)
	--local name = self:GetName()
	local i = 1
	local i2 = tonumber(string.sub(name, 18, 18))
	local numberneeded = tonumber(string.sub(name, 19, 19))
	local number = 1
	local newrank = 0
	local _, currank, maxRank
	number = 1
	while (TheoryCraft_Talents[i]) do
		if (class == TheoryCraft_Talents[i].class) and (TheoryCraft_Talents[i].dontlist == nil) and (((TheoryCraft_Talents[i].tree == i2) and (TheoryCraft_Talents[i].forcetree == nil)) or (TheoryCraft_Talents[i].forcetree == i2)) then
			if (number == numberneeded) then
				nameneeded = TheoryCraft_Talents[i].name
				_, _, _, _, currank, maxRank= GetTalentInfo(TheoryCraft_Talents[i].tree, TheoryCraft_Talents[i].number)
				if (TheoryCraft_Talents[i].forceto == nil) or (TheoryCraft_Talents[i].forceto == -1) then
					newrank = currank + 1
				else
					newrank = TheoryCraft_Talents[i].forceto + 1
				end
				if newrank > maxRank then
					newrank = 0
				end
				break
			end
			number = number + 1
		end
		i = i+1
	end
	i = 1
	while (TheoryCraft_Talents[i]) do
		if (class == TheoryCraft_Talents[i].class) then
			if (TheoryCraft_Talents[i].name == nameneeded) then
				TheoryCraft_Talents[i].forceto = newrank
			end
		end
		i = i+1
	end
	TheoryCraft_UpdateTalents() -- manually adjusting talents in the vitals tab
end

function TheoryCraft_SetUpButton(parentname, type, specialid)
	oldbutton = getglobal(parentname)

	if not oldbutton then return nil end

	newbutton = getglobal(parentname.."_TCText")
	if newbutton and newbutton.type then 
		return newbutton
	end

	oldbutton:CreateFontString(parentname.."_TCText", "ARTWORK");
	newbutton = getglobal(parentname.."_TCText")
	newbutton:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	newbutton:SetPoint("TOPLEFT", oldbutton, "TOPLEFT", 0, 0)
	newbutton:SetPoint("BOTTOMRIGHT", oldbutton, "BOTTOMRIGHT", 0, 0)
	newbutton.type = type
	newbutton.specialid = specialid
	newbutton:SetText("0")
	newbutton:Show()

	return newbutton
end

local function round(arg1, decplaces)
	if (decplaces == nil) then decplaces = 0 end
	if arg1 == nil then arg1 = 0 end
	return string.format ("%."..decplaces.."f", arg1)
end

local function UpdateCustomOutfit()
	if TheoryCraft_Data.outfit == 2 then
		TheoryCraftCustomOutfit:Show()
	else
		TheoryCraftCustomOutfit:Hide()
		return
	end
	local i = 1
	local i2 = 1
	TheoryCraftCustomLeft:SetText()
	TheoryCraftCustomRight:SetText()
	TheoryCraftCustomLeft:SetHeight(1)
	TheoryCraftCustomRight:SetHeight(1)
	local text = 1
	while (TheoryCraft_SlotNames[i]) do
		if (TheoryCraftCustomLeft:GetText(text) == nil) or (string.find(TheoryCraftCustomLeft:GetText(text), TheoryCraft_SlotNames[i].slot) == nil) then
			if string.find(TheoryCraft_SlotNames[i].slot, "%d+") then
				text = string.sub(TheoryCraft_SlotNames[i].slot, 1, string.find(TheoryCraft_SlotNames[i].slot, "%d+")-1)
			else
				text = TheoryCraft_SlotNames[i].slot
			end
			if TheoryCraftCustomLeft:GetText() then
				TheoryCraftCustomLeft:SetText(TheoryCraftCustomLeft:GetText().."\n"..text)
			else
				TheoryCraftCustomLeft:SetText(text)
			end
			if TheoryCraft_Settings["CustomOutfit"].slots[TheoryCraft_SlotNames[i].slot] then
				text = TheoryCraft_Settings["CustomOutfit"].slots[TheoryCraft_SlotNames[i].slot]["name"]
			else
				text = " "
			end
			if TheoryCraftCustomRight:GetText() then
				TheoryCraftCustomRight:SetText(TheoryCraftCustomRight:GetText().."\n"..text)
			else
				TheoryCraftCustomRight:SetText(text)
			end
			TheoryCraftCustomLeft:SetHeight(11+TheoryCraftCustomLeft:GetHeight())
			TheoryCraftCustomRight:SetHeight(TheoryCraftCustomLeft:GetHeight())
		end
		i = i + 1
	end
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

local function TheoryCraftAddStat(text, text2)
	if (text == nil) or (text2 == nil) then return end
	if TheoryCraftStatsLeft:GetText() then
		TheoryCraftStatsLeft:SetText(TheoryCraftStatsLeft:GetText().."\n"..text)
		TheoryCraftStatsRight:SetText(TheoryCraftStatsRight:GetText().."\n"..text2)
	else
		TheoryCraftStatsLeft:SetText(text)
		TheoryCraftStatsRight:SetText(text2)
	end
	TheoryCraftStatsLeft:SetHeight(10+TheoryCraftStatsLeft:GetHeight())
	TheoryCraftStatsRight:SetHeight(TheoryCraftStatsLeft:GetHeight())
end

local function TheoryCraftAddVital(text, text2)
	if (text == nil) or (text2 == nil) then return end
	if TheoryCraftVitalsLeft:GetText() then
		TheoryCraftVitalsLeft:SetText(TheoryCraftVitalsLeft:GetText().."\n"..text)
		TheoryCraftVitalsRight:SetText(TheoryCraftVitalsRight:GetText().."\n"..text2)
	else
		TheoryCraftVitalsLeft:SetText(text)
		TheoryCraftVitalsRight:SetText(text2)
	end
	TheoryCraftVitalsLeft:SetHeight(10+TheoryCraftVitalsLeft:GetHeight())
	TheoryCraftVitalsRight:SetHeight(TheoryCraftVitalsLeft:GetHeight())
end

local function TheoryCraftAddMod(text, text2)
	if (text == nil) or (text2 == nil) then return end
	if TheoryCraftModsLeft:GetText() then
		TheoryCraftModsLeft:SetText(TheoryCraftModsLeft:GetText().."\n"..text)
	else
		TheoryCraftModsLeft:SetText(text)
	end
	if TheoryCraftModsRight:GetText() then
		TheoryCraftModsRight:SetText(TheoryCraftModsRight:GetText().."\n"..text2)
	else
		TheoryCraftModsRight:SetText(text2)
	end
end

function TheoryCraft_TabHandler(name)
	--local name = self:GetName()
	name = tonumber(string.sub(name, 15))
	TheoryCraftSettingsTab:Hide()
	TheoryCraftCustomOutfit:Hide()
	TheoryCraftOutfitTab:Hide()
	TheoryCraftButtonTextTab:Hide()
	TheoryCraftCustomOutfit:Hide()
--	TheoryCraftMitigationTab:Hide()
	if (name == _TOOLTIPTAB) then
		TheoryCraftSettingsTab:Show()
	elseif (name == _BUTTONTEXTTAB) then
		TheoryCraftButtonTextTab:Show()
	elseif (name == _ADVANCEDTAB) then 
		TheoryCraftOutfitTab:Show()
		TheoryCraft_UpdateOutfitTab()
--	elseif (name == _MITIGATIONTAB) then
--		TheoryCraftMitigationTab:Show()
	end
end


function TheoryCraft_UpdateOutfitTab()
	if not TheoryCraftOutfitTab:IsVisible() then
		return
	end
	local i = 1
	local i2 = 1
	while i < 4 do
		i2 = 1
		getglobal("TheoryCraftTalentTree"..i):SetText(" ")
		while getglobal("TheoryCraftTalent"..i..i2) do
			getglobal("TheoryCraftTalent"..i..i2):Hide()
			i2 = i2+1
		end
		i = i+1
	end
	i2 = 1
	local number
	local title, rank, i3, _, currank
	local highestnumber = 0
	while i2 < 4 do
		i = 1
		number = 1
		while (TheoryCraft_Talents[i]) do
			if (class == TheoryCraft_Talents[i].class) and (TheoryCraft_Talents[i].dontlist == nil) and (((TheoryCraft_Talents[i].tree == i2) and (TheoryCraft_Talents[i].forcetree == nil)) or (TheoryCraft_Talents[i].forcetree == i2)) then
				title = getglobal("TheoryCraftTalentTree"..i2)
				rank = getglobal("TheoryCraftTalent"..i2..number)
				i3 = 1
				while (TheoryCraft_Locale.TalentTranslator[i3]) and (TheoryCraft_Locale.TalentTranslator[i3].id ~= TheoryCraft_Talents[i].name) do
					i3 = i3 + 1
				end
				if (TheoryCraft_Locale.TalentTranslator[i3]) and (rank ~= nil) then
					title:SetText(title:GetText()..TheoryCraft_Locale.TalentTranslator[i3].translated.."\n")
					_, _, _, _, currank = GetTalentInfo(TheoryCraft_Talents[i].tree, TheoryCraft_Talents[i].number)
					if ((TheoryCraft_Talents[i].forceto == nil) or (TheoryCraft_Talents[i].forceto == -1)) then
						rank:SetText(currank)
					else
						rank:SetText(TheoryCraft_Talents[i].forceto)
					end
					rank:SetNormalTexture("")
					rank:SetPushedTexture("")
					rank:SetHighlightTexture("")
					local f = rank:GetFontString()
					if (TheoryCraft_Talents[i].forceto) and (TheoryCraft_Talents[i].forceto ~= -1) and (TheoryCraft_Talents[i].forceto ~= currank) then
						if f then
							f:SetTextColor(1,1,0.1)
						end
					else
						if f then
							f:SetTextColor(0.1,1,0.1)
						end
					end
					rank:Show()
					number = number + 1
				end
			end
			i = i+1
		end
		if highestnumber < number then highestnumber = number end
		i2 = i2 + 1
	end

	TheoryCraftTalentTitle:SetPoint("BOTTOMLEFT", TheoryCraftOutfitTab, "BOTTOMLEFT", 20, 42+10*highestnumber)

	TheoryCraftVitalsLeft:SetText()
	TheoryCraftVitalsRight:SetText()
	TheoryCraftVitalsLeft:SetHeight(2)
	TheoryCraftVitalsRight:SetHeight(2)
	TheoryCraftStatsLeft:SetText()
	TheoryCraftStatsRight:SetText()
	TheoryCraftStatsLeft:SetHeight(2)
	TheoryCraftStatsRight:SetHeight(2)
	TheoryCraftModsLeft:SetText()
	TheoryCraftModsRight:SetText()
	TheoryCraftModsLeft:SetHeight(2)
	TheoryCraftModsRight:SetHeight(2)

	local totalmana = TheoryCraft_GetStat("totalmana")+TheoryCraft_GetStat("manarestore")

	TheoryCraftAddVital("Health", math.floor(TheoryCraft_GetStat("totalhealth")))
	if class == "HUNTER" then
		TheoryCraftAddVital("Mana", math.floor(TheoryCraft_GetStat("totalmana")))
		TheoryCraftAddVital("Attack Power", math.floor(TheoryCraft_GetStat("attackpower")))
		TheoryCraftAddVital("Ranged Attack Power", math.floor(TheoryCraft_GetStat("rangedattackpower")))
		TheoryCraftAddVital("Crit Chance", round(TheoryCraft_GetStat("meleecritchancereal"), 2).."%")
		TheoryCraftAddVital("Ranged Crit Chance", round(TheoryCraft_GetStat("rangedcritchance"), 2).."%")
		TheoryCraftAddVital("Agi per Crit", round(TheoryCraft_agipercrit, 2))
		TheoryCraftAddVital("Normal Regen", round(TheoryCraft_Data.Stats["regen"]*2, 2).." / Tick")
		TheoryCraftAddVital("Regen Whilst Casting", round(TheoryCraft_Data.Stats["icregen"]*2, 2).." / Tick")
		TheoryCraftAddStat("Stamina", math.floor(TheoryCraft_GetStat("stamina")))
		TheoryCraftAddStat("Strength", math.floor(TheoryCraft_GetStat("strength")))
		TheoryCraftAddStat("Agility", math.floor(TheoryCraft_GetStat("agility")))
		TheoryCraftAddStat("Intellect", math.floor(TheoryCraft_GetStat("intellect")))
		TheoryCraftAddStat("Spirit", math.floor(TheoryCraft_GetStat("spirit")))
	elseif (class == "ROGUE") or (class == "WARRIOR") then
		TheoryCraftAddVital("Attack Power", math.floor(TheoryCraft_GetStat("attackpower")))
		TheoryCraftAddVital("Crit Chance", round(TheoryCraft_GetStat("meleecritchancereal"), 2).."%")
		TheoryCraftAddVital("Agi per Crit", round(TheoryCraft_agipercrit, 2))
		TheoryCraftAddStat("Stamina", math.floor(TheoryCraft_GetStat("stamina")))
		TheoryCraftAddStat("Strength", math.floor(TheoryCraft_GetStat("strength")))
		TheoryCraftAddStat("Agility", math.floor(TheoryCraft_GetStat("agility")))
	elseif (class == "PALADIN") then
		TheoryCraftAddVital("Mana", math.floor(TheoryCraft_GetStat("totalmana")))
		TheoryCraftAddVital("Attack Power", math.floor(TheoryCraft_GetStat("attackpower")))
		TheoryCraftAddVital("Crit Chance", round(TheoryCraft_GetStat("meleecritchancereal"), 2).."%")
		TheoryCraftAddVital("Agi per Crit", round(TheoryCraft_agipercrit, 2))
		TheoryCraftAddVital("Normal Regen", round(TheoryCraft_Data.Stats["regen"]*2, 2).." / Tick")
		TheoryCraftAddVital("Regen Whilst Casting", round(TheoryCraft_Data.Stats["icregen"]*2, 2).." / Tick")
		TheoryCraftAddStat("Stamina", math.floor(TheoryCraft_GetStat("stamina")))
		TheoryCraftAddStat("Intellect", math.floor(TheoryCraft_GetStat("intellect")))
		TheoryCraftAddStat("Strength", math.floor(TheoryCraft_GetStat("strength")))
		TheoryCraftAddStat("Agility", math.floor(TheoryCraft_GetStat("agility")))
		TheoryCraftAddStat("Spirit", math.floor(TheoryCraft_GetStat("spirit")))
	elseif (class == "DRUID") then
		if UnitPowerMax("player", Enum.PowerType.Mana) == 100 then
			TheoryCraftAddVital("Attack Power", math.floor(TheoryCraft_GetStat("attackpower")))
			TheoryCraftAddVital("Crit Chance", round(TheoryCraft_GetStat("meleecritchancereal"), 2).."%")
			TheoryCraftAddVital("Agi per Crit", round(TheoryCraft_agipercrit, 2))
			TheoryCraftAddStat("Stamina", math.floor(TheoryCraft_GetStat("stamina")))
			TheoryCraftAddStat("Strength", math.floor(TheoryCraft_GetStat("strength")))
			TheoryCraftAddStat("Agility", math.floor(TheoryCraft_GetStat("agility")))
		else
			TheoryCraftAddVital("Mana", math.floor(TheoryCraft_GetStat("totalmana")))
			TheoryCraftAddVital("Normal Regen", round(TheoryCraft_Data.Stats["regen"]*2, 2).." / Tick")
			TheoryCraftAddVital("Regen Whilst Casting", round(TheoryCraft_Data.Stats["icregen"]*2, 2).." / Tick")
			TheoryCraftAddStat("Stamina", math.floor(TheoryCraft_GetStat("stamina")))
			TheoryCraftAddStat("Intellect", math.floor(TheoryCraft_GetStat("intellect")))
			TheoryCraftAddStat("Spirit", math.floor(TheoryCraft_GetStat("spirit")))
		end
	else
		TheoryCraftAddVital("Mana", math.floor(TheoryCraft_GetStat("totalmana")))
		TheoryCraftAddVital("Normal Regen", round(TheoryCraft_Data.Stats["regen"]*2, 2).." / Tick")
		TheoryCraftAddVital("Regen Whilst Casting", round(TheoryCraft_Data.Stats["icregen"]*2, 2).." / Tick")
		TheoryCraftAddStat("Stamina", math.floor(TheoryCraft_GetStat("stamina")))
		TheoryCraftAddStat("Intellect", math.floor(TheoryCraft_GetStat("intellect")))
		TheoryCraftAddStat("Spirit", math.floor(TheoryCraft_GetStat("spirit")))
	end

	TheoryCraftModsLeft:SetHeight(288-TheoryCraftStatsLeft:GetHeight()-TheoryCraftVitalsLeft:GetHeight()-10*highestnumber)
	TheoryCraftModsRight:SetHeight(TheoryCraftModsLeft:GetHeight())

	local proceffect
	if TheoryCraft_GetStat("FrostboltNetherwind") ~= 0 then
		proceffect = 1
	end
	if TheoryCraft_GetStat("Beastmanarestore") ~= 0 then
		proceffect = 1
	end
	if TheoryCraft_Data.EquipEffects["procs"] then
		if TheoryCraft_IsDifferent(TheoryCraft_Data.EquipEffects["procs"], { }) then
			proceffect = 1
		end
	end
	if proceffect then
		TheoryCraftAddMod("Proc Effect", " ")
	end

	if TheoryCraft_GetStat("CritReport") ~= 0 then
		TheoryCraftAddMod("Crit Chance", "+"..(TheoryCraft_GetStat("CritReport")).."%")
	end
	if (class ~= "HUNTER") and (class ~= "WARRIOR") and (class ~= "ROGUE") then
		if TheoryCraft_GetStat("Allcritchance") ~= 0 then
			TheoryCraftAddMod("Spell Crit Chance", round(TheoryCraft_Data.Stats["critchance"], 2).."% + "..(TheoryCraft_GetStat("Allcritchance")).."%")
		else
			TheoryCraftAddMod("Spell Crit Chance", round(TheoryCraft_Data.Stats["critchance"], 2).."%")
		end
	end
	AddMods(1, "critchance", "DONT", "Heal Crit Chance", "Damage Spell Crit Chance", " Crit Chance", "+", "%")
	AddMods(1, "", "+Damage and Healing", "+Healing", "+Spell Damage", " Damage", "", "", "+")
	if TheoryCraft_GetStat("Undead") ~= 0 then
		TheoryCraftAddMod("+Damage to Undead", TheoryCraft_GetStat("Undead"))
	end
	if TheoryCraft_GetStat("AttackPowerReport") ~= 0 then
		TheoryCraftAddMod("Attack Power", "+"..(TheoryCraft_GetStat("AttackPowerReport")))
	end
	if TheoryCraft_GetStat("RangedAttackPowerReport") ~= 0 then
		TheoryCraftAddMod("Ranged Attack Power", "+"..(TheoryCraft_GetStat("RangedAttackPowerReport")))
	end
	if TheoryCraft_GetStat("BlockValueReport") ~= 0 then
		TheoryCraftAddMod("Shield Block Value", TheoryCraft_GetStat("BlockValueReport"))
	end
	AddMods(1, "hitchance", "Spell Hit Chance", "", "Damage Spell Hit Chance", " Hit Chance", "+", "%")
	if TheoryCraft_GetStat("Meleehitchance") ~= 0 then
		TheoryCraftAddMod("Hit Chance", "+"..(TheoryCraft_GetStat("Meleehitchance")).."%")
	end
	AddMods(1, "penetration", "Spell Penetration", "", "Damage Spell Penetration", " Penetration", "", "")
	if TheoryCraft_GetStat("manaperfive") ~= 0 then
		TheoryCraftAddMod("Mana Per Five", TheoryCraft_GetStat("manaperfive"))
	end
	if TheoryCraft_GetStat("ICPercent") ~= 0 then
		TheoryCraftAddMod("Spirit In 5 Rule", (TheoryCraft_GetStat("ICPercent")*100).."%")
	end
	if TheoryCraft_GetStat("manarestore") ~= 0 then
		TheoryCraftAddMod("Mana Restore", TheoryCraft_GetStat("manarestore"))
	end
	UpdateCustomOutfit()
end

function TheoryCraft_Combo1Click(self)
	local optionID = self:GetID()
	UIDropDownMenu_SetSelectedID(TheoryCrafttryfirst, optionID)
	TheoryCraft_Settings["tryfirst"] = self.value
	TheoryCraft_DeleteTable(TheoryCraft_UpdatedButtons)
end

function TheoryCraft_Combo2Click(self)
	local optionID = self:GetID()
	UIDropDownMenu_SetSelectedID(TheoryCrafttrysecond, optionID)
	TheoryCraft_Settings["trysecond"] = self.value
	TheoryCraft_DeleteTable(TheoryCraft_UpdatedButtons)
end

function TheoryCraft_Combo3Click(self)
	local optionID = self:GetID()
	UIDropDownMenu_SetSelectedID(TheoryCrafttryfirstsfg, optionID)
	TheoryCraft_Settings["tryfirstsfg"] = self.value
	TheoryCraft_DeleteTable(TheoryCraft_UpdatedButtons)
end

function TheoryCraft_Combo4Click(self)
	local optionID = self:GetID()
	UIDropDownMenu_SetSelectedID(TheoryCrafttrysecondsfg, optionID)
	TheoryCraft_Settings["trysecondsfg"] = self.value
	TheoryCraft_DeleteTable(TheoryCraft_UpdatedButtons)
end
local info = {}

local function AddButton(i, text, value, func, remaining)
	TheoryCraft_DeleteTable(info)
	info.remaining = true
	info.text = text
	info.value = value
	info.func = func
	UIDropDownMenu_AddButton(info)
	if (func == TheoryCraft_Combo1Click) and (TheoryCraft_Settings["tryfirst"] == value) then
		UIDropDownMenu_SetSelectedID(TheoryCrafttryfirst, i)
	end
	if (func == TheoryCraft_Combo2Click) and (TheoryCraft_Settings["trysecond"] == value) then
		UIDropDownMenu_SetSelectedID(TheoryCrafttrysecond, i)
	end
	if (func == TheoryCraft_Combo3Click) and (TheoryCraft_Settings["tryfirstsfg"] == value) then
		UIDropDownMenu_SetSelectedID(TheoryCrafttryfirstsfg, i)
	end
	if (func == TheoryCraft_Combo4Click) and (TheoryCraft_Settings["trysecondsfg"] == value) then
		UIDropDownMenu_SetSelectedID(TheoryCrafttrysecondsfg, i)
	end
	if (func == TheoryCraft_OutfitClick) and ((TheoryCraft_Data["outfit"] == value) or ((TheoryCraft_Data["outfit"] == nil) and (value == 1))) then
		UIDropDownMenu_SetSelectedID(TheoryCraftoutfit, i)
	end
	return i + 1
end

function TheoryCraft_InitDropDown(this)
	local a
	local i = 1
	if string.find(this:GetName(), "TheoryCraftoutfit") then
		for k, v in pairs(TheoryCraft_Outfits) do
			if ((v.class == nil) or (class == v.class)) then
				i = AddButton(i, (v.shortname or v.name), k, TheoryCraft_OutfitClick)
			end
		end
		return
	end
	if string.find(this:GetName(), "sfg") then
		if string.find(this:GetName(), "TheoryCrafttryfirst") then
			a = TheoryCraft_Combo3Click
		else
			a = TheoryCraft_Combo4Click
		end
		i = AddButton(i, "0.01", 2, a)
		i = AddButton(i, "0.1", 1, a)
		i = AddButton(i, "1", 0, a)
		i = AddButton(i, "10", -1, a)
		i = AddButton(i, "100", -2, a)
		i = AddButton(i, "1000", -3, a)
		return
	end
	if string.find(this:GetName(), "TheoryCrafttryfirst") then
		a = TheoryCraft_Combo1Click
	else
		a = TheoryCraft_Combo2Click
	end
	i = AddButton(i, "Do Nothing", "donothing", a)
	i = AddButton(i, "Min Damage", "mindamage", a)
	i = AddButton(i, "Max Damage", "maxdamage", a)
	i = AddButton(i, "Average Damage", "averagedam", a)
	i = AddButton(i, "Ave Dam (no crits)", "averagedamnocrit", a)
	i = AddButton(i, "DPS", "dps", a)
	i = AddButton(i, "With Dot DPS", "withdotdps", a)
	i = AddButton(i, "DPM", "dpm", a)
	i = AddButton(i, "Total Damage", "maxoomdamfloored", a)
	i = AddButton(i, "Total Damage (left)", "maxoomdamremaining", a)
	i = AddButton(i, "Min Heal", "minheal", a)
	i = AddButton(i, "Max Heal", "maxheal", a)
	i = AddButton(i, "Average Heal", "averageheal", a)
	i = AddButton(i, "Ave Heal (no crits)", "averagehealnocrit", a)
	i = AddButton(i, "HPS", "hps", a)
	i = AddButton(i, "With Hot HPS", "withhothps", a)
	i = AddButton(i, "HPM", "hpm", a)
	i = AddButton(i, "Total Healing", "maxoomhealfloored", a)
	i = AddButton(i, "Total Healing (left)", "maxoomhealremaining", a)
	i = AddButton(i, "Spellcasts remaining", "spellcasts", a)
end


function TheoryCraft_UpdateButtonTextPos(this)
	TheoryCraft_Settings["buttontextx"] = (this:GetParent():GetLeft()-this:GetLeft())/3
	TheoryCraft_Settings["buttontexty"] = (this:GetParent():GetTop()-this:GetTop())/3
	TheoryCraftdummytext:GetParent():ClearAllPoints()
	TheoryCraftdummytext:GetParent():SetPoint("TOPLEFT", TheoryCraftdummytext:GetParent():GetParent(), "TOPLEFT", -TheoryCraft_Settings["buttontextx"]*3, -TheoryCraft_Settings["buttontexty"]*3)
	TheoryCraftdummytext:GetParent():SetPoint("BOTTOMRIGHT", TheoryCraftdummytext:GetParent():GetParent(), "BOTTOMRIGHT", -TheoryCraft_Settings["buttontextx"]*3, -TheoryCraft_Settings["buttontexty"]*3)
end

function TheoryCraft_UpdateDummyButtonText(dontupdate)
	if not dontupdate then
		TheoryCraftFontPath:SetText(TheoryCraft_Settings["FontPath"])
		TheoryCraftColR:SetText(TheoryCraft_Settings["ColR"]*255)
		TheoryCraftColG:SetText(TheoryCraft_Settings["ColG"]*255)
		TheoryCraftColB:SetText(TheoryCraft_Settings["ColB"]*255)
		TheoryCraftColR2:SetText(TheoryCraft_Settings["ColR2"]*255)
		TheoryCraftColG2:SetText(TheoryCraft_Settings["ColG2"]*255)
		TheoryCraftColB2:SetText(TheoryCraft_Settings["ColB2"]*255)
		TheoryCraftFontSize:SetText(TheoryCraft_Settings["FontSize"])
	end

	TheoryCraftdummytext:GetParent():ClearAllPoints()
	TheoryCraftdummytext:GetParent():SetPoint("TOPLEFT", TheoryCraftdummytext:GetParent():GetParent(), "TOPLEFT", -TheoryCraft_Settings["buttontextx"]*3, -TheoryCraft_Settings["buttontexty"]*3)
	TheoryCraftdummytext:GetParent():SetPoint("BOTTOMRIGHT", TheoryCraftdummytext:GetParent():GetParent(), "BOTTOMRIGHT", -TheoryCraft_Settings["buttontextx"]*3, -TheoryCraft_Settings["buttontexty"]*3)

	TheoryCraftdummytext:SetFont(TheoryCraft_Settings["FontPath"], TheoryCraft_Settings["FontSize"]*3, "OUTLINE")
	TheoryCraftdummytext:SetTextColor(TheoryCraft_Settings["ColR"], TheoryCraft_Settings["ColG"], TheoryCraft_Settings["ColB"])
	TheoryCraftdummytext:SetJustifyV("MIDDLE")
	if TheoryCraft_Settings["alignleft"] then
		TheoryCraftdummytext:SetJustifyH("LEFT")
	elseif TheoryCraft_Settings["alignright"] then
		TheoryCraftdummytext:SetJustifyH("RIGHT")
	else
		TheoryCraftdummytext:SetJustifyH("CENTER")
	end
end

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

function TheoryCraft_AddButtonText(...)
	local newbutton, oldbutton
	local setupbutton = TheoryCraft_SetUpButton

	if SpellButton1 then
		for i = 1,12 do setupbutton("SpellButton"..i, "SpellBook") end
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

function TheoryCraft_UpdateAllButtonText(...)
	if not TheoryCraft_Data.TalentsHaveBeenRead then
		return
	end
	local newbutton, oldbutton
	local updatebutton = function(name)
		local button = getglobal(name)
		if button then
			TheoryCraft_ButtonUpdate(button)
		end
	end

	if SpellButton1 then
		for i = 1,12 do updatebutton("SpellButton"..i, "SpellBook") end
	end

	if ActionButton1 then
		for i = 1,12 do updatebutton("ActionButton"..i, "Flippable") end
		for i = 1,12 do updatebutton("MultiBarRightButton"..i, "Special", 24+i) end
		for i = 1,12 do updatebutton("MultiBarLeftButton"..i, "Special", 36+i) end
		for i = 1,12 do updatebutton("MultiBarBottomRightButton"..i, "Special", 48+i) end
		for i = 1,12 do updatebutton("MultiBarBottomLeftButton"..i, "Special", 60+i) end
		for i = 1,12 do updatebutton("BonusActionButton"..i, "Bonus") end
	end

	if _G['Bartender4'] ~= nil then
		for i = 1,120 do updatebutton("BT4Button"..i, "Normal") end
	end
end


hooksecurefunc("ChangeActionBarPage", function(i)
	CURRENT_ACTIONBAR_PAGE = i
	TheoryCraft_UpdateAllButtonText()
end)

hooksecurefunc("ActionButton_Update", function(button)
	TheoryCraft_ButtonUpdate(button)
end)

hooksecurefunc("SpellBookFrame_UpdateSpells", function(i)
	TheoryCraft_UpdateAllButtonText()
end)

function TheoryCraft_ButtonUpdate(this, ...)
	if not TheoryCraft_Data.TalentsHaveBeenRead then
		return
	end
	local i = this:GetName().."_TCText"

	local buttontext = getglobal(i)
	if not buttontext then 
		return
	end

	if not buttontext then return end

	

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

	if not TheoryCraft_Settings["buttontext"] then
		buttontext:Hide()
		return
	end
	-- Try to find the spell data lookup by the spell we have on the button

	local tryfirst, trysecond, spelldata
	if buttontext.type == "SpellBook" then
		local icon = getglobal(this:GetName().."SpellName")
		local id = icon:GetText()
		local id2 = getglobal(this:GetName().."SubSpellName"):GetText()
		if (not icon:IsShown() or not (getglobal(this:GetName().."SpellName"):IsShown())) or (id == nil) then
			buttontext:Hide()
			id = nil
		end
		if id then
			id2 = tonumber(findpattern(id2, "%d+"))
			if id2 == nil then id2 = 0 end
			spelldata = TheoryCraft_GetSpellDataByName(id, id2)
		end
	else
		local action = this:GetAttribute('action') or this.action
		spelldata = TheoryCraft_GetSpellDataByAction(action)
	end
	-- Must contain some properties to be valid
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