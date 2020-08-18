--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Class UOL
    -- Initialization functions
    function SetDefaultOrbwalker(paidscript_index, second) -- Will set the default orbwalker to load if no orbwalker manualy loaded in the given second time
        -- paidscript_index: _G.PaidScript.AURORA_ORB, _G.PaidScript.REBORN_ORB
    function RequireAuroraOrbAPI() -- Will force the library to load AuroraOrbAPI if it's another Orbwalker loaded (So you can still have access to the Utility API)
    function OnOrbLoad(entrypoint_function) -- Set your OnLoad function here, this will fire when the library will found one orbwalker loaded

    -- Orbwalkers functions
    function IsAttacking() --  Return true if my hero is attacking
    function IsOrbWalking() -- Return true if my hero is orbwalking
    function CanAttack() -- Return true if my hero can auto attack
    function CanMove() -- Return true if my hero can move without cancel auto attack
    function MoveTo(position) -- Issue order a move to the given position if orbwalker can move
    function Attack(object) -- Issue order a attack to the given object (No range/unit check) if orbwalker can attack
    function BlockAttack(bool) -- Block/Unblock orbwalker attack
    function BlockMove(bool) -- Block/Unblock Orbwalker movement
    function IsAttackBlocked() -- Return if orbwalker attack is currently blocked
    function IsMoveBlocked() -- Return if orbwalker movement is currently blocked
    function GetMode() -- Return active orbwalker mode ("Combo", "Waveclear", "Harass", "Lasthit", "Support", "none")
    function ResetAA() -- Reset orbwalker auto attack cooldown
    function GetTarget(range, position) -- Return current orbwalker target (minions/structures included for LegitOrb)
    function GetHeroTarget(range, position) -- Returns hero target
    function SetTarget(target, time) -- Force Orbwalker to target the given gameOject during time (time is optional)
    function UnSetTarget() -- Unset the forced target
    function GetForcedTarget() --  Get forced target object
    function  WaitingForMinion() -- Return true if orbwalker is waiting for a minion to last hit
    function  GetMinions() -- Return only minions present on lane (mage, cannon, melee, super)
    function HpPred(unit, time) -- Return predicted unit health after the given time
    function AutoAttackCooldown() -- Return the next auto attack time in second
    function AutoAttackOnCooldown() -- Return if auto attack is on cooldown
    function AttackSpeed() -- Return the actual attack speed of myHero
    function GetProjectileSpeed(gameObject) -- Return projectile speed of given gameObject
    function AddCallback(callback, func) -- Register a callback
        -- callback's:
        --    OnUnKillable -- Trigger if it's impossible to last hit | arg: GameObject//minion
        --    OnAttack -- Triggers after an AA is recognized | arg: GameObject//minion
        --    OnAfterAttack -- Triggers after an AA is done | arg: GameObject//minion
        --    OnBeforeAttack -- Triggers just before an AA is recognized | arg: GameObject//minion
        --    OnBeforeMovement -- Triggers just before a movement is recognized | arg: Position
        --    CanMove -- Triggers when the Champion can move again
         --   CanAttack -- Triggers when the Champion can AA again
    function RemoveCallback(func) -- Remove a function from callback
    function GetCallbacks() -- Get table of registered callback

    -- AuroraOrbApi function , ONLY if RequireAuroraOrbAPI() set
    class AuroraOrbApi
        Class Hero
            function GetAll(validator_func) -- Get all heroes including special objects (zac blob)
            function GetAlly(validator_func) -- Get ally heroes including special objects (zac blob)
            function GetEnemy(validator_func) -- Get enemy heroes including special objects (zac blob)
            function IsHero(gameObject) -- Return boolean

        Class Minion
            function GetAll(validator_func) -- Get all minions including special objects (shaco clones, trinket, plants, etc)
            function GetAlly(validator_func) -- Get ally heroes including special objects (shaco clones, trinket, plants, etc)
            function GetEnemy(validator_func) -- Get enemy heroes including special objects (shaco clones, trinket, plants, etc)
            function GetType(gameObject) -- Return int (corresponding to following enum)
                Enum: 
                    None            = 0,
                    Super           = 1,
                    Siege           = 2,
                    Melee           = 3,
                    Ranged          = 4,
                    Pet             = 5,
                    Clone           = 6,
                    Invocation      = 7,
                    Ward            = 8,
                    Plant           = 9,
                    Monster         = 10,
                    Monster_Big     = 11,
                    Monster_Epic    = 12
            function IsMinion(gameObject) -- Return boolean
            function IsLaneMinion(gameObject) -- Return boolean

        Class Structure
            function GetAll(validator_func) -- Get all structures (turret/inhib/nexus)
            function GetAlly(validator_func) -- Get ally structures (turret/inhib/nexus)
            function GetEnemy(validator_func) -- Get enemy structures (turret/inhib/nexus)
            function GetType(gameObject) -- Return int (corresponding to following enum)
                Enum: 
                    None        = 0,
                    Turret      = 1,
                    Inhibitor   = 2,
                    Nexus       = 3
            function IsStructure(gameObject) -- Return boolean

        Class Timer
            function DelayAction(function, delay (ms), function_args (opt)) -- Delay a function
            function GetTime() -- Return current tick count

        Class Utility
            function Hex(a, r, g, b) -- Return formated ARGB color for drawings
            function GetDistance(a, b) -- Return distance between position A and position B
                - a: gameObject or position
                - b: gameObject, position or nil (if nil then myHero.position is take)
            function CursorPosition() -- Return cursor position
            function GetLatency() -- Return latency
            function IsValidTarget(gameObject) -- Return boolean (no distance check)
            function IsValidObject(gameObject) -- Return boolean
            function GetSummonerSlot(summonerspell_name) -- Return SpellSlot.Summoner1/SpellSlot.Summoner2 or nil
            function TableContain(lua_table, element_to_find) -- Return boolean
            function IsResetSpell(spell) -- Return boolean
            function IsAttack(spell) -- return boolean
            function IsNoMoveSpell(spell) -- return boolean
            function IsAnimationReset(animation_name) -- return boolean
            function IsAnimationAttack(animation_name) -- return boolean

        Class Damage
            function GetDamage(caster, target) -- return damage including damage on special objects (trap, wards, trinket, etc)

        Class GangplankBarrel
            function GetAll(validator_func) -- Get all gangplank barrels
            function GetAlly(validator_func) -- Get ally gangplank barrels
            function GetEnemy(validator_func) -- Get enemy gangplank barrels
            function GetHealth(barrel_object, delay) -- Return barrel_object health in given delay
            function IsBarrel(gameObject) -- Return boolean

        class Health
            function Get(gameObject, delay) -- Return unit health after the delay
            function GetPrediction(gameObject, delay1, delay2) -- Return unit health after the first delay, and unit health after the second delay
            function IsAttackInProgress(gameObject_caster, gameObject_target) -- Return boolean

        class MyHero
            function GetBasicAttackRange() -- Return basic attack range
            function IsInAttackRange(gameObject) -- Return boolean
            function GetAttackCastDelay() -- Return attack cast delay in ms
            function GetAttackDelay() -- Return attack delay in ms
            function GetAttackDamage(gameObject) -- Return basic attack damage on gameObject
            function Move(position) -- Move to position
            function Attack(gameObject) -- Attack gameObject (no range check)
            function TimeToHit(gameObject) -- Return time in ms needed to hit gameObject with basic attack
            function CanAttack() -- Return boolean
            function CanMove() -- Return boolean

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Example script

local UOL = require 'ModernUOL' --Load the lib and store the class inside UOL variable

-- Class function
local function class()
    local cls = {}
    cls.__index = cls
    return setmetatable(cls, {__call = function (c, ...)
        local instance = setmetatable({}, cls)
        if cls.__init then
            cls.__init(instance, ...)
        end
        return instance
    end})
end


local Example = class()
function Example:__init()
    UOL:AddCallback("OnAfterAttack", function(target) self:OnAfterAttack(target) end) -- Register a callback, our OnAfterAttack function will fire after each auto attack
    AddEvent(Events.OnTick, function(...) self:OnTick(...) end) -- Add OnTick Event
end

function Example:OnTick()
    if UOL:GetMode() == "Combo" then -- Get Orbwalker mode and check if it's combo active
        -- Combo action here
        print("Combo !!")
    end

    self:LoopEnemyStructures()
end

function Example:LoopEnemyStructures()
    -- Specefic to AuroraOrbApi, you need to have set UOL:RequireAuroraOrbAPI() to use that
    local structures = UOL.AuroraOrbApi.Structure:GetEnemy(function(structure) return UOL.AuroraOrbApi.Utility:IsValidTarget(structure) end)
    for i = 1, #structures do
        local structure = structures[i]
        print("Valid structure: " .. structure.networkId)
        -- I have my valid structure here
    end
end

function Example:OnAfterAttack(target)
    print("Attacked: " .. target.networkId)
end

if not UOL then -- UOL not present on the computer we download it
    DownloadInternalFileAsync('ModernUOL.lua', COMMON_PATH, function(success)
        if success then
            PrintChat("Press F5 to reload")
        end
    end)
else -- UOL Present we can load our script
    UOL:RequireAuroraOrbAPI() -- Will load AuroraOrbAPI even if it's LegitOrb in use
    UOL:SetDefaultOrbwalker(_G.PaidScript.AURORA_ORB, 5) -- Will load AuroraOrb if no orb loaded after 5 secondes
    UOL:OnOrbLoad(function() Example() end) -- Entry point of my script
end