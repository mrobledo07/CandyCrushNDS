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
@; n�mero de secuencia: se utiliza para generar n�meros de secuencia �nicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r11, lr}
		mov r1, #0                  @; �ndex files (i)
		mov r2, #0                  @; �ndex columnes (j)
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
		ldrb r8, [r0, r7]           @; Contingut de la posici� (i, j) de la matriu
		
		cmp r8, #0
		ble .Lif2                   @; Casella buida
		
		cmp r8, #7                  
		beq .Lif2                   @; Bloc s�lid
		
		cmp r8, #8
		beq .Lif2                   @; Casella buida
		
		cmp r8, #15
		beq .Lif2                   @; Espai buit
		
		cmp r8, #16
		beq .Lif2                   @; Casella buida
		
		cmp r8, #23
		bge .Lif2                   @; Entrada "inv�lida"
		
		sub r9, r5, #1
		cmp r1, r9
		bge .Lif1
		
		mov r3, #1                  @; Orientaci� sud de la rutina cuenta_repeticiones
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
		mov r3, #0                  @; Orientaci� est de la rutina cuenta_repeticiones
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
@;	secuencias de 3 o m�s elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, as� como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	adem�s, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador �nico para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r2-r11, lr}
		mov r2, #0                  @; �ndex files (i)
		mov r3, #0                  @; �ndex columnes (j)
		mov r5, #ROWS
		mov r6, #COLUMNS
		mov r7, #0                  @; 0 a col�locar a la posici� (i, j) de la matriu de marques
		
		.LForFila:
		cmp r2, r5
		beq .LFiForFila
		
		.LForColumna:
		cmp r3, r6
		beq .LFiForColumna
		
		mla r8, r2, r6, r3          
		strb r7, [r1, r8]            @; Matriu de marques[i][j] = 0
		add r3, #1                   @; j++
		b .LForColumna
		
		.LFiForColumna:
		add r2, #1                   @; i++
		mov r3, #0                   @; j = 0
		b .LForFila
		
		.LFiForFila:
		bl marcar_horizontales
		bl marcar_verticales
		
		mov r2, #0                   @; �ndex files (i)
		mov r3, #0                   @; �ndex columnes (j)                  
		mov r4, #8                   @; 8 a col�locar si hi ha element amb gelatina doble
		
		.LForFila2:
		cmp r2, r5
		beq .LFiForFila2
		
		.LForColumna2:
		cmp r3, r6
		beq .LFiForColumna2
		
		mla r8, r2, r6, r3
		ldrb r9, [r0, r8]            @; Contingut de la posici� (i, j) de la matriu del joc.
		
		mla r10, r2, r6, r3
		ldrb r11, [r1, r10]          @; Contingut de la posici� (i, j) de la matriu de marques.
		
		cmp r11, #0                  @; Torna al principi del bucle si matriu de marques[i][j] == 0 (no hi ha seq��ncia)
		addeq r3, #1
		beq .LForColumna2
		
		cmp r9, #0                   @; Torna al principi del bucle si matriu[i][j] <= 0  (Casella buida)
		addls r3, #1
		bls .LForColumna2
		
		cmp r9, #7                   @; Torna al principi del bucle si matriu[i][j] == 7  (Bloc s�lid)
		addeq r3, #1
		beq .LForColumna2
		
		cmp r9, #8                   @; Torna al principi del bucle si matriu[i][j] == 8  (Gel. buida)
		addeq r3, #1 
		beq .LForColumna2
		
		cmp r9, #15                  @; Torna al principi del bucle si matriu[i][j] == 15 (espai buit)
		addeq r3, #1
		beq .LForColumna2
		
		cmp r9, #16                  @; Torna al principi del bucle si matriu[i][j] == 16 (Gel. doble buida)
		addeq r3, #1
		beq .LForColumna2
		
		cmp r9, #17                  @; Amb les restriccions anteriors, matriu[i][j]<17 implica element simple o element simple amb gelatina simple  
		bhs .LGelDoble               @; matriu[i][j] > 17 implica element simple amb gelatina doble
		
		strb r7, [r0, r8]            @; matriu[i][j] = 0
		add r3, #1
		b .LForColumna2
		
		LGelDoble:
		cmp r9, #23                  @; Torna al principi del bucle si matriu[i][j] >= 23 (El valor m�xim �s 22)
		addhs r3, #1
		bhs .LForColumna2
		
		strb r4, [r0, r8]            @; matriu[i][j] = 8
		add r3, #1                   @; j++
		b .LForColumna2
		
		.LFiForColumna2:
		add r2, #1
		mov r3, #0
		b .LForFila2
		
		.LFiForFila:
		pop {r2-r11, pc}


	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o m�s
@;	elementos repetidos consecutivamente en horizontal, con un n�mero identifi-
@;	cativo diferente para cada secuencia, que empezar� siempre por 1 y se ir�
@;	incrementando para cada nueva secuencia, y cuyo �ltimo valor se guardar� en
@;	la variable global 'num_sec'; las marcas se guardar�n en la matriz que se
@;	pasa por par�metro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' est� toda a ceros
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
marcar_horizontales:
		push {lr}
		
		
		pop {pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o m�s
@;	elementos repetidos consecutivamente en vertical, con un n�mero identifi-
@;	cativo diferente para cada secuencia, que seguir� al �ltimo valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardar�n en la matriz que se
@;	pasa por par�metro 'mat' (por referencia);
@;	sin embargo, habr� que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habr�n
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' est� marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendr� el siguiente indentificador (>1)
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
marcar_verticales:
		push {lr}
		
		
		pop {pc}



.end
