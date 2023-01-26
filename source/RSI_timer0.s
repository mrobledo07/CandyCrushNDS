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
		beq .LnoActualizar				@; si update_spr != 0 -> actualizar sprites
		mov r0, #0x07000000				@; r0 = 0x0700 0000 (dirección base para los sprites (Object Attribute Memory) en el procesador gráfico principal)
		ldr r1, =n_sprites
		ldr r1, [r1]					@; r1 = n_sprites
		bl SPR_actualizarSprites
		mov r1, #0
		strh r1, [r2]					@; update_spr = 0 (variable update_spr a 0 indica que no hay sprites para actualizar)
		
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
		
		cmp r0, #0
		beq .LnoRestablecerDivFreq	@; si init != 0, entonces se restablece el valor original del divisor de frecuencia
		ldr r0, =divFreq0	
		ldrh r0, [r0]				@; se guardará el valor del divisor de frecuencia en divF0 y en el registro de datos
		ldr r1, =divF0
		strh r0, [r1]				@; divF0 = divisor de frecuencia inicial
		ldr r1, =0x04000100			@; TIMER0_DATA = 0x0400 0100
		rsb r0, r0, #0				@; r0 = divisor_frecuencia_inicial * (-1)
		strh r0, [r1]				@; TIMER0_DATA = divisor de frecuencia inicial (negativo)
		
		.LnoRestablecerDivFreq:		@; si init == 0, no se modifica el valor del divisor de frecuencia
		ldr r0, =0x04000102			@; TIMER0_CR = 0x0400 0102
		mov r1, #0xC3
		strh r1, [r0]				@; TIMER0_CR = bits 0 y 1 -> 11 (frecuencia entrada = 32728), bits 6 y 7 -> 11 (se activa el timer y las interrupciones)
		ldr r0, =timer0_on
		mov r1, #1	
		strh r1, [r0]				@; timer0_on = 1 (variable timer0_on a 1 indica que el timer está activado)
		
		pop {r0, r1, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0, r1, lr}
		ldr r0, =0x04000102		@; TIMER0_CR = 0x0400 0102
		mov r1, #0
		strh r1, [r0]			@; TIMER0_CR = 0x0000 -> todos los bits a 0 (incluídos los bits Start/Stop y IRQ Enable)
			
		ldr r0, =timer0_on
		strh r1, [r0]			@; timer0_on = 0 (variable timer0_on  a 0 indica que el timer está desactivado)
		
		pop {r0, r1, pc}



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
		push {r0-r9, lr}
		ldr r0, =cont
		ldr r1, [r0]
		add r1, #1
		str r1, [r0]			@; cont++ (la variable global contador incrementa para saber cuantas veces se entra a la rsi)
			
		ldr r0, =vect_elem		@; r0 = dirección base del array vect_elem
		mov r7, #0				@; r7 = 0 (índice para recorrer el array vect_elem)
		ldr r6, =n_sprites		
		ldr r6, [r6]			@; r6 = n_sprites (límite que hay que recorrer del array)
		ldr r3, =divFreq0
		ldrh r5, [r3]
		mov r5, r5, lsr #32		@; r5 = r5/2^32		(límite de aceleración del sprite)
		
		.Lbucle:
		ldsh r3, [r0, #ELE_II]
		cmp r3, #0
		ble .LfiBucle				@; if(r3 <= 0) b.LfiBucle
		sub r3, #1					@; r3--
		strh r3, [r0, #ELE_II]		@; ii = r3 (se decrementa el valor del atributo ii)
		ldsh r3, [r0, #ELE_VX]		@; r3 = atributo vx del elemento
		cmp r3, #0
		bne .LmoverHorizontal		@; if(r3 != 0) b .LmoverHorizontal 
		ldsh r3, [r0, #ELE_VY]		@; r3 = atributo vy del elemento
		cmp r3, #0
		bne .LmoverVertical			@; if(r3 != 0) b .LmoverVertical
		
		.LmoverHorizontal:
		ldsh r4, [r0, #ELE_PX]		@; r4 = atributo px del elemento
		add r4, r3					@; r4 = px+ vx
		strh r4, [r0, #ELE_PX]		@; vect_elem.px = r4
		ldsh r3, [r0, #ELE_VY]		@; r3 = atributo vy del elemento	
		cmp r3, #0
		beq .Lcontinuacion			@; if(r3 == 0) b .Lcontinuacion (no habrá movimiento vertical)
		
		.LmoverVertical:
		ldsh r4, [r0, #ELE_PY]		@; r4 = atributo py del elemento
		add r4, r3					@; r4 = py + vy
		strh r4, [r0, #ELE_PY]		@; vect_elem.py = r4
	
		.Lcontinuacion:
	
		ldsh r1, [r0, #ELE_PX]		@; r1 = atributo px (actualizado/nuevo) del elemento	
		ldsh r2, [r0, #ELE_PY]		@; r2 = atributo py (actualizado/nuevo) del elemento
		bl SPR_moverSprite
		
		ldr r3, =update_spr
		mov r4, #1
		strh r4, [r3]			@; update_spr = 1 (ya que se ha actualizado un sprite)
		
		.LfiBucle:
		add r7, #1
		cmp r7, r6			
		beq .Lfinal			@; if (i == n_sprites) b .Lfinal	(se han recorrido los n_sprites del array)
		add r0, #10			@; r0 = r0 + 10 (así nos posicionamos en la siguiente posición del array vect_elem el cual en cada posición tiene 5 atributos de 2 bytes cada uno)
		b .Lbucle
		
		.Lfinal:
		ldr r4, =update_spr
		ldrh r3, [r4]
		cmp r3, #0
		bleq desactiva_timer0	@; si no ha habido ningún movimiento se desactiva el timer
		beq .LnoActualizarFreq
		
		ldr r3, =divF0
		ldrh r4, [r3]			@; r4 = divF0
		mov r4, r4, lsr #1		@; r4 = r4/2 (disminuye el divisor de frecuencia en un factor de 2)
		cmp r4, r5
		movhi r4, r5			@; if(r4 > r5) r4 = r5 (si se ha superado el límite de aceleración, r4 se establece en el límite)	
		strh r4, [r3]			@; divF0 = divF0/2 (para conseguir el efecto de aceleración)
		rsb r4, r4, #0			@; divF0 = divF0 * (-1)
		ldr r8, =0x04000100		@; TIMER0_DATA = 0x0400 0100
		strh r4, [r8]			@; TIMER0_DATA = divisor de frecuencia actualizado (negativo)
		
		.LnoActualizarFreq:
		
		
		pop {r0-r9, pc}



.end
