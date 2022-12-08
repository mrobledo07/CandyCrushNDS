@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: victor.fosch@estudiants.urv.cat			  ===
@;=== Programador tarea 1F: victor.fosch@estudiants.urv.cat			  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el n�mero de
@;	repeticiones del elemento situado en la posici�n (f,c) de la matriz, 
@;	visitando las siguientes posiciones seg�n indique el par�metro de
@;	orientaci�n 'ori'.
@;	Restricciones:
@;		* s�lo se tendr�n en cuenta los 3 bits de menor peso de los c�digos
@;			almacenados en las posiciones de la matriz, de modo que se ignorar�n
@;			las marcas de gelatina (+8, +16)
@;		* la primera posici�n tambi�n se tiene en cuenta, de modo que el n�mero
@;			m�nimo de repeticiones ser� 1, es decir, el propio elemento de la
@;			posici�n inicial
@;	Par�metros:
@;		R0 = direcci�n base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientaci�n 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = n�mero de repeticiones detectadas (m�nimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
	    push {r1-r2, r4-r8, lr}
		
		mov r7, #ROWS
		mov r8, #COLUMNS
		mla r4, r1, r7, r2
		add r4, r0				@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = n�mero de repeticiones
		cmp r3, #0
		beq .Lconrep_este
		cmp r3, #1
		beq .Lconrep_sur
		cmp r3, #2
		beq .Lconrep_oeste
		cmp r3, #3
		beq .Lconrep_norte
		b .Lconrep_fin
		
	Lconrep_este :
		add r2, #1
		cmp r2, r8				@;compara la columna actual con #COLUMNS
		bhs .Lconrep_fin
		add r4, #1				@;pasa a la siguiente columna
		ldrb r6, [r4]
		and r6, #7
		cmp r6, r5				@;compara el valor inicial con la nueva posici�n
		bne .Lconrep_fin
		add r0, #1				@;a�ade una repetici�n
		b .Lconrep_este
	
	Lconrep_sur :
		add r1, #1
		cmp r1, r7				@;compara la fila actual con #ROWS
		bhs .Lconrep_fin
		add r4, r7				@;pasa a la siguiente fila
		ldrb r6, [r4]
		and r6, #7
		cmp r6, r5				@;compara el valor inicial con la nueva posici�n
		bne .Lconrep_fin
		add r0, #1				@;a�ade una repetici�n
		b .Lconrep_sur
	
	Lconrep_oeste :
		sub r2, #1
		cmp r2, #0				@;compara la columna actual con la primera columna
		blo .Lconrep_fin
		sub r4, #1				@;retrocede a la columna anterior
		ldrb r6, [r4]
		and r6, #7
		cmp r6, r5				@;compara el valor inicial con la nueva posici�n
		bne .Lconrep_fin
		add r0, #1				@;a�ade una repetici�n
		b .Lconrep_oeste
		
	Lconrep_norte :
		sub r1, #1
		cmp r1, #0				@;compara la fila actual con el primera fila
		blo .Lconrep_fin
		sub r4, r7				@;retrocede a la fila anterior
		ldrb r6, [r4]
		and r6, #7
		cmp r6, r5				@;compara el valor inicial con la nueva posici�n
		bne .Lconrep_fin
		add r0, #1				@;a�ade una repetici�n
		b .Lconrep_norte
	
	Lconrep_fin :
		
		pop {r1-r2, r4-r8, pc}




@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vac�as, primero en vertical y despu�s en sentido inclinado; cada llamada a
@;	la funci�n s�lo baja elementos una posici�n y devuelve cierto (1) si se ha
@;	realizado alg�n movimiento, o falso (0) si est� todo quieto.
@;	Restricciones:
@;		* para las casillas vac�as de la primera fila se generar�n nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado alg�n movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en vertical; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_verticales:
		push {lr}
		
		
		pop {pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en diagonal; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_laterales:
		push {lr}
		
		
		pop {pc}



.end
