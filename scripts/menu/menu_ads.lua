-- scripts/menu/menu_ads.lua

local save_manager = require("scripts.managers.save_manager")
local sound_manager = require("scripts.managers.sound_manager")
local localization_manager = require("scripts.managers.localization_manager")
local ad_timer = require("scripts.managers.ad_timer")
local yagames = require("yagames.yagames")
local C = require("scripts.menu.menu_constants")

local menu_ads = {}
local is_yagames_initialized = false

local timer_update_handle = nil

local function update_timer_display()
	local node = gui.get_node("ad_timer")

	if ad_timer.can_show_rewarded() then
		gui.set_text(node, "5:00")
	else
		local remaining = ad_timer.get_remaining_time()
		gui.set_text(node, ad_timer.format_time(remaining))
	end
end

local function start_timer_update()
	if not timer_update_handle then
		timer_update_handle = timer.delay(1.0, true, function()
			update_timer_display()
		end)
	end
end

local function on_open()
	print("Реклама открыта")
end

local function on_rewarded()
	print("Награда засчитана!")
	save_manager.add_coins(C.AD_REWARD_COINS)
	save_manager.sync_leaderboard()
	ad_timer.mark_rewarded_shown()
	update_timer_display()
	start_timer_update()
end

local function on_close()
	print("Реклама закрыта")
	local updated_save = save_manager.load()
	gui.set_text(gui.get_node("txt_total_coins"), "$ " .. updated_save.coins)
	sound_manager.restore_after_ads("menu")
end

local function on_error(err)
	print("Ошибка показа рекламы:", err)
	sound_manager.restore_after_ads("menu")
end

function menu_ads.show_rewarded()
	if not ad_timer.can_show_rewarded() then
		local remaining = ad_timer.get_remaining_time()
		print("Реклама недоступна. Подождите: " .. ad_timer.format_time(remaining))
		return false
	end

	sound_manager.mute_for_ads()
	gui.set_enabled(gui.get_node("ad_block"), false)
	yagames.adv_show_rewarded_video({
		open     = on_open,
		rewarded = on_rewarded,
		close    = on_close,
		error    = on_error,
	})
	return true
end

local function apply_player_language(self)
	local ok, env = pcall(yagames.environment)
	local lang = "en"
	if ok and env and env.i18n and env.i18n.lang then
		lang = env.i18n.lang
	else
		print("Не удалось определить язык через YaGames, используется 'en' по умолчанию")
	end

	if lang ~= "ru" then
		lang = "en"
	end
	localization_manager.init(lang, "menu")

	local menu_settings = require("scripts.menu.menu_settings")
	menu_settings.sync_visual(self)
end

function menu_ads.init_yagames(self)
	if is_yagames_initialized then
		local menu_leaderboard = require("scripts.menu.menu_leaderboard")
		menu_leaderboard.fetch(self)
		start_timer_update()
		return
	end
	yagames.init(function(self, err)
		if err then
			print("YaGames init error:", err)
			return
		end
		is_yagames_initialized = true
		print("YaGames SDK готов")
		yagames.features_loadingapi_ready()
		apply_player_language(self)
		local menu_leaderboard = require("scripts.menu.menu_leaderboard")
		menu_leaderboard.fetch(self)
		yagames.player_init({}, function(self, err)
			if err then
				print("Ошибка инициализации player:", err)
			else
				print("Player готов. Авторизован:", yagames.player_is_authorized())
			end
		end)
		start_timer_update()
	end)
end

local pending_interstitial_callback = nil

local function on_interstitial_open()
	print("Полноэкранная реклама открыта")
	sound_manager.mute_for_ads()
end

local function on_interstitial_close(self, was_shown)
	print("Полноэкранная реклама закрыта. Была показана:", was_shown)
	sound_manager.restore_after_ads("menu")

	if pending_interstitial_callback then
		local cb = pending_interstitial_callback
		pending_interstitial_callback = nil
		cb()
	end
end

local function on_interstitial_offline()
	print("Нет сети — реклама недоступна")
end

local function on_interstitial_error(self, err)
	print("Ошибка полноэкранной рекламы:", err)
end

function menu_ads.show_interstitial(on_complete)
	pending_interstitial_callback = on_complete
	yagames.adv_show_fullscreen_adv({
		open    = on_interstitial_open,
		close   = on_interstitial_close,
		offline = on_interstitial_offline,
		error   = on_interstitial_error,
	})
end

return menu_ads