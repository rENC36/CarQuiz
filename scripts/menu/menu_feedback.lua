-- scripts/menu/menu_feedback.lua
local yagames = require("yagames.yagames")

local menu_feedback = {}

local already_requested_this_session = false

function menu_feedback.request_review(on_result)
	if already_requested_this_session then
		if on_result then on_result(false, "ALREADY_REQUESTED_THIS_SESSION") end
		return
	end

	yagames.feedback_can_review(function(self, err, result)
		if err then
			print("Ошибка проверки доступности отзыва:", err)
			if on_result then on_result(false, "ERROR") end
			return
		end

		if not result.value then
			print("Оценка недоступна. Причина:", result.reason or "unknown")
			if on_result then on_result(false, result.reason) end
			return
		end

		already_requested_this_session = true

		yagames.feedback_request_review(function(self, err, result)
			if err then
				print("Ошибка запроса отзыва:", err)
				if on_result then on_result(false, "ERROR") end
				return
			end

			if result.feedbackSent then
				print("Игрок оценил игру!")
				if on_result then on_result(true) end
			else
				print("Игрок закрыл диалог оценки без оценки")
				if on_result then on_result(false, "DISMISSED") end
			end
		end)
	end)
end

return menu_feedback