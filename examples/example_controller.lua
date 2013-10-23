--This file would be located and named at /usr/lib/lua/luci/controller/test.lua
module("luci.controller.test", package.seeall)

function index()
   entry({'admin', 'view_test'}, template("example_view_reboot"), "testing application", 666)
   entry({'admin', 'function_test'}, call("main"), "testing application", 555)
   entry({'admin', 'cbi_test'}, cbi("example_cbi"), "testing application", 28)
end

function main()
   local go_go = require "luci.http.redirect" --always make required things local to increase speed
   --redirecting us to our template
   go_go("https://"..env.SERVER_NAME../cgi-bin/luci/guide_cbi)
end