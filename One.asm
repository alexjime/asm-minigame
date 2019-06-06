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

;################### 묵찌빠 #########################
winner_flag DWORD 2 ; If flag is 0, computer's win. And If this flag is 1, player's win. Last Start flag is 2.
ad_count DWORD 0 ; How much attack/defence give and take count.

;####################### Hangman variables ##########################

; *** File I/O  *** 
Random_Parameter DWORD 0 ; 랜덤값 인자
set_File DWORD 0         ; 파일을 설정할 랜덤 값
set_Word DWORD 0         ; 단어를 고를 랜덤 값
FileName DWORD 0         ; 읽어와야 하는 파일명의 오프셋

four_words BYTE "4words.txt",0
five_words BYTE "5words.txt",0
six_words BYTE "6words.txt",0
seven_words BYTE "7words.txt",0
eight_words BYTE "8words.txt",0

File_value_array BYTE 1000 DUP(0) ; File reading stream 
File_value_array_Size DWORD 1000  ; File Max Size

handler DWORD ?

Choose_file_param DWORD 0 ; 파일 고르기 함수 인자
File_length DWORD 0       ; 배열의 알파벳 수 저장

; Find_Zero함수에서 사용
find_zero_offset DWORD 0 ; 0을 찾은 곳의 offset을 저장
find_zero_length DWORD 0 ; 0을 찾은 까지의 길이를 저장

; *** Game backend *** 
life DWORD 6
word_length DWORD 0         ; 단어의 길이
Random_Word BYTE 100 DUP(0) ; 랜덤으로 골라진 단어(맞춰야할 단어)
Wrong_Alpha BYTE 6 DUP(0)   ; 틀린단어 (6개까지 틀릴수 있음)
Space_Word BYTE 8 DUP(0)    ; 매치된 단어가 들어갈 곳(처음엔 빈 단어)

;init values
init_Random_Word BYTE SIZEOF Random_Word DUP(0) ; Random_Word 변수 초기화 때 사용할 것
init_Wrong_Alpha BYTE SIZEOF Wrong_Alpha DUP(0)   ; Wrong_Alpha 변수 초기화 때 사용할 것
init_Space_Word BYTE SIZEOF Space_Word DUP(0)    ; Space_Word 변수 초기화 때 사용할 것

Input_Alpha BYTE 0          ; 입력한 알파벳
Match_Alpha BYTE 0          ; 매치되는 알파벳 
Replay DWORD 0              ; replay 변수 (아직 미구현)
tempebx DWORD 0             ; ebx 임시저장소 

; console size
outHandle HANDLE 0
windowRect1 SMALL_RECT <0,0,55,50> ;RSP CONSOLE SET
windowRect2 SMALL_RECT <0,0,90,55> ;HANGMAN CONSOLE SET

.code
Print_Start PROC ; MainScreen
   mWrite < "==========================================================================================================",0ah>
   mWrite < "==========================================================================================================",0ah>
   mWrite < "   ■      ■      ■   ■■■■■   ■         ■■■■   ■■■■■       ■      ■       ■■■■■   ",0ah>
   mWrite < "    ■    ■■    ■    ■           ■         ■         ■      ■      ■■    ■■      ■           ",0ah>
   mWrite < "     ■  ■  ■  ■     ■■■■■   ■         ■         ■      ■     ■  ■  ■  ■     ■■■■■   ",0ah>
   mWrite < "      ■■    ■■      ■           ■         ■         ■      ■    ■    ■■    ■    ■           ",0ah>
   mWrite < "       ■      ■       ■■■■■   ■■■■   ■■■■   ■■■■■   ■      ■      ■   ■■■■■   ",0ah>
   mWrite < "==========================================================================================================",0ah>
   invoke sleep, 250h
ret
Print_Start ENDP

Print_Menu PROC ; MainScreen
   mWrite < "==========================================================================================================",0ah>
   mWrite < "                    Mini Game                                                ",0ah>
   mWrite < "==========================================================================================================",0ah>
   mWrite < "                    Game Menu                                                ",0ah>
   mWrite < "==========================================================================================================",0ah>
   mWrite < "                 1. Rock Scissors Paper                                         ",0ah>
   mWrite < "                 2. Hang Man                                                    ",0ah>
   mWrite < "                 3. MOCK - JJI - PPA                                            ",0ah>
   mWrite < "                 4. Made by                                                     ",0ah>
   mWrite < "                 5. exit                                                        ",0ah>
   mWrite < "==========================================================================================================",0ah>
ret
Print_Menu ENDP

Print_Made_by PROC
Wait_N:
   call clrscr   ; 화면 클리어
   mWrite < "==========================================================================================================",0ah>
   mWrite < "                    Made By                                                ",0ah>
   mWrite < "==========================================================================================================",0ah>
   mWrite < "                    16_지민수                                                ",0ah>
   mWrite < "                    18_박재광                                                ",0ah>
   mWrite < "                    18_유태현                                                ",0ah>
   mWrite < "                    18_홍택균                                                ",0ah>
   mWrite < "==========================================================================================================",0ah>

RE_Chos:
   mWrite < "다시 돌아가시겠습니까?(Y/N) : ", 0ah>
   call ReadChar   ; Y/N 입력받음
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
   call clrscr ; 화면 클리어
   call Print_Menu

ReInput:
   mWrite < "Choose : ">
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
   mWrite < "1 ~ 5 사이에서만 골라주세요. ",0ah>
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
Run_RSP PROC
push ebp
mov ebp, esp

   ;console size set
   invoke GetStdHandle, STD_OUTPUT_HANDLE
   mov outHandle, eax
   invoke SetConsoleWindowInfo,outHandle, TRUE, ADDR windowRect1
   
   mWrite < "            Running_Rock-Scissors-Paper~~",0ah>
   invoke Sleep,750h
   call Randomize ; Seed set

RSP_main:
   call clrscr
   mov eax, 3 
   call RandomRange  ; Generating Random 3numbers
   inc eax           ; Start range set 1
   mov randVal,eax

   call clrscr
   mWrite <"[*]What would you like to do? 1)Scissors 2)Rock 3)Paper",0ah>
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
   mov eax,randVal ; randVal=1
   sub eax,choice  ; choice=3
   cmp eax,-2 
   je RSP_lose         ; if true -> lose
   
   mWrite <"Player Win! '3'",0ah>
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
   mWrite < "한 게임 더 하시겠습니까?? (Y/N) : ", 0ah>
   call ReadChar   ; Y/N 입력받음
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
   mWrite <"draw~~",0ah>
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
Set_Random_Value PROC   ; 인자 변수 : Random_Parameter, 반환값 : eax 레지스터
push ebp
mov ebp,esp

   ; 랜덤 값을 고르는 프로시저
   mov eax, Random_Parameter
   call RandomRange
   inc eax           ; 1 더해줘서 1 ~ Random_Parameter 까지의 범위가 골라지도록 함. ; 리턴 값
   ;call DumpRegs

pop ebp
ret
Set_random_Value ENDP


Read_File PROC ; 인자 : FileName(오프셋), 리턴 : File_value_array에 파일의 내용 저장
push ebp
mov ebp,esp

   mov edx, FileName
   call OpenInputFile
   mov handler, eax ; 핸들러 저장
   
   ; 파일 읽어오기 
   mov eax, handler 
   mov edx, OFFSET File_value_array
   mov ecx, File_value_array_Size
   call ReadFromFile

pop ebp
ret
Read_File ENDP


Choose_File PROC ; 인자 : Choose_file_param, 리턴 값 : FileName( offset 임. ), Read_File 프로시저를 통해 File_value_array에 단어들 저장
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
J1:				; 점프 1, 길이 5의 단어장
	mov FileName, OFFSET five_words
	call Read_File	; File_value_array에 단어들 저장
	mov word_length, 5
	jmp J6

J2:				; 점프 2, 길이 6의 단어장
	mov FileName, OFFSET six_words
	call Read_File	; File_value_array에 단어들 저장
	mov word_length, 6
	jmp J6

J3:				; 점프 3, 길이 7의 단어장
	mov FileName, OFFSET seven_words
	call Read_File	; File_value_array에 단어들 저장
	mov word_length, 7
	jmp J6
J4:				; 점프 4, 길이 8의 단어장
	mov FileName, OFFSET eight_words
	call Read_File	; File_value_array에 단어들 저장
	mov word_length, 8
	jmp J6
J5:				; 점프 5, 길이 4의 단어장
	mov FileName, OFFSET four_words
	call Read_File	; File_value_array에 단어들 저장
	mov word_length, 4
	jmp J6	
	J6:
pop ebp
ret
Choose_File ENDP


Choose_Word PROC ; 인자 : FileName , 리턴 : Random_Word 배열
push ebp
mov ebp,esp

   ;mov eax, FIleName ; Offset 저장
   mov File_length, LENGTHOF File_value_array
   ; mov eax, File_length
   ; call DumpRegs ;check
   call Find_File_Length
   ; 랜덤으로 단어 고르기
   mov eax, find_zero_length
   ; call DumpRegs; check
   call RandomRange ; 리턴 : eax
   ; mov eax, find_zero_length 이거 넣으면 총 단어의 개수를 구해주고 이걸 빼면 랜덤으로 단어를 고를 수 있게 됨
   mov ecx, word_length
   ; call DumpRegs ; check
   add ecx, 2  ; 개행은 2byte 크기이기 때문에 한 줄의 바이트를 word_length+2로 계산
   mov edx, 0  ; div를 사용하면 나머지가 edx에 저장이 되기 때문에 edx의 값을 0으로 초기화 해주어야 함
   ;call DumpRegs ;check
   div ecx           ; 몫 : eax에 저장, 나머지 : edx에 저장 ; 각 파일의 총 단어 개수
   ;call DumpRegs ;check
   
   ; call DumpRegs; check
   mov ebx, word_length
   add ebx, 2 ; 개행은 2byte 크기이기 때문에 한 줄의 바이트를 word_length+2로 계산
   mul ebx ; eax * ebx , 몫 : eax
   ;mov ebx, eax
   
   ;고른 단어 출력
   mov ebx, OFFSET File_value_array
   add ebx, eax      ; 랜덤 범위 만큼 더함
   mov edx, OFFSET Random_Word
   mov ecx, word_length
   dec ecx     ; 이유는 잘 모르겠지만 단어의 길이에서 1을 빼주고 하면 된다.
   ;call DumpRegs ;check 

L1:                           ; Random_Word 배열에 단어를 저장하는 루프
   mov eax, [ebx]
   mov [edx], eax
   inc ebx
   inc edx
   ;call DumpRegs ;check 
   loop L1

   ;check
   mov edx, OFFSET Random_Word
   call WriteString

pop ebp
ret
Choose_Word ENDP


Find_File_Length PROC ; 리턴 : find_zero_offset, find_zero_length
push ebp
mov ebp,esp

   mov edx, OFFSET File_value_array
   ;call DumpRegs ; check
   mov ebx, 0
   mov ecx, LENGTHOF File_value_array ; 1000번 루프

L1:  ; 루프 1 ; 파일에서 널값을 찾을 때 까지 반복
   mov eax, [edx]
   add ebx, TYPE File_value_array  
   cmp eax, 0
   je Find_Zero      ; 루프 탈출
   add edx, TYPE File_value_array 
   loop L1

Find_Zero:  
   mov find_zero_offset, edx
   mov find_zero_length, ebx
   ; call DumpRegs ; check

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
   xor edx,edx  ; set dl = 0
   cmp dl, [Space_Word + esi] 
   ;Tip: 문자값을 비교할때는 edx레지스터를 써야한다. 꼭! 꼭! eax는 정수값 비교할 때만 쓰는 레지스터입니다.
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
   mWrite "   " ;공백 출력
   inc esi ;인덱스 증가
   loop is_exist
   jmp pm_end

pm_end: ; pm:print_matched 
   call crlf 

pop ebp
ret
PRINT_MATCHED ENDP

PRINT_UNDERBAR PROC ; show underbar until now 
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
   cmp ecx, 1 ; 마지막까지 다 맞췄었다면  (1로 둔 이유는 ecx=0이 되면 loop를 다시 반복하지 않게되기때문임)
   je win
   loop check_all

lose: 
   mwrite <"                     ##############################################",0ah>
   mwrite <"                                                                   ",0ah>
   mwrite <"                     *********** Game Over! You Dead XD ***********",0ah>
   mwrite <"                                                                   ",0ah>
   mwrite <"                     ##############################################",0ah>
   mwrite <"                     Wrong WORD : ",0>
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
   mWrite < "한 게임 더 하시겠습니까?? (Y/N) : ", 0ah>
   call ReadChar   ; Y/N 입력받음
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
   mwrite <"[>]input : ",0>
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

isc_end: ;공통
   call PRINT_MATCHED     ;현재까지 맞춘 알파벳 출력
   call PRINT_UNDERBAR    ;언더바 출력
   call PRINT_WRONG_ALPHA ;현재까지 틀린 알파벳 출력
   call PRINT_LIFE        ;남은 목숨 출력
   call PRINT_Hangman         ;행맨출력
   call IS_CLEAR          ;클리어 여부 확인
   call crlf
   call crlf
   call crlf

pop ebp
ret 
IS_CORRECT ENDP

; 기둥출력 프로시저
stick PROC
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

; 머리출력 프로시저
head PROC
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

; 몸통출력 프로시저
body PROC
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

; 왼팔출력 프로시저
leftarm PROC
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

; 오른팔출력 프로시저
rightarm PROC
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

; 왼다리출력 프로시저
leftleg PROC
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

; 오른다리출력 프로시저
rightleg PROC
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

; Dead 프로시저
Dead PROC
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

; 승리출력 프로시저
victory PROC
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

; 행맨출력 프로시저
PRINT_Hangman PROC
push ebp
mov ebp,esp

   mov eax, life ;목숨 개수를 eax에 저장
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

Life6:            ;목숨이 6개 일때
   call stick
   Jmp exit1

Life5:            ;목숨이 5개 일때
   call head
   Jmp exit1

Life4:            ;목숨이 4개 일때
   call body
   Jmp exit1

Life3:            ;목숨이 3개 일때
   call leftarm
   Jmp exit1

Life2:            ;목숨이 2개 일때
   call rightarm
   Jmp exit1

Life1:            ;목숨이 1개 일때
   call leftleg
   Jmp exit1

Life0:			; 목숨이 0개 일때
      call rightleg
      invoke sleep, 100h
      call Dead
      Jmp exit1

exit1:

pop ebp
ret
PRINT_Hangman ENDP
; 행맨출력 프로시저 종료

INIT_HANGMAN PROC
push ebp
mov ebp, esp

   mov life, 6
   mov word_length, 0         ; 단어의 길이

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
    
   mov Input_Alpha, 0          ; 입력한 알파벳
   mov Match_Alpha, 0          ; 매치되는 알파벳 
   mov Replay, 0              ; replay 변수 (아직 미구현)
   mov tempebx, 0             ; ebx 임시저장소 

pop ebp
ret
INIT_HANGMAN ENDP

Run_HangMan PROC
; 함수 프롤로그
push ebp
mov ebp, esp

   call INIT_HANGMAN
   ;console size set
   invoke GetStdHandle, STD_OUTPUT_HANDLE
   mov outHandle,eax
   invoke SetConsoleWindowInfo,outHandle,TRUE,ADDR windowRect2
   mWrite < "                    Running_Hangman~~                                                ",0ah>
   invoke Sleep,750h
   call clrscr

Hangman:
   mov Replay, 0 ;재시작 했을 때를 고려해서 재시작변수를 초기화함
   call Randomize ; 프로시저 시작 시드 값 초기화

   ; 읽어올 단어장 파일 랜덤으로 고르기
   mov Random_Parameter, 5 ; Set_Random_Value를 위한 인자값 설정 1 ~ 5
   call Set_Random_Value
   
   ;call DumpRegs    ; 체크 용
   ; 조건문 (파일 고르기) 
   mov Choose_file_param, eax 
   call Choose_File
   
   ; 고른 파일에서 단어 고르기
   call Choose_Word
   
   ; 단어의 길이만큼 언더바 출력
   call PRINT_UNDERBAR
   
   ; 틀린 알파벳 현황 출력(edx~>readstring한 값을 인자로 받은 뒤부터 실행가능해서 함수로 호출하면 오류뜸)
   call PRINT_WRONG_ALPHA
   ;mwrite <"Wrong Alphabet: ",0>
   call crlf;
   
   ; 남은목숨 현황 출력 
   call PRINT_LIFE
   
   ; 입력 시작
   call INPUT
   
   ; 위에서 열였던 파일 닫기
   mov eax, handler
   call CloseFile

; 함수 에필로그
pop ebp
ret
Run_HangMan ENDP

;~~~~~~~~~~~~~~~~~~~~~~~~ MOCK - JJI - PPA Area ~~~~~~~~~~~~~~~~~~~~~~~~ 
Run_MSP PROC
push ebp
mov ebp, esp

   ;console size set
   invoke GetStdHandle, STD_OUTPUT_HANDLE
   mov outHandle,eax
   invoke SetConsoleWindowInfo,outHandle,TRUE,ADDR windowRect1
   
   mWrite < "            Running_MOCK - JJI - PPA~~",0ah>
   invoke Sleep,750h
   call Randomize ; Seed set

   mov winner_flag, 2 ; set start flag
   mov ad_count, 0 ; init ad_count

MSP_main:   ; 이곳으로 다시 돌아와야 함.
   call clrscr
   mov eax, 3 
   call RandomRange  ; Generating Random 3numbers
   inc eax           ; Start range set 1
   mov randVal,eax

   call clrscr
   mWrite <"[*] What would you like to do? 1)Scissors 2)Rock 3)Paper",0ah>
   mWrite <"[>]input : ",0>
   call ReadDec
   mov choice, eax
   
   cmp eax, randVal  ; comparing values 
   jg MSP_win 
   jl MSP_lose 
   inc ad_count     ; 공방 횟수 카운트
   jmp MSP_draw
   loop MSP_main
;==========================================================================
MSP_win:
   ;exception handling ~> cause Scissors(1) is more stronger than Paper(3) 
   mov eax, randVal ; randVal=1
   sub eax, choice  ; choice=3
   cmp eax, -2 
   je MSP_lose         ; if true -> lose
   
   mWrite <"Player Win! '3'",0ah>
   mWrite <"Your turn to Attack!! '3'",0ah>
 
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
   
   mWrite <"Computer Win! '3'",0ah>
   mWrite <"Your turn to defend. '3'",0ah>
 
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
   call CHECK_WINNER    ; 맨 처음 가위바위보가 무승부 일시 다시 이곳으로 리턴, 아니라면 Check_winner 프로시저 내에서 게임이 종료되어 이곳으로 다시 안돌아옴.
   jmp MSP_main

MSP_R_draw: ; When player draw by Rock
   call R_PRINT
   mWrite <"||                  P L A Y E R                  ||",0ah>
   call crlf
   mWrite <"                        V S                        ",0ah>
   call crlf
   call R_PRINT
   mWrite <"||                C O M P U T E R                ||",0ah>
   call CHECK_WINNER    ; 맨 처음 가위바위보가 무승부 일시 다시 이곳으로 리턴, 아니라면 Check_winner 프로시저 내에서 게임이 종료되어 이곳으로 다시 안돌아옴.
   jmp MSP_main

MSP_P_draw: ; When player draw by Paper
   call P_PRINT
   mWrite <"||                  P L A Y E R                  ||",0ah>
   call crlf
   mWrite <"                        V S                        ",0ah>
   call crlf
   call P_PRINT
   mWrite <"||                C O M P U T E R                ||",0ah>
   call CHECK_WINNER    ; 맨 처음 가위바위보가 무승부 일시 다시 이곳으로 리턴, 아니라면 Check_winner 프로시저 내에서 게임이 종료되어 이곳으로 다시 안돌아옴.
   jmp MSP_main

pop ebp
ret
Run_MSP ENDP
;==========================================================================

;무승부인 시점에 확인
CHECK_WINNER PROC
push ebp
mov ebp, esp

    cmp winner_flag, 2
    je MSP_RE_game ;MSP_main

    cmp winner_flag, 1
    je MSP_P_win
    
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

    pop ebp ; 스택에 쌓인 ebp를 제거하기 위함
    jmp RE_TRY

MSP_C_win:  ; If Player win, print this message. 
    mWrite <"#################################################",0ah>
    mWrite <"#                                               #",0ah>
    mWrite <"                 PLAYER Lose...                  ",0ah>
    mWrite <"              Count : ",0>
    mov eax, ad_count
    call WriteDec
    call crlf
    mWrite <"#                                               #",0ah>
    mWrite <"#################################################",0ah>
        
   pop ebp
   jmp RE_TRY

RE_TRY:
   mWrite < "한 게임 더 하시겠습니까?? (Y/N) : ", 0ah>
   call ReadChar   ; Y/N 입력받음
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

MSP_RE_game:        ; 비겼을 경우
   mWrite <"draw~~",0ah>
   mWrite <"Please One more time. '3'",0ah>
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
