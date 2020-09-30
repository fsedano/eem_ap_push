# TCL script to write tag config on demand

![](tcl_write_tag.gif)

## Installation

* Create a directory on bootflash (i.e. applets)
* Copy the tcl file to that directory
* Add the following config:
```
event manager directory user policy "bootflash:/applets"
event manager policy appush.tcl
```
* To execute run:
```
event manager run appush.tcl
```