--[[
RA-MOD <ravageralpha AT gmail.com>
]]--

module("luci.controller.aria2", package.seeall)

function index()
	require("luci.i18n")
	luci.i18n.loadc("aria2")
	
	if not nixio.fs.access("/etc/config/aria2") then
		return
	end

	local page
	page = entry({"admin", "diskapply", "aria2"}, cbi("aria2"), _("aria2 Downloader"))
	page.i18n = "aria2"
	page.dependent = true
end
