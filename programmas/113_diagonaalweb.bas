  100 rem diagonaalweb
  110 print chr$(147)
  120 gosub 2000:rem in plaats van hires
  130 y1=0 : y2=200
  200 for x1=0 to 320 step 40
  210 : for x2=0 to 320 step 40
  220 :   gosub 3000:rem i.p.v. line
  230 : next x2
  240 next x1
  300 get a$ : if a$="" then 300
  310 end
 2000 poke 53272,peek(53272)or8
 2010 for va=8192 to 16191
 2020 : poke va,0
 2030 next va
 2040 for va=1024 to 2023
 2050 : poke va,1
 2060 next va
 2070 poke 53265,peek(53265)or32
 2080 return
 3000 dx=x2-x1:dy=y2-y1:sx=sgn(dx):sy=sgn(dy)
 3010 if abs(dx)<=abs(dy) then goto 3080
 3020 for px=x1 to x2 step sx:py=dy/dx*(px-x1)+y1
 3031 va=8192+8*int(px/8)+320*int(py/8)+(pyand7)
 3032 ma=2^(7-(pxand7)):poke va,peek(va)orma
 3050 next px:return
 3080 for py=y1 to y2 step sy:px=dx/dy*(py-y1)+x1
 3101 va=8192+8*int(px/8)+320*int(py/8)+(pyand7)
 3102 ma=2^(7-(pxand7)):poke va,peek(va)orma
 3110 next py:return

