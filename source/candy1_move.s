	@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: victor.fosch@estudiants.urv.cat			  ===
@;=== Programador tarea 1F: victor.fosch@estudiants.urv.cat			  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación 'ori'.
@;	Restricciones:
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
	    push {r1-r2, r4-r8, lr}
		
		mov r7, #ROWS
		mov r8, #COLUMNS
		mla r4, r1, r8, r2
		add r4, r0				@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = número de repeticiones
		cmp r3, #0
		beq .Lconrep_este
		cmp r3, #1
		beq .Lconrep_sur
		cmp r3, #2
		beq .Lconrep_oeste
		cmp r3, #3
		beq .Lconrep_norte
		b .Lconrep_fin
		
	Lconrep_este:
		add r2, #1
		cmp r2, r8				@;compara la columna actual con #COLUMNS
		bhs .Lconrep_fin
		add r4, #1				@;pasa a la siguiente columna
		ldrb r6, [r4]
		and r6, #7
		cmp r6, r5				@;compara el valor inicial con la nueva posición
		bne .Lconrep_fin
		add r0, #1				@;añade una repetición
		b .Lconrep_este
	
	Lconrep_sur:
		add r1, #1
		cmp r1, r7				@;compara la fila actual con #ROWS
		bhs .Lconrep_fin
		add r4, r7				@;pasa a la siguiente fila
		ldrb r6, [r4]
		and r6, #7
		cmp r6, r5				@;compara el valor inicial con la nueva posición
		bne .Lconrep_fin
		add r0, #1				@;añade una repetición
		b .Lconrep_sur
	
	Lconrep_oeste:
		sub r2, #1
		cmp r2, #0				@;compara la columna actual con la primera columna
		blo .Lconrep_fin
		sub r4, #1				@;retrocede a la columna anterior
		ldrb r6, [r4]
		and r6, #7
		cmp r6, r5				@;compara el valor inicial con la nueva posición
		bne .Lconrep_fin
		add r0, #1				@;añade una repetición
		b .Lconrep_oeste
		
	Lconrep_norte:
		sub r1, #1
		cmp r1, #0				@;compara la fila actual con el primera fila
		blo .Lconrep_fin
		sub r4, r7				@;retrocede a la fila anterior
		ldrb r6, [r4]
		and r6, #7
		cmp r6, r5				@;compara el valor inicial con la nueva posición
		bne .Lconrep_fin
		add r0, #1				@;añade una repetición
		b .Lconrep_norte
	
	Lconrep_fin:
		
		pop {r1-r2, r4-r8, pc}




@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en sentido inclinado; cada llamada a
@;	la función sólo baja elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si está todo quieto.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {r4, lr}
		
		mov r4, r0
		bl baja_verticales
		cmp r0, #1
		beq .Lfinal
		bl baja_laterales
		
	Lfinal:
		
		pop {r4, pc}



@;:::RUTINAS DE SOPORTE:::


@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_verticales:
		push {rX-rY, lr}
		
		mov r1, #ROWS
		mov r2, #COLUMNS
		add r9, r4, r2				@;R9 = primera posició de la segona fila
		mla r3, r1, r2, r4   		@;Conté la direccio de l'última posició de la matriu
		
	Lrecorre_mat:
		ldrb r5, [r3]				@;Valor del element a la posicio actual
		cmp r3, r9			
		blo .Lfila_superior			@;Si la direccio de la posició actual es inferior a R9, ens trobem a la fila superior de la matriu
		tst r5, #7					@;Fa un tst amb els tres bits baixos, per comprovar si hi ha un 0, 8 o 16
		beq .Lbaixa_elem
		cmp r3, r4					@;Si R3=R4 ens trobem a la primera posició de la matriu
		beq .Lfora_mat		
		sub r3, #1
		b .Lrecorre_mat
		
	Lbaixa_elem:
		mov r6, r3
		Lelem_superior:
			sub r6, r2
			ldrb r7, [r6]				@;R7 conté el valor del element superior a la posicio buida
			cmp r7, #7					
			beq .Lrecorre_mat			@;si R7 es un bloc sòlid no cambia res i segueix recorren la matriu
			cmp r7, #15
			beq .Lelem_superior			@;si R7 es un forat mira el valor del element superior
			and r7, #7
			strb r7, [r3]				@;Coloquem el valor del element, filtrat, a la posicio buida
			ldrb r7, [r6]
			lsr r7, #3
			lsl	r7, #3
			strb r7, [r6]				@;Eliminem el valor del element i el guardem
			b .Lrecorre_mat
		
	Lfila_superior:
		tst r5, #7
		bne .Lrecorre_mat
		add r5, #3						@;Aqui ficara un element aleatori
		
		
	Lfora_mat:
		
		pop {rX-rY, pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
		push {lr}
		
		
		pop {pc}



.end
