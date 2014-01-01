luci_tutorials
==============

<p>These "Tutorials" are simply notes I used during a casual training I did on LuCI. Over the coming months I will start to actually work them into a set of discreet tutorials and bits of documentation so that others can leverage this toolkit.</p> 

<p>The LuCI web interface is slowly being moved to a JSON-RPC structure to reduce the ammount of on-node processing. The notes contained here that are focused on the CBI structure will eventually be supported by work about how to build the on-node hooks that allow browser-plugins and sites to communicate remotely with a LuCI enabled openWRT node.</p>

TODO: 
 * Organize notes into a more chapter based structure
 * Add section on JSON-RPC and remote site design
 * Add section on benchmarking various lua functions {eg. for backend calls (shell [sys/util.exec(uci)], C [model.uci], and io [io.write(/etc/config/uciFile)])} to show how to best write lua on embedded devices. 
