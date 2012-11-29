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

local button="&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"button\" value=\" " .. translate("Open Web Interface") .. " \" onclick=\"window.open('http://'+window.location.host+'/aria2')\"/>"

m = Map("aria2", translate("aria2 Downloader"), translate("Make sure you have mounted USB Storage device") .. button)

s = m:section(TypedSection, "aria2", translate("Settings"))
s.anonymous = true

s:tab("basic",  translate("Basic Settings"))

switch = s:taboption("basic", Flag, "enable", translate("Enable"))
switch.rmempty = false

dev = s:taboption("basic", ListValue, "path", translate("Device"))
dev.rmempty = false

mounted = luci.sys.exec("mount | grep /dev/sda | cut -d \" \" -f3")

for line in mounted:gmatch("[^\r\n]+") do
	dev:value(line)
end

download_folder = s:taboption("basic", Value, "download_folder", translate("Download Folder"), translate("Where Your Files Save"))
download_folder.default = "Downloads"
download_folder.placeholder = "Downloads"

download_limit = s:taboption("basic", Value, "download_limit", translate("Download Limit"), translate("Default Bytes"))
download_limit.default = "0"
download_limit.placeholder = "0"
download_limit.datatype = "uinteger"

upload_limit = s:taboption("basic", Value, "upload_limit", translate("Upload Limit"), translate("Default Bytes"))
upload_limit.default = "0"
upload_limit.placeholder = "0"
upload_limit.datatype = "uinteger"

bt_maxpeers = s:taboption("basic", Value, "btmaxpeers", translate("BT/PT Max Peers"), translate("Recommand 25"))
bt_maxpeers.datatype = "uinteger"
bt_maxpeers.default = "25"
bt_maxpeers.placeholder = "25"

maxjobs = s:taboption("basic", Value, "maxjobs", translate("Max Concurrent Queue"), translate("Default 5"))
maxjobs.default = "5"
maxjobs.placeholder = "5"
maxjobs.datatype = "uinteger"

maxthread = s:taboption("basic", Value, "maxthread", translate("Max Thread"), translate("Default 5 , Max 20"))
maxthread.default = "4"
maxthread.placeholder = "4"
maxthread.datatype = "uinteger"

tcp_port = s:taboption("basic", Value, "tcp_port", translate("TCP Port"), translate("Default 51413"))
tcp_port.default = "51413"
tcp_port.placeholder = "51413"
tcp_port.datatype = "portrange"

udp_port = s:taboption("basic", Value, "udp_port", translate("UDP Port"), translate("Default 51413"))
udp_port.default = "51413"
udp_port.placeholder = "51413"
udp_port.datatype = "portrange"

seedtime = s:taboption("basic", Value, "seedtime", translate("Seed Time"), translate("Minute"))
seedtime.default = "525600"
seedtime.placeholder = "525600"
seedtime.datatype = "uinteger"

rpc_user = s:taboption("basic", Value, "rpc_user", translate("RPC Username"), translate("Your RPC Username"))
rpc_user.default = ""

rpc_passwd = s:taboption("basic", Value, "rpc_passwd", translate("RPC Password"), translate("Your RPC Password"))
rpc_passwd.password = true
rpc_passwd.default = ""

s:tab("editconf", translate("Edit Configuration"))

editconf = s:taboption("editconf", Value, "conf", 
	translate("You can customize aria2 configuration here"), 
	translate("Comment Using #"))

editconf:depends("enable", "1")

editconf.template = "cbi/tvalue"
editconf.rows = 20
editconf.wrap = "off"

function editconf.cfgvalue(self, section)
	local aria2_config = self.map:get(section, "path") .. "/.aria2/aria2.conf"
	return fs.readfile(aria2_config) or fs.readfile("/etc/aria2/aria2.conf.template")
end

function editconf.write(self, section, value)
	local mounted = luci.sys.exec("mount | grep /mnt/")
	local onoff = self.map:get(section, "enable")
	if mounted ~= "" and onoff == "1" then		
		local aria2_confpath = self.map:get(section, "path") .. "/.aria2"
		local aria2_config = aria2_confpath .. "/aria2.conf"
		if fs.access(aria2_confpath) == false then
			fs.mkdirr(aria2_confpath)
		end
		fs.writefile(aria2_config, value:gsub("\r\n?", "\n"))
	end
end

return m
