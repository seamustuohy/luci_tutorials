luci_tutorials
==============

<p>These "Tutorials" are simply notes I used during a casual training I did on LuCI. </p>

[You can find the training video here](https://www.youtube.com/edit?o=U&video_id=hSHXySh6lrI)

<p>The LuCI web interface is slowly being moved to a JSON-RPC structure to reduce the ammount of on-node processing. The notes contained here that are focused on the CBI structure will eventually be supported by work about how to build the on-node hooks that allow browser-plugins and sites to communicate remotely with a LuCI enabled openWRT node.</p>

TODO: 
 * Organize notes into a more chapter based structure
 * Add section on JSON-RPC and remote site design
 * Add section on benchmarking various lua functions {eg. for backend calls (shell [sys/util.exec(uci)], C [model.uci], and io [io.write(/etc/config/uciFile)])} to show how to best write lua on embedded devices. 
