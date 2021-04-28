local mod = get_mod("krazedkirbengi")
--[increase base HP to 125]:
CareerSettings.dr_engineer.attributes.max_hp = 125
--[allow cranking at max pressure stacks]:
Weapons.bardin_engineer_career_skill_weapon.actions.weapon_reload.default.condition_func = function (action_user, input_extension)
	local talent_extension = ScriptUnit.has_extension(action_user, "talent_system")
	local career_extension = ScriptUnit.has_extension(action_user, "career_system")
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon.actions.weapon_reload.default.chain_condition_func = function (action_user, input_extension)
	local talent_extension = ScriptUnit.has_extension(action_user, "talent_system")
	local career_extension = ScriptUnit.has_extension(action_user, "career_system")
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon_special.actions.weapon_reload.default.condition_func = function (action_user, input_extension)
	local talent_extension = ScriptUnit.has_extension(action_user, "talent_system")
	local career_extension = ScriptUnit.has_extension(action_user, "career_system")
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon_special.actions.weapon_reload.default.chain_condition_func = function (action_user, input_extension)
	local talent_extension = ScriptUnit.has_extension(action_user, "talent_system")
	local career_extension = ScriptUnit.has_extension(action_user, "career_system")
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
ActionCareerDREngineerCharge.client_owner_post_update = function (self, dt, t, world, can_damage)
	local buff_extension = self.buff_extension
	local current_action = self.current_action
	local interval = current_action.ability_charge_interval
	local charge_timer = self.ability_charge_timer + dt

	if interval <= charge_timer then
		local recharge_instances = math.floor(charge_timer / interval)
		charge_timer = charge_timer - recharge_instances * interval
		local wwise_world = self.wwise_world
		local buff_to_add = self._buff_to_add
		local num_stacks = buff_extension:num_buff_type(buff_to_add)
		local buff_type = buff_extension:get_buff_type(buff_to_add)

		if buff_type then
			if not self.last_pump_time then
				self.last_pump_time = t
			end

			local buff_template = buff_type.template

			if t - self.last_pump_time > 10 and buff_template.max_stacks <= num_stacks then
				Managers.state.achievement:trigger_event("clutch_pump", self.owner_unit)
			end

			self.last_pump_time = t
		end

		WwiseWorld.set_global_parameter(wwise_world, "engineer_charge", num_stacks + recharge_instances)

		for i = 1, recharge_instances, 1 do
			buff_extension:add_buff(buff_to_add)
		end
	end

	self.ability_charge_timer = charge_timer
	local current_cooldown = self.career_extension:current_ability_cooldown()
end
BuffTemplates.bardin_engineer_remove_pump_stacks_fire.buffs[1].event = "on_kill"
BuffTemplates.bardin_engineer_remove_pump_stacks_fire.buffs[1].remove_buff_stack_data[1].num_stacks = 1
BuffTemplates.bardin_engineer_remove_pump_stacks_fire.buffs[1].remove_buff_stack_data[2].num_stacks = 1
ProcFunctions.bardin_engineer_remove_pump_stacks_on_fire = function(player, buff, params)
    local player_unit = player.player_unit

    local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
    local wielded_slot = inventory_extension:get_wielded_slot_name()
    if wielded_slot == "slot_career_skill_weapon" then
		ProcFunctions.bardin_engineer_remove_pump_stacks(player, buff, params)
  end
end
--[allow ability regen from melee and ranged attacks]:
PassiveAbilitySettings.dr_4.buffs = {
	"bardin_engineer_passive_no_ability_regen",
	"bardin_engineer_passive_ranged_power_aura",
	"bardin_engineer_passive_max_ammo",
	"bardin_engineer_remove_pump_stacks_fire",
	"kerillian_waywatcher_ability_cooldown_on_hit",
	"victor_zealot_ability_cooldown_on_damage_taken"
}
--[allow engineer to use crossbow in all modes]:
ItemMasterList.dr_crossbow.can_wield = {
	"dr_ironbreaker",
	"dr_ranger",
	"dr_engineer"
}
ItemMasterList.dr_crossbow_magic_01.can_wield = {
	"dr_ironbreaker",
	"dr_ranger",
	"dr_engineer"
}
local function add_career_to_weapon_group(weapons, career)
	for _, weapon in ipairs(weapons) do
		local weapon_group_can_wield = DeusWeaponGroups[weapon].can_wield

		if not table.contains(weapon_group_can_wield, career) then
			table.insert(weapon_group_can_wield, career)
		end
	end
end
if DLCSettings.cog then
	add_career_to_weapon_group({
		"dr_1h_axe",
		"dr_2h_hammer",
		"dr_1h_hammer",
		"dr_2h_axe",
		"dr_2h_pick",
		"dr_shield_axe",
		"dr_shield_hammer",
		"dr_dual_wield_hammers",
		"dr_rakegun",
		"dr_handgun",
		"dr_drakegun",
		"dr_drake_pistol",
		"dr_crossbow"
	}, "dr_engineer")
end
--[regular crank gun uninterruptible]:
Weapons.bardin_engineer_career_skill_weapon.actions.action_one.default.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_one.spin.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_one.fire.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_one.base_fire.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_two.default.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_two.charged.uninterruptible = true
--[Gromril rounds uninterruptible]: 
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.default.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.spin.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.fire.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_two.default.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_two.charged.uninterruptible = true
--[Bombardier bomb radius + duration 25% increase]:
ExplosionTemplates.frag_fire_grenade.explosion.radius = 6.25
ExplosionTemplates.frag_fire_grenade.aoe.radius = 7.5
ExplosionTemplates.frag_fire_grenade.aoe.duration = 6.25
--[Increased Super-Armor damage with Gromril-Plated Shot]:
DamageProfileTemplates.engineer_ability_shot_armor_pierce.armor_modifier_near.attack = {
	1,
	1,
	1,
	1,
	0.5,
	0.4
}
DamageProfileTemplates.engineer_ability_shot_armor_pierce.armor_modifier_far.attack = {
	1,
	1,
	1,
	1,
	0.5,
	0.4
}
--[Bombardier gives bombs at start]:
SimpleInventoryExtension.extensions_ready = function(self, world, unit)
    local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
    self.first_person_extension = first_person_extension
    self._first_person_unit = first_person_extension:get_first_person_unit()
    self.buff_extension = ScriptUnit.extension(unit, "buff_system")
    local career_extension = ScriptUnit.extension(unit, "career_system")
    self.career_extension = career_extension
    local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
    self.talent_extension = talent_extension
    local equipment = self._equipment
    local profile = self._profile
    local unit_1p = self._first_person_unit
    local unit_3p = self._unit

    self:add_equipment_by_category("weapon_slots")
    self:add_equipment_by_category("enemy_weapon_slots")

    local skill_index = (talent_extension and talent_extension:get_talent_career_skill_index()) or 1
    local weapon_index = talent_extension and talent_extension:get_talent_career_weapon_index()
    self.initial_inventory.slot_career_skill_weapon = career_extension:career_skill_weapon_name(skill_index,
                                                          weapon_index)

    self:add_equipment_by_category("career_skill_weapon_slots")

    local additional_inventory = self.initial_inventory.additional_items


    local has_bombardier = self.buff_extension:has_buff_type("bardin_engineer_upgraded_grenades")
	additional_inventory = additional_inventory or {}
    if has_bombardier and additional_inventory then
        table.append(additional_inventory, {{
            slot_name = "slot_grenade",
            item_name = "grenade_frag_02"
        }, {
            slot_name = "slot_grenade",
            item_name = "grenade_fire_02"
        }})
    else
		additional_inventory = {}
    end
    if additional_inventory then
        for i = 1, #additional_inventory, 1 do
            local additional_item = additional_inventory[i]
            local slot_name = additional_item.slot_name
            local item_data = ItemMasterList[additional_item.item_name]
            local slot_data = self:get_slot_data(slot_name)

            if slot_data then
                self:store_additional_item(slot_name, item_data)
            else
                self:add_equipment(slot_name, item_data)
            end
        end
    end

    Unit.set_data(self._first_person_unit, "equipment", self._equipment)

    if profile.default_wielded_slot then
        local default_wielded_slot = profile.default_wielded_slot
        local slot_data = self._equipment.slots[default_wielded_slot]

        if not slot_data then
            table.dump(self._equipment.slots, "self._equipment.slots", 1)
            Application.error("Tried to wield default slot %s for %s that contained no weapon.", default_wielded_slot,
                career_extension:career_name())
        end

        self:_wield_slot(equipment, slot_data, unit_1p, unit_3p)

        local item_data = slot_data.item_data
        local item_template = BackendUtils.get_item_template(item_data)

        self:_spawn_attached_units(item_template.first_person_attached_units)

        local backend_id = item_data.backend_id
        local buffs = self:_get_property_and_trait_buffs(backend_id)

        self:apply_buffs(buffs, "wield", item_data.name, default_wielded_slot)
    end

    self._equipment.wielded_slot = profile.default_wielded_slot
end
--[Updated Linked Compression Chamber movement + dodge after spinning or firing gun]:
ActionCareerDREngineerSpin.client_owner_start_action = function (self, new_action, t)
	ActionCareerDREngineerSpin.super.client_owner_start_action(self, new_action, t)
	self:start_audio_loop()

	self._initial_windup = new_action.initial_windup
	self._windup_max = new_action.windup_max
	self._windup_speed = new_action.windup_speed
	self._current_windup = self.weapon_extension:get_custom_data("windup")
	self._override_visual_spinup = new_action.override_visual_spinup
	self._visual_spinup_min = new_action.visual_spinup_min
	self._visual_spinup_max = new_action.visual_spinup_max
	self._visual_spinup_time = new_action.visual_spinup_time
	self._action_start_t = t
	self._last_update_t = t

	if self.talent_extension:has_talent("bardin_engineer_reduced_ability_fire_slowdown") then
		self._current_windup = 1
		Weapons.bardin_engineer_career_skill_weapon.dodge_count = 3
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.spin.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.6,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.base_fire.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.6,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_two.default.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.6,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_two.charged.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.6,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
	else
		Weapons.bardin_engineer_career_skill_weapon.dodge_count = 1
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.spin.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.2,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.base_fire.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.2,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_two.default.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.2,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_two.charged.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.2,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
	end
end
--[Engi gets ult from melee + ranged but NOT crank gun]:
ProcFunctions.reduce_activated_ability_cooldown = function (player, buff, params)
	local player_unit = player.player_unit
	local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
	local wielded_slot = inventory_extension:get_wielded_slot_name()
	if Unit.alive(player_unit) then
		local attack_type = params[2]
		local target_number = params[4]
		local career_extension = ScriptUnit.extension(player_unit, "career_system")

		if not attack_type or attack_type == "heavy_attack" or attack_type == "light_attack" then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		elseif target_number and target_number == 1 then
			if wielded_slot == "slot_career_skill_weapon" then
				return
			end
				career_extension:reduce_activated_ability_cooldown(buff.bonus)
		end
	end
end
mod:echo("[Engineer Tweaks]: Active")
-- Your mod code goes here.
-- https://vmf-docs.verminti.de
