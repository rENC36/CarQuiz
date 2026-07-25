-- scripts/managers/localization_manager.lua
local M = {}

local locales = {
	ru = require("localization.strings_ru"),
	en = require("localization.strings_en"),
}

M.current_lang = "ru"

function M.init(lang, screen_name)
	if lang then
		M.current_lang = lang
	end

	local locale = locales[M.current_lang]
	if not locale then
		M.current_lang = "ru"
		locale = locales[M.current_lang]
		if not locale then return end
	end

	if screen_name then
		M.update_screen(screen_name, locale)
	end
end

function M.update_screen(screen_name, locale)
	local texts = locale[screen_name]
	if not texts then return end

	for key, value in pairs(texts) do
		local node = gui.get_node(key)
		if node then
			gui.set_text(node, value)
		end
	end
end

function M.get_text(key)
	local locale = locales[M.current_lang]
	if not locale then return key end

	local parts = {}
	for part in string.gmatch(key, "[^%.]+") do
		table.insert(parts, part)
	end

	local current = locale
	for _, part in ipairs(parts) do
		if current[part] then
			current = current[part]
		else
			return key
		end
	end

	return current
end

function M.set_lang(lang)
	if lang then
		M.current_lang = lang
	end
end

return M