frame_counter_:
li      t4, 0x8027E944
lw      t4, 0x0000(t4)
sll     t9, v1, 0x3
j       _frame_counter_return
nop