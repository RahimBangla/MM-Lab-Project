INCLUDE 'EMU8086.INC'
.model small
.stack 100h

.data
    menu db '1. View Clock$', 0
    menu2 db '2. Set Clock$', 0
    prompt db 'Enter your choice: $', 0
    set_prompt db 'Enter HHMMSS (24-hour format): $', 0
    invalid_input db 'Invalid Input!$', 0
    current_time db 'Current Time: $', 0
    time_str db '00:00:00$', 0
    newline db 13, 10, '$', 0

    hours db 0, 0  ; Hours
    minutes db 0, 0  ; Minutes
    seconds db 0, 0  ; Seconds

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
    jmp invalid_choice

view_clock:
    call display_clock
    jmp menu_loop

set_clock:
    call set_time
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
    
    ret
display_clock endp

set_time proc
    lea dx, newline
    mov ah, 9
    int 21h

    lea dx, set_prompt
    mov ah, 9
    int 21h

    ; Read HHMMSS
    mov ah, 0Ah
    lea dx, hours
    int 21h

    ; Validation skipped for simplicity
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
