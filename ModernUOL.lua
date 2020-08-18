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
        {
            Name = "Aurora Orbwalker",
            Valid =
                function()
                    return _G.AuroraOrb
                end
        },
    [_G.PaidScript.REBORN_ORB] =
        {
            Name = "Legit Orbwalker: Reborn",
            Valid =
                function()
                    return _G.LegitOrbwalker
                end
        },
    [_G.PaidScript.RMAN_LOADER] =
        {
            Name = "RMAN Orbwalker",
            Valid =
                function()
                    return _G.LegitOrbwalker -- RMAN supports same exact API
                end
        },
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

function ModernUOLAbstract:Print(text)
    _G.PrintChat('<font color=\'#9391FF\'><b>[ModernUOL] </b></font> <font color=\'#FDFF91\'>' .. tostring(text) .. '</font>')
end

function ModernUOLAbstract:InitMenu()
    if self.Menu then return end

    -- For future
end

function ModernUOLAbstract:OnTick()
    if self.ActiveOrb or self.DefaultOrb.Loaded or (not self.DefaultOrb.Val) then
        return
    end

    if os.clock() >= self.DefaultOrb.Time then
        local orb_name = ModernUOLAbstract.SupportedOrbwalkers[self.DefaultOrb.Val].Name

        self:Print("No orbwalker found. Loading default orbwalker (" .. orb_name .. ").")
        _G.LoadPaidScriptAsync(self.DefaultOrb.Val, function() end)

        self.DefaultOrb.Loaded = true
    end
end

function ModernUOLAbstract:SetDefaultOrbwalker(val, time)
    assert(ModernUOLAbstract.SupportedOrbwalkers[val], "SetDefaultOrbwalker: Given orbwalker not supported.")

    time = math.min(10, time or 10)
    self.DefaultOrb.Val = val
    self.DefaultOrb.Time = os.clock() + time
end

function ModernUOLAbstract:OnAsyncLoad(val)
    if self.ActiveOrb then return end

    local valid_func = ModernUOLAbstract.SupportedOrbwalkers[val].Valid

    if valid_func and valid_func() then
        self.ActiveOrb = val

        for i = 1, #self.OrbLoadCallbacks do
            self.OrbLoadCallbacks[i](val)
        end
    end
end

function ModernUOLAbstract:OnOrbLoad(callback)
    if self.ActiveOrb then
        callback(self.ActiveOrb)
        return
    end

    self.OrbLoadCallbacks[#self.OrbLoadCallbacks + 1] = callback
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


local ModernUOL = class(ModernUOLAbstract)

function ModernUOL:init()
    self.super.init(self)
end

--[[
    function: ModernUOL:IsAttacking()
    Parameter: None
    Return: Boolean
    Comment: Return true if my hero is attacking
--]]
function ModernUOL:IsAttacking()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:IsAttacking()
    end
end

--[[
    function: ModernUOL:IsOrbWalking()
    Parameter: None
    Return: Boolean
    Comment: Return true if my hero is orbwalking
--]]
function ModernUOL:IsOrbWalking()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:IsOrbWalking()
    end
end

--[[
    function: ModernUOL:CanAttack()
    Parameter: None
    Return: Boolean
    Comment: Return true if my hero can auto attack
--]]
function ModernUOL:CanAttack()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:CanAttack()
    end
end

--[[
    function: ModernUOL:CanMove()
    Parameter: None
    Return: Boolean
    Comment: Return true if my hero can move without cancel auto attack
--]]
function ModernUOL:CanMove()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:CanMove()
    end
end

--[[
    function: ModernUOL:MoveTo()
    Parameter:
        1. D3DXVECTOR3
    Return: nil
    Comment: Issue order a move to the given position if orbwalker can move
--]]
function ModernUOL:MoveTo(position)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:MoveTo(position)
    end
end

--[[
    function: ModernUOL:Attack()
    Parameter:
        1. gameObject
    Return: nil
    Comment: Issue order a attack to the given object (No range/unit check) if orbwalker can attack
--]]
function ModernUOL:Attack(object)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:Attack(object)
    end
end

--[[
    function: ModernUOL:BlockAttack()
    Parameter:
        1. boolean
    Return: nil
    Comment: Block orbwalker attack
--]]
function ModernUOL:BlockAttack(bool)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:BlockAttack(bool)
    end
end

--[[
    function: ModernUOL:BlockMove()
    Parameter:
        1. boolean
    Return: nil
    Comment: Block Orbwalker movement
--]]
function ModernUOL:BlockMove(bool)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:BlockMove(bool)
    end
end

--[[
    function: ModernUOL:IsAttackBlocked()
    Parameter: None
    Return: boolean
    Comment: Return if orbwalker attack is currently blocked
--]]
function ModernUOL:IsAttackBlocked()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:IsAttackBlocked()
    end
end

--[[
    function: ModernUOL:IsMoveBlocked()
    Parameter: None
    Return: boolean
    Comment: Return if orbwalker movement is currently blocked
--]]
function ModernUOL:IsMoveBlocked()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:IsMoveBlocked()
    end
end

--[[
    function: ModernUOL:GetMode()
    Parameter: None
    Return: string ("Combo", "Waveclear", "Harass", "Lasthit", "none")
    Comment: Return active orbwalker mode
--]]
function ModernUOL:GetMode()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:GetMode()
    end
end

--[[
    function: ModernUOL:ResetAA()
    Parameter: None
    Return: nil
    Comment: Reset orbwalker auto attack cooldown
--]]
function ModernUOL:ResetAA()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:ResetAA()
    end
end

--[[
    function: ModernUOL:GetTarget(range, position)
    Parameter: int, D3DXVECTOR3
    Return: gameObject or nil
    Comment: Return current orbwalker target (minions/structures included)
--]]
function ModernUOL:GetTarget(range, position)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:GetTarget(range, position)
    end
end

--[[
    function: ModernUOL:GetHeroTarget(range, position)
    Parameter: int, D3DXVECTOR3
    Return: gameObject or nil
    Comment: Returns hero target
--]]
function ModernUOL:GetHeroTarget(range, position)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:GetHeroTarget(range, position)
    end
end

--[[
    function: ModernUOL:SetTarget(target, time)
    Parameter: gameObject, time (optional and in second)
    Return: nil
    Comment: Force Orbwalker to target the given gameOject during time (time is optional)
--]]
function ModernUOL:SetTarget(target, time)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:SetTarget(target, time)
    end
end

--[[
    function: ModernUOL:UnSetTarget()
    Parameter: None
    Return: nil
    Comment: Unset the forced target
--]]
function ModernUOL:UnSetTarget()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:UnSetTarget()
    end
end

--[[
    function: ModernUOL:GetForcedTarget()
    Parameter: None
    Return: gameObject or nil
    Comment: Get forced target object
--]]
function ModernUOL:GetForcedTarget()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:GetForcedTarget()
    end
end

--[[
    function: ModernUOL:WaitingForMinion()
    Parameter: None
    Return: boolean
    Comment: Return true if orbwalker is waiting for a minion to last hit
--]]
function ModernUOL:WaitingForMinion()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:WaitingForMinion()
    end
end

--[[
    function: ModernUOL:GetMinions()
    Parameter: None
    Return: table
    Comment: Return only minions present on lane (mage, cannon, melee, super)
--]]
function ModernUOL:GetMinions()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:GetMinions()
    end
end

--[[
    function: ModernUOL:HpPred(unit, time)
    Parameter: gameObject, time (sec/ms ?)
    Return: float
    Comment: Return predicted unit health after the given time
--]]
function ModernUOL:HpPred(unit, time)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:HpPred(unit, time)
    end
end

--[[
    function: ModernUOL:AutoAttackCooldown()
    Parameter: None
    Return: float
    Comment: Return the next auto attack time
--]]
function ModernUOL:AutoAttackCooldown()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:AutoAttackCooldown()
    end
end

--[[
    function: ModernUOL:AutoAttackOnCooldown()
    Parameter: None
    Return: boolean
    Comment: Return if auto attack is on cooldown
--]]
function ModernUOL:AutoAttackOnCooldown()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:AutoAttackOnCooldown()
    end
end

--[[
    function: ModernUOL:AttackSpeed()
    Parameter: None
    Return: float
    Comment: Return the actual attack speed of myHero
--]]
function ModernUOL:AttackSpeed()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:AttackSpeed()
    end
end

--[[
    function: ModernUOL:GetProjectileSpeed(gameObject)
    Parameter: gameObject
    Return: int
    Comment: Return projectile speed of given gameObject
--]]
function ModernUOL:GetProjectileSpeed(gameObject)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:GetProjectileSpeed(gameObject)
    end
end

--[[
    function: ModernUOL:AddCallback(callback, func)
    Parameter: string, function
        callback's:
            OnUnKillable -- Trigger if it's impossible to last hit | arg: GameObject//minion
            OnAttack -- Triggers after an AA is recognized
            OnAfterAttack -- Triggers after an AA is done
            OnBeforeAttack -- Triggers just before an AA is recognized
            OnBeforeMovement -- Triggers just before a movement is recognized | arg: Position
            CanMove -- Triggers when the Champion can move again
            CanAttack -- Triggers when the Champion can AA again
    Return: nil
    Comment: Register a callback
--]]
function ModernUOL:AddCallback(callback, func)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:AddCallback(callback, func)
    end
end

--[[
    function: ModernUOL:RemoveCallback(func)
    Parameter: function
    Return: nil
    Comment: Remove a function from callback
--]]
function ModernUOL:RemoveCallback(func)
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:RemoveCallback(func)
    end
end

--[[
    function: ModernUOL:GetCallbacks()
    Parameter: function
    Return: table
    Comment: Get table of registered callback
--]]
function ModernUOL:GetCallbacks()
    if self.ActiveOrb == _G.PaidScript.REBORN_ORB then
        return _G.LegitOrbwalker:GetCallbacks()
    end
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

return ModernUOL()
