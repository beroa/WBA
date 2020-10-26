local TOCNAME,WBA=...
WorldBossAttendance_Addon=WBA


WBA.Initalized = false;
WBA.AutoUpdateTimer=0
WBA.UPDATETIMER=5

WBA.GuildList = {}
WBA.TrackedZonesList = {"Ashenvale", "Feralas", "The Hinterlands", "Duskwood", "Azshara", "Blasted Lands", "Stormwind City"}
WBA.TrackedZones = {}

function WBA.SaveAnchors()
	WBA.DB.X = WorldBossAttendanceFrame:GetLeft()
	WBA.DB.Y = WorldBossAttendanceFrame:GetTop()
	WBA.DB.Width = WorldBossAttendanceFrame:GetWidth()
	WBA.DB.Height = WorldBossAttendanceFrame:GetHeight()
end

function WBA.Init()
	WorldBossAttendanceFrame:SetMinResize(300,170)	
	
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
    
    WorldBossAttendanceFrame:SetMinResize(300,300)
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
		-- WBA_print(WBA.AutoUpdateTimer)
		-- WBA_print("cur: "..time())
		if WBA.AutoUpdateTimer<time() then-- or WBA.ClearNeeded then			
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

function GetGuildiesOnline() -- Makes the GuildRoster request and prints the guildies + locations
    GuildRoster()

    wba_history_snap = {} -- all the guilds locations + metadata

    -- Read the Guild Roster Info
    numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers();
    for i=1, numOnlineGuildMembers do
        name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i)
		if WBA.TrackedZones[zone] ~= nil then
			
		
			wba_history_snap_row = {};
			wba_history_snap_row.name = StripServerName(name);
			wba_history_snap_row.zone = zone;
			wba_history_snap_row.class = class;
			
			wba_history_snap[GUID] = wba_history_snap_row;
		end
        -- print("row: " .. dump(wba_history_snap_row))
        WBA_print("CHAR: " .. trim(tostring(name)) .. " ZONE: " .. tostring(zone))
    end
    
    --Todo: add metadata

    -- print(dump(wba_history_snap))
    return wba_history_snap;
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