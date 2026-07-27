-- scripts/gameplay/gameplay_ui.lua

local anim_manager = require("scripts.managers.anim_manager")
local save_manager = require("scripts.managers.save_manager")
local yandex_marking = require("scripts.managers.yandex_marking")
local C = require("scripts.gameplay.gameplay_constants")

local gameplay_ui = {}

local function get_category_unlocked(difficulty)
	if difficulty == "easy" then return true end
	local prev = difficulty == "medium" and "easy" or "medium"
	for lvl = 1, 3 do
		if save_manager.get_stars(prev, lvl) == 0 then
			return false
		end
	end
	return true
end

local function apply_hover_out(node, btn)
	local size = btn.defaultsize or vmath.vector3(1, 1, 1)
	if get_category_unlocked(btn.difficulty) or btn.difficulty == nil then
		anim_manager.hover_out(node, btn.color, size, btn.anim_color, btn.anim_scale)
	else
		gui.animate(node, gui.PROP_SCALE, size, gui.EASING_OUT, 0.1, 0)
	end
end

local function apply_hover_in(node, btn)
	local size = btn.hoversize or vmath.vector3(1.03, 1.03, 1)
	if get_category_unlocked(btn.difficulty) or btn.difficulty == nil then
		anim_manager.hover_in(node, btn.hover, size, btn.anim_color, btn.anim_scale)
	else
		gui.animate(node, gui.PROP_SCALE, size, gui.EASING_OUT, 0.1, 0)
	end
end

function gameplay_ui.process_hover(action_id, action, self)
	if action_id ~= nil then return end
	if self.answered then return end

	local is_ad_block_active = gui.is_enabled(gui.get_node("ad_block"))
	for _, btn in pairs(self.data) do
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
					end
				elseif btn.hovered then
					btn.hovered = false
					apply_hover_out(node, btn)
				end
			end
		end
	end
end

function gameplay_ui.init_help_menu(self)
	self.help_open = false

	self.help_buttons = {
		{ node = gui.get_node("btn_continue"), hovered = false },
		{ node = gui.get_node("btn_settings"), hovered = false },
		{ node = gui.get_node("btn_main_menu"), hovered = false },
	}

	for i, btn in ipairs(self.help_buttons) do
		local pos = gui.get_position(btn.node)
		if not self.help_buttons_original_pos then
			self.help_buttons_original_pos = {}
		end
		self.help_buttons_original_pos[i] = pos
	end

	local menu_node = gui.get_node("help_menu")
	self.help_menu_original_pos = gui.get_position(menu_node)

	gui.set_position(menu_node, vmath.vector3(
	self.help_menu_original_pos.x + C.HELP_PANEL_OFFSET_X,
	self.help_menu_original_pos.y,
	self.help_menu_original_pos.z))

	gui.set_enabled(menu_node, false)
end

function gameplay_ui.open_help_menu(self)
	if self.help_open then return end
	self.help_open = true
	self.paused = true
	gameplay_ui.pause_game_audio(self)
	yandex_marking.stop()

	gui.set_enabled(gui.get_node("help_menu"), true)

	gui.animate(gui.get_node("help_menu"), "position.x",
	self.help_menu_original_pos.x, gui.EASING_OUTBACK, C.HELP_ANIM_TIME)

	for i, btn in ipairs(self.help_buttons) do
		local delay = C.HELP_ANIM_TIME * 0.4 + (i - 1) * 0.06
		local orig_pos = self.help_buttons_original_pos[i]

		gui.set_position(btn.node, vmath.vector3(orig_pos.x - 40, orig_pos.y, orig_pos.z))
		gui.set_alpha(btn.node, 0)

		gui.animate(btn.node, "position.x", orig_pos.x, gui.EASING_OUTBACK, C.HELP_ANIM_TIME * 0.7, delay)
		gui.animate(btn.node, gui.PROP_COLOR, vmath.vector4(1, 1, 1, 1), gui.EASING_OUTQUAD, C.HELP_ANIM_TIME * 0.6, delay)
	end
end

-- Модифицирован: теперь принимает опциональный callback
function gameplay_ui.close_help_menu(self, on_complete)
	if not self.help_open then return end
	self.help_open = false
	self.paused = false
	gameplay_ui.resume_game_audio(self)
	yandex_marking.start() 

	for _, btn in ipairs(self.help_buttons) do
		btn.hovered = false
		gui.animate(btn.node, gui.PROP_COLOR, vmath.vector4(1, 1, 1, 0), gui.EASING_INQUAD, C.HELP_ANIM_TIME * 0.3)
	end

	gui.animate(gui.get_node("help_menu"), "position.x",
	self.help_menu_original_pos.x + C.HELP_PANEL_OFFSET_X,
	gui.EASING_INQUAD, C.HELP_ANIM_TIME * 0.7, 0,
	function()
		gui.set_enabled(gui.get_node("help_menu"), false)
		if on_complete then
			on_complete()
		end
	end)
end

function gameplay_ui.process_help_menu_hover(self, action)
	if not self.help_open then return end

	for _, btn in ipairs(self.help_buttons) do
		if gui.pick_node(btn.node, action.x, action.y) then
			if not btn.hovered then
				btn.hovered = true
				gui.animate(btn.node, gui.PROP_SCALE, vmath.vector3(1.05, 1.05, 1), gui.EASING_OUT, 0.15, 0)
				gui.animate(btn.node, gui.PROP_COLOR, vmath.vector4(1.1, 1.1, 1.1, 1), gui.EASING_OUT, 0.15, 0)
			end
		elseif btn.hovered then
			btn.hovered = false
			gui.animate(btn.node, gui.PROP_SCALE, vmath.vector3(1, 1, 1), gui.EASING_OUT, 0.15, 0)
			gui.animate(btn.node, gui.PROP_COLOR, vmath.vector4(1, 1, 1, 1), gui.EASING_OUT, 0.15, 0)
		end
	end
end

function gameplay_ui.handle_help_menu_input(self, x, y)
	if not self.help_open then return false end

	if gui.pick_node(gui.get_node("btn_continue"), x, y) then
		gameplay_ui.close_help_menu(self)
		return true
	end

	if gui.pick_node(gui.get_node("btn_settings"), x, y) then
		gameplay_ui.open_settings_from_pause(self)
		return true
	end

	if gui.pick_node(gui.get_node("btn_main_menu"), x, y) then
		yandex_marking.stop()
		gameplay_ui.stop_game_audio(self)
		
		gameplay_ui.close_help_menu(self, function()
			msg.post("/gameplay#gameplay", "disable")
		end)
		
		msg.post("/menu#menu", "enable")
		return true
	end

	return false
end

function gameplay_ui.open_settings_from_pause(self)
	self.help_open = false
	self.settings_open = true

	for _, btn in ipairs(self.help_buttons) do
		btn.hovered = false
		gui.animate(btn.node, gui.PROP_COLOR, vmath.vector4(1, 1, 1, 0), gui.EASING_INQUAD, C.HELP_ANIM_TIME * 0.3)
	end

	gui.animate(gui.get_node("help_menu"), "position.x",
	self.help_menu_original_pos.x + C.HELP_PANEL_OFFSET_X,
	gui.EASING_INQUAD, C.HELP_ANIM_TIME * 0.7, 0,
	function()
		gui.set_enabled(gui.get_node("help_menu"), false)
		msg.post("/menu#menu", "open_settings")
	end)
end

function gameplay_ui.pause_game_audio(self)
	msg.post("/music#sound_gameplay", "pause_sound")
	msg.post("/music#sound_timer", "stop_sound")
	self.timer_played = false
end

function gameplay_ui.resume_game_audio(self)
	if self.music_on ~= false then
		msg.post("/music#sound_gameplay", "play_sound")
	end
end

function gameplay_ui.stop_game_audio(self)
	msg.post("/music#sound_gameplay", "stop_sound")
	msg.post("/music#sound_timer", "stop_sound")
end

return gameplay_ui