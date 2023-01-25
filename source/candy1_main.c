/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: xxx.xxx@estudiants.urv.cat
	Programador 2: yyy.yyy@estudiants.urv.cat
	Programador 3: victor.fosch@estudiants.urv.cat
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
/* ---------------------------------------------------------------- */
/* candy1_main.c : función principal main() para test de tarea 1F 	*/
/* ---------------------------------------------------------------- */
#define NUMTESTS 14
short nmap[] = {11, 10, 11, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 8};

int main(void)
{
	seed32 = time(NULL);
	int ntest = 0;
	int movimiento;

	consoleDemoInit();			// inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 1F)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	level = nmap[0];
	actualizar_contadores(1);
	copia_mapa(matrix, level);
	escribe_matriz(matrix);
	do							// bucle principal de pruebas
	{
		printf("\x1b[39m\x1b[2;0H test %d: bajada vertical", ntest);
		
		do
		{
			movimiento = baja_elementos(matrix);
			retardo(20);
			escribe_matriz(matrix);
		} while(movimiento == 1);

		retardo(5);
		printf("\x1b[38m\x1b[5;19H (pulse A)");
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A'
		} while (!(keysHeld() & KEY_A));
		
		retardo(5);
		if (keysHeld() & KEY_A)		// si pulsa 'A'
		{
			ntest++;				// siguiente test
			if ((ntest < NUMTESTS) && (nmap[ntest] != level))
			{				// si número de mapa del siguiente test diferente
				level = nmap[ntest];		// del número de mapa actual,
				actualizar_contadores(1);		// cambiar el mapa actual
				copia_mapa(matrix, level);
				escribe_matriz(matrix);
			}
		}
	} while (ntest < NUMTESTS);		// bucle de pruebas
	printf("\x1b[38m\x1b[5;19H (fin tests)");
	do { swiWaitForVBlank(); } while(1);	// bucle infinito
	return(0);
}