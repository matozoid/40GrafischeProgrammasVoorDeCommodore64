100 rem programma 2 moiree-effekt
110 print chr$(147)
120 hires 0,1
130 for j=0 to 200 step 8
140 : line 60,0,j+60,200,1
150 : line 60,0,260,(200-j),1
160 next j
170 for j=0 to 200 step 8
180 : line 260,200,60,200-j,1
190 : line 260,200,j+60,0,1
200 next j
210 get a$:if a$="" then 210
220 end
