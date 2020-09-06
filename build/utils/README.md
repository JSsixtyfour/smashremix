# SSB64ImageFileAppender
A simple tool for appending binary image data to Smash Remix. A lot of this was based off of https://github.com/jordanbarkley/Texture64.

I didn't bother making the code look nice. It works.

## Files Currently Supported
- 0A04 Stage Icons
- 0A05 Character Portraits

# How to Use
## Stage Icons
1. Grab file 0A04 using the GE Editor and name it 0A04.bin.
2. In the same directory as 0A04.bin, put your stage icon file(s).
3. Drag your stage icon file(s) over StageIconAppender.bat - this will update 0A04.bin.
4. Inject 0A04.bin using the GE Editor.
5. Confirm using GE Editor's Image Tools.

## Character Portraits
Note: Currently, Remix expects the flash portrait to be immediately after the normal portrait.
1. Grab file 0A05 using the GE Editor and name it 0A05.bin.
2. In the same directory as 0A04.bin, put your character portrait file(s).
3. Drag your character portrait file(s) over CharacterIconAppender.bat - this will update 0A05.bin.
4. Inject 0A05.bin using the GE Editor.
5. Confirm using GE Editor's Image Tools.