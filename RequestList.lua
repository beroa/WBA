local TOCNAME,WBA=...

function WBA.Clear()
	if WBA.ClearNeeded or WBA.ClearTimer<time() then 
		local newRequest={}
		WBA.ClearTimer=WBA.MAXTIME
		WBA.RequestList=newRequest	
		WBA.ClearNeeded=false
	end		
end

local LastZone
local lastIsFolded
local function CreateHeader(yy, zone)
	local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
	local ItemFrameName="WBA.Zone_"..zone

	if WBA.FramesEntries[zone]==nil then
		WBA.FramesEntries[zone]=CreateFrame("Frame", ItemFrameName, WorldBossAttendanceFrame_ScrollChildFrame, "WorldBossAttendance_TmpHeader")
		WBA.FramesEntries[zone]:SetPoint("RIGHT", _G[AnchorRight], "RIGHT", 0, 0)						
		_G[ItemFrameName.."_name"]:SetPoint("RIGHT",WBA.FramesEntries[zone], "RIGHT", 0,0)
		local fname,h=_G[ItemFrameName.."_name"]:GetFont()
		_G[ItemFrameName.."_name"]:SetHeight(h)
		_G[ItemFrameName]:SetHeight(h+5)
		
		
	end

	if LastZone~="" and not (lastIsFolded and WBA.FoldedZones[zone]) then
		yy=yy+10
	end

	local colTXT="";
	if WBA.FoldedZones[zone]==true then
		colTXT=colTXT.."|c00FF0000[+]|c00FFFFFF "
		lastIsFolded=true
	else
		lastIsFolded=false
	end

	_G[ItemFrameName.."_name"]:SetText(colTXT .. zone)
						
	WBA.FramesEntries[zone]:SetPoint("TOPLEFT",_G[AnchorTop], "TOPLEFT", 0,-yy)
	WBA.FramesEntries[zone]:Show()
	
	yy=yy+_G[ItemFrameName]:GetHeight()
	LastZone = zone
	return yy
end

-- yy is the items height, used in setting the height of the ScrollChildFrame
local function CreateItem(yy, zone, req, hidden, forceHeight)
    local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
	zone = zone .. "_players"
    local ItemFrameName="WBA.Item_"..zone

	if WBA.FramesEntries[zone]==nil then
		WBA.FramesEntries[zone]=CreateFrame("Frame", ItemFrameName, WorldBossAttendanceFrame_ScrollChildFrame, "WorldBossAttendance_TmpRequest")
		WBA.FramesEntries[zone]:SetPoint("RIGHT", _G[AnchorRight], "RIGHT", 0, 0)
		_G[ItemFrameName.."_message"]:SetPoint("TOPLEFT")
		_G[ItemFrameName.."_message"]:SetPoint("TOP",_G[ItemFrameName.."_name"], "TOP",0,0)
		_G[ItemFrameName.."_message"]:SetPoint("RIGHT",WBA.FramesEntries[zone], "RIGHT", 0,0)
		_G[ItemFrameName.."_message"]:SetMaxLines(99)
	end

	WBA.FramesEntries[zone]:SetHeight(999)
	_G[ItemFrameName.."_message"]:SetHeight(999)
	_G[ItemFrameName.."_message"]:SetMaxLines(99)
	
	if req then
		_G[ItemFrameName.."_message"]:SetText(req)
	end

	local h = _G[ItemFrameName.."_message"]:GetStringHeight()

	if forceHeight then
		h = forceHeight
	end

	WBA.FramesEntries[zone]:SetPoint("TOPLEFT",_G[AnchorTop], "TOPLEFT", 10,-yy)
	_G[ItemFrameName.."_message"]:SetHeight(h+10)
	WBA.FramesEntries[zone]:SetHeight(h)

	if hidden then
		WBA.FramesEntries[zone]:Hide()
	else
		WBA.FramesEntries[zone]:Show()
	end

    return h
end

function WBA.UpdateList()
	WBA.Clear()
	WBA.AutoUpdateTimer=time()+WBA.UPDATETIMER
	
	if not WorldBossAttendanceFrame:IsVisible() then
		return
	end

	WorldBossAttendanceFrameTime:SetText(WBA_datetime())
	

	WBA.RequestList = GetGuildiesOnline()
	
	for zone, f in pairs(WBA.FramesEntries) do
		f:Hide()
	end

    local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
	local yy=0;

    local itemHeight = CreateItem(yy,"nil",nil,true,nil)
	WorldBossAttendanceFrame_ScrollFrame.ScrollBar.scrollStep=itemHeight*2

	-- sort the zones before displaying
	local zoneKeys = {};
	for k in pairs(WBA.RequestList) do table.insert(zoneKeys, k) end
	table.sort(zoneKeys)
	
	for key, value in ipairs(zoneKeys) do 
		yy=CreateHeader(yy,value)
		if WBA.FoldedZones[value]~=true then
			yy=yy+CreateItem(yy,value,WBA.RequestList[value],false,nil)+3
		end
	end
	
	WorldBossAttendanceFrame_ScrollChildFrame:SetHeight(yy)
end

function WBA.ClickZone(self,button)
	id=string.match(self:GetName(), "WBA.Zone_(.+)") 
	if id==nil or id==0 then return end
	
	if WBA.FoldedZones[id] then
		WBA.FoldedZones[id]=false
	else
		WBA.FoldedZones[id]=true
	end
	WBA.UpdateList()
end
