%define WIDTH 320
%define HEIGHT 240


section .text
global markers
markers:
    push ebp
    mov ebp, esp
    sub esp, 4 ;marker counter
    sub esp, 4, ;x cord
    sub esp, 4 ;y cord
    push ebx
    push edi
    push esi
   ; mov ecx, DWORD[ebp+20] ;file
   ; mov edi, DWORD[ebp+24] ;output
    mov DWORD[ebp-4], 0 ;marker counter
    mov DWORD[ebp-8], 0 ;x coord
    mov DWORD[ebp-12], 0 ;y cord
    jmp find_black
    jmp exit

find_black:
    mov eax, [ebp-12]
    mov ebx, [ebp-8]
    cmp ebx, WIDTH
    je next_row
    mov ecx, DWORD[ebp+8]
    call get_pixel
    cmp bl, 0
    je go_right
    inc DWORD[ebp-8]
    jmp find_black

next_row:
    inc DWORD[ebp-12]
    mov DWORD[ebp-8], 0
    jmp find_black

go_right:
    jmp exit



get_pixel:
    push ebp
    mov ebp, esp
    imul eax, WIDTH
    add eax, ebx
    imul eax, 3
    add eax, ecx
    mov ebx, 0
    add bl, BYTE[eax]
    inc eax
    add bl, BYTE[eax]
    inc eax
    add bl, BYTE[eax]
    inc eax
    mov esp, ebp
    pop ebp
    ret
exit:
    pop esi
    pop edi
    pop ebx
    pop ebp
    ret
