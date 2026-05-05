require("TRCommands")
require("PGStateMachine")
require("deepcore/std/class")

---@class AbilityAreaEffectHeal
AbilityAreaEffectHeal = class()

function AbilityAreaEffectHeal:new()

	self.areaeffectheal = "AREA_EFFECT_HEAL"
    self.object_owner = Object.Get_Owner()
    self.all_units_of_player = {}
    self.low_health_count = 0
end

function AbilityAreaEffectHeal:update()
	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | update:")
	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | Ability Is Ready:"..tostring(Object.Is_Ability_Ready(self.areaeffectheal)),tostring(Script))

	if Object.Is_Ability_Ready(self.areaeffectheal) ~= true then
		return
	end

    self:Friendly_Units()
    self:clean_friendly_units()

	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | Owner is Human:"..tostring(Object.Get_Owner().Is_Human()),tostring(Script))
	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | Ability Is Autofire:"..tostring(Object.Is_Ability_Autofire(self.areaeffectheal)),tostring(Script))

	local Health = Object.Get_Hull()

    self:count_low_health_friendlies()
	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | Count of low HP units GreaterThan 9:"..tostring(self.low_health_count > 9),tostring(Script))
	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | Object Health:"..tostring(Health),tostring(Script))
	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | Object Health less then threshold:"..tostring(Health < 0.5),tostring(Script))

	local Protect_Target = false

    local human = self.object_owner.Is_Human()
    local autofire_enabled = Object.Is_Ability_Autofire(self.areaeffectheal)

	if (human and autofire_enabled) or not human then
        if Health < 0.5 then
            Protect_Target = true
        elseif self.low_health_count > 9 then
            Protect_Target = true
        end
    end

	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | Protect_Target:"..tostring(Protect_Target),tostring(Script))

	if Protect_Target == true then
    	Object.Activate_Ability(self.areaeffectheal, true)
	end

    self.all_units_of_player = {}
    self.low_health_count = 0
end

function AbilityAreaEffectHeal:Friendly_Units()
	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | area_effect_heal_prox_trigger function:")

    self.all_units_of_player = Find_All_Objects_Of_Type("Organic", self.object_owner) or {}
end

function AbilityAreaEffectHeal:count_low_health_friendlies()
	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | count_low_health_friendlies:")

	for _, unit in ipairs(self.all_units_of_player) do
		if TestValid(unit) then
			local hp = unit.Get_Hull()
			if hp < 0.5 then
				self.low_health_count = self.low_health_count + 1
			end
		end
	end

	-- DebugMessage(GetCurrentTime().."Rhino | AreaEffectHeal | Count of low HP units: "..tostring(self.low_health_count), tostring(Script))
	return self.low_health_count
end

function AbilityAreaEffectHeal:clean_friendly_units()
	local cleaned = {}
	for _, unit in ipairs(self.all_units_of_player) do
		if TestValid(unit) and unit.Get_Distance(Object) < 150 then
            if unit ~= Object then
			    table.insert(cleaned, unit)
            end
		end
	end
	self.all_units_of_player = cleaned
end

return AbilityAreaEffectHeal