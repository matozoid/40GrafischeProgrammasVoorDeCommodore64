; This routines implements an unoptimized version of the Bresenham line drawing algorithm.
; TODO could probably just use "brush"
colour_tmp = $FE
; all variables are stored in the cassette buffer
x1 = $033C
y1 = $033e
x2 = $0340
y2 = $0342
dx = $0344
dy = $0346

abs_dx = $0348
abs_dy = $034a

primary_delta_abs = $034c
secondary_delta_abs = $034e

error = $0350
pixels_left_to_draw = $0352
error_acc = $0356
delta_min = $0354
; TODO probably redundant var
b__ = $0358
; inc is -1,0 or 1,0 or 0,-1 or 0,1, used to step one pixel of a straight line segment
y_inc = $035a
x_inc = $035c
; step is -1,-1 or 1,-1 or 1,1 or -1,1, used when the coordinate needs to move to the next straight line segment
step_x = $0360
step_y = $035e

hires_line:
                    ; parse x1,y1
                    jsr CHKCMA
                    jsr GETNUM
                    ; store y1
                    txa
                    sta y1
                    lda #0
                    sta y1+1
                    ; store x1
                    lda LINNUM
                    sta x1
                    lda LINNUM+1
                    sta x1+1
                    ; parse x2, y2
                    jsr CHKCMA
                    jsr GETNUM
                    ; store y2
                    txa
                    sta y2
                    lda #0
                    sta y2+1
                    ; store x2
                    lda LINNUM
                    sta x2
                    lda LINNUM+1
                    sta x2+1
                    ; parse colour, brush
                    jsr CHKCMA
                    jsr GETNUM
                    ; store brush
                    txa
                    sta brush
                    lda LINNUM
                    ; store colour
                    sta colour_tmp
                    ; dx = x2 - x1
                    lda x2
                    sec
                    sbc x1
                    sta dx
                    lda x2+1
                    sbc x1+1
                    sta dx+1
                    ; dy = y2 - y1
                    lda y2
                    sec
                    sbc y1
                    sta dy
                    lda y1+1
                    sbc y2+1
                    sta dy+1
                    ; determine step direction
                    ; default to step x,y = 1,1
                    lda #1
                    sta step_y
                    sta step_x
                    lda #0
                    sta step_y+1
                    sta step_x+1
                    ; dy<0 ?
                    lda dy+1
                    and #%10000000
                    beq Lc356
                    ; then step y = -1
                    lda #$ff
                    sta step_y
                    sta step_y+1
Lc356:              ; dx<0 ?
                    lda dx+1
                    and #%10000000
                    beq calc_abs_dx
                    ; then step x = -1
                    lda #$ff
                    sta step_x
                    sta step_x+1
calc_abs_dx:        ; abs_dx = abs(dx)
                    lda dx+1
                    and #%10000000
                    beq Lc38a
                    lda dx+1
                    eor #%11111111
                    sta abs_dx+1
                    clc
                    lda dx
                    eor #%11111111
                    adc #1
                    sta abs_dx
                    lda abs_dx+1
                    adc #0
                    sta abs_dx+1
                    jmp calc_abs_dy
Lc38a:              lda dx
                    sta abs_dx
                    lda dx+1
                    sta abs_dx+1
                    ; abs_dy = abs(dy)
calc_abs_dy:        lda dy+1
                    and #%10000000
                    beq Lc3bb
                    lda dy+1
                    eor #%11111111
                    sta abs_dy+1
                    clc
                    lda dy
                    eor #%11111111
                    adc #1
                    sta abs_dy
                    lda abs_dy+1
                    adc #0
                    sta abs_dy+1
                    jmp determine_primary_axis
Lc3bb:              lda dy
                    sta abs_dy
                    lda dy+1
                    sta abs_dy+1
                    ; determine primary axis to step along:
determine_primary_axis:
                    ; dx - dy < 0?
                    lda abs_dx
                    sec
                    sbc abs_dy
                    ; TODO no need to store in b__ ?
                    sta b__
                    lda abs_dx+1
                    sbc abs_dy+1
                    sta b__+1
                    and #%10000000
                    beq primary_axis_x
                    ; <0, primary axis is y
primary_axis_y:
                    ; inc per pixel = 0,-1
                    lda #$ff
                    sta y_inc
                    sta y_inc+1
                    lda #0
                    sta x_inc
                    sta x_inc+1
                    lda abs_dy
                    sta primary_delta_abs
                    lda abs_dy+1
                    sta primary_delta_abs+1
                    lda abs_dx
                    sta secondary_delta_abs
                    lda abs_dx+1
                    sta secondary_delta_abs+1
                    lda dy+1
                    and #%10000000
                    bne Lc453
                    ; inc per pixel = 0,1
                    lda #1
                    sta y_inc
                    lda #0
                    sta y_inc+1
                    jmp Lc453
primary_axis_x:     ; >=0, primary axis = x
                    ; inc per pixel = -1,0
                    lda #0
                    sta y_inc
                    sta y_inc+1
                    lda #$ff
                    sta x_inc
                    sta x_inc+1
                    lda abs_dx
                    sta primary_delta_abs
                    lda abs_dx+1
                    sta primary_delta_abs+1
                    lda abs_dy
                    sta secondary_delta_abs
                    lda abs_dy+1
                    sta secondary_delta_abs+1
                    lda dx+1
                    and #%10000000
                    bne Lc453
                    ; inc per pixel = 1,0
                    lda #1
                    sta x_inc
                    lda #0
                    sta x_inc+1
Lc453:              ; pixels_left_to_draw = primary_delta_abs
                    lda primary_delta_abs
                    sta pixels_left_to_draw
                    lda primary_delta_abs+1
                    sta pixels_left_to_draw+1
                    ; error = secondary_delta_abs
                    lda secondary_delta_abs
                    sta error
                    lda secondary_delta_abs+1
                    sta error+1
                    ; delta_min = primary_delta_abs - secondary_delta_abs
                    lda primary_delta_abs
                    sec
                    sbc secondary_delta_abs
                    sta delta_min
                    lda primary_delta_abs+1
                    sbc secondary_delta_abs+1
                    sta delta_min+1
                    ; error_acc = secondary_delta_abs - (primary_delta_abs/2)
                    lsr primary_delta_abs+1
                    ror primary_delta_abs
                    lda secondary_delta_abs
                    sec
                    sbc primary_delta_abs
                    sta error_acc
                    lda secondary_delta_abs+1
                    sbc primary_delta_abs+1
                    sta error_acc+1
draw_loop:              
                    lda x1
                    sta x
                    lda x1+1
                    sta x+1
                    lda y1
                    sta y
                    lda colour_tmp
                    sta colour
                    jsr hires_plot_internal
                    ; error < 0 ?
                    lda error_acc+1
                    and #%10000000
                    beq step_diagonal
step_straight:
                    lda error_acc
                    clc
                    adc error
                    sta error_acc
                    lda error_acc+1
                    adc error+1
                    sta error_acc+1
                    ; advance 1 pixel
                    ; x1 = x1 + x_inc
                    lda x1
                    clc
                    adc x_inc
                    sta x1
                    lda x1+1
                    adc x_inc+1
                    sta x1+1
                    ; y1 = y1 + y_inc
                    lda y1
                    clc
                    adc y_inc
                    sta y1
                    lda y1+1
                    adc y_inc+1
                    sta y1+1
                    jmp Lc529
step_diagonal:              
                    lda error_acc
                    sec
                    sbc delta_min
                    sta error_acc
                    lda error_acc+1
                    sbc delta_min+1
                    sta error_acc+1
                    ; step x
                    lda x1
                    clc
                    adc step_x
                    sta x1
                    lda x1+1
                    adc step_x+1
                    sta x1+1
                    ; step y
                    lda y1
                    clc
                    adc step_y
                    sta y1
                    lda y1+1
                    adc step_y+1
                    sta y1+1

Lc529:              ; pixels_left_to_draw = pixels_left_to_draw - 1
                    lda pixels_left_to_draw
                    sec
                    sbc #1
                    sta pixels_left_to_draw
                    lda pixels_left_to_draw+1
                    sbc #0
                    sta pixels_left_to_draw+1
                    lda pixels_left_to_draw+1
                    beq Lc546
                    cmp #$ff
                    beq line_drawn
                    jmp draw_loop
Lc546:              lda pixels_left_to_draw
                    beq line_drawn
                    jmp draw_loop
line_drawn:
                    rts
