100 rem programma 4 ingeschreven zeshoeken
110 print chr$(147)
120 hires 0,1
130 dimx(6),y(6),mx(6),my(6)
140 u=160:v=100:r=100:h=0.5:w=60*~/180
150 for j=0 to 6
160 : w1=j*w
170 : x(j)=int(u+r*cos(w1)+h)
180 : y(j)=int(v-r*sin(w1)+h)
190 next j
200 for n=1 to 20
210 : for j=0 to 5
220 :   line x(j),y(j),x(j+1),y(j+1),1
230 : next j
240 : for k=0 to 5
250 :   mx(k)=int((x(k)+x(k+1))/2+h)
260 :   my(k)=int((y(k)+y(k+1))/2+h)
270 : next k
280 : mx(6)=mx(0):my(6)=my(0)
290 : for j=0 to 6
300 :   x(j)=mx(j):y(j)=my(j)
310 : next j
320 next n
330 get a$:if a$="" then 330
340 end
