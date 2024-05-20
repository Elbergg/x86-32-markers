%define WIDTH 320
%define HEIGHT 240
%define TOP_BORDER 319
%define RIGHT_BORDER 319

section .text
global markers
markers:
    push ebp
    mov ebp, esp
    sub esp, 68
    push ebx
    push edi
    push esi
    push edx
    mov DWORD[ebp-4], 0 ;marker counter
    mov DWORD[ebp-8], 0 ;x coord
    mov DWORD[ebp-12], 0 ;y cord
    mov DWORD[ebp-16], 0 ;bottom length
    mov DWORD[ebp-20], 0 ;return x cord
    mov DWORD[ebp-24], 0 ;return y cord
    mov DWORD[ebp-28], 0 ;height
    mov DWORD[ebp-32], 0 ;saved y cord
    mov DWORD[ebp-36], 0 ;left x cord
    mov DWORD[ebp-40], 0 ; saved x cord in urf
    mov DWORD[ebp-44], 0 ;saved y cord in down loop
    mov DWORD[ebp-48], 0 ; arm_width
    mov DWORD[ebp-52], 0 ; a point at which the inner arms should intersect
    mov DWORD[ebp-56], 0 ; saved x cord in left again
    mov DWORD[ebp-60], 0 ; saved y cord in da
    mov DWORD[ebp-64], 0 ; x cord of inner intersection
    mov eax, [ebp+12]
    mov DWORD[ebp-68], eax
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
    mov eax, [ebp-12]
    cmp eax, HEIGHT
    je exit
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
    je go_left
    mov [ebp-32], eax
    call get_pixel
    cmp bl, 0
    je not_found
    mov ebx, [ebp-8]
    cmp ebx, RIGHT_BORDER
    je go_left
    jmp right_frame

right_frame:
    mov eax, [ebp-24]
    mov [ebp-12], eax
    inc DWORD[ebp-8]

rf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-32]
    je end_rf
    call get_pixel
    inc DWORD[ebp-12]
    cmp bl, 0
    je not_found
    jmp rf_loop

end_rf:
    dec DWORD[ebp-8]
    jmp go_left


go_left:
    dec DWORD[ebp-12]
    shl edi, 1
    mov esi, [ebp-8]
    sub esi, edi
    inc esi
    mov [ebp-36], esi
    shr edi, 1
    mov edx, [ebp-24]

left_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    mov esi, eax
    mov edi, ebx
    call get_pixel
    cmp bl, 0
    jne up_right_frame
    call cd
    dec DWORD[ebp-8]
    jmp left_loop

up_right_frame:
    mov ebx, [ebp-8]
    mov [ebp-40], ebx
    mov ebx, [ebp-20]
    mov [ebp-8], ebx
    inc DWORD[ebp-12]

urf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-40]
    je go_down
    cmp eax, HEIGHT
    je go_down_border
    call get_pixel
    cmp bl, 0
    je not_found
    dec DWORD[ebp-8]
    jmp urf_loop

go_down_border:
    mov ebx, [ebp-40]
    mov [ebp-8], ebx
go_down:
    inc DWORD[ebp-8]
    dec DWORD[ebp-12]
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    mov [ebp-44], eax
    mov esi, [ebp-20]
    sub esi, [ebp-8]
    mov [ebp-48], esi
    mov edi, [ebp-24]
    add edi, [ebp-48]
    mov [ebp-52], edi

down_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-52]
    je up_left_frame
    call get_pixel
    cmp bl, 0
    jne not_found
    dec DWORD[ebp-12]
    jmp down_loop

up_left_frame:
    dec DWORD[ebp-8]
    mov eax, [ebp-44]
    mov [ebp-12], eax
ulf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-52]
    je left_again
    call get_pixel
    cmp bl, 0
    je not_found
    dec DWORD[ebp-12]
    jmp ulf_loop

left_again:
    mov [ebp-56], ebx
la_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-36]
    je la_frame
    call get_pixel
    cmp bl, 0
    jne not_found
    dec DWORD[ebp-8]
    jmp la_loop

la_frame:
    inc DWORD[ebp-12]
    mov ebx, [ebp-56]
    mov [ebp-8], ebx
laf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-36]
    je down_again
    call get_pixel
    cmp bl, 0
    je not_found
    dec DWORD[ebp-8]
    jmp laf_loop

down_again:
    dec DWORD[ebp-12]
    mov eax, [ebp-12]
    mov [ebp-60], eax
da_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-24]
    je da_frame
    call get_pixel
    cmp bl, 0
    jne not_found
    mov edi, [ebp-8]
    mov esi, [ebp-12]
    mov edx, [ebp-20]
    sub edx, [ebp-48]
    mov [ebp-64], edx
    call cr
    dec DWORD[ebp-12]
    jmp da_loop


cr:
    push ebp
    mov ebp, esp
    push eax
    push ebx

cr_loop:
    inc edi
    mov ebx, edi
    mov eax, esi
    cmp ebx, edx
    je end_cr
    call get_pixel
    cmp bl, 0
    jne not_found_cr
    jmp cr_loop


end_cr:
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret


not_found_cr:
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    add esp, 4
    jmp not_found
da_frame:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, 0
    je marker_found
    mov eax, [ebp-60]
    mov [ebp-12], eax
    dec DWORD[ebp-8]
daf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-24]
    je marker_found
    call get_pixel
    cmp bl, 0
    je not_found
    dec DWORD[ebp-12]
    jmp daf_loop

marker_found:
    inc DWORD[ebp-4]
    mov eax, [ebp-68]
    mov ebx, [ebp-20]
    mov DWORD[eax], ebx
    add DWORD[ebp-68], 4
    add eax, 4
    mov ebx, 239
    sub ebx, [ebp-24]
    mov DWORD[eax], ebx
    add DWORD[ebp-68], 4
    add eax, 4
    jmp not_found

not_found:
    inc DWORD[ebp-20]
    mov eax, [ebp-20]
    mov [ebp-8], eax
    mov eax, [ebp-24]
    mov [ebp-12], eax
    mov DWORD[ebp-16], 0 ;bottom length
    mov DWORD[ebp-20], 0 ;return x cord
    mov DWORD[ebp-24], 0 ;return y cord
    mov DWORD[ebp-28], 0 ;height
    mov DWORD[ebp-32], 0 ;saved y cord
    mov DWORD[ebp-36], 0 ;left x cord
    mov DWORD[ebp-40], 0 ; saved x cord in urf
    mov DWORD[ebp-44], 0 ;saved y cord in down loop
    mov DWORD[ebp-48], 0 ; arm_width
    mov DWORD[ebp-52], 0 ; a point at which the inner arms should intersect
    mov DWORD[ebp-56], 0 ; saved x cord in left again
    mov DWORD[ebp-60], 0 ; saved y cord in da
    mov DWORD[ebp-64], 0 ; x cord of inner intersection
    jmp find_black


cd:
    push ebp
    mov ebp, esp
    push eax
    push ebx
cd_loop:
    dec esi
    mov ebx, edi
    mov eax, esi
    cmp eax, edx
    je end_cd
    call get_pixel
    cmp bl, 0
    jne not_found_cd
    jmp cd_loop

end_cd:
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret

not_found_cd:
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    add esp, 4
    jmp not_found


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
    mov eax, [ebp-4]
    pop edx
    pop esi
    pop edi
    pop ebx
    mov esp, ebp
    pop ebp
    ret
