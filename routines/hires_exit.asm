hires_exit:
                    ; reset screen pointer
                    lda #>$0400
                    sta $0288
                    ; reset port A on CIA#2
                    lda CIA2PRDDRA
                    and #%11111100
                    sta CIA2PRDDRA
                    ; disable bitmap mode
                    lda #%00011011
                    sta VMCTRL1
                    ; disable multi-colour
                    lda #%11001000
                    sta VMCTRL2
                    ; restore VIC to default setup
                    lda #%00010101
                    sta VMCSB
                    rts
