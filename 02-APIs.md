<p align="right"><a href="01-introduction.md">01-introduction.md &larr; </a> | <a href="03-controller.md">&rarr; 03-controller.md</a></p>
LuCI and Nixio API's
======================

We will go through this live and allow you to build notes that we can push back to this repo.

Main LuCI controller Files
===========================
/usr/lib/lua/luci/*.lua files

asterisk.lua :runs asterisk functions
    http://luci.subsignal.org/api/luci/modules/luci.asterisk.html

cacheloader.lua : simply uses config.lua to check the luci uci file and if on loads ccache.cache_ondemand()

cbi.lua : The library that handles binding configuration values to UCI data.

ccache.lua : enables caching (and if cache_ondemand() runs the S values of debugging output for one level of introspection with debug.getinfo on errors. see: http://pgl.yoyo.org/luai/i/lua_getinfo)

config.lua : reads configuration values from the luci uci file

debug.lua : Runs debugging commands. See: module 06-debugging for more info.

dispatcher.lua : The library that control the http requests, page loading, and basic controller... controlling.
    http://luci.subsignal.org/api/luci/modules/luci.dispatcher.html

fs.lua : The lua file system library.
    http://luci.subsignal.org/api/luci/modules/luci.fs.html

httpclient.lua : Library that implements the client side of required http standards like Get and more

http.lua : LuCI Web Framework high-level HTTP functions.
    http://luci.subsignal.org/api/luci/modules/luci.http.html

i18n.lua : LuCi translation library
    http://luci.subsignal.org/api/luci/modules/luci.i18n.html

init.lua : The main LuCI initialization module.

ip.lua : LuCI IP calculation library.
    http://luci.subsignal.org/api/luci/modules/luci.ip.html

json.lua : LuCI JSON-Library
    http://luci.subsignal.org/api/luci/modules/luci.json.html

jsonrpc.lua : an implementation of a json remote procedure call protocol similar to XML-RPC.

ltn12.lua (With an L at the front): The Lua Socket Toolkit 
		  http://luci.subsignal.org/api/luci/modules/luci.ltn12.html
		  http://luci.subsignal.org/api/luci/modules/luci.ltn12.filter.html
		  http://luci.subsignal.org/api/luci/modules/luci.ltn12.pump.html
		  http://luci.subsignal.org/api/luci/modules/luci.ltn12.sink.html
		  http://luci.subsignal.org/api/luci/modules/luci.ltn12.source.html
		  
lucid.lua : A superprocess / child process / daemon manager  that has the ability to work with rpc, http, and other networking services. -> I have yet to dig in to this but we should
    http://luci.subsignal.org/api/luci/modules/luci.lucid.html

niulib.lua : A library that allows you to get a list of available (and bridged) ethernet and wireless interfaces.

rpcc.lua : LuCI RPC Client.
    http://luci.subsignal.org/api/luci/modules/luci.rpcc.html

sauth.lua : The library that controls user sessions.
    http://luci.subsignal.org/api/luci/modules/luci.sauth.html

store.lua : A module that is simple an instance of util.threadlocal(). Don't ask me...
    http://luci.subsignal.org/api/luci/modules/luci.util.html#threadlocal

sys.lua : LuCI Linux and POSIX system utilities.
    http://luci.subsignal.org/api/luci/modules/luci.sys.html

template.lua : A template parser supporting includes, translations, lua code blocks, and more. It can be set as either a compiler or as an interpreter.
			 
util.lua : The LuCI utility functions library.
    http://luci.subsignal.org/api/luci/modules/luci.util.html

version.lua : Module that gets/gives the Lua/LuCI versions
