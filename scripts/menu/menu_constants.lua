-- scripts/menu/menu_constants.lua

local C = {}

C.COLORS = {
	locked   = vmath.vector4(0.2, 0.2, 0.2, 0.5),
	star_off = vmath.vector4(0,   0,   0,   0.5),
	star_on  = vmath.vector4(1,   1,   1,   1),
	gold     = vmath.vector4(1,   1,   0,   1),
	dimmed   = vmath.vector4(1,   1,   1, 0.25),
	white    = vmath.vector4(1,   1,   1,   1),
}

C.ALPHA = {
	on  = 1,
	off = 0.3,
}

C.SCREENS = {"menu", "settings", "categories", "leaderboard", "result", "levels"}
C.DIFFICULTIES = {"easy", "medium", "hard"}

C.LEADERBOARD_NAME = "TopScores"
C.AD_REWARD_COINS = 100

C.CATEGORY_NODE_NAMES = {
	easy   = { name = "EasyCatText",   percent = "EasyCompleted" },
	medium = { name = "MediumCatText1", percent = "MediumCompleted" },
	hard   = { name = "HardCatText1",   percent = "HardCompleted" },
}

C.BAR_STATES = {
	[0] = { alpha = 0,    scale_x = 1,    pos_x = 0 },
	[1] = { alpha = 1,    scale_x = 0.4,  pos_x = -182 },
	[2] = { alpha = 1,    scale_x = 0.8,  pos_x = -151 },
	[3] = { alpha = 1,    scale_x = 1.33, pos_x = -112 },
}

return C