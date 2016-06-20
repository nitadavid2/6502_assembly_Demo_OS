  JSR init
  JSR loop
  JSR end
 
init:
  CLD
  lda #$00 ; user-type-keys - on or off
  sta $5900
  lda #$2  ; bitmap x-start position
  ldy #$00 ; bitmap x-offset position
  sta $5901
  sty $5902
  LDX #$04 ; default color
  stx $5903
  ;5904 and 5905 used for lookup address
  JSR OpenMessage
  RTS
 
loop:
  JSR Inputs
  jmp loop
 
Inputs:
  JSR Keys
  RTS
 
Keys:
  lda $ff
 
  RTS
 
OpenMessage:
  JSR saveSP ; save stack pointer
;save letters at specified address
  LDA #$90
  PHA
  LDA #$00
  PHA

  LDA #$00 ; enter/carriage_return
  STA $900c
  LDA #$30 ; 0
  sta $900b
  LDA #$2e ; .
  STA $900a
  LDA #$30 ; 0
  STA $9009
  LDA #$2e ; .
  STA $9008
  LDA #$30 ; 0
  sta $9007
  LDA #$0d ;  
  sta $9006
  LDA #$6c ; l
  sta $9005
  LDA #$6c ; l
  sta $9004
  LDA #$65 ; e
  sta $9003
  LDA #$68 ; h
  sta $9002
  LDA #$53 ; S
  sta $9001
  LDA #$44 ; D
  STA $9000
  LDA #$d ; Length = 12
  STA $12
  JSR WriteString
  RTS
 
end:
  BRK
 
;-----------------------------
;|| ANSI AMERICAN 104-KEY   ||
;-----------------------------
;a - z   ->  $61 - $7a
;A - Z   ->  $41 - $5a
;backspace-> $08
;enter   ->  $0d
;SpaceBar->  $20
;0 - 10  ->  $30 - $39
; !      ->  $21
; @      ->  $40
; # $ %  ->  $23 $24 $25
; ^      ->  $5e
; &      ->  $26
; *      ->  $2a
; ( )    ->  $28 $29
; - =    ->  $2d $3d
; _ +    ->  $5f $2b
; , <    ->  $2c $3c
; . >    ->  $2e $3e
; / ?    ->  $2f $3f
; ; :    ->  $3b $3a
; ' "    ->  $27 $22
; [ {    ->  $5b $7b
; ] }    ->  $5d $7d
; \ |    ->  $5c $7c
; ` ~    ->  $60 $7e
;---------------------------
 
;---------------------------
;|| MEMORY MAP OUTLINE    ||
;---------------------------
; $00  -> $ff -> various short term, volatile storage
;               System gets full access to overwrite
; $100 -> $1ff -> Stack (high to low)
; $200 -> $5ff -> Screen BitMap
; $600 -> $56ff -> Prog Memory (reserved)
; $5700 -> $58ff -> function/error check storage
; $5900 -> $59ff -> System only (reserved)
; $5a00 -> $79ff -> General Heap
; $7a00 -> $7aff -> Program Data
; $7b00 -> $7fff -> Reserved for Functions
; $8000 -> $cfff -> Unmanaged Heap
; $d000 -> $ffff -> lookup table (reserved)
; |--| |--| |--| |--| |--| |--|  |--| |--|
; \                           /  \       /
;        6 byte id                address
;---------------------------
 
 
saveSP:
;for saving and checking stack pointer
;use only in top-most programs to check
;function call safe
;will overwrite itself if you call it again
;inside function
  TSX
  STX $5701
  RTS
 
ClearFEStorage:
;clears the function/error check storage by
;pointing it back to $1001
  LDA #$5
  STA $5700
  RTS
 
;--------------------------------
;|| Write characters to screen ||
;--------------------------------
;when writing individual characters, it is recommended
;you store #$1 in both the y-register and at $12
 
WriteString:
  LDY $12
  PLA
  STA $03 ;store return address temporarily
  PLA
  STA $02
  PLA     ;get lsb of addr
  STA $13
  PLA     ;get msb of addr
  STA $14
  LDA $02
  PHA
  LDA $03
  PHA

writecont:
  LDX #$0
  LDA ($13,x) ;access address pushed (value)
  INC $13  ;inc lsb

  Jmp WriteChar
 
WriteChar:
  sta $35 ; save pushed a-value
  ldx $5903 ;get color

  ldy $5902 ;go ahead and put offset in y
  lda $5902 ;get offset
  cmp #$1a
  BCC no_eval
  cmp #$20
  BCS more_eval
  jmp carriage_return ;indent if about to overflow
more_eval:
  cmp #$9b
  BCC no_eval
  jmp carriage_return

no_eval:
  adc #$5   ;add 5 to offset
  sta $5902
  lda $35 ; restore pushed a-value
  cmp #$61
  BNE not_ca
  jmp writecapA
not_ca:
  cmp #$62
  BNE not_cb
  jmp writecapB
not_cb:
  cmp #$63
  BNE not_cc
  jmp writecapC
not_cc:
  cmp #$64
  BNE not_cd
  jmp writecapD
not_cd:
  cmp #$65
  BNE not_ce
  jmp writecapE
not_ce:
  cmp #$66
  BNE not_cf
  jmp writecapF
not_cf:
  cmp #$67
  BNE not_cg
  jmp writecapG
not_cg:
  cmp #$68
  BNE not_ch
  jmp writecapH
not_ch:
  cmp #$69
  BNE not_ci
  jmp writecapI
not_ci:
  cmp #$6a
  BNE not_cj
  jmp writecapJ
not_cj:
  cmp #$6b
  BNE not_ck
  jmp writecapK
not_ck:
  cmp #$6c
  BNE not_cl
  jmp writecapL
not_cl:
  cmp #$6d
  BNE not_cm
  jmp writecapM
not_cm:
  cmp #$6e
  BNE not_cn
  jmp writecapN
not_cn:
  cmp #$6f
  BNE not_co
  jmp writecapO
not_co:
  cmp #$70
  BNE not_cp
  jmp writecapP
not_cp:
  cmp #$71
  BNE not_cq
  jmp writecapQ
not_cq:
  cmp #$72
  BNE not_cr
  jmp writecapR
not_cr:
  cmp #$73
  BNE not_cs
  jmp writecapS
not_cs:
  cmp #$74
  BNE not_ct
  jmp writecapT
not_ct:
  cmp #$75
  BNE not_cu
  jmp writecapU
not_cu:
  cmp #$76
  BNE not_cv
  jmp writecapV
not_cv:
  cmp #$77
  BNE not_cw
  jmp writecapW
not_cw:
  cmp #$78
  BNE not_cx
  jmp writecapX
not_cx:
  cmp #$79
  BNE not_cy
  jmp writecapY
not_cy:
  cmp #$7a
  BNE not_cz
  jmp writecapZ

not_cz:
  cmp #$20
  BNE not_spc
  jmp space_bar
not_spc:
  cmp #$0d
  BNE not_carro
  jmp carriage_return
not_carro:
  cmp #$00
  BNE not_carrt  ; null terminator
  jmp carriage_return

not_carrt:
  cmp #$30
  BNE not_ze
  jmp writezero
not_ze:
  cmp #$31
  BNE not_on
  jmp writeone
not_on:
  cmp #$32
  BNE not_tw
  jmp writetwo
not_tw:
  cmp #$33
  BNE not_thr
  jmp writethree
not_thr:
  cmp #$34
  BNE not_four
  jmp writefour
not_four:
  cmp #$35
  BNE not_five
  jmp writefive
not_five:
  cmp #$36
  BNE not_six
  jmp writesix
not_six:
  cmp #$37
  BNE not_sev
  jmp writeseven
not_sev:
  cmp #$38
  BNE not_ei
  jmp writeeight
not_ei:
  cmp #$39
  BNE not_nin
  jmp writenine
  
not_nin:
  cmp #$41
  BNE not_la
  jmp writecapA
not_la:
  cmp #$42
  BNE not_lb
  jmp writecapB
not_lb:
  cmp #$43
  BNE not_lc
  jmp writecapC
not_lc:
  cmp #$44
  BNE not_ld
  jmp writecapD
not_ld:
  cmp #$45
  BNE not_le
  jmp writecapE
not_le:
  cmp #$46
  BNE not_lf
  jmp writecapF
not_lf:
  cmp #$47
  BNE not_lg
  jmp writecapG
not_lg:
  cmp #$48
  BNE not_lh
  jmp writecapH
not_lh:
  cmp #$49
  BNE not_li
  jmp writecapI
not_li:
  cmp #$4a
  BNE not_lj
  jmp writecapJ
not_lj:
  cmp #$4b
  BNE not_lk
  jmp writecapK
not_lk:
  cmp #$4c
  BNE not_ll
  jmp writecapL
not_ll:
  cmp #$4d
  BNE not_lm
  jmp writecapM
not_lm:
  cmp #$4e
  BNE not_ln
  jmp writecapN
not_ln:
  cmp #$4f
  BNE not_lo
  jmp writecapO
not_lo:
  cmp #$50
  BNE not_lp
  jmp writecapP
not_lp:
  cmp #$51
  BNE not_lq
  jmp writecapQ
not_lq:
  cmp #$52
  BNE not_lr
  jmp writecapR
not_lr:
  cmp #$53
  BNE not_ls
  jmp writecapS
not_ls:
  cmp #$54
  BNE not_lt
  jmp writecapT
not_lt:
  cmp #$55
  BNE not_lu
  jmp writecapU
not_lu:
  cmp #$56
  BNE not_lv
  jmp writecapV
not_lv:
  cmp #$57
  BNE not_lw
  jmp writecapW
not_lw:
  cmp #$58
  BNE not_lx
  jmp writecapX
not_lx:
  cmp #$59
  BNE not_ly
  jmp writecapY
not_ly:
  cmp #$5a
  BNE not_lz
  jmp writecapZ

not_lz:
  jmp contChar
 
writecapA:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_a_n2 
  sta $220, x  ;  *
  sta $240, x  ; * *
  sta $260, x  ; ***
  INX          ; * *
  sta $200, x
  sta $240, x
  INX
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_a_n2:
  cpy #$3
  BNE h_a_n3
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  INX
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_a_n3:
  cpy #$4
  BNE h_a_n4
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  INX
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_a_n4:
  ;cpy #$6
  ;BCS cls
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  INX
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapB:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_b_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; * *
  sta $260, x  ; ***
  INX          ; ***
  sta $200, x
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_b_n2:
  cpy #$3
  BNE h_b_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_b_n3:
  cpy #$4
  BNE h_b_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_b_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapC:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_c_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; *
  sta $260, x  ; *
  INX          ; ***
  sta $200, x
  sta $260, x
  INX
  sta $200, x
  sta $260, x
  jmp contChar

  h_c_n2:
  cpy #$3
  BNE h_c_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  jmp contChar

  h_c_n3:
  cpy #$4
  BNE h_c_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  jmp contChar
  
  h_c_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  jmp contChar
 
writecapD:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_d_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; * *
  sta $260, x  ; * *
  INX          ; ***
  sta $200, x
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_d_n2:
  cpy #$3
  BNE h_d_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_d_n3:
  cpy #$4
  BNE h_d_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_d_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapE:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_e_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; **
  sta $260, x  ; **
  INX          ; ***
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  sta $260, x
  jmp contChar

  h_e_n2:
  cpy #$3
  BNE h_e_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  jmp contChar

  h_e_n3:
  cpy #$4
  BNE h_e_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  jmp contChar
  
  h_e_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  jmp contChar

writecapF:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_f_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; *
  sta $260, x  ; ***
  INX          ; *
  sta $200, x
  sta $240, x
  INX
  sta $200, x
  sta $240, x
  jmp contChar

  h_f_n2:
  cpy #$3
  BNE h_f_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  INX
  sta $300, x
  sta $340, x
  jmp contChar

  h_f_n3:
  cpy #$4
  BNE h_f_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  INX
  sta $400, x
  sta $440, x
  jmp contChar
  
  h_f_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  INX
  sta $500, x
  sta $540, x
  jmp contChar

writecapG:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_g_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; *
  sta $260, x  ; * *
  INX          ; ***
  sta $200, x
  sta $260, x
  INX
  sta $200, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_g_n2:
  cpy #$3
  BNE h_g_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_g_n3:
  cpy #$4
  BNE h_g_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_g_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapH:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_h_n2 
  sta $200, x
  sta $220, x  ; * *
  sta $240, x  ; * *
  sta $260, x  ; ***
  INX          ; * *
  sta $240, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_h_n2:
  cpy #$3
  BNE h_h_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $340, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_h_n3:
  cpy #$4
  BNE h_h_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $440, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_h_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $540, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapI:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_i_n2   ; ***
  sta $200, x  ;  *
  sta $260, x  ;  *
  INX          ; ***
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  sta $260, x
  jmp contChar

  h_i_n2:
  cpy #$3
  BNE h_i_n3
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  jmp contChar

  h_i_n3:
  cpy #$4
  BNE h_i_n4
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  jmp contChar
  
  h_i_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  jmp contChar

writecapJ:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_j_n2   ; ***
  sta $200, x  ;  *
  sta $260, x  ;  *
  INX          ; **
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  jmp contChar

  h_j_n2:
  cpy #$3
  BNE h_j_n3
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  jmp contChar

  h_j_n3:
  cpy #$4
  BNE h_j_n4
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  jmp contChar
  
  h_j_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  jmp contChar

writecapK:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_k_n2 
  sta $200, x
  sta $220, x  ; * *
  sta $240, x  ; * *
  sta $260, x  ; **
  INX          ; * *
  sta $240, x
  INX
  sta $200, x
  sta $220, x
  sta $260, x
  jmp contChar

  h_k_n2:
  cpy #$3
  BNE h_k_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $340, x
  INX
  sta $300, x
  sta $320, x
  sta $360, x
  jmp contChar

  h_k_n3:
  cpy #$4
  BNE h_k_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $440, x
  INX
  sta $400, x
  sta $420, x
  sta $460, x
  jmp contChar
  
  h_k_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $540, x
  INX
  sta $500, x
  sta $520, x
  sta $560, x
  jmp contChar

writecapL:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_l_n2 
  sta $200, x
  sta $220, x  ; *
  sta $240, x  ; *
  sta $260, x  ; *
  INX          ; ***
  sta $260, x
  INX
  sta $260, x
  jmp contChar

  h_l_n2:
  cpy #$3
  BNE h_l_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $360, x
  INX
  sta $360, x
  jmp contChar

  h_l_n3:
  cpy #$4
  BNE h_l_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $460, x
  INX
  sta $460, x
  jmp contChar
  
  h_l_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $560, x
  INX
  sta $560, x
  jmp contChar

writecapM:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_m_n2 
  sta $200, x
  sta $220, x  ; * *
  sta $240, x  ; ***
  sta $260, x  ; ***
  INX          ; * *
  sta $220, x
  sta $240, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_m_n2:
  cpy #$3
  BNE h_m_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $320, x
  sta $340, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_m_n3:
  cpy #$4
  BNE h_m_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $420, x
  sta $440, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_m_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $520, x
  sta $540, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapN:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_n_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; * *
  sta $260, x  ; * *
  INX          ; * *
  sta $200, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_n_n2:
  cpy #$3
  BNE h_n_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_n_n3:
  cpy #$4
  BNE h_n_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_n_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapO:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_o_n2 
  sta $220, x  ; ***
  sta $240, x  ; * *
  sta $260, x  ; ***
  INX 
  sta $220, x
  sta $260, x
  INX
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_o_n2:
  cpy #$3
  BNE h_o_n3
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $320, x
  sta $360, x
  INX
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_o_n3:
  cpy #$4
  BNE h_o_n4
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $420, x
  sta $460, x
  INX
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_o_n4:
  ;cpy #$6
  ;BCS cls
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $520, x
  sta $560, x
  INX
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapP:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_p_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; * *
  sta $260, x  ; ***
  INX          ; *
  sta $200, x
  sta $240, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  jmp contChar

  h_p_n2:
  cpy #$3
  BNE h_p_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  jmp contChar

  h_p_n3:
  cpy #$4
  BNE h_p_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  jmp contChar
  
  h_p_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  jmp contChar

writecapQ:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_q_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; * *
  INX          ; ***
  sta $200, x  ;   *
  sta $240, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_q_n2:
  cpy #$3
  BNE h_q_n3
  sta $300, x
  sta $320, x
  sta $340, x
  INX
  sta $300, x
  sta $340, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_q_n3:
  cpy #$4
  BNE h_q_n4
  sta $400, x
  sta $420, x
  sta $440, x
  INX
  sta $400, x
  sta $440, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_q_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  INX
  sta $500, x
  sta $540, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapR:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_r_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; ***
  sta $260, x  ; **
  INX          ; * *
  sta $200, x
  sta $220, x
  sta $240, x
  INX
  sta $200, x
  sta $220, x
  sta $260, x
  jmp contChar

  h_r_n2:
  cpy #$3
  BNE h_r_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  INX
  sta $300, x
  sta $320, x
  sta $360, x
  jmp contChar

  h_r_n3:
  cpy #$4
  BNE h_r_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  INX
  sta $400, x
  sta $420, x
  sta $460, x
  jmp contChar
  
  h_r_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  INX
  sta $500, x
  sta $520, x
  sta $560, x
  jmp contChar

writecapS:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_s_n2   ;   *
  sta $260, x  ;  *
  INX          ;  *
  sta $220, x  ; *
  sta $240, x
  INX
  sta $200, x
  jmp contChar

  h_s_n2:
  cpy #$3
  BNE h_s_n3
  sta $360, x
  INX
  sta $320, x
  sta $340, x
  INX
  sta $300, x
  jmp contChar

  h_s_n3:
  cpy #$4
  BNE h_s_n4
  sta $460, x
  INX
  sta $420, x
  sta $440, x
  INX
  sta $400, x
  jmp contChar
  
  h_s_n4:
  ;cpy #$6
  ;BCS cls
  sta $560, x
  INX
  sta $520, x
  sta $540, x
  INX
  sta $500, x
  jmp contChar

writecapT:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_t_n2 
  sta $200, x  ; ***
  INX          ;  *
  sta $200, x  ;  *
  sta $220, x  ;  *
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  jmp contChar

  h_t_n2:
  cpy #$3
  BNE h_t_n3
  sta $300, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  jmp contChar

  h_t_n3:
  cpy #$4
  BNE h_t_n4
  sta $400, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  jmp contChar
  
  h_t_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  jmp contChar

writecapU:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_u_n2 
  sta $200, x
  sta $220, x  ; * *
  sta $240, x  ; * *
  sta $260, x  ; * *
  INX          ; ***
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_u_n2:
  cpy #$3
  BNE h_u_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_u_n3:
  cpy #$4
  BNE h_u_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_u_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapV:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_v_n2 
  sta $200, x  ; * *
  sta $220, x  ; * *
  sta $240, x  ; * *
  INX          ;  *
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  jmp contChar

  h_v_n2:
  cpy #$3
  BNE h_v_n3
  sta $300, x
  sta $320, x
  sta $340, x
  INX
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  jmp contChar

  h_v_n3:
  cpy #$4
  BNE h_v_n4
  sta $400, x
  sta $420, x
  sta $440, x
  INX
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  jmp contChar
  
  h_v_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  INX
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  jmp contChar

writecapW:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_w_n2 
  sta $200, x
  sta $220, x  ; * *
  sta $240, x  ; * *
  sta $260, x  ; ***
  INX          ; ***
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_w_n2:
  cpy #$3
  BNE h_w_n3
  sta $300, y
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_w_n3:
  cpy #$4
  BNE h_w_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_w_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writecapX:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_x_n2   ; * *
  sta $200, x  ;  *
  sta $260, x  ;  *
  INX          ; * *
  sta $220, x
  sta $240, x
  INX
  sta $200, x
  sta $260, x
  jmp contChar

  h_x_n2:
  cpy #$3
  BNE h_x_n3
  sta $300, x
  sta $360, x
  INX
  sta $320, x
  sta $340, x
  INX
  sta $300, x
  sta $360, x
  jmp contChar

  h_x_n3:
  cpy #$4
  BNE h_x_n4
  sta $400, x
  sta $460, x
  INX
  sta $420, x
  sta $440, x
  INX
  sta $400, x
  sta $460, x
  jmp contChar
  
  h_x_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $560, x
  INX
  sta $520, x
  sta $540, x
  INX
  sta $500, x
  sta $560, x
  jmp contChar

writecapY:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_y_n2   ; * *
  sta $200, x  ;  *
  INX          ;  *
  sta $220, x  ;  *
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  jmp contChar

  h_y_n2:
  cpy #$3
  BNE h_y_n3
  sta $300, x
  INX
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  jmp contChar

  h_y_n3:
  cpy #$4
  BNE h_y_n4
  sta $400, x
  INX
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  jmp contChar
  
  h_y_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  INX
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  jmp contChar

writecapZ:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_z_n2 
  sta $200, x  ; ***
  sta $240, x  ;   *
  sta $260, x  ;  *
  INX          ; ***
  sta $200, x
  sta $220, x
  sta $260, x
  INX
  sta $200, x
  sta $260, x
  jmp contChar

  h_z_n2:
  cpy #$3
  BNE h_z_n3
  sta $300, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  jmp contChar

  h_z_n3:
  cpy #$4
  BNE h_z_n4
  sta $400, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  jmp contChar
  
  h_z_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  jmp contChar

;--------------------
writezero:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_zero_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; * *
  sta $260, x  ; * *
  INX          ; ***
  sta $200, x
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_zero_n2:
  cpy #$3
  BNE h_zero_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_zero_n3:
  cpy #$4
  BNE h_zero_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_zero_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writeone:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_one_n2   ; **
  sta $200, x  ;  *
  sta $260, x  ;  *
  INX          ; ***
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  INX
  sta $260, x
  jmp contChar

  h_one_n2:
  cpy #$3
  BNE h_one_n3
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $360, x
  jmp contChar

  h_one_n3:
  cpy #$4
  BNE h_one_n4
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $460, x
  jmp contChar
  
  h_one_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $560, x
  jmp contChar

writetwo:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_two_n2 
  sta $200, x  ; **
  sta $240, x  ;  *
  sta $260, x  ; *
  INX          ; ***
  sta $200, x
  sta $220, x
  sta $260, x
  INX
  sta $260, x
  jmp contChar

  h_two_n2:
  cpy #$3
  BNE h_two_n3
  sta $300, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $360, x
  INX
  sta $360, x
  jmp contChar

  h_two_n3:
  cpy #$4
  BNE h_two_n4
  sta $400, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $460, x
  INX
  sta $460, x
  jmp contChar
  
  h_two_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $560, x
  INX
  sta $560, x
  jmp contChar

writethree:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_three_n2   ; ***
  sta $200, x  ;  **
  sta $260, x  ;  **
  INX          ; ***
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_three_n2:
  cpy #$3
  BNE h_three_n3
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_three_n3:
  cpy #$4
  BNE h_three_n4
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_three_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writefour:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_four_n2 
  sta $220, x  ;  **
  sta $240, x  ; * *
  INX          ; ***
  sta $200, x  ;   *
  sta $240, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_four_n2:
  cpy #$3
  BNE h_four_n3
  sta $320, x
  sta $340, x
  INX
  sta $300, x
  sta $340, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_four_n3:
  cpy #$4
  BNE h_four_n4
  sta $420, x
  sta $440, x
  INX
  sta $400, x
  sta $440, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_four_n4:
  ;cpy #$6
  ;BCS cls
  sta $520, x
  sta $540, x
  INX
  sta $500, x
  sta $540, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  jmp contChar

writefive:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_five_n2 
  sta $200, x  ; ***
  sta $220, x  ; *
  sta $260, x  ;  *
  INX          ; ***
  sta $200, x
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  sta $260, x
  jmp contChar

  h_five_n2:
  cpy #$3
  BNE h_five_n3
  sta $300, x
  sta $320, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $360, x
  jmp contChar

  h_five_n3:
  cpy #$4
  BNE h_five_n4
  sta $400, x
  sta $420, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $460, x
  jmp contChar
  
  h_five_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $560, x
  jmp contChar

writesix:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_six_n2 
  sta $200, x
  sta $220, x  ; ***
  sta $240, x  ; *
  sta $260, x  ; ***
  INX          ; ***
  sta $200, x
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  sta $240, x
  sta $260, x
  jmp contChar

  h_six_n2:
  cpy #$3
  BNE h_six_n3
  sta $300, x
  sta $320, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  sta $360, x
  jmp contChar

  h_six_n3:
  cpy #$4
  BNE h_six_n4
  sta $400, x
  sta $420, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  sta $460, x
  jmp contChar
  
  h_six_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  sta $560, x
  jmp contChar

writeseven:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_sev_n2   ; ***
  sta $200, x  ;   *
  sta $260, x  ;  *
  INX          ; *
  sta $200, x
  sta $240, x
  INX
  sta $200, x
  sta $220, x
  jmp contChar

  h_sev_n2:
  cpy #$3
  BNE h_sev_n3
  sta $300, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  INX
  sta $300, x
  sta $320, x
  jmp contChar

  h_sev_n3:
  cpy #$4
  BNE h_sev_n4
  sta $400, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  INX
  sta $400, x
  sta $420, x
  jmp contChar
  
  h_sev_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  INX
  sta $500, x
  sta $520, x
  jmp contChar

writeeight:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_eig_n2 
  sta $200, x  ; ***
  sta $220, x  ; * *
  sta $260, x  ;  *
  INX          ; ***
  sta $200, x
  sta $240, x
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $260, x
  jmp contChar

  h_eig_n2:
  cpy #$3
  BNE h_eig_n3
  sta $300, x
  sta $320, x
  sta $360, x
  INX
  sta $300, x
  sta $340, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $360, x
  jmp contChar

  h_eig_n3:
  cpy #$4
  BNE h_eig_n4
  sta $400, x
  sta $420, x
  sta $460, x
  INX
  sta $400, x
  sta $440, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $460, x
  jmp contChar
  
  h_eig_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  sta $560, x
  INX
  sta $500, x
  sta $540, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $560, x
  jmp contChar

writenine:
  TXA
  sty $23
  ldx $23
  ldy $5901 ;start value in Y, offset in X, color in A
  cpy #$2
  BNE h_nine_n2 
  sta $200, x  ; ***
  sta $220, x  ; ***
  INX          ;   *
  sta $200, x  ;  *
  sta $220, x
  sta $260, x
  INX
  sta $200, x
  sta $220, x
  sta $240, x
  jmp contChar

  h_nine_n2:
  cpy #$3
  BNE h_nine_n3
  sta $300, x
  sta $320, x
  INX
  sta $300, x
  sta $320, x
  sta $360, x
  INX
  sta $300, x
  sta $320, x
  sta $340, x
  jmp contChar

  h_nine_n3:
  cpy #$4
  BNE h_nine_n4
  sta $400, x
  sta $420, x
  INX
  sta $400, x
  sta $420, x
  sta $460, x
  INX
  sta $400, x
  sta $420, x
  sta $440, x
  jmp contChar
  
  h_nine_n4:
  ;cpy #$6
  ;BCS cls
  sta $500, x
  sta $520, x
  INX
  sta $500, x
  sta $520, x
  sta $560, x
  INX
  sta $500, x
  sta $520, x
  sta $540, x
  jmp contChar

carriage_return:
  lda $5901
  cmp #$5
  ;BEQ cls
  lda $5902
  cmp #$20
  BCS inc_start
  lda #$80
  sta $5902
  lda $35
  cmp #$0d
  BNE fWriteChar
  jmp contChar

  inc_start:
  lda $5901
  ldx #$0
  stx $5902
  INC $5901
  lda $35
  cmp #$0d
  BNE fWriteChar
  jmp contChar

fWriteChar:
  cmp #$00
  BEQ stopprint
  jmp WriteChar

stopprint:
  RTS

space_bar:
  
  jmp contChar

contChar:
  LDY $12 
  DEY
  STY $12
  CPY #$00
  BEQ close_sec
  jmp writecont
close_sec:
  RTS
;-----------------------------

;-----------------------------
; || IMPLEMENT GRAPHICS ||
;-----------------------------
; Will be done in layers (up to 256) each with an
; unique address. A black (masking) pixel can be any
; byte hex value ending in 0 (ie. #$10, #$20, #$a0, 
; #$c0, etc) but not #$00. #$00 will be ignored as
; part of layer. Each "line" can then be used with
; vectors, both horizontally and vertically. Color
; changes will also be implemented.

draw_graph_layer:
  PLA
  sta $55
  pla ; get layer id
  pha
  lda #$00
  pha

  jsr _lookup

;----------------------------------
; || Lookup table ||
;----------------------------------
;from $d000
_lookup:
  pla
  sta $56
  pla
  sta $99
  ldy #$00

sec_dz:
  lda $d000, y
  INY
  cmp $99
  bne sec_done

  lda $d000, y
  INY
  cmp $99
  bne sec_done

  lda $d000, y
  INY
  cmp $99
  bne sec_done

  lda $d000, y
  INY
  cmp $99
  bne sec_done

  lda $d000, y
  INY
  cmp $99
  bne sec_done

  lda $d000, y
  INY
  cmp $99
  bne sec_done

  lda $d000, y
  INY
  cmp $99
  bne sec_done

  ;eval address (LSB first)
  lda $d000, y
  sta $5905
  INY
  lda $d000, y
  sta $5904
  INY
  RTS

sec_done:
  tya

  ldy #$8
  cmp #$8
  BCC sec_dz
