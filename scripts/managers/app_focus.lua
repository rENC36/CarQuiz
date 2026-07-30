-- scripts/managers/app_focus.lua
local sound_manager = require("scripts.managers.sound_manager")
local yandex_marking = require("scripts.managers.yandex_marking")

local app_focus = {}

local current_context = "menu" 
local gameplay_self_ref = nil
local listener_registered = false

function app_focus.set_context(context)
	current_context = context
end

function app_focus.get_context()
	return current_context
end

function app_focus.register_gameplay_self(self)
	gameplay_self_ref = self
end

local function on_focus_lost()
	sound_manager.mute_for_ads() 

	if current_context == "gameplay" and gameplay_self_ref then
		gameplay_self_ref.paused = true
		yandex_marking.stop()
	end
end

local function on_focus_gained()
	if current_context == "gameplay" and gameplay_self_ref then
		local should_resume = not gameplay_self_ref.help_open and not gameplay_self_ref.settings_open

		if should_resume then
			sound_manager.restore_after_ads("gameplay")
			gameplay_self_ref.paused = false
			yandex_marking.start()
		else
			sound_manager.restore_after_ads(nil)
		end
	else
		sound_manager.restore_after_ads("menu")
	end
end

function app_focus.init()
	if listener_registered then return end
	listener_registered = true

	window.set_listener(function(self, event, data)
		if event == window.WINDOW_EVENT_FOCUS_LOST then
			on_focus_lost()
		elseif event == window.WINDOW_EVENT_FOCUS_GAINED then
			on_focus_gained()
		end
	end)
end

return app_focus