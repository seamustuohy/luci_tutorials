<p align="right"><a href="06-debugging.md">06-debugging.md &larr; </a> | <a href="08-uci.md">&rarr; 08-uci.md</a></p>

Luci.util.append
----------------
Dont use this function.

This function uses the # operator to check the length of a table. This operator is known to cause errors on lists that combine numerically indexed tables and tables that have unique keys.
