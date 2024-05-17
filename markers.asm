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
    jmp get_pixel
find_black_2:
    jmp exit






get_pixel:
    mov eax, [ebp-8]
    imul eax, WIDTH
    mov ebx, [ebp-12]
    add eax, ebx
    imul eax, 3
    add eax, DWORD[ebp+8]
    mov ebx, 0
    add bl, BYTE[eax]
    inc eax
    add bl, BYTE[eax]
    inc eax
    add bl, BYTE[eax]
    inc eax
    jmp find_black_2
exit:
    pop esi
    pop edi
    pop ebx
    pop ebp
    ret
