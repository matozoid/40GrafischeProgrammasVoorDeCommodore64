; An unoptimized fill routine.
; It seems unfinished because:
;   - its multicolour support is broken
;   - it ignores its brush parameters
;
; Overall approach:
;   - move x,y right until a set pixel is found, or right side of the screen hit
;   - repeat:
;      - if current pixel is set:
;           - if stack not empty: pop a coordinate and go to the first step
;           - else fill routine is done
;      - if pixel at y+1 is set:
;           - void below has not been seen
;           - else if void below has not been seen:
;               - push it on the stack
;               - void below has been seen
;      - same for pixel at y-1
;      - set the current pixel
;      - x=x-1
postponed_coordinate_stack_ptr = $02
postponed_coordinate_stack = $CF00

fill_x = $033c
fill_y = $033e

horizontal_step = $036a

brush_1 = $0373
brush_2 = $0374

void_above_pushed = $0375
void_below_pushed = $0376

hires_fill:         ; parse parameters
                    jsr CHKCMA
                    ; store y
                    jsr GETNUM
                    stx fill_y
                    ; store colour
                    ldx #0
                    jsr COMBYT
                    stx line_colour
                    ; store brush 1
                    ldx #0
                    jsr COMBYT
                    stx brush_1
                    ; store brush 2
                    ldx #0
                    jsr COMBYT
                    sta brush_2
                    ; set hi byte of fill_y to 0
                    lda #0
                    sta fill_y+1
                    ; store x
                    lda LINNUM
                    sta fill_x
                    lda LINNUM+1
                    sta fill_x+1
                    ; check brush validity
                    lda #3
                    cmp brush_1
                    bmi _invalid_brush
                    cmp brush_2
                    bmi _invalid_brush
                    jmp Lc65d

_invalid_brush:     jsr hires_exit
                    jmp FCERR

Lc65d:              jsr prepare_for_prepare_coords
                    jsr prepare_coords
                    ; clear stack
                    lda #0
                    sta postponed_coordinate_stack_ptr

                    lda MODE
                    bne Lc679
                    lda #1
                    sta brush_1
                    sta brush_2
                    sta horizontal_step
                    jmp start_new_line

Lc679:              lda #2                      ; multi colour mode: double width pixels.
                    sta horizontal_step
start_new_line:
                    lda #0
                    sta void_below_pushed
                    sta void_above_pushed
                    jsr scan_right_until_pixel_hit
check_current_coord:; pixel at fill_x,y is brush_1 ?
                    jsr prepare_for_prepare_coords
                    lda brush_1
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq _not_brush_1
                    jmp pop_coordinate_and_continue
_not_brush_1:       ; pixel at fill_x,y is brush_2 ? 
                    jsr prepare_for_prepare_coords
                    lda brush_2
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq _check_down
                    jmp pop_coordinate_and_continue
_check_down:        ; 
                    lda fill_y
                    cmp #199
                    beq Lc6e0
                    jsr prepare_for_prepare_coords
                    lda brush_1
                    sta brush
                    inc y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc6e0
                    jsr prepare_for_prepare_coords
                    lda brush_2
                    sta brush
                    inc y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc6e0
                    jsr push_down_coord
                    jmp check_up
Lc6e0:              lda #0
                    sta void_below_pushed
check_up:           lda #0
                    cmp fill_y
                    beq Lc716
                    jsr prepare_for_prepare_coords
                    lda brush_1
                    sta brush
                    dec y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc716
                    jsr prepare_for_prepare_coords
                    lda brush_2
                    sta brush
                    dec y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc716
                    jsr push_up_coord
                    jmp set_current_pixel
Lc716:              lda #0
                    sta void_above_pushed
set_current_pixel:  jsr prepare_for_prepare_coords
                    lda brush_1
                    sta brush
                    lda line_colour
                    sta colour
                    jsr hires_plot_internal
                    ; move left 1 step
                    sec
                    lda fill_x
                    sbc horizontal_step
                    sta fill_x
                    lda fill_x+1
                    sbc #0
                    sta fill_x+1
                    cmp #2
                    bcc Lc743
                    jmp pop_coordinate_and_continue
Lc743:              jmp check_current_coord

prepare_for_prepare_coords:
                    lda fill_x
                    sta x
                    lda fill_x+1
                    sta x+1
                    lda fill_y
                    sta y
                    lda #0
                    sta pixel_screen_ram_addr
                    rts

pop_coordinate_and_continue:     
                    ldx postponed_coordinate_stack_ptr
                    beq _stack_empty
                    dex
                    lda postponed_coordinate_stack,x
                    sta fill_y
                    dex
                    lda postponed_coordinate_stack,x
                    sta fill_x+1
                    dex
                    lda postponed_coordinate_stack,x
                    sta fill_x
                    stx postponed_coordinate_stack_ptr
                    jmp start_new_line
_stack_empty:       rts

push_down_coord:    lda void_below_pushed
                    beq void_below_not_pushed
                    rts
void_below_not_pushed:              
                    lda #1
                    sta void_below_pushed
                    jsr prepare_for_prepare_coords
                    inc y
                    jmp push_coord

push_up_coord:      lda void_above_pushed
                    beq void_above_not_pushed
                    rts
void_above_not_pushed:
                    lda #1
                    sta void_above_pushed
                    jsr prepare_for_prepare_coords
                    dec y
push_coord:         ldx postponed_coordinate_stack_ptr
                    cpx #$bb
                    bcc Lc7a8
                    jsr hires_exit
                    jmp OVERR
Lc7a8:              lda x
                    sta postponed_coordinate_stack,x
                    inx
                    lda x+1
                    sta postponed_coordinate_stack,x
                    inx
                    lda y
                    sta postponed_coordinate_stack,x
                    inx
                    stx postponed_coordinate_stack_ptr
                    rts

scan_right_until_pixel_hit:
tmp_x = $0340       
                    ; tmp_x = fill_x + horizontal_step
                    clc
                    lda fill_x
                    adc horizontal_step
                    sta tmp_x
                    sta x
                    lda fill_x+1
                    adc #0
                    sta tmp_x+1
                    sta x+1
                    lda fill_y
                    sta y
                    ;
                    lda #0
                    sta pixel_screen_ram_addr
                    ; x > 320 then rts
                    lda tmp_x+1
                    beq Lc7ee
                    cmp #1
                    beq Lc7e6
                    rts
Lc7e6:              lda tmp_x
                    cmp #$40
                    bcc Lc7ee
                    rts
Lc7ee:              lda brush_2
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq Lc7fc
                    rts
Lc7fc:              lda tmp_x
                    sta fill_x
                    lda tmp_x+1
                    sta fill_x+1
                    jmp scan_right_until_pixel_hit
