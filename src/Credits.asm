// Credits.asm
if !{defined __CREDITS__} {
define __CREDITS__()
print "included Credits.asm\n"

// @ Description
// This file allows us to add additional credits on the staff roll screen.
// It creates a /build/credits.bin with string data that must be injected into original.z64 separately.

include "OS.asm"

scope Credits {
    // @ Description
    // Update original section info table so that it goes to the first added section after 0x54 names
    OS.patch_start(0x183F58, 0x80136858)
    dw 0x54
    OS.patch_end()

    // @ Description
    // Holds the number of added titles
    variable added_titles(0)

    // @ Description
    // Holds the number of added companies
    variable added_companies(0)

    // @ Description
    // Holds the number of added names
    variable added_names(0)

    // @ Description
    // Holds the total number of names as we build our custom list
    variable total_names(0x54)

    // @ Description
    // Holds the number of added characters
    variable added_characters(0)

    // @ Description
    // Holds the starting index of added titles
    variable title_start(0)

    // @ Description
    // Holds the starting index of added companies
    variable company_start(0)

    // @ Description
    // Holds the starting index of added names
    variable name_start(0)

    // @ Description
    // Holds the starting index of details for added names
    variable details_start(0)

    // @ Description
    // Adds a title to the credits
    // @ Arguments
    // title - the title
    macro add_title(title) {
        evaluate n(added_titles)
        evaluate ts(title_start)

        // calculate length of title string
        variable start(origin())
        db {title}
        variable end(origin())
        origin start
        evaluate l(end - start)

        // create struct for this title
        global define title_{n}.start({ts})
        global define title_{n}.length({l})
        global define title_{n}.string({title})
        global define title_{n}.section_end(-1)
        if ({n} > 0) {
            evaluate prev({n} - 1)
            evaluate tn(total_names)
            global define title_{prev}.section_end({tn})
        }

        // update global variables
        global variable added_titles(added_titles + 1)
        global variable title_start(title_start + (end - start))
    }

    // @ Description
    // Adds a company to be used in the credits
    // @ Arguments
    // company_id - ID to reference the company by
    // company - the company
    macro add_company(company_id, company) {
        evaluate n(added_companies)
        evaluate cs(company_start)

        global define company.id.{company_id}({n})

        // calculate length of title string
        variable start(origin())
        db {company}
        variable end(origin())
        origin start
        evaluate l(end - start)

        // create struct for this title
        global define company_{n}.start({cs})
        global define company_{n}.length({l})
        global define company_{n}.string({company})

        // update global variables
        global variable added_companies(added_companies + 1)
        global variable company_start(company_start + (end - start))
    }

    // @ Description
    // Adds a name under the current title to the credits
    // @ Arguments
    // name - the name string
    // details - the details string (displayed when name is selected)
    // company_id - the company_id to use (the purple text in the details box)
    macro add_name(name, details, company_id) {
        evaluate n(added_names)
        evaluate ns(name_start)
        evaluate ds(details_start)

        // calculate length of name string
        variable start(origin())
        db {name}
        variable end(origin())
        origin start
        evaluate l(end - start)

        // calculate length of details string
        db {details}
        variable details_end(origin())
        origin start
        evaluate dl(details_end - start)

        // create struct for this name
        global define name_{n}.start({ns})
        global define name_{n}.length({l})
        global define name_{n}.string({name})
        global define name_{n}.details_start({ds})
        global define name_{n}.details_length({dl})
        global define name_{n}.details_string({details})
        global define name_{n}.company({company_id})

        // update global variables
        global variable total_names(total_names + 1)
        global variable added_names(added_names + 1)
        global variable name_start(name_start + (end - start))
        global variable details_start(details_start + (details_end - start))
    }

    // @ Description
    // Constants for type of string
    scope string_type {
        constant SCROLLING(0x0000)
        constant DETAILS(0x0001)
    }

    // @ Description
    // Converts the given string into a staff roll string
    // @ Arguments
    // str - the string
    // type - the type (see string_type)
    macro convert_string(str, type) {
        variable start(origin())
        dw {{str}}
        variable end(origin())

        origin start

        while (origin() < end) {
            evaluate n(origin())
            read32 char_{n}, origin()

            if ((char_{n} >= 'A') && (char_{n} <= 'Z')) {
                // A-Z
                dw char_{n} - 'A'
            } else if ((char_{n} >= 'a') && (char_{n} <= 'z')) {
                // a-z
                dw char_{n} - 'a' + 26
            } else if ({type} == string_type.SCROLLING) {
                if (char_{n} == '.') {
                    dw 0x34
                } else if (char_{n} == ',') {
                    dw 0x35
                } else if (char_{n} == '4') {
                    dw 0x37
                } else if ((char_{n} >= '0') && (char_{n} <= '9')) {
                    dw char_{n} + 0x20 // 0x50 - 0x59 (we'll skip 0x54 though since 4 is already available
                } else if (char_{n} == '_') {
                    dw 0x54
                } else if (char_{n} == '!') {
                    dw 0x5A
                } else if (char_{n} == '-') {
                    dw 0x5B
                } else if (char_{n} == '/') {
                    dw 0x5C
                } else if (char_{n} == '*') {
                    dw 0x5D
                } else if (char_{n} == '(') {
                    dw 0x5E
                } else if (char_{n} == ')') {
                    dw 0x5F
                } else if (char_{n} == '@') {
                    dw 0x60
                } else if (char_{n} == '~') { // ã
                    dw 0x61
                } else {
                    // replace all unhandled characters with a space
                    dw -0x21
                }
            } else { // string_type.DETAILS
                if (char_{n} == ':') {
                    dw 0x34
                } else if ((char_{n} >= '0') && (char_{n} <= '9')) {
                    dw char_{n} * -1 + 0x6E
                } else if ((char_{n} == '(') || (char_{n} == ')')) {
                    dw char_{n} + 0x1F
                } else if (char_{n} == '.') {
                    dw 0x3F
                } else if (char_{n} == '-') {
                    dw 0x40
                } else if (char_{n} == ',') {
                    dw 0x41
                } else if (char_{n} == '&') {
                    dw 0x42
                } else if (char_{n} == '"') {
                    dw 0x43
                } else if (char_{n} == '/') {
                    dw 0x44
                } else if (char_{n} == '\s') {
                    dw 0x45
                } else if (char_{n} == '?') {
                    dw 0x46
                } else if (char_{n} == '|') {
                    dw -0x37
                } else {
                    // replace all unhandled characters with a space
                    dw -0x21
                }
            }
        }
    }

    // @ Description
    // Adds new characters
    // @ Arguments
    // width - width of texture
    // height - height of texture
    // offset - offset to texture in texture file
    macro add_new_character(width, height, offset) {
        evaluate n(added_characters)

        // create struct for this character
        global define char_{n}.width({width})
        global define char_{n}.height({height})
        global define char_{n}.offset({offset})

        // update global variables
        global variable added_characters(added_characters + 1)
    }

    add_new_character(0x10, 0x16, 0x7958) // 0
    add_new_character(0x0C, 0x16, 0x7A18) // 1
    add_new_character(0x10, 0x16, 0x7AE0) // 2
    add_new_character(0x10, 0x16, 0x7BA8) // 3
    add_new_character(0x12, 0x18, 0x7C70) // _
    add_new_character(0x10, 0x16, 0x7E10) // 5
    add_new_character(0x10, 0x16, 0x7ED8) // 6
    add_new_character(0x10, 0x16, 0x7FA0) // 7
    add_new_character(0x10, 0x16, 0x8068) // 8
    add_new_character(0x10, 0x16, 0x8130) // 9
    add_new_character(0x08, 0x16, 0x81F8) // !
    add_new_character(0x0A, 0x16, 0x82C0) // -
    add_new_character(0x10, 0x16, 0x8388) // /
    add_new_character(0x0B, 0x16, 0x8470) // *
    add_new_character(0x0C, 0x1F, 0x8538) // (
    add_new_character(0x0C, 0x1F, 0x8640) // )
    add_new_character(0x14, 0x16, 0x8748) // @
    add_new_character(0x0F, 0x16, 0x88B8) // ã - use ~ below

    // @ Description
    // Helper to update the pointers in the Remix credits file as we go
    macro update_pointer(pointer_offset) {
        evaluate start(origin() - REMIX_CREDITS_FILE_ORIGIN)
        pushvar origin, base
        origin REMIX_CREDITS_FILE_ORIGIN + {pointer_offset} + 2
        dh {start}/4
        pullvar base, origin
    }

    // ADD NAMES HERE
    add_company(remix, "(Smash Remix)")

    add_title("Project Leader")
    add_name("The_Smashfather", "I'm gonna make them a mod|they can't refuse", remix)

    add_title("Designer and Gameplay Developer")
    add_name("Fray", "Clone Engine|Character Programming|Balance & Design Direction", remix)

    add_title("Developer")
    add_name("MarioReincarnate", "Let's just say you owe him|lunch", remix)
    add_name("Cyjorg", "Stage Engine", remix)
    add_name("Halofactory", "That's the way she goes.", remix)

    add_title("Lead Artist")
    add_name("Sope", "Character Modeling|Character Artwork|Stage Modeling|Smash Remix Logo", remix)
    
    add_title("Lead Musician")
    add_name("Pringles", "You didn't see 60 bucks|lyin' around, did ya bud?", remix)

    add_title("Animation and Model Import Specialist")
    add_name("Subdrag", "Living Legend|Creator of GE Editor", remix)

    add_title("Moveset Designer")
    add_name("Honey", "Gameplay Balance & Design", remix)

    add_title("Lead Tester")
    add_name("goombapatrol", "Quality Control|They make it, I break it", remix)

    add_title("Installation Specialist")
    add_name("CEnnis91", "-- .- -.. .|-.-- --- ..-|.-.. --- --- -.-", remix)

    add_title("Modelers")
    add_name("Retro64", "Character Modeling|Stage Modeling", remix)
    add_name("Sope", "Character Modeling|Stage Modeling", remix)
    add_name("Likiji123", "Onett Model", remix)
    add_name("Fray", "Falco and Wario Models,|Fray's Stage Model", remix)
    add_name("Pik", "Marth and Giga Bowser|Models", remix)
    add_name("Dshaynie", "Dark Samus, Young Link|Models", remix)
    add_name("Garret Atwood", "Turtle - Great Bay", remix)
    add_name("Adrian Garcia", "Dark Samus Textures", remix)
    add_name("M-1", "Wolf Model, Gerudo Valley", remix)
    add_name("TheQuickSlash", "Stage Modeller|\dDork\d -sope|oFTo | https://youtu.be/ | widZEAJc0QM", remix)
    add_name("Halofactory", "Sheik Model|Smashville v2", remix)

    add_title("Artists")
    add_name("Sope", "Character Models, VFX,|Character Artwork", remix)
    add_name("Retro64", "Remix 1P Character Icons,|Miscellaneous VFX, Promo|Art", remix)
    add_name("Connor Rentz", "Ganondorf Portrait", remix)
    add_name("Colonel Birdstrong", "Young Link Portrait", remix)
    add_name("Jay6T4", "Additional Menu Graphics,|Extra Costumes for|Original 12", remix)
    add_name("Likiji123", "", remix)
    add_name("Pik", "Remix 1p Victory Image", remix)
    add_name("Gael Romo", "", remix)
    add_name("TheQuickSlash", "Sonic Victory Image", remix)
    add_name("Halofactory", "Sheik Portrait", remix)

    add_title("Animators")
    add_name("Sope", "Character and Stage|Animations", remix)
    add_name("Fray", "Character and Cinematic|Animation", remix)
    add_name("Coolguy", "Character Animations", remix)
    add_name("Super4ng", "Character Animations", remix)
    add_name("dshaynie", "Character Animation and|Cinematic Designer", remix)
    add_name("Retro64", "Character and Stage|Animation", remix)
    add_name("MrLuigi001", "Character Animations", remix)
    add_name("SushiiZ", "Character Animations,|Work on Conker and Bowser", remix)
    add_name("Meekal", "Character Animations", remix)
    add_name("BlazingFireOmega", "Character Animations", remix)
    add_name("PrufStudent", "Character Animations", remix)
    add_name("Zeozen", "Character Animations", remix)
    add_name("M-1", "Character Animations", remix)
    add_name("Halofactory", "Character Animations", remix)
    add_name("TheQuickSlash", "Character Animations", remix)

    add_title("Musicians")
    add_name("TT", "Music Porter and Arranger", remix)
    add_name("MyNewSoundtrack", "Arranger", remix)
    add_name("PablosCorner", "Instrument Designer|Music Porter and Arranger", remix)
    add_name("Sope", "Music Porter and Arranger", remix)
    add_name("Retro64", "Music Porter", remix)
    add_name("DSC", "Music Porter", remix)
    add_name("Coffee", "Music Porter and Arranger", remix)
    add_name("mosky2000", "Music Porter - Crescent|Island, Frosty Village,|Windy and Co", remix)
    add_name("Jay6T4", "Various VS Stage|Arrangements, Sonic|Victory Theme|Arrangement", remix)
    add_name("PurpleFreezer", "Arranger", remix)
    add_name("Pun", "Music Porter and Arranger", remix)
    add_name("Fray", "All-Star Rest Area and|Mewtwo Victory Theme|Arrangement, Various|Track Mixing", remix)
    add_name("TheQuickSlash", "Sonic 2 Special Stage,|Sonic CD Special Stage|Arrangements,|Bein' Friends", remix)
    add_name("supa", "", remix)
    add_name("Pringles", "Three twenties,|or something?", remix)
    add_name("TheMrIron2", "", remix)
    add_name("Unforseen Uplink", "", remix)

    add_title("Stage Designers")
    add_name("BridGurrr", "Ganon's Tower, Deku Tree,|First Destination", remix)
    add_name("Jay6T4", "Various VS Stages, Bonus|Stages, Home-Run Contest", remix)
    add_name("Plaehni", "Muda Kingdom", remix)
    add_name("Farcry15", "Goomba Road, Zebes|Landing, Norfair, Cool|Cool Mountain, Great|Bay, Mad Monster Mansion", remix)
    add_name("smb123w64gb", "Tower of Heaven", remix)
    add_name("Sope", " Smashketball, Glacial River,|Congo Falls, Planet|Clancer, Jungle Japes,|Pirate Land, Metallic|Madness", remix)
    add_name("Fray", "Fray's Stage, Pirate Land,|Miscellaneous Layout|Direction", remix)
    add_name("Snooplax", "Bowser's Stadium", remix)
    add_name("Sixty Four", "Frosty Village", remix)
    add_name("M-1", "Gerudo Valley", remix)
    add_name("Retro64", "Dr. Mario, Kitchen Island,|Onett, New Pork City,|Bowser's Keep, Windy,|Casino Night Zone", remix)
    add_name("TheQuickSlash", "dataDyne, Castle Siege", remix)
    add_name("ownsoldier", "Rith Essa", remix)
    add_name("Halofactory", "Dracula's Castle,|Reverse Castle", remix)

    add_title("Voice Artists")
    add_name("Zarkpudd", "Narration", remix)
    add_name("Puma Pet", "Editing and Effects", remix)

    add_title("Modders")
    add_name("Qapples", "", remix)
    add_name("smb123w64gb", "", remix)
    add_name("FaxMeAppleJuice", "Regional Variant Porting", remix)
    add_name("goombapatrol", "Menu Coding Support,|1P Practice Mode,|Dpad map,|Miscellaneous Coding", remix)

    add_title("Consultants")
    add_name("Madao", "Moveset Consultant", remix)
    add_name("DannySsB", "Moveset Consultant", remix)
    add_name("tehz", "Coding Consultant", remix)
    add_name("Carnivorous", "Stage Consultant", remix)
    add_name("CrookedPoe/Clockwise", "N64 Displaylist Consultant", remix)
    add_name("CrashOveride", "Animation and Modeling|Consultant", remix)
    add_name("M-1", "Animation and Modeling|Consultant", remix)
    add_name("Kaki", "Stage Consultant - Tent|Final Destination", remix)
    add_name("Katakiri", "Stage Consultant - Green|Hill Zone", remix)
    add_name("Aqua Midi", "Instrument Consultant", remix)

    add_title("Playtesters")
    add_name("Abnormal Adept", "", remix)
    add_name("Darkhorse", "Playtesting, Frame Data|Analysis", remix)
    add_name("hanson933", "", remix)
    add_name("IronAidan07", "", remix)
    add_name("majin_bukkake", "", remix)
    add_name("minymidge", "", remix)
    add_name("Stevie G", "", remix)
    add_name("Luigidoed", "", remix)
    add_name("Hyper64", "", remix)
    add_name("Dogs_Johnson", "", remix)
    add_name("emptyW", "", remix)
    add_name("FaxMeAppleJuice", "", remix)
    add_name("phreshguy", "", remix)
    add_name("measTHEbeast", "", remix)
    add_name("Xrmy", "", remix)
    add_name("Q!", "", remix)
    add_name("Raychu", "", remix)
    add_name("Pluto", "", remix)
    add_name("The Yid", "", remix)
    add_name("Wololo", "", remix)
    add_name("Wookiee", "", remix)
    add_name("thelordoflight", "", remix)
    add_name("JODO", "", remix)
    add_name("farcry15", "Hardware Testing", remix)
    add_name("Mimimax", "", remix)
    add_name("kyleglor", "", remix)
    add_name("Revan", "", remix)
    add_name("Big Red", "", remix)
    add_name("Bamboo", "", remix)
    add_name("cobr", "", remix)
    add_name("Dr. D", "", remix)
    add_name("Andykins", "", remix)
    add_name("Loz", "", remix)
    add_name("jonnjonn", "", remix)
    add_name("Kaki", "", remix)
    add_name("Maafia", "", remix)
    add_name("SushiiZ", "", remix)
    add_name("JaimeHR", "", remix)
    add_name("MojoMonkey", "", remix)
    add_name("DannySsB", "", remix)
    add_name("Vidya James", "", remix)
    add_name("SuperSqank", "", remix)
    add_name("Goon", "", remix)
    add_name("JeyKeyAr", "", remix)
    add_name("RazzSmash", "", remix)
    add_name("PADB", "", remix)
    add_name("madrush", "", remix)
    add_name("krakhead", "", remix)
    add_name("KM", "", remix)
    add_name("fruitman", "", remix)
    add_name("baby caweb", "", remix)
    add_name("MissingN0pe", "", remix)
    add_name("Shalaka", "", remix)
    add_name("foca64", "", remix)
    add_name("Lowww", "", remix)
    add_name("Kix", "", remix)
    add_name("HAMMERHEART", "", remix)
    add_name("beta", "", remix)
    add_name("LOC", "", remix)
    add_name("Maciaga", "", remix)
    add_name("pecosix", "", remix)
    add_name("PKStickThing", "", remix)
    add_name("SyluxVIV", "", remix)
    add_name("Weedwack", "", remix)
    add_name("KeroKeroppi", "", remix)
    add_name("1upShyguy", "", remix)
    add_name("epona", "", remix)
    add_name("Stew", "", remix)
    add_name("thetaiter", "", remix)
    add_name("LesbianChemicalPlant", "", remix)
    add_name("Bedoop!", "", remix)
    add_name("CMM1215", "", remix)
    add_name("Djzach", "", remix)
    add_name("Exile", "", remix)
    add_name("FrankBlack22", "", remix)
    add_name("Freean", "", remix)
    add_name("Gibrani", "", remix)
    add_name("Huntsman", "", remix)
    add_name("Indefa", "", remix)
    add_name("MultiVolt", "", remix)
    add_name("Policombo", "", remix)
    add_name("Raihem/MayRai", "", remix)
    add_name("Roman", "", remix)
    add_name("ShyGuyGH", "", remix)
    add_name("The Ranger", "", remix)
    add_name("Tylan 64", "", remix)
    add_name("Toad", "", remix)
    add_name("Wiseacre", "", remix)
    add_name("MissingNo.", "", remix)
    add_name("Pringles", "Nobody wants to |admit they ate |nine cans of |ravioli.", remix)


    add_title("Original Sequencing Musical Credits")
    add_name("Golen", "Ganondorf Battle", none)
    add_name("King Meteor", "Corneria, Flat Zone 2,|Multi-Man Melee 2", none)
    add_name("Sirius", "Kokiri Forest", none)
    add_name("Jo~o *Johnnyz* Buaes", "Battle! Champion, Victory:|Mewtwo, The Road to|Cerulean City", none)
    add_name("Sonic SBL", "Town Hall and Tom Nook's|Store", none)
    add_name("ChocolateJake", "Stonecarving City", none)
    add_name("jrlepage", "Final Destination (Melee)", none)
    add_name("Matas Pealoza", "Ballad of the Godess", none)
    add_name("pigpag", "Last Surprise", none)
    add_name("Zenkusa", "Battlefield Ver. 2, Flat|Zone", none)
    add_name("Ryland Fallon", "Melee Menu", none)
    add_name("Jonathan Shen", "Gourmet Race (Alternative)", none)
    add_name("Dave Phaneuf", "Brinstar Depths, Metal|Battle", none)
    add_name("Sean Bee", "River Stage, Clock Tower", none)
    add_name("Insane Apu", "Hyrule Temple", none)
    add_name("Chibi Vegito", "All I Needed Was You,|Together We Ride", none)
    add_name("Leu", "DCMC Performance,|Unfounded Revenge", none)
    add_name("Mantato", "Blooming Villain", none)
    add_name("mittens", "Team Select Music", none)
    add_name("Anikom15", "Pollyanna (I Believe in You)", none)
    add_name("Dentelle (D. Stphanie)", "Yoshi's Island", none)
    add_name("David Alberto", "Temple Theme 8-bit", none)
    add_name("Dr. Fruitcake", "Peach's Castle (Melee),|Battle Fanfare", none)
    add_name("JexuBandicoot527", "Multi-Man Melee 1", none)
    add_name("Ethan Williams", "Cruel Brawl", none)
    add_name("Kirby of Doom", "Showdown (Gourmet Race)", none)
    add_name("Kiopineapple", "K.Rool's Acid Punk", none)
    add_name("Susan Carriere, A. R. C. T.", "Beware The Forest's|Mushrooms", none)
    add_name("erik@vbe.com", "Fight Agianst Bowser", none)
    add_name("Dicaeopolis", "Surprise Attack!", none)
    add_name("Paper Luigi", "Windy and Co.", none)
    add_name("Mark Jansen", "Sloprano", none)
    add_name("matthewcollinson", "Level Music 1", none)
    add_name("anthony bouchereau", "Mabe Village", none)
    add_name("ZERMa", "Yoshi's Tale", none)
    add_name("Gigasoft", "Flower Garden", none)
    add_name("Joe Cortez", "Vs. Marx, Super Mario|Bros. 2 Overworld", none)
    add_name("Teck", "Forest Interlude", none)
    add_name("WaVeOf_DaRKnEsS", "Bubbly Clouds", none)
    add_name("Monster Iestyn", "Emerald Hill Zone, Stardust|Speedway B Mix", none)
    add_name("William Borges", "Casino Night Zone", none)
    add_name("Blue Warrior", "Green Hill Zone", none)
    add_name("isabellechiming", "Onett", none)
    add_name("Venatus", "The Days When My Mother|Was There", none)

    add_title("Video Team")
    add_name("Fray", "Trailer Editing, Footage|Capturing, Marth Cinematic", remix)
    add_name("Darkhorse", "Trailer Directing, Trailer|Editing, Graphics", remix)
    add_name("sope", "Graphics, Cinematic|Animation", remix)
    add_name("Dshaynie", "Cinematic Animation", remix)
    add_name("TheQuickSlash", "Cinematic Animation", remix)
    add_name("Retro64", "Trailer Directing, Trailer|Editing, Graphics", remix)

    // The strings and tables for the Remix credits will be in an external file...
    // This constant will help with that.
    constant REMIX_CREDITS_FILE_ORIGIN(origin())

    // @ Description
    // Will hold pointers to strings/tables
    // First halfword is the address to the next pointer, divided by 4
    // Second halfword is the address of the data, divided by 4
    dh 0x1, 0x0 // 0x00: pointer to title_strings
    dh 0x2, 0x0 // 0x04: pointer to name_strings
    dh 0x3, 0x0 // 0x08: pointer to details_strings
    dh 0x4, 0x0 // 0x0C: pointer to company_strings
    dh 0x5, 0x0 // 0x10: pointer to title_info_table
    dh 0x6, 0x0 // 0x14: pointer to name_info_table
    dh 0x7, 0x0 // 0x18: pointer to details_info_table
    dh 0x8, 0x0 // 0x1C: pointer to company_info_table
    dh 0x9, 0x0 // 0x20: pointer to company_table
    dh 0xA, 0x0 // 0x24: pointer to section_info_table
    dh 0xB, 0x0 // 0x28: pointer to character_info_table
    dh -1,  0x0 // 0x2C: pointer to character_displaylist_table

    // @ Description
    // Constants for offsets to the pointers
    scope offset {
	    constant title_strings(0x00)
	    constant name_strings(0x04)
	    constant details_strings(0x08)
	    constant company_strings(0x0C)
	    constant title_info_table(0x10)
	    constant name_info_table(0x14)
	    constant details_info_table(0x18)
	    constant company_info_table(0x1C)
	    constant company_table(0x20)
	    constant section_info_table(0x24)
	    constant character_info_table(0x28)
	    constant character_displaylist_table(0x2C)
	}

    // @ Description
    // Holds title strings
    title_strings:
    update_pointer(offset.title_strings)
    evaluate n(0)
    while ({n} < added_titles) {
        convert_string(title_{n}.string, string_type.SCROLLING)
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds name strings
    name_strings:
    update_pointer(offset.name_strings)
    evaluate n(0)
    while ({n} < added_names) {
        convert_string(name_{n}.string, string_type.SCROLLING)
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds details strings
    details_strings:
    update_pointer(offset.details_strings)
    evaluate n(0)
    while ({n} < added_names) {
        convert_string(name_{n}.details_string, string_type.DETAILS)
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds company strings
    company_strings:
    update_pointer(offset.company_strings)
    evaluate n(0)
    while ({n} < added_companies) {
        convert_string(company_{n}.string, string_type.DETAILS)
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds title info: [index in title_strings, length of string]
    title_info_table:
    update_pointer(offset.title_info_table)
    evaluate n(0)
    while ({n} < added_titles) {
        evaluate s({title_{n}.start})
        evaluate l({title_{n}.length})
        dw {s}, {l}
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds name info: [index in name_strings, length of string]
    name_info_table:
    update_pointer(offset.name_info_table)
    evaluate n(0)
    while ({n} < added_names) {
        evaluate s({name_{n}.start})
        evaluate l({name_{n}.length})
        dw {s}, {l}
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds details info: [index in details_strings, length of string]
    details_info_table:
    update_pointer(offset.details_info_table)
    evaluate n(0)
    while ({n} < added_names) {
        evaluate s({name_{n}.details_start})
        evaluate l({name_{n}.details_length})
        dw {s}, {l}
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds company info: [index in company_strings, length of string]
    company_info_table:
    update_pointer(offset.company_info_table)
    evaluate n(0)
    while ({n} < added_companies) {
        evaluate s({company_{n}.start})
        evaluate l({company_{n}.length})
        dw {s}, {l}
        evaluate n({n} + 1)
    }

    // @ Description
    // Maps company to a name in company_info_table
    company_table:
    update_pointer(offset.company_table)
    evaluate n(0)
    evaluate company.id.none(-1)
    while ({n} < added_names) {
        evaluate company_index({company.id.{name_{n}.company}})
        dw {company_index}
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds section info: [left word index or -1, only/right word index, total name count before end of section]
    section_info_table:
    update_pointer(offset.section_info_table)
    evaluate n(0)
    while ({n} < added_titles) {
        evaluate se({title_{n}.section_end})
        dw -0x1, {n}, {se}
        evaluate n({n} + 1)
    }

    // @ Description
    // Holds scrolling text character info for added characters
    // [width height 00 00] [offset to texture]
    character_info_table:
    update_pointer(offset.character_info_table)
    evaluate n(0)
    while ({n} < added_characters) {
        evaluate w({char_{n}.width})
        evaluate h({char_{n}.height})
        evaluate o({char_{n}.offset})
        db {w}, {h}; dh 0x0000
        dw {o}
        evaluate n({n} + 1)
    }

    // @ Description
    // Maps charactes to a displaylist, populated by a setup routine
    character_displaylist_table:
    update_pointer(offset.character_displaylist_table)
    fill added_characters * 4

    // export the data to file
    export "../build/credits.bin", REMIX_CREDITS_FILE_ORIGIN, origin() - REMIX_CREDITS_FILE_ORIGIN

    // reset origin now that we have externalized the data
    origin REMIX_CREDITS_FILE_ORIGIN

    // @ Description
    // Ensure our Remix credits file gets loaded
    scope load_files_: {
        // get size of files for memory allocation
        OS.patch_start(0x182128, 0x80134A28)
        li      a0, file_array                // modified original lines 1/2
        jal     0x800CDEEC                    // original line 2
        addiu   a1, r0, 0x0002                // modified original line 2 (updated to load 2 files)
        OS.patch_end()
        // load files
        OS.patch_start(0x182144, 0x80134A44)
        li      a0, file_array                // modified original lines 1/4
        li      a2, 0x8013AA10                // original lines 2/3 - address of loaded file address array
        addiu   a1, r0, 0x0002                // modified original line 5 (updated to load 2 files)
        OS.patch_end()

        file_array:
        dw 0xC3                               // vanilla credits
        dw File.REMIX_CREDITS                 // Remix credits
    }

    // @ Description
    // Pointer to loaded Remix credits file. This address is unused by original code.
    constant remix_credits_pointer(0x8013AA14)

    // @ Description
    // Update so the loop continues beyond the original 0x54 names until our last added name
    OS.patch_start(0x181F9C, 0x8013489C)
    slti    at, t6, total_names
    OS.patch_end()

    // @ Description
    // This allows us to use our extended section info table
    scope use_extended_section_info_table_: {
        OS.patch_start(0x182030, 0x80134930)
        jal     use_extended_section_info_table_
        lw      t1, 0x0000(s3)                // original line 1 - t1 = current name count
        OS.patch_end()

        slti    at, t1, 0x0054                // original line 2 - at = 0 if we should use our extended table
        bnez    at, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address and recalculate loop condition
        lli     at, 0x0054
        bne     at, t1, _end                  // if we didn't just get to the first name of our list, skip updating s2
        slti    at, t1, total_names           // at = 1 if we should continue looping

        li      t1, remix_credits_pointer     // t1 = pointer to Remix credits file
        lw      t1, 0x0000(t1)                // t1 = Remix credits file
        lw      t1, offset.section_info_table(t1) // t1 = our extended table
        addiu   t1, t1, -0x000C               // t1 = our extended table - 0xC (will get incremented by 0xC)
        subu    t2, s2, t1                    // t2 < 0 if s2 hasn't already been updated
        bltzl   t2, _end                      // if s2 hasn't already been updated, then update it
        or      s2, t1, r0

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This allows us to use our extended title info table
    scope use_extended_title_info_table_: {
        OS.patch_start(0x18117C, 0x80133A7C)
        j       use_extended_title_info_table_
        lui     t6, 0x8014
        _return:
        OS.patch_end()

        li      t7, 0x80136B10                // original lines 1-2 - t7 = original title info table

        lw      t6, 0xA8B8(t6)                // t6 = current name count
        slti    t6, t6, 0x0054                // t6 = 0 if we should use our extended table
        bnez    t6, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address
        li      t7, remix_credits_pointer     // t7 = pointer to Remix credits file
        lw      t7, 0x0000(t7)                // t7 = Remix credits file
        lw      t7, offset.title_info_table(t7) // t7 = our extended table

        _end:
        j       _return
        nop
    }

    // @ Description
    // This allows us to use our extended title strings table
    scope use_extended_title_strings_table_: {
        OS.patch_start(0x181200, 0x80133B00)
        jal     use_extended_title_strings_table_._1
        lui     t8, 0x8014
        OS.patch_end()
        OS.patch_start(0x1812D4, 0x80133BD4)
        lui     at, 0x8014
        jal     use_extended_title_strings_table_._2
        lw      at, 0xA8B8(at)                // at = current name count
        OS.patch_end()

        _1:
        li      t9, 0x8013685C                // original lines 1-2 - t9 = original title strings table

        lw      t8, 0xA8B8(t8)                // t8 = current name count
        slti    t8, t8, 0x0054                // t8 = 0 if we should use our extended table
        bnez    t8, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address
        li      t9, remix_credits_pointer     // t9 = pointer to Remix credits file
        lw      t9, 0x0000(t9)                // t9 = Remix credits file
        lw      t9, offset.title_strings(t9)  // t9 = our extended table

        _end:
        jr      ra
        nop

        _2:
        lui     v1, 0x8013                    // original line 1
        addu    v1, v1, t5                    // original line 2

        slti    at, at, 0x0054                // at = 0 if we should use our extended table
        bnezl   at, _end                      // if the original names are still rolling, skip
        lw      v1, 0x685C(v1)                // original line 3

        // otherwise, get from the new table address
        li      v1, remix_credits_pointer     // v1 = pointer to Remix credits file
        lw      v1, 0x0000(v1)                // v1 = Remix credits file
        lw      v1, offset.title_strings(v1)  // v1 = our extended table
        addu    v1, v1, t5                    // original line 2
        b       _end
        lw      v1, 0x0000(v1)                // v1 = character
    }

    // @ Description
    // This allows us to use our extended name info table
    scope use_extended_name_info_table_: {
        OS.patch_start(0x181718, 0x80134018)
        jal     use_extended_name_info_table_
        slti    t8, t7, 0x0054                // t8 = 0 if we should use our extended table
        OS.patch_end()
        OS.patch_start(0x181A14, 0x80134314)
        jal     use_extended_name_info_table_._length_check
        addu    v1, v1, t1                    // original line 1
        OS.patch_end()

        li      t9, 0x801364F4                // original lines 1-2 - t9 = original name info table

        bnez    t8, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address
        li      t9, remix_credits_pointer     // t9 = pointer to Remix credits file
        lw      t9, 0x0000(t9)                // t9 = Remix credits file
        lw      t9, offset.name_info_table(t9) // t9 = our extended table
        addiu   t7, t7, -0x0054               // t7 = index in our extended table

        _end:
        jr      ra
        nop

        _length_check:
        slti    at, t0, 0x0054                // at = 0 if we should use our extended table
        bnezl   at, _end                      // if the original names are still rolling, skip
        lw      v1, 0x64F8(v1)                // original line 2 - v1 = length

        // otherwise, use our extended table to get the length
        li      v1, remix_credits_pointer     // v1 = pointer to Remix credits file
        lw      v1, 0x0000(v1)                // v1 = Remix credits file
        lw      v1, offset.name_info_table(v1) // v1 = our extended table
        addiu   at, t0, -0x0054               // at = index in our extended table
        sll     at, at, 0x0003                // at = offset in our extended table
        addu    v1, v1, at                    // v1 = address of name info array
        b       _end
        lw      v1, 0x0004(v1)                // v1 = length
    }

    // @ Description
    // This allows us to use our extended name strings table
    scope use_extended_name_strings_table_: {
        OS.patch_start(0x181750, 0x80134050)
        jal     use_extended_name_strings_table_._1
        lui     t0, 0x8014
        OS.patch_end()
        OS.patch_start(0x18181C, 0x8013411C)
        lui     at, 0x8014
        jal     use_extended_name_strings_table_._2
        lw      at, 0xA8B8(at)                // at = current name count
        OS.patch_end()

        _1:
        li      t1, 0x80135260                // original lines 1-2 - t1 = original name strings table

        lw      t0, 0xA8B8(t0)                // t0 = current name count
        slti    t0, t0, 0x0054                // t0 = 0 if we should use our extended table
        bnez    t0, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address
        li      t1, remix_credits_pointer     // t1 = pointer to Remix credits file
        lw      t1, 0x0000(t1)                // t1 = Remix credits file
        lw      t1, offset.name_strings(t1)   // t1 = our extended table

        _end:
        jr      ra
        nop

        _2:
        lui     v1, 0x8013                    // original line 1
        addu    v1, v1, t7                    // original line 2

        slti    at, at, 0x0054                // at = 0 if we should use our extended table
        bnezl   at, _end                      // if the original names are still rolling, skip
        lw      v1, 0x5260(v1)                // original line 3

        // otherwise, get from the new table address
        li      v1, remix_credits_pointer     // v1 = pointer to Remix credits file
        lw      v1, 0x0000(v1)                // v1 = Remix credits file
        lw      v1, offset.name_strings(v1)   // v1 = our extended table
        addu    v1, v1, t7                    // original line 2
        b       _end
        lw      v1, 0x0000(v1)                // v1 = character
    }

    // @ Description
    // This allows us to use our extended details info table
    scope use_extended_details_info_table_: {
        OS.patch_start(0x1802D4, 0x80132BD4)
        lw      t6, 0x0004(v1)                // original line 3 - t6 = selected name index
        jal     use_extended_details_info_table_
        slti    at, t6, 0x0054                // at = 0 if we should use our extended table
        OS.patch_end()

        li      t8, 0x80139B68                // original lines 1-2 - t8 = original details info table

        bnez    at, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address
        li      t8, remix_credits_pointer     // t8 = pointer to Remix credits file
        lw      t8, 0x0000(t8)                // t8 = Remix credits file
        lw      t8, offset.details_info_table(t8) // t8 = our extended table
        addiu   t6, t6, -0x0054               // t6 = index in our extended table

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This allows us to use our extended details strings table
    scope use_extended_details_strings_table_: {
        OS.patch_start(0x18030C, 0x80132C0C)
        lw      s1, 0x0004(v1)                // s1 = selected name
        jal     use_extended_details_strings_table_
        lui     at, 0x4040                    // original line 2
        OS.patch_end()

        li      t1, 0x80136BA0                // original lines 1/3 - t1 = original details strings table

        slti    s1, s1, 0x0054                // s1 = 0 if we should use our extended table
        bnez    s1, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address
        li      t1, remix_credits_pointer     // t1 = pointer to Remix credits file
        lw      t1, 0x0000(t1)                // t1 = Remix credits file
        lw      t1, offset.details_strings(t1) // t1 = our extended table

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This allows us to use our extended company map table
    scope use_extended_company_table_: {
        OS.patch_start(0x180654, 0x80132F54)
        jal     use_extended_company_table_
        slti    s2, t6, 0x0054                // s2 = 0 if we should use our extended table
        OS.patch_end()

        addu    v1, v1, t7                    // original line 1

        bnezl   s2, _end                      // if the original names are still rolling, skip
        lw      v1, 0xA034(v1)                // original line 2

        // otherwise, update the table address
        li      v1, remix_credits_pointer     // v1 = pointer to Remix credits file
        lw      v1, 0x0000(v1)                // v1 = Remix credits file
        lw      v1, offset.company_table(v1)  // v1 = our extended table
        addiu   t6, t6, -0x0054               // t6 = index in our extended table
        sll     t7, t6, 0x0002                // t7 = offset in our extended table
        addu    v1, v1, t7                    // original line 1
        lw      v1, 0x0000(v1)                // v1 = company index

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This allows us to use our extended company info table
    scope use_extended_company_info_table_: {
        OS.patch_start(0x180648, 0x80132F48)
        jal     use_extended_company_info_table_
        slti    s2, t6, 0x0054                // s2 = 0 if we should use our extended table
        OS.patch_end()

        li      t9, 0x80139FD4                // original lines 1-2 - t8 = original company info table

        bnez    s2, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address
        li      t9, remix_credits_pointer     // t9 = pointer to Remix credits file
        lw      t9, 0x0000(t9)                // t9 = Remix credits file
        lw      t9, offset.company_info_table(t9) // t9 = our extended table

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This allows us to use our extended company strings table
    scope use_extended_company_strings_table_: {
        OS.patch_start(0x180694, 0x80132F94)
        jal     use_extended_company_strings_table_
        lw      t0, 0x0084(a1)                // t0 = selected name special struct
        OS.patch_end()

        li      t1, 0x80139E08                // original lines 1/3 - t1 = original company strings table

        lw      t0, 0x0004(t0)                // t0 = selected name id
        slti    t0, t0, 0x0054                // t0 = 0 if we should use our extended table
        bnez    t0, _end                      // if the original names are still rolling, skip
        nop                                   // otherwise, update the table address
        li      t1, remix_credits_pointer     // t1 = pointer to Remix credits file
        lw      t1, 0x0000(t1)                // t1 = Remix credits file
        lw      t1, offset.company_strings(t1) // t1 = our extended table

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This allows us to use our added characters
    scope use_added_characters_: {
        // displaylist setup
        OS.patch_start(0x1824D0, 0x80134DD0)
        jal     use_added_characters_._displaylist_setup
        or      a1, v1, r0                    // original line 1
        OS.patch_end()
        // render added characters
        OS.patch_start(0x181798, 0x80134098)
        jal     use_added_characters_._handle_added_character
        addiu   t4, t4, 0xA188                // original line 2
        addu    v1, t3, t4                    // original line 3
        or      a1, t5, r0                    // set a1 to t5 (set in _get_character_info)
        addu    a1, a1, t2                    // original line 6
        lw      a1, 0x0000(a1)                // modified original line 8 - get display list
        lbu     t5, 0x0000(v1)                // original line 4
        mtc1    t5, f6                        // original line 7
        OS.patch_end()

        _displaylist_setup: {
            slt     at, s3, t8                    // at = 1 if original characters remain
            bnez    at, _j_0x80134AC8             // modified original line 2 - if original characters remain, loop
            nop

            // if here, then we need to address added characters
            beq     s3, t8, _first_time           // if we just finished original characters, set up for added chars
            nop

            _check_added:
            li      t8, remix_credits_pointer     // t8 = pointer to Remix credits file
            lw      t8, 0x0000(t8)                // t8 = Remix credits file
            lw      t8, offset.character_displaylist_table(t8) // t8 = our extended table
            addiu   t8, t8, (added_characters * 4)
            bne     s3, t8, _j_0x80134AC8         // modified original line 2 - if added characters remain, loop
            nop

            _end:
            jr      ra
            nop

            _j_0x80134AC8:
            j       0x80134AC8
            nop

            _first_time:
            li      s3, remix_credits_pointer     // s3 = pointer to Remix credits file
            lw      s3, 0x0000(s3)                // s3 = Remix credits file
            lw      s0, offset.character_info_table(s3) // s0 = our extended table
            lw      s3, offset.character_displaylist_table(s3) // s3 = our extended table
            b       _check_added
            nop
        }

        _handle_added_character: {
            li      t5, 0x8013A7D8                // t5 = original displaylist table
            sltiu   t3, v0, 0x0050                // t3 = 1 if an original character
            bnez    t3, _return                   // if an original character, continue normally
            nop                                   // otherwise it's an added character
            li      t5, remix_credits_pointer     // t5 = pointer to Remix credits file
            lw      t5, 0x0000(t5)                // t5 = Remix credits file
            lw      t4, offset.character_info_table(t5) // t4 = our extended table
            addiu   t4, t4, -(0x50 * 8)           // set the table offset so v0 will work without modifying it
            lw      t5, offset.character_displaylist_table(t5) // t5 = our extended table
            addiu   t5, t5, -(0x50 * 4)           // set the table offset so v0 will work without modifying it
            sll     t2, v0, 0x0002                // t2 = offset in character_displaylist_table

            _return:
            jr      ra
            sll     t3, v0, 0x0003            // original line 1
        }
    }
}

} // __CREDITS__
