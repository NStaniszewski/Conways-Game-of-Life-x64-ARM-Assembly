.text
.global get_bit

// x0 - Array of integers
// w1 - Width of the array in bits
// w2 - Desired bit
get_bit:
  ary_ints .req x0
  width .req w1
  desired .req w2
  
  cmp w2,#0
  blt fail_num_get

  cmp w2,w1
  bge fail_num_get

  lsr w5,desired,#5
  and w6,desired,#0x1f
 
array_travel_get:
  cmp w5,#0
  beq loop_get

  sub w5,w5,#1
  add ary_ints,ary_ints,#4
  b array_travel_get

fail_num_get:
  mov w0,#0
  ret

loop_get:
  ldr w4,[ary_ints]
  mov w5,#31
  sub w6,w5,w6

  mov w3,#1
  lsr w4,w4,w6
  and w0,w4,#1
  b done_get

done_get:
 
  ret
  .unreq ary_ints
  .unreq width
  .unreq desired
