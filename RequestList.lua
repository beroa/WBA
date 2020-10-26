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

-- yy is the items height, used in setting the height of the ScrollChildFrame
local function CreateItem(yy, i, hidden, forceHeight)
    local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
    local ItemFrameName="WBA.Item_"..i

	if WBA.FramesEntries[i]==nil then
		WBA.FramesEntries[i]=CreateFrame("Frame", ItemFrameName, WorldBossAttendanceFrame_ScrollChildFrame, "WorldBossAttendance_TmpRequest")
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
	_G[ItemFrameName.."_message"]:SetText("hi "..i)

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
	WBA_print("updating!")
	
	for i, f in pairs(WBA.FramesEntries) do
		f:Hide()
	end

    local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
    local yy=0
	local count=0
	local doCompact=1

    local itemHeight = CreateItem(yy,0,true,nil)
	WorldBossAttendanceFrame_ScrollFrame.ScrollBar.scrollStep=itemHeight*2
	
	-- fill the list with dummy data
    NUM_guildies = 50
    for i = 1, NUM_guildies do
        yy=yy+CreateItem(yy,i,false,itemHeight)+3
	end
	
	WorldBossAttendanceFrame_ScrollChildFrame:SetHeight(yy)

end

