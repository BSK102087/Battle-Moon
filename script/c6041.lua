--Beast Drones Armada
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon
	Xyz.AddProcedure(c,nil,9,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--Special Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--Battle Damage Immunity
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Special Summon (Opponent)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptarget)
	e4:SetOperation(s.spoperation)
	c:RegisterEffect(e4)
	--Banish Temporarily 
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetOperation(s.bop)
	c:RegisterEffect(e5)
end
function s.cfilter(c)
	return c:IsType(TYPE_TRAP) or c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	if tc then
		Duel.SendtoGrave(tc,REASON_DISCARD+REASON_COST)
		return true
	else return false end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(s.reglimit)
	Duel.RegisterEffect(e2,tp)
end
function s.reglimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_SPECIAL==SUMMON_TYPE_SPECIAL
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end	
function s.spoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	if c:IsLocation(LOCATION_MZONE) and Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e6=Effect.CreateEffect(c)
		e6:SetDescription(aux.Stringid(id,2))
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e6:SetReset(RESET_PHASE+PHASE_BATTLE_START)
		e6:SetLabelObject(c)
		e6:SetCountLimit(1)
		e6:SetCondition(s.discon)
		e6:SetOperation(s.retop)
		Duel.RegisterEffect(e6,tp)
	end
end
function s.discon(e,c)
	if e:GetLabelObject():IsLocation(LOCATION_REMOVED) then
		return true
	else
		e:Reset()
		return false
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if Duel.ReturnToField(tc) then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(aux.TRUE),tp,LOCATION_GRAVE,0,nil)
		if #g==0 then return end
		
		
end
