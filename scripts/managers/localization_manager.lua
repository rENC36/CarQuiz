-- scripts/managers/localization_manager.lua

local M = {}

local dicts = {
	ru = require("localization.strings_ru"),
	en = require("localization.strings_en"),
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

function M.get(key, place)
	local dict = dicts[M.current_lang]
	if place and dict[place] and dict[place][key] then
		return dict[place][key]
	end
	
	for _, section in pairs(dict) do
		if section[key] then
			return section[key]
		end
	end
	
	for _, section in pairs(dicts["ru"]) do
		if section[key] then
			return section[key]
		end
	end
	return key
end

function M.set_lang(lang, place)
	if dicts[lang] then
		M.current_lang = lang

		if place and dicts[lang][place] then
			for key, text in pairs(dicts[lang][place]) do
				local ok, node = pcall(gui.get_node, key)
				if ok and node then
					gui.set_text(node, text)
				end
			end
		end
	end
end

function M.apply_to_screen(place)
	M.set_lang(M.current_lang, place)
end

function M.apply_to_all()
	local dict = dicts[M.current_lang]
	for place, section in pairs(dict) do
		for key, text in pairs(section) do
			local ok, node = pcall(gui.get_node, key)
			if ok and node then
				gui.set_text(node, text)
			end
		end
	end
end

return M