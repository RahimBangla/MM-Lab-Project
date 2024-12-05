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
    is_24_hour db 1  ; 1 for 24-hour, 0 for 12-hour
    
    input_buffer db 7  ; Buffer size
                db ?   ; Actual chars read
                db 7 dup(?) ; Buffer for HHMMSS
    hours db 0, 0  ; Hours
    minutes db 0, 0  ; Minutes
    seconds db 0, 0  ; Seconds
    old_seconds db 0 ; Store previous seconds value

.code
main proc
    mov ax, @data
    mov ds, ax

menu_loop:
    ; Display menu
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

    ; Prompt for choice
    lea dx, newline
    mov ah, 9
    int 21h

    lea dx, prompt
    mov ah, 9
    int 21h

    ; Get user choice
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
    ; Clear screen
    mov ax, 3
    int 10h
    
    ; Get initial seconds
    mov ah, 2Ch
    int 21h
    mov old_seconds, dh
    
view_clock_loop:
    ; Move cursor to top
    mov ah, 2
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h
    
    ; Get current time
    mov ah, 2Ch
    int 21h
    
    ; Compare with old seconds
    cmp dh, old_seconds
    je check_key  ; If same second, don't update display
    
    mov old_seconds, dh  ; Store new seconds
    call display_clock
    
check_key:
    ; Check for ESC key
    mov ah, 1
    int 16h
    jz view_clock_loop
    
    mov ah, 0
    int 16h
    cmp al, 27  ; ESC key
    jne view_clock_loop
    
    jmp menu_loop

set_clock:
    call set_time
    jmp menu_loop

toggle_format:
    not is_24_hour  ; Toggle between 0 and 1
    jmp menu_loop

invalid_choice:
    lea dx, invalid_input
    mov ah, 9
    int 21h
    jmp menu_loop

main endp

display_clock proc
    ; Get system time
    mov ah, 2Ch
    int 21h    ; CH=hour(0-23), CL=minute(0-59), DH=second(0-59)
    
    ; Convert hours
    mov al, ch
    cmp is_24_hour, 1
    je convert_hours
    
    ; Convert to 12-hour format
    cmp al, 12
    jl am_time
    mov am_pm[1], 'P'  ; Set PM
    cmp al, 12
    je convert_hours
    sub al, 12
    jmp am_time
    
am_time:
    mov am_pm[1], 'A'  ; Set AM
    cmp al, 0
    jne convert_hours
    mov al, 12

convert_hours:    
    aam
    add ax, 3030h
    mov time_str[0], ah
    mov time_str[1], al
    
    ; Convert minutes
    mov al, cl
    aam
    add ax, 3030h
    mov time_str[3], ah
    mov time_str[4], al
    
    ; Convert seconds  
    mov al, dh
    aam
    add ax, 3030h
    mov time_str[6], ah
    mov time_str[7], al

    ; Display current time label
    lea dx, current_time
    mov ah, 9
    int 21h
    
    ; Display time
    lea dx, time_str
    mov ah, 9
    int 21h
    
    ; Display AM/PM if in 12-hour mode
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

    ; Read HHMMSS into buffer
    mov ah, 0Ah
    lea dx, input_buffer
    int 21h

    ; Convert and store hours
    mov al, input_buffer[2]  ; First hour digit
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, input_buffer[3]  ; Second hour digit
    sub bl, '0'
    add al, bl
    mov hours[0], al

    ; Convert and store minutes
    mov al, input_buffer[4]  ; First minute digit
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, input_buffer[5]  ; Second minute digit
    sub bl, '0'
    add al, bl
    mov minutes[0], al

    ; Convert and store seconds
    mov al, input_buffer[6]  ; First second digit
    sub al, '0'
    mov bl, 10
    mul bl
    mov bl, input_buffer[7]  ; Second second digit
    sub bl, '0'
    add al, bl
    mov seconds[0], al

    ret
set_time endp

update_time proc
    ; Logic to increment seconds, minutes, and hours
    inc seconds[1]
    cmp seconds[1], 10
    jl no_minute_carry

    ; Seconds carry
    mov seconds[1], 0
    inc seconds[0]
    cmp seconds[0], 6
    jl no_minute_carry
    mov seconds[0], 0
    inc minutes[1]

no_minute_carry:
    cmp minutes[1], 10
    jl no_hour_carry

    ; Minutes carry
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
