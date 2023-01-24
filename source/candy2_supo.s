@;=                                                               		=
@;== candy2_supo.s: rutinas de soporte a la pr�ctia CandyNDS (fase 2) ===
@;=                                                         			=
@;=== Analista-programador: santiago.romani@urv.cat			 		  ===
@;=                                                         	      	=

.include "../include/candy2_incl.i"


@;-- .text. Program code ---
.text	
		.align 2
		.arm


@;busca_elemento(int fil, int col);
@;Rutina para buscar un elemento dentro del vector de elementos, a partir de las
@;	coordenadas de fila y columna del elemento, que se tienen que contrastar con
@;	las coordenadas (px,py) de cada sprite. La rutina devuelve el �ndice del
@;	elemento, o ROWS*COLUMNS si no lo ha encontrado
@;	Par�metros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	�ndice del elemento encontrado, o ROWS*COLUMNS 
	.global busca_elemento
busca_elemento:
		push {r2-r6,lr}
		
		ldr r6, =n_sprites
		ldr r6, [r6]			@;R6 = n�mero de sprites creados
		mov r2, r1, lsl #5		@;R2 = px (columna * 32)
		mov r3, r0, lsl #5		@;R3 = py (fila * 32)
		mov r0, #0				@;R0 es �ndice de elementos
		ldr r4, =vect_elem		@;R4 es direcci�n base del vector elementos
	.Lbe_bucle:
		ldsh r5, [r4, #ELE_II]
		cmp r5, #-1
		beq .Lbe_cont			@;continuar si vect_elem[i].ii == -1
		ldsh r5, [r4, #ELE_PX]
		cmp r5, r2
		bne .Lbe_cont			@;continuar si vect_elem[i].px != posici�n px
		ldsh r5, [r4, #ELE_PY]
		cmp r5, r3
		beq .Lbe_finbucle		@;salir si vect_elem[i].py == posici�n py
		
	.Lbe_cont:
		add r4, #ELE_TAM
		add r0, #1				@;repetir para todos los sprites creados
		cmp r0, r6
		blo .Lbe_bucle
		mov r0, #ROWS*COLUMNS	@;c�digo de no encontrado (>= n_sprites)
		
	.Lbe_finbucle:
		
		pop {r2-r6, pc}
	
	
@;crea_elemento(int tipo, int fil, int col);
@;Rutina para crear un nuevo elemento de juego, buscando un sprite libre
@;	(ii = -1) y asignandole el �ndice de baldosa correspondiente al tipo del
@;	elemento que se pasa por par�metro, adem�s de la posici�n inicial seg�n la
@;	fila y columna en la matriz de juego;
@;	La funci�n devuelve como resultado el �ndice del sprite/elemento que se ha
@;	reservado, o bien el total de posiciones del tablero de juego (ROWS*COLUMNS)
@;	si no ha encontrado ninguno libre.
@;	Par�metros:
@;		R0 :	tipo de elemento
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;	Resultado:
@;		R0 :	�ndice del elemento encontrado, o ROWS*COLUMNS 
	.global crea_elemento
crea_elemento:
		push {r1-r5,lr}
		
		mov r3, r0					@;R3 = tipo de elemento
	@;	int i = 0;
		mov r0, #0					@;R0 es �ndice de elementos (i)
		
	@;	while ((vect_elem[i].ii != -1) && (i < ROWS*COLUMNS))
	@;		i++;
		ldr r4, =vect_elem			@;R4 es direcci�n base del vector elementos
	.Lce_bucle:
		ldsh r5, [r4, #ELE_II]
		cmp r5, #-1
		beq .Lce_finbucle			@;salir si vect_elem[i].ii == -1
		add r4, #ELE_TAM
		add r0, #1
		cmp r0, #ROWS*COLUMNS
		blo .Lce_bucle				@;repetir para todos los sprites posibles
		b .Lce_fin
	.Lce_finbucle:
	@;	if (i < ROWS*COLUMNS)		// si lo ha encontrado
	@;	{							// inicializar sus campos principales
		mov r5, #0
		strh r5, [r4, #ELE_II]		@;vect_elem[i].ii = 0;
		mov r5, r2, lsl #5
		strh r5, [r4, #ELE_PX]		@;vect_elem[i].px = col*MTWIDTH;
		mov r5, r1, lsl #5
		strh r5, [r4, #ELE_PY]		@;vect_elem[i].py = fil*MTHEIGHT;
		
	@;		SPR_crearSprite(i, 0, 2, 'indice metabaldosa');
		sub r1, r3, #1
		mov r2, #MTOTAL
		mul r3, r1, r2				@;indice metabaldosa = (tipo-1)*MTOTAL
		mov r1, #0
		mov r2, #2
		bl SPR_crearSprite
	@;		SPR_moverSprite(i, vect_elem[i].px, vect_elem[i].py);
		ldsh r5, [r4, #ELE_PX]
		mov r1, r5
		ldsh r5, [r4, #ELE_PY]
		mov r2, r5
		bl SPR_moverSprite
	@;		SPR_fijarPrioridad(i, 1);
		mov r1, #1
		bl SPR_fijarPrioridad
	@;		SPR_mostrarSprite(i);
		bl SPR_mostrarSprite
	@;	}
	.Lce_fin:
		pop {r1-r5, pc}



@;elimina_elemento(int fil, int col);
@;Rutina para eliminar un elemento de juego, a partir de sus coordenadas fila
@;	y columna actuales; si se encuentra dicho elemento, se libera la posici�n
@;	del vector y se oculta el sprite asociado.
@;	La funci�n devuelve el �ndice del elemento eliminado, o bien el total de
@;	posiciones del tablero de juego (ROWS*COLUMNS) si no lo ha encontrado.
@;	Par�metros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	�ndice del elemento encontrado, o ROWS*COLUMNS
	.global elimina_elemento
elimina_elemento:
		push {r1-r4,lr}
		
	@;	int i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Lee_fin
	@;	{
	@;		vect_elem[i].ii = -1;		// libera la entrada en el vector
		ldr r4, =vect_elem
		mov r3, #ELE_TAM
		mul r2, r0, r3					@;R2 = i * TAMELEM;
		add r4, r2
		mov r1, #-1
		strh r1, [r4, #ELE_II]
	@;		SPR_ocultarSprite(i);		// ocultar el sprite asociado
		bl SPR_ocultarSprite
	@;	}
	.Lee_fin:
		pop {r1-r4,pc}



@;activa_elemento(int fil, int col, int f2, int c2);
@;Rutina para activar la animaci�n del movimiento de un elemento/sprite
@;	a partir de sus coordenadas fila y columna actuales as� como la posici�n
@;	del tablero donde se tiene que mover dicho elemento.
@;	La funci�n devuelve el �ndice del elemento activado, o bien el total de
@;	posiciones del tablero de juego (ROWS*COLUMNS) si no lo ha encontrado.*/
@;	Par�metros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;		R2 :	fila destino
@;		R3 :	columna destino
@;	Resultado:
@;		R0 :	�ndice del elemento encontrado, o ROWS*COLUMNS
	.global activa_elemento
activa_elemento:
		push {r1-r7,lr}
		
		mov r5, r0						@;R5 guarda valor de fila del elemento
	@;	int i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Lae_fin
	@;	{
		ldr r4, =vect_elem
		mov r6, #ELE_TAM
		mul r7, r0, r6					@;R7 = i * TAMELEM;
		add r4, r7
	@;		vect_elem[i].vx = c2 - col;	// fija la velocidad como la diferencia
	@;		vect_elem[i].vy = f2 - fil;	// de posiciones a desplazarse
		sub r3, r1
		strh r3, [r4, #ELE_VX]
		sub r2, r5 
		strh r2, [r4, #ELE_VY]
	@;		vect_elem[i].ii = 32;		// activa el movimiento (32 interrups.)
		mov r5, #32
		strh r5, [r4, #ELE_II]
	@;	}
	.Lae_fin:
		pop {r1-r7,pc}



@;activa_escalado(int fil, int col);
@;Rutina para activar la animaci�n de escalado de un elemento/sprite
@;	a partir de sus coordenadas fila y columna actuales.
@;	La funci�n devuelve el �ndice del elemento activado, o bien el total de
@;	posiciones del tablero (ROWS*COLUMNS) si no lo ha encontrado.
@;	Par�metros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	�ndice del elemento encontrado, o ROWS*COLUMNS
	.global activa_escalado
activa_escalado:
		push {r1,lr}
		
	@;	int i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Laes_fin
	@;	{								// activa escalado del sprite (grupo 0)
	@;		SPR_activarRotacionEscalado(i,0);
		mov r1, #0
		bl SPR_activarRotacionEscalado
	@;	}
	.Laes_fin:
		pop {r1,pc}



@;desactiva_escalado(int fil, int col);
@;Rutina para desactivar la animaci�n de escalado de un elemento/sprite
@;	a partir de sus coordenadas fila y columna actuales.
@;	La funci�n devuelve el �ndice del elemento activado, o bien el total de
@;	posiciones del tablero (ROWS*COLUMNS) si no lo ha encontrado.
@;	Par�metros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	�ndice del elemento encontrado, o ROWS*COLUMNS
	.global desactiva_escalado
desactiva_escalado:
		push {lr}
		
	@;	int i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Ldes_fin
	@;	{								// desactiva escalado del sprite
	@;		SPR_desactivarRotacionEscalado(i);
		bl SPR_desactivarRotacionEscalado
	@;	}
	.Ldes_fin:
		pop {pc}




@;fija_metabaldosa(u16 * mapbase, int fil, int col, int imeta);
@;Rutina para guardar, en el mapa de baldosas cuya direcci�n base se pasa por
@;	par�metro, los �ndices de las baldosas correspondientes a una metabaldosa
@;	de MTROWS x MTCOLS (MTWIDTH x MTHEIGHT p�xeles), a partir de la posici�n
@;	(fil, col) del espacio de juego y del �ndice de la metabaldosa.
@;	Par�metros:
@;		R0 :	direcci�n base del mapa de baldosas (mapbase)
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;		R3 :	�ndice de metabaldosa (imeta)
	.global fija_metabaldosa
fija_metabaldosa:
		push {r1-r10, lr}
		
		mov r4, #MTOTAL
		mul r5, r3, r4
	@;	i_baldosa = imeta*MTOTAL;
		mov r3, r5					@;R3 = �ndice inicial de baldosas simples
		mov r4, #MTROWS
		mul r5, r1, r4
		mov r1, r5					@;R1 = i*MTROWS
		mov r5, #MTCOLS
		mul r6, r2, r5
		mov r2, r6					@;R2 = j*MTCOLS
		
		mov r6, #0					@;R6 es fila de metabaldosa (df)
	@;	for (df = 0; df < MTROWS; df++)
	@;	{								// dir. base en mapa de fila actual
	.Lfm_for_df:
	@;		base_fila = mapbase + (i*MTROWS + df)*32;
		add r8, r1, r6
		add r10, r0, r8, lsl #6		@;R10 = dir. base de fila actual en mapa
									@;R8*32*2 -> 32 columnas * 2 bytes/posici�n
									
		mov r9, #0					@;R9 es columna de metabaldosa (dc)
	@;		for (dc = 0; dc < MTCOLS; dc++)
	.Lfm_for_dc:
	@;			*(base_fila + j*MTCOLS + dc) = i_baldosa;
		add r8, r2, r9
		add r8, r10, r8, lsl #1		@;R8 = dir. base de (fil,col) actual en mapa
		strh r3, [r8]
	@;			i_baldosa++;	
		add r3, #1					@;aumentar �ndice de baldosa simple
		add r9, #1
		cmp r9, #MTCOLS
		blo .Lfm_for_dc				@;repetir para todas las filas metabaldosa
		
		add r6, #1
		cmp r6, #MTROWS
		blo .Lfm_for_df				@;repetir para todas las columnas metabaldosa
		
		pop {r1-r10, pc}


@;elimina_gelatina(int fil, int col);
@;Rutina para eliminar una gelatina del tablero de juego, a partir de sus 
@;	coordenadas de fila y columna.
@;	Par�metros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
	.global elimina_gelatina
elimina_gelatina:
		push {r0-r5,lr}
		
		ldr r4, =mat_gel
		mov r2, #COLUMNS
		mul r3, r0, r2
		add r5, r3, r1
		mov r3, #GEL_TAM
		mul r2, r5, r3					@;R2 = (fil * COLUMNS + col) * GEL_TAM;
		add r4, r2
	@;	imeta = mat_gel[fil,col].im;
		ldrb r3, [r4, #GEL_IM]
	@;	if (imeta > 8)
	@;	{								// si c�digo animaci�n gelatina doble
		cmp r3, #8
		blo .Leligel_else
	@;		imeta -= 8;					// pasar a animaci�n gelatina simple
		sub r3, #8
	@;		mat_gel[fil,col].im = imeta
		strb r3, [r4, #GEL_IM]
		b .Leligel_finif
	@;	}
	@;	else
	@;	{								// si c�digo animaci�n gelatina simple
	.Leligel_else:
	@;		mat_gel[fil,col].ii = -1	// desactivar gelatina
		mov r5, #-1
		strb r5, [r4, #GEL_II]
	@;		imeta = 19;					// �ndice metabaldosa vac�a
		mov r3, #19
	@;	}
	.Leligel_finif:
		mov r2, r1
		mov r1, r0
		mov r0, #0x06000000
		bl fijar_metabaldosa
		
		pop {r0-r5,pc}

