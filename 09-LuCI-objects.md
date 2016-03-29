<p align="right"><a href="08-uci.md">08-uci.md &larr; </a>

# Yasnippet LuCI snippets.

See http://luci.subsignal.org/trac/wiki/Documentation for full LuCI documentation.

## CBI Snippets

### map
Creates a generic map object.

#### Attributes

```
mymap:readinput
```

if the map should read input or not boolean

```
mymap:proceed
```

If true (bool) this lets the map skip committing  unless "save and apply" was clicked... then its useless

```
mymap:flow
```

Values set by the cbi values passed in the entry call that called the map

```
mymap:uci
```

The UCI cursor the map uses to make changes

```
mymap:save
```

The flag that tells the parse function to save

```
mymap:changed
```

The flag that changes the maps state when somthing has changed but save and proceed are both unset/false

```
mymap:template
```

The html template that the map populates

```
mymap:parsechain
```

The list of objects within the map that should be rendered

```
mymap:scheme
```

TODO explore what schemes are used for

```
mymap:state
```

Used by dispatcher to redirect the user to various on_BLANK_to pages and to otherwise dispatch the pages based upon the state of the map

```
mymap:apply_on_parse
```

The flag that tells the map to apply all values when parsed

```
mymap:apply_needed
```

This value is what is used by the CBI pages to actually apply the uci changes that were saved


#### Methods

```
mymap:formvalue(key)
```

Returns the formvalue for the map

```
mymap:formvaluetable(key)
```

return the formvalue for the map as a table

```
mymap:get_scheme(sectiontype, option)
```

TODO explore scheme usage

```
mymap:submitstate()
```

Get the submission type of the submitted page

```
mymap:chain(config)
```

Chain another config file onto this maps parsechain !!!!!

```
mymap:state_handler(state)
```

do somthing based on the maps state (dummy function in base code)

```
mymap:parse(readinput, ...)
```

core parseing function for maps

```
mymap:render(...)
```

Render the map

```
mymap:section(class, ...)
```

Create a child section

```
mymap:add(sectiontype)
```

Add a section to the attacked UCI config TODO check how this works with chain()

```
mymap:set(section, option, value)
```

Set a value within a specified section

```
mymap:del(section, option)
```

Delete a value from a UCI config

```
mymap:get(section, option)
```

Get a value from this maps UCI  config file

```
mymap:commit_handler(submit_state)
```

Dummy function that gets passed submitstate on self.save


### section
Section objects.



#### Attributes

```
mysection.map
```

The map that this section belongs to

```
mysection.config
```

```
mysection.optionals
```

```
mysection.defaults
```

```
mysection.fields
```

```
mysection.tag_error
```

```
mysection.tag_invalid
```

```
mysection.changed
```

```
mysection.optional
```

This section is optional (Value, Flag)

```
mysection.addremove
```

```
mysection.dynamic
```

```
mysection.tabs
```

```
mysection.tab_names
```

```
mysection.template
```

The html template that the section populates

```
mysection.data
```

Table

```
mysection.rowcolors
```

Table allow row coloration

```
mysection.anonymous
```

Table TODO explore this

```
mysection.deps
```


```
mysection.err_invalid
```

typedsection

```
mysection.invalid_cts
```

typedsection


#### Methods

```
mysection:tab(tab, title, desc)
```

Define a tab for the section

```
mysection:has_tabs()
```

Check whether the section has tabs

```
mysection:option(class, option)
```

Append a new option to the section

```
mysection:taboption(tab)
```

Append a new tabbed option

```
mysection:render_tab(tab, ...)
```

Render a single tab

```
mysection:parse_optionals(section)
```

Parse optional options

```
mysection:add_synamic(field, optional)
```

add a dynamic option

```
mysection:parse_dynamic(section)
```

parse all dynamic options

```
mysection:cfgsection(section)
```

Return the sections UCI table

```
mysection:push_events()
```

Set map to changed

```
mysection:remove(section)
```

Delete this section

```
mysection:create(section)
```

Creates this section

```
mysection:parse(readinput)
```

Main parser for the section and TODO explore table internals (Table)

```
mysection:update(data)
```

Refresh table with new data (Table)

```
mysection:depends(option, value)
```

imits scope to sections that have certain option => value pairs (TypedSection)

```
mysection:checkscope(section)
```

Verifies scope of sections (TypedSection)

```
mysection:filter(section)
```

A function to filter out unwanted sections from a TypedSection (TypedSection)

```
mysection:validate(section)
```

A validation function for sections (TypedSection <- dummy function)


### option
Creates one of the predefined option objects.

#### methods

```
myoption:prepare()
```

THING AND STUFF

```
myoption:depends(field, value)
```

Add a dependencie to another field in this section

```
myoption:cbid(section)
```

creates and returns the unique cbid for this object

```
myoption:formcreated(section)
```

TODO find how this function is used

```
myoption:formvalue(section)
```

Returns the formvalue for this object

```
myoption:additional(value)
```

TODO see why this is a function

```
myoption:manditory(value)
```

Makes a value manditory. TODO see how setting rmempty to true on nil/false values makes things manditory

```
myoption:add_error(section, type, msg)
```

Set an error (optionally takes "invalid" and "missing"  types for predefined error messages)

```
myoption:parse(section, novld)
```

The core option parser. Your better know what your doing when editing this function

```
myoption:render(s, scope)
```

The function that renders the section for the page

```
myoption:cfgvalue(section)
```

Returns the UCI value of this object

```
myoption:validate(value)
```

Validates the form value

```
myoption:transform(value)
```

Same thing as validate... TODO see how it is used differently to best document how to take advantage of it

```
myoption:write(section, value)
```

Writes the value to UCI

```
myoption:remove(section)
```

Deletes a value from uci (NOT SET TO FALSE. DELETED)

```
myoption:reset_values(key, val)
```

Empties key and value lists (Value, ListValue, MultiValue)

```
myoption:value(key, value)
```

Adds a value to the key and val lists (Value, ListValue, MultiValue) or sets value (DummyValue)

```
myoption:value_list(section)
```

split list of UCI config values by the delimiter and return them as a table (MultiValue)

#### Attributes

```
myoption.template
```

The htm template to use (ALL)

```
myoption.null
```

Value can be empty

```
myoption.default
```

The default value (Value, Flag)

```
myoption.size
```

The size of the input fields (ListValue)

```
myoption.rmempty
```

Unset value if empty (All)

```
myoption.optional
```

This value is optional (Value, Flag)

```
myoption.vallist
```

A table of value, key pairs (Value, ListValue, MultiValue, StaticList, DynamicList)

```
myoption.keylist
```

A table of key, value pairs (Value, ListValue, MultiValue, StaticList, DynamicList)

```
myoption.value
```

The value to display (DummyValue)

```
myoption.enabled
```

The value to write if the box is checked (Flag)

```
myoption.disabled
```

The value used to signify that the option should be deleted or written to the file (Flag)

```
myoption.widget
```

The widget that will be used (select, radio) (ListValue, MultiValue,StaticList)

```
myoption.delimiter
```

he delimiter that will separate the values (default: " ") (MultiValue, StaticList)

```
myoption.override_scheme
```

```
myoption.rows
```

Literally the number of rows (TextValue)

```
myoption.inputstyle
```

class="cbi-input-<%=self.inputstyle or "button" %>" (Button)

```
myoption.maxlength
```

The maximum length (Value)


### attr
Use attr to access special map, section, and option attributes.



### method
Use method to access special map, section, and option methods.

## Controller Snippets

### entry
Create a generic entry for a cbi controller's index.

#### Attributes

```
myentry.i18n
```

```
myentry.dependent
```

```
myentry.leaf
```

```
myentry.sysauth
```

#### Parameters

```
myentry.noheader
```

```
myentry.nofooter
```

```
myentry.on_success_to
```

```
myentry.on_changed_to
```

```
myentry.on_valid_to
```

```
myentry.autoapply
```
