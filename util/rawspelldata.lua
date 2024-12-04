local function createTalentOutputFrame()
   local className = UnitClass("player") -- Get the current player's class name
   local talentOutput = ""
   
   -- Gather talent data
   for i = 1, GetNumTalentTabs() do
      for j = 1, GetNumTalents(i) do
         local name = GetTalentInfo(i, j)
         local talentData = string.format(
            '{ "class": "%s", "name": "%s", "tree": %d, "number": %d },',
            className, name, i, j
         )
         talentOutput = talentOutput .. talentData .. "\n"
      end
   end
   
   -- Create frame
   local frame = CreateFrame("Frame", "TalentOutputFrame", UIParent, "BackdropTemplate")
   frame:SetSize(500, 400)
   frame:SetPoint("CENTER")
   frame:SetBackdrop({
         bgFile = "Interface/Tooltips/UI-Tooltip-Background",
         edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
         tile = true,
         tileSize = 16,
         edgeSize = 16,
         insets = { left = 4, right = 4, top = 4, bottom = 4 }
   })
   frame:SetBackdropColor(0, 0, 0, 0.8)
   
   -- Add title
   local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
   title:SetPoint("TOP", 0, -10)
   title:SetText("Talent Output")
   
   -- Create a scrollable edit box
   local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
   scrollFrame:SetPoint("TOPLEFT", 10, -40)
   scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
   
   local editBox = CreateFrame("EditBox", nil, scrollFrame)
   editBox:SetMultiLine(true)
   editBox:SetFontObject(GameFontNormal)
   editBox:SetWidth(440)
   editBox:SetText(talentOutput)
   editBox:SetAutoFocus(false)
   editBox:HighlightText()
   
   scrollFrame:SetScrollChild(editBox)
   
   -- Close and destroy frame on Escape key
   editBox:SetScript("OnKeyDown", function(self, key)
         if key == "ESCAPE" then
            frame:Hide()
            frame:SetScript("OnHide", function()
                  frame:Hide()
                  frame = nil
            end)
         end
   end)
   
   frame:Show()
end

-- Call the function to display the frame
createTalentOutputFrame()
