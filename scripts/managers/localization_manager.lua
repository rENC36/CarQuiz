local M = {}

local dicts = {
	ru = require("localization.strings_ru"),
	eng = require("localization.strings_eng"),
}

M.current_lang = "ru" 

function M.init(lang, place)
	if lang and dicts[lang] then
		M.current_lang = lang
	else
		M.current_lang = "ru"
	end
	
	M.set_lang(M.current_lang, place)
end

function M.get(key)
	local dict = dicts[M.current_lang]
	return dict[key] or dicts["ru"][key] or key
end

function M.set_lang(lang, place)
	if dicts[lang] then
		M.current_lang = lang

		for key, text in pairs(dicts[lang][place]) do
			gui.set_text(gui.get_node(key), text)
		end
	end
end

return M