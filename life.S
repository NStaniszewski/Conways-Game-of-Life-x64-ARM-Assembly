.data
//.balign 4 
//cells: .word 0
//cells_cpy: .word 0
//width: .word 0
//height: .word 0

.text
.global life

//
// life iteration calculator
// x0 - int *cells
// w1 - int width in words
// w2 - int height in rows
//
life:
  stp x29,x30,[sp,#-16]!
  stp x19,x20,[sp,#-16]!
  stp x21,x22,[sp,#-16]!
  stp x23,x24,[sp,#-16]!
  stp x25,x26,[sp,#-16]!  
  
  cells .req x19
  mov cells,x0

  width .req w22
  mov width,w1

  mul w1,w2,w1 //size=width*height

  size .req w21
  mov size,w1 //size saved to w21
  
  mov w2,#32 
  mul w2,w1,w2
  bit_size .req w20 //size*32 saved to w20, total bits size
  mov bit_size,w2

  add w0,size,#1 //size+1, move to w0 for calloc
  mov w1,#4 //size of integer for calloc
  bl calloc
    
  cell_copy .req x25
  mov cell_copy,x0
   
  mov x0,cell_copy
  mov w1,size
  mov w2,bit_size
  mov w3,width 
  bl life_init //initialize the copy array
  
  mov x0,cells
  mov w1,size
  mov w2,bit_size
  mov w3,width
  mov x4,cell_copy
  bl life_game //actually do the life thing here
  
  b life_complete

life_complete:
  mov w7,#0
  b merge_cpy_real

merge_cpy_real:
  cmp w7,size
  beq life_shutdown

  lsl w1,w7,#2 //*4 for array pos
  
  ldr w6,[cell_copy,w1,uxtw] 
  str w6,[cells,w1,uxtw]

  add w7,w7,#1
  b merge_cpy_real

life_shutdown:
  mov x0,cell_copy
  bl free
  ldp x25,x26,[sp],#16
  ldp x23,x24,[sp],#16
  ldp x21,x22,[sp],#16
  ldp x19,x20,[sp],#16
  ldp x29,x30,[sp],#16
  ret
  .unreq width
  .unreq size
  .unreq bit_size
  .unreq cells
  .unreq cell_copy

//x0=cells,x1=number array elements, x2=bit size of array,x3=width*32
life_game:
  stp x29,x30,[sp,#-16]!
  stp x19,x20,[sp,#-16]!
  stp x21,x22,[sp,#-16]!
  stp x23,x24,[sp,#-16]!
  stp x25,x26,[sp,#-16]!

  cells .req x19
  bit_size .req w20
  size .req w21
  width .req w22
  i .req w24  //i will be our counter for the population in the 3x3 grid around
  // and including i
  bit_mover .req w23 //this is how well move through the array per bit,starting
  //from 0 bit position
  cell_copy .req x25 
  cell_pos .req x26
  mov w7,#32

  mov cells,x0
  mov size,w1
  mov bit_size,w2
  mul width,w3,w7
  mov i,#0 
  mov bit_mover,#0
  mov cell_copy,x4
  mov cell_pos,#0
  b life_game_loop

life_game_loop:
  cmp bit_mover,bit_size
  bgt life_game_end
  //get population of the 3x3 grid
  //set i based on population
  mov i,#0 //reset population count to 0 zero we check
  //get_bit params: x0=int array(cells),x1=width in bits,x2=desired
  
  //i+1
  mov x0,cells
  mov w1,bit_size
  add w2,bit_mover,#1
  bl get_bit
  add i,i,w0

  //i-1
  mov x0,cells
  mov w1,bit_size
  sub w2,bit_mover,#1
  bl get_bit
  add i,i,w0

  //i-width*32
  mov x0,cells
  mov w1,bit_size
  sub w2,bit_mover,width
  bl get_bit
  add i,i,w0

  //i-width*32+1
  mov x0,cells
  mov w1,bit_size
  sub w2,bit_mover,width
  sub w2,w2,#1
  bl get_bit
  add i,i,w0

  //i-width*32-1
  mov x0,cells
  mov w1,bit_size
  sub w2,bit_mover,width
  add w2,w2,#1
  bl get_bit
  add i,i,w0

  //i+width*32
  mov x0,cells
  mov w1,bit_size
  add w2,bit_mover,width
  bl get_bit
  add i,i,w0

  //i+width*32+1
  mov x0,cells
  mov w1,bit_size
  add w2,bit_mover,width
  add w2,w2,#1
  bl get_bit
  add i,i,w0

  //i+width*32-1
  mov x0,cells
  mov w1,bit_size
  add w2,bit_mover,width
  sub w2,w2,#1
  bl get_bit
  add i,i,w0
  
  //do the population checks for next move
  cmp i,#2
  blt die //kill if <2

  cmp i,#2
  beq no_change //do nothing if =2

  cmp i,#3
  beq procreate //procreate if =3

  cmp i,#3
  bgt die //kill if >3

no_change:
  mov x0,cells
  mov w1,bit_size
  mov w2,bit_mover
  bl get_bit
  
  mov w3,w0
  b bit_setto
die:
  mov w3,#0
  b bit_setto

procreate:
  mov w3,#1
  b bit_setto

bit_setto:
  //set i based on population
  //set_bit params:
  //x0=int array(cells),x1=bit width,x2=desired,x3=setto
  //use the modifier copy here
  mov x0,cell_copy
  mov w1,bit_size
  mov w2,bit_mover
 
  bl set_bit
  //we put the changed version into copy to merge later so it works right  
  b setto_end

setto_end:
  add bit_mover,bit_mover,#1
  b life_game_loop

life_game_end:
  ldp x25,x26,[sp],#16
  ldp x23,x24,[sp],#16
  ldp x21,x22,[sp],#16
  ldp x19,x20,[sp],#16
  ldp x29,x30,[sp],#16
  ret
  .unreq cells
  .unreq bit_size
  .unreq bit_mover
  .unreq width
  .unreq i
  .unreq cell_copy
  .unreq cell_pos


//x0 = cells,w1=number items in array,w2=bit size
life_init:
  stp x29,x30,[sp,#-16]!
  stp x19,x20,[sp,#-16]!
  stp x21,x22,[sp,#-16]!
  stp x23,x24,[sp,#-16]!
  stp x25,x26,[sp,#-16]!
  cell_copy .req x25
  bit_size .req w20
  size .req w21
  i .req w23

  mov cell_copy,x0
  mov size,w1
  mov bit_size,w2
  mov i,#0

init_loop:
  cmp i,size
  bgt init_loop_end
  
  mov w0,#1
  lsl w1,i,#2 //i*4 <-- moving through array takes 4 per 1 slot
  str w0,[cell_copy,w1,uxtw] //initialize all the integers in array as 1

  add i,i,#1
  b init_loop

init_loop_end:
  ldp x25,x26,[sp],#16
  ldp x23,x24,[sp],#16
  ldp x21,x22,[sp],#16
  ldp x19,x20,[sp],#16
  ldp x29,x30,[sp],#16
  ret
  .unreq cell_copy
  .unreq size
  .unreq i
  .unreq bit_size 
