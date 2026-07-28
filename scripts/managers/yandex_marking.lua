-- scripts/managers/yandex_marking.lua
-- Управление индикатором разметки геймплея Yandex SDK (GameplayAPI.start/stop)
local yagames = require("yagames.yagames")

local yandex_marking = {}

function yandex_marking.start()
	local ok, err = pcall(yagames.features_gameplayapi_start)
	if not ok then
		print("YaGames gameplay marking (start) error:", err)
	end
end

function yandex_marking.stop()
	local ok, err = pcall(yagames.features_gameplayapi_stop)
	if not ok then
		print("YaGames gameplay marking (stop) error:", err)
	end
end

return yandex_marking