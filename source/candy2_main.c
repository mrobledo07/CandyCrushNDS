#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy2_incl.h>

	
	
/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de números aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// número de movimientos restantes
int gelees;						// número de gelatinas restantes
int cont;

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


void inicializa_interrupciones()
{
	irqSet(IRQ_VBLANK, rsi_vblank);
	TIMER0_CR = 0x00;  		// inicialmente el timer no genera interrupciones
	irqSet(IRQ_TIMER0, rsi_timer0);		// cargar direcciones de las RSI
	irqEnable(IRQ_TIMER0);				// habilitar la IRQ correspondiente
}


int main(void)
{
	int i = 0;
	bool final = false;
	seed32 = time(NULL);			// fijar semilla de números aleatorios
	init_grafA();					// cargamos información gráfica
	inicializa_interrupciones();	// inicializamos timer y habilitamos su IRQ
	
	consoleDemoInit();			// inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 2A)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);
	
	
	do							// bucle principal de pruebas
	{
		
		inicializa_matriz(matrix, level);
		genera_sprites(matrix);
		escribe_matriz(matrix);
		
	
		retardo(5);
		printf("\x1b[39m\x1b[3;8H (pulse A)");
		
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A'
		} while (!(keysHeld() & KEY_A));
		
		printf("\x1b[3;8H              ");
		retardo(5);		
		
		if (keysHeld() & KEY_A)			// si pulsa 'A',
		{								// pasa a siguiente nivel
			level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
			i++;
		}
		
		if(i == MAXLEVEL)
			final = true;
		
	} while (!final);
	
	
	
	consoleDemoInit();			// inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 2E)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	actualizar_contadores(1);
	//la parte de la rsi me falla ya que después de realizar el intercambia_posiciones se intercambian los sprites pero tarda mucho tiempo (como 1 o 2 minutos)
	//los dos primeros mapas del candy2_conf.s estan dedicados a probar este intercambio de posiciones

	do							// bucle principal de pruebas
	{
		cont = 0;
		copia_mapa(matrix, level);
		genera_sprites(matrix);
		escribe_matriz(matrix);
		intercambia_posiciones(matrix,0,0,1,0);
		retardo(10);			//esperamos 1 segundo
		
		printf("\x1b[39m\x1b[4;8H contador = %d", cont); //cont = veces que se ha entrado al rsi_timer0 en 1 segundo
		
		genera_sprites(matrix);
		escribe_matriz(matrix);
		retardo(5);
		printf("\x1b[39m\x1b[3;8H (pulse A)");
		
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A'
		} while (!(keysHeld() & KEY_A));
		
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

