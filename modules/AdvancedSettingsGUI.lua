--    FILE: AdvancedSettingsGUI.lua
--    DATE: 31-10-19
--  AUTHOR: Vitruvius
-- PURPOSE: GUI for advanced settings

local function TOPGUN_CreateAdvancedGUI() 

   local frame = CreateFrame("Frame",nil,UIParent,"BasicFrameTemplateWithInset");

   -- register for scrolls
   frame:EnableMouse(true);

   -- dimensions
   frame:SetWidth(217);
   frame:SetHeight(390);
   frame:SetPoint("CENTER");
   frame:SetFrameStrata("MEDIUM");

   -- heading
   frame.Heading = frame:CreateFontString(nil,nil,"GameFontNormalSmall");
   frame.Heading:SetPoint("TOP",frame,"TOP",0,-6);
   frame.Heading:SetText("Advanced Settings");

   ShowLearningCheck = CreateFrame("CheckButton", "ShowLearningCheck_GlobalName", frame, "ChatConfigCheckButtonTemplate");
   ShowLearningCheck:SetPoint("TOPLEFT",frame,15,-35);
   ShowLearningCheck_GlobalNameText:SetText(" Show Learning Bar");
   ShowLearningCheck.tooltip = "Enable/disable the learning bar for unknown flights";
   ShowLearningCheck:SetScript("OnClick", 
      function()
         if (ShowLearningCheck:GetChecked()) then
            TOPGUN_GlobalData.Settings.ShowLearningBar = true;

            if (FlightData.IsFlying) then

               TOPGUN_FlightTimeFrame:Show();

            end

         else

            TOPGUN_GlobalData.Settings.ShowLearningBar = false;

            if (FlightData.IsFlying and TOPGUN_FlightTimeFrame:IsVisible() and TOPGUN_FlightTimeFrame.LearningTxt:IsVisible()) then

               TOPGUN_FlightTimeFrame:Hide();

            end

         end
      end);
   ShowLearningCheck:SetChecked(true);

--[[

   -- reset previous button

   local ResetPreviousBtn = CreateFrame("Button",nil,frame,"GameMenuButtonTemplate");
   ResetPreviousBtn:SetWidth(150);
   ResetPreviousBtn:SetHeight(25);
   ResetPreviousBtn:SetPoint("BOTTOM",frame,0,50);
   -- button text
   ResetPreviousBtn.txt = ResetPreviousBtn:CreateFontString(nil,nil,"GameFontNormal");
   ResetPreviousBtn.txt:SetPoint("CENTER",ResetPreviousBtn);
   ResetPreviousBtn.txt:SetText("Clear Previous Flights");

   ResetPreviousBtn:SetScript("onClick",function(self) 

      -- confirm delete
      StaticPopup_Show("DELETE_PREVIOUS_DATA");

   end)
]]
   -- reset all button

   local ResetAllBtn = CreateFrame("Button",nil,frame,"GameMenuButtonTemplate");
   ResetAllBtn:SetWidth(115);
   ResetAllBtn:SetHeight(25);
   ResetAllBtn:SetPoint("BOTTOM",frame,"BOTTOM",0,30);
   -- button text
   ResetAllBtn.txt = ResetAllBtn:CreateFontString(nil,nil,"GameFontNormal");
   ResetAllBtn.txt:SetPoint("CENTER",ResetAllBtn);
   ResetAllBtn.txt:SetText("Reset ALL Data");

   ResetAllBtn:SetScript("onClick",function(self) 

      -- confirm delete
      StaticPopup_Show("DELETE_ALL_FLIGHT_DATA");

   end)

   --______________________________________________________________

   frame.Toggle = function(self)
     if (frame:IsVisible()) then
       frame:Hide();
     else
       frame:Update(frame);
       frame:Show();
     end
   end

   --______________________________________________________________

   frame.SetToTaxi = function(self)

      -- show the flight list

      frame.Toggle();
      frame:ClearAllPoints();
      frame:SetPoint("TOPLEFT",TaxiFrame,"BOTTOMLEFT",13,75);

   end

   --______________________________________________________________

   frame:SetScript("OnHide",function() 

	
   end)

   frame:Hide();

   return frame;

end -- TOPGUN_CreateStandaloneGUI()

TOPGUN_AdvancedSettingsGUI = TOPGUN_CreateAdvancedGUI();

TOPGUN_AdvancedSettingsGUI.Update = function(self)
	
   -- update stuff

   self:SetPoint("TOPLEFT",TOPGUN_StandaloneGUI,"TOPRIGHT");

   ShowLearningCheck:SetChecked(TOPGUN_GlobalData.Settings.ShowLearningBar);

end

StaticPopupDialogs["DELETE_ALL_FLIGHT_DATA"] = {
   text = "Delete ALL your data?\n\n",
   button1 = "Yes",
   button2 = "No",
   OnAccept = function()

      -- delete FlightData stuff
      FlightData.TotalFlights = 0;
      FlightData.TotalSpent = 0;
      FlightData.TotalTime = 0;      

      FlightData.Flights = {};
      FlightData.ZoneStats = {};

      FlightData.HasReset = true; -- checked on landing, so we don't update a nil flight with a landing time
      -- update GUIs
      TOPGUN_PreviousFlightGUI:Update(TOPGUN_PreviousFlightGUI);
      TOPGUN_StatFrameGUI:Update(TOPGUN_StatFrameGUI);

   end,
   timeout = 0,
   whileDead = true,
   hideOnEscape = true,
   preferredIndex = 3,  -- avoid some UI taint??
}
--[[
StaticPopupDialogs["DELETE_PREVIOUS_DATA"] = {
   text = "Delete your previous flight data?\n\n",
   button1 = "Yes",
   button2 = "No",
   OnAccept = function()
      print("you accepted!!!!");   
   end,
   timeout = 0,
   whileDead = true,
   hideOnEscape = true,
   preferredIndex = 3,  -- avoid some UI taint??
}
]]