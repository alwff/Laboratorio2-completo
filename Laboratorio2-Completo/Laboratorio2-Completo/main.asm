;******************************************************************
;
; Universidad del Valle de Guatemala 
; IE2023:: Programación de Microcontroladores
; Laboratorio2-Completo.asm
; Autor: Alejandra Cardona 
; Proyecto: Laboratorio 2
; Hardware: ATMEGA328P
; Creado: 06/02/2024
; Última modificación: 20/02/2024
;
;******************************************************************
; ENCABEZADO
;******************************************************************

.INCLUDE "M328PDEF.INC"
.CSEG

.ORG 0x00

;******************************************************************
; STACK POINTER
;******************************************************************

	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17

;******************************************************************
; 
;		TABLA DE VALORES
; A	  B	  C	  D	  E	  F	  G 
; PD7 PC0 PC1 PC2 PC3 PC4 PC5
; 
;******************************************************************

t7s: .DB 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

;******************************************************************
; CONFIGURACIÓN 
;******************************************************************

Setup:

	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16		
	LDI R24, 0b0000_1000		
	STS CLKPR, R16
			
	;Setting
	LDI R16, 0xFC	; PD como salidas -- PD2aPD6 LEDS -- PD7 7seg sobrante -- Hacer logical shit left para LEDs. (2 posiciones)
	OUT DDRD, R16

	LDI R16, 0x7F	; PC como salidas PARA 7seg
	OUT DDRC, R16

	LDI R16, 0x03 ; Pullups
	OUT PORTB, R16	; Fin de pullups
			
	LDI R21, 0	//	Shift bits
	LDI R17, 0 // Lista de los 7 segmentos 
	LDI R19, 0
	CALL SET7SEG

;******************************************************************
; LOOP 
;******************************************************************

LOOP:
	
	CPI R17, 16
	BREQ RESETEA
	
	SBRC R17, PC0 //Si el bit correspondiente a PC0 es 0, se salta la siguiente linea, de lo coontrario PD7 se enciende 
	SBI PIND, PD7 

	IN R16, PINB
	SBRS R16, PB0				
	RJMP DELAY	
			
	IN R18, PINB
	SBRS R18, PB1
	RJMP DELAY2

	MOV R21, R17
	LSR R21
	OUT PORTC, R21

	RJMP LOOP

;******************************************************************
; delay
;******************************************************************

DELAY:
	LDI R16, 100				
	delayy:
		DEC R16
		BRNE delayy	;	Lee el estado del botón despues del antirebote
	SBIS PINB, PB0				
	RJMP DELAY			
	INC R19
	CALL SET7SEG
	SBI PIND, PD6 ; Enciende LED para verificar estado del botón. 
RJMP LOOP

DELAY2:
	LDI R18, 100				
	delayy2:
		DEC R18
		BRNE delayy2
	SBIS PINB, PB1				;	salta si el bit es 1
	RJMP DELAY2	
	DEC R19	
	CALL SET7SEG	
	SBI PIND, PD5	; Enciende LED para verificar estado del botón. 
RJMP LOOP

;******************************************************************
; BORRA R17 
;******************************************************************

RESETEA: 

	CLR R17
	CLR R19
	CLR R21

;******************************************************************
; 7SEGMENTOS 
;******************************************************************

SET7SEG: 
	MOV R17, R19 
	LDI ZH, HIGH(t7s << 1)
	LDI ZL, LOW(t7s << 1)
	ADD ZL, R17
	LPM R17, Z
	RET