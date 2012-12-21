--[[
LuCI - Lua Configuration Interface - Transmission support

Copyright 2012 Rui Shen <shenrui01@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.util")
local uci = require "luci.model.uci".cursor()
local trport = uci:get_first("transmission", "transmission", "rpc_port") or 9091
local button = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"button\" value=\" " .. translate("Open Web Interface") .. " \" onclick=\"window.open('http://'+window.location.hostname+':" .. trport .. "')\"/>"

m = Map("transmission", "Transmission", translate("Transmission daemon is a simple bittorrent client, here you can configure the settings.") .. button)

s=m:section(TypedSection, "transmission", translate("Settings"))
s.addremove=false
s.anonymous=true

--[[tab list]]--
s:tab("Basic",  translate("Basic Settings"))
s:tab("Location",  translate("Location"))
s:tab("Speed",  translate("Limit Speed"))
s:tab("Peer",  translate("Peer Settings"))
s:tab("Network",  translate("Network"))
s:tab("Queueing",  translate("Queueing"))

--[[Basic Settings]]--
enable=s:taboption("Basic", Flag, "enabled", translate("Enabled"))
enable.rmempty=false
config_dir=s:taboption("Basic", Value, "config_dir", translate("Config file directory"))
user=s:taboption("Basic", ListValue, "user", translate("Run daemon as user"))
local p_user
for _, p_user in luci.util.vspairs(luci.util.split(luci.sys.exec("cat /etc/passwd | cut -f 1 -d :"))) do
	user:value(p_user)
end
cache_size_mb=s:taboption("Basic", Value, "cache_size_mb", translate("Cache size in MB"))
message_level=s:taboption("Basic", ListValue, "message_level", translate("Message level"))
message_level:value("0", translate("None"))
message_level:value("1", translate("Error"))
message_level:value("2", translate("Info"))
message_level:value("3", translate("Debug"))
rpc_enabled=s:taboption("Basic", Flag, "rpc_enabled", translate("RPC enabled"))
rpc_enabled.enabled="true"
rpc_enabled.disabled="false"
rpc_port=s:taboption("Basic", Value, "rpc_port", translate("RPC port"))
rpc_port:depends("rpc_enabled", "true")
rpc_bind_address=s:taboption("Basic", Value, "rpc_bind_address", translate("RPC bind address"))
rpc_bind_address:depends("rpc_enabled", "true")
rpc_url=s:taboption("Basic", Value, "rpc_url", translate("RPC URL"))
rpc_url:depends("rpc_enabled", "true")
rpc_whitelist_enabled=s:taboption("Basic", Flag, "rpc_whitelist_enabled", translate("RPC whitelist enabled"))
rpc_whitelist_enabled.enabled="true"
rpc_whitelist_enabled.disabled="false"
rpc_whitelist_enabled:depends("rpc_enabled", "true")
rpc_whitelist=s:taboption("Basic", Value, "rpc_whitelist", translate("RPC whitelist"))
rpc_whitelist:depends("rpc_whitelist_enabled", "true")
rpc_authentication_required=s:taboption("Basic", Flag, "rpc_authentication_required", translate("RPC authentication required"))
rpc_authentication_required.enabled="true"
rpc_authentication_required.disabled="false"
rpc_authentication_required:depends("rpc_enabled", "true")
rpc_username=s:taboption("Basic", Value, "rpc_username", translate("RPC username"))
rpc_username:depends("rpc_authentication_required", "true")
rpc_password=s:taboption("Basic", Value, "rpc_password", translate("RPC password"))
rpc_password:depends("rpc_authentication_required", "true")
rpc_password.password = true
script_torrent_done_enabled=s:taboption("Basic", Flag, "script_torrent_done_enabled", translate("Script torrent done enabled"))
script_torrent_done_enabled.enabled="true"
script_torrent_done_enabled.disabled="false"
script_torrent_done_filename=s:taboption("Basic", Value, "script_torrent_done_filename", translate("Script torrent done filename"))
script_torrent_done_filename:depends("script_torrent_done_enabled", "true")

--[[Location]]--
download_dir=s:taboption("Location", Value, "download_dir", translate("Download directory"))
incomplete_dir_enabled=s:taboption("Location", Flag, "incomplete_dir_enabled", translate("Incomplete directory enabled"))
incomplete_dir_enabled.enabled="true"
incomplete_dir_enabled.disabled="false"
incomplete_dir=s:taboption("Location", Value, "incomplete_dir", translate("Incomplete directory"))
incomplete_dir:depends("incomplete_dir_enabled", "true")
preallocation=s:taboption("Location", ListValue, "preallocation", translate("preallocation"))
preallocation:value("0", translate("Off"))
preallocation:value("1", translate("Fast"))
preallocation:value("2", translate("Full"))
prefetch_enabled=s:taboption("Location", Flag, "prefetch_enabled", translate("Prefetch enabled"))
rename_partial_files=s:taboption("Location", Flag, "rename_partial_files", translate("Rename partial files"))
rename_partial_files.enableid="true"
rename_partial_files.disabled="false"
start_added_torrents=s:taboption("Location", Flag, "start_added_torrents", translate("Automatically start added torrents"))
start_added_torrents.enabled="true"
start_added_torrents.disabled="false"
trash_original_torrent_files=s:taboption("Location", Flag, "trash_original_torrent_files", translate("Trash original torrent files"))
trash_original_torrent_files.enabled="true"
trash_original_torrent_files.disabled="false"
umask=s:taboption("Location", Value, "umask", "umask")
watch_dir_enabled=s:taboption("Location", Flag, "watch_dir_enabled", translate("Enable watch directory"))
watch_dir_enabled.enabled="true"
watch_dir_enabled.disabled="false"
watch_dir=s:taboption("Location", Value, "watch_dir", translate("Watch directory"))
watch_dir:depends("watch_dir_enabled", "true")

--[[Speed]]--
speed_limit_down_enabled=s:taboption("Speed", Flag, "speed_limit_down_enabled", translate("Speed limit down enabled"))
speed_limit_down_enabled.enabled="true"
speed_limit_down_enabled.disabled="false"
speed_limit_down=s:taboption("Speed", Value, "speed_limit_down", translate("Speed limit down"), "KB/s")
speed_limit_down:depends("speed_limit_down_enabled", "true")
speed_limit_up_enabled=s:taboption("Speed", Flag, "speed_limit_up_enabled", translate("Speed limit up enabled"))
speed_limit_up_enabled.enabled="true"
speed_limit_up_enabled.disabled="false"
speed_limit_up=s:taboption("Speed", Value, "speed_limit_up", translate("Speed limit up"), "KB/s")
speed_limit_up:depends("speed_limit_up_enabled", "true")
upload_slots_per_torrent=s:taboption("Speed", Value, "upload_slots_per_torrent", translate("Upload slots per torrent"))
alt_speed_enabled=s:taboption("Speed", Flag, "alt_speed_enabled", translate("Alternative speed enabled"))
alt_speed_enabled.enabled="true"
alt_speed_enabled.disabled="false"
alt_speed_down=s:taboption("Speed", Value, "alt_speed_down", translate("Alternative download speed"), "KB/s")
alt_speed_down:depends("alt_speed_enabled", "true")
alt_speed_up=s:taboption("Speed", Value, "alt_speed_up", translate("Alternative upload speed"), "KB/s")
alt_speed_up:depends("alt_speed_enabled", "true")
alt_speed_time_enabled=s:taboption("Speed", Flag, "alt_speed_time_enabled", translate("Alternative speed timing enabled"))
alt_speed_time_enabled.enabled="true"
alt_speed_time_enabled.disabled="false"
alt_speed_time_enabled.default="false"
alt_speed_time_enabled:depends("alt_speed_enabled", "true")
alt_speed_time_day=s:taboption("Speed", Value, "alt_speed_time_day", translate("Alternative speed time day"), translate("Number/bitfield. Start with 0, then for each day you want the scheduler enabled, add a value. For Sunday - 1, Monday - 2, Tuesday - 4, Wednesday - 8, Thursday - 16, Friday - 32, Saturday - 64"))
alt_speed_time_day:depends("alt_speed_time_enabled", "true")
alt_speed_time_begin=s:taboption("Speed", Value, "alt_speed_time_begin", translate("Alternative speed time begin"), translate("in minutes from midnight"))
alt_speed_time_begin:depends("alt_speed_time_enabled", "true")
alt_speed_time_end=s:taboption("Speed", Value, "alt_speed_time_end", translate("Alternative speed time end"), translate("in minutes from midnight"))
alt_speed_time_end:depends("alt_speed_time_enabled", "true")

--[[Peer]]--
bind_address_ipv4=s:taboption("Peer", Value, "bind_address_ipv4", translate("Binding address IPv4"))
bind_address_ipv4.default="0.0.0.0"
bind_address_ipv6=s:taboption("Peer", Value, "bind_address_ipv6", translate("Binding address IPv6"))
bind_address_ipv6.default="::"
peer_congestion_algorithm=s:taboption("Peer", Value, "peer_congestion_algorithm", translate("Peer congestion algorithm"))
peer_limit_global=s:taboption("Peer", Value, "peer_limit_global", translate("Global peer limit"))
peer_limit_per_torrent=s:taboption("Peer", Value, "peer_limit_per_torrent", translate("Peer limit per torrent"))
peer_socket_tos=s:taboption("Peer", Value, "peer_socket_tos", translate("Peer socket tos"))
blocklist_enabled=s:taboption("Peer", Flag, "blocklist_enabled", translate("Block list enabled"))
blocklist_enabled.enabled="true"
blocklist_enabled.disabled="false"
blocklist_url=s:taboption("Peer", Value, "blocklist_url", translate("Blocklist URL"))
blocklist_url:depends("blocklist_enabled", "true")

--[[Network]]--
peer_port=s:taboption("Network", Value, "peer_port", translate("Peer port"))
peer_port_random_on_start=s:taboption("Network", Flag, "peer_port_random_on_start", translate("Peer port random on start"))
peer_port_random_on_start.enabled="true"
peer_port_random_on_start.disabled="false"
peer_port_random_high=s:taboption("Network", Value, "peer_port_random_high", translate("Peer port random high"))
peer_port_random_high:depends("peer_port_random_on_start", "true")
peer_port_random_low=s:taboption("Network", Value, "peer_port_random_low", translate("Peer port random low"))
peer_port_random_low:depends("peer_port_random_on_start", "true")
port_forwarding_enabled=s:taboption("Network", Flag, "port_forwarding_enabled", translate("Port forwarding enabled"))
port_forwarding_enabled.enabled="true"
port_forwarding_enabled.disabled="false"
encryption=s:taboption("Network", ListValue, "encryption", translate("Encryption"))
encryption:value("0", translate("Off"))
encryption:value("1", translate("Preferred"))
encryption:value("2", translate("Forced"))
lazy_bitfield_enabled=s:taboption("Network", Flag, "lazy_bitfield_enabled", translate("Lazy bitfield enabled"))
lazy_bitfield_enabled.enabled="true"
lazy_bitfield_enabled.disabled="false"
dht_enabled=s:taboption("Network", Flag, "dht_enabled", translate("DHT enabled"))
dht_enabled.enabled="true"
dht_enabled.disabled="false"
lpd_enabled=s:taboption("Network", Flag, "lpd_enabled", translate("LPD enabled"))
lpd_enabled.enabled="true"
lpd_enabled.disabled="false"

pex_enabled=s:taboption("Network", Flag, "pex_enabled", translate("PEX enabled"))
pex_enabled.enabled="true"
pex_enabled.disabled="false"
utp_enabled=s:taboption("Network", Flag, "utp_enabled", translate("uTP enabled"))
utp_enabled.enabled="true"
utp_enabled.disabled="false"
idle_seeding_limit_enabled=s:taboption("Network", Flag, "idle_seeding_limit_enabled", translate("Idle seeding limit enabled"))
idle_seeding_limit_enabled.enabled="true"
idle_seeding_limit_enabled.disabled="false"
idle_seeding_limit=s:taboption("Network", Value, "idle_seeding_limit", translate("Idle seeding limit"))
idle_seeding_limit:depends("idle_seeding_limit_enabled", "true")
ratio_limit_enabled=s:taboption("Network", Flag, "ratio_limit_enabled", translate("Ratio limit enabled"))
ratio_limit_enabled.enabled="true"
ratio_limit_enabled.disabled="false"
ratio_limit=s:taboption("Network", Value, "ratio_limit", translate("Ratio limit"))
ratio_limit:depends("ratio_limit_enabled", "true")
--[[Queueing]]--
download_queue_enabled=s:taboption("Queueing", Flag, "download_queue_enabled", translate("Download queue enabled"))
download_queue_enabled.enabled="true"
download_queue_enabled.disabled="false"
download_queue_size=s:taboption("Queueing", Value, "download_queue_size", translate("Download queue size"))
download_queue_size:depends("download_queue_enabled", "true")
queue_stalled_enabled=s:taboption("Queueing", Flag, "queue_stalled_enabled", translate("Queue stalled enabled"))
queue_stalled_enabled.enabled="true"
queue_stalled_enabled.disabled="false"
queue_stalled_minutes=s:taboption("Queueing", Value, "queue_stalled_minutes", translate("Queue stalled minutes"))
queue_stalled_minutes:depends("queue_stalled_enabled", "true")
seed_queue_enabled=s:taboption("Queueing", Flag, "seed_queue_enabled", translate("Seed queue enabled"))
seed_queue_enabled.enabled="true"
seed_queue_enabled.disabled="false"
seed_queue_size=s:taboption("Queueing", Value, "seed_queue_size", translate("Seed queue size"))
seed_queue_size:depends("seed_queue_enabled", "true")
scrape_paused_torrents_enabled=s:taboption("Queueing", Flag, "scrape_paused_torrents_enabled", translate("Scrape paused torrents enabled"))
scrape_paused_torrents_enabled.enabled="true"
scrape_paused_torrents_enabled.disabled="false"

return m
