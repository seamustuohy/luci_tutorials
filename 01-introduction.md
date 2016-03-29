
Basic LuCI development Info
===========================

Model-View-Controller (MVC)
---------------------
MVC is a software design that seperates the representation of data from the user's interactions with that data. This is the architecture that is used by the LuCI system

LuCI uses the existing UCI configuration files as a model. It uses its own configuration language called CBI to translate the UCI file into the HTML form (view) you see on most pages. It's controller's are a series fo lua scripts that can be found in the main LuCI directory.

The LuCI directory Structure
---------------------

LuCI's directory is contained at:

    /usr/lib/lua/luci/

The Default directories for resources on the Commotion router are as such:

RESOURCES: The directory for LuCI resources (images, js, css, and html assets) that are not theme specific

    /www/luci-static/resources/

MEDIA: The LuCI resource directory for the current active theme

    /www/luci-static/commotion/

	
The LuCI config file
--------------------

'core' 'main': Thiese are the basic setttings for things like setting the default directories, turning on the network interface unit, and setting the language.

'extern' 'flash_keep': The  files to keep when sysupgrade is run with save-settings. See: https://forum.openwrt.org/viewtopic.php?id=23194 for more info on customization

'internal' 'languages': The abbreviations that represent the supported translations in LuCI translate. 

'internal' 'sauth': Defines where sessions are stored and how long they last for logged in admin users.

'internal' 'ccache':  LuCI module caching. See: 06-debugging module of this repo for an in depth overview.

'internal' 'themes': The current themes that LuCI knows about. You should not have to touch this.

CBI
---

CBI models are lua files that describe the structure of a UCI vconfig file and the resulting HTML form to be evaluated by the CBi parser.

The main CBI parser is found in the luci directory.

    /usr/lib/lua/luci/cbi.lua

CBI also uses a set of datatypes. These datatypes are lua functions that dynamically calidate user input on the client side using javascript.

    /usr/lib/lua/luci/cbi/datatypes.lua

We will cover CBI in more depth in section 04-model-cbi of this module.

The LuCI API
-------------

While much can be done simply using the CBI interface and properly implementing UCI into your OpenWRT programs, more complex functionality, or non-UCI compliant programs, will require that you write your own Lua scripts. LuCI has a robust set of Lua functions for interacting with OpenWRT routers. 

API Documentation- http://luci.subsignal.org/api/luci/

Nixio
-----
Nixio is the "Networking and I/O library for Lua." Nixio is the low level Lua code that powers the LuCI API. IF you are looking for Lua hooks for specific networking and I/O tasks that too far abstracted by the LuCI libraries, here is where you need to look.

API Documentation - http://luci.subsignal.org/api/nixio/
Source - http://luci.subsignal.org/trac/browser/luci/trunk/libs/nixio


The LuCI development Environment
-----------------------------

To use the LuCI development environment you can simply run 'make luci' from the luci_tutorials folder to use the simple makefile I have written to automate the process. It will echo out the command to run once it is finished gathering the needed files.

If you are missing dependencies you can go to the online guide to get requirements:

    http://luci.subsignal.org/trac/wiki/Documentation/DevelopmentEnvironmentHowTo


Executing a LuCI command from the Linux shell
--------------------------------------------

Note:
-l     Used to load the module
-e    Executes some lua script

root@OpenWrt:~# lua -lluci.sys -e 'print(luci.sys.sysinfo())'


Config file for init-scripts and dependences
--------------------------------------------
/etc/config/unitrack


