TITLE START_GAME.asm
INCLUDE Irvine32.inc
INCLUDE macros.inc

.data
choose_menu_num DWORD 0   ; Choose_Menu 프로시저에서 입력받은 값 저장
print_made_by_input BYTE ? ; Print_Made_by 프로시저에서 입력받은 값 저장

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
mWrite < "                 2. Hang Manu                                                   ",0ah>
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
ret
Print_Made_by ENDP

Run_RCP PROC
mWrite < "                    Running_RCP_Game~~                                                ",0ah>
ret
Run_RCP ENDP

Run_HangMan PROC
mWrite < "                    Running_HangMan_Game~~                                                ",0ah>
ret
Run_HangMan ENDP

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
   call Run_RCP   ; 가위바위보 게임 실행
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

main PROC
call Print_Start
call Choose_Menu
exit
main ENDP
END main
