.text
.global set_bit


//
// Get a bit from an array of words.
// x0 - Array of integers
// w1 - Width of the array in bits
// w2 - Desired bit
// w3 - 1 if bit is to be set
//
set_bit:
  ary_ints .req x0
  width .req x1
  desired .req x2
  setto .req x3

  cmp x2,#0
  blt fail_num_set

  cmp x2,x1
  bge fail_num_set

  lsr x5,desired,#5
  and x6,desired,#0x1f

array_travel_set:
  cmp x5,#0
  beq loop_set

  sub x5,x5,#1
  add x1,x1,#4
  add ary_ints,ary_ints,#4
  b array_travel_set

fail_num_set:
  mov w0,#0
  ret

loop_set:
  ldr x4,[ary_ints]

  mov x5,#31
  sub x6,x5,x6

  cmp setto,#0
  beq zero_set
  b one_set

zero_set:
  mov x7,#1

  lsl x7,x7,x6
  bic x4,x4,x7

  str x4,[x0]
  b done_set
one_set:
  mov x7,#1

  lsl x7,x7,x6
  orr x4,x4,x7

  str x4,[x0]
  b done_set
done_set:
  ret
  .unreq ary_ints
  .unreq width
  .unreq desired
  .unreq setto
