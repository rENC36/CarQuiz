-- scripts/menu/menu_leaderboard.lua

local yagames = require("yagames.yagames")
local C = require("scripts.menu.menu_constants")

local menu_leaderboard = {}

local function display(self, entries)
	for _, node in ipairs(self.leaderboard_clones) do
		gui.delete_node(node)
	end
	self.leaderboard_clones = {}

	local template = self.leaderboard_template
	local base_pos = self.leaderboard_base_pos

	for i, entry in ipairs(entries) do
		local clone_ids = gui.clone_tree(template)
		local root_node = clone_ids[gui.get_id(template)]

		gui.set_enabled(root_node, true)
		local pos = gui.get_position(root_node)
		pos.y = base_pos.y - (i - 1) * 70
		gui.set_position(root_node, pos)

		gui.set_text(clone_ids[hash("Stat_Number1")], tostring(entry.rank))
		gui.set_text(clone_ids[hash("Stat_Name1")],   entry.player and entry.player.publicName or "Игрок")
		gui.set_text(clone_ids[hash("Stat_Money1")],  tostring(entry.score))

		table.insert(self.leaderboard_clones, root_node)
	end
end

function menu_leaderboard.fetch(self)
	yagames.leaderboards_get_entries(C.LEADERBOARD_NAME, { quantityTop = 10 }, function(self, err, result)
		if err then
			print("Ошибка получения лидерборда:", err)
		else
			display(self, result.entries)
		end
	end)
end

function menu_leaderboard.setup_template(self)
	self.leaderboard_clones = {}
	local template = gui.get_node("Stat1")
	self.leaderboard_template = template
	self.leaderboard_base_pos = gui.get_position(template)
	gui.set_enabled(template, false)
end

return menu_leaderboard