
local TOCNAME,WBA=...
WorldBossAttendance_Addon=WBA

function WBA.OnLoad()
    WBA_print("loaded!")
    WorldBossAttendanceFrame:SetMinResize(300,170)

    WBA.ResizeFrameList()
    
    SLASH_WBA1 = "/wba" -- For quicker access to frame stack
    SlashCmdList.WBA = function()
        WBA.ToggleWindow()
    end

    WBA.Tool.EnableSize(WorldBossAttendanceFrame,16,nil,WBA.ResizeFrameList())
    WBA.Tool.EnableMoving(WorldBossAttendanceFrame)
end


function WBA.HideWindow()
	WorldBossAttendanceFrame:Hide()
end
function WBA.ShowWindow()
	WorldBossAttendanceFrame:Show()
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
	WorldBossAttendanceFrame_DisplayFrame:SetHeight(WorldBossAttendanceFrame:GetHeight() -30-11)
	w=WorldBossAttendanceFrame:GetWidth() -20-10-10
	WorldBossAttendanceFrame_DisplayFrame:SetWidth( w )
	-- WorldBossAttendanceFrame_ScrollChildFrame:SetWidth( w )
end


SLASH_WBA1 = "/wba" -- For quicker access to frame stack
SlashCmdList.WBA = function()
    WBA.ToggleWindow()
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

---------------------------------------------------------
-- old code 
---------------------------------------------------------
function GetGuildiesOnline() -- Makes the GuildRoster request and prints the guildies + locations
    GuildRoster()

    wba_history_snap = {} -- all the guilds locations + metadata

    -- Read the Guild Roster Info
    numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers();
    for i=1, numOnlineGuildMembers do
        name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i)
        wba_history_snap_row = {};
        wba_history_snap_row.name = name;
        wba_history_snap_row.zone = zone;
        wba_history_snap_row.class = class;
        
        wba_history_snap[GUID] = wba_history_snap_row;
        -- print("row: " .. dump(wba_history_snap_row))
        WBA_print("CHAR: " .. trim(tostring(name)) .. " ZONE: " .. tostring(zone))
    end
    
    --Todo: add metadata

    print(dump(wba_history_snap))
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