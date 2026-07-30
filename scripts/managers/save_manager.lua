-- scripts/managers/save_manager.lua

local yagames = require("yagames.yagames")
local C = require("scripts.menu.menu_constants")

local M = {}

local SAVE_PATH = sys.get_save_file("CarQuiz", "save.json")

local DEFAULT_SAVE = {
	coins = 0,
	score = 0,
	sound_on = true,
	music_on = true,
	progress = {
		easy =   { level_1 = 0, level_2 = 0, level_3 = 0 },
		medium = { level_1 = 0, level_2 = 0, level_3 = 0 },
		hard =   { level_1 = 0, level_2 = 0, level_3 = 0 },
	}
}

function M.load()
	local data = sys.load(SAVE_PATH)
	if not data or not data.coins then
		return DEFAULT_SAVE
	end
	-- На случай если старые сохранения не имеют этих полей
	if data.sound_on == nil then data.sound_on = true end
	if data.music_on == nil then data.music_on = true end
	return data
end

function M.save(data)
	sys.save(SAVE_PATH, data)
end

function M.get_stars(difficulty, level_num)
	local data = M.load()
	local key = "level_" .. level_num
	return data.progress[difficulty][key] or 0
end

function M.set_stars(difficulty, level_num, stars)
	local data = M.load()
	local key = "level_" .. level_num
	if stars > (data.progress[difficulty][key] or 0) then
		data.progress[difficulty][key] = stars
	end
	M.save(data)
end

function M.add_coins(amount)
	local data = M.load()
	data.coins = data.coins + amount
	M.save(data)
	return data.coins
end

function M.add_score(amount)
	local data = M.load()
	data.score = data.score + amount
	M.save(data)
	return data.score
end

function M.set_sound_on(value)
	local data = M.load()
	data.sound_on = value
	M.save(data)
end

function M.set_music_on(value)
	local data = M.load()
	data.music_on = value
	M.save(data)
end

function M.sync_leaderboard()
	local ok, is_authorized = pcall(yagames.player_is_authorized)
	if ok and is_authorized then
		local data = M.load()
		yagames.leaderboards_set_score(C.LEADERBOARD_NAME, data.coins, nil, function(self, err)
			if err then
				print("Не удалось отправить очки в лидерборд:", err)
			end
		end)
	end
end

return M