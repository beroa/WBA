local TOCNAME,WBA=...
WorldBossAttendance_Addon=WBA


WBA.Initalized = false;
WBA.AutoUpdateTimer=0
WBA.UPDATETIMER=5

WBA.TrackedZonesList = {"Ashenvale", "Feralas", "The Hinterlands", "Duskwood", "Azshara", "Blasted Lands", "Stormwind City", "Ruins of Ahn'Qiraj", "Ironforge", "Swamp of Sorrows", "Zul'Gurub", "Molten Core", "Temple of Ahn'Qiraj", "Ahn'Qiraj", "Dire Maul"}
WBA.TrackedZones = {}

function WBA.SaveAnchors()
	WBA.DB.X = WorldBossAttendanceFrame:GetLeft()
	WBA.DB.Y = WorldBossAttendanceFrame:GetTop()
	WBA.DB.Width = WorldBossAttendanceFrame:GetWidth()
	WBA.DB.Height = WorldBossAttendanceFrame:GetHeight()
end

function WBA.Init()
	WorldBossAttendanceFrame:SetMinResize(300,300)
	
	WBA.UserLevel=UnitLevel("player")
	WBA.UserName=(UnitFullName("player"))
	WBA.ServerName=GetRealmName()

	DEFAULT_CHAT_FRAME:AddMessage("init ran")
		
	-- Initalize options
	if not WorldBossAttendanceDB then WorldBossAttendanceDB = {} end -- fresh DB
	if not WorldBossAttendanceDBChar then WorldBossAttendanceDBChar = {} end -- fresh DB
	
	WBA.DB=WorldBossAttendanceDB
	WBA.DBChar=WorldBossAttendanceDBChar
	
	if WBA.DB.OnDebug == nil then WBA.DB.OnDebug=false end
	WBA.DB.widthNames=93 
	WBA.DB.widthTimes=50 
	
	-- Reset Request-List
	WBA.RequestList={}
	WBA.FramesEntries={}
	WBA.FoldedZones={}
	
	-- Timer-Stuff
	WBA.MAXTIME=time()+60*60*24*365 --add a year!
	WBA.AutoUpdateTimer=time()+WBA.UPDATETIMER
	
	WBA.ClearNeeded=true
	WBA.ClearTimer=WBA.MAXTIME

	for k, v in pairs(WBA.TrackedZonesList) do
		WBA.TrackedZones[v] = 1
	end
		
	local x, y, w, h = WBA.DB.X, WBA.DB.Y, WBA.DB.Width, WBA.DB.Height
	if not x or not y or not w or not h then
		WBA.SaveAnchors()
	else
		WorldBossAttendanceFrame:ClearAllPoints()
		WorldBossAttendanceFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
		WorldBossAttendanceFrame:SetWidth(w)
		WorldBossAttendanceFrame:SetHeight(h)		
	end
	
	WBA.ResizeFrameList()
	
	WBA.Tool.EnableSize(WorldBossAttendanceFrame,8,nil,function()
		WBA.ResizeFrameList()
		WBA.SaveAnchors()
		WBA.UpdateList()
		end
	)
	WBA.Tool.EnableMoving(WorldBossAttendanceFrame,WBA.SaveAnchors)
	WBA.Initalized=true
end

local function Event_ADDON_LOADED(arg1)
	if arg1 == TOCNAME then
		WBA.Init()
	end
end

function WBA.OnLoad()
	WBA.Tool.RegisterEvent("ADDON_LOADED",Event_ADDON_LOADED)

    SLASH_WBA1 = "/wba"
    SlashCmdList.WBA = function()
        WBA.ToggleWindow()
    end
    
    WBA.ResizeFrameList()
    WBA.Tool.EnableSize(WorldBossAttendanceFrame,16,nil,function() -- Resizing with LibGPI
		WBA.ResizeFrameList()
		end
    )
    WBA.Tool.EnableMoving(WorldBossAttendanceFrame)
    WBA.Initalized = true

    WBA.Tool.OnUpdate(WBA.OnUpdate)
end


function WBA.OnUpdate()
	if WBA.Initalized==true then
		if WBA.AutoUpdateTimer<time() or WBA.ClearNeeded then
			WBA.UpdateList()			
		end	
	end
end

function WBA.HideWindow()
	WorldBossAttendanceFrame:Hide()
end
function WBA.ShowWindow()
	WorldBossAttendanceFrame:Show()
	WBA.ClearNeeded=true	 
	WBA.UpdateList()
	WBA.ResizeFrameList()
end
function WBA.ToggleWindow()
	if WorldBossAttendanceFrame:IsVisible() then
		WBA.HideWindow()
	else
		WBA.ShowWindow()
	end
end

function WBA.BtnClose()
    WBA.HideWindow()
end

function WBA.OnSizeChanged()
	if WBA.Initalized==true then
		WBA.ResizeFrameList()
	end
	WBA.ClearNeeded = true;
end

function WBA.ResizeFrameList()
	local w
	WorldBossAttendanceFrame_ScrollFrame:SetHeight(WorldBossAttendanceFrame:GetHeight() -30-11)
	w=WorldBossAttendanceFrame:GetWidth() -20-10-10
	WorldBossAttendanceFrame_ScrollFrame:SetWidth( w )
	WorldBossAttendanceFrame_ScrollChildFrame:SetWidth( w )
end

---------------------------------------------------------
-- debugging utilies
---------------------------------------------------------
SLASH_FRAMESTK1 = "/fs" -- For quicker access to frame stack
SlashCmdList.FRAMESTK = function()
    LoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle()
end

SLASH_RELOADUI1 = "/rl" -- For quicker reload
SlashCmdList.RELOADUI = function()
    ReloadUI()
end

function GetGuildiesOnline() -- Makes the GuildRoster request and returns the zone_strings
    GuildRoster()
    wba_zone_snap = {} -- names and zones for all people we're interested in
	numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers();
    for i=0, numOnlineGuildMembers do
        name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i)
		if WBA.TrackedZones[zone] ~= nil then
			wba_zone_snap_row = {};
			wba_zone_snap_row.name = StripServerName(name);
			wba_zone_snap_row.zone = zone;
			wba_zone_snap_row.class = class;
			table.insert(wba_zone_snap, wba_zone_snap_row);
		end
	end

	table.sort(wba_zone_snap, function(a, b) 
		return a.name < b.name
	end)

	wba_zone_strings = {}
	for k, v in pairs(wba_zone_snap) do
		_,_,_,classColor = GetClassColor(v.class)
		classColorCode = "|c"..classColor
		if wba_zone_strings[v.zone] == nil then
			wba_zone_strings[v.zone] = classColorCode .. v.name .. "|c00FFFFFF  "
		else
			wba_zone_strings[v.zone] = wba_zone_strings[v.zone] .. classColorCode .. v.name .."|c00FFFFFF "
		end
	end
    return wba_zone_strings;
end

-- UTILITY: Removes the server name from the player name
function StripServerName(s)
    return string.gsub(s, "-.+", "")
end

-- UTILITY: Table scanning
function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

-- UTILITY: Colorful print function
function WBA_print(str, err)
    if not str then return; end;
    if err == nill then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF80FF80WBA:|r " .. tostring(str) .. "|r");
    else
		DEFAULT_CHAT_FRAME:AddMessage("|cFF80FF80WBA:|r |c00FF0000Error|r - " .. tostring(str) .. "|r");
    end
end

-- UTILITY: Table print/dump
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end