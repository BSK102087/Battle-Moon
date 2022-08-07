--Fortress Battle Moon
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
	--Summon with Pendulum Cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetCondition(s.trcon)
	e3:SetOperation(s.trop)
	e3:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e3)
	--Change to ATK Position (Opponent only)(Non-EARTH)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_POSITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.poscon)
	e4:SetTarget(s.target)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.poscon)
	e5:SetTarget(s.target)
	e5:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e5)
	--Must Attack Card
	local e6=e5:Clone()
	e6:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e7:SetValue(s.atklimit)
	c:RegisterEffect(e7)
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
	c:RegisterEffect(e9)
	--Add to hand (Extra Deck)
	local e10=Effect.CreateEffect(c)
	e10:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e10:SetType(EFFECT_TYPE_IGNITION)
	e10:SetRange(LOCATION_PZONE)
	e10:SetCountLimit(1,0x1f4)
	e10:SetTarget(s.extg)
	e10:SetOperation(s.exop)
	c:RegisterEffect(e10)
	--Non-EARTH -ATK & DEF
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
function s.trfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1f4) and c:IsReleasable()
end
function s.exfilter(c,g,sc)
	if not c:IsReleasable() or g:IsContains(c) or c:IsHasEffect(EFFECT_EXTRA_RELEASE) then return false end
	local rele=c:GetCardEffect(EFFECT_EXTRA_RELEASE_SUM)
	if rele then
		local remct,ct,flag=rele:GetCountLimit()
		if remct<=0 then return false end
	else return false end
	local sume={c:GetCardEffect(EFFECT_UNRELEASABLE_SUM)}
	for _,te in ipairs(sume) do
		if type(te:GetValue())=='function' then
			if te:GetValue()(te,sc) then return false end
		else return false end
	end
	return true
end
function s.val(c,sc,ma)
	local eff3={c:GetCardEffect(EFFECT_TRIPLE_TRIBUTE)}
	if ma>=3 then
		for _,te in ipairs(eff3) do
			if te:GetValue()(te,sc) then return 0x30001 end
		end
	end
	local eff2={c:GetCardEffect(EFFECT_DOUBLE_TRIBUTE)}
	for _,te in ipairs(eff2) do
		if te:GetValue()(te,sc) then return 0x20001 end
	end
	return 1
end
function s.req(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1f4) and c:IsLocation(LOCATION_PZONE)
end
function s.unreq(c,tp)
	return c:IsControler(1-tp) and not c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM)
end
function s.rescon(sg,e,tp,mg)
	local c=e:GetHandler()
	local mi,ma=c:GetTributeRequirement()
	if mi<1 then mi=ma end
	if not sg:IsExists(s.req,1,nil) or not aux.ChkfMMZ(1)(sg,e,tp,mg) 
		or sg:FilterCount(s.unreq,nil,tp)>1 then return false end
	local ct=sg:GetCount()
	return sg:CheckWithSumEqual(s.val,mi,ct,ct,c,ma) or sg:CheckWithSumEqual(s.val,ma,ct,ct,c,ma)
end
function s.trcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetTributeGroup(c)
	local exg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_PZONE,0,nil)
	g:Merge(exg)
	local opg=Duel.GetMatchingGroup(s.exfilter,tp,0,LOCATION_MZONE,nil,g,c)
	g:Merge(opg)
	local mi,ma=c:GetTributeRequirement()
	if mi<minc then mi=minc end
	if ma<mi then return false end
	return ma>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-ma and aux.SelectUnselectGroup(g,e,tp,1,ma,s.rescon,0)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetTributeGroup(c)
	local exg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_PZONE,0,nil)
	g:Merge(exg)
	local opg=Duel.GetMatchingGroup(s.exfilter,tp,0,LOCATION_MZONE,nil,g,c)
	g:Merge(opg)
	local mi,ma=c:GetTributeRequirement()
	if mi<1 then mi=1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,mi,ma,s.rescon,1,tp,HINTMSG_RELEASE)
	local remc=sg:Filter(s.unreq,nil,tp):GetFirst()
	if remc then
		local rele=remc:GetCardEffect(EFFECT_EXTRA_RELEASE_SUM)
		rele:Reset()
	end
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsType(TYPE_EFFECT)
end	
function s.target(e,c)
	return not c:IsAttribute(0x01) and c:IsFaceup()
end
function s.atklimit(e,c)
	return c==e:GetHandler()
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
function s.exfilter(c)
	return c:IsSetCard(0x1f4) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.rtfilter(c)
	return c:IsAbleToDeck()
end
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) and 
		Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	local bg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if #g>0 and Duel.SendtoDeck(g,nil,0,REASON_EFFECT)~=0 and bg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=bg:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
	end
end
