100 rem programma 1 diagonaalweb
110 print chr$(147)
120 sys49152,0,1
130 y1=0 : y2=200
200 for x1=0 to 320 step 40
210 : for x2=0 to 320 step 40
220 :   sys49874,x1,y1,x2,y2,0,1
230 : next x2
240 next x1
300 get a$ : if a$="" then 300
310 end

