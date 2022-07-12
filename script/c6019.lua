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
	e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e5)
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
function s.filter(c)
	return not c:IsPublic() and Duel.IsPlayerCanSpecialSummonMonster(tp,6039,0,TYPES_TOKEN,1000,1500,nil,nil,nil) 
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
function s.filter1(c)
	return c:IsSetCard(0x1f4)
end
function s.filter2(c)
	return c:IsSetCard(0x1f4) and c:IsType(TYPE_PENDULUM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,e:GetHandler():GetLinkedZone(tp)) 
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	if zone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local dc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		Duel.ConfirmCards(1-tp,dc)
		Duel.ShuffleHand(tp)
		if dc:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,6039,0,TYPES_TOKEN,1000,1500,dc:GetLevel(),dc:GetRace(),dc:GetAttribute()) then
			Duel.BreakEffect()
			local token=Duel.CreateToken(tp,6039)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP,zone)
			local e6=Effect.CreateEffect(e:GetHandler())
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_CHANGE_LEVEL)
			e6:SetValue(dc:GetLevel())
			e6:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e6)
			local e7=e6:Clone()
			e7:SetCode(EFFECT_CHANGE_RACE)
			e7:SetValue(dc:GetRace())
			token:RegisterEffect(e7)
			local e8=e7:Clone()
			e8:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e8:SetValue(dc:GetAttribute())
			token:RegisterEffect(e8)
			Duel.SpecialSummonComplete()
		elseif dc:IsType(TYPE_TRAP) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil)
				if #g>0 then
				Duel.SendtoExtraP(g,tp,REASON_EFFECT)
			end	
		elseif dc:IsType(TYPE_SPELL) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
				if g:GetCount()>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
		end	
	end
end
