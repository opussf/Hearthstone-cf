Welcome to HearthStone v2.0

NOTE TO CURRENT USERS:
I changed how this addon modifies the macros.

It now changes the line that your tag is on to something like "/use item:6948#hs", and not the line after the "#hs".
You will want to edit your macro, and remove the hearthstone usage line from before.

The macro charater limit is tight, and 1 character here or there can make a difference.

What this does:

Allows editing of a macro to use specific or random hearthstones (or toys really).
A seperate list can be configured for each modifier.
If more than one hearthstone is given for a modifier, then a random one that is available and usable will be choosen.

How to use:

* Use `/hs` to open the UI
* Choose the tag, or make a new one
* Choose the modifier to work with
* Drag toys to the window (or anything that you can /use) for each modifier
* Create a macro (or modify an existing one), add your tag on an empty line.
* Drag the macro someplace to use
* Enjoy

Examples:

Edit it to look like:
```
#showtooltip
/bye
#hs
/played
```

Force an update:

If you want to force HearthStone to update the macro, just do this command:
`/hs update`

No action needed - updates run automatically after loading screens.
