local function class(super)
    return setmetatable({super = super},
    {
        __index = super,
        __call = function(self, ...)
            local result = setmetatable({}, {__index = self})
            result:init(...)

            return result
        end
    })
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local ModernUOLAbstract = class()

ModernUOLAbstract.SupportedOrbwalkers = {
    [_G.PaidScript.AURORA_ORB] =
        function()
            return _G.AuroraOrb and _G.AuroraOrb.Enabled
        end,
    [_G.PaidScript.REBORN_ORB] =
        function()
            return _G.LegitOrbwalker
        end,
    [_G.PaidScript.RMAN_LOADER] =
        function()
            return _G.LegitOrbwalker -- RMAN supports same exact API
        end
}

function ModernUOLAbstract:init()
    self.LoadTime = os.clock()
    self.OrbLoadCallbacks = {}
    self.ActiveOrb = nil
    self.DefaultOrb = {Val = nil, Time = nil, Loaded = false}

    self:InitMenu()

    _G.RegisterPaidAsyncCallback(function(...) self:OnAsyncLoad(...) end)
    _G.AddEvent(_G.Events.OnTick, function() self:OnTick() end)
end

function ModernUOLAbstract:InitMenu()
    if self.Menu then return end

    -- For future
end

function ModernUOLAbstract:OnTick()
    if not self.DefaultOrb.Val or self.DefaultOrb.Loaded then return end

    if os.clock() >= self.DefaultOrb.Time then
        _G.PrintChat("No orbwalker loaded. Loading default orbwalker..")
        _G.LoadPaidScriptAsync(_G.DefaultOrb.Val, function() end)
        self.DefaultOrb.Loaded = true
    end
end

function ModernUOLAbstract:SetDefaultOrbwalker(val, time)
    assert(ModernUOLAbstract.SupportedOrbwalkers[val], "SetDefaultOrbwalker: Given orbwalker not supported.")

    time = time or 10
    self.DefaultOrb.Val = val
    self.DefaultOrb.Time = os.clock() + time
end

function ModernUOLAbstract:OnAsyncLoad(val)
    if self.ActiveOrb then return end

    local func = ModernUOLAbstract.SupportedOrbwalkers[val]

    if func and func() then
        self.ActiveOrb = val

        for i = 1, #self.OrbLoadCallbacks do
            self.OrbLoadCallbacks[#self.OrbLoadCallbacks + 1](val)
        end
    end
end

function ModernUOLAbstract:OnOrbLoad(callback)
    self.OrbLoadCallbacks[#self.OrbLoadCallbacks + 1] = callback
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


local ModernUOL = class(ModernUOLAbstract)

function ModernUOL:init()
    self.super.init(self)

    self.OrbState = {}
end

function ModernUOL:GetTarget(range, damageType, from)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        if range == nil then return _G.LegitOrbwalker:GetTarget() end
        if range ~= nil and damageType == nil then return _G.LegitOrbwalker:GetTarget(range) end
        if range ~= nil and damageType ~= nil and from == nil then return _G.LegitOrbwalker:GetTarget(range, damageType) end
        if range ~= nil and damageType ~= nil and from ~= nil then return _G.LegitOrbwalker:GetTarget(range, damageType, from) end
    end
end

function ModernUOL:GetMode()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:GetMode()
    end
end

function ModernUOL:ForceTarget(unit)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        _G.LegitOrbwalker:SetForcedTarget(unit)
    end

    self.OrbState.ForcedTarget = unit
end

function ModernUOL:ResetForcedTarget()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        _G.LegitOrbwalker:UnsetForcedTarget()
    end

    self.OrbState.ForcedTarget = nil
end

function ModernUOL:GetForcedTarget()
    return self.OrbState.ForcedTarget
end

function ModernUOL:IsAttacking()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:IsAttacking()
    end
end

function ModernUOL:CanAttack()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:CanAttack()
    end
end

function ModernUOL:CanMove()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:CanMove()
    end
end

function ModernUOL:GetDamagePrediction(object, delay)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return object.health - _G.LegitOrbwalker:HpPred(object, delay)
    end
end

function ModernUOL:GetHealthPrediction(object, delay)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:HpPred(object, delay)
    end
end

function ModernUOL:OrbwalkTo(position)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        _G.LegitOrbwalker:MoveTo(position)
    end

    self.OrbState.OrbwalkTo = position
end

function ModernUOL:ResetOrbwalkTo()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        _G.LegitOrbwalker:MoveTo()
    end

    self.OrbState.OrbwalkTo = nil
end

function ModernUOL:IsOrbwalkToSet()
    return self.OrbState.OrbwalkTo
end

function ModernUOL:Attack(unit)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        _G.LegitOrbwalker:Attack(unit)
    end
end

function ModernUOL:BlockAttack(bool)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        _G.LegitOrbwalker:BlockAttack(bool)
    end

    self.OrbState.BlockAttack = bool
end

function ModernUOL:IsBlockedAttack()
    return self.OrbState.BlockAttack
end

function ModernUOL:BlockMove(bool)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        _G.LegitOrbwalker:BlockMove(bool)
    end

    self.OrbState.BlockMove = bool
end

function ModernUOL:IsBlockedMove()
    return self.OrbState.BlockMove
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

return ModernUOL()
