-- scripts/menu/menu_leaderboard.lua
local yagames = require("yagames.yagames")
local save_manager = require("scripts.managers.save_manager")
local C = require("scripts.menu.menu_constants")

local menu_leaderboard = {}

local HIGHLIGHT_COLOR = vmath.vector4(1, 1, 1, 1)
local YOU_LABEL = "Вы"

local function get_own_unique_id()
	local ok, is_authorized = pcall(yagames.player_is_authorized)
	if not ok or not is_authorized then
		return nil
	end
	local ok2, own_id = pcall(yagames.player_get_unique_id)
	if not ok2 or not own_id or own_id == "" then
		return nil
	end
	return own_id
end

local function find_own_entry_index(entries, own_id)
	if not own_id then return nil end
	for i, entry in ipairs(entries) do
		if entry.player and entry.player.uniqueID == own_id then
			return i
		end
	end
	return nil
end

local function clear_own_row_clone(self)
	if self.own_row_clone then
		gui.delete_node(self.own_row_clone)
		self.own_row_clone = nil
	end
end

local function update_own_row_fallback(self)
	gui.set_enabled(self.own_row_template, true)

	yagames.leaderboards_get_player_entry(C.LEADERBOARD_NAME, nil, function(self, err, result)
		if err then
			local save_data = save_manager.load()
			gui.set_text(gui.get_node("Stat_Number"), "—")
			gui.set_text(gui.get_node("Stat_Money"), tostring(save_data.coins))
			return
		end

		gui.set_text(gui.get_node("Stat_Number"), tostring(result.rank + 1))
		gui.set_text(gui.get_node("Stat_Money"), tostring(result.score))
	end)
end

local function display(self, entries)
	for _, node in ipairs(self.leaderboard_clones) do
		gui.delete_node(node)
	end
	self.leaderboard_clones = {}
	clear_own_row_clone(self)

	local template = self.leaderboard_template
	local base_pos = self.leaderboard_base_pos

	local own_id = get_own_unique_id()
	local own_index = find_own_entry_index(entries, own_id)

	for i, entry in ipairs(entries) do
		local pos_y = base_pos.y - (i - 1) * 63

		if i == own_index then
			local clone_ids = gui.clone_tree(self.own_row_template)
			local root_node = clone_ids[gui.get_id(self.own_row_template)]

			gui.set_enabled(root_node, true)
			gui.set_color(root_node, HIGHLIGHT_COLOR)

			local pos = gui.get_position(root_node)
			pos.y = pos_y
			gui.set_position(root_node, pos)

			gui.set_text(clone_ids[hash("Stat_Number")], tostring(entry.rank))
			gui.set_text(clone_ids[hash("Stat_Name")],   YOU_LABEL)
			gui.set_text(clone_ids[hash("Stat_Money")],  tostring(entry.score))

			self.own_row_clone = root_node
		else
			local clone_ids = gui.clone_tree(template)
			local root_node = clone_ids[gui.get_id(template)]
			gui.set_enabled(root_node, true)

			local pos = gui.get_position(root_node)
			pos.y = pos_y
			gui.set_position(root_node, pos)

			gui.set_text(clone_ids[hash("Stat_Number1")], tostring(entry.rank))
			gui.set_text(clone_ids[hash("Stat_Name1")],   entry.player and entry.player.publicName or "Игрок")
			gui.set_text(clone_ids[hash("Stat_Money1")],  tostring(entry.score))

			table.insert(self.leaderboard_clones, root_node)
		end
	end

	if own_index then
		gui.set_enabled(self.own_row_template, false)
	elseif own_id then
		update_own_row_fallback(self)
	else
		gui.set_enabled(self.own_row_template, true)
		local save_data = save_manager.load()
		gui.set_text(gui.get_node("Stat_Number"), "—")
		gui.set_text(gui.get_node("Stat_Money"), tostring(save_data.coins))
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
	self.own_row_clone = nil

	local template = gui.get_node("Stat1")
	self.leaderboard_template = template
	self.leaderboard_base_pos = gui.get_position(template)
	gui.set_enabled(template, false)

	local own_row_template = gui.get_node("Stat")
	self.own_row_template = own_row_template
	self.own_row_base_pos = gui.get_position(own_row_template)
end

local function ensure_player_ready(callback)
	local ok, is_authorized = pcall(yagames.player_is_authorized)
	if ok then
		callback(is_authorized)
	else
		yagames.player_init({}, function(self, err)
			if err then
				callback(false)
			else
				callback(yagames.player_is_authorized())
			end
		end)
	end
end

function menu_leaderboard.request_access(self, callback)
	ensure_player_ready(function(is_authorized)
		if is_authorized then
			callback()
		else
			yagames.auth_open_auth_dialog(function(self2, err)
				if err then
					print("Авторизация отменена или не удалась:", err)
				else
					yagames.player_init({}, function() end)
				end
				callback()
			end)
		end
	end)
end

return menu_leaderboard