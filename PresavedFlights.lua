--    FILE: PresavedFlights.lua
--    DATE: 29-10-19
--  AUTHOR: Vitruvius
-- PURPOSE: Load some pre-set flight times into TOPGUN_GlobalData.FlightTimes

local PreloadFrame = CreateFrame("Frame",nil,UIParent); -- for events

local PresavedData = {};

PresavedData.Alliance = {
		
		["Southshore, Hillsbrad"] = {
			["Menethil Harbor, Wetlands"] = 111,		
			["Ironforge, Dun Morogh"] = 206,
			["Stormwind, Elwynn"] = 367,
		},
		["Sentinel Hill, Westfall"] = {
			["Thorium Point, Searing Gorge"] = 362,
			["Ironforge, Dun Morogh"] = 330,
			["Stormwind, Elwynn"] = 86,
		},
		["Theramore, Dustwallow Marsh"] = {
			["Rut'theran Village, Teldrassil"] = 700,		
			["Gadgetzan, Tanaris"] = 156,
			["Talonbranch Glade, Felwood"] = 806,
			["Feathermoon, Feralas"] = 341,
			["Ratchet, The Barrens"] = 114,
			["Astranaar, Ashenvale"] = 792,
			["Nijel's Point, Desolace"] = 335,
			["Everlook, Winterspring"] = 907,
			["Thalanaar, Feralas"] = 163,
			["Marshal's Refuge, Un'Goro Crater"] = 260,
		},
		["Marshal's Refuge, Un'Goro Crater"] = {
			["Theramore, Dustwallow Marsh"] = 257,
			["Feathermoon, Feralas"] = 258,			
		},
		["Darkshire, Duskwood"] = {
			["Ironforge, Dun Morogh"] = 333,
			["Stormwind, Elwynn"] = 88,
			["Nethergarde Keep, Blasted Lands"] = 97,			
		},
		["Astranaar, Ashenvale"] = {
			["Theramore, Dustwallow Marsh"] = 745,
		},
		["Nijel's Point, Desolace"] = {
			["Theramore, Dustwallow Marsh"] = 308,
			["Stonetalon Peak, Stonetalon Mountains"] = 120,			
		},
		["Everlook, Winterspring"] = {
			["Auberdine, Darkshore"] = 292,		
			["Talonbranch Glade, Felwood"] = 123,
			["Theramore, Dustwallow Marsh"] = 890,
		},
		["Aerie Peak, The Hinterlands"] = {
			["Menethil Harbor, Wetlands"] = 176,		
			["Ironforge, Dun Morogh"] = 257,
			["Stormwind, Elwynn"] = 428,
		},
		["Light's Hope Chapel, Eastern Plaguelands"] = {
			["Chillwind Camp, Western Plaguelands"] = 150,		
			["Ironforge, Dun Morogh"] = 369,
			["Stormwind, Elwynn"] = 541,			
		},		
		["Stormwind, Elwynn"] = {
			["Booty Bay, Stranglethorn"] = 244,
			["Sentinel Hill, Westfall"] = 78,
			["Lakeshire, Redridge"] = 113,
			["Morgan's Vigil, Burning Steppes"] = 158,			
			["Chillwind Camp, Western Plaguelands"] = 507,
			["Darkshire, Duskwood"] = 117,
			["Nethergarde Keep, Blasted Lands"] = 176,
			["Ironforge, Dun Morogh"] = 259,
			["Menethil Harbor, Wetlands"] = 342,
			["Thelsamar, Loch Modan"] = 317,
			["Light's Hope Chapel, Eastern Plaguelands"] = 564,			
			["Aerie Peak, The Hinterlands"] = 507,
			["Southshore, Hillsbrad"] = 443,
			["Refuge Pointe, Arathi"] = 450,
		},
		["Chillwind Camp, Western Plaguelands"] = {
			["Menethil Harbor, Wetlands"] = 193,		
			["Ironforge, Dun Morogh"] = 260,
			["Light's Hope Chapel, Eastern Plaguelands"] = 147,			
			["Stormwind, Elwynn"] = 432,
		},
		["Lakeshire, Redridge"] = {
			["Morgan's Vigil, Burning Steppes"] = 62,		
			["Ironforge, Dun Morogh"] = 357,
			["Stormwind, Elwynn"] = 113,
		},
		["Gadgetzan, Tanaris"] = {
			["Theramore, Dustwallow Marsh"] = 153,
			["Marshal's Refuge, Un'Goro Crater"] = 105,	
			["Stonetalon Peak, Stonetalon Mountains"] = 599,
			["Everlook, Winterspring"] = 1054,			
			["Thalanaar, Feralas"] = 177,					
		},
		["Morgan's Vigil, Burning Steppes"] = {
			["Menethil Harbor, Wetlands"] = 271,
			["Aerie Peak, The Hinterlands"] = 436,
			["Ironforge, Dun Morogh"] = 186,
			["Lakeshire, Redridge"] = 64,
			["Thorium Point, Searing Gorge"] = 104,			
		},		
		["Menethil Harbor, Wetlands"] = {
			["Chillwind Camp, Western Plaguelands"] = 188,		
			["Ironforge, Dun Morogh"] = 89,
			["Stormwind, Elwynn"] = 260,
			["Morgan's Vigil, Burning Steppes"] = 222,			
		},
		["Talonbranch Glade, Felwood"] = {
			["Theramore, Dustwallow Marsh"] = 785,
			["Everlook, Winterspring"] = 120,			
		},
		["Feathermoon, Feralas"] = {
			["Theramore, Dustwallow Marsh"] = 314,
			["Moonglade"] = 618,			
		},
		["Ratchet, The Barrens"] = {
			["Theramore, Dustwallow Marsh"] = 105,
			["Astranaar, Ashenvale"] = 284,
			["Feathermoon, Feralas"] = 445,						
		},
		["Thelsamar, Loch Modan"] = {
			["Menethil Harbor, Wetlands"] = 152,
			["Nethergarde Keep, Blasted Lands"] = 441,
			["Ironforge, Dun Morogh"] = 109,
			["Thorium Point, Searing Gorge"] = 153,
			["Stormwind, Elwynn"] = 279,
		},
		["Ironforge, Dun Morogh"] = {
			["Booty Bay, Stranglethorn"] = 440,
			["Sentinel Hill, Westfall"] = 273,
			["Lakeshire, Redridge"] = 309,
			["Thorium Point, Searing Gorge"] = 87,
			["Darkshire, Duskwood"] = 312,
			["Chillwind Camp, Western Plaguelands"] = 294,
			["Southshore, Hillsbrad"] = 265,
			["Thelsamar, Loch Modan"] = 101,
			["Menethil Harbor, Wetlands"] = 129,
			["Aerie Peak, The Hinterlands"] = 298,
			["Nethergarde Keep, Blasted Lands"] = 373,
			["Refuge Pointe, Arathi"] = 253,
		},
		["Nethergarde Keep, Blasted Lands"] = {
			["Ironforge, Dun Morogh"] = 424,
			["Stormwind, Elwynn"] = 190,
			["Booty Bay, Stranglethorn"] = 262,			
		},
		["Booty Bay, Stranglethorn"] = {
			["Ironforge, Dun Morogh"] = 465,
			["Stormwind, Elwynn"] = 219,
		},
		["Thorium Point, Searing Gorge"] = {
			["Sentinel Hill, Westfall"] = 256,		
			["Ironforge, Dun Morogh"] = 93,
			["Stormwind, Elwynn"] = 257,
		},
		["Thalanaar, Feralas"] = {
			["Ratchet, The Barrens"] = 274,
			["Astranaar, Ashenvale"] = 545,
			["Theramore, Dustwallow Marsh"] = 160,
			["Gadgetzan, Tanaris"] = 171,
			["Marshal's Refuge, Un'Goro Crater"] = 275,
		},
		["Auberdine, Darkshore"] = {
			["Talonbranch Glade, Felwood"] = 190,
			["Everlook, Winterspring"] = 281,			
		},		
		["Refuge Pointe, Arathi"] = {
			["Menethil Harbor, Wetlands"] = 127,		
			["Ironforge, Dun Morogh"] = 271,
			["Stormwind, Elwynn"] = 385,
			["Southshore, Hillsbrad"] = 87,			
		},
		["Rut'theran Village, Teldrassil"] = {
			["Astranaar, Ashenvale"] = 261,
			["Nijel's Point, Desolace"] = 376,
			["Talonbranch Glade, Felwood"] = 274,
			["Feathermoon, Feralas"] = 558,
		},		
		["Moonglade"] = {
			["Rut'theran Village, Teldrassil"] = 226,
		},		
	}

PresavedData.Horde = {
		
		["Southshore, Hillsbrad"] = {
			["Ironforge, Dun Morogh"] = 206,
			["Stormwind, Elwynn"] = 367,
		},

    } -- PresavedData

local function PreloadHandler()

   -- fills flight times if player doesn't have

   local faction = UnitFactionGroup("player");

   -- check if player already has a flight time,
   -- if not, add the presaved flight time

   for startZone,startZoneTbl in pairs(PresavedData[faction]) do 

      -- check if we have this starting zone entry
      if not TOPGUN_GlobalData.FlightTimes[startZone] then
         TOPGUN_GlobalData.FlightTimes[startZone] = {};
      end

      for toZone,ftime in pairs(startZoneTbl) do

         -- check if we have this flight time
         if not TOPGUN_GlobalData.FlightTimes[startZone][toZone] then
            TOPGUN_GlobalData.FlightTimes[startZone][toZone] = ftime;
            --print("added a flight time! From "..startZone.." to "..toZone);
         end

      end -- for (startzone) 

   end -- for (endzone)

end -- PreloadHandler()

PreloadFrame:RegisterEvent("VARIABLES_LOADED");
PreloadFrame:SetScript("OnEvent",PreloadHandler);