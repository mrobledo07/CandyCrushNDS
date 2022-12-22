/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: miguel.robledo@estudiants.urv.cat
	Programador 2: yyy.yyy@estudiants.urv.cat
	Programador 3: zzz.zzz@estudiants.urv.cat
	Programador 4: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy1_incl.h>


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de números aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// número de movimientos restantes
int gelees;						// número de gelatinas restantes



/* actualizar_contadores(code): actualiza los contadores que se indican con el
	parámetro 'code', que es una combinación binaria de booleanos, con el
	siguiente significado para cada bit:
		bit 0:	nivel
		bit 1:	puntos
		bit 2:	movimientos
		bit 3:	gelatinas  */
void actualizar_contadores(int code)
{
	if (code & 1) printf("\x1b[38m\x1b[1;8H %d", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}



/* Programa principal: control general del juego */
int main(void)
{
	seed32 = time(NULL);		// fijar semilla de números aleatorios
	consoleDemoInit();			// inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 1A)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);
	bool final = true;
	int i = 0;

	do							// bucle principal de pruebas
	{
		inicializa_matriz(matrix, level);
		escribe_matriz(matrix);
		retardo(5);
		printf("\x1b[39m\x1b[3;8H (pulse A)");
		do
		{	swiWaitForVBlank();
			scanKeys();	
		} while (!(keysHeld() & KEY_A));	// esperar pulsación tecla 'A'
		printf("\x1b[3;8H              ");
		retardo(5);		
		if (keysHeld() & KEY_A)			// si pulsa 'A',
		{								// pasa a siguiente nivel
			level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
			i++;
		}
		
		if (i == MAXLEVEL)
			final = false;
		
		
	} while (final);


	consoleDemoInit();
	printf("candyNDS (prueba tarea 1B)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);
	char mat_recomb1[ROWS][COLUMNS];		
	char mat_recomb2[ROWS][COLUMNS];		
	level = 0;
	i = 0;
	
	do {
		
		
		if (i == 0){
			copia_mapa(matrix,level);
			recombina_elementos(matrix);
			printf("\x1b[2;0Hmat_recomb1");
			escribe_matriz(mat_recomb1);
		}
		else if(i == 1){
			printf("\x1b[2;0Hmat_recomb2");
			escribe_matriz(mat_recomb2);
		}
		else if (i == 2){
			printf("\x1b[2;0Hmatriu__joc");
			escribe_matriz(matrix);
		}

		retardo(5);
		printf("\x1b[39m\x1b[3;8H (pulse B)");
		
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'B'
		} while (!(keysHeld() & KEY_B));
		printf("\x1b[3;8H              ");
		retardo(5);	

		if (keysHeld() & KEY_B)			// si pulsa 'B'
			i++;
			
		if (i == 3)
		{
			level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
			i = 0;
		}

		
	} while (1);

	return(0);

}