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

### How to Use
The sequence of events will look like this:

0.5. Select an image or other piece of data you want to replace (for example, Link's Progress Icon in file 0xB)

1. You replace some data using the GE Setup Editor in some file. (Replace Link's Progress Icon with another Icon, this part is essential for Step 2)

2. You track down the part of the file that has your change (a file comparison in HxD will typically reveal this). Take note of this offset in the file 
which should show where your data begins - this is called the originalOffset. (The offset cannot be found through the editor and must be found through a file compare or other method. This would be 0x70E0 for Link's Progress Icon).

4. You copy the data that you want to append to a new file. (from the beginning of the offset you discovered until the beginning of the next data/image (this was 0x7210 in for the example. There is often a row of two of 0's that signify the seperate between one file or the next). 
This may be difficult to see because each image has a footer that may not actually change if simply replaced, so file comparison alone may not be good enough. 

5. You look in the new file you just created for the first pointer (the format is `XXXXYYYY` where `XXXX * 4` is the offset of the next pointer and `YYYY * 4` is the offset of the data that 
will be converted by the game to a pointer) - this is called the internalFileTableOffset. (For Link's Progress Icon this is 0xE8 in your new file)

6. Most likely, but optionally, you want to append this to an existing file (this is most likely the same file you originally extracted from, thus 0xB). You need to know the Internal File Table Offset for this file 
- this is the internalFileTableOffsetTarget (This is easy to find in the editor, simply select the file in the editor and the internalFileTableOffsetTarget will be noted. This is 0x1EF8 in 0xB).
7. Open a command line and cd to this directory, then call the jar like so: `java -jar ./SSB64FileAppender.jar /path/to/newFile.bin originalOffset internalFileTableOffset /path/to/targetFileToAppendTo.bin internalFileTableOffsetTarget`.

Example: `java -jar ./SSB64FileAppender.jar "../smashremixprivate/roms/newFile.bin" 0x70E0 0xE8 "../smashremixprivate/roms/0xB.bin" 0x1EF8`

The tool should update all pointers in the internal file linked list and update the last pointer in the original file as well (changing it from 0xFFFF). If there are any external file pointers, you will get a warning message that details where in the file they occurred. You'll have to manually adjust those. Too bad!
This tool will automatically add spacers in between this file and the next.