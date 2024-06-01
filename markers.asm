

section .text
global markers
markers:
    push ebp
    mov ebp, esp
    sub esp, 92
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
    mov DWORD[ebp-28], 0 ;height of marker
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
    mov DWORD[ebp-68], eax ;address of output_x buffer
    mov eax, [ebp+16]
    mov DWORD[ebp-72], eax ;address of output_x buffer
    mov DWORD[ebp-76], 0 ;heigth of image
    mov DWORD[ebp-80], 0 ;width of image
    mov DWORD[ebp-84], 0 ;right border
    mov DWORD[ebp-88], 0 ;bottom border
    mov DWORD[ebp-92], 0 ;bytes per row
    jmp get_info
    jmp find_black
    jmp exit

get_info:
    xor eax, eax
    mov ecx, DWORD[ebp+8]  ;load [ebp-80]
    mov al, BYTE[ecx+19]
    shl eax, 8
    mov al, BYTE[ecx+18]
    mov DWORD[ebp-80], eax
    xor eax, eax
    mov al, BYTE[ecx+23] ;load heigth
    shl eax, 8
    mov al, BYTE[ecx+22]
    mov DWORD[ebp-76], eax
    xor eax, eax
    mov al, BYTE[ecx+11] ;data offset
    shl eax, 8
    mov al, BYTE[ecx+10]
    add ecx, eax ;first pixel
    mov eax, DWORD[ebp-80] ;right
    sub eax, 1
    mov DWORD[ebp-84], eax ;right border
    mov eax, DWORD[ebp-76]
    sub eax, 1
    mov DWORD[ebp-88], eax ;top border
    mov eax, DWORD[ebp-80]
    imul eax, 24 ; calculatirng byter per pixel  - 3*8*[ebp-80] - Bitperpixel*[ebp-80]
    add eax, 31  ; Bitperpixel*[ebp-80]+31
    push ecx
    xor edx, edx
    mov ecx, 32
    div ecx ; (Bitperpixel*[ebp-80]+31) /32
    shl eax, 2 ; (Bitperpixel*[ebp-80]+31) /32 *4
    mov DWORD[ebp-92], eax
    pop ecx


find_black:
    mov eax, [ebp-12] ;load eax with y cord
    mov ebx, [ebp-8] ;load ebx with x cord
    cmp ebx, [ebp-80] ;check if reached right border
    je next_row ;if so go one row up
    call get_pixel ;check pixel under current ebx, eax coords
    cmp bl, 0 ;check if its black
    je go_right ;if so go right
    inc DWORD[ebp-8] ;go to the right
    jmp find_black

next_row:
    inc DWORD[ebp-12] ;inc y coord
    mov DWORD[ebp-8], 0 ;reset x cord
    mov eax, [ebp-12]
    cmp eax, [ebp-76] ;if reached the top exit
    je exit
    jmp find_black

go_right:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-80]
    je end_right ;if right border end_right
    call get_pixel
    cmp bl, 0
    jne end_right ;if pixel not black  end_right
    inc DWORD[ebp-16] ;inc length counter
    inc DWORD[ebp-8] ;go right
    jmp go_right


end_right:
    dec DWORD[ebp-8] ;move one to the left
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    mov [ebp-20], ebx ;save return x and y coords
    mov [ebp-24], eax
bottom_frame:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, 0 ;if we are at the bottom end bf
    je end_bf
    sub ebx, [ebp-16]
    inc ebx
    mov [ebp-8], ebx
    dec DWORD[ebp-12]
b_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-20]
    jg end_bf ;if we reached the return x cord
    call get_pixel
    cmp bl, 0
    je not_found ;if pixel is black not found
    inc DWORD[ebp-8]
    jmp b_loop


end_bf:
    mov ebx, [ebp-20] ;change x and y coords to return values
    mov eax, [ebp-24]
    mov [ebp-8], ebx
    mov [ebp-12], eax
    mov edi, [ebp-16]
    test edi, 1
    jnz not_found ;if length is not an even number not found
    shr edi, 1 ;divide length by 2
    jmp go_up



go_up:
    inc DWORD[ebp-28] ; inc [ebp-76] counter
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    call get_pixel
    cmp bl, 0
    jne not_found ; if pixel not black go not found
    cmp [ebp-28], edi ; check if
    je end_up
    inc DWORD[ebp-12]
    jmp go_up


end_up:
    inc DWORD[ebp-12] ; go one row up
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-76] ; check if we are at top, if so just go left
    je go_left
    mov [ebp-32], eax ; save y cord
    call get_pixel ;check if pixel above is black
    cmp bl, 0
    je not_found ;if its black not found
    mov ebx, [ebp-8]
    cmp ebx, [ebp-84] ; if we are at the right border go left
    je go_left
    jmp right_frame

right_frame:
    mov eax, [ebp-24] ;load saved t5 value into a1
    mov [ebp-12], eax
    inc DWORD[ebp-8] ;increment x coordinate by 1

rf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-32]
    je end_rf ;if y coordinate equal to saved a5, end right frame
    call get_pixel ;get color of pixel at a0,a1
    inc DWORD[ebp-12] ;go one row up
    cmp bl, 0 ;if pixel is black, not found
    je not_found
    jmp rf_loop

end_rf:
    dec DWORD[ebp-8] ;dec x coord
    jmp go_left


go_left:
    dec DWORD[ebp-12] ;dec row by one
    shl edi, 1 ;bottom length
    mov esi, [ebp-8]
    sub esi, edi ;main_X - bl
    inc esi ;correction
    mov [ebp-36], esi
    shr edi, 1 ;divide s6 by 2
    mov edx, [ebp-24]

left_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-36] ;not square
    jle not_found
    mov esi, eax
    mov edi, ebx
    call get_pixel
    cmp bl, 0
    jne up_right_frame ;if not black, check ur frame
    call cd ;check if all the pixels beneath the current one are black as well
    dec DWORD[ebp-8] ;go left
    jmp left_loop

up_right_frame:
    mov ebx, [ebp-8]  ;load x and y with saved cords
    mov [ebp-40], ebx
    mov ebx, [ebp-20]
    mov [ebp-8], ebx
    inc DWORD[ebp-12] ;go one row up

urf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-40] ;if reached end of urf, go down
    je go_down
    cmp eax, [ebp-76]
    je go_down_border
    call get_pixel ;if pixel is black, not found
    cmp bl, 0
    je not_found
    dec DWORD[ebp-8] ;go left
    jmp urf_loop

go_down_border:
    mov ebx, [ebp-40]
    mov [ebp-8], ebx
go_down:
    inc DWORD[ebp-8] ;correct x coord
    dec DWORD[ebp-12] ;correct y coord
    mov ebx, [ebp-8] ;save y cord
    mov eax, [ebp-12]
    mov [ebp-44], eax
    mov esi, [ebp-20]
    sub esi, [ebp-8]
    mov [ebp-48], esi
    mov edi, [ebp-24]
    add edi, [ebp-48]
    mov [ebp-52], edi ;a point at which inner arms should intersect

down_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-52]
    je up_left_frame ;if that point is reached, go to ulf
    call get_pixel
    cmp bl, 0 ;if pixel not black, not found
    jne not_found
    dec DWORD[ebp-12] ;go down
    jmp down_loop

up_left_frame:
    dec DWORD[ebp-8] ;go left
    mov eax, [ebp-44]
    mov [ebp-12], eax ;load previous y value
ulf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-52]
    je left_again ;it reached intersection point, go left again
    call get_pixel
    cmp bl, 0
    je not_found ;if pixel is black, not found
    dec DWORD[ebp-12] ; go down
    jmp ulf_loop

left_again:
    mov [ebp-56], ebx ;save x coord
la_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-36]
    je la_frame ;if it reached the left border, got o laframe
    call get_pixel
    cmp bl, 0 ;if pixel not black, not found
    jne not_found
    dec DWORD[ebp-8] ;go left
    jmp la_loop

la_frame:
    inc DWORD[ebp-12] ;go one row up
    mov ebx, [ebp-56] ;load previously saved x coord
    mov [ebp-8], ebx
laf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp ebx, [ebp-36]
    je down_again ;if reached left border, go down again
    call get_pixel
    cmp bl, 0
    je not_found ;if the pixel is black, not found
    dec DWORD[ebp-8] ;go left
    jmp laf_loop

down_again:
    dec DWORD[ebp-12] ;correct y cord
    mov eax, [ebp-12]
    mov [ebp-60], eax ;save y cord
da_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-24]
    je da_frame ;if reached bottom, down_again frame
    call get_pixel
    cmp bl, 0 ;if pixel is not zero, not found
    jne not_found
    mov edi, [ebp-8]
    mov esi, [ebp-12]
    mov edx, [ebp-20]
    sub edx, [ebp-48]
    mov [ebp-64], edx
    call cr   ; check if all the pixels right of the current one, until the intersection are black
    dec DWORD[ebp-12] ; go down
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
    cmp ebx, edx ;check if reached intersection line
    je end_cr
    call get_pixel_from_inside
    cmp bl, 0 ;not black, not found
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
    je marker_found ;we are at the left border, marker found
    mov eax, [ebp-60]
    mov [ebp-12], eax
    dec DWORD[ebp-8] ;correct x cord
daf_loop:
    mov ebx, [ebp-8]
    mov eax, [ebp-12]
    cmp eax, [ebp-24]
    je marker_found ;if reached bottom, marker found
    call get_pixel
    cmp bl, 0
    je not_found ;if pixel is black, not found
    dec DWORD[ebp-12] ;go down
    jmp daf_loop

marker_found:
    inc DWORD[ebp-4]
    mov eax, [ebp-68]
    mov ebx, [ebp-20]
    mov DWORD[eax], ebx
    add DWORD[ebp-68], 4
    add eax, 4
    mov ebx, DWORD[ebp-88]
    sub ebx, [ebp-24]
    mov eax, [ebp-72]
    mov DWORD[eax], ebx
    add DWORD[ebp-72], 4
    add eax, 4
    jmp not_found

not_found:
    inc DWORD[ebp-20] ;go one pixel to the left on the saved ones
    mov eax, [ebp-20]
    mov [ebp-8], eax
    mov eax, [ebp-24]
    mov [ebp-12], eax
    mov DWORD[ebp-16], 0 ;bottom length
    mov DWORD[ebp-20], 0 ;return x cord
    mov DWORD[ebp-24], 0 ;return y cord
    mov DWORD[ebp-28], 0 ;[ebp-76]
    mov DWORD[ebp-32], 0 ;saved y cord
    mov DWORD[ebp-36], 0 ;left x cord
    mov DWORD[ebp-40], 0 ; saved x cord in urf
    mov DWORD[ebp-44], 0 ;saved y cord in down loop
    mov DWORD[ebp-48], 0 ; arm_[ebp-80]
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
    je end_cd ;if reached bottom of the marker, end cd
    call get_pixel_from_inside
    cmp bl, 0 ;if pixel not black, not found
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
    imul eax, [ebp+24] ; t = y*bytes per row
    imul ebx, 3
    add eax, ebx ; t+= 3*x
    add eax, ecx ; add first pixel address
    mov ebx, 0
    add bl, BYTE[eax] ;add R,G and B and if the pixel is not black, the value of bl will not be 0 after the function
    inc eax
    add bl, BYTE[eax]
    inc eax
    add bl, BYTE[eax]
    inc eax
    mov esp, ebp
    pop ebp
    ret

get_pixel_from_inside:
    push ebp
    mov ebp, esp
    imul eax, [ebp+40] ; t = y*bytes per row
    imul ebx, 3
    add eax, ebx ; t+= 3*x
    add eax, ecx ; add first pixel address
    mov ebx, 0
    add bl, BYTE[eax] ;add R,G and B and if the pixel is not black, the value of bl will not be 0 after the function
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
