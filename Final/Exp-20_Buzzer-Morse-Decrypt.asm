ORG 00H
; INITIALIZE SERIAL COMMUNICATION
MOV TMOD,#20H ;Timer 1, mode 2 ; 0010 0000 ;  8 bit auto reload
MOV TH1,#0FDH ;9600 baud rate
MOV SCON,#50H; 8 bit data,1 stop bit, 1 start bit, REN enabled ; 0101 0000 
CLR T1 ; Clear Timer 1 register
SETB TR1 ;start timer 1

;PIN CONFIGURATION
LED_1     BIT P1.0 ; the buffer port is port 1. 
LED_2     BIT P1.1
LED_3     BIT P1.2
LED_4     BIT P1.3
LED_5     BIT P1.4
LED_6     BIT P1.5
LED_7     BIT P1.6
LED_8     BIT P1.7
LED_RELAY BIT P3.5
MOTOR     BIT P3.6
BUZZER    BIT P3.7

CLR  LED_1
CLR  LED_2
CLR  LED_3
CLR  LED_4
CLR  LED_5
CLR  LED_6
CLR  LED_7
CLR  LED_8
SETB LED_RELAY
CLR MOTOR

RS   EQU P3.4
RW   EQU P3.3
ENBL EQU P3.2

;SEND DATA FROM MICROCONTROLLER TO SMARTPHONE 
MOV DPTR, #MYDATA 
GO: 
    CLR A    
    MOVC A,@A+DPTR
    JZ LCD ; LCD Subroutine
    ACALL SEND
    SJMP GO

SEND:
    MOV SBUF, A 
    INC DPTR
    HERE: JNB TI, HERE ;wait for the last bit to transfer
    CLR TI ;clear TI for the next INPUT
    RET

;MAKING THE LCD READY FOR DISPLAYING DATA FROM SMARTPHONE

; LCD Sub routine
LCD: 
    MOV SP,#70H ; 112D of ROM
    MOV PSW,#00H

MOV A,#38H ;LCD 2 lines,5 by 7 matrix
LCALL COMMAND ;call command subroutine
LCALL DELAY ;give LCD some time

MOV A,#0EH ;display on, cursor on
LCALL COMMAND
LCALL DELAY

WELCOME:
MOV 32H, #16
LCALL CLEAR_LCD

MOV A,#06H ;shift cursor right
LCALL COMMAND
LCALL DELAY

MOV A,#80H ;force cursor to begin at 1st line
LCALL COMMAND
LCALL DELAY

    ;DISPLAY WELCOME MESSAGE
    LCALL DELAY
    ; Display the MYDATA string
    MOV DPTR, #MYDATA ; Load the address of the string
    LOOP_1 : CLR A
    MOVC A,@A+DPTR
    JZ FINISH
    LCALL DISPLAY
    LCALL DELAY
    INC DPTR
    LJMP LOOP_1

FINISH: 
    LJMP SMARTPHONE

MSG_A: DB ".-",0
MSG_B: DB "-...",0
MSg_C: DB "-.-.",0
MSG_D: DB "-..", 0
MSG_E: DB ".", 0
MSG_F: DB "..-.", 0
MSG_G: DB "--.", 0
MSG_H: DB "....", 0
MSG_I: DB "..", 0
MSG_J: DB ".---", 0
MSG_K: DB "-.-", 0
MSG_L: DB ".-..", 0
MSG_M: DB "--", 0
MSG_N: DB "-.", 0
MSG_O: DB "---", 0
MSG_P: DB ".--.", 0
MSG_Q: DB "--.-", 0
MSG_R: DB ".-.", 0
MSG_S: DB "...", 0
MSG_T: DB "-", 0
MSG_U: DB "..-", 0
MSG_V: DB "...-", 0
MSG_W: DB ".--", 0
MSG_X: DB "-..-", 0
MSG_Y: DB "-.--", 0
MSG_Z: DB "--..", 0

MYDATA: DB "Group 03, Bluetooth Interfacing",0 ; this data is shown from virtual terminal

;COMMAND FROM THE SMARTPHONE
SMARTPHONE:
    MOV A, "H"
    LCALL TRANS

    TRANS: 
    MOV SBUF, A

    MOV 32H, #16
    LCALL CLEAR_LCD

INPUT_NEW: 
    LCALL GENERAL_INPUT

    MOV A, SBUF ;save incoming byte in A
    CJNE A,#'1', LED_1_OFF
    SETB LED_1;turn on the LED
    LJMP INPUT_NEW ;print the INPUT_NEW_NEWacter pressed


LED_1_OFF: 
    MOV A,SBUF
    CJNE A,#'2', LED_2_OFF
    SETB LED_2 ;turn ofF the LED
    LJMP INPUT_NEW 

LED_2_OFF: 
    MOV A,SBUF
    CJNE A,#'3', LED_3_OFF
    SETB LED_3 
    LJMP INPUT_NEW

LED_3_OFF : 
    MOV A,SBUF
    CJNE A,#'4', LED_4_OFF
    SETB LED_4 
    LJMP INPUT_NEW

LED_4_OFF: 
    MOV A,SBUF
    CJNE A,#'5',LED_5_OFF
    SETB LED_5 
    LJMP INPUT_NEW 

LED_5_OFF: 
    MOV A,SBUF
    CJNE A,#'6',LED_6_OFF
    SETB LED_6 
    LJMP INPUT_NEW 

LED_6_OFF: 
    MOV A,SBUF
    CJNE A,#'7',LED_7_OFF
    SETB LED_7 
    LJMP INPUT_NEW 

LED_7_OFF: 
    MOV A,SBUF
    CJNE A,#'8',LED_8_OFF
    SETB LED_8 
    LJMP INPUT_NEW 

LED_8_OFF: 
    MOV A,SBUF
    CJNE A,#'!',TURN_ON_RELAY
    CLR LED_1 
    LJMP INPUT_NEW 

TURN_ON_RELAY: 
    MOV A,SBUF
    CJNE A,#'9',TURN_OFF_RELAY
    CLR LED_RELAY 
    LJMP INPUT_NEW 

TURN_OFF_RELAY: 
    MOV A,SBUF
    CJNE A,#'(', NOT_TURN_OFF_RELAY
    SETB LED_RELAY 
    LJMP INPUT_NEW     

NOT_TURN_OFF_RELAY: ; TURN ON MOTOR
    MOV A,SBUF
    CJNE A,#'+', NOT_TURN_ON_MOTOR
    SETB MOTOR    
    LJMP INPUT_NEW   

NOT_TURN_ON_MOTOR: ; TURN OFF MOTOR
    MOV A,SBUF
    CJNE A,#'=', NOT_TURN_OFF_MOTOR
    CLR MOTOR
    LJMP INPUT_NEW  

NOT_TURN_OFF_MOTOR:
    MOV A,SBUF
    CJNE A, #'"' , NOT_TURN_ON_BUZZER
    CLR BUZZER
    LJMP INPUT_NEW

NOT_TURN_ON_BUZZER:
    MOV A, SBUF
    CJNE A, #':' , NOT_TURN_OFF_BUZZER
    SETB BUZZER
    LJMP INPUT_NEW

NOT_TURN_OFF_BUZZER:


LED_1_ON: 
    MOV A, SBUF
    CJNE A,#'@',LED_2_ON
    CLR LED_2 
    LJMP INPUT_NEW 

LED_2_ON: 
    MOV A, SBUF
    CJNE A,#'#',LED_3_ON
    CLR LED_3 
    LJMP INPUT_NEW 

LED_3_ON: 
    MOV A, SBUF
    CJNE A,#'$',LED_4_ON
    CLR LED_4 
    LJMP INPUT_NEW 

LED_4_ON: 
    MOV A, SBUF
    CJNE A,#'%',LED_5_ON
    CLR LED_5 
    LJMP INPUT_NEW 

LED_5_ON: 
    MOV A, SBUF
    CJNE A,#'^',LED_6_ON
    CLR LED_6 
    LJMP INPUT_NEW 

LED_6_ON: 
    MOV A, SBUF
    CJNE A,#'&',LED_7_ON
    CLR LED_7 
    LJMP INPUT_NEW 

LED_7_ON: 
    MOV A, SBUF
    CJNE A,#'*',CHECK_A
    CLR LED_8
    LJMP INPUT_NEW 

CHECK_A:
    MOV A, SBUF
    CJNE A,#'A' , NOT_A  ; Jump if not equal to "A"
    MOV DPTR, #MSG_A
    LJMP DISPLAY_MORSE ; Display Morse code for "A"
     
NOT_A:
    MOV A, SBUF
    CJNE A, #'B', NOT_B
    MOV DPTR, #MSG_B
    LJMP DISPLAY_MORSE

NOT_B:
    MOV A, SBUF
    CJNE A, #'C', NOT_C
    MOV DPTR, #MSG_C
    LJMP DISPLAY_MORSE   

NOT_C:
    MOV A, SBUF
    CJNE A, #'D', NOT_D 
    MOV DPTR, #MSG_D
    LJMP DISPLAY_MORSE 

NOT_D:
    MOV A, SBUF
    CJNE A, #'E', NOT_E
    MOV DPTR, #MSG_E
    LJMP DISPLAY_MORSE

NOT_E:
    MOV A, SBUF
    CJNE A, #'F', NOT_F
    MOV DPTR, #MSG_F
    LJMP DISPLAY_MORSE

NOT_F:
    MOV A, SBUF
    CJNE A, #'G', NOT_G
    MOV DPTR, #MSG_G
    LJMP DISPLAY_MORSE

NOT_G:
    MOV A, SBUF
    CJNE A, #'H', NOT_H
    MOV DPTR, #MSG_H
    LJMP DISPLAY_MORSE

NOT_H:
    MOV A, SBUF
    CJNE A, #'I', NOT_I
    MOV DPTR, #MSG_I
    LJMP DISPLAY_MORSE

NOT_I:
    MOV A, SBUF
    CJNE A, #'J', NOT_J
    MOV DPTR, #MSG_J
    LJMP DISPLAY_MORSE

NOT_J:
    MOV A, SBUF
    CJNE A, #'K', NOT_K
    MOV DPTR, #MSG_K
    LJMP DISPLAY_MORSE

NOT_K:
    MOV A, SBUF
    CJNE A, #'L', NOT_L
    MOV DPTR, #MSG_L
    LJMP DISPLAY_MORSE

NOT_L:
    MOV A, SBUF
    CJNE A, #'M', NOT_M
    MOV DPTR, #MSG_M
    LJMP DISPLAY_MORSE

NOT_M:
    MOV A, SBUF
    CJNE A, #'N', NOT_N
    MOV DPTR, #MSG_N
    LJMP DISPLAY_MORSE

NOT_N:
    MOV A, SBUF
    CJNE A, #'O', NOT_O
    MOV DPTR, #MSG_O
    LJMP DISPLAY_MORSE

NOT_O:
    MOV A, SBUF
    CJNE A, #'P', NOT_P
    MOV DPTR, #MSG_P
    LJMP DISPLAY_MORSE

NOT_P:
    MOV A, SBUF
    CJNE A, #'Q', NOT_Q
    MOV DPTR, #MSG_Q
    LJMP DISPLAY_MORSE

NOT_Q:
    MOV A, SBUF
    CJNE A, #'R', NOT_R
    MOV DPTR, #MSG_R
    LJMP DISPLAY_MORSE

NOT_R:
    MOV A, SBUF
    CJNE A, #'S', NOT_S
    MOV DPTR, #MSG_S
    LJMP DISPLAY_MORSE

NOT_S:
    MOV A, SBUF
    CJNE A, #'T', NOT_T
    MOV DPTR, #MSG_T
    LJMP DISPLAY_MORSE

NOT_T:
    MOV A, SBUF
    CJNE A, #'U', NOT_U
    MOV DPTR, #MSG_U
    LJMP DISPLAY_MORSE

NOT_U:
    MOV A, SBUF
    CJNE A, #'V', NOT_V
    MOV DPTR, #MSG_V
    LJMP DISPLAY_MORSE

NOT_V:
    MOV A, SBUF
    CJNE A, #'W', NOT_W
    MOV DPTR, #MSG_W
    LJMP DISPLAY_MORSE

NOT_W:
    MOV A, SBUF
    CJNE A, #'X', NOT_X
    MOV DPTR, #MSG_X
    LJMP DISPLAY_MORSE

NOT_X:
    MOV A, SBUF
    CJNE A, #'Y', NOT_Y
    MOV DPTR, #MSG_Y
    LJMP DISPLAY_MORSE

NOT_Y:
    MOV A, SBUF
    CJNE A, #'Z', NOT_Z
    MOV DPTR, #MSG_Z
    LJMP DISPLAY_MORSE

DISPLAY_MORSE:
        LOOP_MORSE: CLR A
        MOVC A,@A+DPTR
        JNZ NOT_ZERO_MORSE
        ZERO_MORSE : LJMP INPUT_NEW
        NOT_ZERO_MORSE:
        LCALL DISPLAY
        LCALL DELAY
        INC DPTR
        LJMP LOOP_MORSE

NOT_Z:
    MOV A, SBUF
    CJNE A, #'<', NOT_ENCRYPTION
    LJMP ENCRYPTION
        
NOT_ENCRYPTION:
    MOV A, SBUF
    CJNE A, #'?', NOT_MORSE_DECRYPT
    LJMP MORSE_DECRYPT

NOT_MORSE_DECRYPT:
    MOV A, SBUF
    CJNE A, #',' , NOT_NEW_INPUT
    LJMP SMARTPHONE

NOT_NEW_INPUT:
    LJMP SMARTPHONE   

ENCRYPTION:
    MOV 32H, #16
    LCALL CLEAR_LCD

    ENCRYPTION_INPUT:
     LCALL GENERAL_INPUT

        MOV A, SBUF
        CJNE A, #'Z', NOT_Z_ENCRYPTION
        MOV A, #'A' ; EQUAL TO Z
        LCALL DISPLAY
        LCALL DELAY
        LJMP ENCRYPTION_INPUT

        NOT_Z_ENCRYPTION:
            MOV A, SBUF
            CJNE A, #'>', CONTINUE_ENCRYPTION
            LJMP WELCOME ; STOP ENCRYPTION AND GO BACK TO MAIN INPUT SUBROUTINE
    
        CONTINUE_ENCRYPTION:
            ADD A, #1
            LCALL DISPLAY
            LCALL DELAY
            LJMP ENCRYPTION_INPUT

MORSE_DECRYPT:   
    MOV 32H, #16
    ;SETB LED_1
    LCALL CLEAR_LCD
    
    INPUT_NEW_MORSE:
    MOV R0 , #0
    MOV R2 , #0
    MOV R6 , #0
    MOV R7 , #0

    MOV R5 , #1 ;COUNTER
   
    MORSE_DECRYPT_INPUT:
        LCALL GENERAL_INPUT

        MOV A, SBUF
        CJNE A, #'/', NOT_STOP_MORSE_DECRYPT
        LJMP WELCOME
        
    NOT_STOP_MORSE_DECRYPT:
        MOV A, SBUF
        CJNE A, #')' , CONTINUE_MORSE_DECRYPT
        LJMP DISPLAY_MORSE_DECRYPT 

    CONTINUE_MORSE_DECRYPT:        
        MOV A, SBUF

        CJNE R5 , #1 , NOT_1 ; if R5=1, store the input in R0
        SJMP COUNTER_1
    
        NOT_1:
        CJNE R5 , #2 , NOT_2 ; if R5=2, store the input in R6
        SJMP COUNTER_2

        NOT_2:
        CJNE R5 , #3 , NOT_3
        SJMP COUNTER_3

        NOT_3:
        CJNE R5 , #4 , NOT_4
        SJMP COUNTER_4

        NOT_4:
        LJMP WELCOME

        COUNTER_1:
        MOV R0 , A
        INC R5
        LJMP MORSE_DECRYPT_INPUT
        
        COUNTER_2:
        MOV R6 , A
        INC R5
        LJMP MORSE_DECRYPT_INPUT
        
        COUNTER_3:
        MOV R2, A
        INC R5
        LJMP MORSE_DECRYPT_INPUT

        COUNTER_4:
        MOV R7 , A
        LJMP MORSE_DECRYPT_INPUT

    DISPLAY_MORSE_DECRYPT:
        ;CHECK FOR A
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_A
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_A
        CJNE R2, #0 , NOT_MORSE_DECRYPT_A
        CJNE R7, #0 , NOT_MORSE_DECRYPT_A
        LJMP MORSE_DECRYPT_A
        
        ;CHECK FOR B
        NOT_MORSE_DECRYPT_A: 
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_B
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_B
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_B
        CJNE R7, #'.' , NOT_MORSE_DECRYPT_B
        LJMP MORSE_DECRYPT_B

        ; CHECK FOR C
        NOT_MORSE_DECRYPT_B:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_C
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_C
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_C
        CJNE R7, #'.' , NOT_MORSE_DECRYPT_C
        LJMP MORSE_DECRYPT_C

        ; CHECK FOR D
        NOT_MORSE_DECRYPT_C:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_D
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_D
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_D
        CJNE R7, #0 , NOT_MORSE_DECRYPT_D
        LJMP MORSE_DECRYPT_D

        ; CHECK FOR E
        NOT_MORSE_DECRYPT_D:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_E
        CJNE R6, #0 , NOT_MORSE_DECRYPT_E
        CJNE R2, #0 , NOT_MORSE_DECRYPT_E
        CJNE R7, #0 , NOT_MORSE_DECRYPT_E
        LJMP MORSE_DECRYPT_E

        ; CHECK FOR F
        NOT_MORSE_DECRYPT_E:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_F
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_F
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_F
        CJNE R7, #'.' , NOT_MORSE_DECRYPT_F
        LJMP MORSE_DECRYPT_F

        ; CHECK FOR G
        NOT_MORSE_DECRYPT_F:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_G
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_G
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_G
        CJNE R7, #0 , NOT_MORSE_DECRYPT_G
        LJMP MORSE_DECRYPT_G

        ; CHECK FOR H
        NOT_MORSE_DECRYPT_G:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_H
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_H
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_H
        CJNE R7, #'.' , NOT_MORSE_DECRYPT_H
        LJMP MORSE_DECRYPT_H

        ; CHECK FOR I
        NOT_MORSE_DECRYPT_H:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_I
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_I
        CJNE R2, #0 , NOT_MORSE_DECRYPT_I
        CJNE R7, #0 , NOT_MORSE_DECRYPT_I
        LJMP MORSE_DECRYPT_I

        ; CHECK FOR J
        NOT_MORSE_DECRYPT_I:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_J
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_J
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_J
        CJNE R7, #'-' , NOT_MORSE_DECRYPT_J
        LJMP MORSE_DECRYPT_J

        ; CHECK FOR K
        NOT_MORSE_DECRYPT_J:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_K
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_K
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_K
        CJNE R7, #0 , NOT_MORSE_DECRYPT_K
        LJMP MORSE_DECRYPT_K

        ; CHECK FOR L
        NOT_MORSE_DECRYPT_K:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_L
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_L
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_L
        CJNE R7, #'.' , NOT_MORSE_DECRYPT_L
        LJMP MORSE_DECRYPT_L

        ; CHECK FOR M
        NOT_MORSE_DECRYPT_L:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_M
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_M
        CJNE R2, #0 , NOT_MORSE_DECRYPT_M
        CJNE R7, #0 , NOT_MORSE_DECRYPT_M
        LJMP MORSE_DECRYPT_M

        ; CHECK FOR N
        NOT_MORSE_DECRYPT_M:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_N
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_N
        CJNE R2, #0 , NOT_MORSE_DECRYPT_N
        CJNE R7, #0 , NOT_MORSE_DECRYPT_N
        LJMP MORSE_DECRYPT_N

        ; CHECK FOR O
        NOT_MORSE_DECRYPT_N:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_O
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_O
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_O
        CJNE R7, #0 , NOT_MORSE_DECRYPT_O
        LJMP MORSE_DECRYPT_O

        ; CHECK FOR P
        NOT_MORSE_DECRYPT_O:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_P
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_P
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_P
        CJNE R7, #'.' , NOT_MORSE_DECRYPT_P
        LJMP MORSE_DECRYPT_P

        ; CHECK FOR Q
        NOT_MORSE_DECRYPT_P:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_Q
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_Q
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_Q
        CJNE R7, #'-' , NOT_MORSE_DECRYPT_Q
        LJMP MORSE_DECRYPT_Q

        ; CHECK FOR R
        NOT_MORSE_DECRYPT_Q:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_R
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_R
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_R
        CJNE R7, #0 , NOT_MORSE_DECRYPT_R
        LJMP MORSE_DECRYPT_R

        ; CHECK FOR S
        NOT_MORSE_DECRYPT_R:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_S
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_S
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_S
        CJNE R7, #0 , NOT_MORSE_DECRYPT_S
        LJMP MORSE_DECRYPT_S

        ; CHECK FOR T
        NOT_MORSE_DECRYPT_S:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_T
        CJNE R6, #0 , NOT_MORSE_DECRYPT_T
        CJNE R2, #0 , NOT_MORSE_DECRYPT_T
        CJNE R7, #0 , NOT_MORSE_DECRYPT_T
        LJMP MORSE_DECRYPT_T

        ; CHECK FOR U
        NOT_MORSE_DECRYPT_T:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_U
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_U
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_U
        CJNE R7, #0 , NOT_MORSE_DECRYPT_U
        LJMP MORSE_DECRYPT_U

        ; CHECK FOR V
        NOT_MORSE_DECRYPT_U:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_V
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_V
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_V
        CJNE R7, #'-' , NOT_MORSE_DECRYPT_V
        LJMP MORSE_DECRYPT_V

        ; CHECK FOR W
        NOT_MORSE_DECRYPT_V:
        CJNE R0, #'.' , NOT_MORSE_DECRYPT_W
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_W
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_W
        CJNE R7, #0 , NOT_MORSE_DECRYPT_W
        LJMP MORSE_DECRYPT_W

        ; CHECK FOR X
        NOT_MORSE_DECRYPT_W:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_X
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_X
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_X
        CJNE R7, #'-' , NOT_MORSE_DECRYPT_X
        LJMP MORSE_DECRYPT_X

        ; CHECK FOR Y
        NOT_MORSE_DECRYPT_X:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_Y
        CJNE R6, #'.' , NOT_MORSE_DECRYPT_Y
        CJNE R2, #'-' , NOT_MORSE_DECRYPT_Y
        CJNE R7, #'-' , NOT_MORSE_DECRYPT_Y
        LJMP MORSE_DECRYPT_Y

        ; CHECK FOR Z
        NOT_MORSE_DECRYPT_Y:
        CJNE R0, #'-' , NOT_MORSE_DECRYPT_Z
        CJNE R6, #'-' , NOT_MORSE_DECRYPT_Z
        CJNE R2, #'.' , NOT_MORSE_DECRYPT_Z
        CJNE R7, #'.' , NOT_MORSE_DECRYPT_Z
        LJMP MORSE_DECRYPT_Z

        NOT_MORSE_DECRYPT_Z:
        LJMP INPUT_NEW_MORSE

        MORSE_DECRYPT_A:
            MOV A, #'A' 
            LJMP MORSE_LED

        MORSE_DECRYPT_B:
            MOV A, #'B'
            LJMP MORSE_LED

        MORSE_DECRYPT_C:
            MOV A, #'C'
            LJMP MORSE_LED

        MORSE_DECRYPT_D:
            MOV A, #'D'
            LJMP MORSE_LED

        MORSE_DECRYPT_E:
            MOV A, #'E'
            LJMP MORSE_LED

        MORSE_DECRYPT_F:
            MOV A, #'F'
            LJMP MORSE_LED

        MORSE_DECRYPT_G:
            MOV A, #'G'
            LJMP MORSE_LED

        MORSE_DECRYPT_H:
            MOV A, #'H'
            LJMP MORSE_LED

        MORSE_DECRYPT_I:
            MOV A, #'I'     
            LJMP MORSE_LED            

        MORSE_DECRYPT_J:
            MOV A, #'J'
            LJMP MORSE_LED

        MORSE_DECRYPT_K:
            MOV A, #'K'
            LJMP MORSE_LED

        MORSE_DECRYPT_L:
            MOV A, #'L'
            LJMP MORSE_LED

        MORSE_DECRYPT_M:
            MOV A, #'M'
            LJMP MORSE_LED

        MORSE_DECRYPT_N:
            MOV A, #'N'
            LJMP MORSE_LED

        MORSE_DECRYPT_O:
            MOV A, #'O'
            LJMP MORSE_LED

        MORSE_DECRYPT_P:
            MOV A, #'P'
            LJMP MORSE_LED

        MORSE_DECRYPT_Q:
            MOV A, #'Q'
            LJMP MORSE_LED

        MORSE_DECRYPT_R:
            MOV A, #'R'
            LJMP MORSE_LED

        MORSE_DECRYPT_S:
            MOV A, #'S'
            LJMP MORSE_LED

        MORSE_DECRYPT_T:
            MOV A, #'T'
            LJMP MORSE_LED

        MORSE_DECRYPT_U:
            MOV A, #'U'
            LJMP MORSE_LED

        MORSE_DECRYPT_V:
            MOV A, #'V'
            LJMP MORSE_LED

        MORSE_DECRYPT_W:
            MOV A, #'W'
            LJMP MORSE_LED

        MORSE_DECRYPT_X:
            MOV A, #'X'        
            LJMP MORSE_LED

        MORSE_DECRYPT_Y:
            MOV A, #'Y'
            LJMP MORSE_LED

        MORSE_DECRYPT_Z:
            MOV A, #'Z'
            LJMP MORSE_LED        
     
        MORSE_LED:
            LCALL DISPLAY
            LCALL DELAY
            CHECK_R0:
                CJNE R0, #'-' , R0_NOT_DASH
                LJMP R0_DASH
            
                R0_NOT_DASH:
                    CJNE R0, #'.' , R0_NOT_DOT
                    LJMP R0_DOT

                R0_NOT_DOT:
                    CJNE R0, #'0' , R0_NOT_ZERO
                    LJMP R0_ZERO

                R0_NOT_ZERO:
                    LJMP INPUT_NEW_MORSE

                R0_DASH:
                    LCALL DASH
                    LJMP CHECK_R6
                R0_DOT:
                    LCALL DOT
                    LJMP CHECK_R6
                R0_ZERO:
                    LJMP INPUT_NEW_MORSE
                

            CHECK_R6:              
                CJNE R6, #'-' , R6_NOT_DASH
                LJMP R6_DASH
            
                R6_NOT_DASH:
                    CJNE R6, #'.' , R6_NOT_DOT
                    LJMP R6_DOT

                R6_NOT_DOT:
                    CJNE R6, #'0' , R6_NOT_ZERO
                    LJMP R6_ZERO

                R6_NOT_ZERO:
                    LJMP INPUT_NEW_MORSE
           
                R6_DASH:
                    LCALL DASH
                    LJMP CHECK_R2
                R6_DOT:
                    LCALL DOT
                    LJMP CHECK_R2                   
                R6_ZERO:
                    LJMP INPUT_NEW_MORSE

            CHECK_R2:              
                CJNE R2, #'-' , R2_NOT_DASH
                LJMP R2_DASH
            
                R2_NOT_DASH:
                    CJNE R2, #'.' , R2_NOT_DOT
                    LJMP R2_DOT

                R2_NOT_DOT:
                    CJNE R2, #'0' , R2_NOT_ZERO
                    LJMP R2_ZERO

                R2_NOT_ZERO:
                    LJMP INPUT_NEW_MORSE
           
                R2_DASH:
                    LCALL DASH
                    LJMP CHECK_R7
                R2_DOT:
                    LCALL DOT
                    LJMP CHECK_R7
                R2_ZERO:
                    LJMP INPUT_NEW_MORSE

            CHECK_R7:              
                CJNE R7, #'-' , R7_NOT_DASH
                LJMP R7_DASH
            
                R7_NOT_DASH:
                    CJNE R7, #'.' , R7_NOT_DOT
                    LJMP R7_DOT

                R7_NOT_DOT:
                    CJNE R7, #'0' , R7_NOT_ZERO
                    LJMP R7_ZERO

                R7_NOT_ZERO:
                    LJMP INPUT_NEW_MORSE
           
                R7_DASH:
                    LCALL DASH
                    LJMP INPUT_NEW_MORSE
                R7_DOT:
                    LCALL DOT
                    LJMP INPUT_NEW_MORSE
                R7_ZERO:
                    LJMP INPUT_NEW_MORSE

CLEAR_LCD:
    LCALL DELAY
    MOV A,#01H ;clear lcd
    LCALL COMMAND
    LCALL DELAY    
RET      

GENERAL_INPUT:
        ACALL DELAY
        CLR A
        CLR RI ;get ready to receive data
        WAIT_INPUT: JNB RI, WAIT_INPUT ;wait for the INPUT_NEW to come in
RET

COMMAND: 
    LCALL READY
    MOV P2,A
    CLR RS ;control reg is selected, send command to LCD controller
    CLR RW ;write to LCD 
    SETB ENBL
    LCALL DELAY
    CLR ENBL ;H to L pulse
RET

DISPLAY:    
    LCALL READY
    MOV P2,A
    SETB RS ;data register is selected, RS=1 send data to LCD
    CLR RW ;write to LCD
    SETB ENBL
    LCALL DELAY
    CLR ENBL ;H to L pulse
    DJNZ 32H, SAME_LINE
    LJMP NEW_LINE

    NEW_LINE:    
        LCALL DELAY
        MOV A,#0C0H ;2ND LINE
        LCALL COMMAND
        LCALL DELAY            
    SAME_LINE:
RET

;COMMAND and DISPLAY subroutine is same except the RS pin

READY:
    SETB P2.7
    CLR RS ;control reg is selected, send command to LCD controller
    SETB RW ;reading from LCD

WAIT:
    CLR ENBL ; disables communication with the LCD temporarily
    ACALL DELAY ;L to H pulse
    SETB ENBL
    JB P2.7,WAIT ;checks the busy flag
RET

DASH:            
    SETB LED_1
    CLR BUZZER
    LCALL DELAY
    LCALL DELAY
    LCALL DELAY
    LCALL DELAY
    LCALL DELAY
    LCALL DELAY            
    CLR LED_1
    SETB BUZZER
    LCALL DELAY
RET
            
DOT:
    SETB LED_1
    CLR BUZZER
    LCALL DELAY
    LCALL DELAY
    CLR LED_1
    SETB BUZZER
    LCALL DELAY
RET

DELAY:
    MOV R1,#1
    AGAIN_3:
    MOV R3,#220
    AGAIN_2:
    MOV R4,#220 ; delay
    AGAIN:
    DJNZ R4, AGAIN
    DJNZ R3, AGAIN_2
    DJNZ R1, AGAIN_3
RET

EXIT_2: SJMP EXIT_2

END