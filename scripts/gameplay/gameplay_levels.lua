-- scripts/gameplay/gameplay_levels.lua

local level_manager = require("scripts.managers.level_manager")
local save_manager = require("scripts.managers.save_manager")
local yagames = require("yagames.yagames")
local yandex_marking = require("scripts.managers.yandex_marking")
local C = require("scripts.gameplay.gameplay_constants")

local gameplay_levels = {}

local current_questions = {}
local current_index = 1
local lives = C.LIVES_MAX
local coins = 0
local errors = 0

function gameplay_levels.get_state()
	return current_questions, current_index, lives, coins, errors
end

function gameplay_levels.set_coins(value)
	coins = value
end

function gameplay_levels.add_coins(value)
	coins = coins + value
end

function gameplay_levels.get_coins()
	return coins
end

function gameplay_levels.start(self, difficulty, level_num, music_on)
	self.start_time = os.time()
	self.difficulty = difficulty
	self.level_num = level_num
	self.music_on = music_on

	current_questions = level_manager.generate_level(difficulty, level_num)
	current_index = 1
	lives = C.LIVES_MAX
	coins = 0
	errors = 0
	self.level_score = 0
	self.timer = C.TIMER_MAX
	self.answered = false
	self.paused = false
	
	if music_on then
		msg.post("/music#sound", "stop_sound")
		msg.post("/music#sound_gameplay", "play_sound")
	end

	self.hint_5050_used = false
	self.hint_skip_used = false
	gameplay_levels.load_question(self)

	yandex_marking.start() 
end

function gameplay_levels.load_question(self)
	self.answered = false
	self.timer = C.TIMER_MAX
	self.timer_played = false
	msg.post("/music#sound_timer", "stop_sound")

	local q = current_questions[current_index]
	print("Вопрос " .. current_index .. " | Правильный: " .. q.answers[q.correct] .. " | индекс: " .. q.correct)

	self.hint_5050_used = false
	self.hint_skip_used = false

	gameplay_levels.update_coins_display(self)

	gui.set_enabled(gui.get_node("btn_hint_5050"), true)
	gui.set_enabled(gui.get_node("btn_hint_skip"), true)

	gui.set_text(gui.get_node("txt_question"), current_index .. "/" .. C.QUESTIONS_PER_LEVEL)
	gameplay_levels.update_lives(self)

	gui.play_flipbook(gui.get_node("car_image"), hash(q.img))

	for i, btn in ipairs(self.answer_buttons) do
		local node = gui.get_node(btn.node)
		local text = gui.get_node(btn.text)
		gui.set_text(text, q.answers[i])
		gui.play_flipbook(node, hash("btn_white1"))
		gui.set_color(node, C.COLORS.white)
		gui.set_enabled(node, true)
	end

	gui.set_size(gui.get_node("timer_bar"), vmath.vector3(245, 10, 0))
	gui.set_color(gui.get_node("timer_bar"), C.COLORS.timer_normal)
end

function gameplay_levels.update_lives(self)
	for i = 1, C.LIVES_MAX do
		local node = gui.get_node("symbol_heart" .. i)
		if i <= lives then
			gui.play_flipbook(node, hash("heart4"))
		else
			gui.play_flipbook(node, hash("empty_heart4"))
		end
	end
end

function gameplay_levels.update_timer(self, dt)
	if self.answered then return false end
	if #current_questions == 0 then return false end
	if self.paused then return false end
	if self.settings_open then return false end
	if gui.is_enabled(gui.get_node("ad_block")) then return false end

	self.timer = self.timer - dt
	local pct = math.max(0, self.timer / C.TIMER_MAX)
	gui.set_size(gui.get_node("timer_bar"), vmath.vector3(245 * pct, 10, 0))

	if self.timer < C.FAST_ANSWER_TIME then
		gui.set_color(gui.get_node("timer_bar"), C.COLORS.timer_warning)
		if not self.timer_played then
			msg.post("/music#sound_timer", "play_sound")
			self.timer_played = true
		end
	end

	if self.timer <= 0 then
		gameplay_levels.time_out(self)
	end

	return true
end

function gameplay_levels.select_answer(self, index)
	if self.answered then return end
	self.answered = true

	for i, btn in ipairs(self.answer_buttons) do
		gui.set_scale(gui.get_node(btn.node), vmath.vector3(1, 1, 1))
	end

	local q = current_questions[current_index]
	local is_correct = index == q.correct
	local is_fast = self.timer > C.FAST_ANSWER_TIME

	if is_correct then
		msg.post("/music#sound_correct", "play_sound")

		local earned_coins = is_fast and C.COINS.fast_answer or C.COINS.slow_answer
		local earned_score = is_fast and C.SCORE.fast_answer or C.SCORE.slow_answer
		coins = coins + earned_coins
		self.level_score = self.level_score + earned_score

		local correct_node = gui.get_node(self.answer_buttons[index].node)
		gui.play_flipbook(correct_node, hash("btn_rightanswer4"))

		gameplay_levels.update_coins_display(self)
	else
		msg.post("/music#sound_wrong", "play_sound")

		errors = errors + 1
		lives = lives - 1

		local wrong_node = gui.get_node(self.answer_buttons[index].node)
		gui.play_flipbook(wrong_node, hash("btn_wronganswer4"))

		local correct_node = gui.get_node(self.answer_buttons[q.correct].node)
		gui.play_flipbook(correct_node, hash("btn_rightanswer4"))

		gameplay_levels.update_lives(self)
	end

	msg.post("/music#sound_timer", "stop_sound")

	timer.delay(C.HINT_DELAY, false, function()
		gameplay_levels.next_question(self)
	end)
end

function gameplay_levels.time_out(self)
	if self.answered then return end
	self.answered = true
	errors = errors + 1
	lives = lives - 1
	gameplay_levels.update_lives(self)

	msg.post("/music#sound_timer", "stop_sound")

	local q = current_questions[current_index]
	gui.play_flipbook(gui.get_node(self.answer_buttons[q.correct].node), hash("btn_rightanswer4"))

	timer.delay(C.HINT_DELAY, false, function()
		gameplay_levels.next_question(self)
	end)
end

function gameplay_levels.next_question(self)
	if lives <= 0 then
		gameplay_levels.end_level(self, false)
		return
	end

	current_index = current_index + 1

	if current_index > C.QUESTIONS_PER_LEVEL then
		gameplay_levels.end_level(self, true)
	else
		gameplay_levels.load_question(self)
	end
end

function gameplay_levels.end_level(self, win)
	local elapsed = os.time() - self.start_time
	local minutes = math.floor(elapsed / 60)
	local seconds = elapsed % 60
	local time_str = string.format("%d:%02d", minutes, seconds)

	local stars = 0
	if win then
		if errors == 0 then stars = 3
		elseif errors == 1 then stars = 2
		elseif errors == 2 then stars = 1
		end
		save_manager.set_stars(self.difficulty, self.level_num, stars)
	end

	save_manager.add_coins(coins)
	save_manager.add_score(self.level_score or 0)

	local ok, is_authorized = pcall(yagames.player_is_authorized)
	if ok and is_authorized then
		local updated_save = save_manager.load()
		yagames.leaderboards_set_score(C.LEADERBOARD_NAME, updated_save.coins, nil, function(self, err)
			if err then
				print("Не удалось отправить очки в лидерборд:", err)
			end
		end)
	else
		print("Player не готов или не авторизован — очки в лидерборд не отправлены")
	end

	yandex_marking.stop()

	msg.post("/music#sound_gameplay", "stop_sound")
	msg.post("/music#sound_timer", "stop_sound")

	msg.post("/menu#menu", "enable")
	msg.post("/gameplay#gameplay", "disable")
	msg.post("/menu#menu", "show_result", {
		win = win,
		stars = stars,
		coins = coins,
		errors = errors,
		time = time_str,
		difficulty = self.difficulty,
		level_num = self.level_num
	})
end

function gameplay_levels.update_coins_display(self)
	local save_data = save_manager.load()
	local total = save_data.coins
	gui.set_text(gui.get_node("txt_coins"), total)
end

return gameplay_levels