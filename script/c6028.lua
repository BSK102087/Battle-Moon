--Beast Dwarf Ragnarok
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x1f4),3)
	--Control only 1
	c:SetUniqueOnField(1,0,id)
	--Cannot be Tributed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	--Cannot be Targeted
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e3)
	--Cannot be Destroyed
	local e4=e1:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	--Cannot be Banished
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e5:SetCode(EFFECT_CANNOT_REMOVE)
	e5:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,1)
	e6:SetTarget(s.rmlimit)
	c:RegisterEffect(e6)
	--Battle Damage Immunity
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	--Banish Temporarily 
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_REMOVE)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(s.target)
	e8:SetOperation(s.operation)
	c:RegisterEffect(e8)
	--Special Summon
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,2))
	e10:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e10:SetCode(EVENT_BATTLE_DESTROYING)
	e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e10:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e10:SetCondition(s.bdrcon)
	e10:SetTarget(s.bdrtg)
	e10:SetOperation(s.bdrop)
	c:RegisterEffect(e10)
end
function s.rmlimit(e,c,p)
	return e:GetHandler()==c
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e9=Effect.CreateEffect(c)
		e9:SetDescription(aux.Stringid(id,0))
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e9:SetReset(RESET_PHASE+PHASE_BATTLE_START)
		e9:SetLabelObject(g:GetFirst())
		e9:SetCountLimit(1)
		e9:SetCondition(s.discon)
		e9:SetOperation(s.retop)
		Duel.RegisterEffect(e9,tp)
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
function s.bdrcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsMonster()
end
function s.bdrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCountFromEx(tp)>0)
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
function s.bdrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Cannot be Targeted
		local e11=Effect.CreateEffect(c)
		e11:SetDescription(3002)
		e11:SetType(EFFECT_TYPE_SINGLE)
		e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e11:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		e11:SetRange(LOCATION_MZONE)
		e11:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e11:SetValue(1)
		tc:RegisterEffect(e11)
		--Cannot be Destroyed
		local e12=e11:Clone()
		e12:SetDescription(3001)
		e12:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e12)
		--Cannot be Banished
		local e13=Effect.CreateEffect(c)
		e13:SetDescription(aux.Stringid(id,3))
		e13:SetType(EFFECT_TYPE_SINGLE)
		e13:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e13:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		e13:SetCode(EFFECT_CANNOT_REMOVE)
		e13:SetRange(LOCATION_MZONE)
		tc:RegisterEffect(e13)
		local e14=e13:Clone()
		e14:SetType(EFFECT_TYPE_FIELD)
		e14:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e14:SetTargetRange(1,1)
		e14:SetTarget(s.rmlimit)
		tc:RegisterEffect(e14)
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local e15=Effect.CreateEffect(c)
			e15:SetType(EFFECT_TYPE_SINGLE)
			e15:SetCode(EFFECT_SET_ATTACK_FINAL)
			e15:SetValue(3100)
			e15:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e15)
			local e16=e15:Clone()
			e16:SetCode(EFFECT_SET_DEFENSE_FINAL)
			tc:RegisterEffect(e16)
		end
	end	
	Duel.SpecialSummonComplete()
end