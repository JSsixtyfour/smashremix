The Smash Remix xdelta will generate the current version of the Ganondorf mod of Smash 64. No further patch is necessary. For those uninterested in the messing around with the source code, this is all you will need to play the mod. Use the xdelta UI (provided) and put your legally acquired rom in the original box and the xdelta in the patch box of the program. You will then have the Smash Remix/Ganondorf Mod.

If you would like to play it on netplay, please replace your "Project64.rdb" file with the one that is also provided in the link above.

The information below is only for those interested in the code/how I did this.

The original xdelta will generate a smash rom that is compatible with my ASM code. Much of my edits are done within
the compressed data within the rom. If you try to utilize a vanilla Smash 64 rom, it will not work correctly. Even after this, you will not have a complete ROM, because some of my edits are done via the GE Editor.

You must utilize my originaly xdelta patch to generate a good ROM for Assembly.

After you create an original via the original xdelta, you must then place your legally acquired ROM in the roms folder for the assembly to work. The ROM must be named original.z64

The model data is located within gnd.bin in the src folder.

armor generates a suped up version of Yoshi's Armor when Ganondorf does a Warlock Punch.

slowattack changes the attack speeds of Ganondorf's attacks.

gnd.obj and gnd.mtl are the current model and materials used for Ganondorf (these are not utilized in the Assembly and are placed here for reference).
