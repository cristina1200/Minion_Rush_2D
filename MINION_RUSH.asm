.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "MINION_RUSH_2D",0
area_width EQU 600    ; dimensiunile ecranului de joc
area_height EQU 600
area DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20


counter DD 0 ; numara evenimentele de tip timer
counter_left DD 0
counter_right DD 0


aux dd 0
minion dd 460
symbol_width DD 10
symbol_height DD 20

symbols_element_width DD 36     ; dimensiunile simbolurilor
symbols_element_height DD 36

xij DD 0    ; parametrii pentru parcurgerea matricii 
yij DD 0
linii DD 11    ; nr linii matrice
coloane DD 11  ; nr coloane matrice joc
zona_joc_x EQU 25    ; dimensiunile zonei de joc propriu-zisa
zona_joc_y EQU 60
zona_size_x EQU 350
zona_size_y EQU 400

start_x DD 0  
start_y DD 60

buton_x_stg EQU 150
buton_y_stg EQU 520
buton_dim_stg EQU 50

buton_x_dr EQU 210
buton_y_dr EQU 520
buton_dim_dr EQU 50
 
i DD 10
j DD 0
dim DD 8
val DD 3
prima DD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 
ok DD 0			

include symbols_game.inc  ; fisierul cu simboluri
include digits.inc
include letters.inc


 
             
;;;;;;;    MATRICE JOC

matrice_joc  dd 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0
     	     dd 0, 2, 0, 1, 0, 1, 0, 1, 0, 1, 0  
             dd 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0
			 dd 0, 1, 0, 2, 0, 0, 0, 2, 0, 0, 0
			 dd 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0
			 dd 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0
			 dd 0, 2, 0, 1, 0, 1, 0, 2, 0, 0, 0
			 dd 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0
			 dd 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			 dd 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0
			 dd 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0
			  ;;   -     -     -     -     -

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y


;;;CREAREA SIMBOLURILOR
make_symbols_game proc     
	push ebp
	mov ebp, esp
	pusha	
	mov eax, [ebp+arg1]     ;;; simbolul de afisat
	lea esi, symbols_game
	jmp draw_text

draw_text:
	mov ebx, symbols_element_width
	mul ebx
	mov ebx, symbols_element_height
	mul ebx
	add esi, eax
	mov ecx, symbols_element_height

loop_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matrice_joc de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbols_element_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ;  avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbols_element_width
	
	
loop_simbol_coloane:  ; colorarea simbolurilor 
    cmp byte ptr[esi], 0
	je space_symbols
	cmp byte ptr[esi], 1
	je yellow_symbols
    cmp byte ptr[esi], 2
	je brown_symbols
    cmp byte ptr[esi], 3
	je black_symbols
    cmp byte ptr[esi], 4
	je blue_symbols

	
space_symbols:
	mov dword ptr[edi], 0ffffffh
	jmp simbol_pixel_next
yellow_symbols:
	mov dword ptr[edi], 0FFFF00h
	jmp simbol_pixel_next
brown_symbols:
	mov dword ptr[edi], 0964B00h
	jmp simbol_pixel_next
black_symbols:
	mov dword ptr[edi], 0000000h
	jmp simbol_pixel_next
blue_symbols:
	mov dword ptr[edi], 00000FFh
	jmp simbol_pixel_next



simbol_pixel_next:
	inc esi
	add edi, 4
	loop loop_simbol_coloane
	pop ecx
	loop loop_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_symbols_game endp


make_text proc
	push ebp
	mov ebp, esp
	pusha	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
loop_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matrice_joc de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
loop_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
	
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop loop_simbol_coloane
	pop ecx
	loop loop_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16 ;; 4biti pt fiecare dintre cei 4 parametrii
endm

make_symbols_macro macro symbols_game, drawArea, x, y
	push y
	push x
	push drawArea
	push symbols_game
	call make_symbols_game
	add esp, 16
endm

make_sageti_macro macro sageti, drawArea, x, y
	push y
	push x
	push drawArea
	push sageti
	call make_sageti
	add esp, 16
endm

line_horizontal macro  x,y, len, color  ; linie orizontala
local loop_line
      mov eax, y 
	  mov ebx, area_width
	  mul ebx 
	  add eax, x 
	  shl eax, 2 
	  add eax, area
	  mov ecx, len

loop_line :
      mov dword ptr[eax], color
	  add eax, 4
	  loop loop_line
endm



line_vertical macro  x,y, len, color   ; linie verticala 
local loop_line
      mov eax, y 
	  mov ebx, area_width
	  mul ebx 
	  add eax, x 
	  shl eax, 2 
	  add eax, area
	  mov ecx, len
loop_line :
      mov dword ptr[eax], color
	  add eax, area_width * 4
	  loop loop_line
endm

schimbare_linie_matrice proc
push ebp
mov ebp, esp
pop ebp
schimbare_linie_matrice endp	



draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
	
;buton_x_stg EQU 150
;buton_y_stg EQU 520
;buton_dim_stg EQU 50

;buton_x_dr EQU 210
;buton_y_dr EQU 520
;buton_dim_dr EQU 50
	evt_click:
	
	mov eax, [ebp+arg2]
	mov ebx, [ebp+arg3]
	cmp eax, 145
	jl exterior
	cmp eax, 200
	jg exterior
	cmp ebx, 510
	jl exterior
	cmp ebx, 570
	jg exterior

	cmp minion, 440
	je exterior
	mov edx, minion; calculam pozitia din stanga minionului
	sub edx, 8
	mov ecx,matrice_joc[edx] ;  in ecx punem pozitia din stanga minionului
	mov esi, minion          ;            in esi punem minionul
	mov edi,matrice_joc[esi] ; in edi punem pozitia minionului
	mov matrice_joc [edx], edi
	mov matrice_joc[esi], ecx
	sub minion, 8
	


exterior:    ;miscarea stg-dr
mov eax, [ebp+arg2]
	mov ebx, [ebp+arg3]
	cmp eax, 205
	jl exterior1
	cmp eax, 255
	jg exterior1
	cmp ebx, 510
	jl exterior1
	cmp ebx, 570
	jg exterior1
	

	cmp minion, 476   ; pozitia initiala a minionului 
	je exterior1
	mov edx, minion; calculam pozitia din dr minionului
	add edx, 8
	mov ecx,matrice_joc[edx] ; in ecx punem pozitia din dr minionului
	mov esi, minion          ; in esi punem minionul
	mov edi,matrice_joc[esi] ; in edi punem pozitia minionului
	mov matrice_joc [edx], edi
	mov matrice_joc[esi], ecx
	add minion, 8
	jmp exterior1

evt_timer:
cmp counter,0
cmp counter,15
jl check_score


	;make_text_macro ' ',area,200,80
	;make_text_macro ' ',area,210,80
	;make_text_macro ' ',area,220,80
	;make_text_macro ' ',area,230,80
	;make_text_macro ' ',area,240,80
	;make_text_macro ' ',area,250,80
	;make_text_macro ' ',area,260,80
	;make_text_macro ' ',area,270,80
	check_score:
	mov eax,counter_left
	cmp eax,5
	mov eax,counter_right
	cmp eax,5
	
	
inc counter
push eax
push ebx
push ecx
push edx

mov ecx, 11
mov ebx, 0

d:  ; mut intr-un array elem de pe prima linie a matricii de joc
mov eax, 1
mul linii
add eax, j
mul dim
mov edx, matrice_joc[eax]
mov prima[ebx], edx
add ebx, 4
inc j

loop d
mov ecx, 11

for1: ; liniile din matrice_joc vor cobori cu o pozitie mai jos
mov i, ecx
push ecx
mov ecx, 11
mov j, 0

for2:
dec i
mov eax, i
mul linii
add eax, j
mul dim
mov val, eax
inc i
mov eax, i
mul coloane
add eax, j
mul dim
mov edx, val
mov ebx, matrice_joc[edx]
mov matrice_joc[eax], ebx
inc j
loop for2

pop ecx
loop for1
mov ecx, 11
mov i, 0
mov j, 0
mov ebx, 0

p: ; completez  prima linie cu elem ce le am copiat inainte 

mov eax, i
mul coloane
add eax, j
mul dim
mov edx, prima[ebx]
mov matrice_joc[eax], edx
add ebx, 4
inc j
loop p

pop edx
pop ecx
pop ebx
pop eax
 
exterior1:

	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	;jmp afisare_litere
	

	push eax 
	push ebx
	push ecx
	push edx
	mov eax, 0
	mov ecx, 0
	
	
	mov esi, 0   ;i->esi    ; pargurgerea matricii de joc
	mov edi, 0   ;j->edi
	for_1: 
	mov edi, 0
	for_2: 
	mov eax, esi
	mul coloane
	add eax, edi
    mov ecx,matrice_joc[eax*4]
	
	mov eax, symbols_element_height ; aflam xij 
	mov ebx, edi
	mul ebx
	add eax, start_x
	mov xij, eax
	
	mov eax, symbols_element_height ; aflam yij
	mov ebx, esi
	mul ebx
	add eax, start_y
	mov yij, eax
	

	make_symbols_macro ecx, area, xij, yij
	inc edi
	cmp edi, coloane
	jl for_2
	inc esi
	cmp esi, linii
	jl for_1
	pop edx
	pop ecx
	pop ebx
	pop eax
	


afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	
	
	
	;scriem un mesaj
	make_text_macro 'M', area, 150, 10   ; scrierea titlului pe ecran
	make_text_macro 'I', area, 160, 10
	make_text_macro 'N', area, 170, 10
	make_text_macro 'I', area, 180, 10
	make_text_macro 'O', area, 190, 10
	make_text_macro 'N', area, 200, 10
	
	make_text_macro 'R', area, 220, 10
	make_text_macro 'U', area, 230, 10
	make_text_macro 'S', area, 240, 10
	make_text_macro 'H', area, 250, 10
	
	make_text_macro '2', area, 270, 10
	make_text_macro 'D', area, 280, 10
	
	make_text_macro 'S', area, 430, 90
	make_text_macro 'C', area, 440, 90
	make_text_macro 'O', area, 450, 90
	make_text_macro 'R', area, 460, 90
	make_text_macro 'E', area, 470, 90
	
	make_text_macro 'O', area, 490, 90
	make_text_macro 'F', area, 500, 90
	
	
	make_text_macro 'B', area, 520, 90
	make_text_macro 'A', area, 530, 90
	make_text_macro 'N', area, 540, 90
	make_text_macro 'A', area, 550, 90
	make_text_macro 'N', area, 560, 90
	make_text_macro 'A', area, 570, 90
	make_text_macro 'S', area, 580, 90
	
	
	make_text_macro '0', area, 500, 110
	make_text_macro '0', area, 510, 110
	make_text_macro '0', area, 520, 110
	
	
	
	
	
	line_horizontal zona_joc_x, zona_joc_y, zona_size_x, 0    ; realizarea zonei de joc 
	line_horizontal zona_joc_x, zona_joc_y + zona_size_y, zona_size_x, 0
	line_vertical zona_joc_x, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + zona_size_x, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + 70, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + 140, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + 210, zona_joc_y, zona_size_y, 0
	line_vertical zona_joc_x + 280, zona_joc_y, zona_size_y, 0
   
  ;  buton_x_stg EQU 150
;buton_y_stg EQU 520
;buton_dim_stg EQU 50

;buton_x_dr EQU 210
;buton_y_dr EQU 520
;buton_dim_dr EQU 50
   
	 make_symbols_macro 5, area, 160, 530
	 make_symbols_macro 4, area, 215, 530
	 
	 line_horizontal buton_x_dr, buton_y_dr, buton_dim_dr, 0     ;crearea controllerlor sub forma de patrate 
	 line_horizontal buton_x_dr, buton_y_dr + buton_dim_dr, buton_dim_dr, 0
	 line_vertical	 buton_x_dr, buton_y_dr, buton_dim_dr, 0
	 line_vertical buton_x_dr + buton_dim_dr, buton_y_dr, buton_dim_dr, 0
	 
	 line_horizontal buton_x_stg, buton_y_stg, buton_dim_stg, 0
	 line_horizontal buton_x_stg, buton_y_stg + buton_dim_stg, buton_dim_stg, 0
	 line_vertical	 buton_x_stg, buton_y_stg, buton_dim_stg, 0
	 line_vertical buton_x_stg + buton_dim_stg, buton_y_stg, buton_dim_stg, 0
	 
	
	; Assuming the game matrix is represented by a 2D array
; The registers used in this example are placeholders, adjust them as per your needs

; Set up the random number generator
; ...

; Define the range for the random position
;minX equ 0
;maxX equ 10
;minY equ 0
;maxY equ 10

; Number of obstacles to generate
;numObstacles equ 5

;generateObstacles:
 ;   xor ecx, ecx       ; Loop counter
  ;  mov edx, numObstacles

;generateObstaclesLoop:
    ; Generate random X and Y coordinates
 ;   call generateRandomX
  ;  mov esi, eax       ; Store X coordinate
   ; call generateRandomY
   ; mov edi, eax       ; Store Y coordinate

    ; Check if the generated position is empty
    ;mov eax, [matrice_joc + edi * rowSize + esi]
 ;   cmp eax, obstacle   ; Check if position is occupied by an obstacle
  ;  jne repeat          ; If occupied, repeat the process

    ; Place the obstacle in the game matrix
   ; mov [matrice_joc+ edi * rowSize + esi], obstacle

    ; Increment loop counter
    ;inc ecx
  ;  cmp ecx, edx       ; Check if all obstacles are generated
   ; jb generateObstaclesLoop

    ;ret

;repeat:
; call generateRandomX
 ;call generateRandomY
  ;jmp repeat  
    ; Repeat the process to generate new coordinates
    ; ...

;generateRandomX:
    ; Generate random X coordinate within the range (minX to maxX)
 ;   mov eax, maxX
  ;  sub eax, minX     ; Calculate the range size (maxX - minX)
   ; inc eax           ; Increment the range size by 1
    ;call generateRandom  ; Call the random number generator
;    xor edx, edx
 ;   div eax           ; Divide the random number by the range size
  ;  add eax, minX     ; Add the minimum value to the result (eax = randomX)
   ; ret

;generateRandomY:
    ; Generate random Y coordinate within the range (minY to maxY)
 ;   mov eax, maxY
  ;  sub eax, minY     ; Calculate the range size (maxY - minY)
   ; inc eax           ; Increment the range size by 1
    ;call generateRandom  ; Call the random number generator
   ; xor edx, edx
    ;div eax           ; Divide the random number by the range size
    ;add eax, minY     ; Add the minimum value to the result (eax = randomY)
    ;ret


	

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
