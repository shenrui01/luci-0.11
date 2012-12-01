--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

local fs = require "nixio.fs"

m = Map("RSS", translate("RSS For PT"))

s = m:section(TypedSection, "RSS", translate("Settings"))
s.anonymous = true

s:tab("basic", translate("Basic Settings"))
s:tab("feeds", translate("RSS Feeds"))

s:taboption("basic", Flag, "enable", translate("Enable")).rmempty = false

s:taboption("basic", Flag, "aria2", translate("Auto import to aria2 RPC")).rmempty = false

folder = s:taboption("basic", Value, "folder", translate("Torrent Folder"), translate("Where your torrent files save"))
folder.optional = false
folder.rmempty = false

interval = s:taboption("basic", Value, "interval", translate("Interval"), translate("Hours , zero mean run once"))
interval.optional = false
interval.datatype = "uinteger"
interval.default = "0"
interval.rmempty = false

maxtask = s:taboption("basic", Value, "maxtask", translate("Max Task"), translate("Max fetch per feed"))
maxtask.optional = false
maxtask.datatype = "uinteger"
maxtask.default = "3"
maxtask.rmempty = false

kwords = s:taboption("basic", Value, "keywords", translate("Keywords"), translate("ANY using asterisk , AND using ['plus'] , OR using [ 'space' , 'comma' , 'semicolon' ]"))
kwords.optional = false
kwords.default = "*"
kwords.rmempty = false

feeds = s:taboption("feeds", Value, "feeds", 
	translate("Put your RSS feeds here line by line"), 
	translate("Comment Using #"))

feeds.template = "cbi/tvalue"
feeds.rows = 20
feeds.wrap = "off"

function feeds.cfgvalue(self, section)
	return fs.readfile("/etc/RSS/feeds") or ""
end

function feeds.write(self, section, value)
	if value then
		fs.writefile("/etc/RSS/feeds", value:gsub("\r\n", "\n"))
	end
end

return m
