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
		push {r1-r10, lr}
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
		add r2, #1
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
		push {lr}
		
		
		pop {pc}


	
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
		push {lr}
		
		
		pop {pc}



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
		push {lr}
		
		
		pop {pc}



.end
