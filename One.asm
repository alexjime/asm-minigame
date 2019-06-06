TITLE START_GAME.asm
INCLUDE Irvine32.inc
INCLUDE macros.inc

.data
;Menu variables
choose_menu_num DWORD 0   ; Choose_Menu 프로시저에서 입력받은 값 저장
print_made_by_input BYTE ? ; Print_Made_by 프로시저에서 입력받은 값 저장

;Rock-Scissors-Paper Variables
randVal DWORD ? ;computer
choice DWORD ? ;player
counter DWORD ? ;counter of win in a row

;Hangman variables
; 랜덤 함수용 인자
Random_Parameter DWORD 0 ; 랜덤값 인자
set_File DWORD 0  ; 파일을 설정할 랜덤 값
set_Word DWORD 0  ; 단어를 고를 랜덤 값
FileName DWORD 0 ; 읽어와야 하는 파일명의 오프셋

; 파일 입출력용 인자
; file name
five_words BYTE "5words.txt",0
six_words BYTE "6words.txt",0
seven_words BYTE "7words.txt",0

; 읽어온 파일의 내용을 저장할 배열
File_value_array BYTE 1000 DUP(0) ; 파일에서 읽어온 값을 저장할 배열
File_value_array_Size DWORD 1000 ; 1000 저장

; 핸들러 저장
handler DWORD ?

; 파일 고르기 함수 인자
Choose_file_param DWORD 0

; 배열의 알파벳 수 저장
File_length DWORD 0

; Find_Zero함수에서 사용
find_zero_offset DWORD 0 ; 0을 찾은 곳의 offset을 저장
find_zero_length DWORD 0 ; 0을 찾은 까지의 길이를 저장

; 목숨
life DWORD 6

; 단어의 길이
word_length DWORD 0;

; 랜덤으로 골라진 단어
Random_Word BYTE 100 DUP(0)

; 틀린단어 (6개까지 틀릴수 있음)
Wrong_Alpha BYTE 6 DUP(0)

; 매치된 단어가 들어갈 곳(처음엔 빈 단어)
Space_Word BYTE 6 DUP(0)

; 입력한 알파벳 
Input_Alpha BYTE 0

; 매치되는 알파벳 
Match_Alpha BYTE 0

; replay 변수
Replay DWORD 0

; ebx 임시저장소 
tempebx DWORD 0 

; console size
outHandle HANDLE 0
windowRect1 SMALL_RECT <0,0,55,50>
windowRect2 SMALL_RECT <0,0,90,55>

.code
Print_Start PROC
	mWrite < "==========================================================================================================",0ah>
	mWrite < "==========================================================================================================",0ah>
	mWrite < "   ■      ■      ■   ■■■■■   ■         ■■■■   ■■■■■       ■      ■       ■■■■■   ",0ah>
	mWrite < "    ■    ■■    ■    ■           ■         ■         ■      ■      ■■    ■■      ■           ",0ah>
	mWrite < "     ■  ■  ■  ■     ■■■■■   ■         ■         ■      ■     ■  ■  ■  ■     ■■■■■   ",0ah>
	mWrite < "      ■■    ■■      ■           ■         ■         ■      ■    ■    ■■    ■    ■           ",0ah>
	mWrite < "       ■      ■       ■■■■■   ■■■■   ■■■■   ■■■■■   ■      ■      ■   ■■■■■   ",0ah>
	mWrite < "==========================================================================================================",0ah>
ret
Print_Start ENDP

Print_Menu PROC
	mWrite < "==========================================================================================================",0ah>
	mWrite < "                    Mini Game                                                ",0ah>
	mWrite < "==========================================================================================================",0ah>
	mWrite < "                    Game Menu                                                ",0ah>
	mWrite < "==========================================================================================================",0ah>
	mWrite < "                 1. Rock Scissors Paper                                         ",0ah>
	mWrite < "                 2. Hang Man                                                    ",0ah>
	mWrite < "                 3. Made by                                                     ",0ah>
	mWrite < "                 4. exit                                                        ",0ah>
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
	mWrite < "다시 돌아가시겠습니까?(Y/N) : ">

	call ReadChar   ; Y/N 입력받음
	mov print_made_by_input, al 
	cmp print_made_by_input, "Y"
	jz Return_main
	jmp Wait_N

Return_main: 
ret
Print_Made_by ENDP

Choose_Menu PROC
ReStart:
	call clrscr ; 화면 클리어
	call Print_Menu

ReInput:
	mWrite < "Choose : ">
	call ReadDec   ; 1 ~ 4중 하나의 값 입력 받음
	mov choose_menu_num, eax 
	cmp choose_menu_num, 4   ; 입력받은 값이 4보다 클 때
	ja Re_Choose1
	cmp choose_menu_num, 1  ; 입력받은 값이 1보다 작을 때
	jb Re_Choose1
	cmp choose_menu_num, 1   ; 입력받은 값이 1일 때
	jz choose_one
	cmp choose_menu_num, 2   ; 입력받은 값이 2일 때
	jz choose_two
	cmp choose_menu_num, 3   ; 입력받은 값이 3일 때
	jz choose_three
	cmp choose_menu_num, 4   ; 입력받은 값이 4일 때
	jz choose_four

Re_Choose1:
	mWrite < "1 ~ 4 사이에서만 골라주세요. ",0ah>
	jmp ReInput

choose_one:
	call Run_RSP   ; 가위바위보 게임 실행
	jmp ReStart

choose_two:
	call Run_HangMan   ; 행맨 게임 실행
	jmp ReStart

choose_three:
	call Print_Made_by   ; 만든사람 정보 출력
	jmp ReStart

choose_four:
	mWrite < "Bye~~!",0ah>
	exit    ; 프로그램 종료

ret
Choose_Menu ENDP

;Rock-Scissors-Paper 영역
Run_RSP PROC
push ebp
mov ebp, esp

	;console size set
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle,eax
	invoke SetConsoleWindowInfo,outHandle,TRUE,ADDR windowRect1
	
	mWrite < "                    Running_Rock-Scissors-Paper~~                                                ",0ah>
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
	call S_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call R_print
	mWrite <"||                C O M P U T E R                ||",0ah>
 	exit

R_lose:
	call R_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call crlf
	mWrite <"                        V S                        ",0ah>
	call crlf
	call P_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	exit

P_lose:
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
	call S_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call S_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp main

R_draw:
	call R_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call R_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp main

P_draw:
	call P_print
	mWrite <"||                  P L A Y E R                  ||",0ah>
	call P_print
	mWrite <"||                C O M P U T E R                ||",0ah>
	invoke Sleep,1000h ;200h=1sec
	jmp main
	;
;==========================================================================
R_print:
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

S_print:
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

P_print:
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
Run_RSP ENDP

;Hangman 영역
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
	; check 파일 열렸는지 안열렸는지 check
	; 나중에 만들 예정
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

	mov eax, Choose_file_param
	cmp eax, 1
	je J1
	cmp eax, 2
	je J2
	cmp eax, 3
	je J3

J1:                     ; 점프 1
      mov FileName, OFFSET five_words
      call Read_File    ; File_value_array에 단어들 저장
      ;call DumpRegs    ; 체크 용
      ;mov edx, OFFSET File_value_array   ; 파일의 값들 출력 (잘 읽어왔는지 체크용)
      ;call WriteString
      mov word_length, 5
      jmp J4

J2:                     ; 점프 2
      mov FileName, OFFSET six_words
      call Read_File    ; File_value_array에 단어들 저장
      ;call DumpRegs    ; 체크 용
      ;mov edx, OFFSET File_value_array   ; 파일의 값들 출력 (잘 읽어왔는지 체크용)
      ;call WriteString
      mov word_length, 6
      jmp J4

J3:                     ; 점프 3
      mov FileName, OFFSET seven_words
      call Read_File    ; File_value_array에 단어들 저장
      ;call DumpRegs    ; 체크 용
      ;mov edx, OFFSET File_value_array   ; 파일의 값들 출력 (잘 읽어왔는지 체크용)
      ;call WriteString
      mov word_length, 7
      jmp J4
J4:

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


;현재까지 맞춘 알파벳 출력 
PRINT_MATCHED PROC
push ebp    
mov ebp,esp

	mov ecx, word_length
	mov esi,0 
	xor eax,eax

L1:
    xor edx,edx ;dl=0으로 초기화
    cmp dl, [Space_Word + esi] ;al ;Space_Word에는 매치된 부분에만 "0이 아닌 값"이 저장되어있음
    ;Tip: 문자값을 비교할때는 edx레지스터를 써야한다. 꼭! 꼭! eax는 정수값 비교할 때만 쓰는 레지스터입니다.
    je L5
    mov dl, [Space_Word + esi]
    mov Match_Alpha, dl
    mov edx, OFFSET Match_Alpha 
    call WriteString ;매치된 알파벳 출력
    mWrite "  " ;공백 출력
    inc esi ;인덱스 증가
    loop L1 
    
    jmp pm_end

L5: ;매치되는 값이 없었으면
    mWrite "   " ;공백 출력
    inc esi ;인덱스 증가
    loop L1
    jmp pm_end

pm_end:
    call crlf 

pop ebp
ret
PRINT_MATCHED ENDP

;언더바 출력 
PRINT_UNDERBAR PROC
push ebp
mov ebp,esp
	
	mov eax, word_length

	cmp eax, 5
	je L1
	cmp eax, 6
	je L2
	cmp eax, 7
	je L3

L1:	;5단어 일때
    mov ecx, eax
    jmp L4

L2:	;6단어 일때
    mov ecx, eax
    jmp L4
	
L3:	;7단어 일때
    mov ecx, eax
    jmp L4

L4: ; word_length 만큼 언더바 출력
    mWrite "-  "
    loop L4

	call Crlf

pop ebp
ret
PRINT_UNDERBAR ENDP

;틀린 알파벳 출력 
PRINT_WRONG_ALPHA PROC
push ebp    
mov ebp,esp

	mwrite <"Wrong Alphabet: ",0>
	mov edx, OFFSET Wrong_Alpha 
	call WriteString ;틀린 알파벳 출력 
	call crlf 

pop ebp
ret
PRINT_WRONG_ALPHA ENDP

;남은 목숨 출력 
PRINT_LIFE PROC
push ebp    
mov ebp,esp

	mwrite <"Life : ",0>
	mov eax,life
	call WriteDec 
	call crlf

pop ebp
ret
PRINT_LIFE ENDP

; 클리어 여부 프로시저 
IS_CLEAR PROC
push ebp
mov ebp,esp

	mov eax, life
	cmp eax, 0
	je lose ;그냥짐 
	mov ecx, word_length
	xor esi, esi ;esi 초기화

check_all:
   ;jmp L3
   ;cmp ecx, 0
   ;je win
   mov dl, [space_word+esi]
   cmp dl, 0
   je L3 
   inc esi
   cmp ecx, 1 ;마지막까지 다 맞췄었다면  (1로둔이유는 ecx=0이 되면 loop를 다시 반복하지 않게되기때문임)
   je win
   loop check_all

lose:
    mwrite <"                     ##############################################",0ah>
    mwrite <"                                                                   ",0ah>
    mwrite <"                     *********** Game Over! You Dead XD ***********",0ah>
    mwrite <"                                                                   ",0ah>
    mwrite <"                     ##############################################",0ah>
    invoke Sleep,1000h ;200h=1sec
    exit
    ;mov ebx, OFFSET caption2 
    ;mov edx, OFFSET Lmsg
    ;call MsgBoxAsk
    ;cmp eax, 6 ;IDYES=6 IDNO=7
    ;jne L3 
    ;mov Replay, eax ;재도전 눌렀으면 Replay변수에 6들어감.
    ;jmp L3

win:
    call victory 
    mwrite <"                     ##############################################",0ah>   
    mwrite <"                                 *  ^      *        *    ^         ",0ah>
    mwrite <"                             Wow ~ Game Clear! Congraturation!     ",0ah>
    mwrite <"                       *  *                                  *  *  ",0ah>
    mwrite <"                     ##############################################",0ah>
    invoke Sleep,1000h ;200h=1sec
    exit
    ;mov ebx, OFFSET caption1 
    ;mov edx, OFFSET Wmsg
    ;call MsgBox 

L3:

pop ebp
ret 
IS_CLEAR ENDP

; 입력 프로시저
INPUT PROC
push ebp
mov ebp,esp

	mov ecx, life ;목숨만큼 입력 가능하게 반복문 카운터 설정

L1:
    push ecx ;반복문의 카운터값을 복구하기 위해 저장해둠
    mov esi,6 
    sub esi,ecx  
    mov edx, OFFSET Input_Alpha
    mov ecx, 2 ;ReadString의 인자로 Input_Alpha의 크기만큼 ecx를 설정한다. 
    call ReadString ;Input_Alpha에 입력한 문자 저장

    mov dl, Input_Alpha
    push edx ;dl은 입력한 문자로 사용하기 위한 레지스터
    call IS_CORRECT
      
    pop ecx ;반복문의 카운터값을 복구함
    loop L1

pop ebp
ret
INPUT ENDP
; 입력 프로시저 종료

;문자 매치 프로시저 시작
IS_CORRECT PROC
push ebp
mov ebp,esp

	mov ecx, word_length ;단어의 길이만큼 반복
	xor ebx,ebx ;배열의 인덱스1
	xor esi,esi ;배열의 인덱스2
	xor edi,edi ;일치하는 단어 없는거 개수 체크용

L2:
    cmp ecx, 0 ;반복문을 다 돌았는가?
    je end_all ;다 돌았음
    mov al, [Random_Word + esi] 
    cmp dl, al ;Input_Alpha(입력한 문자) = Random_Word[esi](맞춰야할 문자)인가?
    je L2_ok
    jne L2_no

L2_ok: ;해당 자리에 입력한 문자가 일치할 경우
    mov [Space_Word + esi] , dl ;해당 문자를 저장함

    inc esi ; 배열의 인덱스 값을 하나 증가시킴
    ;mwrite "test " ;디버깅 테스트 확인용
    loop L2 
    jmp end_ret ;단어 끝부분을 맞출경우 L2_no로 넘어가는걸 방지하기 위해 end_ret로 이동
    ;모든 단어 다맞추면 플래그!

L2_no: ;해당 자리에 입력한 문자가 일치하지 않을 경우
    inc esi ; 배열의 인덱스 값을 하나 증가시킴
    inc edi ; 일치하는 단어 없는거 개수 체크용
    ;mwrite "test2 " ;디버깅 테스트 확인용
    loop L2

end_all: ;단어의 끝부분이면
    cmp esi, edi ;입력한 문자가 일치하는 문자가 하나도 존재하지 않았는가?
    je all_no
    jne end_ret

all_no: ;맞출 단어에 입력한 문자가 들어가지 않을 경우
    dec life ;남은 목숨 하나 깎는다.
    mov ebx,tempebx ;ebx값을 복원한다
    mov Wrong_Alpha[ebx], dl ;입력받았던 문자를 틀린문자에 저장한다. 
    inc ebx 
    mov tempebx, ebx ;ebx값을 복원하기위해 저장해둔다.
    ;mwrite "test3 " ;디버깅 테스트 확인용

end_ret: ;공통
    ;call clrscr ;화면지움
    call PRINT_MATCHED ;현재까지 맞춘 알파벳 출력
    call PRINT_UNDERBAR ;언더바 출력
    call PRINT_WRONG_ALPHA ;현재까지 틀린 알파벳 출력
    call PRINT_LIFE ;남은 목숨 출력
    call P_Hangman ;행맨출력
    call IS_clear ;클리어 여부 확인
    call crlf
    call crlf
    call crlf

pop ebp
ret 
Is_Correct ENDP

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
	mWrite < "                                     .!                                          ",0ah>
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
P_Hangman PROC
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

Life0:            ;목숨이 0개 일때
      call rightleg
      ;sleep
      ;call die
      Jmp exit1

exit1:

pop ebp
ret
P_Hangman ENDP
; 행맨출력 프로시저 종료

Run_HangMan PROC
; 함수 프롤로그
push ebp
mov ebp,esp

	;console size set
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle,eax
	invoke SetConsoleWindowInfo,outHandle,TRUE,ADDR windowRect2
	mWrite < "                    Running_Hangman~~                                                ",0ah>

L1:
	mov Replay, 0 ;재시작 했을 때를 고려해서 재시작변수를 초기화함
	call Randomize ; 프로시저 시작 시드 값 초기화

	; 파일 랜덤으로 고르기
	mov Random_Parameter, 3 ; Set_Random_Value를 위한 인자값 설정 1 ~ 3
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
	mwrite <"Wrong Alphabet: ",0>
	call crlf;
	
	; 남은목숨 현황 출력 
	call PRINT_LIFE
	
	; 입력 시작
	call INPUT
	
	; 위에서 열였던 파일 닫기
	mov eax, handler
	call CloseFile
	
	cmp Replay, 6 ;재시작 눌렀는가?
	je L1 ; 재시작 

; 함수 에필로그
pop ebp
ret
Run_HangMan ENDP


main PROC
push ebp
mov ebp, esp
	
	call Print_Start
	call Choose_Menu
	
	exit
main ENDP
END main
