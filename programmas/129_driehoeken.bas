100 rem programma 3 driehoeken in perspectief
110 print chr$(147)
120 sys49152,0,1
130 dimx(3),y(3),sx(3),sy(3)
140 for j=1 to 3
150 : read sx(j),sy(j)
160 next j
170 x(0)=0 : y(0)=72
180 for k=0 to 10 step 0.5
190 : for j=1 to 3
200 :   x(j)=x(0)+k*sx(j)
210 :   y(j)=y(0)+k*sy(j)
220 : next j
230 : sys49874,x(1),y(1),x(2),y(2),0,1
240 : sys49874,x(2),y(2),x(3),y(3),0,1
250 : sys49874,x(3),y(3),x(1),y(1),0,1
260 next k
270 get a$ : if a$="" then 270
275 sys49845
280 end
290 : data 6,12,20,9,12,-6
