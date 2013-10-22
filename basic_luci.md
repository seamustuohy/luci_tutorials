Executing a LuCI command from the Linux shell
--------------------------------------------

Note:
-l     Used to load the module
-e    Executes some lua script

root@OpenWrt:~# lua -lluci.sys -e 'print(luci.sys.sysinfo())'

Config file for init-scripts and dependences
--------------------------------------------
/etc/config/unitrack

Enabling / Disabling Authentication
-----------------------------------

To enable authentication you need to set the sysauth properties on your root-level node:

x = entry({"myApp"}, template("myApp/overview"), "myApp", 1)
x.dependant = false
x.sysauth = "root"
x.sysauth_authenticator = "htmlauth"

(see controller/admin/index.lua)

To make your site the index, use:
----------------------------------

local root = node()
root.target = alias("myApp")
root.index = true

This should work as long as the name of your app > "admin" due to alphabetical sorting.