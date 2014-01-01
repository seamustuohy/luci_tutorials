Luci.util.append
----------------
Dont use this function.

This function uses the # operator to check the length of a table. This operator is known to cause errors on lists that combine numerically indexed tables and tables that have unique keys. 