--This file would be namedd and live in /usr/lib/lua/luci/model/cbi/example_cbi.lua per the example controller. 

m = Map("network", "Network") -- We want to edit the uci config file /etc/config/network

s = m:section(TypedSection, "interface", "Interfaces") -- Especially the "interface"-sections
s.addremove = true -- Allow the user to create and remove the interfaces
function s:filter(value)
   return value ~= "loopback" and value -- Don't touch loopback
end 
s:depends("proto", "static") -- Only show those with "static"
s:depends("proto", "dhcp") -- or "dhcp" as protocol and leave PPPoE and PPTP alone

p = s:option(ListValue, "proto", "Protocol") -- Creates an element list (select box)
p:value("static", "static") -- Key and value pairs
p:value("dhcp", "DHCP")
p.default = "static"

s:option(Value, "ifname", "interface", "the physical interface to be used") -- This will give a simple textbox

s:option(Value, "ipaddr", translate("ip", "IP Address")) -- Ja, das ist eine i18n-Funktion ;-)

s:option(Value, "netmask", "Netmask"):depends("proto", "static") -- You may remember this "depends" function from above

mtu = s:option(Value, "mtu", "MTU")
mtu.optional = true -- This one is very optional

dns = s:option(Value, "dns", "DNS-Server")
dns:depends("proto", "static")
dns.optional = true
function dns:validate(value) -- Now, that's nifty, eh?
    return value:match("[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+") -- Returns nil if it doesn't match otherwise returns match
end

gw = s:option(Value, "gateway", "Gateway")
gw:depends("proto", "static")
gw.rmempty = true -- Remove entry if it is empty

return m -- Returns the map