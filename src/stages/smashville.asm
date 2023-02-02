// @ Description
// This should match the number of calls to add_sprint_info_array
constant NUM_SPRITE_INFO_ARRAYS(0x01)

// @ Description
// Not sure what the data is at this offset.
constant STAGE_FILE_OFFSET(0x00006D28)

// @ Description
// Here, need to add a sprite info array for each sprite animation option
sprite_info_arrays:
// bi-directional, one UFO only
Stages.add_sprite_info_array(0x0000, 0x0000, 0x0, 0x01)

// @ Description
// Finally, each sprite will have data associated with it that is 0x40 in size.
// This data is found via the pointer at 0xC in the bg info struct.
// Stuff them into a file and insert here.
insert sprite_data, "smashville.bin"

// @ Description
// Reimporting Guide:
// In order to find the values in the vanilla rom with the stage imported, you go to 8012F840 in RAM to a table that is 0x10 in size for each of the first 8 stages
// the offset at 0x8 is the STAGE_FILE_OFFSET in stages/smashville.asm
// then you follow the pointer at 0xC to the sprite data array, where i believe each sprite data struct is 0x40 in size
// copy those 0x40 size chunks (for as many different sprites as there are for that level) and put them in a bin file like i do for stages/smashville.bin, inserted in stages/smashville.asm
// Stages.bg_info needs to be updated to pull in the stages/[level].asm file
// sprite info arrays define paths for the sprite to take - always come from left/right/random, single/multiple, likelihood... use Stages.add_sprite_info_array for adding them, and make sure NUM_SPRITE_INFO_ARRAYS matches the number of times you call that macro
// finally, Stages.add_bg_animation must be called for that stage
// should be straightforward enough
// to test, you can 0 out the countdown counter at 80131AD8 