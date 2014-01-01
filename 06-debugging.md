
How do I find help with this odd problem I am facing?
------------------------------------------------------

Google search for the following (where THING is the thing you are trying to figure out). This will search the LuCI listserv and openwrt forum, which have a ton of helpful tips, etc hidden throughout.

    THING site:https://lists.subsignal.org/pipermail/luci/
	THING luci site:https://forum.openwrt.org/

You can also search the LuCI and nixio API's for technical terms that might show you a existing function in a library you have not looked in.

	THING site:http://luci.subsignal.org/api/
	

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


Commotion_helpers logger
-----------------------

Commotion helpers includes a logging function that is useful for basic debugging. 

    require "commotion_helpers"
	log("This is a thing to output")

The logging output is sent to logread.

	# logread
	user.notice luci: This is a thing to output

The current logger also does tables:

	log({a=1})
	
	user.notice luci: {
    user.notice luci: a
    user.notice luci: :
    user.notice luci: 1
    user.notice luci: }

If you want to capture just the luci logger output you can grep for only "luci" lines. When combined with tail this can be a powerful way of watching your program.

    # logread -f |grep luci

Line-by-line Call trace
------------------------

There is a "luci.debug" module, it was originally intended to trace the
memory usage of functions but it can also generate a line-by-line call
trace. Use it this way:

    require "luci.debug".trap_memtrace("l", "/tmp/trace")   -- (L, not one)

This should create a file /tmp/trace on each invocation. This is much more comprehensive than the normal log debugging and what Lua offers in its debug api. There is no interactive debugger like gdb as far as I know.


Debugging in the Development Environment
=======================================

Logging
-----------------
Since you will not be able to run logread at the same time as running the develoment environement you will need to send your logging to the standard error of the development environment itself. To do this you will want to use luci util's dumptable  and perror functions.

local util = require "luci.util"

if type(logged_item) == "table" then
   util.dumptable(logged_item)
else
   util.perror(logged_item)
end


