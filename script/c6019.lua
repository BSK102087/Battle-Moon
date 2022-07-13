--Elemental Chaos
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	--Link Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--Only Summon Battle Moons
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.sumlimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e4)
	--Reveal
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(s.rccost)
	e5:SetTarget(s.rctg)
	e5:SetOperation(s.rcop)
	c:RegisterEffect(e5)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x1f4,lc,sumtype,tp)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(s.splimit)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end
function s.sumlimit(e,c)
	return not c:IsSetCard(0x1f4)
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.cfilter(c,e,tp,ft,zone)
	local lv=c:GetLevel()
	return lv>0 and ft>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,6039,0,TYPE_TOKEN+TYPE_MONSTER+TYPE_NORMAL,1000,1500,lv,c:GetRace(),c:GetAttribute()) 
		and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0
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
	local zone = e:GetHandler():GetLinkedZone()&0x1f
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPE_TOKEN+TYPE_MONSTER+TYPE_NORMAL,1000,1500,tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0 then
		local token=Duel.CreateToken(tp,6039)
		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_CHANGE_LEVEL)
		e6:SetValue(tc:GetLevel())
		e6:SetReset(RESET_EVENT+RESETS_REDIRECT)
		token:RegisterEffect(e6)
		local e7=e6:Clone()
		e7:SetCode(EFFECT_CHANGE_RACE)
		e7:SetValue(tc:GetRace())
		token:RegisterEffect(e7)
		local e8=e6:Clone()
		e8:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e8:SetValue(tc:GetAttribute())
		token:RegisterEffect(e8)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP,zone)
	end 
end