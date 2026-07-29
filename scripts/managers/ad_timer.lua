-- scripts/managers/ad_timer.lua

local save_manager = require("scripts.managers.save_manager")

local ad_timer = {}

local REWARDED_COOLDOWN = 300

local SAVE_KEY = "last_rewarded_time"

function ad_timer.can_show_rewarded()
	local data = save_manager.load()
	local last_time = data[SAVE_KEY] or 0
	local current_time = os.time()

	return (current_time - last_time) >= REWARDED_COOLDOWN
end

function ad_timer.get_remaining_time()
	local data = save_manager.load()
	local last_time = data[SAVE_KEY] or 0
	local current_time = os.time()
	local elapsed = current_time - last_time

	if elapsed >= REWARDED_COOLDOWN then
		return 0
	end

	return REWARDED_COOLDOWN - elapsed
end

function ad_timer.mark_rewarded_shown()
	local data = save_manager.load()
	data[SAVE_KEY] = os.time()
	save_manager.save(data)
end

function ad_timer.get_cooldown()
	return REWARDED_COOLDOWN
end

function ad_timer.format_time(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%d:%02d", minutes, secs)
end

return ad_timer