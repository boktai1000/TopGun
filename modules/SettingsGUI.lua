--    FILE: SettingsGUI.lua
--    DATE: 19-10-19
--  AUTHOR: Vitruvius
-- PURPOSE: Create Settings GUI

-- these locals are so i can update these widgets in TOPGUN_SettingsGUI.Update()

local TOPGUN_slider; -- timer width slider
local ShowFlightpathCheck, ShowStatsCheck, ShowPreviousCheck, ShowFlavourCheck, ShowTimerCheck; -- check buttons
local BarTextureDrop, BarFontDrop; -- dropdowns
local TextureColourSwatch, FontColourSwatch; -- colour buttons
local CorrectSwatch; -- hack coz i'm going crazy with this & just want it to work
local SettingsBtn; -- toggle gui button
local media = LibStub("LibSharedMedia-3.0");

-- bar shown when changing settings
local TESTBAR = CreateFrame("StatusBar", nil, UIParent); -- flight timer bar
TESTBAR:SetHeight(22);
TESTBAR:SetWidth(200);
TESTBAR:SetPoint("TOPLEFT",UIParent,"TOPLEFT");
TESTBAR:SetFrameStrata("DIALOG");
TESTBAR:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]]})
TESTBAR:SetBackdropColor(0, 0, 0, 0.7)
TESTBAR:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
TESTBAR:SetStatusBarColor(0, 0.5, 1)
-- BAR TEXT
TESTBAR.ZoneTxt = TESTBAR:CreateFontString(nil,nil,"GameFontWhite");
TESTBAR.ZoneTxt:SetPoint("CENTER",TESTBAR);
TESTBAR.ZoneTxt:SetHeight(20);
TESTBAR.ZoneTxt:SetText("Test Bar");
-- MOVABLE   
TESTBAR:RegisterForDrag("LeftButton")
TESTBAR:EnableMouse(true)
TESTBAR:SetMovable(false);
TESTBAR:SetScript("OnDragStart",TESTBAR.StartMoving)
TESTBAR:SetScript("OnDragStop",TESTBAR.StopMovingOrSizing) 

TESTBAR:Hide();

-- Settings Button
SettingsBtn = CreateFrame("Button",nil,TaxiFrame,"GameMenuButtonTemplate");
SettingsBtn:SetWidth(125);
SettingsBtn:SetHeight(22);
SettingsBtn:SetPoint("TOP",TaxiFrame,0,-44);
-- Setting button text
SettingsBtn.txt = SettingsBtn:CreateFontString(nil,nil,"GameFontNormal");
SettingsBtn.txt:SetPoint("CENTER",SettingsBtn);
SettingsBtn.txt:SetText("TopGun Settings");

SettingsBtn:SetScript("onClick",function(self) 

   TOPGUN_SettingsGUI.Toggle();

end)  

--______________________________________________________________________________________________________

local function TOPGUN_CreateSettingsGUI()

   local frame = CreateFrame("Frame",nil,UIParent,"InsetFrameTemplate");

   -- register for scrolls
   frame:EnableMouse(true);

   -- dimensions
   frame:SetWidth(330);
   frame:SetHeight(360);
   frame:SetPoint("CENTER",0,0); -- will be changed by frame.SetToTaxi()
   frame:SetFrameStrata("HIGH");

   -- check buttons
   ShowFlightpathCheck = CreateFrame("CheckButton", "ShowFlightpathCheck_GlobalName", frame, "ChatConfigCheckButtonTemplate");
   ShowFlightpathCheck:SetPoint("TOPLEFT",15,-15);
   ShowFlightpathCheck_GlobalNameText:SetText(" Show Flight Paths Panel");
   ShowFlightpathCheck.tooltip = "Enable/disable the clickable flightpath panel";
   ShowFlightpathCheck:SetScript("OnClick", 
      function()
         if (ShowFlightpathCheck:GetChecked()) then
            TOPGUN_GlobalData.Settings.ShowFlightList = true;            
            -- check we're not mid-flight & at a flight point before trying to show the flight list
            if not FlightData.IsFlying and not TOPGUN_AdvancedSettingsGUI:IsVisible() then
               TOPGUN_FlightListGUI.SetToTaxi();
            end
         else
            TOPGUN_GlobalData.Settings.ShowFlightList = false;
            TOPGUN_FlightListGUI:Hide();
         end
      end);
   ShowFlightpathCheck:SetChecked(true);

   ShowStatsCheck = CreateFrame("CheckButton", "ShowStatsCheck_GlobalName", frame, "ChatConfigCheckButtonTemplate");
   ShowStatsCheck:SetPoint("TOPLEFT",ShowFlightpathCheck,0,-25);
   ShowStatsCheck_GlobalNameText:SetText(" Show Statistics Panel");
   ShowStatsCheck.tooltip = "Enable/disable the Statistics panel";
   ShowStatsCheck:SetScript("OnClick", 
      function()
         if (ShowStatsCheck:GetChecked()) then
            TOPGUN_GlobalData.Settings.ShowStats = true;
            TOPGUN_StatFrameGUI.SetToTaxi();
         else
            TOPGUN_GlobalData.Settings.ShowStats = false;
            TOPGUN_StatFrameGUI:Hide();
         end
      end);
   ShowStatsCheck:SetChecked(true);

   ShowPreviousCheck = CreateFrame("CheckButton", "ShowPreviousCheck_GlobalName", frame, "ChatConfigCheckButtonTemplate");
   ShowPreviousCheck:SetPoint("TOPLEFT",ShowStatsCheck,0,-25);
   ShowPreviousCheck_GlobalNameText:SetText(" Show Previous Flights Panel");
   ShowPreviousCheck.tooltip = "Enable/disable the previous flights panel";
   ShowPreviousCheck:SetScript("OnClick", 
      function()
         if (ShowPreviousCheck:GetChecked()) then
            TOPGUN_GlobalData.Settings.ShowPrevious = true;
            TOPGUN_PreviousFlightGUI.SetToTaxi();
         else
            TOPGUN_GlobalData.Settings.ShowPrevious = false;
            TOPGUN_PreviousFlightGUI:Hide();
         end
      end);
   ShowPreviousCheck:SetChecked(true);

   ShowFlavourCheck = CreateFrame("CheckButton", "ShowFlavourCheck_GlobalName", frame, "ChatConfigCheckButtonTemplate");
   ShowFlavourCheck:SetPoint("TOPLEFT",ShowPreviousCheck,0,-25);
   ShowFlavourCheck_GlobalNameText:SetText(" Show flavour text");
   ShowFlavourCheck.tooltip = "Enable/disable funky takeoff/landing messages";
   ShowFlavourCheck:SetScript("OnClick", 
      function()
         if (ShowFlavourCheck:GetChecked()) then
            TOPGUN_GlobalData.Settings.ShowFlavour = true;
         else
            TOPGUN_GlobalData.Settings.ShowFlavour = false;
         end
      end);
   ShowFlavourCheck:SetChecked(true);

   ShowTimerCheck = CreateFrame("CheckButton", "ShowTimerCheck_GlobalName", frame, "ChatConfigCheckButtonTemplate");
   ShowTimerCheck:SetPoint("TOPLEFT",ShowFlavourCheck,0,-25);
   ShowTimerCheck_GlobalNameText:SetText(" Show flight timer");
   ShowTimerCheck.tooltip = "Enable/disable flight timer";
   ShowTimerCheck:SetScript("OnClick", 
      function()
         if (ShowTimerCheck:GetChecked()) then
            TOPGUN_GlobalData.Settings.ShowTimer = true;
            if(FlightData.IsFlying and not TOPGUN_FlightTimeFrame:IsVisible())then
               TOPGUN_FlightTimeFrame:Show();
            end
         else
            TOPGUN_GlobalData.Settings.ShowTimer = false;
            if (FlightData.IsFlying) then
               TOPGUN_FlightTimeFrame:Hide();
            end
         end
      end);
   ShowTimerCheck:SetChecked(true);

   -- unlock TESTBAR button
   local UnlockBtn = CreateFrame("Button",nil,frame,"GameMenuButtonTemplate");
   UnlockBtn:SetWidth(140);
   UnlockBtn:SetHeight(22);
   UnlockBtn:SetPoint("TOP",ShowTimerCheck,60,-35);

   -- text
   UnlockBtn.txt = UnlockBtn:CreateFontString(nil,nil,"GameFontNormal");
   UnlockBtn.txt:SetPoint("CENTER",UnlockBtn);
   UnlockBtn.txt:SetText("Unlock timer bar");

   UnlockBtn:SetScript("onClick",function(self) 

      -- check if we're flying or not
      -- if we're flying, adjust the actual FlightTimerBar,
      -- if we're not flying adjust the TESTBAR

      if (FlightData.IsFlying) then

         -- check whether we're locking or unlocking the bar

         local btnTxt = self.txt:GetText();

         if (btnTxt == "Unlock timer bar") then

            -- unlock the bar
 
            TOPGUN_FlightTimeFrame:RegisterForDrag("LeftButton")
            TOPGUN_FlightTimeFrame:EnableMouse(true)
            TOPGUN_FlightTimeFrame:SetMovable(true);

            -- show the bar, just in case they're not showing the learning bar...
            TOPGUN_FlightTimeFrame:Show();

            -- the the update settings on drag stop function

            TOPGUN_FlightTimeFrame:SetScript("OnDragStart",TOPGUN_FlightTimeFrame.StartMoving)
            TOPGUN_FlightTimeFrame:SetScript("OnDragStop",function(self)

               TOPGUN_GlobalData.Settings.TimerX = floor(TOPGUN_FlightTimeFrame:GetLeft());
               TOPGUN_GlobalData.Settings.TimerY = floor(TOPGUN_FlightTimeFrame:GetTop());

               self:StopMovingOrSizing();

            end) 

            -- set the button text
            self.txt:SetText("Lock timer bar");

         else

            -- lock the bar!
            TOPGUN_FlightTimeFrame:SetMovable(false);
            TOPGUN_FlightTimeFrame:EnableMouse(false);

            -- set the button txt to unlock
            self.txt:SetText("Unlock timer bar");

         end

      else 

         if (TESTBAR:IsVisible()) then

            TESTBAR:Hide();
            self.txt:SetText("Unlock timer bar");
            -- update any changes to the bar position
            self:SetMovable(false);
            TOPGUN_GlobalData.Settings.TimerX = floor(TESTBAR:GetLeft());
            TOPGUN_GlobalData.Settings.TimerY = floor(TESTBAR:GetTop()); 

         else 

            TESTBAR:ClearAllPoints();
            TESTBAR:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",TOPGUN_GlobalData.Settings.TimerX,TOPGUN_GlobalData.Settings.TimerY);
            TESTBAR:Show();
            TESTBAR:SetMovable(true);
            TESTBAR:SetStatusBarTexture(TOPGUN_GlobalData.Settings.TimerTexture);
            TESTBAR:SetStatusBarColor(TOPGUN_GlobalData.Settings.TimerColour.r,TOPGUN_GlobalData.Settings.TimerColour.g,TOPGUN_GlobalData.Settings.TimerColour.b,TOPGUN_GlobalData.Settings.TimerColour.a)
         
            -- set bar font & colour
            if TOPGUN_GlobalData.Settings.TimerFont ~= "default" then
         
               local _,size,flags = TESTBAR.ZoneTxt:GetFont();

               TESTBAR.ZoneTxt:SetFont(TOPGUN_GlobalData.Settings.TimerFont,size,flags);
               TESTBAR.ZoneTxt:SetTextColor(TOPGUN_GlobalData.Settings.TimerFontColour.r,TOPGUN_GlobalData.Settings.TimerFontColour.g,TOPGUN_GlobalData.Settings.TimerFontColour.b,TOPGUN_GlobalData.Settings.TimerFontColour.a);
               TESTBAR.ZoneTxt:SetText(" ");
               TESTBAR.ZoneTxt:SetText("Test Bar");
            end

            self.txt:SetText("Lock timer bar");
            TESTBAR:SetScript("OnHide",function()

               -- update settings to current bar position
               TOPGUN_GlobalData.Settings.TimerX = floor(TESTBAR:GetLeft());
               TOPGUN_GlobalData.Settings.TimerY = floor(TESTBAR:GetTop());
            end)

         end -- if TESTBAR isVisible

      end -- if FLYING

   end) 

   -- slider heading txt
   frame.BarWidthTxt = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.BarWidthTxt:SetPoint("TOPLEFT",UnlockBtn,"TOPLEFT",0,-35);
   frame.BarWidthTxt:SetText("Timer Width");

   -- slider
   local name = "TOPGUN_WidthSlider"
   local template = "OptionsSliderTemplate"
   TOPGUN_slider = CreateFrame("Slider",name,frame,template) --frameType, frameName, frameParent, frameTemplate   
   TOPGUN_slider:SetPoint("TOPLEFT",frame.BarWidthTxt,0,-20);
   TOPGUN_slider.textLow = _G[name.."Low"]
   TOPGUN_slider.textHigh = _G[name.."High"]
   TOPGUN_slider.text = _G[name.."Text"]
   TOPGUN_slider:SetMinMaxValues(100, GetScreenWidth());
   TOPGUN_slider.minValue, TOPGUN_slider.maxValue = TOPGUN_slider:GetMinMaxValues() 
   TOPGUN_slider.textLow:SetText("min");
   TOPGUN_slider.textHigh:SetText("max");
   TOPGUN_slider:SetValue(50); -- will be changed to settings width
   TOPGUN_slider:SetValueStep(1)
   TOPGUN_slider:SetScript("OnValueChanged", function(self,event,arg1) 

      TOPGUN_GlobalData.Settings.TimerWidth = floor(event);
      TESTBAR:SetWidth(TOPGUN_GlobalData.Settings.TimerWidth);
      TOPGUN_FlightTimeFrame:SetWidth(TOPGUN_GlobalData.Settings.TimerWidth);

   end)

   -- dropdowns

   --$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

   local numOfTextureBtns = 0; -- our hack to count how many texture buttons we create with libSharedMedia

   -- dropdown texture heading txt
   frame.BarTextureTxt = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.BarTextureTxt:SetPoint("TOPLEFT",frame.BarWidthTxt,"TOPLEFT",0,-55);
   frame.BarTextureTxt:SetText("Timer Texture");

   if not BarTextureDrop then
      BarTextureDrop = CreateFrame("Frame","TOPGUN_BarTextureDrop",frame, "UIDropDownMenuTemplate")
   end

   BarTextureDrop:ClearAllPoints()
   BarTextureDrop:SetPoint("TOPLEFT",TOPGUN_slider,"TOPLEFT",-20,-55)
   BarTextureDrop:Show()

   local items = media:HashTable("statusbar");

   local function TextureOnClick(self,arg1)

      local textureName = arg1; -- so we can show the selected choice on updat

      UIDropDownMenu_SetSelectedID(BarTextureDrop, self:GetID())
      TOPGUN_GlobalData.Settings.TimerTextureName = textureName;

      -- set the new texture
      TOPGUN_GlobalData.Settings.TimerTexture = self.value;
      TESTBAR:SetStatusBarTexture(TOPGUN_GlobalData.Settings.TimerTexture);
      TOPGUN_FlightTimeFrame:SetStatusBarTexture(TOPGUN_GlobalData.Settings.TimerTexture);      

   end -- TextureOnClick()

   local function initialize(self, level)

      local info = UIDropDownMenu_CreateInfo()

      numOfTextureBtns = 0; -- reset our counter!

      for k,v in pairs(items) do

         numOfTextureBtns = numOfTextureBtns + 1; -- our counter

         -- set button info
         info = UIDropDownMenu_CreateInfo()
         info.text = k
         info.value = v
         info.arg1 = k
         info.arg2 = "texture"
         info.func = TextureOnClick
         UIDropDownMenu_AddButton(info, level)

      end -- FOR

   end -- initialize()

   UIDropDownMenu_Initialize(BarTextureDrop, initialize)
   UIDropDownMenu_SetWidth(BarTextureDrop, 100);
   UIDropDownMenu_SetButtonWidth(BarTextureDrop, 124)
   UIDropDownMenu_SetSelectedID(BarTextureDrop, 1)
   UIDropDownMenu_JustifyText(BarTextureDrop, "LEFT")

   --$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

   -- dropdown font heading txt
   frame.BarFontTxt = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.BarFontTxt:SetPoint("LEFT",frame.BarTextureTxt,"RIGHT",75,0);
   frame.BarFontTxt:SetText("Timer Font");

   if not BarFontDrop then
      BarFontDrop = CreateFrame("Frame","TOPGUN_BarFontDrop",frame, "UIDropDownMenuTemplate")
   end
 
   BarFontDrop:ClearAllPoints()
   BarFontDrop:SetPoint("TOPLEFT",frame.BarFontTxt,"TOPLEFT",-20,-20)
   BarFontDrop:Show()

   local fonts = media:HashTable("font");

   local function FontOnClick(self,arg1)

      local fontName = arg1; -- so we can show the selected choice on updat

      UIDropDownMenu_SetSelectedID(BarFontDrop, self:GetID())
      TOPGUN_GlobalData.Settings.TimerFontName = fontName;

      -- set the new font
      local font,size,flags = TESTBAR.ZoneTxt:GetFont();

      TOPGUN_GlobalData.Settings.TimerFont = self.value;
      TESTBAR.ZoneTxt:SetFont(self.value,size,flags);
      TESTBAR.ZoneTxt:SetText(" ");
      TESTBAR.ZoneTxt:SetText("Test Bar");

      -- set font on real bar
      local toTxt = TOPGUN_FlightTimeFrame.ZoneTxt:GetText();
      local timeTxt = TOPGUN_FlightTimeFrame.txt:GetText();

      TOPGUN_FlightTimeFrame.ZoneTxt:SetFont(self.value,size,flags);
      TOPGUN_FlightTimeFrame.txt:SetFont(self.value,size,flags);      
      TOPGUN_FlightTimeFrame.LearningTxt:SetFont(self.value,size,flags);

      TOPGUN_FlightTimeFrame.ZoneTxt:SetText(" ");
      TOPGUN_FlightTimeFrame.txt:SetText(" ");
      TOPGUN_FlightTimeFrame.LearningTxt:SetText(" ");
   
      TOPGUN_FlightTimeFrame.ZoneTxt:SetText(toTxt);
      TOPGUN_FlightTimeFrame.txt:SetText(timeTxt);
      TOPGUN_FlightTimeFrame.LearningTxt:SetText("Learning Flight");

      TOPGUN_BarFontDropText:SetFont(TOPGUN_GlobalData.Settings.TimerFont,10)

   end -- TextureOnClick()

   local function initialize2(self, level)
      
      local info = UIDropDownMenu_CreateInfo()

      for k,v in pairs(fonts) do

         -- create the custom font
         local newFont = CreateFont("TopGunFont"..k)
         newFont:SetFont(v,10);

         -- set button info
         info = UIDropDownMenu_CreateInfo()
         info.text = k
         info.value = v
         info.arg1 = k
         info.arg2 = v         
         info.func = FontOnClick
         info.fontObject = newFont;
         UIDropDownMenu_AddButton(info, level)

      end -- FOR

   end -- initialize()

   UIDropDownMenu_Initialize(BarFontDrop, initialize2)
   UIDropDownMenu_SetWidth(BarFontDrop, 100);
   UIDropDownMenu_SetButtonWidth(BarFontDrop, 124)
   UIDropDownMenu_SetSelectedID(BarFontDrop, 1)
   UIDropDownMenu_JustifyText(BarFontDrop, "LEFT")

   -- my magic solution to show the bar textures... hook when they actually click each dropdown
   -- and show/hide the texture/font accordingly! Took me forever to figure it out

   TOPGUN_BarFontDropButton:HookScript("OnClick",function(self,...)

      -- hide the dropdown textures

      for i = 1,numOfTextureBtns,1 do

         local btnName = "DropDownList1Button"..i;

         local btn = _G[btnName];

         if btn.tex then

            btn.tex:Hide();

         end

      end -- for (hide btn textures)

   end)

   TOPGUN_BarTextureDropButton:HookScript("OnClick",function(self,...)

      -- set the dropdown button textures

      for i = 1,numOfTextureBtns,1 do

         local btnName = "DropDownList1Button"..i;

         local btn = _G[btnName];

         if not btn.tex then

            btn.tex = btn:CreateTexture(nil, "BACKGROUND")
            btn.tex:SetAllPoints()
            btn.tex:SetTexture(btn.value);

         else

            btn.tex:Show();

         end

      end -- for (create btn textures)

   end)

   TOPGUN_BarTextureDropButton:HookScript("OnHide",function(self,...)

      -- hide the dropdown button textures!
      -- if you don't, they'll be shown on every right-click menu!

      for i = 1,numOfTextureBtns,1 do

         local btnName = "DropDownList1Button"..i;

         local btn = _G[btnName];

         if btn.tex then

            btn.tex:Hide();

         end

      end -- for (create btn textures)

   end)

   --$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

   -- colour pickers!

   local function UpdateTextureColour(color)

      if (CorrectSwatch ~= "texture") then
         -- don't change the wrong swatch!
         return;
      end

      local r,g,b,a
      if color then
         r,g,b,a = unpack(color)
      else
         r,g,b = ColorPickerFrame:GetColorRGB()
         a = OpacitySliderFrame:GetValue()
      end

      TOPGUN_GlobalData.Settings.TimerColour.r = r;
      TOPGUN_GlobalData.Settings.TimerColour.g = g;
      TOPGUN_GlobalData.Settings.TimerColour.b = b;
      TOPGUN_GlobalData.Settings.TimerColour.a = a;
      -- update the swatch
      TextureColourSwatch.tex:SetColorTexture(r,g,b,a);
      -- update the testbar
      TESTBAR:SetStatusBarColor(r,g,b,a)
      TOPGUN_FlightTimeFrame:SetStatusBarColor(r,g,b,a);

   end -- UpdateTextureColour()

   -- timer colour picker txt
   frame.BarColourTxt = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.BarColourTxt:SetPoint("TOPLEFT",frame.BarTextureTxt,"TOPLEFT",0,-60);
   frame.BarColourTxt:SetText("Timer Colour");

   -- timer colour picker swatch
   TextureColourSwatch = CreateFrame("Frame",nil,frame);
   TextureColourSwatch:SetSize(20,20)
   TextureColourSwatch:SetPoint("BOTTOMLEFT",20,15)

   TextureColourSwatch.tex = TextureColourSwatch:CreateTexture(nil, "BACKGROUND")
   TextureColourSwatch.tex:SetAllPoints()
   TextureColourSwatch.tex:SetColorTexture(1,1,1);

   TextureColourSwatch:EnableMouse(true)
   TextureColourSwatch:SetScript("OnMouseDown", function(self,button,...)
      if button == "LeftButton" then

         CorrectSwatch = "texture"; -- our hack to make sure we're changing the right swatch

         local r = TOPGUN_GlobalData.Settings.TimerColour.r;
         local g = TOPGUN_GlobalData.Settings.TimerColour.g;
         local b = TOPGUN_GlobalData.Settings.TimerColour.b;
         local a = TOPGUN_GlobalData.Settings.TimerColour.a;

         -- show the colour picker
         ColorPickerFrame:SetColorRGB(r,g,b)
         ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a
         ColorPickerFrame.previousValues = {r,g,b,a}
         ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = UpdateTextureColour, UpdateTextureColour, UpdateTextureColour;
         ColorPickerFrame:Hide() -- Need to run the OnShow handler.
         ColorPickerFrame:Show()

      end
   end)

   -- font colour picker txt
   frame.FontColourTxt = frame:CreateFontString(nil,nil,"GameFontNormal");
   frame.FontColourTxt:SetPoint("LEFT",frame.BarColourTxt,"RIGHT",80,0);
   frame.FontColourTxt:SetText("Font Colour");

   local function UpdateFontColour(color)

      if (CorrectSwatch ~= "font") then
         -- don't change the wrong swatch!
         return;
      end

      local r,g,b,a
      if color then
         r,g,b,a = unpack(color)
      else
         r,g,b = ColorPickerFrame:GetColorRGB()
         a = OpacitySliderFrame:GetValue()
      end

      TOPGUN_GlobalData.Settings.TimerFontColour.r = r;
      TOPGUN_GlobalData.Settings.TimerFontColour.g = g;
      TOPGUN_GlobalData.Settings.TimerFontColour.b = b;
      TOPGUN_GlobalData.Settings.TimerFontColour.a = a;
      -- update the swatch
      FontColourSwatch.tex:SetColorTexture(r,g,b,a);
      -- update the testbar font
      TESTBAR.ZoneTxt:SetTextColor(TOPGUN_GlobalData.Settings.TimerFontColour.r,TOPGUN_GlobalData.Settings.TimerFontColour.g,TOPGUN_GlobalData.Settings.TimerFontColour.b,TOPGUN_GlobalData.Settings.TimerFontColour.a)
      TOPGUN_FlightTimeFrame.ZoneTxt:SetTextColor(TOPGUN_GlobalData.Settings.TimerFontColour.r,TOPGUN_GlobalData.Settings.TimerFontColour.g,TOPGUN_GlobalData.Settings.TimerFontColour.b,TOPGUN_GlobalData.Settings.TimerFontColour.a)
      TOPGUN_FlightTimeFrame.txt:SetTextColor(TOPGUN_GlobalData.Settings.TimerFontColour.r,TOPGUN_GlobalData.Settings.TimerFontColour.g,TOPGUN_GlobalData.Settings.TimerFontColour.b,TOPGUN_GlobalData.Settings.TimerFontColour.a)

   end -- UpdateFontColour()

   -- timer colour picker swatch
   FontColourSwatch = CreateFrame("Frame",nil,frame);
   FontColourSwatch:SetSize(20,20)
   FontColourSwatch:SetPoint("BOTTOMRIGHT",-135,15)

   FontColourSwatch.tex = FontColourSwatch:CreateTexture(nil, "BACKGROUND")
   FontColourSwatch.tex:SetAllPoints()
   FontColourSwatch.tex:SetColorTexture(1,1,1);

   FontColourSwatch:EnableMouse(true)
   FontColourSwatch:SetScript("OnMouseDown", function(self,button,...)
      if button == "LeftButton" then

         CorrectSwatch = "font"; -- our hack to make sure we're changing the right swatch

         local r = TOPGUN_GlobalData.Settings.TimerFontColour.r;
         local g = TOPGUN_GlobalData.Settings.TimerFontColour.g;
         local b = TOPGUN_GlobalData.Settings.TimerFontColour.b;
         local a = TOPGUN_GlobalData.Settings.TimerFontColour.a;

         -- show the colour picker
         ColorPickerFrame:SetColorRGB(r,g,b)
         ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a
         ColorPickerFrame.previousValues = {r,g,b,a}
         ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = UpdateFontColour, UpdateFontColour, UpdateFontColour;
         ColorPickerFrame:Hide() -- Need to run the OnShow handler.
         ColorPickerFrame:Show()

      end
   end)
   --______________________________________________________________

   frame.Toggle = function(self)
     if (frame:IsVisible()) then
       frame:Hide();
     else
       frame:SetToTaxi();
       frame:Update(frame);
       TOPGUN_BarFontDropText:SetFont(TOPGUN_GlobalData.Settings.TimerFont,10)
       frame:Show();
     end
   end
   --______________________________________________________________

   frame.SetToTaxi = function(self)

      frame:ClearAllPoints();
      frame:SetPoint("BOTTOMRIGHT",TaxiFrame,"BOTTOMRIGHT",-38,80);
   end
   --______________________________________________________________

   frame:SetScript("OnHide", 
     function(self)
        UnlockBtn.txt:SetText("Unlock timer bar");
        TESTBAR:Hide();
        -- lock the real bar
        TOPGUN_FlightTimeFrame:SetMovable(false);
        TOPGUN_FlightTimeFrame:EnableMouse(false); 
     end
   )
   --______________________________________________________________

   frame:Hide();

   return frame;

end -- TOPGUN_CreateSettingsGUI() 

--______________________________________________________________________________________________________

TOPGUN_SettingsGUI = TOPGUN_CreateSettingsGUI();

--______________________________________________________________________________________________________

TOPGUN_SettingsGUI.Update = function(self)
	
   -- set TOPGUN_slider value
   TOPGUN_slider:SetValue(TOPGUN_GlobalData.Settings.TimerWidth); 
   -- set the checkboxes
   ShowFlightpathCheck:SetChecked(TOPGUN_GlobalData.Settings.ShowFlightList);
   ShowStatsCheck:SetChecked(TOPGUN_GlobalData.Settings.ShowStats);
   ShowPreviousCheck:SetChecked(TOPGUN_GlobalData.Settings.ShowPrevious);
   ShowFlavourCheck:SetChecked(TOPGUN_GlobalData.Settings.ShowFlavour);
   ShowTimerCheck:SetChecked(TOPGUN_GlobalData.Settings.ShowTimer);
   -- texture dropdown
   UIDropDownMenu_SetSelectedName(TOPGUN_BarTextureDrop, TOPGUN_GlobalData.Settings.TimerTextureName);
   UIDropDownMenu_SetText(TOPGUN_BarTextureDrop, TOPGUN_GlobalData.Settings.TimerTextureName);
   -- font dropdown
   UIDropDownMenu_SetSelectedName(TOPGUN_BarFontDrop, TOPGUN_GlobalData.Settings.TimerFontName);
   UIDropDownMenu_SetText(TOPGUN_BarFontDrop, TOPGUN_GlobalData.Settings.TimerFontName);
   -- colour swatches
   TextureColourSwatch.tex:SetColorTexture(TOPGUN_GlobalData.Settings.TimerColour.r,TOPGUN_GlobalData.Settings.TimerColour.g,TOPGUN_GlobalData.Settings.TimerColour.b,TOPGUN_GlobalData.Settings.TimerColour.a);
   FontColourSwatch.tex:SetColorTexture(TOPGUN_GlobalData.Settings.TimerFontColour.r,TOPGUN_GlobalData.Settings.TimerFontColour.g,TOPGUN_GlobalData.Settings.TimerFontColour.b,TOPGUN_GlobalData.Settings.TimerFontColour.a);

end -- .Update()

--______________________________________________________________________________________________________