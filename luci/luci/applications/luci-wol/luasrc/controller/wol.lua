module("luci.controller.wol", package.seeall)

function index()
	require("luci.i18n")
	luci.i18n.loadc("wol")
	entry({"admin", "network", "wol"}, cbi("wol"), _("Wake on LAN"), 90).i18n = "wol"
	entry({"mini", "network", "wol"}, cbi("wol"), _("Wake on LAN"), 90).i18n = "wol"
end
