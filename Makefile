#REQUIREMENTS
#	Subversion
#   GCC, Make (build-essential)
#   Lua 5.1.x + development headers (lua5.1, liblua5.1-0-dev) 

luci:
	mkdir luci_dev_env
	cd luci_dev_env
	svn co http://svn.luci.subsignal.org/luci/branches/luci-0.11
	cd luci-0.11
	git clone https://github.com/opentechinstitute/luci-commotion-linux.git
	cp -fr luci-commotion-linux/themes/commotion luci-0.11/themes/.
	echo "run 'make runhttpd' from the luci-0.11/ folder and go to localhost:8080/luci in your browser to see your luci development instance"
