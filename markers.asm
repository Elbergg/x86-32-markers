%define WIDTH 320
%define HEIGHT 240


section .text
global markers
markers:
    push ebp
    mov ebp, esp
    sub esp, 32
    push ebx
    push edi
    push esi
   ; mov ecx, DWORD[ebp+20] ;file
   ; mov edi, DWORD[ebp+24] ;output
    mov DWORD[ebp-4], 0 ;marker counter
    mov DWORD[ebp-8], 0 ;x coord
    mov DWORD[ebp-12], 0 ;y cord
    mov DWORD[ebp-16], 0 ;bottom length
    mov DWORD[ebp-20], 0 ;return x cord
    mov DWORD[ebp-24], 0 ;return y cord
    mov DWORD[ebp-28], 0 ;height
    mov DWORD[ebp-32], 0 ;saved y cord
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
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, WIDTH
    je end_right
    call get_pixel
    cmp bl, 0
    jne end_right
    inc DWORD[ebp-16]
    inc DWORD[ebp-8]
    jmp go_right


end_right:
    dec DWORD[ebp-8]
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    mov [ebp-20], ebx
    mov [ebp-24], eax
bottom_frame:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, 0
    je end_bf
    sub ebx, [ebp-16]
    inc ebx
    mov [ebp-8], ebx
    dec DWORD[ebp-12]
b_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-20]
    jg end_bf
    call get_pixel
    cmp bl, 0
    je not_found
    inc DWORD[ebp-8]
    jmp b_loop


end_bf:
    mov ebx, [ebp-20]
    mov eax, [ebp-24]
    mov [ebp-8], ebx
    mov [ebp-12], eax
    mov edi, [ebp-16]
    test edi, 1
    jnz not_found
    shr edi, 1
    jmp go_up

not_found:
    jmp exit


go_up:
    inc DWORD[ebp-28]
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    call get_pixel
    cmp bl, 0
    jne not_found
    cmp [ebp-28], edi
    je end_up
    inc DWORD[ebp-12]
    jmp go_up


end_up:
    inc DWORD[ebp-12]
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, HEIGHT
    jg go_left
    mov [ebp-32], eax
    call get_pixel
    cmp bl, 0
    je not_found
    mov ebx, [ebp-8]
    cmp ebx, WIDTH
    jg go_left
    jmp right_frame

right_frame:
    jmp exit

go_left:
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
    mov esp, ebp
    pop ebp
    ret
