;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; On/Off States for Any Line-Guide, by elusive
; based on Line-Guide "Acts Like" Fix, by imamelia
; Re-use permission given by imamelia on 7/19/2021
; Please credit the original author(s) as well
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Line-Guide "Acts Like" Fix, by imamelia
;
; This patch makes the line guide processing routine depend on the "acts like"
; setting of the Map16 tiles rather than the tile number.  This allows you to put
; line guide tiles anywhere on any Map16 page, as long as they act like the original
; tiles (or a tile set to act like one of the original tiles).
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; worldpeace's note:
; The vanilla code of line guide interaction sometimes tries to restore the sprite's position from backup RAM, even if they aren't properly stored.
; This results in teleportation of line-guided sprites. (Like other vanilla glitches, this has been regarded as a feature and utilized for vanilla tricks!)
; 
; The previous version assumed the correctness of Nintendo's code however, and accessed some invalid "acts like" values as a result.
; It caused game freezing in some emulators (e.g. higan v092); for those who're interested, the patch got the map16 value outside of the level area and repeated a loop infinitely.
; 
; My version fixes the freezing issue, as well as giving some extra option regarding behaviors of line guide.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; modify this as you want ($00-$03). use $01-$03 to use the line guide ends.
!glitch_level = $01						


; Explanation: you can choose the frequency of odd behaviors, which are the following:
; 1) Map16 tiles in the page 1 (or acting like one) work as "line guide end".
; 2) Those tiles let line-guided sprites teleport to certain position. (see ft029's swissotel in vldcx)
; 
; These behaviors can be rarely observed in vanilla; only when the line-guided sprite is at a specific position which is decided by the map16 page of interacting tiles.
; 
; $03 = always allows those two behaviors regardless of the position of a line-guided sprite, like the previous version of the patch.
; $02 = always allows the "line guide end" behavior, but disallows the teleportation. (good for non-janky hacks)
; $01 = sparsely allows them as frequent as the true vanilla where there are only map16 pages 0 and 1. (might be useful for a restrictive compilation hack of something)
; $00 = disallows them completely. (another option for non-janky hacks)


; setup sa-1
!addr	= $0000
!bank	= $800000
!state	= $C2

if read1($00FFD5) == $23
	sa1rom
	!addr	= $6000
	!bank	= $000000
	!state	= $D8
endif


; hijack
org $01D99C
autoclean JML LineGuideActFix


freecode

!map16page = $10							; page with custom on/off tiles

; see readme for instructions on how to modify these tables
OnTable:
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$8C,$8D,$00,$88,$25,$91,$90 	; 00-0F \ diagonals, verticals ON
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$25,$25,$00,$8A,$25,$25,$25 	; 10-1F / diagonals, verticals OFF
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$25,$25,$25,$25,$89,$93,$25 	; 20-2F \ diagonals, horizontals OFF
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$8E,$8F,$87,$25,$8B,$92,$25 	; 30-3F / diagonals, horizontals ON
db $00,$00,$00,$00,$00,$00,$00,$00,$7A,$7B,$7E,$7F,$25,$25,$25,$25 	; 40-4F \ 
db $00,$00,$00,$00,$00,$00,$00,$00,$7C,$76,$77,$7D,$25,$25,$25,$25 	; 50-5F | circles ON, circles OFF
db $00,$00,$00,$00,$00,$00,$00,$00,$82,$78,$79,$83,$25,$25,$25,$25 	; 60-6F | 
db $00,$00,$00,$00,$00,$00,$00,$00,$80,$81,$84,$85,$25,$25,$25,$25 	; 70-7F / 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; 80-8F \ 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; 90-9F | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; A0-AF | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; B0-BF | unused rows
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; C0-CF | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; D0-DF | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; E0-EF | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; F0-FF /


OffTable:
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$25,$25,$00,$25,$88,$25,$25 	; 00-0F \ diagonals, verticals OFF
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$8E,$8F,$00,$25,$8A,$91,$90 	; 10-1F / diagonals, verticals ON
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$8C,$8D,$86,$89,$25,$25,$93 	; 20-2F \ diagonals, horizontals ON
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$25,$25,$25,$8B,$25,$25,$92 	; 30-3F / diagonals, horizontals OFF
db $00,$00,$00,$00,$00,$00,$00,$00,$25,$25,$25,$25,$7A,$7B,$7E,$7F 	; 40-4F \ 
db $00,$00,$00,$00,$00,$00,$00,$00,$25,$25,$25,$25,$7C,$76,$77,$7D 	; 50-5F | circles OFF, circles ON
db $00,$00,$00,$00,$00,$00,$00,$00,$25,$25,$25,$25,$82,$78,$79,$83 	; 60-6F | 
db $00,$00,$00,$00,$00,$00,$00,$00,$25,$25,$25,$25,$80,$81,$84,$85 	; 70-7F / 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; 80-8F \ 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; 90-9F | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; A0-AF | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; B0-BF | unused rows
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; C0-CF | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; D0-DF | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; E0-EF | 
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 	; F0-FF /


LineGuideActFix:
	CMP #$80 							;\ A is high byte of map16 tile (from $01D997)
	BCS .reject 							;/ if page is $80 and up, background tiles, reject.

.loop
	CMP #!map16page							;\ only check one page
	BNE .wrongPage 							;/ 

	XBA 								;\ map16 tile
	LDA $1693|!addr 						;/ 

	PHX 								;\ 
	TAX 								;| use map16 low byte as index
	LDA.l OnTable,x 						;| to see if on/off tables have a non $00 value
	PLX 								;| 
	CMP #$00 							;| 
	BNE .found 							;| if value found, check state
	BRA .notFound 							;/ else, try to resolve act as

	.wrongPage
	XBA 								;> high byte of map16 number
	.notFound
	LDA $1693|!addr 						;\ map16 tile
	REP #$20 							;/ 

	ASL 								;\ 
	ADC $06F624|!bank 						;| 
	STA $0D 							;| 
	SEP #$20 							;| 
	LDA $06F626|!bank 						;| get the map16 tile's true act as setting address high byte
	STA $0F 							;| 
	REP #$20							;| 
	LDA [$0D] 							;| 
	SEP #$20							;| 
	STA $1693|!addr 						;| 
	XBA 								;| 
	BRA .checkPage 							;/ 

	.found
	LDA $1693|!addr 						;\ 
	PHX 								;| 
	TAX 								;| check on/off switch and load value from respective table
	LDA $14AF|!addr							;| 
	BNE .off							;/ 

	.on
	LDA.l OnTable,x 						;\ switch in on state, get value at index
	BRA .save 							;/ 
	
	.off 
	LDA.l OffTable,x 						;> switch in off state, get value at index

	.save
	PLX 								;\ 
	STA $1693|!addr 						;| store custom low byte map16, i.e. the act as for this tile in current switch state
	LDA #$00 							;| fake page $00
	BRA .cont 							;/ skip check page since we know its $00
	
	.checkPage
	CMP #$02							;\ loop until we find map16 tile on page 0,1
	BCS .loop 							;/ 

	.cont
	if !glitch_level == $00
		CMP #$00
		BNE .reject
		LDA $1693|!addr
		CMP #$96
		BCS .reject
		PLA
		PLA
		JML $01D83F|!bank
	elseif !glitch_level == $01
		PHA
		LDA $05
		AND #$07
		JML $01D9A1|!bank
	elseif !glitch_level == $02
		LDY !state,x
		CPY #$02
		BEQ +
		CMP #$00
		JML $01D9A6|!bank
		+
		CMP #$00
		BNE .reject
		LDA $1693|!addr
		CMP #$96
		BCS .reject
		PLA
		PLA
		JML $01D83F|!bank
	else
		CMP #$00
		JML $01D9A6|!bank
	endif
.reject
	PLA
	PLA
	JML $01D861|!bank
