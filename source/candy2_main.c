	
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy2_incl.h>
#include <candy1_incl.h>

	
	
/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de n�meros aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// n�mero de movimientos restantes
int gelees;						// n�mero de gelatinas restantes



/* actualizar_contadores(code): actualiza los contadores que se indican con el
	par�metro 'code', que es una combinaci�n binaria de booleanos, con el
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



int main(void)
{
	seed32 = time(NULL);		// fijar semilla de n�meros aleatorios
	consoleDemoInit();			// inicializaci�n de pantalla de texto
	printf("candyNDS (prueba tarea 1A)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);
	init_grafA();
	

	do							// bucle principal de pruebas
	{
		inicializa_matriz(matrix, level);
		recombina_elementos(matrix);
		genera_sprites(matrix);
		escribe_matriz(matrix);
		
		retardo(5);
		printf("\x1b[39m\x1b[3;8H (pulse A)");
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsaci�n tecla 'A'
		} while (!(keysHeld() & KEY_A ));
		printf("\x1b[3;8H              ");
		retardo(5);		
		if (keysHeld() & KEY_A)			// si pulsa 'A',
		{								// pasa a siguiente nivel
			level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
		}
	} while (1);
	return(0);
}
