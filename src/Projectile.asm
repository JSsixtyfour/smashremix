// Projectile.asm
if !{defined __PROJECTILE__} {
    define __PROJECTILE__()
    print "included Projectile.asm\n"

    include "OS.asm"

    scope Projectile {
        constant VANILLA_LAST_ID(0x1F)
        global variable NUM_REMIX_PROJECTILES(0x0)
        global variable LAST_PROJECTILE_ID(VANILLA_LAST_ID)

        macro add_projectile(name) {
            global variable Projectile.NUM_REMIX_PROJECTILES(Projectile.NUM_REMIX_PROJECTILES + 1)
            global variable Projectile.LAST_PROJECTILE_ID(Projectile.LAST_PROJECTILE_ID + 1)
            constant id.{name}(Projectile.LAST_PROJECTILE_ID)
            global variable Projectile.id.{name}(Projectile.LAST_PROJECTILE_ID)

            print "Added Projectile: {name} - ID: 0x" ; OS.print_hex(Projectile.id.{name}) ; print "\n"
        }

        add_projectile(SONIC_SPRING)
        add_projectile(BANJO_EGG)
        add_projectile(GOEMON_RYO)
        add_projectile(SHEIK_NEEDLE)
        add_projectile(CONKER_NUT)
        add_projectile(LANKY_NUT)
        add_projectile(GOLDENGUN_BULLET)
        add_projectile(DEDEDE_WADDLEDOO_BEAM)

        add_projectile(PIRATELAND_CANNONBALL)
        add_projectile(METALLICMADNESS_BEELASER)
        add_projectile(RAINBOWROAD_CHAINCHOMP)
        add_projectile(CACODEMON_THUNDERBALL)
    }
}