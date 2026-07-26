-- scripts/gameplay/gameplay_manager.lua

local localization_manager = require("scripts.managers.localization_manager")
local yandex_marking = require("scripts.managers.yandex_marking")

local gameplay_levels = require("scripts.gameplay.gameplay_levels")
local gameplay_hints  = require("scripts.gameplay.gameplay_hints")
local gameplay_ui     = require("scripts.gameplay.gameplay_ui")

local gameplay_manager = {}

function gameplay_manager.init(self)
	msg.post(".", "acquire_input_focus")

	self.paused = false
	self.settings_open = false

	window.set_listener(function(event, data)
		if event == window.WINDOW_EVENT_FOCUS_LOST then
			self.paused = true
			yandex_marking.stop() 
		elseif event == window.WINDOW_EVENT_FOCUS_GAINED then
			if not self.help_open and not self.settings_open then
				self.paused = false
				yandex_marking.start()
			end
		end
	end)

	self.answered = false
	self.timer = 10
	self.timer_played = false
	self.difficulty = "easy"
	self.level_num = 1
	self.ad_block_hint_type = nil
	self.ad_block_is_purchase = false

	self.data = {
		{ node = "btn_answer_1", color = vmath.vector4(1, 1, 1, 1), hover = vmath.vector4(1, 1, 1, 1), anim_color = false },
		{ node = "btn_answer_2", color = vmath.vector4(1, 1, 1, 1), hover = vmath.vector4(1, 1, 1, 1), anim_color = false },
		{ node = "btn_answer_3", color = vmath.vector4(1, 1, 1, 1), hover = vmath.vector4(1, 1, 1, 1), anim_color = false },
		{ node = "btn_answer_4", color = vmath.vector4(1, 1, 1, 1), hover = vmath.vector4(1, 1, 1, 1), anim_color = false },
		{ node = "btn_hint_skip",  color = vmath.vector4(1, 1, 1, 1), hover = vmath.vector4(1, 1, 1, 1), anim_color = false },
		{ node = "btn_hint_5050",  color = vmath.vector4(1, 1, 1, 1), hover = vmath.vector4(1, 1, 1, 1), anim_color = false },
		{ node = "btn_no",  color = vmath.vector4(1, 1, 1, 1), hover = vmath.vector4(1, 1, 1, 1), anim_color = false },
		{ node = "btn_yes", color = vmath.vector4(1, 1, 1, 1), hover = vmath.vector4(1, 1, 1, 1), anim_color = false },
	}

	self.answer_buttons = {
		{ node = "btn_answer_1", text = "txt_answer_1" },
		{ node = "btn_answer_2", text = "txt_answer_2" },
		{ node = "btn_answer_3", text = "txt_answer_3" },
		{ node = "btn_answer_4", text = "txt_answer_4" },
	}

	gameplay_ui.init_help_menu(self)
end

function gameplay_manager.on_message(self, message_id, message)
	if message_id == hash("start_game") then
		localization_manager.init(localization_manager.current_lang, "gameplay")
		gameplay_levels.start(self, message.difficulty, message.level_num or 1, message.music_play)
	elseif message_id == hash("resume_from_settings") then
		self.settings_open = false
		self.paused = false
		gameplay_ui.resume_game_audio(self)
		yandex_marking.start()
	end
end

function gameplay_manager.update(self, dt)
	gameplay_levels.update_timer(self, dt)
end

function gameplay_manager.on_input(self, action_id, action)
	if self.settings_open then return end
	if not gui.is_enabled(gui.get_node("top_bar"), true) then return end

	local is_ad_block_active = gui.is_enabled(gui.get_node("ad_block"))

	if action_id == hash("touch") and action.pressed then
		if is_ad_block_active then
			if gui.pick_node(gui.get_node("btn_no"), action.x, action.y) then
				gui.set_enabled(gui.get_node("ad_block"), false)
			elseif gui.pick_node(gui.get_node("btn_yes"), action.x, action.y) then
				gameplay_hints.ad_block_yes(self)
			end
			return
		end

		local btn_help = gui.get_node("open_help_menu")
		if gui.is_enabled(btn_help, true) and gui.pick_node(btn_help, action.x, action.y) then
			gameplay_ui.open_help_menu(self)
			return
		end

		if gameplay_ui.handle_help_menu_input(self, action.x, action.y) then
			return
		end

		local btn_5050 = gui.get_node("btn_hint_5050")
		if gui.is_enabled(btn_5050, true) and gui.pick_node(btn_5050, action.x, action.y) then
			gameplay_hints.use_hint_5050(self)
			return
		end

		local btn_skip = gui.get_node("btn_hint_skip")
		if gui.is_enabled(btn_skip, true) and gui.pick_node(btn_skip, action.x, action.y) then
			gameplay_hints.use_hint_skip(self)
			return
		end

		for i, btn in ipairs(self.answer_buttons) do
			local node = gui.get_node(btn.node)
			if gui.pick_node(node, action.x, action.y) then
				gameplay_levels.select_answer(self, i)
				break
			end
		end
	end

	if self.help_open and action_id == nil and not is_ad_block_active then
		gameplay_ui.process_help_menu_hover(self, action)
	else
		gameplay_ui.process_hover(action_id, action, self)
	end
end

return gameplay_manager