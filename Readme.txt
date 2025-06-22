Welcome to HearthStone v2.0-beta

NOTE TO CURRENT USERS:
I changed how this addon modifies the macros.

It now changes the line that "#HS" is on to something like "/use item:6948#HS", and not the line after the "#HS".
You will want to edit your macro, and remove the hearthstone usage line from before.

The macro charaters limit is tight, and 1 character here or there can make a difference.

What this does:

Allows editing of a macro to use specific or random hearthstones (or toys really).
A seperate list can be configured for each modifier.
If more than one hearthstone is given for a modifier, then a random one that is available and usable will be choosen.

How to use:

With a fresh install, the first step is to set the name for the HearthStone macro.
Use `/hs name MacroName` to define a new or current macro.

If it is a current macro, add the line `#HS` to the line you want this addon to change for you.

For example, with this current macro (named "Hearth"):
```
#showtooltip
/bye
/use Hearthstone
/played
```

Edit it to look like:
```
#showtooltip
/bye
/use Hearthstone#HS
/played
```

And tell HearthStone to use that macro:
`/hs name Hearth`


Adding HearthStones:

Just using a single Hearthstone is not why you are using this, and reading this document.
Adding a new stone to the list to use is done like this:

First, decide which modifier you want to use:  `/hs mods`
I like to have my Garrison Hearthstone usable with the alt modifier.

Open the Toy Box, find the Garrison Hearthstone, tell HearthStone to use it with the alt modifier:
`/hs add alt [Garrison Hearthstone]`   < shift-click the toy to get the link.

This will also show the list of toys to pick from for the alt modifier.

Adding to the list for no modifier can be done by omitting 'alt' in the command:
`/hs add [Garrison Hearthstone]`

Note: A toy can be added multiple times (it will simply increase the chances of picking it), and restricted toys can be added (they won't be randomly picked).


Removing a HearthStone:

Just like adding:
`/hs remove alt [Garrison Hearthstone]`

Note: if you added a toy multiple times, you will have to remove it multiple times to get rid of it fully.


Force an update:

If you want to force HearthStone to update the macro, just do this command:
`/hs update`
