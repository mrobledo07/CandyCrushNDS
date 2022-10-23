@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: miguel.robledo@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: miguel.robledo@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global 'mapas'), y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración
	.global inicializa_matriz
inicializa_matriz:
		push {r1-r9, lr}		@;guardar registros utilizados
		
		mov r4, r1			@; carga el numero de mapa de configuracion en r4
		ldr r5, =mapas		@; carga la direccion de la variable global mapas 
		mov r1, #COLUMNS
		mov r8, #ROWS
		mul r6, r1, r8
		mul r6, r4			@; r6 = columns*rows*(numero de mapa de configuracion)
		ldrb r7, [r5, r6]	@; cargamos en r7 la posicion inicial del mapa de configuracion
		
		mov r4, r0			@; movemos la direccion de la matriz base a r4 para trabajar con ella
		mov r1, #0			@; r1 es indice de fila
		mov r8, #0 			@; r8 es indice de movimiento de posiciones
		
		.LFor1:
			mov r2, #0			@; r2 es indice de columna
		.LFor2:
			ldrb r7, [r5, r6] 	@; en r7 se cargara en cada bucle el elemento variable del mapa de configuracion
			strb r7, [r4, r8]
			mov r9, r7			@; r9 es el elemento variable del mapa de configuracion
			and r7, #0x07		@; filtramos los 3 bits bajos
			cmp r7, #0x00
			bne .Lfiif
			
			.Lif:
				mov r0, #7			@; el rango del numero aleatorio será entre 0 y 6
				bl mod_random
				cmp r0, #0
				addeq r0, #1		@; si el numero aleatorio generado es 0, sumamos 1 (el rango debe estar entre 1 y 6)
				add r0, r9			@; sumamos el numero aleatorio generado a el elemento del mapa de configuracion
				strb r0, [r4, r8]	@; guardamos el nuevo numero en la posicion correspondiente de la matriz
				mov r0, r4
				mov r3, #2			@; orientacion = oeste
				bl cuenta_repeticiones
				cmp r0, #3			
				beq .Lif
				mov r0, r4
				mov r3, #3			@; orientacion = norte
				bl cuenta_repeticiones
				cmp r0, #3
				beq .Lif
			
			.Lfiif:
			
			add r6, #1			@; r6 es el indice de desplazamiento para el mapa de configuracion, augmenta en 1
			add r8, #1			@; el indice de desplazamiento de la matriz augmenta en 1
			add r2, #1			@; el indice para el bucle que recorre las columnas augmenta en 1
			cmp r2, #COLUMNS
			blo .LFor2
			
			add r1, #1			@; el indice para el bucle de las filas augmenta en 1 
			cmp r1, #ROWS
			blo .LFor1
			
		
		pop {r1-r9, pc}				@;recuperar registros y volver



@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondrá que siempre existirá una recombinación sin secuencias y
@;			con combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {r1-r10,lr}
		ldr r5, =mat_recomb1
		ldr r6, = mat_recomb2
		mov r4, r0
		
		mov r1, #0				@; r1 es indice de filas
		mov r3, #0				@; r3 es indice de desplazamiento
		
		.LFor3:
			mov r2, #0			@; r2 es indice de columnas
		.LFor4:
			ldrb r7, [r4, r3]
			
			mov r9, r7, lsr #3	@; bits 4 i 3 (2 bits altos) en r9
			and r9, #0x03
			cmp r9, #0			@; si los 2 bits altos son 00, son elementos basicos
			beq .Lcopiar_elembasicosAceros
			cmp r9, #1			@; si los 2 bits altos son 01, son gelatinas simples
			beq .Lcopiar_gelatinassimplesbasicas
			cmp r9, #2			@; si los 2 bits altos son 10, son gelatinas dobles
			beq .Lcopiar_gelatinasdoblesbasicas
			and r8, r7, #0x07
			cmp r8, #7			@; si los 3 bits bajos son unos, copiaremos cero en mat_recomb1 (dependiendo de otras comprobaciones en la funcion copia_ceros)
			beq .Lcopiar_ceros
			cmp r8, #0			@; si los 3 bits bajos son ceros, tambien copiaremos cero en mat_recomb1 (dependiendo de otras comprobaciones en la funcion copia_ceros)
			bne .Lcopiar_elementosbasicos	@; si los 3 bits bajos no son ni todo ceros ni todo unos, seran elementos basicos(dependiendo de los 2 bits altos)
			
			.Lcopiar_ceros:
				cmp r8, #0			@; si los 3 bits bajos son todos unos, será bloque o hueco
				bne .Lbloque_hueco
				cmp r9, #0			@; si los 3 bits bajos son todos ceros y los 2 bits altos son diferentes de 00, asignaremos 0 a matrecomb1
				bne .Lasignacion_ceros
				beq .Lcontinue_noasignado_matrecomb1
				
				.Lbloque_hueco:
					cmp r9, #2		@; si los 2 bits altos son 10, no será ni bloque ni hueco, no asignamos 0 a matrecomb1
					beq .Lcopiar_elementosbasicos
				
				.Lasignacion_ceros:
					mov r8, #0
					strb r8, [r5, r3]
					b .Lcontinue_asignado	
						
				b .Lcontinue_noasignado_matrecomb1	@; en caso que no se haya asignado nada, se asignara el elemento correspondiente en matrecomb1 en la funcion marcada
			
			.Lcopiar_elementosbasicos:
				and r8, r7, #0x07		@; si los 3 bits bajos no son ni todos 0 ni todos 1, ponemos los 2 bits altos a 0 para convertirlo a un elemento basico
				strb r8, [r5, r3]
				
				b .Lcontinue_asignado
			
			.Lcopiar_elembasicosAceros:
				and r8, r7, #0x07
				cmp r8, #0			
				beq .Lcontinue_noasignado_matrecomb2
				cmp r8, #7
				beq .Lcontinue_noasignado_matrecomb2
				mov r8, #0
				strb r8, [r6, r3]	@; si los 3 bits bajos no son ni todos 0 ni todos 1, asignamos 0 a matrecomb2
			
				b .Lcontinue_asignado
			
			.Lcopiar_gelatinassimplesbasicas:
				and r8, r7, #0x07
				cmp r8, #7
				beq .Lcontinue_noasignado_matrecomb2
				mov r8, #8
				strb r8, [r6, r3]	@; si los 3 bits bajos no son todos 1, asignamos la gelatina basica 8  a matrecomb2 
			
				b .Lcontinue_asignado
			
			.Lcopiar_gelatinasdoblesbasicas:
				and r8, r7, #0x07
				cmp r8, #7
				beq .Lcontinue_noasignado_matrecomb2
				mov r8, #16
				strb r8, [r6, r3]   @; si los 3 bits bajos no son todos 1, asignamos la gelatina basica 16 a matrecomb2
			
				b .Lcontinue_asignado
				
			.Lcontinue_noasignado_matrecomb1:
				strb r7, [r5, r3]
				b .Lcontinue_asignado
				
			.Lcontinue_noasignado_matrecomb2:
				strb r7, [r6, r3]
				
			.Lcontinue_asignado:
				add r3, #1
				add r2, #1
				cmp r2, #COLUMNS
				blo .LFor4
				add r1, #1
				cmp r1, #ROWS
				blo .LFor3
				
				
		@; segunda parte
		
		mov r1, #0		@; indice de filas
		mov r10, #0		@; indice de desplazamiento
		
		
		.LFor5:
			mov r2, #0	@; indice de columnas
		.LFor6:
			ldrb r7, [r4, r10]		@; cargamos en r7 el valor contenido en la posicion "i" de la matriz
			and r7, #0x07
			cmp r7, #0
			beq .LFinal				@; si el valor de r7 es 0, 8 o 16, ignoramos la actual posicion
			cmp r7, #7
			beq .LFinal				@; si el valor de r7 es 0,8,16, hueco o bloque solido, ignoramos la posicion
			
			b .Lcodigo_elemento
			
			.Lhay_secuencia:
				strb r9, [r6, r10]	@; restituimos el valor de la posicion actual de mat_recomb2
			
			.Lcodigo_elemento:
				mov r7, #COLUMNS
				mov r8, #ROWS
				mul r0, r7, r8		@; cargamos en r0 el rango para generar un numero aleatorio
				bl mod_random
				mov r7, r0			@; posicion aleatoria de mat_recomb1 en r7
				ldrb r8, [r5, r0]	@; cargamos el valor de una posicion aleatoria de mat_recomb1 en r8
				cmp r8, #0			@; si el valor que hemos cargado es 0, repetimos, hasta que no sea 0
				beq .Lcodigo_elemento
				
			
			ldrb r9, [r6, r10]		@; cargamos en r9 el valor de la posicion actual de mat_recomb2
			and r3, r9, #0x07
			cmp r3, #0				@; si es una gelatina basica 0, 8 o 16, mat_recomb2[i] = mat_recomb2[i]+mat_recomb1[aleatorio]
			addeq r8, r9
			strb r8, [r6, r10]		@; si no es una gelatina basica, mat_recomb2[i] = mat_recomb1[aleatorio]
			
			.Lcuenta_repeticiones:
				mov r0, r4
				mov r3, #2			@; orientacion = oeste
				bl cuenta_repeticiones
				cmp r0, #3			
				beq .Lhay_secuencia
				mov r0, r4
				mov r3, #3			@; orientacion = norte
				bl cuenta_repeticiones
				cmp r0, #3
				beq .Lhay_secuencia	@; si hay secuencia, restituimos el valor anterior en la posicion actual de mat_recomb2, y volvemos a coger una pos. aleatoria de mat_recomb1
			
				mov r3, #0
				strb r3, [r5, r7]	@; fijamos a 0 el valor que hemos usado de mat_recomb1
				strb r8, [r4, r10] 	@; asignamos el valor de mat_recomb2[i] en la matriz_de_juego[i]
		
		.LFinal:
			add r10, #1
			add r2, #1
			cmp r2, #COLUMNS
			blo .LFor6
			add r1, #1
			cmp r1, #ROWS
			blo .LFor5
			
	
		pop {r1-r10,pc}



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el parámetro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1-r4, lr}
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve número aleatorio restringido a rango
		
		
		
		pop {r1-r4, pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable 'seed32'
	ldr r1, [r0]				@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
