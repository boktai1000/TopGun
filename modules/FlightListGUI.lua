--    FILE: FlightListGUI.lua
--    DATE: 19-10-19
--  AUTHOR: Vitruvius
-- PURPOSE: Create List of Flight Paths

local Flights = {}; -- the list of available flights, filled on Update

--______________________________________________________________________________________________________

local function TOPGUN_CreateFlightListGUI() 

   local frame = CreateFrame("Frame",nil,UIParent,"BasicFrameTemplateWithInset");

   -- register for scrolls
   frame:EnableMouse(true);

   -- dimensions
   frame:SetWidth(TOPGUN_FlightListWidth);
   frame:SetHeight(424); -- correct height
   frame:SetPoint("CENTER",0,0);
   frame:SetFrameStrata("MEDIUM");

   -- heading
   frame.Heading = frame:CreateFontString(nil,nil,"GameFontNormalSmall");
   frame.Heading:SetPoint("TOP",frame,"TOP",0,-6);
   frame.Heading:SetText("Flight Paths");

   --scrollframe 
   scrollframe = CreateFrame("ScrollFrame", "TGScrollFrame", frame); 
   scrollframe:SetPoint("TOPLEFT", 10, -30) ;
   scrollframe:SetPoint("BOTTOMRIGHT", -10, 10);

   --scrollbar 
   scrollbar = CreateFrame("Slider", "TGScrollBar", scrollframe, "UIPanelScrollBarTemplate") 
   scrollbar:SetPoint("TOPLEFT", scrollframe, "TOPRIGHT", 4, -16) 
   scrollbar:SetPoint("BOTTOMLEFT", scrollframe, "BOTTOMRIGHT", 4, 16) 
   scrollbar:SetMinMaxValues(1, 100) 
   scrollbar:SetValueStep(1) 
   scrollbar.scrollStep = 1 
   scrollbar:SetValue(0) 
   scrollbar:SetWidth(16) 
   scrollbar:SetScript("OnValueChanged", 
   function (self, value) 
   self:GetParent():SetVerticalScroll(value) 
   end) 
   local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
   scrollbg:SetAllPoints(scrollbar) 
   scrollbg:SetTexture(0, 0, 0, 0.4) 
   scrollframe.ScrollBar = scrollbar; 

   -- Mousewheel scrollable

   scrollframe:SetScript("OnMouseWheel", function(self, delta)

      -- hack to point to the right object

      local scrollBar = TGScrollBar;

      local cur_val = scrollBar:GetValue()
      local min_val, max_val = scrollBar:GetMinMaxValues()

      if delta < 0 and cur_val < max_val then
         cur_val = math.min(max_val, cur_val + 5)
         scrollBar:SetValue(cur_val)
      elseif delta > 0 and cur_val > min_val then
         cur_val = math.max(min_val, cur_val - 5)
         scrollBar:SetValue(cur_val)
      end
   end)

   frame.ScrollFrame = scrollframe;

   -- holder frame, actually holds the content
   local content = CreateFrame("Frame",nil,frame.ScrollFrame);

   content:SetSize(128, 128) ;

   -- add content to main window

   scrollframe.Content = content; 

   scrollframe:SetScrollChild(content);

   -- hide the scrollbar?

   scrollbar:Hide();

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

   frame.Clear = function(self)
      if (frame.ScrollFrame.Content) then
         frame.ScrollFrame.Content:Hide();
         frame.ScrollFrame.Content = nil;
      end   
   end

   --______________________________________________________________

   frame.SetToTaxi = function(self)

      -- show the flight list

      frame.Toggle();
      frame:ClearAllPoints();
      frame:SetPoint("TOPLEFT",TaxiFrame,"TOPRIGHT",-34,-12);

   end

   --______________________________________________________________

   frame:SetScript("OnHide", 
     function(self)
       self:Clear();
     end
   )

   --______________________________________________________________

   -- hide the frame to start with

   frame:Hide();

   return frame;

end -- TOPGUN_CreateGUI()

--______________________________________________________________________________________________________

TOPGUN_FlightListGUI = TOPGUN_CreateFlightListGUI();

--______________________________________________________________________________________________________

TOPGUN_FlightListGUI.Update = function(frame)

   -- restart our available flight list

   Flights = {};

   -- holder frame, actually holds the content

   local content = CreateFrame("Frame",nil,frame.ScrollFrame);
   content:SetSize(frame.ScrollFrame:GetWidth(),frame.ScrollFrame:GetHeight());
   content:SetAllPoints();

   -- how many flight points are available

   local numNodes = NumTaxiNodes();

   -- loop over all the nodes, creating our list of available flights to sort

   for i = 1,NumTaxiNodes(),1 do Flights[TaxiNodeName(i)] = i end;

   -- sort the list alphabetically

   local sortedFlights = {};
   for n in pairs(Flights) do table.insert(sortedFlights, n) end;
   table.sort(sortedFlights);
   
   -- loop thru our list, creating a box for each

   for i,flightName in ipairs(sortedFlights) do 

      local flightID = Flights[flightName]; -- the correct node number for TakeTaxi(node) 

      local nodeType = TaxiNodeGetType(flightID); -- "CURRENT","REACHABLE","UNREACHABLE" 

      -- create the individual box

      content.box = CreateFrame("Button",nil,content);
      content.box:SetWidth(content:GetWidth()-2);
      content.box:SetHeight(25);
      -- the box's vertical position in the list
      local newH = content.box:GetHeight();
      content.box:SetPoint("TOPLEFT",content,"TOPLEFT",0,-((i - 1) * newH));

      content.box.nodeType = nodeType;
      content.box:SetID(flightID); -- for tooltip

      -- background     
      content.box:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
      content.box:SetBackdropColor(0,0,0,0.8);

      -- text
      content.box.txt = content.box:CreateFontString(nil,nil,"GameFontWhiteSmall");
      content.box.txt:SetPoint("LEFT",content.box,"LEFT",6,0);
      content.box.txt:SetJustifyH("LEFT");
      content.box.txt:SetWidth(content.box:GetWidth() - 10);
      content.box.txt:SetHeight(10);
      content.box.txt:SetText(flightName);

      content.box:SetScript("onEnter",function(self) 

         GetNumRoutes(self.flightNodeNum); -- so the cost calculates correctly

         -- draw the flight path!
         TaxiNodeOnButtonEnter(_G["TaxiButton"..self.flightNodeNum]);

         -- check it's not the current location 
         -- if it's not, mouseover effect

         if (self.nodeType == "REACHABLE") then

            self:SetBackdropColor(1,0.8,0,1);
         end

         -- draw the tooltip
         TaxiNodeOnButtonEnter(self); 
         GameTooltip:Show();
         
      end)

      content.box:SetScript("onLeave",function(self) 

         if (self.nodeType == "REACHABLE") then

            self:SetBackdropColor(0,0,0,0.8);

         end

         GameTooltip:Hide();            

      end)

      if (nodeType == "REACHABLE") then

         content.box:SetScript("onClick",function(self) 

            -- for some reason this fixes the multiple flight hop problem...

            GetNumRoutes(self.flightNodeNum);

            -- take flight

            TakeTaxiNode(self.flightNodeNum);

         end)

      end -- REACHABLE

      if (nodeType == "CURRENT") then

         -- this button won't be clickable etc

         content.box:SetBackdropColor(0,1,0,1);

      end -- CURRENT

      -- which node this corresponds to

      content.box.flightNodeNum = flightID;

   end -- for

   -- check whether we need to scroll or not

   local maxHeight = scrollframe:GetHeight();
   local testHeight = numNodes * 25;
   if testHeight > maxHeight then
      local difference = testHeight - maxHeight;
      scrollframe.ScrollBar:SetMinMaxValues(1, difference);
   else
      scrollframe.ScrollBar:SetMinMaxValues(0, 0); -- no need to scroll    
   end

   -- add content to main window

   scrollframe.Content = content; 

   scrollframe:SetScrollChild(content);

end -- .Update()

--______________________________________________________________________________________________________







