TITLE START_GAME.asm
INCLUDE Irvine32.inc
INCLUDE macros.inc

.data
;########################## Menu variables ########################## 
choose_menu_num DWORD 0    ; Choose_Menu input 
print_made_by_input BYTE ? ; restart reply Y/N

;################### Rock-Scissors-Paper Variables ##################
randVal DWORD ? ; Computer's choice
choice DWORD ?  ; Player's choice
counter DWORD ? ; Counter of win in a row

;###################### MOCK - JJI - PPA ############################
winner_flag DWORD 2 ; If flag is 0, computer's win. And If this flag is 1, player's win. Last Start flag is 2.
ad_count DWORD 0 ; How much attack/defence give and take count.

;####################### Hangman variables ##########################

; *** File I/O  *** 
Random_Parameter DWORD 0 ; Random value parameter
set_Word DWORD 0         ; Random value for choosing word
FileName DWORD 0         ; File OFFSET that is have to read 

four_words BYTE "4words.txt",0
five_words BYTE "5words.txt",0
six_words BYTE "6words.txt",0
seven_words BYTE "7words.txt",0
eight_words BYTE "8words.txt",0

File_value_array BYTE 1000 DUP(0) ; File reading stream 
File_value_array_Size DWORD 1000  ; File Max Size

handler DWORD ?

Choose_file_param DWORD 0 ; choice file parameter
File_length DWORD 0       ; store number of alphabet of array 

; Find_Zero PROC
find_zero_offset DWORD 0  ; store OFFSET that is File EOF(0 = Null)
find_zero_length DWORD 0  ; store lenght of File EOF 

; Game sidebar elements 
life DWORD 6
word_length DWORD 0         ; length of Random_word
Random_Word BYTE 100 DUP(0) ; word that User have to match for game clear
Wrong_Alpha BYTE 6 DUP(0)   ; wrong word that user input (MAX : 6)
Space_Word BYTE 8 DUP(0)    ; Matched words storage 

; init values
init_Random_Word BYTE SIZEOF Random_Word DUP(0) ; Random_Word init
init_Wrong_Alpha BYTE SIZEOF Wrong_Alpha DUP(0)   ; Wrong_Alpha init
init_Space_Word BYTE SIZEOF Space_Word DUP(0)    ; Space_Word init

; back-end variables
Input_Alpha BYTE 0          ; User input alphabet 
Match_Alpha BYTE 0          ; Matched alphabet with Random_Word  
Replay DWORD 0              ; replay 
tempebx DWORD 0             ; temporary save ebx   

; console size
outHandle HANDLE 0
windowRect0 SMALL_RECT <0,0,105,30> ;MainScreen CONSOLE SET
windowRect1 SMALL_RECT <0,0,55,50> ;RSP,MSP CONSOLE SET
windowRect2 SMALL_RECT <0,0,90,55> ;HANGMAN CONSOLE SET

.code
Print_Start PROC ; MainScreen
	;console size set
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle,eax
	invoke SetConsoleWindowInfo,outHandle,TRUE,ADDR windowRect0
	mWrite < "==========================================================================================================",0ah>
	mWrite < "==========================================================================================================",0ah>
	mWrite < "   ■      ■      ■   ■■■■■   ■         ■■■■   ■■■■■       ■      ■       ■■■■■   ",0ah>
	mWrite < "    ■    ■■    ■    ■           ■         ■         ■      ■      ■■    ■■      ■           ",0ah>
	mWrite < "     ■  ■  ■  ■     ■■■■■   ■         ■         ■      ■     ■  ■  ■  ■     ■■■■■   ",0ah>
	mWrite < "      ■■    ■■      ■           ■         ■         ■      ■    ■    ■■    ■    ■           ",0ah>
	mWrite < "       ■      ■       ■■■■■   ■■■■   ■■■■   ■■■■■   ■      ■      ■   ■■■■■   ",0ah>
	mWrite < "==========================================================================================================",0ah>
	invoke sleep, 350h
ret
Print_Start ENDP

Print_Menu PROC ; MainScreen
	mWrite < "==========================================================================================================",0ah>
	mWrite < "                                                 Mini Game                                                ",0ah>
	mWrite < "==========================================================================================================",0ah>
	mWrite < "                                                 Game Menu                                                ",0ah>
	mWrite < "==========================================================================================================",0ah>
	mWrite < "                                           1. Rock Scissors Paper                                         ",0ah>
	mWrite < "                                           2. Hang Man                                                    ",0ah>
	mWrite < "                                           3. MOCK - JJI - PPA                                            ",0ah>
	mWrite < "                                           4. Made by                                                     ",0ah>
	mWrite < "                                           5. exit                                                        ",0ah>
	mWrite < "==========================================================================================================",0ah>
ret
Print_Menu ENDP

Print_Made_by PROC
Wait_N:
	call clrscr   ; clear screen
	mWrite < "==========================================================================================================",0ah>
	mWrite < "                                                 Made By                                                  ",0ah>
	mWrite < "==========================================================================================================",0ah>
	mWrite < "                                          16_지민수(AlexJime)                                              ",0ah>
	mWrite < "                                          18_박재광(Whitec01a)                                             ",0ah>
	mWrite < "                                          18_유태현(em9xdm)                                                ",0ah>
	mWrite < "                                          18_홍택균(OZ1NG)                                                 ",0ah>
	mWrite < "==========================================================================================================",0ah>

RE_Chos:
	mWrite < "Do you want to go back? (Y/N) : ", 0ah>
	call ReadChar   
	mov print_made_by_input, al 
	cmp print_made_by_input, "Y"
	jz Return_main
	cmp print_made_by_input, "y"
	jz Return_main
	cmp print_made_by_input, "N"
	jz Wait_N
	cmp print_made_by_input, "n"
	jz Wait_N
	jmp RE_Chos

Return_main: ; Go back MainScreen
ret
Print_Made_by ENDP

Choose_Menu PROC
ReStart:
	call clrscr ; clear screen 
	call Print_Menu

ReInput:
	mWrite < "[>] Choose : ">
	call ReadDec   ; User can input in range of 1 ~ 5
	mov choose_menu_num, eax 
	cmp choose_menu_num, 5  ; User input > 5
	ja Re_Choose1
	cmp choose_menu_num, 1  ; User input < 1
	jb Re_Choose1
	cmp choose_menu_num, 1  ; User input = 1
	jz choose_one
	cmp choose_menu_num, 2  ; User input = 2
	jz choose_two
	cmp choose_menu_num, 3  ; User input = 3 
	jz choose_three
	cmp choose_menu_num, 4  ; User input = 4 
	jz choose_four
	cmp choose_menu_num, 5  ; User input = 5
	jz choose_five

Re_Choose1:
	mWrite < "You choose only 1 ~ 5. plz re-input",0ah>
	jmp ReInput

choose_one:
	call Run_RSP       ; Start Rock-Scissors-Paper Game
	jmp ReStart

choose_two:
	call Run_HangMan   ; Start HangMan Game
	jmp ReStart

choose_three:
	call Run_MSP       ; start MOCK - JJI - PPA
	jmp ReStart

choose_four:
	call Print_Made_by ; show made_by
	jmp ReStart

choose_five:
	mWrite < "Bye~~!",0ah>
	exit   ; Progrem off

ret
Choose_Menu ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~ Rock-Scissors-Paper Area ~~~~~~~~~~~~~~~~~~~~~~~~ 
Run_RSP PROC ; RSP Start
push ebp
mov ebp, esp
   
	mWrite < "            Running_Rock-Scissors-Paper~~",0ah>
	invoke Sleep, 750h

	;console size set
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle, eax
	invoke SetConsoleWindowInfo, outHandle, TRUE, ADDR windowRect1

	call Randomize ; Seed set

RSP_main:
	call clrscr
	mov eax, 3 
	call RandomRange  ; Generating Random 3numbers
	inc eax           ; Start range set 1
	mov randVal,eax

	call clrscr
	mWrite <"[*] What would you like to do? 1)Scissors 2)Rock 3)Paper",0ah>
	mwrite<"[>] input : ",0>
	call ReadDec
	mov choice, eax
   
	cmp eax, randVal  ; comparing values 
	jg RSP_win 
	jl RSP_lose 
	jmp RSP_draw  
	loop RSP_main
;==========================================================================
RSP_win:
	;exception handling ~> cause Scissors(1) is more stronger than Paper(3) 
	mov eax, randVal ; randVal=1
	sub eax, choice  ; choice=3
	cmp eax, -2 
	je RSP_lose         ; if true -> lose
   
	mWrite <"Player Win! ('3')",0ah>
	inc counter     ; Win Counter increase

	; switch depends on what you choice
	mov eax, choice
	cmp eax, 1
	je RSP_S_win
	cmp eax, 2
	je RSP_R_win
	cmp eax, 3
	je RSP_P_win
   
RSP_S_win:  ; When player win by Scissors
	call S_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep, 1000h ;200h=1sec
	jmp RSP_main

RSP_R_win:  ; When player win by Rock
	call R_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call S_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep, 1000h ;200h=1sec
	jmp RSP_main

RSP_P_win:  ; When player win by Paper
	call P_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep, 1000h ;200h=1sec
	jmp RSP_main
;==========================================================================
RSP_lose:
	;exception handling ~> cause Paper(3) is more stronger than Scissors(1)
	mov eax, randVal ; randVal = 3
	sub eax, choice  ; choice = 1
	cmp eax, 2
	je RSP_win

	mWrite <"Player Lose! OTL",0ah>
	mWrite "Win Counter:"
	mov eax, counter
	call writedec
	call crlf
   
	; switch depends on what you choice
	mov eax, choice
	cmp eax, 1
	je RSP_S_lose
	cmp eax, 2
	je RSP_R_lose
	cmp eax, 3
	je RSP_P_lose

RSP_S_lose: ; When player lose by Scissors
	call S_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	jmp RE_RSP

RSP_R_lose: ; When player lose by Rock
	call R_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	jmp RE_RSP

RSP_P_lose: ; When player lose by Paper
	call P_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call S_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	jmp RE_RSP

RE_RSP:
	mWrite < "One more game? (Y/N) : ", 0ah>
	call ReadChar   
	mov print_made_by_input, al 
	cmp print_made_by_input, "Y"
	jz Run_RSP
	cmp print_made_by_input, "y"
	jz Run_RSP
	cmp print_made_by_input, "N"
	jz main
	cmp print_made_by_input, "n"
	jz main
	jmp RE_RSP
 
;==========================================================================
RSP_draw:
	mWrite <"[*] Result : Draw~~",0ah>
	mov eax, choice
	cmp eax, 1
	je RSP_S_draw
	cmp eax, 2
	je RSP_R_draw
	cmp eax, 3
	je RSP_P_draw

RSP_S_draw: ; When player draw by Scissors
	call S_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call S_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp RSP_main

RSP_R_draw: ; When player draw by Rock
	call R_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp RSP_main

RSP_P_draw: ; When player draw by Paper
	call P_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp RSP_main

pop ebp
ret
Run_RSP ENDP
;==========================================================================
R_PRINT PROC
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
R_PRINT ENDP

S_PRINT PROC
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
S_PRINT ENDP

P_PRINT PROC
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
P_PRINT ENDP


;~~~~~~~~~~~~~~~~~~~~~~~~~~~ Hangman Area ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
Set_Random_Value PROC   ; Parameter : Random_Parameter , return : eax
push ebp
mov ebp,esp

	; Create Random value
	mov eax, Random_Parameter
	call RandomRange  ; return eax
	inc eax           ; range of 1 ~ Random_Parameter 

pop ebp
ret
Set_random_Value ENDP


Read_File PROC ; Parameter : OFFSET FileName , return : Store readed words to File_value_array
push ebp
mov ebp,esp

	mov edx, FileName
	call OpenInputFile
	mov handler, eax ; store handler
   
	; read file
	mov eax, handler 
	mov edx, OFFSET File_value_array
	mov ecx, File_value_array_Size
	call ReadFromFile

pop ebp
ret
Read_File ENDP


Choose_File PROC ; Parameter : Choose_file_param , return : OFFSET FileName, Store readed words to File_value_array by Read_File PROC 
push ebp
mov ebp,esp

	cmp eax, 1
	je J1
	cmp eax, 2
	je J2
	cmp eax, 3
	je J3
	cmp eax, 4
	je J4
	cmp eax, 5
	je J5
J1:				; Word lenght 5 file
	mov FileName, OFFSET five_words
	call Read_File	; Store readed words to File_value_array
	mov word_length, 5
	jmp J6

J2:				; Word lenght 6 file
	mov FileName, OFFSET six_words
	call Read_File	; Store readed words to File_value_array
	mov word_length, 6
	jmp J6

J3:				; Word lenght 7 file
	mov FileName, OFFSET seven_words
	call Read_File	; Store readed words to File_value_array
	mov word_length, 7
	jmp J6
J4:				; Word lenght 8 file
	mov FileName, OFFSET eight_words
	call Read_File	; Store readed words to File_value_array
	mov word_length, 8
	jmp J6
J5:				; Word lenght 4 file
	mov FileName, OFFSET four_words
	call Read_File	; Store Readed words to File_value_array
	mov word_length, 4
	jmp J6	
	J6:
pop ebp
ret
Choose_File ENDP


Choose_Word PROC ; Parameter : FileName , return : Random_Word[] 
push ebp
mov ebp,esp

	mov File_length, LENGTHOF File_value_array 
	call Find_File_Length

	mov ecx, word_length
	add ecx, 2  ; *.txt's Newline is 2byte. so calculate word_length+2 at each line
	mov edx, 0  ; 'div' use edx as Remainder. so init 0 
	div ecx     ; 'div' store quotient to eax. ecx means number of words in reading file 
   
	mov ebx, word_length
	add ebx, 2  ; *.txt's Newline is 2byte. so calculate word_length+2 at each line
	mul ebx     ; eax * ebx , quotient : eax
   
	;print choosed word
	mov ebx, OFFSET File_value_array
	add ebx, eax      ; +Random range
	mov edx, OFFSET Random_Word
	mov ecx, word_length
	dec ecx           ; 이유는 잘 모르겠지만 단어의 길이에서 1을 빼주고 하면 된다.

L1:                       ; Loop(Save words in Random_Word array)
	mov eax, [ebx]
	mov [edx], eax
	inc ebx
	inc edx
	loop L1

pop ebp
ret
Choose_Word ENDP


Find_File_Length PROC ; return : find_zero_offset, find_zero_length
push ebp
mov ebp,esp

	mov edx, OFFSET File_value_array
	mov ebx, 0
	mov ecx, LENGTHOF File_value_array ; MAX 1000

Find_EOF:  ; loop until finding Null
	mov eax, [edx]
	add ebx, TYPE File_value_array  
	cmp eax, 0
	je Find_Zero      ; break Find_EOF
	add edx, TYPE File_value_array 
	loop Find_EOF

Find_Zero:  
	mov find_zero_offset, edx
	mov find_zero_length, ebx

pop ebp
ret
Find_File_Length ENDP

PRINT_MATCHED PROC ; show matched alpha until now 
push ebp    
mov ebp,esp

	; set cursor position
	xor edx, edx
	mov dh, 2
	mov dl, 35
	call Gotoxy 

	mov ecx, word_length
	mov esi,0 
	xor eax,eax

is_exist:
	xor edx, edx  ; set dl = 0
	cmp dl, [Space_Word + esi] 
	;Tip: When you compare string value, use edx register
        ;     eax register is use to compare integer value.
	je not_exist
	mov dl, [Space_Word + esi]
	mov Match_Alpha, dl
	mov edx, OFFSET Match_Alpha 
	call WriteString ; show matched alpha
	mWrite "  " 
	inc esi 
	loop is_exist
	jmp pm_end

not_exist: 
	mWrite "   " ; Print space cause not correct
	inc esi ; next index
	loop is_exist
	jmp pm_end

pm_end: ; pm:print_matched 
	call crlf 

pop ebp
ret
PRINT_MATCHED ENDP

PRINT_UNDERBAR PROC ; show underbar
push ebp
mov ebp,esp
   
	; set cursor position
	xor edx, edx
	mov dh, 3
	mov dl, 35
	call Gotoxy 

	mov eax, word_length

	cmp eax, 5
	je five
	cmp eax, 6
	je six
	cmp eax, 7
	je seven

five:   
	mov ecx, eax
	jmp pu_end

six:   
	mov ecx, eax
	jmp pu_end

seven:   
	mov ecx, eax
	jmp pu_end

pu_end: ; show underbar as much as word_length 
	mWrite "-  "
	loop pu_end

	call Crlf

pop ebp
ret
PRINT_UNDERBAR ENDP

PRINT_WRONG_ALPHA PROC ; show wrong alpha until now 
push ebp    
mov ebp,esp

	; set cursor position
	xor edx, edx
	mov dh, 4
	mov dl, 15 
	call Gotoxy 

	mov eax, word_length
	mwrite <"Wrong Alphabet: ",0>
	mov edx, OFFSET Wrong_Alpha 
	call WriteString 
	call crlf 

pop ebp
ret
PRINT_WRONG_ALPHA ENDP

PRINT_LIFE PROC ; show life on now 
push ebp    
mov ebp,esp

	; set cursor position
	xor edx, edx
	mov dh, 5
	mov dl, 15
	call Gotoxy 

	mwrite <"Life : ",0>
	mov eax,life
	call WriteDec 
	call crlf

pop ebp
ret
PRINT_LIFE ENDP

IS_CLEAR PROC ; Game Clear or User dead check
push ebp
mov ebp,esp

	mov eax, life
	cmp eax, 0 
	je lose 
	mov ecx, word_length
	xor esi, esi 

check_all: ; Check all alpha of space_word
	mov dl, [space_word+esi]
	cmp dl, 0
	je ic_end
	inc esi
	cmp ecx, 1 ; if user correct word until last alpha (1로 둔 이유는 ecx=0이 되면 loop를 다시 반복하지 않게되기때문임)
	je win
	loop check_all

lose: 
	mwrite <"                     ##############################################",0ah>
	mwrite <"                                                                   ",0ah>
	mwrite <"                     *********** Game Over! You Dead XD ***********",0ah>
	mwrite <"                                                                   ",0ah>
	mwrite <"                     ##############################################",0ah>
	mwrite "                            >>>>> [!] Answer : ",0>
	mov edx, OFFSET Random_Word
	call writeString
	jmp RE_Hang

win: ; All matched alpha.
	call victory 
	mwrite <"                     ##############################################",0ah>   
	mwrite <"                                 *  ^      *        *    ^         ",0ah>
	mwrite <"                             Wow ~ Game Clear! Congraturation!     ",0ah>
	mwrite <"                       *  *                                  *  *  ",0ah>
	mwrite <"                     ##############################################",0ah>
	jmp RE_Hang
  
RE_Hang:
	mWrite < "One more play? (Y/N) : ", 0ah>
	call ReadChar   
	mov print_made_by_input, al 
	cmp print_made_by_input, "Y"
	jz Run_HangMan
	cmp print_made_by_input, "y"
	jz Run_HangMan
	cmp print_made_by_input, "N"
	jz main
	cmp print_made_by_input, "n"
	jz main
	jmp RE_Hang


ic_end: ; ic:is_clear
pop ebp
ret 
IS_CLEAR ENDP

INPUT PROC ; HangMan user's input
push ebp
mov ebp,esp

	mov ecx, life       ;User can input during living

input_main:
	push ecx            ;save input_main ecx
	mov esi,6 
	sub esi,ecx  
	mwrite <"[>] input : ",0>
	mov edx, OFFSET Input_Alpha
	mov ecx, 2          ;Input_Alpha size (including NULL)
	call ReadString 

	mov dl, Input_Alpha ;chracter is 1byte
	push edx            ;save input_main edx
	call IS_CORRECT
     
	pop ecx             ;Recover input_main ecx
	loop input_main

pop ebp
ret
INPUT ENDP

IS_CORRECT PROC ; Is input alpha correct? not ?
push ebp
mov ebp,esp

	mov ecx, word_length 
	xor ebx,ebx ; ebx is index of Wrong_Alpha
	xor esi,esi ; esi is index of Space_Word, Random_Word
	xor edi,edi ; non-matched alpha count

isc_main:
	cmp ecx, 0  ; Is this loop over?
	je end_all  ; if true -> end_all
	mov al, [Random_Word + esi] 
	cmp dl, al  ; Input_Alpha = Random_Word[esi] ?
	je isc_main_ok
	jne isc_main_no

isc_main_ok: ; correct alpha
    mov [Space_Word + esi] , dl 
    inc esi 
    loop isc_main
    jmp isc_end

isc_main_no: ; not correct alpha
	inc esi  
	inc edi  ; non-matched alpha count increase
	loop isc_main

end_all: ; checked all alpha
	cmp esi, edi ; These's nothing exist matched?
	je all_no
	jne isc_end

all_no: ; There's nothing matched alpha
	dec life                 ; decrease life
	mov ebx,tempebx          ; recover ebx
	mov Wrong_Alpha[ebx], dl ; store Input_Alpha to Wrong_Alpha 
	inc ebx                  ; increase ebx
	mov tempebx, ebx         ; save ebx

isc_end: ;IS_CORRECT end
	call PRINT_MATCHED     ; show matched alpha until now 
	call PRINT_UNDERBAR    ; show underbar 
	call PRINT_WRONG_ALPHA ; show wrong alpha until now 
	call PRINT_LIFE        ; show life on now 
	call PRINT_Hangman     ; show HangMan 
	call IS_CLEAR          ; Game Clear or User dead check
	call crlf

pop ebp
ret 
IS_CORRECT ENDP
;==========================================================================
stick PROC ; When fist input 
push ebp
mov ebp,esp

	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>

pop ebp
ret
stick ENDP

head PROC ; wrong count 1
push ebp
mov ebp,esp

	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  T   T   ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    O     .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;                 ",0ah>
	mWrite < "                     @@@@!                              ;*!,    .;=;.                 ",0ah>
	mWrite < "                     @@@@!                                .*####*.                    ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>

pop ebp
ret
head ENDP

body PROC ; wrong count 2
push ebp
mov ebp,esp

	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  T   T   ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    O     .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;                 ",0ah>
	mWrite < "                     @@@@!                              ;*!,    .;=;.                 ",0ah>
	mWrite < "                     @@@@!                                .*####*.                    ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>

pop ebp
ret
body ENDP

leftarm PROC ; wrong count 3
push ebp
mov ebp,esp

	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  T   T   ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    O     .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;                 ",0ah>
	mWrite < "                     @@@@!                    :!,       ;*!,    .;=;.                 ",0ah>
	mWrite < "                     @@@@!                     ~#!        .*####*.                    ",0ah>
	mWrite < "                     @@@@!                      .=$~         *~                       ",0ah>
	mWrite < "                     @@@@!                        -**:       *~                       ",0ah>
	mWrite < "                     @@@@!                          .#=.     *~                       ",0ah>
	mWrite < "                     @@@@!                            :#~.   *~                       ",0ah>
	mWrite < "                     @@@@!                             ,!=;  *~                       ",0ah>
	mWrite < "                     @@@@!                               ,=$-*~                       ",0ah>
	mWrite < "                     @@@@!                                 ,#@$                       ",0ah>
	mWrite < "                     @@@@!                                  ,$=                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *#-                      ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>

pop ebp
ret
leftarm ENDP

rightarm PROC ; wrong count 4
push ebp
mov ebp,esp

	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  T   T   ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    O     .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;        .        ",0ah>
	mWrite < "                     @@@@!                    :!,       ;*!,    .;=;.      ~*~        ",0ah>
	mWrite < "                     @@@@!                     ~#!        .*####*.      .*#,          ",0ah>
	mWrite < "                     @@@@!                      .=$~         *~        ,$!            ",0ah>
	mWrite < "                     @@@@!                        -**:       *~      ,*!~             ",0ah>
	mWrite < "                     @@@@!                          .#=.     *~     !#:               ",0ah>
	mWrite < "                     @@@@!                            :#~.   *~   ,=$.                ",0ah>
	mWrite < "                     @@@@!                             ,!=;  *~ .;=~                  ",0ah>
	mWrite < "                     @@@@!                               ,=$-*~~#:.                   ",0ah>
	mWrite < "                     @@@@!                                 ,#@$$-                     ",0ah>
	mWrite < "                     @@@@!                                  ,$=.                      ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *#-                      ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>

pop ebp
ret
rightarm ENDP

leftleg PROC ; wrong count 5
push ebp
mov ebp,esp

	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  T   T   ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    O     .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;        .        ",0ah>
	mWrite < "                     @@@@!                    :!,       ;*!,    .;=;.      ~*~        ",0ah>
	mWrite < "                     @@@@!                     ~#!        .*####*.      .*#,          ",0ah>
	mWrite < "                     @@@@!                      .=$~         *~        ,$!            ",0ah>
	mWrite < "                     @@@@!                        -**:       *~      ,*!~             ",0ah>
	mWrite < "                     @@@@!                          .#=.     *~     !#:               ",0ah>
	mWrite < "                     @@@@!                            :#~.   *~   ,=$.                ",0ah>
	mWrite < "                     @@@@!                             ,!=;  *~ .;=~                  ",0ah>
	mWrite < "                     @@@@!                               ,=$-*~~#:.                   ",0ah>
	mWrite < "                     @@@@!                                 ,#@$$-                     ",0ah>
	mWrite < "                     @@@@!                                  ,$=.                      ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *#-                      ",0ah>
	mWrite < "                     @@@@!                                .-*=!                       ",0ah>
	mWrite < "                     @@@@!                               ~=*~                         ",0ah>
	mWrite < "                     @@@@!                             ~$=-                           ",0ah>
	mWrite < "                     @@@@!                           ,*$:                             ",0ah>
	mWrite < "                     @@@@!                         -**:.                              ",0ah>
	mWrite < "                     @@@@!                       -==-.                                ",0ah>
	mWrite < "                     @@@@!                     ,*#~                                   ",0ah>
	mWrite < "                     @@@@!                    ,*~                                     ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>

pop ebp
ret
leftleg ENDP

rightleg PROC ; wrong count 6
push ebp
mov ebp,esp

	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  T   T   ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    O     .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;        .        ",0ah>
	mWrite < "                     @@@@!                    :!,       ;*!,    .;=;.      ~*~        ",0ah>
	mWrite < "                     @@@@!                     ~#!        .*####*.      .*#,          ",0ah>
	mWrite < "                     @@@@!                      .=$~         *~        ,$!            ",0ah>
	mWrite < "                     @@@@!                        -**:       *~      ,*!~             ",0ah>
	mWrite < "                     @@@@!                          .#=.     *~     !#:               ",0ah>
	mWrite < "                     @@@@!                            :#~.   *~   ,=$.                ",0ah>
	mWrite < "                     @@@@!                             ,!=;  *~ .;=~                  ",0ah>
	mWrite < "                     @@@@!                               ,=$-*~~#:.                   ",0ah>
	mWrite < "                     @@@@!                                 ,#@$$-                     ",0ah>
	mWrite < "                     @@@@!                                  ,$=.                      ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *#-                      ",0ah>
	mWrite < "                     @@@@!                                .-*=!$:.                    ",0ah>
	mWrite < "                     @@@@!                               ~=*~  ,*=-                   ",0ah>
	mWrite < "                     @@@@!                             ~$=-      -#;                  ",0ah>
	mWrite < "                     @@@@!                           ,*$:         .*$,                ",0ah>
	mWrite < "                     @@@@!                         -**:.            ;=;               ",0ah>
	mWrite < "                     @@@@!                       -==-.               ,*$-             ",0ah>
	mWrite < "                     @@@@!                     ,*#~                    :#;            ",0ah>
	mWrite < "                     @@@@!                    ,*~                       ,!=           ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>

pop ebp
ret
rightleg ENDP

Dead PROC ; User dead motion
push ebp
mov ebp,esp

call clrscr
Scean1:
	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  --  --  ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    O     .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;        .        ",0ah>
	mWrite < "                     @@@@!                    :!,       ;*!,    .;=;.      ~*~        ",0ah>
	mWrite < "                     @@@@!                     ~#!        .*####*.      .*#,          ",0ah>
	mWrite < "                     @@@@!                      .=$~         *~        ,$!            ",0ah>
	mWrite < "                     @@@@!                        -**:       *~      ,*!~             ",0ah>
	mWrite < "                     @@@@!                          .#=.     *~     !#:               ",0ah>
	mWrite < "                     @@@@!                            :#~.   *~   ,=$.                ",0ah>
	mWrite < "                     @@@@!                             ,!=;  *~ .;=~                  ",0ah>
	mWrite < "                     @@@@!                               ,=$-*~~#:.                   ",0ah>
	mWrite < "                     @@@@!                                 ,#@$$-                     ",0ah>
	mWrite < "                     @@@@!                                  ,$=.                      ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *#-                      ",0ah>
	mWrite < "                     @@@@!                                .-*=!$:.                    ",0ah>
	mWrite < "                     @@@@!                               ~=*~  ,*=-                   ",0ah>
	mWrite < "                     @@@@!                             ~$=-      -#;                  ",0ah>
	mWrite < "                     @@@@!                           ,*$:         .*$,                ",0ah>
	mWrite < "                     @@@@!                         -**:.            ;=;               ",0ah>
	mWrite < "                     @@@@!                       -==-.               ,*$-             ",0ah>
	mWrite < "                     @@@@!                     ,*#~                    :#;            ",0ah>
	mWrite < "                     @@@@!                    ,*~                       ,!=           ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>
	invoke sleep, 100h
	call clrscr

Scean2:
	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  --  --  ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    --    .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;                 ",0ah>
	mWrite < "                     @@@@!                              ;*!,    .;=;.                 ",0ah>
	mWrite < "                     @@@@!                                .*####*.                    ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *=                       ",0ah>
	mWrite < "                     @@@@!              ============================================  ",0ah>
	mWrite < "                     @@@@!                                   *=                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *#-                      ",0ah>
	mWrite < "                     @@@@!                                .-*=!$:.                    ",0ah>
	mWrite < "                     @@@@!                               ~=*~  ,*=-                   ",0ah>
	mWrite < "                     @@@@!                             ~$=-      -#;                  ",0ah>
	mWrite < "                     @@@@!                           ,*$:         .*$,                ",0ah>
	mWrite < "                     @@@@!                         -**:.            ;=;               ",0ah>
	mWrite < "                     @@@@!                       -==-.               ,*$-             ",0ah>
	mWrite < "                     @@@@!                     ,*#~                    :#;            ",0ah>
	mWrite < "                     @@@@!                    ,*~                       ,!=           ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>
	invoke sleep, 100h
	call clrscr

Scean3:
	mWrite < "                                                                                      ",0ah>
	mWrite < "                                                                                      ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                       ",0ah>
	mWrite < "                     @@@@=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:@*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                   @*                       ",0ah>
	mWrite < "                     @@@@!                                 ;@@@#!                     ",0ah>
	mWrite < "                     @@@@!                              -#=,    .*@~                  ",0ah>
	mWrite < "                     @@@@!                             -$,        ,*:                 ",0ah>
	mWrite < "                     @@@@!                             $-  X   X   ,=                 ",0ah>
	mWrite < "                     @@@@!                            *!            ;!                ",0ah>
	mWrite < "                     @@@@!                             #.    __    .=.                ",0ah>
	mWrite < "                     @@@@!                             :*.        .;;                 ",0ah>
	mWrite < "                     @@@@!                              ;*!,    .;=;.                 ",0ah>
	mWrite < "                     @@@@!                                .*####*.                    ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                   *~                       ",0ah>
	mWrite < "                     @@@@!                                  -*~                       ",0ah>
	mWrite < "                     @@@@!                                 ,#@$$-                     ",0ah>
	mWrite < "                     @@@@!                                ,=$$=.~#:.                  ",0ah>
	mWrite < "                     @@@@!                              ,!=; *~ .;=~                  ",0ah>
	mWrite < "                     @@@@!                             :#~.  *~   ,=$.                ",0ah>
	mWrite < "                     @@@@!                           .#=.    *~     !#:               ",0ah>
	mWrite < "                     @@@@!                          -**:     *~      ,*!~             ",0ah>
	mWrite < "                     @@@@!                        .=$~       *~        ,$!            ",0ah>
	mWrite < "                     @@@@!                       ~#!         *~         .*#,          ",0ah>
	mWrite < "                     @@@@!                      :!,          *~           ~*~         ",0ah>
	mWrite < "                     @@@@!                                   *#-                      ",0ah>
	mWrite < "                     @@@@!                                .-*=!$:.                    ",0ah>
	mWrite < "                     @@@@!                               ~=*~  ,*=-                   ",0ah>
	mWrite < "                     @@@@!                             ~$=-      -#;                  ",0ah>
	mWrite < "                     @@@@!                           ,*$:         .*$,                ",0ah>
	mWrite < "                     @@@@!                         -**:.            ;=;               ",0ah>
	mWrite < "                     @@@@!                       -==-.               ,*$-             ",0ah>
	mWrite < "                     @@@@!                     ,*#~                    :#;            ",0ah>
	mWrite < "                     @@@@!                    ,*~                       ,!=           ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@!                                                            ",0ah>
	mWrite < "                     @@@@*                                                            ",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < ":@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,",0ah>
	mWrite < " ",0ah>

pop ebp
ret
Dead ENDP

victory PROC ; When User win
push ebp
mov ebp,esp

	mWrite < "   ■       ■ ■■■■ ■■■■ ■■■■ ■■■■ ■■■■ ■    ■ ",0ah>
	mWrite < "    ■     ■     ■    ■          ■    ■    ■ ■    ■  ■  ■  ",0ah>
	mWrite < "     ■   ■      ■    ■          ■    ■    ■ ■■■■   ■■   ",0ah>
	mWrite < "      ■ ■       ■    ■          ■    ■    ■ ■   ■     ■    ",0ah>
	mWrite < "       ■      ■■■■ ■■■■    ■    ■■■■ ■    ■    ■    ",0ah>
	mWrite < "                           .;#@$~                                    ",0ah>
	mWrite < "                          *!-    ~*;                                 ",0ah>
	mWrite < "                        .=~        ;*          .;                    ",0ah>
	mWrite < "                        $-          ~;        .@.                    ",0ah>
	mWrite < "                       -;            =,      .=,                     ",0ah>
	mWrite < "                       *.            -;     .=,                      ",0ah>
	mWrite < "                       :-            !~    .=,                       ",0ah>
	mWrite < "                       .=.          .=    .=,                        ",0ah>
	mWrite < "                        -=         .@.   .@,                         ",0ah>
	mWrite < "                         ~=-      :=,   .=,                          ",0ah>
	mWrite < "                          .*=!: !$!    .=-                           ",0ah>
	mWrite < "                              -#       .@.                           ",0ah>
	mWrite < "        -!*$=***!~.            ,=:   .=,                             ",0ah>
	mWrite < "               -:!**=$=*:~~~-,   *~. =,                              ",0ah>
	mWrite < "                           :*#@@@@@@.                                ",0ah>
	mWrite < "                                 .~$                                 ",0ah>
	mWrite < "                                    !,                               ",0ah>
	mWrite < "                                     .!                              ",0ah>
	mWrite < "                                      $.                             ",0ah>
	mWrite < "                                      ;~                             ",0ah>
	mWrite < "                                      ,!                             ",0ah>
	mWrite < "                                      $.                             ",0ah>
	mWrite < "                                     .!                              ",0ah>
	mWrite < "                                     *,                              ",0ah>
	mWrite < "                                    ,=                               ",0ah>
	mWrite < "                                   =                                 ",0ah>
	mWrite < "                                  =~                                 ",0ah>
	mWrite < "                                $#===================!               ",0ah>
	mWrite < "                               ;:                   .@               ",0ah>
	mWrite < "                              .*                    .@               ",0ah>
	mWrite < "                              $-                    .@               ",0ah>
	mWrite < "                             -;                     .@               ",0ah>
	mWrite < "                            .#                      .@               ",0ah>
	mWrite < "                            !-                      .@               ",0ah>
	mWrite < "                           -!                       .@               ",0ah>
	mWrite < "                           $.                       .@               ",0ah>
	mWrite < "                          ;~                        .@               ",0ah>
	mWrite < "                         -=                         .@               ",0ah>
	mWrite < "                         *.                         .@               ",0ah>
	mWrite < "                        ::                          .@               ",0ah>
	mWrite < " ",0ah>

pop ebp
ret
victory ENDP

PRINT_Hangman PROC ; depends on comparing life
push ebp
mov ebp,esp

	mov eax, life 
	cmp eax, 6
	jz Life6
	cmp eax, 5
	jz Life5
	cmp eax, 4
	jz Life4
	cmp eax, 3
	jz Life3
	cmp eax, 2
	jz Life2
	cmp eax, 1
	jz Life1
	cmp eax, 0
	jz Life0

Life6:            
	call stick
	Jmp exit1

Life5:            
	call head
	Jmp exit1

Life4:            
	call body
	Jmp exit1

Life3:            
	call leftarm
	Jmp exit1

Life2:            
	call rightarm
	Jmp exit1

Life1:           
	call leftleg
	Jmp exit1

Life0:			
	call rightleg
	invoke sleep, 100h
	call Dead
	Jmp exit1

exit1:

pop ebp
ret
PRINT_Hangman ENDP

INIT_HANGMAN PROC ; init HangMan cause reply
push ebp
mov ebp, esp

	mov life, 6
	mov word_length, 0         

	mov esi, 0
	mov ecx, SIZEOF init_Random_Word
L1:
	mov al, init_Random_Word[esi]	
	mov Random_Word[esi], al
	inc esi
	loop L1

	mov esi, 0
	mov ecx, SIZEOF init_Wrong_Alpha
L2:
	mov al, init_Wrong_Alpha[esi]
	mov Wrong_Alpha[esi], al
	inc esi
	loop L2

	mov esi, 0
	mov ecx, SIZEOF init_Space_Word
L3:
	mov al, init_Space_Word[esi]
	mov Space_Word[esi], al
	inc esi
	loop L3
    
	mov Input_Alpha, 0          
	mov Match_Alpha, 0          
	mov Replay, 0             
	mov tempebx, 0             

pop ebp
ret
INIT_HANGMAN ENDP

Run_HangMan PROC ;HangMan Start
push ebp
mov ebp, esp

	call INIT_HANGMAN
	mWrite < "                    Running_Hangman~~                                                ",0ah>
	invoke Sleep,750h

	;console size set
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle,eax
	invoke SetConsoleWindowInfo,outHandle,TRUE,ADDR windowRect2
	call clrscr

Hangman:
	call Randomize ; init Seed for File I/O

	; choose Random File 
	mov Random_Parameter, 5 ; range of 1 ~ 5
	call Set_Random_Value
	mov Choose_file_param, eax 
	call Choose_File 
 
	call Choose_Word ; choose words in reading file

	call PRINT_UNDERBAR ; show underbar
	call PRINT_WRONG_ALPHA ; show init wrong alpha
	call crlf
	call PRINT_LIFE ; show init life 
	call INPUT ; user input
   
	; File I/O close
	mov eax, handler 
	call CloseFile

pop ebp
ret
Run_HangMan ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~ MOCK - JJI - PPA Area ~~~~~~~~~~~~~~~~~~~~~~~~ 
Run_MSP PROC
push ebp
mov ebp, esp

	mWrite < "            Running_MOCK - JJI - PPA~~",0ah>
	invoke Sleep,750h

	;console size set
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle,eax
	invoke SetConsoleWindowInfo,outHandle,TRUE,ADDR windowRect1

	call Randomize     ; Seed set

	mov winner_flag, 2 ; set start flag
	mov ad_count, 0    ; init ad_count

MSP_main:   
	call clrscr
	mov eax, 3 
	call RandomRange   ; Generating Random 3numbers
	inc eax            ; Start range set 1
	mov randVal,eax

	call clrscr
	mWrite <"[*] What would you like to do? 1)Scissors 2)Rock 3)Paper",0ah>
	mWrite <"[>] input : ",0>
	call ReadDec
	mov choice, eax
   
	cmp eax, randVal   ; comparing values 
	jg MSP_win 
	jl MSP_lose 
	inc ad_count       ; attack/defend count 
	jmp MSP_draw
	loop MSP_main
;==========================================================================
MSP_win:
	;exception handling ~> cause Scissors(1) is more stronger than Paper(3) 
	mov eax, randVal ; randVal=1
	sub eax, choice  ; choice=3
	cmp eax, -2 
	je MSP_lose      ; if true -> lose
   
	mWrite <"Player Win! ('3')",0ah>
	mWrite <"Your turn to Attack!! r(*t*)/",0ah>
 
	mov winner_flag, 1 ; set the flag when player win

	; switch depends on what you choice
	mov eax,choice
	cmp eax, 1
	je MSP_S_win
	cmp eax, 2
	je MSP_R_win
	cmp eax, 3
	je MSP_P_win

MSP_S_win:  ; When player win by Scissors
	call S_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp MSP_main

MSP_R_win:  ; When player win by Rock
	call R_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call S_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp MSP_main

MSP_P_win:  ; When player win by Paper
	call P_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp MSP_main
;==========================================================================
MSP_lose:
	;exception handling ~> cause Paper(3) is more stronger than Scissors(1)
	mov eax, randVal ; randVal = 3
	sub eax, choice  ; choice = 1
	cmp eax, 2
	je MSP_win

	call crlf
   
	mWrite <"Computer Win! ('3')",0ah>
	mWrite <"Your turn to defend. <(k-k)>",0ah>
 
	mov winner_flag, 0 ; set the flag when computer win

	; switch depends on what you choice
	mov eax, choice
	cmp eax, 1
	je MSP_S_lose
	cmp eax, 2
	je MSP_R_lose
	cmp eax, 3
	je MSP_P_lose

MSP_S_lose: ; When player lose by Scissors
	call S_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp MSP_main

MSP_R_lose: ; When player lose by Rock
	call R_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp MSP_main

MSP_P_lose: ; When player lose by Paper
	call P_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call S_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp MSP_main
   
;==========================================================================
MSP_draw:
	mov eax,choice
	cmp eax,1
	je MSP_S_draw
	cmp eax,2
	je MSP_R_draw
	cmp eax,3
	je MSP_P_draw

MSP_S_draw: ; When player draw by Scissors
	call S_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call S_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	call CHECK_WINNER    
	jmp MSP_main

MSP_R_draw: ; When player draw by Rock
	call R_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	call CHECK_WINNER    
	jmp MSP_main

MSP_P_draw: ; When player draw by Paper
	call P_PRINT
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_PRINT
	mWrite <"||                C O M P U T E R                ||",0ah>
	call CHECK_WINNER    
	jmp MSP_main

pop ebp
ret
Run_MSP ENDP
;==========================================================================
CHECK_WINNER PROC ; Check When result is draw
push ebp
mov ebp, esp

	; is previous-result draw? 
	cmp winner_flag, 2 
    je MSP_RE_game 

	; when previous-result player win
    cmp winner_flag, 1
    je MSP_P_win
    
	; when previous-result computer win
    cmp winner_flag, 0
    je MSP_C_win
    
MSP_P_win:  ; If Player win, print this message. 
    mWrite <"#################################################",0ah>
    mWrite <"#                                               #",0ah>
    mWrite <"                  PLAYER WIN!!                   ",0ah>
    mWrite <"              Count : ",0>
    mov eax, ad_count
    call WriteDec
    call crlf
    mWrite <"#                                               #",0ah>
    mWrite <"#################################################",0ah>

    pop ebp ; remove ebp in stack 
    jmp RE_TRY

MSP_C_win:  ; If Player win, print this message. 
    mWrite <"#################################################",0ah>
    mWrite <"#                                               #",0ah>
    mWrite <"                 PLAYER Lose...OTL               ",0ah>
    mWrite <"              Count : ",0>
    mov eax, ad_count
    call WriteDec
    call crlf
    mWrite <"#                                               #",0ah>
    mWrite <"#################################################",0ah>
        
	pop ebp ; remove ebp in stack 
	jmp RE_TRY

RE_TRY:
	mWrite < "One more game? (Y/N) : ", 0ah>
	call ReadChar   
	mov print_made_by_input, al 
	cmp print_made_by_input, "Y"
	jz Run_MSP
	cmp print_made_by_input, "y"
	jz Run_MSP
	cmp print_made_by_input, "N"
	jz main
	cmp print_made_by_input, "n"
	jz main
	jmp RE_TRY

MSP_RE_game:  ; When previous result and present result are draw
	mWrite <"[*] Result : Draw~~",0ah>
	mWrite <"Please One more time. (-t-)",0ah>
	invoke sleep, 1000h

pop ebp
ret
CHECK_WINNER ENDP

main PROC
push ebp
mov ebp, esp
   
	call clrscr
	call Print_Start
	call Choose_Menu
   
   exit
main ENDP
END main
