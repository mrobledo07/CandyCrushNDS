/*------------------------------------------------------------------------------

	$ candy2_sopo.c $

	Funciones de soporte para el programa principal (ver 'candy2_main.c')
	
	Analista-programador: santiago.romani@urv.cat
	
------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <candy2_incl.h>


/* variables globales */
char mat_mar[ROWS][COLUMNS];	// matriz de marcas
char pos_sug[6];				// posiciones sugerencia de combinaci�n
char ele_sug[3];				// elementos de las posiciones sugeridas
char texto[12];					// texto de puntuaciones
int ult_tex = 0;				// �ltimo n�mero de textos de puntuaci�n
int num_pun = 0;				// n�mero de puntuaciones



/* escribe_matriz(*mat): escribe por pantalla de texto de la NDS el contenido
	de la matriz usando secuencias escape de posicionamiento en fila y
	columna (\x1b['fila';'columna'H), donde 'fila' es una coordenada entre 0 y
	23, y columna es una coordenada entre 0 y 31, y la posici�n (0,0) correspon-
	de a la casilla superior izquierda;
	adem�s, se usa la secuencia escape para cambiar el color del texto
	(\x1b['color'm), donde 'color' es un c�digo de color de la librer�a NDS */
void escribe_matriz(char mat[][COLUMNS])
{
	int i, j, value, color;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			value = mat[i][j];		// obtiene el valor del elemento (i,j)
			if (value != 15)
			{
				if (value == 7)
					color = 39;				// el color del bloque
				else if (value > 16)
					color = 38;				// el color de la gelatina doble
				else if (value > 8)
					color = 37;				// el color de la gelatina simple
				else
					color = 40+value;		// el color normal
				printf("\x1b[%dm", color);
				if (value == 255)
					printf("\x1b[%d;%dH_ ",(i*2+DFIL),(j*2+1));
				else
					printf("\x1b[%d;%dH%d ",(i*2+DFIL),(j*2+1),(value % 8));
			}
			else printf("\x1b[%d;%dH  ",(i*2+DFIL),(j*2+1));
		}
	}
}


/* contar_gelatinas(*mat): calcula cuantas gelatinas quedan en la matriz de
	juego, contando 1 para gelatines simples y 2 para gelatinas dobles */
int contar_gelatinas(char mat[][COLUMNS])
{
	int i, j, value, count = 0;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			value = mat[i][j];			// obtiene el valor del elemento (i,j)
			if ((value >= 16) && (value < 23))
				count += 2;				// cuenta 2 por gelatina doble
			else if ((value >= 8) && (value < 15))
				count++;				// cuenta 1 por gelatina simple
		}
	}
	if (count > 0) activa_timer2();
	else desactiva_timer2();
	
	return(count);
}


/* retardo(dsecs): pone el programa en pausa durante el n�mero de d�cimas de
	segundo que indica el par�metro */
void retardo(int dsecs)
{	
	int i, j;
	
	for (i = 0; i < dsecs; i++)		// por cada d�cima de segundo
		for (j = 0; j < 6; j++)		// esperar 6 retrocesos verticales
			swiWaitForVBlank();
}



/* procesar_touchscreen(*mat, *p1X, *p1Y, *p2X, *p2Y): procesa la entrada de la
	pantalla t�ctil esperando a que el usuario realice un movimiento de
	intercambio v�lido, desde una posici�n de la matriz (p1X,p1Y) hasta otra
	posici�n (p2X,p2Y) que deber� ser contig�a en horizontal y en vertical,
	y s�lo deber� contener elementos simples (sin gelatinas ni espacios ni
	bloques s�lidos);
	devuele cierto (1) si el movimiento es posible, o falso (0) si no lo es,
	adem�s de cargar las coordenadas en las variables que se han pasado por
	referencia */
int procesar_touchscreen(char mat[][COLUMNS],
									int *p1X, int *p1Y, int *p2X, int *p2Y)
{
	touchPosition	posXY;			// variables de detecci�n de pulsaciones
	int v1X, v1Y, v2X, v2Y;
	char temp1, temp2;

	swiWaitForVBlank();			
	scanKeys();
	if (keysHeld() & KEY_TOUCH)			// detecta pulsaci�n en pantalla
	{
		touchRead(&posXY);					// capta posici�n (x,y), en p�xeles
		v1X = posXY.px / MTWIDTH;			// convierte a posici�n matriz
		v1Y = posXY.py / MTHEIGHT;
		v2X = v1X;							// igualar coordenadas segunda pos.
		v2Y = v1Y;
		while ((keysHeld() & KEY_TOUCH) &&		// mientras se est� tocando
				(v2X == v1X) && (v2Y == v1Y))	// y no hay nueva posici�n
		{
			touchRead(&posXY);					// capta nuevas posiciones
			v2X = posXY.px / MTWIDTH;
			v2Y = posXY.py / MTHEIGHT;
			swiWaitForVBlank();
			scanKeys();
		}
		if ((v2X != v1X) || (v2Y != v1Y))		// si tenemos nueva posici�n
		{
			if (v2X > v1X) v2X = v1X + 1;		// limitar rango movimientos
			else if (v2X < v1X) v2X = v1X - 1;
			if (v2Y > v1Y) v2Y = v1Y + 1;
			else if (v2Y < v1Y) v2Y = v1Y - 1;
			if ((v2X != v1X) && (v2Y != v1Y))	// si hay movimiento en dos
				v2Y = v1Y;						// direcciones, priorizar X
				
			temp1 = mat[v1Y][v1X] & 0x7;
			temp2 = mat[v2Y][v2X] & 0x7;
			if ((temp1 > 0) && (temp1 < 7) && (temp2 > 0) && (temp2 < 7))
			{
				*p1X = v1X; *p1Y = v1Y;
				*p2X = v2X; *p2Y = v2Y;
				return 1;
			}
		}
	}
	return 0;
}


/* reducir_elementos(*mat): almacena los c�digos de los 3 elementos contenidos
	en las posiciones de la matriz de juego indicadas en el vector 'pos_sug[6]'
	dentro del vector 'ele_sug[3]', para luego colocar un c�digo -1 en dichas
	posiciones, lo cual provocar� que la funci�n 'escribe_matriz()' muestre
	un car�cter '_' (elemento oculto).
	inicia el timer 1 para reproducir el efecto de escalado de los sprites. */
void reducir_elementos(char mat[][COLUMNS])
{
	int i,x,y;
	
	for (i=0; i<3; i++)
	{
		x = pos_sug[i*2];
		y = pos_sug[i*2+1];
		activa_escalado(y, x);
		ele_sug[i] = mat[y][x];
		mat[y][x] = -1;
	}
	escribe_matriz(mat);
	activa_timer1(0);
	while (timer1_on) swiWaitForVBlank();
}


/* aumentar_elementos(*mat): restablece los c�digos de los 3 elementos contenidos
	en las posiciones de la matriz de juego indicadas en el vector 'pos_sug[6]',
	seg�n el contenido del vector 'ele_sug[3]'.
	inicia el timer 1 para reproducir el efecto de escalado de los sprites. */
void aumentar_elementos(char mat[][COLUMNS])
{
	int i,x,y;
	
	activa_timer1(1);
	while (timer1_on) swiWaitForVBlank();
	for (i=0; i<3; i++)
	{
		x = pos_sug[i*2];
		y = pos_sug[i*2+1];
		desactiva_escalado(y, x);
		mat[y][x] = ele_sug[i];
	}
	escribe_matriz(mat);
}



/* intercambia_posiciones(*mat, p1X, p1Y, p2X, p2Y): intercambia los
	elementos de las dos posiciones de la matriz que indican los par�metros,
	conservando las caracter�sticas de gelatina en las posiciones originales.
	inicia el timer 0 para reproducir el movimiento de los sprites.*/
void intercambia_posiciones(char mat[][COLUMNS],
											int p1X, int p1Y, int p2X, int p2Y)
{
	char temp1 = mat[p1Y][p1X];
	char temp2 = mat[p2Y][p2X];
	mat[p1Y][p1X] = (temp2 & 0x7) | (temp1 & 0xF8);
	mat[p2Y][p2X] = (temp1 & 0x7) | (temp2 & 0xF8);

	activa_elemento(p1Y,p1X,p2Y,p2X);
	activa_elemento(p2Y,p2X,p1Y,p1X);
	activa_timer0(1);
	while (timer0_on) swiWaitForVBlank();
}




/* detectar_combo(nhor,nver,mensaje): funci�n auxiliar para detectar el tipo
	de combinaci�n de secuencias hallado con la funci�n 'marca_combos', a partir
	de las longitudes m�ximas de secuencia horizontal 'nhor' y vertical 'nver',
	generando el mensaje correspondiente sobre el string pasado por referencia
	'mensaje' y devolviendo como resultado los puntos correspondientes a la
	combinaci�n. */
int detectar_combo(int nhor, int nver, char mensaje[])
{
	int combi = 0;
	int puntos = 0;
	
	if (nver < 3)			// si s�lo secuencia horizontal
	{
		if (nhor == 3) 
		{
			sprintf(mensaje, "SH3: %3d", PUNT_SEC3);
			puntos = PUNT_SEC3;
		}
		else if (nhor == 4) 
		{
			sprintf(mensaje, "SH4: %3d", PUNT_SEC4);
			puntos = PUNT_SEC4;
		}
		else if (nhor == 5) 
		{
			sprintf(mensaje, "SH5: %3d", PUNT_SEC5);
			puntos = PUNT_SEC5;
		}
	}
	else if (nhor < 3)		// si s�lo secuencia vertical
	{
		if (nver == 3) 
		{
			sprintf(mensaje, "SV3: %3d", PUNT_SEC3);
			puntos = PUNT_SEC3;
		}
		else if (nver == 4) 
		{
			sprintf(mensaje, "SV4: %3d", PUNT_SEC4);
			puntos = PUNT_SEC4;
		}
		else if (nver == 5) 
		{
			sprintf(mensaje, "SV5: %3d", PUNT_SEC5);
			puntos = PUNT_SEC5;
		}
	}
	else					// en caso de combinaci�n de secuencias
	{						// calcular la suma de sec. horizontal y vertical
		combi = nhor + nver - 1;	// restando 1 por la casilla de coincidencia
		if (combi == 5)
		{
			sprintf(mensaje, "CB5: %3d", PUNT_COM5);
			puntos = PUNT_COM5;
		}
		else if (combi == 6) 
		{
			sprintf(mensaje, "CB6: %3d", PUNT_COM6);
			puntos = PUNT_COM6;
		}
		else if (combi == 7) 
		{
			sprintf(mensaje, "CB7: %3d", PUNT_COM7);
			puntos = PUNT_COM7;
		}
	}
	return(puntos);
}


/* calcula_puntuaciones(*mar): detecta los conjuntos de secuencias indicados en
	la matriz que se pasa por par�metro, donde cada conjunto se marca con un
	identificador �nico, y obtiene el tipo de combinaci�n (combo) que corres-
	ponde a la longitud m�xima de secuencias en horizontal y en vertical; dicho
	tipo se muestra por pantalla (para cada conjunto) y se devuelve el total
	de puntos acumulados como resultado de la funci�n.
 ATENCI�N:	esta funci�n requiere de la correcta implementaci�n de la rutina
			'cuenta_repeticiones', ubicada en el fichero 'candy1_move.s' */
int calcula_puntuaciones(char mar[][COLUMNS])
{
	int i,j,k,m,m2,n;
	int nh,nv,puntos,total;
	
	total = 0;
	for (i=0; i<ROWS; i++)					// para todas las filas
	{
		for (j=0; j<COLUMNS; j++)			// para todas las columnas
		{
			if (mar[i][j] != 0)			// si detecta un identificador
			{
				nh = cuenta_repeticiones(mar,i,j,0);
				if (nh > 1)	
				{							// hay una secuencia horizontal
					nv = 1; k = 0;
					do
					{			// busca combinaciones verticales
						m = cuenta_repeticiones(mar,i,j+k,1);
						if (m > nv) nv = m;			// actualizar m�ximo vert.
						for (n=0; n<m; n++)
							mar[i+n][j+k] = 0;		// eliminar marca
						k++;
					} while (k < nh);
				}
				else
				{							// hay una secuencia vertical
					nv = cuenta_repeticiones(mar,i,j,1);
					nh = 1; k = 0;
					do
					{			// busca combinaciones horizontales 
						m = cuenta_repeticiones(mar,i+k,j,0);
							// tambi�n hacia atr�s (Oeste), para comb. cruzadas
						m2 = cuenta_repeticiones(mar,i+k,j,2) - 1;
						m += m2;					// m = longitud total sec.
						if (m > nh) nh = m;			// actualizar m�ximo hor.
						for (n=0; n<m; n++)
							mar[i+k][j+n-m2] = 0;	// eliminar marca
						k++;
					}  while (k < nv);
				}
				puntos = detectar_combo(nh,nv,texto);
				printf("\x1b[%dm\x1b[%d;20H %s",(37 + num_pun%3),
														(12+ult_tex), texto);
				ult_tex++;
				total += puntos;
			}
		}
	}
	return(total);
}


/* borra_puntuaciones(): permite eliminar los textos de puntuaciones anteriores,
	adem�s de poner el contador 'ult_tex' a cero e incrementar el contador
	'num_pun' */
void borra_puntuaciones()
{
	int i;
	
	for (i=0; i<ult_tex; i++)
		printf("\x1b[%d;20H            ",(12+i));
	ult_tex = 0;
	num_pun++;
}



/* copia_mapa(*mat, num_map): copia directamente el contenido del mapa de
	configuraci�n 'num_map' (almacenado en la variable global 'mapas') dentro
	de la matriz de juego 'mat' */
void copia_mapa(char mat[][COLUMNS], int num_map)
{
	int i, j;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			mat[i][j] = mapas[num_map][i][j];		// copia elemento (i,j)
		}
	}
}
