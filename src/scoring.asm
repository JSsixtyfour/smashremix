// @ Description
// Correct scoring (time/stock mode update) [bit]

		
pick_scoring_:

		constant vstimer_(0x800A4D1C)
		constant calculate_time_score_(0x801373F4)
		constant calculate_stock_score_(0x801373CC)

        lli     t0, 0x0001              // t1 = time
        beq     t6, t0, _time           // if mode == time, branch to time
        nop
        li      t0, vstimer_     // t0 = address of timer
        lw      t0, 0x0000(t0)          // t0 = timer
        beqz    t0, _time               // if timer at 0, use time scoring hook
        nop

        _scoringstock:
        j       calculate_stock_score_
        nop

        _scoringtime:
        j       calculate_time_score_
        nop


