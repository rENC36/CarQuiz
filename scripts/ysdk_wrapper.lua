local M = {}

function M.is_ready()
	if not html5 then 
		print("[YSDK] html5 module not available")
		return false 
	end
	
	local has_ysdk = html5.run("typeof window.ysdk !== 'undefined' && window.ysdk !== null")
	print("[YSDK] window.ysdk exists: " .. tostring(has_ysdk))
	
	if has_ysdk == "true" or has_ysdk == true then
		local has_adv = html5.run("typeof window.ysdk.adv !== 'undefined' && window.ysdk.adv !== null")
		print("[YSDK] window.ysdk.adv exists: " .. tostring(has_adv))
		return true
	end

	return false
end

function M.show_rewarded(on_rewarded, on_closed, on_error)
	if not html5 then
		print("[YSDK] html5 not available, fallback reward")
		if on_rewarded then on_rewarded() end
		return
	end

	if not M.is_ready() then
		print("[YSDK] SDK not ready or missing, fallback reward")
		if on_rewarded then on_rewarded() end
		return
	end

	print("[YSDK] Attempting to show rewarded video...")
	
	html5.run([[
	console.log("[YANDEX] Calling showRewardedVideo.");
	console.log("[YANDEX] window.ysdk:", window.ysdk);
	console.log("[YANDEX] window.ysdk.adv:", window.ysdk ? window.ysdk.adv : 'NO ADV MODULE');

	if(window.ysdk && window.ysdk.adv) {
		window.ysdk.adv.showRewardedVideo({
			callbacks: {
				onOpen: function() { console.log("[YANDEX] Ad opened successfully!"); },
					onRewarded: function() { console.log("[YANDEX] Player REWARDED!"); },
						onClose: function(wasShown) { console.log("[YANDEX] Ad closed. Was shown:", wasShown); },
							onError: function(e) { console.log("[YANDEX] Ad ERROR:", e); }
							}
						});
					} else {
						console.log("[YANDEX] ERROR: Cannot show ad, ysdk or ysdk.adv is missing!");
					}
					]])
				end

				function M.show_interstitial()
					if not html5 then return end
					if not M.is_ready() then return end

					html5.run([[
					if(window.ysdk && window.ysdk.adv) {
						window.ysdk.adv.showFullscreenAdv({
							callbacks: {
								onClose: function(wasShown) { console.log("[YANDEX] Interstitial closed"); },
									onError: function(e) { console.log("[YANDEX] Interstitial error:", e); }
									}
								});
							}
							]])
						end

						return M