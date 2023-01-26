@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: alex.casanova@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: alex.casanova@estudiants.urv.cat				  ===
@;=                                                           		   	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; número de secuencia: se utiliza para generar números de secuencia únicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r11, lr}
		mov r1, #0                  @; Índex files (i)
		mov r2, #0                  @; Índex columnes (j)
		mov r5, #ROWS
		mov r6, #COLUMNS
		mov r10, #0                 @; Resultats de cuenta_repeticiones
		.LForFila:
		cmp r1, r5
		beq .LFiForFila
		.LForColumna:
		cmp r2, r6
		beq .LFiForColumna
		mla r7, r1, r6, r2
		ldrb r8, [r0, r7]           @; Contingut de la posició (i, j) de la matriu
		
		cmp r8, #0
		ble .Lif2                   @; Casella buida
		
		cmp r8, #7                  
		beq .Lif2                   @; Bloc sòlid
		
		cmp r8, #8
		beq .Lif2                   @; Casella buida
		
		cmp r8, #15
		beq .Lif2                   @; Espai buit
		
		cmp r8, #16
		beq .Lif2                   @; Casella buida
		
		cmp r8, #23
		bge .Lif2                   @; Entrada "invàlida"
		
		sub r9, r5, #1
		cmp r1, r9
		bge .Lif1
		
		mov r3, #1                  @; Orientació sud de la rutina cuenta_repeticiones
		mov r4, r0                  @; Matriu a R4
		bl cuenta_repeticiones
		mov r10, r0                  
		mov r0, r4                  @; Recuperem la matriu
		
		.Lif1:
		cmp r10, #3
		bge .LFiForFila
		
		sub r11, r6, #1
		cmp r2, r11
		bge .Lif2
		mov r3, #0                  @; Orientació est de la rutina cuenta_repeticiones
		mov r4, r0                  @; Matriu a R4
		bl cuenta_repeticiones
		mov r10, r0
		mov r0, r4                  @; Recuperem la matriu
		
		.Lif2:
		cmp r10, #3
		bge .LFiForFila
		add r2, #1                  @; j++
		b .LForFila
		
		.LFiForColumna:
		add r1, #1                  @; i++
		mov r2, #0                  @; j = 0
		b .LForFila
		
		.LFiForFila:
		mov r0, #1
		cmp r10, #3
		bge .LFiRutina
		mov r0, #0
		
		.LFiRutina:
		
		pop {r1-r11, pc}



@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o más elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, así como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	además, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador único para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r2-r10, lr}
		mov r2, #0                  @; Índex files (i)
		mov r3, #0                  @; Índex columnes (j)
		mov r5, #ROWS
		mov r6, #COLUMNS
		mov r7, #0                  @; 0 a col·locar a la posició (i, j) de la matriu de marques
		
		.LForFila2:
		cmp r2, r5
		beq .LFiForFila2
		
		.LForColumna2:
		cmp r3, r6
		beq .LFiForColumna2
		
		mla r8, r2, r6, r3          
		strb r7, [r1, r8]            @; Matriu de marques[i][j] = 0
		add r3, #1                   @; j++
		b .LForColumna2
		
		.LFiForColumna2:
		add r2, #1                   @; i++
		mov r3, #0                   @; j = 0
		b .LForFila2
		
		.LFiForFila2:
		bl marcar_horizontales
		bl marcar_verticales
		
		mov r2, #0                   @; Índex files (i)
		mov r3, #0                   @; Índex columnes (j)                  
		mov r4, #8                   @; 8 a col·locar si hi ha element amb gelatina doble
		
		.LForFila3:
		cmp r2, r5
		beq .LFiForFila3
		
		.LForColumna3:
		cmp r3, r6
		beq .LFiForColumna3
		
		mla r8, r2, r6, r3
		ldrb r9, [r0, r8]            @; Contingut de la posició (i, j) de la matriu del joc.
		ldrb r10, [r1, r8]           @; Contingut de la posició (i, j) de la matriu de marques.
		
		cmp r10, #0                  @; Torna al principi del bucle si matriu de marques[i][j] == 0 (no hi ha seqüència)
		addeq r3, #1
		beq .LForColumna3
		
		cmp r9, #0                   @; Torna al principi del bucle si matriu[i][j] <= 0  (Casella buida)
		addls r3, #1
		bls .LForColumna3
		
		cmp r9, #7                   @; Torna al principi del bucle si matriu[i][j] == 7  (Bloc sòlid)
		addeq r3, #1
		beq .LForColumna3
		
		cmp r9, #8                   @; Torna al principi del bucle si matriu[i][j] == 8  (Gel. buida)
		addeq r3, #1 
		beq .LForColumna3
		
		cmp r9, #15                  @; Torna al principi del bucle si matriu[i][j] == 15 (espai buit)
		addeq r3, #1
		beq .LForColumna3
		
		cmp r9, #16                  @; Torna al principi del bucle si matriu[i][j] == 16 (Gel. doble buida)
		addeq r3, #1
		beq .LForColumna3
		
		cmp r9, #17                  @; Amb les restriccions anteriors, matriu[i][j]<17 implica element simple o element simple amb gelatina simple  
		bhs .LGelDoble               @; matriu[i][j] >= 17 implica element simple amb gelatina doble
		
		strb r7, [r0, r8]            @; matriu[i][j] = 0
		add r3, #1
		b .LForColumna3
		
		.LGelDoble:
		cmp r9, #23                  @; Torna al principi del bucle si matriu[i][j] >= 23 (El valor màxim és 22)
		addhs r3, #1
		bhs .LForColumna3
		
		strb r4, [r0, r8]            @; matriu[i][j] = 8
		add r3, #1                   @; j++
		b .LForColumna3
		
		
		
		.LFiForColumna3:
		add r2, #1
		mov r3, #0
		b .LForFila3
		
		.LFiForFila3:
		pop {r2-r10, pc}


	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en horizontal, con un número identifi-
@;	cativo diferente para cada secuencia, que empezará siempre por 1 y se irá
@;	incrementando para cada nueva secuencia, y cuyo último valor se guardará en
@;	la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' está toda a ceros
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_horizontales:
		push {r2-r12, lr}
		mov r4, r0                  @; R4: Matriu del joc
		mov r5, r1                  @; R5: Matriu de marques
		mov r1, #0                  @; Índex files (i)
		mov r2, #0                  @; Índex columnes (j)
		mov r6, #0                  @; num_sec
		mov r7, #ROWS
		mov r8, #COLUMNS
		
		.LForFila4:
		cmp r1, r7
		beq .LFiForFila4
		
		.LForColumna4: 
		cmp r2, r8
		beq .LFiForColumna4
		
		mla r9, r1, r8, r2
		ldrb r10, [r4, r9]          @; Contingut de la posició (i, j) de la matriu del joc
		
		cmp r10, #0
		addls r2, #1
		bls .LForColumna4           @; Torna al principi del bucle si matriu[i][j] <= 0  (Casella buida)
		
		cmp r10, #7
		addeq r2, #1
		beq .LForColumna4           @; Torna al principi del bucle si matriu[i][j] == 7  (Bloc sòlid)
		
		cmp r10, #8
		addeq r2, #1
		beq .LForColumna4           @; Torna al principi del bucle si matriu[i][j] == 8  (Gel. buida)
		
		cmp r10, #15
		addeq r2, #1
		beq .LForColumna4            @; Torna al principi del bucle si matriu[i][j] == 15  (Espai buit)
		
		cmp r10, #16
		addeq r2, #1
		beq .LForColumna4            @; Torna al principi del bucle si matriu[i][j] == 16  (Gel. doble buida)
		
		cmp r10, #23
		addhs r2, #1
		bhs .LForColumna4            @; Torna al principi del bucle si matriu[i][j] >= 23  (El màxim és 22)
		
		mov r0, r4                  @; Recuperem la matriu del joc
        mov r3, #0                  @; Orientació "est" a la rutina cuenta_repeticiones
		
		bl cuenta_repeticiones      @; Retorna a R0 el nombre de repeticions d'un element
		mov r11, r0
		cmp r0, #3
		blo .LFiWhile
		
		add r6, #1                  @; num_sec++
		
		.LWhile:
		cmp r0, #0
		beq .LFiWhile
		
		mov r12, #0
		add r12, r2, r0 
		sub r12, #1                 @; j + repeticions - 1
		
		mla r9, r1, r8, r12
		strb r6, [r9, r5]           @; Matriu de marques[i][j+repeticions-1] = num_sec
		sub r0, #1                  @; repeticions--
		b .LWhile
		
		.LFiWhile:
		add r2, r2, r11             @; j = j + repeticions (per no repetir el procés havent detectat repeticions)
		b .LForColumna4
		
		.LFiForColumna4:
		add r1, #1                  @; i++
		mov r2, #0                  @; j = 0
		b .LForFila4
		
		.LFiForFila4:
		mov r0, r4
		mov r1, r5
		mov r2, #0
		ldrb r2, =num_sec           @; R2 apunta a num_sec
		strb r6, [r2]               @; Guardem el valor de num_sec
		pop {r2-r12, pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en vertical, con un número identifi-
@;	cativo diferente para cada secuencia, que seguirá al último valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia);
@;	sin embargo, habrá que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habrán
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' está marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendrá el siguiente indentificador (>1)
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_verticales:
		push {r2-r12, lr}
		mov r4, r0
		mov r5, r1
		mov r1, #0                  @; Índex files (i)
		mov r2, #0                  @; Índex columnes (j)
		mov r6, #ROWS
		mov r7, #COLUMNS
		
		ldrb r8, =num_sec
		
		.LForColumna5:              @; Es fa un recorregut columna per columna
		cmp r2, r7 
		beq .LFiForColumna5
		
		.LForFila5:
		cmp r1, r6
		beq .LFiForFila5
		
		mla r9, r1, r7, r2
		ldrb r10, [r4, r9]          @; Posició (i, j) de la matriu de joc
		
		cmp r10, #0                 
		addls r1, #1
		bls .LForFila5              @; Torna al principi del bucle si matriu[i][j] <= 0  (Casella buida)
		
		cmp r10, #7
		addeq r1, #1
		beq .LForFila5              @; Torna al principi del bucle si matriu[i][j] == 7  (Bloc sòlid)
		
		cmp r10, #8
		addeq r1, #1
		beq .LForFila5              @; Torna al principi del bucle si matriu[i][j] == 8  (Gel. simple)
		
		cmp r10, #15                @; Torna al principi del bucle si matriu[i][j] == 15  (Espai buit)
		addeq r1, #1
		beq .LForFila5
		
		cmp r10, #16                @; Torna al principi del bucle si matriu[i][j] == 16  (Gel. doble)
		addeq r1, #1
		beq .LForFila5
		
		cmp r10, #23                @; Torna al principi del bucle si matriu[i][j] >= 23 (El màxim és 22)
		addhs r1, #1
		bhs .LForFila5
		
		mov r0, r4
		mov r3, #1                  @; Orientació "sud" a cuenta_repeticiones
		bl cuenta_repeticiones 
		
		mov r10, r0                 @; Variable auxiliar = repeticions
		mov r11, r0                 @; Variable auxiliar 2 = repeticions
		cmp r10, #3
		
		blo .LRep
		
		mov r0, #0
		.LWhile2:
		cmp r10, #0
		beq .LFiWhile2
		cmp r0, #1
		beq .LFiWhile2
		
		mov r12, #0
		add r12, r10, r1
		sub r12, #1                 @; i + repeticions - 1
		
		mla r9, r12, r7, r2
		ldrb r12, [r5, r9]          @; Contingut de Matriu de marques[i+rep.-1][j]
		
		cmp r12, #0
		moveq r0, #1
		
		sub r10, #1                
		b .LWhile2
		
		.LFiWhile2:
		
		cmp r0, #1
		bne .LFiWhile3
		add r8, #1
	    mov r10, r11
		
		.LWhile3:
		cmp r10, #0
		beq .LRep
		
		mov r12, #0
		add r12, r10, r1
		sub r12, #1
		
		mla r9, r12, r7, r2
		strb r8, [r9, r5]
		sub r10, #1
		b .LWhile3
		
		.LFiWhile3:
		
		mov r0, r11
		
		.LWhile4:
		cmp r0, #0
		beq .LRep
		
		mov r12, #0
		add r12, r0, r1
		sub r12, #1
		
		mla r9, r12, r7, r2
		ldrb r9, [r5, r9]
		
		mov r12, #0
		add r12, r10, r1
		sub r12, #1
		
		
		mul r12, r7, r12	
		add r12, r12, r2
		strb r9, [r5, r12]
		
		sub r0, #1
		b .LWhile4
		
		.LRep:
		add r1, r11                      @; I = I + repeticions (per no haver de tornar a aquella posició si s'han detectat repeticions)
		b .LForFila5
		
		.LFiForFila5:
		mov r1, #0                       @; i = 0
		add r2, #1                       @; j++
		b .LForColumna5
		
		.LFiForColumna5:
		mov r0, r4
		mov r1, r5
		pop {r2-r12, pc}



.end
