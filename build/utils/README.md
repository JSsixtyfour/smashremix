# File Appenders
1. SSB64ImageFileAppender - stupid easy appending of images
2. SSB64FileAppender - generic appending of files

## SSB64ImageFileAppender
A simple tool for appending binary image data to Smash Remix. A lot of this was based off of https://github.com/jordanbarkley/Texture64.

I didn't bother making the code look nice. It works.

### Files Currently Supported
- 0A04 Stage Icons
- 0A05 Character Portraits

### How to Use
#### Stage Icons
1. Grab file 0A04 using the GE Editor and name it 0A04.bin.
2. In the same directory as 0A04.bin, put your stage icon file(s).
3. Drag your stage icon file(s) over StageIconAppender.bat - this will update 0A04.bin.
4. Inject 0A04.bin using the GE Editor.
5. Confirm using GE Editor's Image Tools.

#### Character Portraits
Note: Currently, Remix expects the flash portrait to be immediately after the normal portrait.
1. Grab file 0A05 using the GE Editor and name it 0A05.bin.
2. In the same directory as 0A05.bin, put your character portrait file(s).
3. Drag your character portrait file(s) over CharacterIconAppender.bat - this will update 0A05.bin.
4. Inject 0A05.bin using the GE Editor.
5. Confirm using GE Editor's Image Tools.

## SSB64FileAppender
A simple tool for appending data of any structure to Smash Remix. Loops through the pointers and adjusts them automatically. A lot of this was based off of https://github.com/jordanbarkley/Texture64.

I didn't bother making the code look nice. It works.

### How to Use
The sequence of events will look like this:

1. You replace some data using the GE Setup Editor in some file.
2. You track down the part of the file that has your change.
3. You take note of the offset in the file where your data begins - this is called the originalOffset.
4. You copy the data that you want to append to a new file.
5. You look in the new file for the first pointer (the format is `XXXXYYYY` where `XXXX * 4` is the offset of the next pointer and `YYYY * 4` is the offset of the data that will be converted by the game to a pointer) - this is called the internalFileTableOffset.
6. Most likely, but optionally, you want to append this to an existing file. You need to know the Internal File Table Offset for this file - this is the internalFileTableOffsetTarget.
7. Open a command line and cd to this directory, then call the jar like so: `java -jar ./SSB64FileAppender.jar /path/to/newFile.bin originalOffset internalFileTableOffset /path/to/targetFileToAppendTo.bin internalFileTableOffsetTarget`.

Example: `java -jar ./SSB64FileAppender.jar "../smashremixprivate/roms/bowser logo.bin" 0xB08 0x6FC "../smashremixprivate/roms/0023-bowser.bin" 0x0004`

The tool should update all pointers in the internal file linked list and update the last pointer in the original file as well (changing it from 0xFFFF). If there are any external file pointers, you will get a warning message that details where in the file they occurred. You'll have to manually adjust those. Too bad!