CBI Basics
===========

See: https://github.com/elationfoundation/luci-snippets for heavily commented snippets that include documented and undocumented functionality of LuCI CBI objects and functions.

See: example_cbi.lua or http://luci.subsignal.org/trac/wiki/Documentation/ModulesHowTo#CBImodels where I stole it directly from.


CBI: How to filter based in the value of an option
---------------------------------------------------

For example: to be able to display interfaces based on the "proto" option

    m = map ("network", "title", "description")
    s = m:section(TypedSection, "interface", "")
    function s.filter(self, section)
        return self.map:get(section, "proto") ~= "gre"    <---- here is the magic
	end

CBI: A simple dummy section header without making a new section (aka using the nullsection template)
----------------------------------

```
dv = s:option(DummyValue, "_dummy", translate("Section title?"), translate("I say things about stuff."))
dv.template = "cbi/nullsection"
```
	
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

**on_init**	   Before rendering the model

**on_parse**  Before writing the config

**on_before_commit**		  Before writing the config

**on_after_commit**		  After writing the config

**on_before_apply**		  Before restarting services

**on_after_apply**		  After restarting services

**on_cancel**			  When the form was cancelled

Use them like this:

```
    m = Map("foo", ...)
    m.on_after_commit = function(self)
        -- all written config names are in self.parsechain
        local file
        for _, file in ipairs(self.parsechain) do
            -- copy "file" ...
        done
    end
```



Schema
------

  * option type
    * one of { "enum", "lazylist", "list", "reference", "variable" }
  * option datatype
    * one of {"Integer", "Boolean", "String"}


Getting Anonymous UCI Config Data
---------------------------------
When accessing "anonymous" sections via LUA do the following:

```
local hostname
luci.model.uci.cursor():foreach("system", "system", function(s) hostname = s.hostname end)
print(hostname)
```

Since this is often needed, they added a shortcut doing exactly that:
```
local hostname = luci.model.uci.cursor():get_first("system", "system", "hostname")
print(hostname)
```

See also http://luci.subsignal.org/api/luci/modules/luci.model.uci.html#Cursor.get_first



Enabling / Disabling Authentication
-----------------------------------

To enable authentication you need to set the sysauth properties on your root-level node:

```
x = entry({"myApp"}, template("myApp/overview"), "myApp", 1)
x.dependant = false
x.sysauth = "root"
x.sysauth_authenticator = "htmlauth"
```
(see controller/admin/index.lua)

To make your site the index, use:

```
local root = node()
root.target = alias("myApp")
root.index = true
```

This should work as long as the name of your app > "admin" due to alphabetical sorting.


Using a template to create custom fields
----------------------------------------

Create a new view e.g. luasrc/view/cbi_timeval.htm like this

```
    <%+cbi/valueheader%>

	<input type="text" class="cbi-input-text" onchange="cbi_d_update(this.id)"<%= attr("name", cbid .. ".hour") .. attr("id", cbid ..".hour") .. attr("value", (self:cfgvalue(section) or ""):match("(%d%d):%d%d")) %> />
	:
	<input type="text" class="cbi-input-text" onchange="cbi_d_update(this.id)"<%= attr("name", cbid .. ".min") .. attr("id", cbid ..".min") .. attr("value", (self:cfgvalue(section) or ""):match("%d%d:(%d%d)")) %> />

	<%+cbi/valuefooter%>
```

Important are the includes at the beggining and the end, and that the id, name and value attributes are correct. The rest can be adapted.

```(self:cfgvalue(section) or ""):match(".*:?(.*)") ```
will only match the part of the config value behind the : 
whereas 
```(self:cfgvalue(section) or ""):match("(.*):?.*") ```
will only match the first part of the real config value.

In your Model do something like this.

```
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
```

Modifying cbi map buttons
-------------------------

The buttons can be controlled through the "flow" property of a map. This
value is not set in the model, but in the controller entry for that page.

The options are: skip, autoapply, hidesavebtn, hideresetbtn, and hideapplybtn 

**skip:** If true ADD the skip button.

**autoapply:** if true (and hideapplybtn not true) HIDE submit button.

**hideapplybtn:** if true (and autoapply not true) HIDE submit button.

**hidesavebtn:** If true HIDE the save button

**hideresetbtn:** if true HIDE the reset button.


These options are set as bool values in a table. This table is passed as
the second value of the cbi call.

```
entry({"admin", "my_page"}, cbi("admin/my_page", {skip=true,
autoapply=false}), translate("My Page"), 15)
```


Save vs Save & Apply
--------------------

**Save** pushes the change to /etc/config /* and **Save & Apply** does the same plus it calls corresponding init scripts defined in /etc/config/ucitrack .

**Q** If my custom page only needs to write to /etc/config/myapp.lua but not reboot the router, how do I get ONLY a **Save** button?

**A** Change the cbi() invocation in your controller to something like this:

```
cbi("my/form", {autoapply=true})
```

Run  a Script from a Button
---------------------------

This bit of code needs "s" to be a section from either a SimpleForm or a Map

```
btn = s:option(Button, "_btn", translate("Click this to run a script"))

function btn.write()
    luci.sys.call("/usr/bin/script.sh")
end
```

CBI Form Values
----------------
The parse functions for various CBI objects contain checks for various form_values. These values are used as conditionals for a variety of tasks. I will go over the values here and the conditions that cause them.

**FORM_NODATA** 

If on parse a http.formvalue() does not contain a "cbi.submit" value

**FORM_PROCEED =  0**

Optional and dynamic options when parsed have a "proceed" option that will let the deligator or dispatcher know that when a optional value is parsed that does not exist, or a dynamic value has confirmed it has added the dynamic options to proceed to processing the rest of the CBI object.

**FORM_VALID   =  1**

Set when a form has data and is neither invalid, or marked to proceed, and has not changed.

**FORM_DONE	 =  1**

Set when the formvalue "cbi.cancel" is returned from a page and if the "on_cancel" hook function returns true. This is usually the second thing parsed on a form after "skip"

**FORM_INVALID = -1**

Set if a form has been submitted without the .save variable set, or if a error has been raised by a validation function on a option or section.

**FORM_CHANGED =  2**

This value gets set if a formvalue has changed from the value in the uci config file and was written to that uci value.

**FORM_SKIP    =  4**
If on parse a http.formvalue() contains a "cbi.skip" value

CBI: Applying Values
--------------------

When the dispatcher loads a map it sets a value that is parsed by the cbi template map which, if an apply is needed will include the apply_xhr.htm template in itself. This calls the action_restart value (in an ingenious use of luci.dispatcher.build_url) passing it the configuration list.

This calls the Cursor.apply() method from luci/model/uci.lua file. As  a result, external script /sbin/luci-reload is invoked. (You will need to read this page http://wiki.openwrt.org/doc/devel/config-scripting if you want to explore this script with any real understanding. This script iterates through the /etc/config/ucitrack file and grabs the init and exec options for each config value passed to it. It then runs all the init scripts and executes all the executable commands. While doing this it mimics the commands it runs back to the user using some on-page XHR.


CBI: Map attributres
--------------------

You can call these as such

```    m = Map("network", "title", "description" {attribute=true})```

**apply_on_parse**

Runs uci:apply on all objects after the on_before_apply chain is run. This skips the normal process of having the rendering of the map in the dispatcher apply values. (see:Applying Values)

**commit_handler**
A function that is run at the end of the self.save chain of events. (see: parsing CBI values)

TODO: Test this to see what negative impacts it may have.
TODO: see if you can set apply_on_parse=false in a on_before_apply command to not have to use apply_xhr.htm
?TODO: replace apply_xhr in the map.htm to show a better application setting configuration to the user? 

Parsing CBI Values
-------------------

The order of parsing a CBI value is is as such.

```
  1) "on_parse"
  2) If the formvalue of "cbi.skip"
  a) FORM_SKIP activated (see: The CBI call and "on_changed_to" and "on_succes_to")
  3) if "save" (this means you have clicked the save button or set the .save value to true)
    3a) "on_save"
    3b) "on_before_save"
    3c) uci:save
    3d) "on_after_save"
      3e1)If not in a deligator (see CBI Form Value) or if "cbi.apply" has been set (You clicked the save and apply button)
      3e2) "on_before_commit"
      3e3) actually commit everything
      3e4) "on_commit"
      3e5) "on_after_commit"
      3e6) "on_before_apply"
      3e7) if apply_on_parse
        3e7a) apply on all values
        3e7b) "on_apply"
        3e7c) "on_after_apply"
TODO: Finish showing the application parsing
      3e8) set apply_needed for map to parse (see:Applying Values)
    3f) run any commit_handler functions that a map has on it . (see: CBI: Map attributres)
```

Special (rarely used) CBI Value Types
----------------

**TextValue**

```
TextValue - A multi-line value
	rows:	Rows
	template

TextValue = class(AbstractValue)
```

**Button**

```
		inputstyle
		rmempty
		template
Button = class(AbstractValue)
```

**FileUpload**

```
		template
		upload_fields
		formcreated
		formvalue
		remobe
		
FileUpload = class(AbstractValue)
```

**FileBrowser**

```
		template

FileBrowser = class(AbstractValue)
```

TO DEFINE:
------------

* self.override_scheme

Found in:

* modules/niu/luasrc/model/cbi/niu/network/etherwan.lua
* modules/niu/luasrc/model/cbi/niu/network/wlanwan.lua
* applications/luci-olsr/luasrc/model/cbi/olsr/olsrdplugins.lua
* libs/web/luasrc/cbi.lua

example:

```
p = s:taboption("general", ListValue, "proto", translate("Connection Protocol"))
p.override_scheme = true
p.default = "dhcp"
p:value("dhcp", translate("Cable / Ethernet / DHCP"))
if has_pppoe then p:value("pppoe", "DSL / PPPoE")   end
if has_pppoa then p:value("pppoa", "PPPoA")   end
if has_pptp  then p:value("pptp",  "PPTP")    end
p:value("static", translate("Static Ethernet"))
```

* self.href

DummyValue : found in the html file called

* self.inputstyle

Button : found in html file



Delegator TODO
-------------

**Delegator - Node controller**

```
Delegator = class(Node)
function Delegator.__init__(self, ...)
	Node.__init__(self, ...)
	self.nodes = {}
	self.defaultpath = {}
	self.pageaction = false
	self.readinput = true
	self.allow_reset = false
	self.allow_cancel = false
	self.allow_back = false
	self.allow_finish = false
	self.template = "cbi/delegator"
end

function Delegator.set(self, name, node)
	assert(not self.nodes[name], "Duplicate entry")

	self.nodes[name] = node
end

function Delegator.add(self, name, node)
	node = self:set(name, node)
	self.defaultpath[#self.defaultpath+1] = name
end

function Delegator.insert_after(self, name, after)
	local n = #self.chain + 1
	for k, v in ipairs(self.chain) do
		if v == after then
			n = k + 1
			break
		end
	end
	table.insert(self.chain, n, name)
end

function Delegator.set_route(self, ...)
	local n, chain, route = 0, self.chain, {...}
	for i = 1, #chain do
		if chain[i] == self.current then
			n = i
			break
		end
	end
	for i = 1, #route do
		n = n + 1
		chain[n] = route[i]
	end
	for i = n + 1, #chain do
		chain[i] = nil
	end
end

function Delegator.get(self, name)
	local node = self.nodes[name]

	if type(node) == "string" then
		node = load(node, name)
	end

	if type(node) == "table" and getmetatable(node) == nil then
		node = Compound(unpack(node))
	end

	return node
end

function Delegator.parse(self, ...)
	if self.allow_cancel and Map.formvalue(self, "cbi.cancel") then
		if self:_run_hooks("on_cancel") then
			return FORM_DONE
		end
	end

	if not Map.formvalue(self, "cbi.delg.current") then
		self:_run_hooks("on_init")
	end

	local newcurrent
	self.chain = self.chain or self:get_chain()
	self.current = self.current or self:get_active()
	self.active = self.active or self:get(self.current)
	assert(self.active, "Invalid state")

	local stat = FORM_DONE
	if type(self.active) ~= "function" then
		self.active:populate_delegator(self)
		stat = self.active:parse()
	else
		self:active()
	end

	if stat > FORM_PROCEED then
		if Map.formvalue(self, "cbi.delg.back") then
			newcurrent = self:get_prev(self.current)
		else
			newcurrent = self:get_next(self.current)
		end
	elseif stat < FORM_PROCEED then
		return stat
	end


	if not Map.formvalue(self, "cbi.submit") then
		return FORM_NODATA
	elseif stat > FORM_PROCEED
	and (not newcurrent or not self:get(newcurrent)) then
		return self:_run_hook("on_done") or FORM_DONE
	else
		self.current = newcurrent or self.current
		self.active = self:get(self.current)
		if type(self.active) ~= "function" then
			self.active:populate_delegator(self)
			local stat = self.active:parse(false)
			if stat == FORM_SKIP then
				return self:parse(...)
			else
				return FORM_PROCEED
			end
		else
			return self:parse(...)
		end
	end
end

function Delegator.get_next(self, state)
	for k, v in ipairs(self.chain) do
		if v == state then
			return self.chain[k+1]
		end
	end
end

function Delegator.get_prev(self, state)
	for k, v in ipairs(self.chain) do
		if v == state then
			return self.chain[k-1]
		end
	end
end

function Delegator.get_chain(self)
	local x = Map.formvalue(self, "cbi.delg.path") or self.defaultpath
	return type(x) == "table" and x or {x}
end

function Delegator.get_active(self)
	return Map.formvalue(self, "cbi.delg.current") or self.chain[1]
end
```

SimpleForm TODO
---------------

**SimpleForm - A Simple non-UCI form**

```
SimpleForm = class(Node)

function SimpleForm.__init__(self, config, title, description, data)
	Node.__init__(self, title, description)
	self.config = config
	self.data = data or {}
	self.template = "cbi/simpleform"
	self.dorender = true
	self.pageaction = false
	self.readinput = true
end

SimpleForm.formvalue = Map.formvalue
SimpleForm.formvaluetable = Map.formvaluetable

function SimpleForm.parse(self, readinput, ...)
	self.readinput = (readinput ~= false)

	if self:formvalue("cbi.skip") then
		return FORM_SKIP
	end

	if self:formvalue("cbi.cancel") and self:_run_hooks("on_cancel") then
		return FORM_DONE
	end

	if self:submitstate() then
		Node.parse(self, 1, ...)
	end

	local valid = true
	for k, j in ipairs(self.children) do
		for i, v in ipairs(j.children) do
			valid = valid
			 and (not v.tag_missing or not v.tag_missing[1])
			 and (not v.tag_invalid or not v.tag_invalid[1])
			 and (not v.error)
		end
	end

	local state = not self:submitstate() and FORM_NODATA
		or valid and FORM_VALID
		or FORM_INVALID

	self.dorender = not self.handle
	if self.handle then
		local nrender, nstate = self:handle(state, self.data)
		self.dorender = self.dorender or (nrender ~= false)
		state = nstate or state
	end
	return state
end

function SimpleForm.render(self, ...)
	if self.dorender then
		Node.render(self, ...)
	end
end

function SimpleForm.submitstate(self)
	return self:formvalue("cbi.submit")
end

function SimpleForm.section(self, class, ...)
	if instanceof(class, AbstractSection) then
		local obj  = class(self, ...)
		self:append(obj)
		return obj
	else
		error("class must be a descendent of AbstractSection")
	end
end

-- Creates a child field
function SimpleForm.field(self, class, ...)
	local section
	for k, v in ipairs(self.children) do
		if instanceof(v, SimpleSection) then
			section = v
			break
		end
	end
	if not section then
		section = self:section(SimpleSection)
	end

	if instanceof(class, AbstractValue) then
		local obj  = class(self, section, ...)
		obj.track_missing = true
		section:append(obj)
		return obj
	else
		error("class must be a descendent of AbstractValue")
	end
end

function SimpleForm.set(self, section, option, value)
	self.data[option] = value
end


function SimpleForm.del(self, section, option)
	self.data[option] = nil
end


function SimpleForm.get(self, section, option)
	return self.data[option]
end


function SimpleForm.get_scheme()
	return nil
end


Form = class(SimpleForm)

function Form.__init__(self, ...)
	SimpleForm.__init__(self, ...)
	self.embedded = true
end
```
