local M = {}

local SAVE_PATH = sys.get_save_file("CarQuiz", "save.json")

local DEFAULT_SAVE = {
	coins = 0,
	score = 0,
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
	-- сохраняем только лучший результат
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

return M