Recreate and get Lua error debugging output on the command line. 
--------------------------

create the following script in /www/cgi-bin/luci.dbg and make it executable:

    #!/usr/bin/lua

    require "nixio"

    dbg = io.open("/tmp/luci.req", "w")

    for k, v in pairs(nixio.getenv()) do
        dbg:write(string.format("export %s=%q\n", k, v))
	end

	dbg:write("/www/cgi-bin/luci\n")
	dbg:close()
	nixio.exec("/www/cgi-bin/luci")

	Now change the url of the broken page from .../luci/... to .../luci.dbg/... and reload.

	The script should create a file "/tmp/luci.req" which you can use to reproduce the same request on the command line:

	root@OpenWrt:~# sh /tmp/luci.req


Developing on the device
========================

In order to develop on the device in 10.03+ you will need the lua source to be in text format. There are 2 compilation settings for LuCI, one is a compile-time setting in make menuconfig under

Build Settings
--------------

LuCI -> Libraries -> LuCI core libraries -> Build Target.

There you can decide whether the device should have: full source, stripped source or bytecode in the .lua files on the device.

Compile Time caching (modulecache)
-----------------------------------

If you selected to have full source or stripped sourcecode, then there is a run-time option luci.ccache.enable which enables or disables a compile-time cache.  You can disable this cache by doing

    uci set luci.ccache.enable=0
	uci commit luci

or by changing the value to 0 directly in /etc/config/luci.

This is a permanent configuration.  If you only need to delete the cache for a one-off you can delete /tmp/luci-modulecache after each change.

Changes to the menu (indexcache)
--------------------

simply remove /tmp/luci-indexcache.

To permanently disable the menu cache for development purposes, (lua style) comment out the line
luci.dispatcher.indexcache = "/tmp/luci-indexcache" in /www/cgi-bin/luci .

    --luci.dispatcher.indexcache = "/tmp/luci-indexcache"