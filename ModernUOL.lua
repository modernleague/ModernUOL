--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local version = 1.33
GetInternalWebResultAsync('ModernUOL.version', function(v)
    if v and tonumber(v) > version then
        DownloadInternalFileAsync('ModernUOL.lua', _G.DEFAULT_COMMON_PATH, function(success)
            if success then
                PrintChat("Press F6 to reload")
                return
            end
        end)
    end
end)

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

local FakeScript = {WADBOT = true}

ModernUOLAbstract.SupportedOrbwalkers = {
    [_G.PaidScript.MED] =
        {
            Name = "Marksman's Efficient Dynamics",
            Valid = function()
                        return _G.MED
                    end
        },
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
                    return _G.LegitOrbwalker and not _G.LegitOrbwalker.fakeIndex
                end
        },
    [_G.PaidScript.RMAN_LOADER] =
        {
            Name = "RMAN Orbwalker",
            Valid =
                function()
                    return _G.LegitOrbwalker and not _G.LegitOrbwalker.fakeIndex
                end
        },
    [_G.PaidScript.WADBOT] =
        {
            Name = "Wadbot",
            Valid =
                function()
                    return _G.LegitOrbwalker and _G.LegitOrbwalker.fakeIndex
                end
        },
}

local IS_LEGIT_ORB_COMPATIBLE = {[_G.PaidScript.REBORN_ORB] = true, [_G.PaidScript.RMAN_LOADER] = true, [_G.PaidScript.WADBOT] = true}

function ModernUOLAbstract:init()
    -- self.requireAuroraOrbAPI = false
    self.RequireAPI = { }
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
    if self.ActiveOrb or self.DefaultOrb.Loaded then
        return
    end

    for enum_val, data in pairs(ModernUOLAbstract.SupportedOrbwalkers) do
        if data.Valid() then
            self:OnAsyncLoad(enum_val)
            return
        end
    end

    if not self.DefaultOrb.Val then
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

    time = math.max(time or 0, 15)
    self.DefaultOrb.Val = val
    self.DefaultOrb.Time = os.clock() + time
end

function ModernUOLAbstract:AllRequireApiLoaded()
    for _, data in pairs(self.RequireAPI) do
        if not data.loaded then return false end
    end

    return true
end

function ModernUOLAbstract:OnAsyncLoad(val)
    if self.ActiveOrb and self:AllRequireApiLoaded() then return end

    -- AuroraBot loaded, set class to variable
    if val == _G.PaidScript.AURORA_ORB then
        self.AuroraOrbApi = _G.AuroraOrb
    end

    -- If it's a required script loaded mark it as loaded
    for _, data in pairs(self.RequireAPI) do
        if data.index == val then data.loaded = true end
    end

    -- Orbwalker Loaded, check for require api loaded
    if self.ActiveOrb and #self.RequireAPI > 0 then
        for _, data in pairs(self.RequireAPI) do
            if not data.loaded then return end
        end

        -- All required orb loaded, fire the on load champ script
        for i = 1, #self.OrbLoadCallbacks do
            self.OrbLoadCallbacks[i](val)
        end

    end

    if self.ActiveOrb then return end

    local valid_func = ModernUOLAbstract.SupportedOrbwalkers[val] and ModernUOLAbstract.SupportedOrbwalkers[val].Valid

    if valid_func and valid_func() then
        self.ActiveOrb = val
        

        if table.getn(self.RequireAPI) == 0 or self:AllRequireApiLoaded() then -- No orb api needed, fire on load
            for i = 1, #self.OrbLoadCallbacks do
                self.OrbLoadCallbacks[i](val)
            end
        else
            for _, data in pairs(self.RequireAPI) do
                if val ~= data.index then _G.LoadPaidScriptAsync(data.index, function() end) end
            end
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

function ModernUOLAbstract:RequireOrbApi(index)
    local data = {
        index = index,
        loaded = false
    }

    table.insert(self.RequireAPI, data)
end

function ModernUOLAbstract:GetOrbApi(index)
    return ModernUOLAbstract.SupportedOrbwalkers[index].Valid()
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
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:IsAttacking()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:IsAttacking()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return not _G.MED.CanMove()
    end
end

--[[
    function: ModernUOL:IsOrbWalking()
    Parameter: None
    Return: Boolean
    Comment: Return true if my hero is orbwalking
--]]
function ModernUOL:IsOrbWalking()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:IsOrbWalking()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:IsOrbwalking()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.InAction()
    end
end

--[[
    function: ModernUOL:CanAttack()
    Parameter: None
    Return: Boolean
    Comment: Return true if my hero can auto attack
--]]
function ModernUOL:CanAttack()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:CanAttack()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:CanAttack()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.CanAttack()
    end
end

--[[
    function: ModernUOL:CanMove()
    Parameter: None
    Return: Boolean
    Comment: Return true if my hero can move without cancel auto attack
--]]
function ModernUOL:CanMove()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:CanMove()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:CanMove()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.CanMove()
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
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:MoveTo(position)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:Move(position)
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.ToMove(position)
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
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:Attack(object)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:Attack(object)
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.ToAttack(object)
    end
end

--[[
    function: ModernUOL:BlockAttack()
    Parameter:
        1. boolean
    Return: nil
    Comment: Block/Unblock orbwalker attack
--]]
function ModernUOL:BlockAttack(bool)
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:BlockAttack(bool)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:BlockAttack(bool)
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return bool and _G.MED.BlockAttack(math.huge) or _G.MED.BlockAttack(0)
    end
end

--[[
    function: ModernUOL:BlockMove()
    Parameter:
        1. boolean
    Return: nil
    Comment: Block/Unblock Orbwalker movement
--]]
function ModernUOL:BlockMove(bool)
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:BlockMove(bool)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:BlockMove(bool)
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return bool and _G.MED.BlockAttack(math.huge) or _G.MED.BlockAttack(0)
    end
end

--[[
    function: ModernUOL:IsAttackBlocked()
    Parameter: None
    Return: boolean
    Comment: Return if orbwalker attack is currently blocked
--]]
function ModernUOL:IsAttackBlocked()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:IsAttackBlocked()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:IsAttackBlocked()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.IsAttackBlocked()
    end
end

--[[
    function: ModernUOL:IsMoveBlocked()
    Parameter: None
    Return: boolean
    Comment: Return if orbwalker movement is currently blocked
--]]
function ModernUOL:IsMoveBlocked()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:IsMoveBlocked()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:IsMoveBlocked()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.IsMovementBlocked()
    end
end

--[[
    function: ModernUOL:GetMode()
    Parameter: None
    Return: string ("Combo", "Waveclear", "Harass", "Lasthit", "Support", "none")
    Comment: Return active orbwalker mode
--]]
function ModernUOL:GetMode()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:GetMode()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        if _G.AuroraOrb.Orbwalker:IsComboKeyPress() then return "Combo"
        elseif _G.AuroraOrb.Orbwalker:IsLaneClearKeyPress() then return "Waveclear"
        elseif _G.AuroraOrb.Orbwalker:IsLastHitKeyPress() then return "Lasthit"
        elseif _G.AuroraOrb.Orbwalker:IsSupportKeyPress() then return "Support"
        elseif _G.AuroraOrb.Orbwalker:IsMixedKeyPress() then return "Harass"
        else return "none" end
    elseif self.ActiveOrb == _G.PaidScript.MED then
        local map = {["carry"] = "Combo", ["mixed"] = "Harass", ["last_hit"] = "Lasthit", ["lane_clear"] = "Waveclear", ["jungle_clear"] = "Waveclear"}

        return map[_G.MED.GetOrbwalkerMode()] or "none"
    end
end

--[[
    function: ModernUOL:ResetAA()
    Parameter: None
    Return: nil
    Comment: Reset orbwalker auto attack cooldown
--]]
function ModernUOL:ResetAA()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:ResetAA()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:ResetAttack()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.ResetAutoAttack()
    end
end

--[[
    function: ModernUOL:GetTarget(range, position)
    Parameter: int, D3DXVECTOR3
    Return: gameObject or nil
    Comment: Return hero target
--]]
function ModernUOL:GetTarget(range, position)
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:GetHeroTarget(range, position)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:GetTargetSelectorTarget(range, position)
    elseif self.ActiveOrb == _G.PaidScript.MED then
        _G.MED.GetTarget(range, position)
    end
end

--[[
    function: ModernUOL:GetCurrentTarget()
    Parameter: None
    Return: gameObject or nil
    Comment: Returns the current orbwalker target (can be all unit)
--]]
function ModernUOL:GetCurrentTarget()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:GetTarget()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:GetCurrentTarget()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.GetOrbwalkerTarget()
    end
end

--[[
    function: ModernUOL:SetTarget(target, time)
    Parameter: gameObject, time (optional and in second)
    Return: nil
    Comment: Force Orbwalker to target the given gameOject during time (time is optional)
--]]
function ModernUOL:SetTarget(target, time)
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:SetTarget(target, time)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:SetTarget(target, time)
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.ForceTarget(target)
    end
end

--[[
    function: ModernUOL:UnSetTarget()
    Parameter: None
    Return: nil
    Comment: Unset the forced target
--]]
function ModernUOL:UnSetTarget()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:UnSetTarget()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:UnSetTarget()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.RemoveForcedTarget()
    end
end

--[[
    function: ModernUOL:GetForcedTarget()
    Parameter: None
    Return: gameObject or nil
    Comment: Get forced target object
--]]
function ModernUOL:GetForcedTarget()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:GetForcedTarget()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:GetForcedTarget()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.GetForcedTarget()
    end
end

--[[
    function: ModernUOL:WaitingForMinion()
    Parameter: None
    Return: boolean
    Comment: Return true if orbwalker is waiting for a minion to last hit
--]]
function ModernUOL:WaitingForMinion()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:WaitingForMinion()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:WaitingForMinion()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.WaitingForMinion()
    end
end

--[[
    function: ModernUOL:GetMinions()
    Parameter: None
    Return: table
    Comment: Return only minions present on lane (mage, cannon, melee, super)
--]]
function ModernUOL:GetMinions()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:GetMinions()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Minion:GetEnemy(function(a) return _G.AuroraOrb.Minion:IsLaneMinion(a) end)
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return ObjectManager:GetEnemyMinions() -- to do
    end
end

--[[
    function: ModernUOL:HpPred(unit, time)
    Parameter: gameObject, time (sec)
    Return: float
    Comment: Return predicted unit health after the given time
--]]
function ModernUOL:HpPred(unit, time)
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:HpPred(unit, time)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Health:Get(unit, time * 1000)
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.GetPredictedHealth(unit, time)
    end
end

--[[
    function: ModernUOL:AutoAttackCooldown()
    Parameter: None
    Return: float
    Comment: Return the next auto attack time in second
--]]
function ModernUOL:AutoAttackCooldown()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:AutoAttackCooldown()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:GetAutoAttackCooldownRemaining()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.GetNextAutoAttackTime()
    end
end

--[[
    function: ModernUOL:AutoAttackOnCooldown()
    Parameter: None
    Return: boolean
    Comment: Return if auto attack is on cooldown
--]]
function ModernUOL:AutoAttackOnCooldown()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:AutoAttackOnCooldown()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:AutoAttackOnCooldown()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        return _G.MED.WaitingForNextAutoAttack()
    end
end

--[[
    function: ModernUOL:AttackSpeed()
    Parameter: None
    Return: float
    Comment: Return the actual attack speed of myHero
--]]
function ModernUOL:AttackSpeed()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:AttackSpeed()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.MyHero:GetAttackSpeed()
    elseif self.ActiveOrb == _G.PaidScript.MED then
        local attackSpeed = myHero.characterIntermediate.baseAttackSpeed * myHero.characterIntermediate.attackSpeedMod -- to do
        return attackSpeed
    end
end

--[[
    function: ModernUOL:GetProjectileSpeed(gameObject)
    Parameter: gameObject
    Return: int
    Comment: Return projectile speed of given gameObject
--]]
function ModernUOL:GetProjectileSpeed(gameObject)
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:GetProjectileSpeed(gameObject)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:GetProjectileSpeed(gameObject)
     elseif self.ActiveOrb == _G.PaidScript.MED then
        local missileSpeed = gameObject.basicAttack.speed > 0 and gameObject.basicAttack.speed or math.huge -- to do
        return missileSpeed
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
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:AddCallback(callback, func)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        if callback == "OnUnKillable" then return _G.AuroraOrb.Orbwalker:RegisterOnMinionNonLastHitableFunction(func)
        elseif callback == "OnAttack" then return _G.AuroraOrb.Orbwalker:RegisterOnPreAttackFunction(func)
        elseif callback == "OnAfterAttack" then return  _G.AuroraOrb.Orbwalker:RegisterOnPostAttackFunction(func)
        elseif callback == "OnBeforeAttack" then return  _G.AuroraOrb.Orbwalker:RegisterOnPreAttackFunction(func)
        elseif callback == "OnBeforeMovement" then return  _G.AuroraOrb.Orbwalker:RegisterOnBeforeMovementFunction(func)
        elseif callback == "CanMove" then return  _G.AuroraOrb.Orbwalker:RegisterOnCanMoveFunction(func)
        elseif callback == "CanAttack" then return  _G.AuroraOrb.Orbwalker:RegisterOnCanAttackFunction(func) end
    elseif self.ActiveOrb == _G.PaidScript.MED then -- to do
        if callback == "OnAfterAttack" then return  _G.MED.AddAfterAttackCallback(func)
        elseif callback == "OnBeforeMovement" then return _G.MED.AddPreMovementCallback(func)
        elseif callback == "OnBeforeAttack" then return _G.MED.AddPreAttackCallback(func) end
    end
end

--[[
    function: ModernUOL:RemoveCallback(func)
    Parameter: function
    Return: nil
    Comment: Remove a function from callback
--]]
function ModernUOL:RemoveCallback(func)
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:RemoveCallback(func)
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:RemoveCallback(func)
    end
end

--[[
    function: ModernUOL:GetCallbacks()
    Parameter: function
    Return: table
    Comment: Get table of registered callback
--]]
function ModernUOL:GetCallbacks()
    if IS_LEGIT_ORB_COMPATIBLE[self.ActiveOrb] then
        return _G.LegitOrbwalker:GetCallbacks()
    elseif self.ActiveOrb == _G.PaidScript.AURORA_ORB then
        return _G.AuroraOrb.Orbwalker:GetCallbacks()
    end
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- SPECIFIC AURORAORB

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

return ModernUOL()
