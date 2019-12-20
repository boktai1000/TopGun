--    FILE: SlashHandler.lua
--    DATE: 8-10-19
--  AUTHOR: Vitruvius
-- PURPOSE: Handle Slash Commands

local prefix = "\124cFFFF0066<TopGun> \124cFFFFFFFF";

SLASH_TOPGUN1,SLASH_TOPGUN2 = "/tg","/topgun"

SlashCmdList["TOPGUN"] = function(cmd)

   -- check cmd

   if (cmd == "") then

      -- toggle GUI

      if (TOPGUN_StandaloneGUI:IsVisible()) then

         TOPGUN_StandaloneGUI:Hide();
         return;
      end

      if (TaxiMap:IsVisible()) then

         TOPGUN_SettingsGUI.Toggle();

      else

         TOPGUN_StandaloneGUI.Toggle();
         TOPGUN_AdvancedSettingsGUI:Toggle();
         TOPGUN_SettingsGUI.Toggle();
         TOPGUN_StatFrameGUI.SetToStandalone();
         TOPGUN_PreviousFlightGUI.SetToStandalone();         

      end

   end -- cmd ""

   if (cmd == "print") then

      -- TESTER FUNCTION
      
      print(prefix .. "Total Flights: " .. FlightData.TotalFlights);

      if (FlightData.IsFlying) then
         print(prefix .. "Currently Flying: true");
      else
         print(prefix .. "Currently Flying: false");
      end -- IsFlying

      for k,v in pairs(FlightData.Flights) do

         print(prefix .. "------------");
         print(prefix .. "Flight no# " .. k);
         print(prefix .. "TimeStamp: " .. v[1]);         
         print(prefix .. "Cost: " .. v[3]);
         print(prefix .. "Start: " .. v[2]);
         print(prefix .. "End: " .. v[4]);
         print(prefix .. "endTimeStamp: " .. v[5]);         
       
      end -- for

   end -- cmd "print"

   if (cmd == "reset") then

      -- reset everything (FOR TESTING PURPOSES)

      FlightData = nil;
      _G["FlightData"] = nil;

      print(prefix .. "All data reset.");

   end -- cmd "reset"

end -- Slash_Handler()