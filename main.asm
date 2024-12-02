ORG 100h

; Macro to print a character
PRINT_CHAR MACRO CHAR
    MOV AH, 0Eh
    MOV AL, CHAR
    INT 10h
ENDM

START:
    ; Set cursor to top-left position (row 0, column 0)
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 00h
    MOV DL, 00h
    INT 10h

CLOCK_LOOP:
    ; Get system time
    MOV AH, 2Ch
    INT 21h

    ; Set cursor to top-left position again
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 00h
    MOV DL, 00h
    INT 10h

    ; Print Hours
    MOV AL, CH         ; Load hours into AL
    CALL PRINT_TWO_DIGITS
    PRINT_CHAR ':'     ; Print colon separator

    ; Print Minutes
    MOV AL, CL         ; Load minutes into AL
    CALL PRINT_TWO_DIGITS
    PRINT_CHAR ':'     ; Print colon separator

    ; Print Seconds
    MOV AL, DH         ; Load seconds into AL
    CALL PRINT_TWO_DIGITS
    PRINT_CHAR '.'     ; Print decimal separator

    ; Print Hundredths of a Second
    MOV AL, DL         ; Load hundredths of a second into AL
    CALL PRINT_TWO_DIGITS

    ; Small delay to control update frequency
    MOV CX, 0FFFFh
DELAY_LOOP:
    LOOP DELAY_LOOP

    JMP CLOCK_LOOP     ; Repeat the loop

; Subroutine to print two digits
PRINT_TWO_DIGITS PROC
    MOV AH, 0
    AAM                 ; ASCII Adjust AX after division by 10
    ADD AX, 3030h       ; Convert to ASCII
    MOV DL, AH          ; High digit
    PRINT_CHAR DL       ; Print high digit
    MOV DL, AL          ; Low digit
    PRINT_CHAR DL       ; Print low digit
    RET
PRINT_TWO_DIGITS ENDP

RET
