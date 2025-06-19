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
 3000 if abs(x2-x1)>abs(y2-y1) then gosub 4000:return
 3010 gosub 5000
 3020 return
 4000 for px=x1 to x2 step sgn(x2-x1)
 4010 : py=(y2-y1)/(x2-x1)*(px-x1) + y1
 4020 : gosub 6000
 4030 next px
 4040 return
 5000 for py=y1 to y2 step sgn(y2-y1)
 5010 : px=(x2-x1)/(y2-y1)*(py-y1) + x1
 5020 : gosub 6000
 5030 next py
 5040 return
 6000 vy=320*int(py/8)+(pyand7)
 6010 vx=8*int(px/8)
 6020 va=8192 + vx+vy
 6030 ma=2^(7-(pxand7))
 6035 poke va,peek(va) or ma
 6040 return

