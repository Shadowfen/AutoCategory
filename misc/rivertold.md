----
numpy
I was trying to set up a filter for Companion Gear my wife's EU account on her computer. I had set it up on her NA a while back, and was finally getting around to doing the other server. I had it set up on my accounts on my computer(including the PTS), but none of hers.

The rule refused to take (sometimes disappearing while I was still imputing fields), and in the process ALL of our accounts have been affected, minus my PTS on my computer.

As near as I can tell, the fields and rule are correct, but it refuses to take or work. Any help would be appreciated, as we want to keep BoE (priority 70) separate if possible.

["tag"] = "Companion",
["name"] = "Companion Gear",
["rule"] = "iscompaniononly()",
["description"] = "Companion Gear",
["priority"] = 71
----

 Bug - items in inventory appear as something else
If I hover over an item, let's say some rubedite gauntlets, they are actually plunder skulls, or vice versa. The hover tooltip reveals what the items actually are. Disabling this add-on fixed that issue.
Worse, some items don't show up at all when searching them, because the add-on incorrectly classifies them as something else.
This only happens with newly looted items, items that already existed in inventory are not affected. Relogging or reloading UI is a temporary fix, but who has time for that every time you need your Fezez or Ezabi?
