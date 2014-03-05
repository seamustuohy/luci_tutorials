The UCI system
===============


Writing bash scripts using the /lib/config/uci.sh or the uci command line functions
-------------------------------------------------


Setting uci anonymously named sections
---------------------------------------

if you have a uci config that has sections with only section types and no stated name there is a special syntax for modifying them


```
config system
	list affects 'luci_statistics'
	option init 'avahi-daemon'

config system
	list affects 'luci_statistics'
	option init 'pineapple'
```
	

You can use the command line interface to modify only the first like this:

```uci set ucitrack.@system[0].init=new-value```

You can use the /lib/config/uci.sh scripts to do it like this

```uci_set ucitrack @system[0] init new-value```

You can access the last in one of two ways:
```
uci set ucitrack.@system[-1].init=new-value
uci set ucitrack.@system[1].init=new-value
```
[-1] will get the last section. [-2] will get the second from last, and etc.

You don't even have to specify the config type.
```uci set ucitrack.@[-1].init=new-value```

This will take the last section in the config file and modify it.
