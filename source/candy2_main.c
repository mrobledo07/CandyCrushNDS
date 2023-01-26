/*------------------------------------------------------------------------------

	$ candy2_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: xxx.xxx@estudiants.urv.cat
	Programador 2: alex.casanova@estudiants.urv.cat
	Programador 3: zzz.zzz@estudiants.urv.cat
	Programador 4: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
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


/* inicializa_interrupciones(): configura las direcciones de las RSI y los bits
	de habilitación (enable) del controlador de interrupciones para que se
	puedan generar las interrupciones requeridas.*/ 
void inicializa_interrupciones()
{
	TIMER1_CR = 0x00;                            // inicialmente los timers no generan interrupciones		
	irqSet(IRQ_TIMER1, rsi_timer1);              // cargar direcciones de las RSI
	irqEnable(IRQ_TIMER1);  		             // habilitar la IRQ correspondiente				
}




/* Programa principal: control general del juego */
int main(void)
{
    seed32 = time(NULL);			// fijar semilla de números aleatorios
	init_grafA();					// cargamos información gráfica
	inicializa_interrupciones();	// inicializamos timer y habilitamos su IRQ
	consoleDemoInit();			    // inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 2B y 2F)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	
	actualizar_contadores(1);
	
	do
	{
	    cont = 0;
		printf("\x1b[38m\x1b[3;19H (pulse A)");
		copia_mapa(matrix, level);
		genera_mapa2(matrix);
		genera_sprites(matrix);
		escribe_matriz(matrix);
		aumentar_elementos(matrix);
		retardo(10);
		printf("\x1b[39m\x1b[4;8H contador = %d", cont); //cont = veces que se ha entrado al rsi_timer1 en 1 segundo
		genera_sprites(matrix);
		cont = 0;
		reducir_elementos(matrix);
		retardo(10);
		printf("\x1b[39m\x1b[4;8H contador = %d", cont); 
		genera_sprites(matrix);
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A'
		} while (!(keysHeld() & (KEY_A)));
		printf("\x1b[3;0H                               ");
		retardo(5);
		if(keysHeld() & KEY_A)          // Si pulsa A pasa al siguiente nivel
		{
		    level = (level + 1) % MAXLEVEL;
			actualizar_contadores(1);
		}

	}while(1);
	return (0);
}