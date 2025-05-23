--Eclipse Battle Moon
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Control only 1
	c:SetUniqueOnField(1,0,id)
	--Normal Summon & Set with no Tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	e1:SetOperation(s.ntop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	--Tribute Summon using Pendulum Cards
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.trtg)
	e3:SetValue(POS_FACEUP)
	c:RegisterEffect(e3)
	--Change Attack Target
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.ctcon)
	e5:SetTarget(s.cttg)
	e5:SetOperation(s.ctop)
	c:RegisterEffect(e5)
	--Special Summon
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetDescription(aux.Stringid(id,2))
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e9:SetCode(EVENT_LEAVE_FIELD)
	e9:SetCondition(s.spcon)
	e9:SetTarget(s.sptg)
	e9:SetOperation(s.spop)
	e9:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e9)
	--Replace
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EFFECT_DESTROY_REPLACE)
	e10:SetRange(LOCATION_PZONE)
	e10:SetTarget(s.reptg)
	e10:SetValue(s.repval)
	e10:SetOperation(s.repop)
	c:RegisterEffect(e10)
	--Non-DARK -ATK & DEF
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_UPDATE_ATTACK)
	e11:SetRange(LOCATION_PZONE)
	e11:SetTarget(s.target)
	e11:SetTargetRange(0,LOCATION_MZONE)
	e11:SetValue(-500)
	c:RegisterEffect(e11)
	local e12=e11:Clone()
	e12:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e12)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	--change base attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1900)
	c:RegisterEffect(e1)
	--change base defense
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1900)
	c:RegisterEffect(e2)
	--Normal Monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetReset(RESET_EVENT+0xff0000)
	e3:SetCode(EFFECT_ADD_TYPE)
	e3:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_REMOVE_TYPE)
	e4:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e4)
end
function s.trtg(e,c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1f4) and c:IsReleasable()
end
function s.ctfilter(c)
	return not c:IsAttribute(0x20)
end
function s.ct1filter(c)
	return c:IsFaceup() and not c:IsAttribute(0x20)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local att=Duel.GetAttacker()
	return e:GetHandler():IsType(TYPE_EFFECT) and not att:IsControler(tp) and not att:IsAttribute(0x20)
end	
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local at=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,at) or 
		Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,0,1,bc) end 
	Duel.SetTargetCard(at)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	local g=Duel.GetMatchingGroup(s.ct1filter,tp,LOCATION_MZONE,LOCATION_MZONE,at)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
		local tc=g:Select(tp,1,1,bc):GetFirst()
		local at=Duel.GetAttacker()
		if at:CanAttack() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
			Duel.CalculateDamage(at,tc)
		end
	end
end
function s.target(e,c)
	return not c:IsAttribute(0x20) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1f4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsLevelBelow(6)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end	
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and (c:IsSetCard(0x1f4) or c:IsAttribute(0x20))
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end	
