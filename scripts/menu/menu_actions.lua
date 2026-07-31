-- scripts/menu/menu_actions.lua

local save_manager = require("scripts.managers.save_manager")
local menu_navigation = require("scripts.menu.menu_navigation")
local menu_levels = require("scripts.menu.menu_levels")
local menu_ads = require("scripts.menu.menu_ads")
local ad_timer = require("scripts.managers.ad_timer")

local yagames = require("yagames.yagames")

local actions = {}

actions.btn_menu_ad = function()
	if not ad_timer.can_show_rewarded() then
		local remaining = ad_timer.get_remaining_time()
		print("Реклама в cooldown. Подождите: " .. ad_timer.format_time(remaining))
		return
	end

	gui.set_enabled(gui.get_node("ad_block"), true)
	gui.set_enabled(gui.get_node("blur"), true)
end

actions.btn_no = function()
	gui.set_enabled(gui.get_node("ad_block"), false)
	gui.set_enabled(gui.get_node("blur"), false)
end

actions.btn_yes = function()
	menu_ads.show_rewarded()
end

actions.btn_2x = function()
	gui.set_enabled(gui.get_node("ad_block_result"), true)
	gui.set_enabled(gui.get_node("blur1"), true)
end

actions.btn_result_next = function(self)
	local next_diff, next_lvl = menu_levels.get_next_level(
	self.last_difficulty, self.last_level, self.last_win)

	actions._start_game(self, next_diff, next_lvl)
end

actions.exit_result = function(self)
	self.opened_settings_from_gameplay = false
	msg.post("/gameplay#gameplay", "disable")
	menu_navigation.change(self, "menu")
end

actions.close_screen_settings = function(self)
	menu_navigation.change(self, "menu")
end

actions.btn_leaderboard = function(self)
	local ok, is_authorized = pcall(yagames.player_is_authorized)
	if ok and is_authorized then
		menu_navigation.change(self, "leaderboard")
	else
		gui.set_enabled(gui.get_node("leaderboard_block"), true)
		gui.set_enabled(gui.get_node("blur2"), true) 
	end
end

function actions._start_game(self, difficulty, level_num)
	msg.post("/gameplay#gameplay", "enable")
	msg.post("/menu#menu", "disable")
	msg.post("/gameplay#gameplay", "start_game", {
		difficulty = difficulty,
		level_num = level_num,
		music_play = self.music_on,
	})
end

function actions.handle(self, btn)
	local specific = actions[btn.node]
	if specific then
		specific(self)
		return
	end

	if btn.target == "levels" then
		if menu_navigation.get_category_unlocked(btn.difficulty) then
			self.selected_difficulty = btn.difficulty
			menu_navigation.change(self, "levels")
			menu_levels.show(self, btn.difficulty)
		end
		return
	end

	if btn.target == "gameplay" and btn.level_num then
		local locked = btn.level_num > 1
		and save_manager.get_stars(self.selected_difficulty, btn.level_num - 1) == 0
		if not locked then
			actions._start_game(self, self.selected_difficulty, btn.level_num)
		end
		return
	end

	if btn.target then
		menu_navigation.change(self, btn.target)
	end
end

return actions