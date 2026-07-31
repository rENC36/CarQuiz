-- scripts/menu/menu_manager.lua

local yagames = require("yagames.yagames")

local save_manager = require("scripts.managers.save_manager")
local localization_manager = require("scripts.managers.localization_manager")
local sound_manager = require("scripts.managers.sound_manager")
local buttons_data = require("scripts.data.buttons_data")
local app_focus = require("scripts.managers.app_focus")

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
	app_focus.init() 
	app_focus.set_context("menu")
	
	sound_manager.init()

	local save_data = save_manager.load()
	print("Монет в сохранении: " .. save_data.coins)
	gui.set_text(gui.get_node("txt_total_coins"), save_data.coins)

	self.sound_on = save_data.sound_on
	self.music_on = save_data.music_on
	
	sound_manager.set_music_on(self.music_on)
	sound_manager.set_sound_on(self.sound_on)

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
end

function menu_manager.on_message(self, message_id, message)
	if message_id == hash("show_result") then  
		if self.music_on then msg.post("/music#sound", "play_sound") end

		local save_data = save_manager.load()
		gui.set_text(gui.get_node("txt_total_coins"), save_data.coins)

		self.last_coins = message.coins
		self.double_reward_used = false
		
		gui.set_enabled(gui.get_node("btn_2x"), message.win)
		gui.set_enabled(gui.get_node("ad_block_result"), false)
		gui.set_enabled(gui.get_node("blur1"), false)

		gui.set_text(gui.get_node("txt_result_title"), 
		localization_manager.get(message.win and "result_win" or "result_lose", "menu"))
		
		gui.set_text(gui.get_node("txt_result_coins"), 
		localization_manager.get("result_coins", "menu") .. message.coins)

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
		local save_data = save_manager.load()

		menu_navigation.change(self, "menu")
		menu_leaderboard.fetch(self)
		gui.set_text(gui.get_node("txt_total_coins"), save_data.coins)
	end
end

function menu_manager.on_input(self, action_id, action)
	if action_id == hash("touch") and action.released then
		local is_ad_block_active = gui.is_enabled(gui.get_node("ad_block"))
		local is_ad_block_result_active = gui.is_enabled(gui.get_node("ad_block_result"))
		local is_leaderboard_block_active = gui.is_enabled(gui.get_node("leaderboard_block"))
		
		if is_leaderboard_block_active then
			local btn_auth_yes = gui.get_node("btn_auth_yes")
			local btn_auth_no = gui.get_node("btn_auth_no")

			if gui.pick_node(btn_auth_no, action.x, action.y) then
				print("btn_auth_no нажато")
				play_click_sound(self)
				gui.set_enabled(gui.get_node("leaderboard_block"), false)
				gui.set_enabled(gui.get_node("blur2"), false)
				return
			end

			if gui.pick_node(btn_auth_yes, action.x, action.y) then
				print("btn_auth_yes нажато")
				play_click_sound(self)
				gui.set_enabled(gui.get_node("leaderboard_block"), false)
				gui.set_enabled(gui.get_node("blur2"), false)

				local ok, err = pcall(yagames.auth_open_auth_dialog, function(self2, err)
					if err then
						print("Авторизация отменена или не удалась:", err)
						return 
					end
					yagames.player_init({}, function(self3, init_err)
						if init_err then
							print("Ошибка инициализации player после авторизации:", init_err)
							return
						end
						local ok2, is_authorized = pcall(yagames.player_is_authorized)
						if ok2 and is_authorized then
							menu_navigation.change(self, "leaderboard") 
						else
							print("Авторизация не подтверждена — лидерборд не открываем")
						end
					end)
				end)
				if not ok then
					print("Ошибка вызова диалога авторизации:", err)
				end
				return
			end
			return
		end
		
		if is_ad_block_result_active then
			local btn_yes_result = gui.get_node("btn_yes_result")
			local btn_no_result = gui.get_node("btn_no_result")

			if gui.pick_node(btn_no_result, action.x, action.y) then
				print("btn_no_result нажато")
				play_click_sound(self)
				gui.set_enabled(gui.get_node("ad_block_result"), false)
				gui.set_enabled(gui.get_node("blur1"), false)
				self.double_reward_used = false
				return
			end

			if gui.pick_node(btn_yes_result, action.x, action.y) then
				print("btn_yes_result нажато")
				play_click_sound(self)
				gui.set_enabled(gui.get_node("ad_block_result"), false)
				gui.set_enabled(gui.get_node("blur1"), false)
				menu_ads.show_double_reward(self.last_coins, function(doubled)
					if doubled then
						gui.set_enabled(gui.get_node("btn_2x"), false)
					else
						self.double_reward_used = false
					end
				end)
				return
			end
			return
		end
		
		if is_ad_block_active then
			local btn_no = gui.get_node("btn_no")
			local btn_yes = gui.get_node("btn_yes")

			if gui.pick_node(btn_no, action.x, action.y) then
				print("btn_no нажато")
				play_click_sound(self)
				gui.set_enabled(gui.get_node("ad_block"), false)
				gui.set_enabled(gui.get_node("blur"), false)
				return
			end

			if gui.pick_node(btn_yes, action.x, action.y) then
				print("btn_yes нажато")
				play_click_sound(self)
				gui.set_enabled(gui.get_node("ad_block"), false)
				gui.set_enabled(gui.get_node("blur"), false)
				menu_ads.show_rewarded()
				return
			end
			return
		end

		if not is_ad_block_active then
			menu_settings.handle_toggles(self, action)
		end

		for _, btn in ipairs(self.buttons) do
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
				elseif btn.node == "btn_2x" then
					if self.double_reward_used or not self.last_coins or self.last_coins <= 0 then
						print("Удвоение недоступно: уже использовано или нечего удваивать")
					else
						self.double_reward_used = true
						gui.set_enabled(gui.get_node("ad_block_result"), true)
						gui.set_enabled(gui.get_node("blur1"), true)
					end
				else
					menu_actions.handle(self, btn)
				end

				break
			end
		end
	end

	menu_hover.process(self, action_id, action)
end

return menu_manager