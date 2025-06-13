--Gemini Trickster
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,nil,2,4,s.lcheck)
	c:EnableReviveLimit()
	--Gemini Unlock
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.utg)
	e1:SetCode(EFFECT_GEMINI_STATUS)
	c:RegisterEffect(e1)
	--Copy Effect (Gemini)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.copytg)
	e2:SetOperation(s.copyop)
	c:RegisterEffect(e2)
	--Special Summon (GY)
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCost(s.spcost)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	--Special Summon Limit
	local e7=Effect.CreateEffect(c)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCondition(s.regcon)
	e7:SetOperation(s.regop)
	c:RegisterEffect(e7)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_GEMINI,lc,sumtype,tp)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e8=Effect.CreateEffect(e:GetHandler())
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetTargetRange(1,0)
	e8:SetReset(RESET_PHASE+PHASE_END)
	e8:SetTarget(s.reglimit)
	Duel.RegisterEffect(e8,tp)
end
function s.reglimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_SPECIAL==SUMMON_TYPE_SPECIAL
end
function s.utg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsType(TYPE_GEMINI)
end
function s.copyfilter(c)
	return c:IsType(TYPE_GEMINI) and c:IsFaceup()
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED) and s.copyfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetBaseAttack()
	local def=tc:GetBaseDefense()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	if sel==0 then dou=atk
	else dou=def end
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsFaceup() or tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED)) then
		local code=tc:GetOriginalCode()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_CHANGE_CODE)
		e3:SetValue(code)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EFFECT_GEMINI_STATUS)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_SET_ATTACK)
		e5:SetValue(dou*2)
		c:RegisterEffect(e5)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
	end
end
function s.cfilter(c,tp)
	return c:IsType(TYPE_NORMAL+TYPE_GEMINI) and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsInMainMZone(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,true,nil,nil,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,true,nil,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
