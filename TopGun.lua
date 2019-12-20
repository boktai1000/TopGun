--    FILE: TopGun.lua
--    DATE: 19-10-19
--  AUTHOR: Vitruvius
-- PURPOSE: Flight Addon

--[[ NOTES: VERSION - 1.3.8

            - RELEASE version

            1.0.4 - fixed bug if you reload ui mid-flight
 
            1.1.0 - added timer bar textures with Libsharedmedia
                  - added timer bar colours
                  - added timer fonts
                  - added font colours

            1.2.0 - added preloaded flight times
                  - fixed a total flight time bug
                  - added flight time to tooltip

            1.2.2 - fixed flight timers so you can edit the bar during flight, & it instantly updates
                  - added advanced settings panel
                  - added ability to hide learning bar
                  - fixed bug where timer wouldn't show up on free flights (auberdine to darn)
            1.2.3 - fixed bug when clicking show flight list mid-flight
                  - added a bunch of pre-loaded flights

            1.3.0 - made known flight times and timer bar settings global across all characters
                  - added more flight times

            1.3.2 - font preview in dropdown
                  - cancelled flights no longer mess up flight time database 

            1.3.3 - fixed bug that throws error when you change textures

            1.3.4 - hotfix for bug where EVERY dropdown will have a texture after opening topgun

            1.3.5 - fixed bug so flight times update if a shorter path is learned

            1.3.6 - added delete all data button

            1.3.7 - Code cleanup

            1.3.8 - tooltip fix
]]

TOPGUN_FlightListWidth = 220;

TOPGUN_FlightTimeFrame = CreateFrame("StatusBar","TOPGUN_FlightTimeFrame",UIParent); -- flight timer bar

local prefix = "\124cFFFF0066[TopGun] \124cFFFFFFFF";
local pendingStartZone,pendingEndZone; -- filled when we successfully take a flight
local tempFlightData; -- filled when we try to take a flight
local tempStartZone; -- used for tooltip time calculation

local EventFrame = CreateFrame("Frame",nil,UIParent); -- for takeoff/landing events

--  create the timer bar
TOPGUN_FlightTimeFrame:SetSize(200, 22)
TOPGUN_FlightTimeFrame:SetPoint("CENTER")
TOPGUN_FlightTimeFrame:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]]})
TOPGUN_FlightTimeFrame:SetBackdropColor(0, 0, 0, 0.7)
TOPGUN_FlightTimeFrame:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
TOPGUN_FlightTimeFrame:SetStatusBarColor(0, 0.5, 1)
TOPGUN_FlightTimeFrame:SetFrameStrata("HIGH");
-- left timer bar text
TOPGUN_FlightTimeFrame.ZoneTxt = TOPGUN_FlightTimeFrame:CreateFontString(nil,nil,"GameFontWhite");
TOPGUN_FlightTimeFrame.ZoneTxt:SetPoint("LEFT",TOPGUN_FlightTimeFrame,3,0);
TOPGUN_FlightTimeFrame.ZoneTxt:SetWidth(TOPGUN_FlightTimeFrame:GetWidth() - 50);
TOPGUN_FlightTimeFrame.ZoneTxt:SetJustifyH("LEFT");
TOPGUN_FlightTimeFrame.ZoneTxt:SetHeight(20);
TOPGUN_FlightTimeFrame.ZoneTxt:SetText("none");
-- middle timer bar text
TOPGUN_FlightTimeFrame.LearningTxt = TOPGUN_FlightTimeFrame:CreateFontString(nil,nil,"GameFontWhite");
TOPGUN_FlightTimeFrame.LearningTxt:SetPoint("CENTER",TOPGUN_FlightTimeFrame);
TOPGUN_FlightTimeFrame.LearningTxt:SetText("Learning Flight");
-- right timer bar text
TOPGUN_FlightTimeFrame.txt = TOPGUN_FlightTimeFrame:CreateFontString(nil,nil,"GameFontWhite");
TOPGUN_FlightTimeFrame.txt:SetPoint("RIGHT",TOPGUN_FlightTimeFrame,-5,0);
TOPGUN_FlightTimeFrame.txt:SetText("none");

TOPGUN_FlightTimeFrame:Hide();

--______________________________________________________________________________________________________

local returnTimeFormatted = function(time)

   local timeString = "";
   local hours = 0;
   local minutes = 0;
   local seconds = 0;

   if (time > 3600) then

      hours = floor(time / 3600);
      minutes = floor(time % 3600);
      seconds = floor(minutes % 60);

      timeString = hours .. "h " ..minutes .. "m " .. seconds .. "s";

   end

   if (time > 60) then

      minutes = floor(time / 60);
      seconds = floor(time % 60);

      timeString = minutes .. "m " .. seconds .. "s";

   else

      seconds = floor(time);

      timeString = seconds .. "s";

   end

   return timeString;

end -- returnTimeFormatted()

--______________________________________________________________________________________________________

local LandingHandler = function(self,event,...) 

   -- double check if the player was flying

   if (FlightData.IsFlying) then

      if not FlightData.HasReset then

         FlightData.Flights[FlightData.TotalFlights][5] = time();   -- landed timestamp
         local flightName = FlightData.ZoneStats.LastFlightPoint;

         -- how long was the flight?

         local endTime = time();
         local leaveTime = FlightData.ZoneStats[flightName].LastTimestamp;

         local flightTime = endTime - leaveTime;

         FlightData.ZoneStats[flightName].TimeFlying = FlightData.ZoneStats[flightName].TimeFlying + flightTime;
         FlightData.TotalTime = FlightData.TotalTime + flightTime;

         -- update the timer if we need to

         if (pendingStartZone and pendingEndZone) then

            if not event then
   
               TOPGUN_GlobalData.FlightTimes[pendingStartZone][pendingEndZone] = nil;

               print(prefix.."Emergency Landing Initiated.");

            else

               TOPGUN_GlobalData.FlightTimes[pendingStartZone][pendingEndZone] = flightTime;

            end -- cancelled flight?

         end

      else 

         FlightData.HasReset = false;

      end -- RESET

      pendingStartZone = nil;
      pendingEndZone = nil;

      -- hide the timer bar

      if (TOPGUN_FlightTimeFrame:IsVisible()) then

         TOPGUN_FlightTimeFrame:Hide();
      end

      TOPGUN_FlightTimeFrame:SetScript("OnUpdate",nil); -- needed?

      -- unregister from event

      EventFrame:UnregisterEvent("PLAYER_CONTROL_GAINED");

      -- set flag

      FlightData.IsFlying = false;

      -- print thankyou

      if (TOPGUN_GlobalData.Settings.ShowFlavour) then

         if not event then

            print(prefix .. "Emergency Landing Initiated.");

         else

            print(prefix .. "Thank-you for flying with TopGun.");

         end

      end

      -- UPDATE THE GLOBAL

      _G["FlightData"] = FlightData; 

      return;

   end -- IsFlying

end -- LandingHandler()

--______________________________________________________________________________________________________

local TakeoffHandler = function(self,event,...)

   if (event == "UI_ERROR_MESSAGE") then

      -- This exact thing here caused me so much pain!
      -- What happens if you hook TakeTaxiNode, but they're mounted?
      -- there's no way to check if they actually took the flight
      -- UnitOnTaxi returns false for a few moments even if they take the flight
      -- So instead, i listen for a couple of events, & try to figure out if they
      -- successfully took the flight or not... 
      -- This error event means they couldn't take the flight.
      EventFrame:UnregisterEvent("UI_ERROR_MESSAGE");
      EventFrame:UnregisterEvent("PLAYER_CONTROL_LOST");

      tempFlightData = nil;

   end -- UI_ERROR_MESSAGE

   if (event == "PLAYER_CONTROL_LOST") then

      -- TakeTaxiNode was successful, create the timer bar & FlightData info

      local destNode = tempFlightData[1];
      local currNode = tempFlightData[2];
      local cost = tempFlightData[3];
      local currentText = tempFlightData[4];
      local destText = tempFlightData[5];
      local currentTime = tempFlightData[6];
      local endTime = tempFlightData[7];

      if not FlightData.ZoneStats[destText] then

         -- first time taking this flight, create a blank entry
         FlightData.ZoneStats[destText] = {TimesFlown = 0,TimeFlying = 0,TotalSpent = 0,TimeFlying = 0};
         -- now update the entry like normal
      end

      -- fill our database with 90% of the info. 
      -- the rest will be filled on PLAYER_CONTROL_GAINED event

      FlightData.ZoneStats.LastFlightPoint = destText; -- so we know which ZoneStats entry to update when we land
      FlightData.ZoneStats[destText].TimesFlown = FlightData.ZoneStats[destText].TimesFlown + 1;
      FlightData.ZoneStats[destText].TotalSpent = FlightData.ZoneStats[destText].TotalSpent + cost;
      FlightData.ZoneStats[destText].LastTimestamp = time();

      FlightData.TotalFlights = FlightData.TotalFlights + 1;
      FlightData.TotalSpent = FlightData.TotalSpent + cost;
      FlightData.IsFlying = true; -- for PLAYER_CONTROL_GAINED, also register for that event

      -- create a record of this flight

      local startTimeStamp = time();
      local startZone = currentText;
      --    cost
      local endZone = destText;
      local endTimeStamp = 0;

      local FlightInfo = {startTimeStamp,startZone,cost,endZone,endTimeStamp};

      table.insert(FlightData.Flights,FlightInfo);

      -- do we know how long this flight is?

      if not TOPGUN_GlobalData.FlightTimes[startZone] then
 
         TOPGUN_GlobalData.FlightTimes[startZone] = {};
      end

      if (TOPGUN_GlobalData.FlightTimes[startZone][endZone]) then

         -- **************************************************************

         -- create a bar!

         local START = TOPGUN_GlobalData.FlightTimes[startZone][endZone];
         local END = 0;

         -- settings
         TOPGUN_FlightTimeFrame:SetWidth(TOPGUN_GlobalData.Settings.TimerWidth);
         TOPGUN_FlightTimeFrame.ZoneTxt:SetWidth(TOPGUN_FlightTimeFrame:GetWidth() - 50);
         TOPGUN_FlightTimeFrame:ClearAllPoints();
         TOPGUN_FlightTimeFrame:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",TOPGUN_GlobalData.Settings.TimerX,TOPGUN_GlobalData.Settings.TimerY);

         TOPGUN_FlightTimeFrame:SetMinMaxValues(END, START);

         local timer = TOPGUN_GlobalData.FlightTimes[startZone][endZone];

         -- this function will run repeatedly, incrementing the value of timer as it goes
         TOPGUN_FlightTimeFrame:SetScript("OnUpdate", function(self, elapsed)
            timer = timer - elapsed
            self:SetValue(timer)
            TOPGUN_FlightTimeFrame.txt:SetText(returnTimeFormatted(timer));
            -- when timer has reached the desired value, as defined by global END (seconds), restart it by setting it to 0, as defined by global START
            if timer <= END then
               --timer = START
            end
         end)

         -- set the bar texture to user choice

         TOPGUN_FlightTimeFrame:SetStatusBarTexture(TOPGUN_GlobalData.Settings.TimerTexture);
         TOPGUN_FlightTimeFrame:SetStatusBarColor(TOPGUN_GlobalData.Settings.TimerColour.r,TOPGUN_GlobalData.Settings.TimerColour.g,TOPGUN_GlobalData.Settings.TimerColour.b,TOPGUN_GlobalData.Settings.TimerColour.a)

         -- set the bar font to user choice

         if TOPGUN_GlobalData.Settings.TimerFont ~= "default" then
         
            local _,size,flags = TOPGUN_FlightTimeFrame.ZoneTxt:GetFont();

            TOPGUN_FlightTimeFrame.ZoneTxt:SetFont(TOPGUN_GlobalData.Settings.TimerFont,size,flags);
            TOPGUN_FlightTimeFrame.ZoneTxt:SetText(" ");
            TOPGUN_FlightTimeFrame.txt:SetFont(TOPGUN_GlobalData.Settings.TimerFont,size,flags);
            TOPGUN_FlightTimeFrame.txt:SetText(" ");

         end

         -- set the bar colour

         TOPGUN_FlightTimeFrame.ZoneTxt:SetTextColor(TOPGUN_GlobalData.Settings.TimerFontColour.r,TOPGUN_GlobalData.Settings.TimerFontColour.g,TOPGUN_GlobalData.Settings.TimerFontColour.b,TOPGUN_GlobalData.Settings.TimerFontColour.a);
         TOPGUN_FlightTimeFrame.txt:SetTextColor(TOPGUN_GlobalData.Settings.TimerFontColour.r,TOPGUN_GlobalData.Settings.TimerFontColour.g,TOPGUN_GlobalData.Settings.TimerFontColour.b,TOPGUN_GlobalData.Settings.TimerFontColour.a);

         -- set the destination text

         TOPGUN_FlightTimeFrame.LearningTxt:Hide();
         TOPGUN_FlightTimeFrame.ZoneTxt:SetText(destText);

         if (TOPGUN_GlobalData.Settings.ShowTimer) then

            TOPGUN_FlightTimeFrame:Show();

         end -- IF show timer

         -- **************************************************************

         -- this is to allow the known time to CHANGE, if we learn a shorter path or something.
         -- this means that every time we land, we'll be updating the time stored for that flight

         pendingStartZone = startZone;
         pendingEndZone = endZone;
   
      else -- CREATE A LEARNING BAR!

         local START = 20;
         local END = 0;

         -- settings
         TOPGUN_FlightTimeFrame:SetWidth(TOPGUN_GlobalData.Settings.TimerWidth);
         TOPGUN_FlightTimeFrame:ClearAllPoints();
         TOPGUN_FlightTimeFrame:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",TOPGUN_GlobalData.Settings.TimerX,TOPGUN_GlobalData.Settings.TimerY);

         TOPGUN_FlightTimeFrame:SetMinMaxValues(END, START);

         local timer = START;

         -- this function will run repeatedly, incrementing the value of timer as it goes
         TOPGUN_FlightTimeFrame:SetScript("OnUpdate", function(self, elapsed)
            timer = timer - elapsed
            self:SetValue(timer)
            -- when timer has reached the desired value, reset it
            if timer <= END then
               timer = START
            end
         end)

         -- set the bar texture to user choice

         TOPGUN_FlightTimeFrame:SetStatusBarTexture(TOPGUN_GlobalData.Settings.TimerTexture);
         TOPGUN_FlightTimeFrame:SetStatusBarColor(TOPGUN_GlobalData.Settings.TimerColour.r,TOPGUN_GlobalData.Settings.TimerColour.g,TOPGUN_GlobalData.Settings.TimerColour.b,TOPGUN_GlobalData.Settings.TimerColour.a)

         -- set the bar font & colour

         if TOPGUN_GlobalData.Settings.TimerFont ~= "default" then
         
            local _,size,flags = TOPGUN_FlightTimeFrame.ZoneTxt:GetFont();

            TOPGUN_FlightTimeFrame.LearningTxt:SetFont(TOPGUN_GlobalData.Settings.TimerFont,size,flags);
            TOPGUN_FlightTimeFrame.LearningTxt:SetText(" ");
            TOPGUN_FlightTimeFrame.LearningTxt:SetText("Learning Flight");

         end

         TOPGUN_FlightTimeFrame.LearningTxt:SetTextColor(TOPGUN_GlobalData.Settings.TimerFontColour.r,TOPGUN_GlobalData.Settings.TimerFontColour.g,TOPGUN_GlobalData.Settings.TimerFontColour.b,TOPGUN_GlobalData.Settings.TimerFontColour.a);

         -- learning text

         TOPGUN_FlightTimeFrame.ZoneTxt:SetText("");
         TOPGUN_FlightTimeFrame.txt:SetText("");
         TOPGUN_FlightTimeFrame.LearningTxt:Show();

         if (TOPGUN_GlobalData.Settings.ShowTimer and TOPGUN_GlobalData.Settings.ShowLearningBar) then

            TOPGUN_FlightTimeFrame:Show();

         end -- IF show timer

         -- **************************************************************

         -- create an entry ready for landing
         TOPGUN_GlobalData.FlightTimes[startZone][endZone] = 0;
         pendingStartZone = startZone;
         pendingEndZone = endZone;

      end -- if/else (show timer bar or learning bar)

      -- register for the landing event

      EventFrame:RegisterEvent("PLAYER_CONTROL_GAINED");
      EventFrame:SetScript("OnEvent",LandingHandler);

      if (TOPGUN_GlobalData.Settings.ShowFlavour) then

         print(prefix .. "Ka-Ching!");
   
      end

      _G["FlightData"] = FlightData;

      EventFrame:UnregisterEvent("UI_ERROR_MESSAGE");
      EventFrame:UnregisterEvent("PLAYER_CONTROL_LOST");

      tempFlightData = nil;

   end -- PLAYER_CONTROL_LOST

end -- TakeoffHandler()

--______________________________________________________________________________________________________

-- hook the TakeTaxiNode(node) function

local original_TakeTaxiNode = TakeTaxiNode;

--______________________________________________________________________________________________________

TakeTaxiNode = function ( ... )
   
   local destNode = ...;
   local currNode;
   local cost = TaxiNodeCost(...);
   local currentText;
   local destText = TaxiNodeName(...);
   local currentTime = time();
   local endTime = 0;
   
   -- find our current node, so we can get the text

   for i = 1,NumTaxiNodes(),1 do

      local nodeType = TaxiNodeGetType(i); -- "CURRENT","REACHABLE","UNREACHABLE"

      if (nodeType == "CURRENT") then

         -- update our currentNode
         currNode = i;
         currentText = TaxiNodeName(currNode);
      end
   end

   -- fill our temp flight data with this flight info

   tempFlightData = {destNode,currNode,cost,currentText,destText,currentTime,endTime}; -- holds the info while we try to take the flight

   DoEmote("STAND"); -- HACK - just in case we're sitting

   -- register for takeoff events

   EventFrame:RegisterEvent("UI_ERROR_MESSAGE");
   EventFrame:RegisterEvent("PLAYER_CONTROL_LOST");

   -- set our takeoff handler

   EventFrame:SetScript("OnEvent",TakeoffHandler);

   -- call original

   return original_TakeTaxiNode( ... ); 

end

--______________________________________________________________________________________________________

local original_TaxiNodeOnButtonEnter = TaxiNodeOnButtonEnter;

--______________________________________________________________________________________________________

TaxiNodeOnButtonEnter = function(...)

   -- POST hook? try doing stuff AFTER the tooltip is already created

   original_TaxiNodeOnButtonEnter(...);

   local btn = ...;
   local index = btn:GetID();
   local flightName = TaxiNodeName(index);

   -- get our current node

   for i = 0,NumTaxiNodes(),1 do

      local ttype = TaxiNodeGetType(i);

      if ttype == "CURRENT" then

         tempStartZone = TaxiNodeName(i);
         --return;

      end

   end
 
   -- if we have a flight time

   if (TOPGUN_GlobalData.FlightTimes[tempStartZone] and TOPGUN_GlobalData.FlightTimes[tempStartZone][flightName]) then

      GameTooltip:AddLine(returnTimeFormatted(TOPGUN_GlobalData.FlightTimes[tempStartZone][flightName]), 0, 1, 0, 1, true);

   else

      -- check we're not mousing over our current location

      if (tempStartZone ~= flightName) then

         GameTooltip:AddLine("unknown time", 1, 0, 0, 1, true);

      end -- if

   end

   -- add the tooltip info

   GameTooltip:AddLine(" ",nil,nil,nil,false) -- blank line before our info

   -- if we have stats for this flight path

   if (FlightData.ZoneStats[flightName]) then

      GameTooltip:AddDoubleLine("Times Flown: ", FlightData.ZoneStats[flightName].TimesFlown, 0.8, 0.4, 0, 1, 1, 1);
      GameTooltip:AddDoubleLine("Total Flown Time: ", returnTimeFormatted(FlightData.ZoneStats[flightName].TimeFlying), 0.8, 0.4, 0, 1, 1, 1);            
      GameTooltip:AddDoubleLine("Total Spent: ", GetCoinTextureString(FlightData.ZoneStats[flightName].TotalSpent), 0.8, 0.4, 0, 1, 1, 1);            
            
      local lastTS = date("%d-%m-%y",FlightData.ZoneStats[flightName].LastTimestamp);
      local today = date("%d-%m-%y");

      if (lastTS == today) then

               -- today
         GameTooltip:AddDoubleLine("Last Flown: ", "today at " .. date("%H:%M",FlightData.ZoneStats[flightName].LastTimestamp), 0.8, 0.4, 0, 1, 1, 1);  

      else

         GameTooltip:AddDoubleLine("Last Flown: ", date("%d-%m-%y",FlightData.ZoneStats[flightName].LastTimestamp), 0.8, 0.4, 0, 1, 1, 1);  

      end

   else

      GameTooltip:AddLine("no flight data yet!", 1, 0, 0, 1, true);

   end

   GameTooltip:Show();

   return; 

end -- TaxiNodeOnButtonEnter

--______________________________________________________________________________________________________

hooksecurefunc("TaxiRequestEarlyLanding", function()

   LandingHandler();

end);

hooksecurefunc("AcceptBattlefieldPort", function()

   LandingHandler();

end);

hooksecurefunc("ConfirmSummon", function()

   LandingHandler();

end);