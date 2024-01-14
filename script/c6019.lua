--Beast Core Genesis
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	--Reveal
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rccost)
	e1:SetTarget(s.rctg)
	e1:SetOperation(s.rcop)
	c:RegisterEffect(e1)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x1f4,lc,sumtype,tp)
end
function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.cfilter(c,e,tp,ft,zone)
	local lv=c:GetLevel()
	return lv>0 and ft>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,6039,0,TYPE_TOKEN+TYPE_MONSTER+TYPE_NORMAL,1000,1500,lv,c:GetRace(),c:GetAttribute()) 
		and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0 and not c:IsPublic()
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft, zone = Duel.GetLocationCount(tp,LOCATION_MZONE), e:GetHandler():GetLinkedZone()&0x1f
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return ft>-1 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ft,zone)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ft,zone)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	local tc=g:GetFirst()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone = e:GetHandler():GetLinkedZone()&0x1f
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPE_TOKEN+TYPE_MONSTER+TYPE_NORMAL,1000,1500,tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0 then
		local token=Duel.CreateToken(tp,6039)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP,zone)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(tc:GetLevel())
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		token:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CHANGE_RACE)
		e3:SetValue(tc:GetRace())
		token:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e4:SetValue(tc:GetAttribute())
		token:RegisterEffect(e4)
		end 
		if c:IsRelateToEffect(e) then
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD)
			e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e5:SetRange(LOCATION_MZONE)
			e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e5:SetAbsoluteRange(tp,1,0)
			e5:SetTarget(function(_,c) return not c:IsSetCard(0x1f4) end)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e5)
			local e6=e5:Clone()
			e6:SetCode(EFFECT_CANNOT_SUMMON)
			c:RegisterEffect(e6)
		end
	Duel.SpecialSummonComplete()
end
