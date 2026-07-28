-- scripts/menu/menu_levels.lua

local save_manager = require("scripts.managers.save_manager")
local C = require("scripts.menu.menu_constants")

local menu_levels = {}

local function change_level_color(self, color, i)
	for _, btn in ipairs(self.buttons) do
		if btn.node == "btn_level_" .. i then
			gui.set_color(gui.get_node("btn_level_" .. i), color)
			btn.color = color
			btn.hover = color
		end
	end
end

function menu_levels.show(self, difficulty)
	for i = 1, 3 do
		local stars = save_manager.get_stars(difficulty, i)
		local locked = i > 1 and save_manager.get_stars(difficulty, i - 1) == 0

		for s = 1, 3 do
			gui.set_color(gui.get_node("star" .. i .. "_" .. s), s <= stars and C.COLORS.star_on or C.COLORS.star_off)
		end

		local btn_color = locked and C.COLORS.locked or (stars == 3 and C.COLORS.gold or C.COLORS.white)
		gui.set_color(gui.get_node("btn_level_" .. i), btn_color)
		change_level_color(self, btn_color, i)
	end
end

function menu_levels.get_next_level(difficulty, level, won)
	if not won then return difficulty, level end
	if level < 3 then return difficulty, level + 1 end

	local next_diff = { easy = "medium", medium = "hard", hard = "hard" }
	return next_diff[difficulty], difficulty == "hard" and 3 or 1
end

return menu_levels