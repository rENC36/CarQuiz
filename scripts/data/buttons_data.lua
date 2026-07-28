return {

	-- кнопка открытия экрана категории в screen_menu
	{ node = "btn_play", target = "categories",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1),
	defaultsize = vmath.vector3(1, 1, 1),
	hoversize = vmath.vector3(1.02, 1.02, 1), 
	anim_scale = true},

	-- кнопка открытия экрана лидерборда в screen_menu
	{ node = "btn_leaderboard", target = "leaderboard",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1),
	defaultsize = vmath.vector3(1, 1, 1),
	hoversize = vmath.vector3(1.02, 1.02, 1), 
	anim_scale = true},

	-- кнопка открытия экрана настроек в screen_menu
	{ node = "btn_settings", target = "settings",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1),
	defaultsize = vmath.vector3(1, 1, 1),
	hoversize = vmath.vector3(1.02, 1.02, 1), 
	anim_scale = true},

	--кнопка выбора сложности в screen_categories
	{ node = "btn_easy",        target = "levels", difficulty = "easy",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1),
	defaultsize = vmath.vector3(1, 1, 1),
	hoversize = vmath.vector3(1.02, 1.02, 1), 
	anim_scale = true},

	--кнопка выбора сложности в screen_categories
	{ node = "btn_medium",      target = "levels", difficulty = "medium",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1),
	defaultsize = vmath.vector3(1, 1, 1),
	hoversize = vmath.vector3(1.02, 1.02, 1), 
	anim_scale = true},

	--кнопка выбора сложности в screen_categories
	{ node = "btn_hard",        target = "levels", difficulty = "hard",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1),
	defaultsize = vmath.vector3(1, 1, 1),
	hoversize = vmath.vector3(1.02, 1.02, 1), 
	anim_scale = true},

	--кнопка возвращения в экран меню screen_menu
	{ node = "white_arrow", 	target = "menu", 
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1), 
	hoversize = vmath.vector3(1.2,1.2,1.2)},
	
	--кнопка возвращения в экран категории screen_categories
	{ node = "white_arrow1", 	target = "categories",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1), 
	hoversize = vmath.vector3(1.2,1.2,1.2)},

	-- кнопка запуска gameplay.gui уровня номер один с определённой сложностью
	{ node = "btn_level_1", target = "gameplay", level_num = 1, 
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(0, 1, 0, 1), anim_color = false},

	-- кнопка запуска gameplay.gui уровня номер два с определённой сложностью
	{ node = "btn_level_2",     target = "gameplay", level_num = 2, 
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(0, 1, 0, 1), anim_color = false},

	-- кнопка запуска gameplay.gui уровня номер три с определённой сложностью
	{ node = "btn_level_3",     target = "gameplay", level_num = 3, 
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(0, 1, 0, 1), anim_color = false},

	-- кнопка возвращения из screen_leaderboard в screen_menu
	{ node = "close_screen_leaderboard",     target = "menu", 
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1), 
	hoversize = vmath.vector3(1.2, 1.2, 1.2)},

	-- кнопка возвращения из screen_settings в screen_menu
	{ node = "close_screen_settings",     target = "menu", 
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1), 
	hoversize = vmath.vector3(1.2, 1.2, 1.2)},

	-- Кнопка «ГЛАВНОЕ МЕНЮ» на экране результатов
	{ node = "exit_result", target = "menu",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1),
	defaultsize = vmath.vector3(.5, .5, 1),
	hoversize = vmath.vector3(.51, .51, 1),
	anim_scale = true},

	-- Кнопка «ПРОЙТИ ЕЩЕ РАЗ» / «СЛЕДУЮЩИЙ УРОВЕНЬ»
	{ node = "btn_result_next", target = "gameplay",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1),
	defaultsize = vmath.vector3(.5, .5, 1),
	hoversize = vmath.vector3(.51, .51, 1),
	anim_scale = true},

	{node = "btn_menu_ad",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1), 
	defaultsize = vmath.vector3(1, 1, 1),
	hoversize = vmath.vector3(1.1, 1.1, 1)},

	{node = "btn_no",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1), 
	anim_color = false},

	{node = "btn_yes",
	color = vmath.vector4(1, 1, 1, 1),
	hover = vmath.vector4(1, 1, 1, 1), 
	anim_color = false},
}

