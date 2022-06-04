--Beast Raider Dreadnought
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	c:EnableReviveLimit()
	--Control only 1
	c:SetUniqueOnField(1,0,id)
	--Battle Damage Immunity
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Banish Temporarily 
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.bcon)
	e2:SetOperation(s.bop)
	c:RegisterEffect(e2)
	--Shuffle
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetTarget(s.shtg)
	e4:SetOperation(s.shop)
	c:RegisterEffect(e4)
end
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_NORMAL,scard,sumtype,tp)
end
function s.bcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	if c:IsLocation(LOCATION_MZONE) and Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e3:SetReset(RESET_PHASE+PHASE_BATTLE_START)
		e3:SetLabelObject(c)
		e3:SetCountLimit(1)
		e3:SetCondition(s.discon)
		e3:SetOperation(s.retop)
		Duel.RegisterEffect(e3,tp)
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
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if c==tc then tc=Duel.GetAttackTarget() end
	if tc and tc:IsRelateToBattle() then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end	
	if c:IsRelateToEffect(e) and c:CanChainAttack() and c==Duel.GetAttacker() then
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_DAMAGE_STEP_END)
		e5:SetOperation(s.caop)
		e5:SetCountLimit(1)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e5)
	end
end
function s.caop(e,tp)
	local c=e:GetHandler()
	if c:CanChainAttack() then
		Duel.ChainAttack()
	end
end	
