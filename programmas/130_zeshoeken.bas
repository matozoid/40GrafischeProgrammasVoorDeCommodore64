100 rem programma 4 ingeschreven zeshoeken
110 print chr$(147)
115 rem machinetaalroutine voor hoge-resolutiestand
120 sys49152,0,1
130 dim x(6),y(6),mx(6),my(6),xo(6),yo(6)
140 u=160:v=100:r=100:h=0.5:w=60*~/180
150 for j=0 to 6
160 : w1=j*w
170 : x(j)=int(u+r*cos(w1)+h)
180 : y(j)=int(v-r*sin(w1)+h)
190 next j
200 for n=1 to 20
210 : for j=0 to 5
215 :   rem machinetaalroutine voor lijn tussen twee punten
220 :   sys49874,x(j),y(j),x(j+1),y(j+1),0,1
230 : next j
240 : if n=1 then 310
245 : for k = 1 to 5 step 2
250 :   x=int((x(k)+x(k+1)+xo(k+1))/3)
260 :   y=int((y(k)+y(k+1)+yo(k+1))/3)
265 :   rem machinetaalroutine voor inkleuren
270 :   sys50713,x,y,0,1,1
271 : next k
310 : for k=0 to 5
320 :   mx(k)=int((x(k)+x(k+1))/2+h)
330 :   my(k)=int((y(k)+y(k+1))/2+h)
340 : next k
350 : mx(6)=mx(0) : my(6)=my(0)
360 : for j=0 to 6
370 :   xo(j)=x(j):yo(j)=y(j)
380 :   x(j)=mx(j) : y(j)=my(j)
390 : next j
400 next n
410 get a$ : if a$ = "" then 410
414 rem machinetaalroutine voor terugkeer naar tekstscherm
415 sys49845
420 end

