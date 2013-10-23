--- Redirects a page to https if the path is within the "node" path.
-- @param node  node path to check. format as such -> "/NODE/" 
-- @param env A table containing the REQUEST_URI and the SERVER_NAME. Can take full luci.http.getenv()
-- @return True if page is to be redirected. False if path does not include node or if https is already on.
function check_https(node, env)
   if string.match(env.REQUEST_URI, node) then
	  if env.HTTPS ~= "on" then
		 luci.http.redirect("https://"..env.SERVER_NAME..env.REQUEST_URI)
		 return true
	  end
	  return false
   end
   return false
end
