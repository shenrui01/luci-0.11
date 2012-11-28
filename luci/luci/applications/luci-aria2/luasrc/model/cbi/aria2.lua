--[[
LuCI - Lua Configuration Interface - aria2 support

Script by animefans_xj @ nowvideo.dlinkddns.com (af_xj@yahoo.com.cn)
Based on luci-app-transmission and luci-app-upnp

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.util")
local running=(luci.sys.call("pidof aria2c > /dev/null") == 0)
local button=""
if running then
	button="&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"button\" value=\" " .. translate("Open Web Interface") .. " \" onclick=\"window.open('http://'+window.location.host+'/aria2')\"/>"
end
--[[ "Aria2_Config" 指定要打开的配置文件位置,详情访问http://luci.subsignal.org/trac/wiki/Documentation/ModulesHowTo]]--
m=Map("Aria2_Config",translate("Aria2 Downloader"),translate("Use this page, you can download files from HTTP FTP and BitTorrent via Aria2.") .. button)
					--[[Global]]--
s=m:section(TypedSection,"aria2",translate("Global"))
s.addremove=false
s.anonymous=true
--[[enable]]--
enable=s:option(Flag,"enabled",translate("Enabled"))
enable.rmempty=false
--[[function enable.cfgvalue(self,section)
	return luci.sys.init.enabled("aria2") and self.enabled or self.disabled
end]]--
--[[启动和停止]]--
--[[function enable.write(self,section,value)
	if value == "1" then
		luci.sys.call("/etc/init.d/Aria2_Init enable >/dev/null")
		luci.sys.call("/etc/init.d/Aria2_Init start >/dev/null")
	else
		luci.sys.call("/etc/init.d/Aria2_Init stop >/dev/null")
		luci.sys.call("/etc/init.d/Aria2_Init disable >/dev/null")
	end
end]]--
--[[User]]--
user=s:option(ListValue,"user",translate("Run as"),translate("Run daemon as user"))
local list_user
for _, list_user in luci.util.vspairs(luci.util.split(luci.sys.exec("cat /etc/passwd | cut -f 1 -d :"))) do
	user:value(list_user)
end
--[[log Enable]]--
logEnable=s:option(Flag,"logEnable",translate("Log Enabled"),translate("Enable log"))
logEnable.rmempty=false
--[[check_integrity]]--
check_integrity=s:option(Flag,"check_integrity",translate("Check Integrity"),translate("Check file integrity by validating piece hashes or a hash of entire file"))
check_integrity.rmempty=false
--[[Continue?]]--
Continue=s:option(Flag,"Continue",translate("Continue"),translate("Continue downloading a partially downloaded file."))
Continue.rmempty=false
--[[file_allocation : aria2 param : file_allocation ]]--
file_allocation=s:option(Value,"file_allocation",translate("File  Allocation"),translate("none: doesn't pre-allocate file space. prealloc:pre-allocates file space before download begins.This may take some time depending on the size ofthe file.If you are using newer file systems such as ext4(with extents support), btrfs, xfs or NTFS(MinGW build only), falloc is your bestchoice. It allocates large(few GiB) filesalmost instantly. Don't use falloc with legacyfile systems such as ext3 and FAT32 because ittakes almost same time as prealloc and itblocks aria2 entirely until allocation finishes.falloc may not be available if your system doesn't have posix_fallocate() function.trunc : uses ftruncate() system call or platform-specific counterpart to truncate a file to a specified length."))
file_allocation:value("none","none")
file_allocation:value("prealloc","prealloc")
file_allocation:value("trunc","trunc")
file_allocation:value("falloc","falloc")
file_allocation.rmempty=false
file_allocation.placeholder="falloc"
--[[min_split_size : aria2 param : min_split_size]]--
min_split_size=s:option(Value,"min_split_size",translate("Min split size"),translate("MB The min size to split the file to pieces to download "))
min_split_size:value("10M","10M")
min_split_size:value("20M","20M")
min_split_size:value("30M","30M")
min_split_size.rmempty=false
min_split_size.placeholder="30M"

					--[[Location]]--
location=m:section(TypedSection,"aria2",translate("Location"))
location.addremove=false
location.anonymous=true
config_dir=location:option(Value,"config_dir",translate("Config Directory"))
config_dir.placeholder="/mnt/MountPoint/Aria2/.Aria2_Config"
download_dir=location:option(Value,"download_dir",translate("Download Directory"))
download_dir.placeholder="/mnt/MountPoint/Aria2"
--[[Task]]--
task=m:section(TypedSection,"aria2",translate("Task"))
task.addremove=false
task.anonymous=true
--[[restortask]]--
restore_task=task:option(Flag,"restore_task",translate("Restore unfinished task when boot"))
restore_task.rmempty=false
--[[load_cookies]]--
load_cookies=task:option(Flag,"load_cookies",translate("Load Cookies from FILE using the Firefox3 format and Mozilla/Firefox(1.x/2.x)/Netscape format.(Aria2Cookies.cookies)"))
load_cookies.rmempty=false
--[[ save_interval : aria2 param : --auto-save-interval ]]--
save_interval=task:option(Value,"save_interval",translate("Save interval"),translate("In seconds, 0 means unsave and let tasks can't be restore"))
save_interval:value("5","5")
save_interval:value("10","10")
save_interval:value("20","20")
save_interval:value("30","30")
save_interval:value("40","40")
save_interval:value("50","50")
save_interval:value("60","60")
save_interval.rmempty=true
save_interval.placeholder="60"
save_interval.datatype="range(0,600)"
--[[ queue_size : aria2 param : -j ]]--
queue_size=task:option(Value,"queue_size",translate("Download queue size"))
queue_size:value("1","1")
queue_size:value("2","2")
queue_size:value("3","3")
queue_size:value("4","4")
queue_size:value("5","5")
queue_size.rmempty=true
queue_size.placeholder="2"
queue_size.datatype="range(1,20)"
--[[ Split : aria2 param : -s ]]--
Split=task:option(Value,"Split",translate("Blocks of per task"))
Split:value("1","1")
Split:value("2","2")
Split:value("3","3")
Split:value("4","4")
Split:value("5","5")
Split:value("6","6")
Split:value("7","7")
Split:value("8","8")
Split:value("9","9")
Split.rmempty=true
Split.placeholder="5"
Split.datatype="range(1,20)"
--[[ thread : aria2 param : -x ]]--
thread=task:option(ListValue,"thread",translate("Download threads of per server"))
thread:value("1","1")
thread:value("2","2")
thread:value("3","3")
thread:value("4","4")
thread:value("5","5")
thread:value("6","6")
thread:value("7","7")
thread:value("8","8")
thread:value("9","9")
thread:value("10","10")
					--[[Network]]--
network=m:section(TypedSection,"aria2",translate("Network"))
network.addremove=false
network.anonymous=true
disable_ipv6=network:option(Flag,"disable_ipv6",translate("Disable IPv6"))
disable_ipv6.rmempty=false
enable_lpd=network:option(Flag,"enable_lpd",translate("Enable Local Peer Discovery"))
enable_lpd.rmempty=false
enable_dht=network:option(Flag,"enable_dht",translate("Enable DHT Network"))
enable_dht.rmempty=false
listen_port=network:option(Value,"listen_port",translate("Port for BitTorrent"))
listen_port.placeholder="6882"
listen_port.datatype="range(1,65535)"
download_speed=network:option(Value,"download_speed",translate("Download speed limit"),translate("In KB/S, 0 means unlimit"))
download_speed.placeholder="0"
download_speed.datatype="range(0,100000)"
upload_speed=network:option(Value,"upload_speed",translate("Upload speed limit"),translate("In KB/S, 0 means unlimit"))
upload_speed.placeholder="0"
upload_speed.datatype="range(0,100000)"
					--[[RPC]]--
rpc=m:section(TypedSection,"aria2",translate("Remote Control"))
rpc.addremove=false
rpc.anonymous=true
rpc_auth=rpc:option(Flag,"rpc_auth",translate("Use RPC Auth"))
rpc_auth.rmempty=false
rpc_user=rpc:option(Value,"rpc_user",translate("User name"))
rpc_user.placeholder="admin"
rpc_user:depends("rpc_auth",1)
rpc_password=rpc:option(Value,"rpc_password",translate("Password"))
rpc_password.placeholder="admin"
rpc_password:depends("rpc_auth",1)
					--[[Advance]]--
advanced=m:section(TypedSection,"aria2",translate("Advanced"))
advanced.addremove=false
advanced.anonymous=true
extra_cmd=advanced:option(Flag,"extra_cmd",translate("add extra commands"))
extra_cmd.rmempty=false
cmd_line=advanced:option(Value,"cmd_line",translate("Command-Lines"),translate("To check all commands availabled, visit:") .. "&nbsp;<a onclick=\"window.open('http://'+window.location.host+'/Aria2/help.html')\" style=\"cursor:pointer\"><font color='blue'><u>点击获取帮助</u></font></a>")
cmd_line:depends("extra_cmd",1)
return m
