local TOCNAME,WBA=...

function WBA.ScrollGroupList(self,delta)
	self:SetScrollOffset(self:GetScrollOffset() + delta*5);
	self:ResetAllFadeTimes()
end