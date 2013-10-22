#REQUIREMENTS
#	Subversion
#   GCC, Make (build-essential)
#   Lua 5.1.x + development headers (lua5.1, liblua5.1-0-dev) 

lua:
	mkdir lua_tutorial
	cd lua_tutorial
	git clone https://github.com/elationfoundation/Learning-Lua


luci:
	mkdir luci_tutorial
	cd luci_tutorial
	svn co http://svn.luci.subsignal.org/luci/branches/luci-0.11
	cd luci-0.11
	git clone https://github.com/opentechinstitute/luci-commotion-linux.git
	cp -fr luci-commotion-linux/themes/commotion luci-0.11/themes/.
	make runhttpd
