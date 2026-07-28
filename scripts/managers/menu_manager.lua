-- scripts/menu/menu_manager.lua

local save_manager = require("scripts.managers.save_manager")
local localization_manager = require("scripts.managers.localization_manager")
local buttons_data = require("scripts.data.buttons_data")

local menu_navigation  = require("scripts.menu.menu_navigation")
local menu_settings    = require("scripts.menu.menu_settings")
local menu_levels      = require("scripts.menu.menu_levels")
local menu_leaderboard = require("scripts.menu.menu_leaderboard")
local menu_ads         = require("scripts.menu.menu_ads")
local menu_hover       = require("scripts.menu.menu_hover")
local menu_actions     = require("scripts.menu.menu_actions")
local menu_feedback	   = require("scripts.menu.menu_feedback")

local menu_manager = {}

local function play_click_sound(self)
	if self.sound_on then
		msg.post("/music#sound_click", "play_sound")
	end
end

local function calculate_total_progress()
	local total_stars, total_levels = 0, 0
	for _, diff in ipairs({"easy", "medium", "hard"}) do
		for lvl = 1, 3 do
			local stars = save_manager.get_stars(diff, lvl)
			total_stars = total_stars + stars
			if stars > 0 then total_levels = total_levels + 1 end
		end
	end
	return total_stars, total_levels
end

function menu_manager.init(self)
	local save_data = save_manager.load()
	print("Монет в сохранении: " .. save_data.coins)
	gui.set_text(gui.get_node("txt_total_coins"), save_data.coins)

	self.sound_on = true
	self.music_on = true
	self.buttons = buttons_data

	self.buttons_by_node = {}
	for _, btn in ipairs(self.buttons) do
		self.buttons_by_node[btn.node] = btn
	end
	
	menu_navigation.change(self, "menu")
	print("Menu init работает!")

	local total_stars, total_levels = calculate_total_progress()
	gui.set_text(gui.get_node("StarsOutput"),  total_stars  .. "/27")
	gui.set_text(gui.get_node("LevelsOutput"), total_levels .. "/9")

	localization_manager.init(localization_manager.current_lang, "menu")
	menu_leaderboard.setup_template(self)
	menu_settings.sync_visual(self)
	menu_ads.init_yagames(self)

	save_manager.sync_leaderboard()
end

function menu_manager.on_message(self, message_id, message)
	if message_id == hash("show_result") then  
		if self.music_on then msg.post("/music#sound", "play_sound") end

		local save_data = save_manager.load()
		gui.set_text(gui.get_node("txt_total_coins"), save_data.coins)

		gui.set_text(gui.get_node("txt_result_title"),  message.win and "УРОВЕНЬ ПРОЙДЕН!" or "ПРОИГРЫШ")
		gui.set_text(gui.get_node("txt_result_coins"),  "Монет: +" .. message.coins)
		gui.set_text(gui.get_node("txt_result_errors"), message.errors)
		gui.set_text(gui.get_node("txt_result_time"),   message.time)

		local is_final_level = message.win and message.difficulty == "hard" and message.level_num == 3
		gui.set_enabled(gui.get_node("btn_result_next"), not is_final_level)

		if message.difficulty == "easy" and message.level_num == 3 then
			menu_feedback.request_review(function()
				print("Оценка игры выполнена")
			end)
		end

		local total_stars, total_levels = calculate_total_progress()
		gui.set_text(gui.get_node("StarsOutput"),  total_stars  .. "/27")
		gui.set_text(gui.get_node("LevelsOutput"), total_levels .. "/9")

		for i = 1, 3 do
			local color = i <= message.stars and vmath.vector4(1,1,1,1) or vmath.vector4(0,0,0,.5)
			gui.set_color(gui.get_node("star" .. i .. "_result"), color)
		end

		self.last_difficulty = message.difficulty or "easy"
		self.last_level = message.level_num or 1
		self.last_win = message.win

		menu_navigation.change(self, "result")
		
		gui.set_text(gui.get_node("txt_result_next"),
		localization_manager.get(message.win and "result_next_win" or "result_next_lose", "menu"))
		
		msg.post("/music#" .. (message.win and "sound_win" or "sound_defeat"), "play_sound")
	elseif message_id == hash("open_settings") then
		msg.post("/gameplay#gameplay", "force_close_help_menu")

		self.opened_settings_from_gameplay = true
		msg.post("/menu#menu", "enable")
		menu_navigation.change(self, "settings")
	elseif message_id == hash("open_main_menu") then
		menu_navigation.change(self, "menu")
	end
end

function menu_manager.on_input(self, action_id, action)
	if action_id == hash("touch") and action.released then
		local is_ad_block_active = gui.is_enabled(gui.get_node("ad_block"))

		if not is_ad_block_active then
			menu_settings.handle_toggles(self, action)
		end

		for _, btn in ipairs(self.buttons) do
			if is_ad_block_active and btn.node ~= "btn_no" and btn.node ~= "btn_yes" then

			else
				local node = gui.get_node(btn.node)
				if gui.is_enabled(node, true) and gui.pick_node(node, action.x, action.y) then
					print(btn.node .. " нажато")
					play_click_sound(self)
					
					if btn.node == "close_screen_settings" and self.opened_settings_from_gameplay then
						self.opened_settings_from_gameplay = false
						msg.post("/menu#menu", "disable")
						msg.post("/gameplay#gameplay", "resume_from_settings")
					elseif btn.node == "btn_result_next" or btn.node == "exit_result" then
						menu_ads.show_interstitial(function()
							menu_actions.handle(self, btn)
						end)
					else
						menu_actions.handle(self, btn)
					end

					break
				end
			end
		end
	end

	menu_hover.process(self, action_id, action)
end
return menu_manager