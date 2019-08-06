// FGM.asm
if !{defined __FGM__} {
define __FGM__()
print "included FGM.asm\n"

// @ Description
// This file allows FGM (forground music) to be played.

include "OS.asm"

scope FGM {

    // @ Description
    // Plays a sound effect (safe)
    // @ Arguments
    // a0 - fgm_id
    scope play_: {
        OS.save_registers()
        jal     0x800269C0
        nop
        OS.restore_registers()
        jr      ra
        nop
    }


    // item sounds
    scope item {
        constant BAT(52)
    }

    // main menu sounds
    scope menu {
        constant START(157)
        constant CONFIRM(158)
        constant SELECT_STAGE(159)
        constant TOGGLE(163)
        constant SCROLL(164)
        constant ILLEGAL(165)
    }

    // character select screen
    scope announcer {

        scope names {
            constant FIGHTING_POLYGON_TEAM(482)
            constant DONKEY_KONG(483)
            constant DK(483)
            constant CAPTAIN_FALCON(485)
            constant FALCON(485)
            constant FOX(486)
            constant GIANT_DONKEY_KONG(489)
            constant GDK(489)
            constant KIRBY(496)
            constant LINK(497)
            constant LUIGI(498)
            constant MARIO(499)
            constant NESS(501)
            constant PIKACHU(507)
            constant JIGGLYPUFF(508)
            constant SAMUS(513)
            constant YOSHI(536)
        }

        scope css {
            constant CHOOSE_YOUR_CHARACTER(479)
            constant FREE_FOR_ALL(512)
            constant TEAM_BATTLE(526)
            constant TRAINING_MODE(530)
        }

        scope team {
            constant BLUE(475)
            constant GREEN(491)
            constant RED(510)
        }

        scope results {
            constant DRAW_GAME(484)                 // unused
            constant NO_CONTEST(502)
            constant WINS(533)
            constant THIS_GAMES_WINNER_IS(533)
        }

        scope singleplayer {
            constant BOARD_THE_PLATFROMS(476)
            constant BONUS_STAGE(477)
            constant BREAK_THE_TARGETS(478)
            constant CONTINUE(481)
            constant GAME_OVER(487)
            constant RACE_TO_THE_FINISH(495)
            constant MARIO_BROTHERS(500)
            constant KIRBY_TEAM(529)
            constant YOSHI_TEAM(531)
            constant VERSUS(532)
        }

        scope fight {
            constant GAME_SET(488)
            constant GO(490)
            constant PLAYER_1(503)
            constant PLAYER_2(504)
            constant PLAYER_3(505)
            constant PLAYER_4(506)
            constant DEFEATED(511)
            constant SUDDEN_DEATH(514)
            constant TIME_UP(527)
        }

        scope misc {
            constant HOW_TO_PLAY(494)
            constant ARE_YOU_READY(509)
            constant SUPER_SMASH_BROTHERS(528)
            constant INCREDIBLE(533)
            constant SHINE(189)
            constant MARIO_POWERUP(212)
            constant MARIO_POWERDOWN(213)
            constant WARP_PIPE(214)
            constant FIREBALL(215)
            constant COIN(216)
            constant MARIO_JUMP(217)
            constant SHOW_ME_YOUR_MOVES(337)
        }

    }

}

} // __FGM__ 


