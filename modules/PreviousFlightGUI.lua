--    FILE: PreviousFlightGUI.lua
--    DATE: 19-10-19
--  AUTHOR: Vitruvius
-- PURPOSE: Create Previous Flight GUI

local ForwardBtn;
local BackBtn;
local UpdatePreviousFlightFrame;
local CurrentFlight = 1;

--______________________________________________________________________________________________________

local function TOPGUN_CreatePreviousFlightGUI() 

   local frame = CreateFrame("Frame",nil,UIParent,"BasicFrameTemplateWithInset");

   -- register for scrolls
   frame:EnableMouse(true);

   -- dimensions
   frame:SetWidth(TOPGUN_FlightListWidth);
   frame:SetHeight(150); -- correct height
   frame:SetPoint("CENTER",0,0);
   frame:SetFrameStrata("MEDIUM");

   -- heading
   frame.Heading = frame:CreateFontString(nil,nil,"GameFontNormalSmall");
   frame.Heading:SetPoint("TOP",frame,"TOP",0,-6);
   frame.Heading:SetText("Previous Flights");

   -- back Button
   frame.BackBtn = CreateFrame("Button",nil,frame,"GameMenuButtonTemplate");
   frame.BackBtn:SetWidth(20);
   frame.BackBtn:SetHeight(20);
   frame.BackBtn:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-32,10);

   -- text
   frame.BackBtn.txt = frame.BackBtn:CreateFontString(nil,nil,"GameFontNormal");
   frame.BackBtn.txt:SetPoint("CENTER",frame.BackBtn);
   frame.BackBtn.txt:SetText("<");

   frame.BackBtn:SetScript("onClick",function(self) 

      CurrentFlight = CurrentFlight - 1;
      TOPGUN_PreviousFlightGUI.Update(frame);

   end)  

   -- forward Button
   frame.ForwardBtn = CreateFrame("Button",nil,frame,"GameMenuButtonTemplate");
   frame.ForwardBtn:SetWidth(20);
   frame.ForwardBtn:SetHeight(20);
   frame.ForwardBtn:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-12,10);

   -- text
   frame.ForwardBtn.txt = frame.ForwardBtn:CreateFontString(nil,nil,"GameFontNormal");
   frame.ForwardBtn.txt:SetPoint("CENTER",frame.ForwardBtn,1,0);
   frame.ForwardBtn.txt:SetText(">");

   frame.ForwardBtn:SetScript("onClick",function(self) 

      CurrentFlight = CurrentFlight + 1;
      TOPGUN_PreviousFlightGUI.Update(frame);

   end) 

   -- flight from lbl
   frame.FlightFromLbl = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.FlightFromLbl:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-35);
   frame.FlightFromLbl:SetText("From: ");

   -- flight from txt
   frame.FlightFromTxt = frame:CreateFontString(nil,nil,"GameFontWhiteSmall");
   frame.FlightFromTxt:SetPoint("LEFT",frame.FlightFromLbl,"RIGHT",0,0);
   frame.FlightFromTxt:SetWidth(frame:GetWidth() - 70)
   frame.FlightFromTxt:SetHeight(15);
   frame.FlightFromTxt:SetJustifyH("LEFT");   
   frame.FlightFromTxt:SetText("none");

   -- flight to lbl
   frame.FlightToLbl = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.FlightToLbl:SetPoint("TOPLEFT",frame.FlightFromLbl,"TOPLEFT",0,-20);
   frame.FlightToLbl:SetText("To: ");

   -- flight to txt
   frame.FlightToTxt = frame:CreateFontString(nil,nil,"GameFontWhiteSmall");
   frame.FlightToTxt:SetPoint("LEFT",frame.FlightToLbl,"RIGHT",0,0);
   frame.FlightToTxt:SetWidth(frame:GetWidth() - 50)
   frame.FlightToTxt:SetHeight(15);
   frame.FlightToTxt:SetJustifyH("LEFT");
   frame.FlightToTxt:SetText("none");

   -- departed lbl
   frame.DepartedLbl = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.DepartedLbl:SetPoint("TOPLEFT",frame.FlightToLbl,"TOPLEFT",0,-20);
   frame.DepartedLbl:SetText("Departed: ");

   -- departed txt
   frame.DepartedTxt = frame:CreateFontString(nil,nil,"GameFontWhiteSmall");
   frame.DepartedTxt:SetPoint("LEFT",frame.DepartedLbl,"RIGHT",0,0);
   frame.DepartedTxt:SetText("0");

   -- arrived lbl
   frame.ArrivedLbl = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.ArrivedLbl:SetPoint("TOPLEFT",frame.DepartedLbl,"TOPLEFT",0,-20);
   frame.ArrivedLbl:SetText("Arrived: ");

   -- arrived txt
   frame.ArrivedTxt = frame:CreateFontString(nil,nil,"GameFontWhiteSmall");
   frame.ArrivedTxt:SetPoint("LEFT",frame.ArrivedLbl,"RIGHT",0,0);
   frame.ArrivedTxt:SetText("0 (0s)");

   -- cost lbl
   frame.CostLbl = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.CostLbl:SetPoint("TOPLEFT",frame.ArrivedLbl,"TOPLEFT",0,-20);
   frame.CostLbl:SetText("Cost: ");

   -- cost txt
   frame.CostTxt = frame:CreateFontString(nil,nil,"GameFontWhiteSmall");
   frame.CostTxt:SetPoint("LEFT",frame.CostLbl,"RIGHT",0,0);
   frame.CostTxt:SetText(GetCoinTextureString(0));

   --______________________________________________________________

   frame.Toggle = function(self)
     if (frame:IsVisible()) then
       frame:Hide();
     else
       CurrentFlight = FlightData.TotalFlights;
       frame:Update(frame);
       frame:Show();
     end
   end

   --______________________________________________________________

   frame.SetToTaxi = function(self)

      -- show the flight list

      frame.Toggle();
      frame:ClearAllPoints();
      frame:SetPoint("TOPLEFT",TaxiFrame,"BOTTOMRIGHT",-33,75);
   end

   --______________________________________________________________

   frame.SetToStandalone = function(self)

      -- show the flight list

      frame.Toggle();
      frame:ClearAllPoints();
      frame:SetPoint("TOPLEFT",TOPGUN_StandaloneGUI,"BOTTOMRIGHT",-3,0);

   end

   --______________________________________________________________

   frame:Hide();

   return frame;

end -- TOPGUN_CreatePreviousFlightGUI()

--______________________________________________________________________________________________________

TOPGUN_PreviousFlightGUI = TOPGUN_CreatePreviousFlightGUI();

--______________________________________________________________________________________________________

TOPGUN_PreviousFlightGUI.Update = function(self)

   --check if there's a previous flight

   if (FlightData.TotalFlights > 0) then

      -- get the flight data

      local lastFlight = FlightData.Flights[CurrentFlight];

      local startTimestamp = lastFlight[1];
      local startZone = lastFlight[2];
      local cost = lastFlight[3];
      local endZone = lastFlight[4];
      local endTimestamp = lastFlight[5];
      local flightTime = endTimestamp - startTimestamp;

      -- now fill it!
      self.Heading:SetText("Previous Flights (" .. CurrentFlight .. "/" .. FlightData.TotalFlights ..")")

      if startZone then self.FlightFromTxt:SetText(startZone) end
      if endZone then self.FlightToTxt:SetText(endZone) end
      if startTimestamp then self.DepartedTxt:SetText(date("%H:%M",startTimestamp)) end

      -- bugfix in case we didn't get the flight landing info, like they reloaded ui mid-flight or somethin
      local bugTime = date(" (%Mm %Ss)",flightTime) or 0;

      if (bugTime == 0) then
         self.ArrivedTxt:SetText("Ummm...");
      else 
         self.ArrivedTxt:SetText(date("%H:%M",endTimestamp)..bugTime);
      end

      if cost then self.CostTxt:SetText(GetCoinTextureString(cost)) end

      -- check if we need to grey out a button
      if (CurrentFlight == 1) then
         self.BackBtn:SetEnabled(false);
      else 
         self.BackBtn:SetEnabled(true);
      end

      if (CurrentFlight == FlightData.TotalFlights) then
         self.ForwardBtn:SetEnabled(false);
      else 
         self.ForwardBtn:SetEnabled(true);
      end

   else

      -- create blank entries
      self.Heading:SetText("Previous Flights 0/0")
      self.FlightFromTxt:SetText("none")
      self.FlightToTxt:SetText("none")
      self.DepartedTxt:SetText("0:00")
      self.ArrivedTxt:SetText("0:00");
      self.CostTxt:SetText(GetCoinTextureString(0))
      self.ForwardBtn:SetEnabled(false);
      self.BackBtn:SetEnabled(false);

   end

end -- .Update()

--______________________________________________________________________________________________________