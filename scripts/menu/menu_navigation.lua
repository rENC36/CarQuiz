-- scripts/menu/menu_navigation.lua
local buttons_data = require("scripts.data.buttons_data")

local save_manager = require("scripts.managers.save_manager")
local localization_manager = require("scripts.managers.localization_manager")
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

local function update_category_progress(self)
	local difficulties = C.DIFFICULTIES
	local nodes = {"easy", "medium", "hard"}
	local MAX_STARS_PER_CATEGORY = 9

	for i, diff in ipairs(difficulties) do
		local completed = 0
		local total_stars = 0

		for lvl = 1, 3 do
			local stars = save_manager.get_stars(diff, lvl)
			total_stars = total_stars + stars
			if stars > 0 then completed = completed + 1 end
		end

		local pct = math.floor((total_stars / MAX_STARS_PER_CATEGORY) * 100)
		gui.set_text(gui.get_node(nodes[i] .. "Completed"), completed .. "/3 (" .. pct .. "%)")

		local is_perfect = total_stars == MAX_STARS_PER_CATEGORY

		if is_perfect then
			gui.set_color(gui.get_node(nodes[i] .. "Completed"), vmath.vector4(1,1,0,1))
			local btn_node_id = "btn_" .. nodes[i]
			local btn = self.buttons_by_node[btn_node_id]
			if btn then
				btn.color = vmath.vector4(1,1,0,1)
				btn.hover = vmath.vector4(1,1,0,1)
				gui.set_color(gui.get_node(btn_node_id), vmath.vector4(1,1,0,1))
			else
				print("Кнопка не найдена в buttons_data:", btn_node_id)
			end
		end
		
		local bar = gui.get_node("progress_bar_line_" .. diff)

		local state_from, state_to, t

		if total_stars <= 3 then
			state_from = C.BAR_STATES[0]
			state_to = C.BAR_STATES[1]
			t = total_stars / 3
		elseif total_stars <= 6 then
			state_from = C.BAR_STATES[1]
			state_to = C.BAR_STATES[2]
			t = (total_stars - 3) / 3
		else
			state_from = C.BAR_STATES[2]
			state_to = C.BAR_STATES[3]
			t = (total_stars - 6) / 3
		end

		-- Alpha: 0 если 0 звёзд, 1 если больше 0
		local alpha = total_stars > 0 and 1 or 0

		local scale_x = state_from.scale_x + (state_to.scale_x - state_from.scale_x) * t
		local pos_x = state_from.pos_x + (state_to.pos_x - state_from.pos_x) * t

		local color = gui.get_color(bar)
		color.w = alpha
		gui.set_color(bar, color)

		local scale = gui.get_scale(bar)
		scale.x = scale_x
		gui.set_scale(bar, scale)

		local pos = gui.get_position(bar)
		pos.x = pos_x
		gui.set_position(bar, pos)
	end
end

local function update_categories_screen(self)
	for _, diff in ipairs(C.DIFFICULTIES) do
		local btn_node = gui.get_node("btn_" .. diff)
		local names = C.CATEGORY_NODE_NAMES[diff]
		local name_node = gui.get_node(names.name)
		local percent_node = gui.get_node(names.percent)
		local unlocked = get_category_unlocked(diff)

		if not unlocked then
			gui.play_flipbook(btn_node, hash("btn_closed2.2"))
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
	update_category_progress(self)
end

function menu_navigation.change(self, name)
	for _, screen_name in ipairs(C.SCREENS) do
		if screen_name == "categories" then
			update_categories_screen(self)
		end
		gui.set_enabled(gui.get_node("screen_" .. screen_name), screen_name == name)
	end

	localization_manager.apply_to_screen(name)

	if name == "leaderboard" then
		local menu_leaderboard = require("scripts.menu.menu_leaderboard")
		menu_leaderboard.request_access(self, function()
			menu_leaderboard.fetch(self)
		end)
	end
end

function menu_navigation.get_category_unlocked(difficulty)
	return get_category_unlocked(difficulty)
end

return menu_navigation