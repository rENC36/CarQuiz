-- scripts/menu/menu_ads.lua

local save_manager = require("scripts.managers.save_manager")
local yagames = require("yagames.yagames")
local C = require("scripts.menu.menu_constants")

local menu_ads = {}

local function on_open()
	print("Реклама открыта")
	msg.post("/music#sound", "play_sound")
end

local function on_rewarded()
	print("Награда засчитана!")
	save_manager.add_coins(C.AD_REWARD_COINS)
	msg.post("/music#sound", "play_sound")
end

local function on_close()
	print("Реклама закрыта")
	local updated_save = save_manager.load()
	gui.set_text(gui.get_node("txt_total_coins"), "$ " .. updated_save.coins)
	msg.post("/music#sound", "play_sound")
end

local function on_error(err)
	print("Ошибка показа рекламы:", err)
	msg.post("/music#sound", "play_sound")
end

function menu_ads.show_rewarded()
	msg.post("/music#sound", "pause_sound")
	gui.set_enabled(gui.get_node("ad_block"), false)

	yagames.adv_show_rewarded_video({
		open     = on_open,
		rewarded = on_rewarded,
		close    = on_close,
		error    = on_error,
	})
end

function menu_ads.init_yagames(self)
	yagames.init(function(err)
		if err then
			print("YaGames init error:", err)
		else
			print("YaGames SDK готов")
			yagames.features_loadingapi_ready()

			local menu_leaderboard = require("scripts.menu.menu_leaderboard")
			menu_leaderboard.fetch(self)

			yagames.player_init({}, function(self, err)
				if err then
					print("Ошибка инициализации player:", err)
				else
					print("Player готов. Авторизован:", yagames.player_is_authorized())
				end
			end)
		end
	end)
end

return menu_ads