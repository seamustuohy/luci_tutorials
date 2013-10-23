The Index and Entry's
=====================

See: example & guide in example/empty_controller.lua & example/guide_controller.lua

Making a controller
--------------------

For existing Controller tutorial go to:

    http://luci.subsignal.org/trac/wiki/Documentation/ModulesHowTo

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
