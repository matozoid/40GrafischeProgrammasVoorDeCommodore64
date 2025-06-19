100 rem programma 6 ingeschreven vierkanten
110 print chr$(147)
120 input "toets k in 1<k<20"; k
130 hires 0,1:h=.5
140 dim x(5),y(5),xx(5),yy(5)
150 for j=1 to 5
160 : read x(j),y(j)
170 next j
180 print chr$(147)
190 for n=1 to 40
200 : for j=1 to 4
210 :   line x(j),y(j),x(j+1),y(j+1),1
220 : next j
230 : for j=1 to 4
240 : xx(j)=x(j)+int((x(j+1)-x(j))/k+h)
250 : yy(j)=y(j)+int((y(j+1)-y(j))/k+h)
260 : next j
270 : for j=1 to 4
280 :   x(j)=xx(j):y(j)=yy(j)
290 : next j
300 : x(5)=x(1):y(5)=y(1)
310 next n
320 get a$:if a$="" then 320
330 end
340 : data 60,200,260,200,260,0,60,0
350 : data 60,200
