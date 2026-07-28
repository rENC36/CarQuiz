local save_manager = require("scripts.managers.save_manager")
local sound_manager = {}

local is_muted = false
local SOUND_GROUPS = {
	"music",
	"sfx",
	"ui",
	"master"
}

local function apply_mute_state()
	local gain = is_muted and 0.0 or 1.0
	for _, group in ipairs(SOUND_GROUPS) do
		sound.set_group_gain(group, gain)
	end
end

local function load_mute_state()
	local save = save_manager.load()
	is_muted = save.sound_muted or false
	apply_mute_state()
end

function sound_manager.init()
	load_mute_state()
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

	if context == "menu" then
		msg.post("/music#sound", "play_sound")
	elseif context == "gameplay" then
		msg.post("/music#sound_gameplay", "play_sound")
	end
end

return sound_manager