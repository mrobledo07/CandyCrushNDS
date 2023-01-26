@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: alex.casanova@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: .hword	-5727,5			@;divisor de frecuencia para timer 1


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;Factor actual de escalado
	escNum: .space	2				@;número de variaciones del factor


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado según el parámetro init.
@;	Parámetros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {r1-r3, lr}
		ldr r1, =escNum
		mov r2, #0
		strh r2, [r1]                 @; escNum = 0
		
		ldr r1, =timer1_on
		mov r2, #1
		strh r2, [r1]                 @; timer1_on = 1
		
		ldr r1, =0x04000104           @; TIMER1_DATA
		ldr r2, =divFreq1
		ldrh r3, [r2]
		strh r3, [r1]                 @; Divisor de freqüència a TIMER1_DATA
		
		ldr r1, =0x04000106           @; TIMER1_CR   
		ldrh r2, [r1]
		orr r2, #0x00C1               @; Màscara per iniciar el timer amb interrupcions activades, sense enllaçar amb el timer anterior i amb una freq d'entrada F/64
		strh r2, [r1]
		
		ldr r1, =escSen
		strh r0, [r1]                 @; escSen = init
		
		cmp r0, #0
		bne .LFinal
		
		mov r1, #1                   
		mov r2, r1, lsl #8            @; 1,0 amb format coma fixa 0,8,8; py (SPR_fijarEscalado) = 1,0
		ldr r1, =escFac               
		strh r2, [r1]                 @; escFac = 1,0
		mov r0, #0                    @; igrp (SPR_fijarEscalado) = 0
		mov r1, r2                    @; px (SPR_fijarEscalado) = escFac (1,0)
		bl SPR_fijarEscalado
		
		.LFinal:
		pop {r1-r3, pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0, r1, lr}
		ldr r0, =timer1_on
		mov r1, #0                    @; Timer1_on = 0
		strh  r1, [r0]
		ldr r0, =0x04000106           @; TIMER1_CR
		ldrh r1, [r0]
		bic r1, #128                  @; Bit 7 a 0, s'atura el timer
		strh r1, [r0]
		pop {r0, r1, pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	número de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual según el código de la variable 'escSen'. Cuando se llega al máximo
@;	se desactivará el timer1.
	.global rsi_timer1
rsi_timer1:
		push {r0-r2, lr}
		ldr r0, =cont                  @; Comptador per 
		ldr r1, [r0]
		add r1, #1
		str r1, [r0]
		ldr r0, =escNum
		ldrh r1, [r0]
		add r1, #1                     @; escNum++
		strh r1, [r0]
		cmp r1, #32 
		bne .LContinua                 @; Si escNum = 32 es desactiva el timer i es surt de la rutina
		
		bl desactiva_timer1
		b .LFinal2
		
		.LContinua:
		ldr r0, =escSen
		ldrh r1, [r0]
		ldr r0, =escFac
		ldrh r2, [r0]
		
		cmp r1, #0                      @; escSen = 0, escFac decrementa; escSen = 1, escFac incrementa
		subeq r2, #32
		addne r2, #32
		
		strh r2, [r0]
		
		mov r0, #0                      @; igrp (SPR_fijarEscalado) = 0
		mov r1, r2                      @; px (SPR_fijarEscalado) = escFac = py
		bl SPR_fijarEscalado
		
		ldr r0, =update_spr
		mov r1, #1
		strh r1, [r0]                   @; update_spr = 1
		
		.LFinal2:
		pop {r0-r2, pc}



.end
