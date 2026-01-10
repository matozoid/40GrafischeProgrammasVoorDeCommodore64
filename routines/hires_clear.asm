ptr = $57          ; tmp pointer storage
; Clear hires bitmap (a000 to bf40)
hires_clear:        ldy #0
                    lda #$40
                    sta ptr
                    lda #$bf
                    sta ptr+1
Lc063:              lda #0
                    sta (ptr),y
                    lda ptr
                    beq Lc070
                    dec ptr
                    jmp Lc063
Lc070:              dec ptr+1
                    lda ptr+1
                    cmp #$9f
                    beq Lc07f
                    lda #$ff
                    sta ptr
                    jmp Lc063
Lc07f:              rts

; Set bitmap colour memory (screen RAM from 8400 to 87e7) to X
clear_screen_ram:              ldy #0
                    lda #$e7
                    sta ptr
                    lda #$87
                    sta ptr+1
Lc08a:              txa
                    sta (ptr),y
                    lda ptr
                    beq Lc096
                    dec ptr
                    jmp Lc08a
Lc096:              dec ptr+1
                    lda ptr+1
                    cmp #$83
                    beq Lc0a5
                    lda #$ff
                    sta ptr
                    jmp Lc08a
Lc0a5:              rts

; Clear colour memory (d800 to dbe7)
clear_colour_ram:              ldy #0
                    lda #$e7
                    sta ptr
                    lda #$db
                    sta ptr+1
Lc0b0:              lda #0
                    sta (ptr),y
                    lda ptr
                    beq Lc0bd
                    dec ptr
                    jmp Lc0b0
Lc0bd:              dec ptr+1
                    lda ptr+1
                    cmp #$d7
                    beq Lc0cc
                    lda #$ff
                    sta ptr
                    jmp Lc0b0
Lc0cc:              rts
