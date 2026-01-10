;
; From Commodore_Computing_International_Vol_02-06_1983_Oct.pdf
;
;******************************
;* THESE ROUTINES ALLOW THE   *
;*PRODUCTION OF HIRES GRAPHICS*
;*DISPLAYS ON THE 64. ALL OF  *
;*THE ROUTINES HAVE THE       *
;*FACILITY FOR MULTI-COLOUR OR*
;*STANDARD HI-RES EXCEPT FOR  *
;*THE FILL ROUTINE WHICH ONLY *
;*ALLOWS THE FILLING OF STAND-*
;*ARD HIRES AREAS.            *
;******************************
;* EACH ROUTINE IS CALLED WITH*
;*A SYS CALL FOLLOWED BY THE  *
;*PARAMETERS SEPARATED BY ','.*
;******************************
;*SYS(49152),MODE,COLOUR      *
;*   SELECT AND SET UP HI-RES *
;*   MODE. MODE=0 FOR STANDARD*
;*   AND 1 FOR MULTI-COLOUR.  *    
;*   COLOUR IS FOR THE BORDER *
;*   AND THE SCREEN.          *
;******************************
;*SYS(49182)                  *
;*   GO FROM NORMAL SCREEN TO *
;*   HIRES SCREEN.            *
;******************************
;*SYS(49241)                  *
;*   CLEARS THE HIRES SCREEN. *
;******************************
;*SYS(49845)                  *
;*   GO FROM HIRES SCREEN TO  *
;*   NORMAL SCREEN.           *
;******************************
;*SYS(49585),X,Y,COL,BR       *
;*   PLOTS A POINT AT X,Y IN  *
;*   COLOUR COL USING BRUSH BR*
;******************************
;*SYS(49874),X1,Y1,X2,Y2,CL,BR*
;*   PLOTS A LINE BETWEEN.    *
;*   X1,Y1 AND X2,Y2 WITH     *
;*   COLOUR COL AND BRUSH BR. *
;******************************
;*SYS(50713),X,Y,COL,BR1,BR2  *
;*   FILLS AN ENCLOSED AREA.  *
;*   POINT X,Y IS WITHIN THE  *
;*   AREA AND BR1 AND BR2 MUST*
;*   BOTH BE 1.               *
;******************************
;*USR(BRUSH),X,Y              *
;*   RETURNS A 1 IF THE POINT *
;*   IS SET USING THAT BRUSH  *
;*   OR A 0 IF IT IS NOT.     *
;******************************

*                   = $C000

                    .include "basic.asm"
                    .include "io.asm"

                    .include "hires_init.asm"
                    .include "hires_clear.asm"
                    .include "prepare_coords.asm"
                    .include "hires_plot.asm"
                    .include "hires_exit.asm"
                    .include "hires_line.asm"
                    .include "hires_isset.asm"
                    .include "hires_fill.asm"
