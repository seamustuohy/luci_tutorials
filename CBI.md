CBI: How to filter based in the value of an option
---------------------------------------------------

For example: to be able to display interfaces based on the "proto" option

    m = map ("network", "title", "description")
    s = m:section(TypedSection, "interface", "")
    function s.filter(self, section)
        return self.map:get(section, "proto") ~= "gre"    <---- here is the magic
	end

CBI: Validating all options on a page
====================================

In you have a requirement to validate that all parameters are unique, or have other relationships that cannot be defined in the schema you will need to be able to validate ALL parameters on a page level rather than use the existing CBI option or section  level validation

To Validate a field/option
----------------------------

If you require a validation of field or option, you can define a validate function for for the option,
the value passed is the uncommitted value from the submitted form.

NOTE: boolean options don't call a validate function

    m = Map(...)
    s = m:section(...)
    o = option(...)

    function o.validate(self, value)
        if value < min then return nil end
	    if value > max then return nil end
		return value
    end


To Validate a section
---------------------

If you require a validation of a section you can define a validate function for a whole section, this allows you  to validate all fields within it. It gets self and the section id as  parameters.  The fields are stored in a key->value table within self.fields, you can access their :formvalue() member function to obtain the values you want.

Try something like that:

    m = Map(...)
    s = m:section(...)

    function s.validate(self, sectionid)
        local field, obj
        local values = { }
        for field, obj in pairs(self.fields) do
            local fieldval = obj:formvalue(sectionid)
            if not values[fieldval] then
                values[fieldval] = true
            else
                return nil -- raise error
            end
        end

        return sectionid -- signal success
    end

To Validate a whole page
---------------------------

When a CBI map is rendered after a form submit, the associated controller calls m:parse() which triggers form value fetching and
validation across all sections within the map, each section in turn does validation on each fields within it.

If one of the field validation functions fail, the whole map is flagged invalid by setting .save = false on the map object.

When a validation error occurs on a per-field or per-section level, the associated error handling sets the property .error to a table value to flag the error condition in a specific field (or section) - this is used by the templates later on to highlight failed options (for example make them red and print an error text next to it).

The error structure looks like this:

    .error = {
        [section_id_1] = "Error message string",
        [section_id_2] = "Another error message"
    }
    
The format is the same for per-section and per-option errors. The variables section_id_1 andsection_id_2 are the uci identifiers of the
underlying section e.g. "lan" for "config interface lan" and "cfg12ab23f" for "config foo" (anonymous section).

To complicate it further, sections of the type TypedSection are not 1:1 mapped to the CBI model, one TypeSection declaration may result in multiple actual section blocks rendered in theform so you need to treat it correctly when traversing the map->sections->options tree.


With that in mind, you can hijack the Map's .parse function to implement some kind of globalvalidation:

    local utl = require "luci.util"

    m = Map("config", ...)

    function m.parse(self, ...) -- NB: "..." actually means ellipsis here

        -- call the original parse implementation
        Map.parse(self, ...)

        -- do custom processing
        local sobj

        for _, sobj in ipairs(self.children) do

            local sids

            -- check section type
            if utl.instanceof(sobj, NamedSection) then

            -- this is a named section,
            -- the uci id of this section is
            -- stored in sobj.section
            sids = { sobj.section }

        elseif utl.instanceof(sobj, TypedSection) then

            -- this is a typed section,
            -- it may map to multiple uci ids
            sids = sobj:cfgsections()

        end

        -- now validate the fields within this section
        -- for each associated config section
        local sid, fld

        for _, sid in ipairs(sids) do

            for _, fld in ipairs(sobj.children) do

                -- get the value for a specific field in
                -- a specific section
                local val = fld:formvalue(sid)

                -- do some custom checks on val,
                -- e.g. compare against :cfgvalue(),
                -- some global structure etc.
                if not is_valid(val, other_stuff) then

                    -- failed, flag map (self == m)
                    self.save = false

                    -- create field error for
                    -- template highlight
                    fld.error = {
                        [sid] = "Error foobar"
                    }
                end
            end
        end
    end
end


Save & Apply Hooks
------------------

LuCI Trunk and the 0.9 branch offer hooks for that:

on_init	   Before rendering the model
on_parse  Before writing the config
on_before_commit		  Before writing the config
on_after_commit		  After writing the config
on_before_apply		  Before restarting services
on_after_apply		  After restarting services
on_cancel			  When the form was cancelled

Use them like this:

    m = Map("foo", ...)
    m.on_after_commit = function(self)
        -- all written config names are in self.parsechain
        local file
        for _, file in ipairs(self.parsechain) do
            -- copy "file" ...
        done
    end




Schema
------

option type

    one of { "enum", "lazylist", "list", "reference", "variable" }

option datatype

    one of {"Integer", "Boolean", "String"}


Getting Anonymous UCI Config Data
---------------------------------
When accessing "anonymous" sections via LUA do the following:

local hostname

	luci.model.uci.cursor():foreach("system", "system", function(s) hostname = s.hostname end)
	print(hostname)

Since this is often needed, they added a shortcut doing exactly that:

	local hostname = luci.model.uci.cursor():get_first("system", "system", "hostname")
	print(hostname)

See also http://luci.subsignal.org/api/luci/modules/luci.model.uci.html#Cursor.get_first



Enabling / Disabling Authentication
-----------------------------------

To enable authentication you need to set the sysauth properties on your root-level node:

    x = entry({"myApp"}, template("myApp/overview"), "myApp", 1)
    x.dependant = false
    x.sysauth = "root"
    x.sysauth_authenticator = "htmlauth"

(see controller/admin/index.lua)

To make your site the index, use:

    local root = node()
    root.target = alias("myApp")
    root.index = true

This should work as long as the name of your app > "admin" due to alphabetical sorting.


Using a template to create custom fields
----------------------------------------

Create a new view e.g. luasrc/view/cbi_timeval.htm like this

    <%+cbi/valueheader%>

	<input type="text" class="cbi-input-text" onchange="cbi_d_update(this.id)"<%= attr("name", cbid .. ".hour") .. attr("id", cbid ..".hour") .. attr("value", (self:cfgvalue(section) or ""):match("(%d%d):%d%d")) %> />
	:
	<input type="text" class="cbi-input-text" onchange="cbi_d_update(this.id)"<%= attr("name", cbid .. ".min") .. attr("id", cbid ..".min") .. attr("value", (self:cfgvalue(section) or ""):match("%d%d:(%d%d)")) %> />

	<%+cbi/valuefooter%>

Important are the includes at the beggining and the end, and that the id, name and value attributes are correct. The rest can be adapted.

(self:cfgvalue(section) or ""):match(".*:?(.*)") will only match the part of the config value behind the : whereas (self:cfgvalue(section) or ""):match("(.*):?.*") will only match the first part of the real config value.

In your Model do something like this.

    somename = s:option(Value, "option", "name") -- or whatever creating a Value
    somename.template = "cbi_timeval"            -- Template name from above
    somename.formvalue = function(self, section) -- This will assemble the parts
        local hour = self.map:formvalue(self:cbid(section) .. ".hour")
        local min = self.map:formvalue(self:cbid(section) .. ".min")
        if hour and min and #hour > 0 and #min > 0 then
            return hour .. ":" .. min
        else
            return nil
        end
    end



Save vs Save & Apply
--------------------

[Save] pushes the change to /etc/config /* and [Save & Apply] does the same plus it calls corresponding init scripts defined in /etc/config/ucitrack .

If my custom page only needs to write to /etc/config/myapp.lua but not reboot the router, how do I get ONLY a [Save] button?
Change the cbi() invocation in your controller to something like this:

	cbi("my/form", {autoapply=true})



Run  a Script from a Button
---------------------------

This bit of code needs "s" to be a section from either a SimpleForm or a Map

    btn = s:option(Button, "_btn", translate("Click this to run a script"))

	function btn.write()
	luci.sys.call("/usr/bin/script.sh")
	end
																							 