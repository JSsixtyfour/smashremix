// main.asm

// general setup
arch    n64.cpu
endian  msb
include "assembler/N64.inc"

// copy fresh rom
origin  0x0
insert  "roms/original.z64"

// change ROM name
origin  0x20
db  "SMASH REMIX"
fill 0x34 - origin(), 0x20

// add asm to rom
origin  0x02400000
base    0x80400000
include "src/OS.asm"
include "src/String.asm"
include "src/Render.asm"
include "src/Action.asm"
include "src/File.asm"
include "src/Boot.asm"
include "src/Settings.asm"
include "src/Moveset.asm"
include "src/Command.asm"
include "src/Timeouts.asm"
include "src/GFX.asm"
include "src/BGM.asm"
include "src/Camera.asm"
include "src/Color.asm"
include "src/Combo.asm"
include "src/Crash.asm"
include "src/Credits.asm"
include "src/FD.asm"
include "src/FGM.asm"
include "src/GameEnd.asm"
include "src/Global.asm"
include "src/Handicap.asm"
include "src/Hazards.asm"
include "src/Hitbox.asm"
include "src/Item.asm"
include "src/Joypad.asm"
include "src/Menu.asm"
include "src/Pause.asm"
include "src/Practice.asm"
include "src/Spawn.asm"
include "src/Stages.asm"
include "src/Toggles.asm"
include "src/Cheats.asm"
include "src/TimedStock.asm"
include "src/Shield.asm"
include "src/Training.asm"
include "src/ComboMeter.asm"
include "src/VsStats.asm"
include "src/Widescreen.asm"
include "src/AA.asm"
include "src/Japan.asm"
include "src/FPS.asm"
include "src/SinglePlayer.asm"
include "src/Skeleton.asm"
include "src/Surface.asm"
include "src/SinglePlayerModes.asm"
include "src/SinglePlayerMenus.asm"
include "src/HRC.asm"
include "src/Bonus.asm"
include "src/TwelveCharBattle.asm"
include "src/Size.asm"
include "src/CharEnvColor.asm"
include "src/SwordTrail.asm"
include "src/GFXRoutine.asm"
include "src/Damage.asm"
include "src/Knockback.asm"
include "src/InputDelay.asm"
include "src/InputDisplay.asm"
include "src/StockMode.asm"
include "src/Stereo.asm"
include "src/Stamina.asm"
include "src/Practice_1P.asm"
include "src/SinglePlayerEnemy.asm"
include "src/PlayerTag.asm"
include "src/Reflect.asm"
include "src/Transitions.asm"
include "src/ZCancel.asm"
include "src/Tripping.asm"
include "src/PokemonAnnouncer.asm"
include "src/FootStool.asm"
include "src/AirDodge.asm"
include "src/JabLock.asm"
include "src/LedgeJump.asm"
include "src/PerfectShield.asm"
include "src/SpotDodge.asm"
include "src/AerialAttackFastFall.asm"
include "src/LedgeTrump.asm"
include "src/Hitstun.asm"
include "src/WallTeching.asm"
include "src/VsDemo.asm"
include "src/Teams.asm"
include "src/ChargeSmashAttacks.asm"
include "src/Gallery.asm"
include "src/Poison.asm"
include "src/DragonKingHUD.asm"
include "src/Accessibility.asm"
include "src/BlastZone.asm"
include "src/MagnifyingGlass.asm"

// CHARACTER
include "src/Character.asm"
include "src/AI.asm"
include "src/CharacterSelect.asm"
include "src/CharacterSelectDebugMenu.asm"
include "src/Costumes.asm"
include "src/Fireball.asm"
include "src/ResultsScreen.asm"
include "src/CharacterDataScreen.asm"
include "src/linkshared.asm"
include "src/captainshared.asm"
include "src/dkshared.asm"
include "src/nessshared.asm"
include "src/jigglypuffkirbyshared.asm"
include "src/yoshishared.asm"
include "src/pikashared.asm"
include "src/samusshared.asm"
// METAL MARIO
include "src/MetalMario/MetalMario.asm"
// FALCO
include "src/Falco/Phantasm.asm"
include "src/Falco/Falco.asm"
// GANONDORF
include "src/Ganondorf/Ganondorf.asm"
// YOUNG LINK
include "src/YoungLink/YoungLinkSpecial.asm"
include "src/YoungLink/YoungLink.asm"
// DR MARIO
include "src/DrMario/DrMario.asm"
// WARIO
include "src/Wario/WarioSpecial.asm"
include "src/Wario/Wario.asm"
// DARK SAMUS
include "src/DSamus/DSamus.asm"
// ELINK
include "src/ELink/ELink.asm"
// JSAMUS
include "src/JSamus/JSamus.asm"
// JNESS
include "src/JNess/JNess.asm"
// LUCAS
include "src/Lucas/LucasSpecial.asm"
include "src/Lucas/Lucas.asm"
// JLINK
include "src/JLink/JLink.asm"
// JFALCON
include "src/JFalcon/JFalcon.asm"
// JFOX
include "src/JFox/JFox.asm"
// JMARIO
include "src/JMario/JMario.asm"
// JLUIGI
include "src/JLuigi/JLuigi.asm"
// JDK
include "src/JDK/JDK.asm"
// EPIKA
include "src/EPika/EPika.asm"
// JPUFF
include "src/JPuff/JPuff.asm"
// EPUFF
include "src/EPuff/EPuff.asm"
// JYOSHI
include "src/JYoshi/JYoshi.asm"
// JPIKA
include "src/JPika/JPika.asm"
// ESAMUS
include "src/ESamus/ESamus.asm"
// BOWSER
include "src/Bowser/BowserSpecial.asm"
include "src/Bowser/Bowser.asm"
// GBOWSER
include "src/GBowser/GBowser.asm"
// PIANO
include "src/Piano/PianoSpecial.asm"
include "src/Piano/Piano.asm"
// WOLF
include "src/Wolf/WolfSpecial.asm"
include "src/Wolf/Wolf.asm"
// CONKER
include "src/Conker/ConkerSpecial.asm"
include "src/Conker/Conker.asm"
// MEWTWO
include "src/Mewtwo/MewtwoSpecial.asm"
include "src/Mewtwo/Mewtwo.asm"
// MARTH
include "src/Marth/MarthSpecial.asm"
include "src/Marth/Marth.asm"
// SONIC
include "src/Sonic/SonicSpecial.asm"
include "src/Sonic/Sonic.asm"
// SANDBAG
include "src/Sandbag/Sandbag.asm"
// SUPER SONIC
include "src/SSonic/SSonic.asm"
// SHEIK
include "src/Sheik/SheikSpecial.asm"
include "src/Sheik/Sheik.asm"
// NWARIO
include "src/NWario/NWario.asm"
// NLUCAS
include "src/NLucas/NLucas.asm"
// MARINA
include "src/Marina/MarinaSpecial.asm"
include "src/Marina/Marina.asm"
// NBOWSER
include "src/NBowser/NBowser.asm"
// NWOLF
include "src/NWolf/NWolf.asm"
// NDRM
include "src/NDrMario/NDrMario.asm"
// NSONIC
include "src/NSonic/NSonic.asm"
// NSHEIK
include "src/NSheik/NSheik.asm"
// DEDEDE
include "src/Dedede/DededeSpecial.asm"
include "src/Dedede/Dedede.asm"
// NMARINA
include "src/NMarina/NMarina.asm"
// GOEMON
include "src/Goemon/GoemonSpecial.asm"
include "src/Goemon/Goemon.asm"
// NFALCO
include "src/NFalco/NFalco.asm"
// NGANONDORF
include "src/NGanondorf/NGanondorf.asm"
// PEPPY
include "src/Peppy/PeppySpecial.asm"
include "src/Peppy/Peppy.asm"
// SLIPPY
include "src/Slippy/SlippySpecial.asm"
include "src/Slippy/Slippy.asm"
// BANJO
include "src/Banjo/BanjoSpecial.asm"
include "src/Banjo/Banjo.asm"
// NDSAMUS
include "src/NDSamus/NDSamus.asm"
// MLUIGI
include "src/MLuigi/MLuigi.asm"
// EBISUMARU/EBI
include "src/Ebi/EbiSpecial.asm"
include "src/Ebi/Ebi.asm"
// NMARTH
include "src/NMarth/NMarth.asm"
// NMTWO
include "src/NMewtwo/NMewtwo.asm"
// NDEDEDE
include "src/NDedede/NDedede.asm"
// NYOUNGLINK
include "src/NYoungLink/NYoungLink.asm"
// DRAGONKING
include "src/DragonKing/DragonKingSpecial.asm"
include "src/DragonKing/DragonKing.asm"
// NGOEMON
include "src/NGoemon/NGoemon.asm"
// NCONKER
include "src/NConker/NConker.asm"
// NBANJO
include "src/NBanjo/NBanjo.asm"


// KIRBY
include "src/Kirby/Kirby.asm"
include "src/KirbyHats.asm"
// JKIRBY
include "src/JKirby/JKirby.asm"

// MIDI
include "src/MIDI.asm"

OS.align(16)
midi_memory_block: // This is where music files will be loaded
fill MIDI.largest_midi  // Allocate as much space as we need!

OS.align(16)
file_table:  // This is where we move the file table to in order to load more files
fill 0x620

custom_heap: // This is where we move the heap to when we need to increase its size

// rom size = 64MB
origin 0x3E7FFFF
db 0x00
