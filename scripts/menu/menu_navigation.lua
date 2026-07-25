-- scripts/menu/menu_navigation.lua

local save_manager = require("scripts.managers.save_manager")
local C = require("scripts.menu.menu_constants")

local menu_navigation = {}

local function get_category_unlocked(difficulty)
	if difficulty == "easy" then return true end
	local prev = difficulty == "medium" and "easy" or "medium"
	for lvl = 1, 3 do
		if save_manager.get_stars(prev, lvl) == 0 then return false end
	end
	return true
end

local function update_category_progress()
	local difficulties = C.DIFFICULTIES
	local nodes = {"Easy", "Medium", "Hard"}

	for i, diff in ipairs(difficulties) do
		local completed = 0
		for lvl = 1, 3 do
			if save_manager.get_stars(diff, lvl) > 0 then completed = completed + 1 end
		end

		local pct = math.floor((completed / 3) * 100)
		local completed_node = gui.get_node(nodes[i] .. "Completed")
		gui.set_text(completed_node, completed .. "/3 (" .. pct .. "%)")

		if completed == 3 then
			gui.set_color(completed_node, C.COLORS.gold)
		end

		local state = C.BAR_STATES[completed]
		local bar = gui.get_node("progress_bar_line_" .. diff)

		local color = gui.get_color(bar)
		color.w = state.alpha
		gui.set_color(bar, color)

		local scale = gui.get_scale(bar)
		scale.x = state.scale_x
		gui.set_scale(bar, scale)

		local pos = gui.get_position(bar)
		pos.x = state.pos_x
		gui.set_position(bar, pos)
	end
end

local function update_categories_screen()
	for _, diff in ipairs(C.DIFFICULTIES) do
		local btn_node = gui.get_node("btn_" .. diff)
		local names = C.CATEGORY_NODE_NAMES[diff]
		local name_node = gui.get_node(names.name)
		local percent_node = gui.get_node(names.percent)
		local unlocked = get_category_unlocked(diff)

		if not unlocked then
			gui.play_flipbook(btn_node, hash("btn_closed2.1"))
			gui.set_color(btn_node, C.COLORS.white)
			if name_node then gui.set_color(name_node, C.COLORS.dimmed) end
			if percent_node then gui.set_enabled(percent_node, false) end
			gui.set_enabled(gui.get_node("progress_bar_background_" .. diff), false)
			gui.set_enabled(gui.get_node("progress_bar_line_" .. diff), false)
		else
			gui.play_flipbook(btn_node, hash("btn_gray_open2"))
			gui.set_color(btn_node, C.COLORS.white)
			if name_node then gui.set_color(name_node, C.COLORS.white) end
			if percent_node then
				gui.set_color(percent_node, C.COLORS.white)
				gui.set_enabled(percent_node, true)
			end
			gui.set_enabled(gui.get_node("progress_bar_background_" .. diff), true)
			gui.set_enabled(gui.get_node("progress_bar_line_" .. diff), true)
		end
	end
	update_category_progress()
end

function menu_navigation.change(self, name)
	for _, screen_name in ipairs(C.SCREENS) do
		if screen_name == "categories" then
			update_categories_screen()
		end
		gui.set_enabled(gui.get_node("screen_" .. screen_name), screen_name == name)
	end

	if name == "leaderboard" then
		local menu_leaderboard = require("scripts.menu.menu_leaderboard")
		menu_leaderboard.fetch(self)
	end
end

function menu_navigation.get_category_unlocked(difficulty)
	return get_category_unlocked(difficulty)
end

return menu_navigation