--    FILE: StandaloneGUI.lua
--    DATE: 31-10-19
--  AUTHOR: Vitruvius
-- PURPOSE: Create Standalone GUI that opens on /topgun

--______________________________________________________________________________________________________

local function TOPGUN_CreateStandaloneGUI() 

   local frame = CreateFrame("Frame",nil,UIParent,"BasicFrameTemplateWithInset");

   -- register for scrolls
   frame:EnableMouse(true);

   -- dimensions
   frame:SetWidth(340);
   frame:SetHeight(390);
   frame:SetPoint("TOPLEFT",10,-150);
   frame:SetFrameStrata("MEDIUM");

   -- heading
   frame.Heading = frame:CreateFontString(nil,nil,"GameFontNormalSmall");
   frame.Heading:SetPoint("TOP",frame,"TOP",0,-6);
   frame.Heading:SetText("TopGun Settings");

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

      -- when we hide this settings frame, hide everything else

      TOPGUN_SettingsGUI:Hide();

      if (TOPGUN_AdvancedSettingsGUI:IsVisible()) then

         TOPGUN_AdvancedSettingsGUI:Hide();
      end

      if (TOPGUN_StatFrameGUI:IsVisible()) then

         TOPGUN_StatFrameGUI:Hide();
      end

      if (TOPGUN_PreviousFlightGUI:IsVisible()) then

         TOPGUN_PreviousFlightGUI:Hide();
      end
	
   end)

   frame:Hide();

   return frame;

end -- TOPGUN_CreateStandaloneGUI()

TOPGUN_StandaloneGUI = TOPGUN_CreateStandaloneGUI();

TOPGUN_StandaloneGUI.Update = function(self)
	
   -- update stuff

end