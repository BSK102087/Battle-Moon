--Symbols of Nature and Chaos
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,s.fusfilter,nil,s.fextra)
	c:RegisterEffect(e1)
	--Banish Temporarily 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_card_types={TYPE_GEMINI}
function s.fusfilter(c)
	return c:IsCode(6027,6028,6029,64463828)
end
function s.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.fextra(e,tp,mg)
	if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0 then
		return Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_PZONE+LOCATION_EXTRA,0,nil)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e2:SetReset(RESET_PHASE+PHASE_BATTLE_START)
		e2:SetLabelObject(g:GetFirst())
		e2:SetCountLimit(1)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.retop)
		Duel.RegisterEffect(e2,tp)
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
	Duel.ReturnToField(e:GetLabelObject())
end

