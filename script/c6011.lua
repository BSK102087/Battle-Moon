--Cyclone Battle Moon
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
	--Change to DEF Position (Opponent only)(Non-WIND)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_POSITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.poscon)
	e4:SetTarget(s.target)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e5)
	--Cannot Attack
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_ATTACK)	
	c:RegisterEffect(e6)
	--Special Summon
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetCondition(s.spcon)
	e7:SetTarget(s.sptg)
	e7:SetOperation(s.spop)
	c:RegisterEffect(e7)
	--Replace
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EFFECT_DESTROY_REPLACE)
	e8:SetRange(LOCATION_PZONE)
	e8:SetTarget(s.reptg)
	e8:SetValue(s.repval)
	e8:SetOperation(s.repop)
	c:RegisterEffect(e8)
	--Non-WIND -ATK & DEF
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_UPDATE_ATTACK)
	e9:SetRange(LOCATION_PZONE)
	e9:SetTarget(s.target)
	e9:SetTargetRange(0,LOCATION_MZONE)
	e9:SetValue(-500)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e10)
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
function s.tg(e,c)
	return c~=e:GetHandler() and c:IsFaceup()
end	
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsType(TYPE_EFFECT)
end
function s.target(e,c)
	return not c:IsAttribute(0x08) and c:IsFaceup()
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
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and (c:IsSetCard(0x1f4) or c:IsAttribute(0x08))
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
