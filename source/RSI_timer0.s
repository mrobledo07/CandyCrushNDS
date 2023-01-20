@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: miguel.robledo@estudiants.urv.cat				  ===
@;=== Programador tarea 2G: yyy.yyy@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: zzz.zzz@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0:   .hword 5728			@;divisor de frecuencia inicial para timer 0


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retrazado vertical;
@;Tareas 2E,2F: actualiza la posición y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r2, lr}
		
@;Tareas 2Ea
		ldr r2, =update_spr
		ldrh r1, [r2]
		cmp r1, #0
		beq .LnoActualizar
		mov r0, #0x07000000
		ldr r1, =n_sprites
		ldr r1, [r1]
		bl SPR_actualizarSprites()
		mov r1, #0
		strh r1, [r2]
		
		.LnoActualizar:

@;Tarea 2Ga


@;Tarea 2Ha

		
		pop {r0-r2, pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r0, r1, lr}
		
		@; falta ajustar frecuencia de entrada y activaciones varias en registro TIMER0_CR 
		@; y falta indicar divisor de frecuencia mediante registro TIMER0_DATA
		@; a parte de acabar la lógica de la tarea
		
		mov r0, #1
		ldr r1, =timer0_on
		strh r0, [r1]
		
		cmp r0, #0
		beq .LnoModificar
		ldr r0, =divFreq0
		ldrh r0, [r0]
		ldr r1, =divF0
		strh r0, [r1]
		ldr r1, =TIMER0_DATA
		strh r0, [r1]
		
		.LnoModificar:
		
		pop {r0, r1, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {lr}
		
		
		pop {pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector vect_elem y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 0, decrementa dicho código y actualiza
@;	la posición del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	además de mover el sprite correspondiente a las nuevas coordenadas.
@;	Si no se ha movido ningún elemento, se desactivará el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducirá para simular
@;  el efecto de aceleración (con un límite).
	.global rsi_timer0
rsi_timer0:
		push {lr}
		
		
		pop {pc}



.end
