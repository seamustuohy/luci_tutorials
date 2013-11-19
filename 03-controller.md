The Index and Entry's
=====================

See: example & guide in example/empty_controller.lua & example/guide_controller.lua

Making a controller
--------------------

*module creation*
*the index function*


The Index Function
-------------------
The dispatcher calls the index function of a 


Entries
--------------------


The CBI Call
------------
While there are many attributes you can set for a cbi value within its object structure in the cbi file there are a few that can only be set in the call itself. These attributes are parsed by the dispatcher's _cbi function. You can pass a set of configurations to the cbi call by passing it a table as below.

cbi("path/to/cbi", {"config values"})

The Following config vallues are allowed:

* on_success_to
If set this will redirect to the node passed it upon a form value returning that it was valid, done, changed or skipped (see:cbi-form values)
  
* on_changed_to
If set this will redirect to the node passed it upon a form value returning that it was changed or skipped (see:cbi-form values)

* on_valid_to
If set this will redirect to the node passed it upon a form value returning that it was valid, or done (see:cbi-form values)

* noheader
If set this will cause a CBI page to be rendered without the CBI header (which contains the start of the form that all CBI values are contained within) and without the OpenWRT Theme header. 

* nofooter
If set this will cause a CBI page to be rendered without the CBI footer (which contains the CBI submission buttons) and without the OpenWRT Theme footer. 

* autoapply
	
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
