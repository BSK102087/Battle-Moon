--Battle Moon Crescent
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon (from hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Hand Synchro
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_HAND_SYNCHRO)
	e2:SetCondition(s.lvcon)
	e2:SetLabel(id)
	e2:SetValue(s.synval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SYNCHRO_MAT_RESTRICTION)
	e3:SetCondition(s.lvcon)
	e3:SetValue(s.synfilter)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1f4)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.lvfilter(c)
	return c:IsSetCard(0x1f4)
end
function s.lvcon(e)
	return Duel.IsExistingMatchingCard(s.lvfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil)
end
function s.synfilter(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsLocation(LOCATION_MZONE)))
end
function s.synval(e,c,sc)
	if c:IsLocation(LOCATION_HAND) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		e1:SetLabel(id)
		e1:SetTarget(s.synchktg)
		c:RegisterEffect(e1)
		return true
	else return false end
end
function s.chk2(c)
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
	for i=1,#te do
		local e=te[i]
		if e:GetLabel()==id then return true end
	end
	return false
end
function s.synchktg(e,c,sg,tg,ntg,tsg,ntsg)
	if c then
		local res=tg:IsExists(s.chk2,1,c) or ntg:IsExists(s.chk2,1,c) or sg:IsExists(s.chk2,1,c)
		return res,Group.CreateGroup(),Group.CreateGroup()
	else
		return true
	end
end
