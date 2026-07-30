local save_manager = require("scripts.managers.save_manager")
local sound_manager = {}

local is_muted = false
local music_on = true
local sound_on = true

local SOUND_GROUPS = {
	"music",
	"sfx",
	"ui",
	"master"
}

local function apply_mute_state()
	local music_gain = (is_muted or not music_on) and 0.0 or 1.0
	sound.set_group_gain("music", music_gain)
	
	local sfx_gain = (is_muted or not sound_on) and 0.0 or 1.0
	sound.set_group_gain("sfx", sfx_gain)
	
	local other_gain = is_muted and 0.0 or 1.0
	sound.set_group_gain("ui", other_gain)
	sound.set_group_gain("master", other_gain)
end

local function load_settings()
	local save = save_manager.load()
	is_muted = save.sound_muted or false
	music_on = save.music_on ~= false
	sound_on = save.sound_on ~= false
	apply_mute_state()
end

function sound_manager.init()
	load_settings()
end

function sound_manager.set_music_on(value)
	music_on = value
	apply_mute_state()
end

function sound_manager.set_sound_on(value)
	sound_on = value
	apply_mute_state()
end

function sound_manager.get_music_on()
	return music_on
end

function sound_manager.get_sound_on()
	return sound_on
end

function sound_manager.mute_all()
	is_muted = true
	apply_mute_state()
	msg.post("/music#sound", "stop_sound")
	msg.post("/music#sound_click", "stop_sound")
	msg.post("/music#sound_correct", "stop_sound")
	msg.post("/music#sound_defeat", "stop_sound")
	msg.post("/music#sound_gameplay", "stop_sound")
	msg.post("/music#sound_hover", "stop_sound")
	msg.post("/music#sound_timer", "stop_sound")
	msg.post("/music#sound_win", "stop_sound")
	msg.post("/music#sound_wrong", "stop_sound")
	local save = save_manager.load()
	save.sound_muted = true
	save_manager.save(save)
end

function sound_manager.unmute_all()
	is_muted = false
	apply_mute_state()
	local save = save_manager.load()
	save.sound_muted = false
	save_manager.save(save)
end

function sound_manager.is_muted()
	return is_muted
end

function sound_manager.toggle_mute()
	if is_muted then
		sound_manager.unmute_all()
	else
		sound_manager.mute_all()
	end
	return is_muted
end

local was_muted_before_ad = nil

function sound_manager.mute_for_ads()
	if was_muted_before_ad ~= nil then return end
	was_muted_before_ad = is_muted
	is_muted = true
	apply_mute_state()
	msg.post("/music#sound", "stop_sound")
	msg.post("/music#sound_click", "stop_sound")
	msg.post("/music#sound_correct", "stop_sound")
	msg.post("/music#sound_defeat", "stop_sound")
	msg.post("/music#sound_gameplay", "stop_sound")
	msg.post("/music#sound_hover", "stop_sound")
	msg.post("/music#sound_timer", "stop_sound")
	msg.post("/music#sound_win", "stop_sound")
	msg.post("/music#sound_wrong", "stop_sound")
end

function sound_manager.restore_after_ads(context)
	if was_muted_before_ad == nil then return end
	is_muted = was_muted_before_ad
	apply_mute_state()
	was_muted_before_ad = nil

	if is_muted then
		return
	end
	
	if context == "menu" and music_on then
		msg.post("/music#sound", "play_sound")
	elseif context == "gameplay" and music_on then
		msg.post("/music#sound_gameplay", "play_sound")
	end
end

return sound_manager