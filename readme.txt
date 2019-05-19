In order to use this hack you will need to utilize the xdelta pack. Everything you will need is provided if you download all the files.

Step 1: Make sure you have an unaltered Super Smash 64 ROM that is a .z64 file (.n64 or .v64 will not work!). You can easily convert one of these files to .z64 via Tool64 (download here: https://www.zophar.net/utilities/n64aud/tool-n64.html). After conversion, ensure that the conversion was succesful by opening the new file in Tool64.).

Step 2: Start the Delta UI Program. In the Patch box click "Open", then select the your ROM file (make sure it is .z64)

Step 3: In the Source File box click "Open", select the current version of smashremix.xdelta

Step 4: In the Output File Box click "Open", select a name for the file that ends in .z64

Step 5: Click patch. You should now have a functioning copy of Smash Remix

Netplay: If you would like to play it on netplay, please replace your "Project64.rdb" file with the one that is also provided in the download.

DO NOT READ THE INFORMATION BELOW UNLESS YOU ARE INTERESTED IN HACKING - THIS WILL NOT RELEVANT TO MOST PEOPLE

The original xdelta will generate a smash rom that is compatible with my ASM code. Much of my edits are done within
the compressed data within the rom. If you try to utilize a vanilla Smash 64 rom, it will not work correctly. Even after this, you will not have a complete ROM, because some of my edits are done via the GE Editor.

You must utilize my originaly xdelta patch to generate a good ROM for Assembly.

After you create an original via the original xdelta, you must then place your legally acquired ROM in the roms folder for the assembly to work. The ROM must be named original.z64

The model data is located within gnd.bin in the src folder.

armor generates a suped up version of Yoshi's Armor when Ganondorf does a Warlock Punch.

slowattack changes the attack speeds of Ganondorf's attacks.

gnd.obj and gnd.mtl are the current model and materials used for Ganondorf (these are not utilized in the Assembly and are placed here for reference).
