--[[
RA-MOD <ravageralpha AT gmail.com>
]]--

local fs = require "nixio.fs"

local running=(luci.sys.call("pidof aria2c > /dev/null") == 0)
local button=""
if running then
	button="&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"button\" value=\" " .. translate("Open Web Interface") .. " \" onclick=\"window.open('http://'+window.location.host+'/aria2')\"/>"
	m = Map("aria2", translate("aria2 Downloader"), translate("aria2 is running") .. button)
else
	m = Map("aria2", translate("aria2 Downloader"), translate("aria2 is not running,make sure you have mounted USB Storage device"))
end

s = m:section(TypedSection, "aria2", translate("Settings"))
s.anonymous = true

s:tab("basic",  translate("Basic Settings"))

mounted = luci.sys.exec("mount | grep /dev/sda | cut -d \" \" -f3")

switch = s:taboption("basic", Flag, "enable", translate("Enable"))
switch.rmempty = false

dev = s:taboption("basic", ListValue, "path", translate("Device"))
dev.rmempty = false

if mounted ~="" then
	for line in mounted:gmatch("[^\r\n]+") do
		dev:value(line)
	end
else
	dev:value("/dev/null")
end

download_folder = s:taboption("basic", Value, "download_folder", translate("Download Folder"), translate("Where Your Files Save"))
download_folder.default = "Downloads"
download_folder.placeholder = "Downloads"

maxjobs = s:taboption("basic", Value, "maxjobs", translate("Max Concurrent Queue"), translate("Default 5"))
maxjobs.default = "5"
maxjobs.placeholder = "5"
maxjobs.datatype = "uinteger"

file_allocation = s:taboption("basic", ListValue, "fileallocation", translate("File Allocation Method"), translate("<br />none - Disable file allocation<br />trunc - Recommand for mostly filesystem<br />falloc - fastest,EXT4 only"))
file_allocation:value("none")
file_allocation:value("trunc")
file_allocation:value("falloc")

diskcache = s:taboption("basic", Flag, "enablemmap", translate("Enable Disk Cache"), translate("Filesize below 4G only"))
diskcache.rmempty = false
diskcache.default = 1

if mounted ~= "" then
	s:tab("editconf", translate("Edit Configuration"))
	editconf = s:taboption("editconf", Value, "conf", 
		translate("You can customize aria2 configuration here"), 
		translate("Comment Using #"))
	editconf.template = "cbi/tvalue"
	editconf.rows = 20
	editconf.wrap = "off"
	aria2_confpath = luci.model.uci.cursor():get_first("aria2","aria2","path") .. "/.aria2"
	aria2_config = aria2_confpath .. "/aria2.conf"
	function editconf.cfgvalue(self, section)
		return fs.readfile(aria2_config) or fs.readfile("/etc/aria2/aria2.conf.template")
	end
	function editconf.write(self, section, value)
		local onoff = self.map:get(section, "enable")
		if onoff == "1" then
			if fs.access(aria2_confpath) == false then
				fs.mkdirr(aria2_confpath)
			end
			fs.writefile(aria2_config, value:gsub("\r\n?", "\n"))
		end
	end
end
-- Network
network=m:section(TypedSection, "aria2", translate("Network"))
network.anonymous = true

maxthread = network:option(Value, "maxthread", translate("Max Thread"), translate("Default 5 , Max 20"))
maxthread.default = "5"
maxthread.placeholder = "5"
maxthread.datatype = "uinteger"

download_limit = network:option(Value, "download_limit", translate("Download Limit"), translate("Default Bytes"))
download_limit.default = "0"
download_limit.placeholder = "0"

upload_limit = network:option(Value, "upload_limit", translate("Upload Limit"), translate("Default Bytes"))
upload_limit.default = "0"
upload_limit.placeholder = "0"

tcp_port = network:option(Value, "tcp_port", translate("TCP Port"), translate("Default 51413"))
tcp_port.default = "51413"
tcp_port.placeholder = "51413"
tcp_port.datatype = "portrange"

udp_port = network:option(Value, "udp_port", translate("UDP Port"), translate("Default 51413"))
udp_port.default = "51413"
udp_port.placeholder = "51413"
udp_port.datatype = "portrange"

bt_maxpeers = network:option(Value, "btmaxpeers", translate("BT/PT Max Peers"), translate("Recommand 25"))
bt_maxpeers.datatype = "uinteger"
bt_maxpeers.default = "25"
bt_maxpeers.placeholder = "25"

seedtime = network:option(Value, "seedtime", translate("Seed Time"), translate("Minute"))
seedtime.default = "525600"
seedtime.placeholder = "525600"
seedtime.datatype = "uinteger"

-- Authentication
rpc=m:section(TypedSection, "aria2", translate("Authentication"))
rpc.anonymous = true
rpc_auth = rpc:option(Flag, "rpc_auth", translate("Enable"))
rpc_auth.default = false
rpc_user = rpc:option(Value, "rpc_user", translate("RPC Username"), translate("Your RPC Username"))
rpc_user.default = ""
rpc_user:depends("rpc_auth", 1)
rpc_passwd = rpc:option(Value, "rpc_passwd", translate("RPC Password"), translate("Your RPC Password"))
rpc_passwd.password = true
rpc_passwd.default = ""
rpc_passwd:depends("rpc_auth", 1)

-- Auto download Subtitle
autosub=m:section(TypedSection, "aria2", translate("Auto Download Subtitle"))
autosub.anonymous = true

autosub_enable = autosub:option(Flag, "autosub_enable", translate("Enable"))
autosub_enable.default = false

autosub_filetype = autosub:option(Value, "autosub_filetype", translate("FileType"), translate("Separate with Comma"))
autosub_filetype.placeholder = "avi,mkv"
autosub_filetype.default = "avi,mkv"
autosub_filetype:depends("autosub_enable", 1)

return m

