-- scripts/gameplay/gameplay_constants.lua

local C = {}

C.TIMER_MAX = 10
C.QUESTIONS_PER_LEVEL = 15
C.LIVES_MAX = 3

C.COLORS = {
	timer_warning = vmath.vector4(0.9, 0.0, 0.15, 1.0),
	timer_normal  = vmath.vector4(1, 1, 1, 1),
	correct_hint  = vmath.vector4(0.11, 0.62, 0.46, 1),
	white         = vmath.vector4(1, 1, 1, 1),
}

C.COINS = {
	hint_5050_price = 10,
	hint_skip_price = 20,
	ad_reward       = 50,
	fast_answer     = 2,
	slow_answer     = 1,
}

C.SCORE = {
	fast_answer = 30,
	slow_answer = 10,
}

C.FAST_ANSWER_TIME = 5
C.HINT_DELAY = 1.2
C.SKIP_DELAY = 0.3
C.LEADERBOARD_NAME = "TopScores"

C.HELP_ANIM_TIME = 0.35
C.HELP_PANEL_OFFSET_X = -320

return C