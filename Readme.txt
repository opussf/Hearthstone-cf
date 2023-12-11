Welcome to HearthStone v0.1.6

What this does:

Allows editing of a macro to use specific or random hearthstones (or toys really).
A seperate list can be configured for each modifier.
If more than one hearthstone is given for a modifier, then a random one that is available and usable will be choosen.


How to use:

With a fresh install, the first step is to set the name for the HearthStone macro.
Use `/hs name MacroName` to define a new or current macro.

If it is a current macro, add the line `#HS` to the line before the line you want this addon to change for you.

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
#HS
/use Hearthstone
/played
```

And tell HearthStone to use that macro:
`/hs name Hearth`


Adding HearthStones:

Just using a single Hearthstone is not why you are using this, and reading this document.
Adding a new stone to the list to use is done like this:

First, decide which modifier you want to use:  `/hs mods`
I like to have my Garrison Hearthstone usable with the alt modifier.

Open the Toy Box, find the Garrison Hearthstone, tell HearthStone to it with the alt modifier:
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
