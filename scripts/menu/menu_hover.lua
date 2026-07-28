-- scripts/menu/menu_hover.lua

local anim_manager = require("scripts.managers.anim_manager")
local menu_navigation = require("scripts.menu.menu_navigation")

local menu_hover = {}

local function play_sound_effect(self, state)
	if not self.sound_on then return end
	if state == "hover" then
		msg.post("/music#sound_hover", "play_sound")
	elseif state == "click" then
		msg.post("/music#sound_click", "play_sound")
	end
end

local function apply_hover_out(node, btn)
	local size = btn.defaultsize or vmath.vector3(1, 1, 1)
	if menu_navigation.get_category_unlocked(btn.difficulty) or btn.difficulty == nil then
		anim_manager.hover_out(node, btn.color, size, btn.anim_color, btn.anim_scale)
	else
		gui.animate(node, gui.PROP_SCALE, size, gui.EASING_OUT, 0.1, 0)
	end
end

local function apply_hover_in(node, btn)
	local size = btn.hoversize or vmath.vector3(1.03, 1.03, 1)
	if menu_navigation.get_category_unlocked(btn.difficulty) or btn.difficulty == nil then
		anim_manager.hover_in(node, btn.hover, size, btn.anim_color, btn.anim_scale)
	else
		gui.animate(node, gui.PROP_SCALE, size, gui.EASING_OUT, 0.1, 0)
	end
end

function menu_hover.process(self, action_id, action)
	if action_id ~= nil then return end
	local is_ad_block_active = gui.is_enabled(gui.get_node("ad_block"))

	for _, btn in pairs(self.buttons) do
		if btn.hover ~= nil and btn.color ~= nil then
			local node = gui.get_node(btn.node)
			if is_ad_block_active and btn.node ~= "btn_no" and btn.node ~= "btn_yes" then
				if btn.hovered then
					btn.hovered = false
					apply_hover_out(node, btn)
				end
			else
				if not gui.is_enabled(node, true) then
					btn.hovered = false
					apply_hover_out(node, btn)
				elseif gui.pick_node(node, action.x, action.y) then
					if not btn.hovered then
						btn.hovered = true
						apply_hover_in(node, btn)
						play_sound_effect(self, "hover")
					end
				elseif btn.hovered then
					btn.hovered = false
					apply_hover_out(node, btn)
				end
			end
		end
	end
end

return menu_hover