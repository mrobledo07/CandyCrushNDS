/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Test rutina 1D
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: alex.casanova@estudiants.urv.cat


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
char mat_mar[ROWS][COLUMNS];    // matriz de marcas


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

int main(void)
{
    consoleDemoInit();
	copia_mapa(matrix, level);
	printf("CandyNDS (prueba tarea 1D)");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);
	do
	{
		printf("\x1b[38m\x1b[3;19H (pulse A/B)");
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A' o 'B'
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		printf("\x1b[3;0H                               ");
		retardo(5);
		if(keysHeld() & KEY_A)          // Si pulsa A muestra la matriz con los elementos eliminados
		{
		   elimina_secuencias(matrix, mat_mar);
		   escribe_matriz(matrix);
		}
		if(keysHeld() & KEY_B)          // Si pulsa B pasa al siguiente nivel
		{
		    level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
			copia_mapa(matrix, level);
		    escribe_matriz(matrix);
		}

	}while(1);
	return (0);
}