local TOCNAME,WBA=...

function WBA.UpdateList()

    local AnchorTop="WorldBossAttendanceFrame_ScrollChildFrame"
	local AnchorRight="WorldBossAttendanceFrame_ScrollChildFrame"
    local yy=0
	local count=0
	local doCompact=1
	local cEntrys=0
    

    WorldBossAttendanceFrame_ScrollFrame.ScrollBar.scrollStep=itemHight*2

    yy=yy+WorldBossAttendanceFrame_ScrollFrame:GetHeight()-20
    WorldBossAttendanceFrame_ScrollChildFrame:SetHeight(yy)
    
end