--http://luci.subsignal.org/trac/wiki/Documentation/ModulesHowTo

module("luci.path.to.this.controller.file", package.seeall)


function index()
   entry(path, target, title=nil, order=nil)
end

path = "/cgi-bin/luci/"+{"path", "that", "follows"}
true_statement = (path == "http://192.168.1.20/cgi-bin/luci/path/that/follows")

target = call("function") or cbi("model (cbi)") or template("view (html)")

title = "menu option title"

order = "weighting in the menu structure"

--CBI
--http://luci.subsignal.org/trac/wiki/Documentation/ModulesHowTo#CBImodels
