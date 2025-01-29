rivertold
Would it be possible to add Dressing Room 2018 integration for saved gear sets?

There's this integration but it doesn't seem to work.
----
Federale
X  1) When adding a rule containing a reference to one of FCOs dynamic icons, the dynamic icon name is displayed in [Brackets] after the 'Category Name' field - is it possible to change this? Even when creating a custom category (not cloned from FCO 'presets') if you include fco_ismarked("dynamic_x") you get the extra text


2) It appears "others" won't shift from the 5th position in my list, regardless of the priority number set for other items. 1-4 are fine, the 5th added category to the bag goes under "others" and so do the rest


Edit: I set all priority values to 999, 998 etc and Others is now at the bottom. Does it have a hidden "weight"? I was using 900-400 previously.

Edit2: think all the issues I've had bar the #1 above have been my config. If anyone reading this, keep at it (and look for typos like 'weapons' instead of 'weapon').

----
atharti
Having huge game freezes on opening containers, for example event boxes.
Also freezing in AddOns menu provided by AutoCategory lag, as well as opening bag after looting new items. Microfreezeing on looting designs.
And inventory jump issue.

UPD: These lags most likely are caused by issues with GridList integration aswell.

Also isitemid() rule doesnt seem to work, rule is not recognizing ids i get with context menu tool. Such as 203611, archive consumable.

----
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
----
 Originally Posted by Pamplamouss
Originally Posted by Shadowfen
Originally Posted by Pamplamouss
Hi ! I have i little bug when I want take or put an item in banks. If the item is under my category "treasure map" I will up automatically on this category. I don't know why, I have tried to reinstall the addon, set by default but it doesn't work. I didn't see someone talk about this bug. Do you have a possible answer ?

Thank you for your job !
Sorry but I do not understand your problem report. Please clarify.
Yes sorry, I don't really know how to explain it. When I am on my bank. If I want take 1 item in a category which is very low (for exemple 100) the scroll bar go everytime to the middle of my inventory.
1 other player in my guild has the same bug.
Same problem when using this addon with Grid list addon.
----

Could we please have an option to disable the "AC: ItemID" thingy on our rightclick menu?
----

NOT A BUG!!

Can't remove pre-defined categories
Hi there, there seems to be a bug with the most recent update where I can't remove the pre-defined categories that you made with the add-on from my backpack permanently. Everytime I delete them they come back whenever I log out, and I'm using account-wide settings. I have even tried manually removing them from the saved variables file from all characters, and they still come back when I log back in.

I personally do not like using them (no offense), so fixing this would be greatly appreciated. I love this add on and it has been something I've depended on for years!