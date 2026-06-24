local data = require("scripts.data")
local M = {}

function M.generate_level(difficulty, level_num)
	local level_key = "level_" .. level_num
	local pool = {}
	
	for _, car in ipairs(data.categories[difficulty][level_key]) do
		table.insert(pool, car)
	end
	
	for i = #pool, 2, -1 do
		local j = math.random(i)
		pool[i], pool[j] = pool[j], pool[i]
	end
	
	local questions = {}
	local all_names = {}
	
	for _, car in ipairs(pool) do
		table.insert(all_names, car.name)
	end

	for i, car in ipairs(pool) do
		local wrong = {}
		for j, name in ipairs(all_names) do
			if j ~= i then
				table.insert(wrong, name)
			end
		end
		
		for k = #wrong, 2, -1 do
			local r = math.random(k)
			wrong[k], wrong[r] = wrong[r], wrong[k]
		end
		
		local answers = {car.name, wrong[1], wrong[2], wrong[3]}
		for k = #answers, 2, -1 do
			local r = math.random(k)
			answers[k], answers[r] = answers[r], answers[k]
		end
		
		local correct_index = 1
		for k, ans in ipairs(answers) do
			if ans == car.name then
				correct_index = k
				break
			end
		end

		table.insert(questions, {
			img = car.id,
			image = car.image,
			correct = correct_index,
			answers = answers
		}) 
	end

	return questions
end

return M