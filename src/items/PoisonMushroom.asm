// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(Item.SuperMushroom.spawn_custom_item_based_on_star_)
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant PLAYER_COLLISION(Item.SuperMushroom.collide_mushroom_)
constant THROW_ITEM(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xDE0)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw 0x8018D040                           // 0x04 - hard-coded pointer to file 0xFB
dw FILE_OFFSET                          // 0x08 - offset to item footer in file 0xFB
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?
dw Item.SuperMushroom.movement_routine_no_bounce_  // 0x14 - movement routine
dw Item.SuperMushroom.ground_collision_no_bounce_  // 0x18 - ground routine
dw 0x80174A0C                           // 0x1C - ? player contact? (using Star)
dw 0, 0, 0, 0                           // 0x20 - 0x2C - ?
dw 0                                    // 0x30 - ?
dw 0                                    // 0x34 - ?
dw 0                                    // 0x38 - ? resting state? (using Star)
dw 0                                    // 0x3C - ?
