-- scripts/gameplay/gameplay_hints.lua

local save_manager = require("scripts.managers.save_manager")
local yagames = require("yagames.yagames")
local gameplay_levels = require("scripts.gameplay.gameplay_levels")
local C = require("scripts.gameplay.gameplay_constants")

local gameplay_hints = {}

local function apply_hint_5050(self)
	self.hint_5050_used = true

	if self.ad_block_is_purchase then
		save_manager.add_coins(-C.COINS.hint_5050_price)
	end

	local current_questions, current_index = gameplay_levels.get_state()
	local q = current_questions[current_index]
	local wrong_buttons = {}
	for i, btn in ipairs(self.answer_buttons) do
		if i ~= q.correct then
			table.insert(wrong_buttons, i)
		end
	end

	for i = #wrong_buttons, 2, -1 do
		local j = math.random(i)
		wrong_buttons[i], wrong_buttons[j] = wrong_buttons[j], wrong_buttons[i]
	end

	for i = 1, 2 do
		local node = gui.get_node(self.answer_buttons[wrong_buttons[i]].node)
		gui.set_enabled(node, false)
	end

	gameplay_levels.update_coins_display(self)
end

local function apply_hint_skip(self)
	self.hint_skip_used = true
	self.answered = true

	if self.ad_block_is_purchase then
		save_manager.add_coins(-C.COINS.hint_skip_price)
	end

	gameplay_levels.update_coins_display(self)

	timer.delay(C.SKIP_DELAY, false, function()
		gameplay_levels.next_question(self)
	end)
end

local function ad_block_rewarded(self)
	print("Награда за просмотр рекламы засчитана!")
	save_manager.add_coins(C.COINS.ad_reward)
	msg.post("/music#sound", "play_sound")
end

local function rewarded_ad_open(self)
	print("Реклама открыта")
end

local function rewarded_ad_error(self, err)
	print("Ошибка показа рекламы:", err)
	msg.post("/music#sound", "play_sound")
end

local function rewarded_ad_close(self)
	print("Реклама закрыта")
	msg.post("/music#sound", "play_sound")
end

function gameplay_hints.ad_block_yes(self)
	gui.set_enabled(gui.get_node("ad_block"), false)

	if self.ad_block_is_purchase then
		if self.ad_block_hint_type == "5050" then
			apply_hint_5050(self)
		elseif self.ad_block_hint_type == "skip" then
			apply_hint_skip(self)
		end
	else
		msg.post("/music#sound_gameplay", "pause_sound")
		self.paused = true

		yagames.adv_show_rewarded_video({
			open = rewarded_ad_open,
			rewarded = ad_block_rewarded,
			close = function()
				rewarded_ad_close()
				if self.ad_block_hint_type == "5050" then
					apply_hint_5050(self)
				elseif self.ad_block_hint_type == "skip" then
					apply_hint_skip(self)
				end
				self.paused = false
				msg.post("/music#sound_gameplay", "play_sound")
			end,
			error = rewarded_ad_error
		})
	end

	self.ad_block_hint_type = nil
	self.ad_block_is_purchase = false
end

function gameplay_hints.use_hint_5050(self)
	if self.hint_5050_used or self.answered then return end
	local save_data = save_manager.load()
	self.ad_block_hint_type = "5050"

	if save_data.coins >= C.COINS.hint_5050_price then
		self.ad_block_is_purchase = true
		apply_hint_5050(self)
	else
		self.ad_block_is_purchase = false
		gui.set_text(gui.get_node("txt_ad_block_message"), "Использовать бесплатно\nза просмотр рекламы?")
		gui.set_enabled(gui.get_node("ad_block"), true)
	end
end

function gameplay_hints.use_hint_skip(self)
	if self.hint_skip_used or self.answered then return end
	local save_data = save_manager.load()
	self.ad_block_hint_type = "skip"

	if save_data.coins >= C.COINS.hint_skip_price then
		self.ad_block_is_purchase = true
		apply_hint_skip(self)
	else
		self.ad_block_is_purchase = false
		gui.set_text(gui.get_node("txt_ad_block_message"), "Использовать бесплатно\nза просмотр рекламы?")
		gui.set_enabled(gui.get_node("ad_block"), true)
	end
end

return gameplay_hints