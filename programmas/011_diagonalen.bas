100 rem programma 5 diagonalen in een n-hoek
110 print chr$(147)
120 input "halve grote as a<=160"; a
130 input "halve kleine as b<=100"; b
140 input "hoeveel hoekpunten n<25"; n
150 print chr$(147)
160 hires 0,1
170 dim x(n),y(n)
180 u=160:v=100:h=0.5:w=(360/n)*~/180
190 for j=0 to n-1
200 : w1=j*w
210 : x(j)=int(u+a*cos(w1)+h)
220 : y(j)=int(v-b*sin(w1)+h)
230 next j
240 for i=0 to n-2
250 : for j=i+1 to n-1
260 :   line x(i),y(i),x(j),y(j),1
270 : next j
280 next i
290 get a$:if a$="" then 290
300 end
