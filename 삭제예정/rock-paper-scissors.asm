TITLE ROCK-PAPER-SCISSORS
include Irvine32.inc
include macros.inc

;This program rock-paper-scissors 32-bit integers.
.386
.MODEL flat,stdcall
.STACK 4096

.data
randVal DWORD ? ;computer
choice DWORD ? ;player
counter DWORD ? ;counter of win in a row
;
outHandle HANDLE 0
windowRect SMALL_RECT <0,0,55,50>
.code
main PROC
	;console size set
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle,eax
	invoke SetConsoleWindowInfo,outHandle,TRUE,ADDR windowRect
	
	;Seed set
	call Randomize 
	mov ecx, 20
L1:
	;Generating Random 3numbers
	;Start range set 1
	mov eax, 3 
	call RandomRange 
	inc eax 
	mov randVal,eax

	mWrite <"[*]What would you like to do? 1)Scissors 2)Rock 3)Paper",0ah>
	call ReadDec
	mov choice, eax
	;comparing values 
	cmp eax, randVal 
	jg win 
	jl lose 
	jmp draw  
	loop L1
;==========================================================================
win:
	;exception handling ~> cause Scissors(1) is more stronger than Paper(3) 
	mov eax,randVal ;randVal=1
	sub eax,choice  ;choice=3
	cmp eax,-2 
	je lose
	
	mWrite <"Player Win! '3'",0ah>
	inc counter ;Win Counter increase

	;switch depends on what you choice
	mov eax,choice
	cmp eax,1
	je S_win
	cmp eax,2
	je R_win
	cmp eax,3
	je P_win
	
S_win:
	push ebp
	mov ebp,esp
	call S_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
 	jmp main
R_win:
	push ebp
	mov ebp,esp
	call R_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call S_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp main
P_win:
	push ebp
	mov ebp,esp
	call P_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp main
;==========================================================================
lose:
	;exception handling ~> cause Paper(3) is more stronger than Scissors(1)
	mov eax,randVal ;3
	sub eax,choice ;1
	cmp eax,2
	je win
	;
	mWrite <"Player Lose! OTL",0ah>
	mWrite "Win Counter:"
	mov eax,counter
	call writedec
	call crlf
	;switch depends on what you choice
	mov eax,choice
	cmp eax,1
	je S_lose
	cmp eax,2
	je R_lose
	cmp eax,3
	je P_lose
	;
S_lose:
	push ebp
	mov ebp,esp
	call S_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_print
	mWrite <"||                C O M P U T E R                ||",0ah>
 	exit
R_lose:
	push ebp
	mov ebp,esp
	call R_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	exit
P_lose:
	push ebp
	mov ebp,esp
	call P_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call S_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	exit
	;
;==========================================================================
draw:
	mWrite <"draw~~",0ah>
	mov eax,choice
	cmp eax,1
	je S_draw
	cmp eax,2
	je R_draw
	cmp eax,3
	je P_draw
	;
S_draw:
	push ebp
	mov ebp,esp
	call S_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call S_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp main
R_draw:
	push ebp
	mov ebp,esp
	call R_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call R_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp main
P_draw:
	push ebp
	mov ebp,esp
	call P_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call P_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp main
	;
;==========================================================================
R_print:
	push ebp
	mov ebp,esp
	mWrite <"                                                   ",0ah>
	mWrite <"                         ````   ``                 ",0ah>
	mWrite <"               `:/:::/o+/:--+s/:::://`             ",0ah>
	mWrite <"         .//:/s+`   `o:    /+`      .+:            ",0ah>
	mWrite <"        +/   //    `s.   `:o```       :+           ",0ah>
	mWrite <"       +:   `y     o- -/::/::::://:.`  -o          ",0ah>
	mWrite <"      `y    .o     y //           `-:/-`o.         ",0ah>
	mWrite <"      `s    `s     y //`              -+oo         ",0ah>
	mWrite <"       y`    s.    s. -//-.```          :s.        ",0ah>
	mWrite <"       os`   .s`   .s`  `./s:++          `s.       ",0ah>
	mWrite <"       y.o-   .s.   -y:../y+/-.           .o       ",0ah>
	mWrite <"       y `:/-.-o//::/../s+.               .s       ",0ah>
	mWrite <"       o.  `...   `  -+-`                `o.       ",0ah>
	mWrite <"       `s`           -`                 :+.        ",0ah>
	mWrite <"        .o:                           :+-          ",0ah>
	mWrite <"          :+:`                     ./+-            ",0ah>
	mWrite <"            .:o`                 /+:`              ",0ah>
	mWrite <"              .s                 o.                ",0ah>
	mWrite <"               +-                s.                ",0ah>
	mWrite <"               `/////:::::::/:://+                 ",0ah>
	mWrite <"                                                   ",0ah>
	pop ebp
	ret
S_print:
	push ebp
	mov ebp,esp
	mWrite <"                 .+/:/+/          :////-           ",0ah>
	mWrite <"                 y`    o-       `s-    //          ",0ah>
	mWrite <"                `y     -+       s.     .s          ",0ah>
	mWrite <"                 y     `y      +:     .s`          ",0ah>
	mWrite <"                 o-     y`    -o     `s`           ",0ah>
	mWrite <"                 `s     //   .s`     s.            ",0ah>
	mWrite <"                  +:    `y  `s`     -o             ",0ah>
	mWrite <"              `...-y     +- o-      s.             ",0ah>
	mWrite <"         `..`:/---:h-----:yo+.`     y              ",0ah>
	mWrite <"       `+:--:y     ++-```..---:/:.  y              ",0ah>
	mWrite <"       +:    s`    y`           .-/:h              ",0ah>
	mWrite <"       o-    -o    -//-.`          -h-             ",0ah>
	mWrite <"       .s`    +:     +o-::/:        `s.            ",0ah>
	mWrite <"        -y`    o-     y   /o`        .s            ",0ah>
	mWrite <"         ho-   `o/.`./+  +:          .s            ",0ah>
	mWrite <"         s-:/:::+--:-`   +           s.            ",0ah>
	mWrite <"         .s` ```                   `o-             ",0ah>
	mWrite <"          -o`                     -o.              ",0ah>
	mWrite <"           `+/`                 -+:                ",0ah>
	mWrite <"             `//:`          `://-                  ",0ah>
	mWrite <"                `://////////:`                     ",0ah>
	pop ebp
	ret
P_print:
	push ebp
	mov ebp,esp
	mWrite <"                       /+//+-                      ",0ah>
	mWrite <"             :///.    `s    y                      ",0ah>
	mWrite <"            o-   s.   :+    y     `://-            ",0ah>
	mWrite <"            //   -o   +-   `y    `s.  //           ",0ah>
	mWrite <"     `       y    y`  s`   .s   `s`   o-           ",0ah>
	mWrite <"   :/://`    +-   :+  y    :/  .s.   //            ",0ah>
	mWrite <"  `y`  .+-   -o    y  y    o. .o`   :o             ",0ah>
	mWrite <"   -o`   //` `y    //.s    y`-o`   -o              ",0ah>
	mWrite <"    .o`   -o` y     --.    ::/`   :o`              ",0ah>
	mWrite <"     .o.   .o-s                  :+                ",0ah>
	mWrite <"      `o-   `-`         .:.     `y                 ",0ah>
	mWrite <"       `+:          `-:/:. `-:///y       .-----`   ",0ah>
	mWrite <"         s-```.--::/:.`  .//.`   -+..--:/-.```.s`  ",0ah>
	mWrite <"         -y::--..`      //`       `--..`     .:o   ",0ah>
	mWrite <"          y            :+                `-:/:.    ",0ah>
	mWrite <"          +:           y`             .:/:.`       ",0ah>
	mWrite <"          `s`         `s            :+-`           ",0ah>
	mWrite <"           .s`        `:           :+              ",0ah>
	mWrite <"            `+/                  .+:               ",0ah>
	mWrite <"              .+/:.           -//:                 ",0ah>
	mWrite <"                 `-//////////:.                    ",0ah>
	pop ebp
	ret
main ENDP
END main

