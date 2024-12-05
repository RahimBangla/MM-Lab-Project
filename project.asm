INCLUDE 'EMU8086.INC'
.model small
.stack 100h

.data
    menu db '1. View Clock$', 0
    menu2 db '2. Set Clock$', 0
    menu3 db '3. Toggle 12/24 Hour Format$', 0
    prompt db 'Enter your choice: $', 0
    set_prompt db 'Enter HHMMSS (24-hour format): $', 0
    invalid_input db 'Invalid Input!$', 0
    current_time db 'Current Time: $', 0
    time_str db '00:00:00$', 0
    newline db 13, 10, '$', 0
    am_pm db ' AM$', 0
    is_24_hour db 1
    
    input_buffer db 7
                db ?
                db 7 dup(?)
    hours db 0, 0
    minutes db 0, 0
    seconds db 0, 0
    old_seconds db 0

.code
main proc
    mov ax, @data
    mov ds, ax

menu_loop:
    lea dx, newline
    mov ah, 9
    int 21h

    lea dx, menu
    mov ah, 9
    int 21h

    lea dx, newline
    mov ah, 9
    int 21h

    lea dx, menu2
    mov ah, 9
    int 21h

    lea dx, newline
    mov ah, 9
    int 21h

    lea dx, menu3
    mov ah, 9
    int 21h

    lea dx, newline
    mov ah, 9
    int 21h

    lea dx, prompt
    mov ah, 9
    int 21h

    mov ah, 1
    int 21h
    cmp al, '1'
    je view_clock
    cmp al, '2'
    je set_clock
    cmp al, '3'
    je toggle_format
    jmp invalid_choice

view_clock:
    mov ax, 3
    int 10h
    
    mov ah, 2Ch
    int 21h
    mov old_seconds, dh
    
view_clock_loop:
    mov ah, 2
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h
    
    mov ah, 2Ch
    int 21h
    
    cmp dh, old_seconds
    je check_key
    
    mov old_seconds, dh
    call display_clock
    
check_key:
    mov ah, 1
    int 16h
    jz view_clock_loop
    
    mov ah, 0
    int 16h
    cmp al, 27
    jne view_clock_loop
    
    jmp menu_loop

set_clock:
    call set_time
    jmp menu_loop

toggle_format:
    not is_24_hour
    jmp menu_loop

invalid_choice:
    lea dx, invalid_input
    mov ah, 9
    int 21h
    jmp menu_loop

main endp

display_clock proc
    mov ah, 2Ch
    int 21h
    
    mov al, ch
    cmp is_24_hour, 1
    je convert_hours
    
    cmp al, 12
    jl am_time
    mov am_pm[1], 'P'
    cmp al, 12
    je convert_hours
    sub al, 12
    jmp am_time
    
am_time:
    mov am_pm[1], 'A'
    cmp al, 0
    jne convert_hours
    mov al, 12

convert_hours:    
    aam
    add ax, 3030h
    mov time_str[0], ah
    mov time_str[1], al
    
    mov al, cl
    aam
    add ax, 3030h
    mov time_str[3], ah
    mov time_str[4], al
    
    mov al, dh
    aam
    add ax, 3030h
    mov time_str[6], ah
    mov time_str[7], al

    lea dx, current_time
    mov ah, 9
    int 21h
    
    lea dx, time_str
    mov ah, 9
    int 21h
    
    cmp is_24_hour, 0
    jne skip_ampm
    lea dx, am_pm
    mov ah, 9
    int 21h
    
skip_ampm:
    ret
display_clock endp

set_time proc
    lea dx, newline
    mov ah, 9
    int 21h

    lea dx, set_prompt
    mov ah, 9
    int 21h

    mov ah, 0Ah
    lea dx, input_buffer
    int 21h

    mov al, input_buffer[2]
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, input_buffer[3]
    sub bl, '0'
    add al, bl
    mov hours[0], al

    mov al, input_buffer[4]
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, input_buffer[5]
    sub bl, '0'
    add al, bl
    mov minutes[0], al

    mov al, input_buffer[6]
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, input_buffer[7]
    sub bl, '0'
    add al, bl
    mov seconds[0], al

    ret
set_time endp

update_time proc
    inc seconds[1]
    cmp seconds[1], 10
    jl no_minute_carry

    mov seconds[1], 0
    inc seconds[0]
    cmp seconds[0], 6
    jl no_minute_carry
    mov seconds[0], 0
    inc minutes[1]

no_minute_carry:
    cmp minutes[1], 10
    jl no_hour_carry

    mov minutes[1], 0
    inc minutes[0]
    cmp minutes[0], 6
    jl no_hour_carry
    mov minutes[0], 0
    inc hours[1]

no_hour_carry:
    cmp hours[1], 10
    jl continue_update
    mov hours[1], 0
    inc hours[0]

continue_update:
    cmp hours[0], 2
    jl ret_update
    cmp hours[1], 4
    jl ret_update
    mov hours[0], 0
    mov hours[1], 0

ret_update:
    ret
update_time endp

end main
