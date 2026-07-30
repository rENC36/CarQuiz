-- scripts/menu/menu_settings.lua

local localization_manager = require("scripts.managers.localization_manager")
local ui = require("scripts.shared.ui_helpers")
local C = require("scripts.menu.menu_constants")

local menu_settings = {}

function menu_settings.sync_visual(self)
	ui.toggle_pair("on_music_text", "off_music_text", self.music_on)
	ui.toggle_pair("on_sound_text", "off_sound_text", self.sound_on)

	local current_lang = localization_manager.current_lang or "ru"
	local is_ru = (current_lang == "ru")
	ui.toggle_pair("lang_ru", "lang_eng", is_ru)

	sound.set_group_gain(hash("music"), self.music_on and 1 or 0)
	sound.set_group_gain(hash("sfx"),   self.sound_on  and 1 or 0)
end

local function handle_music_toggle(self, screen_settings, action)
	if not gui.is_enabled(screen_settings, true) then return end
	local pressed_on  = ui.is_node_pressed("on_music_box",  action.x, action.y)
	local pressed_off = ui.is_node_pressed("off_music_box", action.x, action.y)
	if not pressed_on and not pressed_off then return end
	if self.music_on and pressed_on then return end

	self.music_on = pressed_on
	ui.toggle_pair("on_music_text", "off_music_text", self.music_on)
	sound.set_group_gain(hash("music"), self.music_on and 1 or 0)
	msg.post("/music#sound", self.music_on and "play_sound" or "stop_sound")
end

local function handle_sound_toggle(self, screen_settings, action)
	if not gui.is_enabled(screen_settings, true) then return end
	local pressed_on  = ui.is_node_pressed("on_sound_box",  action.x, action.y)
	local pressed_off = ui.is_node_pressed("off_sound_box", action.x, action.y)
	if not pressed_on and not pressed_off then return end

	self.sound_on = pressed_on
	ui.toggle_pair("on_sound_text", "off_sound_text", self.sound_on)
	sound.set_group_gain(hash("sfx"), self.sound_on and 1 or 0)
end

local function handle_lang_toggle(self, screen_settings, action)
	if not gui.is_enabled(screen_settings, true) then return end
	local pressed_on  = ui.is_node_pressed("lang_ru_box",   action.x, action.y)
	local pressed_off = ui.is_node_pressed("lang_eng_box",  action.x, action.y)
	if not pressed_on and not pressed_off then return end

	ui.toggle_pair("lang_ru", "lang_eng", pressed_on)
	localization_manager.init(pressed_on and "ru" or "en", "settings")
	localization_manager.apply_to_all()
	
	msg.post("/gameplay#gameplay", "update_language")
end

function menu_settings.handle_toggles(self, action)
	local screen_settings = gui.get_node("screen_settings")
	handle_music_toggle(self, screen_settings, action)
	handle_sound_toggle(self, screen_settings, action)
	handle_lang_toggle(self, screen_settings, action)
end

return menu_settings