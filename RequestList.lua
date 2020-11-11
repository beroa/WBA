local TOCNAME,WBA=...

function WBA.Clear()
	if WBA.ClearNeeded or WBA.ClearTimer<time() then 
		local newRequest={}
		WBA.ClearTimer=WBA.MAXTIME
				
		-- for i,req in pairs(WBA.RequestList) do
		-- 	if type(req) == "table" then
		-- 		if req.last + WBA.DB.TimeOut * 3 > time() then
		-- 			if req.last < WBA.ClearTimer then
		-- 				WBA.ClearTimer=req.last
		-- 			end
		-- 			newRequest[#newRequest+1]=req			
					
		-- 		end
		-- 	end
		-- end
		WBA.RequestList=newRequest	
		WBA.ClearTimer=WBA.ClearTimer--+WBA.DB.TimeOut * 3
		WBA.ClearNeeded=false
	end		
end

local function requestSort(a,b)
	return a.zone > b.zone
end

local LastZone
local lastIsFolded
local function CreateHeader(yy, zone)
	local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
	-- zone = zone:gsub("%s+", "")
	local ItemFrameName="WBA.Zone_"..zone

	if WBA.FramesEntries[zone]==nil then
		WBA.FramesEntries[zone]=CreateFrame("Frame",ItemFrameName , WorldBossAttendanceFrame_ScrollChildFrame, "WorldBossAttendance_TmpHeader")
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
local function CreateItem(yy, i, req, hidden, forceHeight)
    local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
	-- i = i:gsub("%s+", "") .. "_players"
	i = i .. "_players"
    local ItemFrameName="WBA.Item"..i

	WBA_print("WBA.FramesEntries "..dump(WBA.FramesEntries))
	if WBA.FramesEntries[i]==nil then
		WBA.FramesEntries[i]=CreateFrame("Frame", ItemFrameName, WorldBossAttendanceFrame_ScrollChildFrame, "WorldBossAttendance_TmpRequest")
		WBA_print("just created: ".. ItemFrameName)
		WBA.FramesEntries[i]:SetPoint("RIGHT", _G[AnchorRight], "RIGHT", 0, 0)
		_G[ItemFrameName.."_message"]:SetPoint("TOPLEFT")
		_G[ItemFrameName.."_message"]:SetPoint("TOP",_G[ItemFrameName.."_name"], "TOP",0,0)
		_G[ItemFrameName.."_message"]:SetNonSpaceWrap(false)
		if WBA.DontTrunicate then
			WBA.ClearNeeded=true
		end
	end

	WBA.FramesEntries[i]:SetHeight(999)
	_G[ItemFrameName.."_message"]:SetHeight(999)

	
	if req then
		_G[ItemFrameName.."_message"]:SetText(req)
	end

	local h = _G[ItemFrameName.."_message"]:GetStringHeight()

	if forceHeight then
		h = forceHeight
	end

	WBA.FramesEntries[i]:SetPoint("TOPLEFT",_G[AnchorTop], "TOPLEFT", 10,-yy)
	_G[ItemFrameName.."_message"]:SetHeight(h+10)
	WBA.FramesEntries[i]:SetHeight(h)

	if hidden then
		WBA.FramesEntries[i]:Hide()
	else
		WBA.FramesEntries[i]:Show()
	end

    return h
end

function WBA.UpdateList()
	WBA.Clear()
	WBA.AutoUpdateTimer=time()+WBA.UPDATETIMER
	
	if not WorldBossAttendanceFrame:IsVisible() then
		return
	end

	WBA.RequestList = GetGuildiesOnline()
	table.sort(WBA.RequestList, requestSort)
	
	for i, f in pairs(WBA.FramesEntries) do
		f:Hide()
	end

    local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
	local yy=0
	lastZone=""
	local count=0
	local doCompact=1

    local itemHeight = CreateItem(yy,"nil",nil,true,nil)
	WorldBossAttendanceFrame_ScrollFrame.ScrollBar.scrollStep=itemHeight*2
	
	WBA_print(dump(WBA.RequestList));
	-- fill the list
	for zone, playerString in pairs(WBA.RequestList) do
		WBA_print("zone "..zone)
		-- if LastZone ~= zone then
		-- 	if LastZone~="" and WBA.FoldedZones[zone]~=true then
		-- 		yy=yy+itemHeight+3
		-- 	end
			yy=CreateHeader(yy,zone)
		-- end

		if WBA.FoldedZones[zone]~=true then
			yy=yy+CreateItem(yy,zone,playerString,false,itemHeight)+3
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
