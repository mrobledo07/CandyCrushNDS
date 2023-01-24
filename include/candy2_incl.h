/*------------------------------------------------------------------------------

	$Id: candy2_incl.h $

	Definiciones externas en C para la versi�n 2 del juego (modo gr�fico)

------------------------------------------------------------------------------*/

#include <candy1_incl.h>

// Pixeles por casilla del tablero de juego
#define MTWIDTH	(256/COLUMNS)			// num. p�xeles de ancho (e.g. 32)
#define MTHEIGHT   (192/ROWS)			// num. p�xeles de alto (e.g. 32)

// Dimensiones de las metabaldosas:
#define MTROWS	(MTHEIGHT/8)			// num. filas metabaldosa (e.g. 4)
#define MTCOLS	(MTWIDTH/8)				// num. columnas metabaldosa (e.g. 4)
#define MTOTAL	MTROWS*MTCOLS			// num. total de baldosas simples


// esctructura de datos relativos a un elemento
typedef struct
{
	short	ii;				// n�mero de interrupciones pendientes (0..32)
							// o (-1) si est� inactivo
	short	px;				// posici�n x (0..256)
	short	py;				// posici�n y (-32..192)
	short	vx;				// velocidad x
	short	vy;				// velocidad y
} elemento;

// esctructura de datos relativos a una gelatina
typedef struct
{
	char	ii;				// n�mero de interrupciones pendientes (0..10)
							// o (-1) si est� inactivo
	char	im;				// �ndice de metabaldosa (0..7/8..15)
} gelatina;



	// candy2_supo.s //
extern int busca_elemento(int fil, int col);
extern int crea_elemento(int tipo, int fil, int col);
extern int elimina_elemento(int fil, int col);
extern int activa_elemento(int fil, int col, int f2, int c2);
extern int activa_escalado(int fil, int col);
extern int desactiva_escalado(int fil, int col);
extern void fija_metabaldosa(u16 * mapbase, int fil, int col, int imeta);
extern void elimina_gelatina(int fil, int col);


	// candy2_graf.c //
//extern int n_sprites;
//extern elemento vect_elem[ROWS*COLUMNS];
//extern gelatina mat_gel[ROWS][COLUMNS];
extern void init_grafA(void);							// 2Aa,2Ba,2Ca,2Da
extern void genera_sprites(char matriz[][COLUMNS]);	// 2Ab
extern void genera_mapa1(char matriz[][COLUMNS]);		// 2Cb
extern void genera_mapa2(char matriz[][COLUMNS]);		// 2Bb
//extern void ajusta_imagen3(int ibg);					// 2Db


	// RSI_timer0.s //
//extern short update_spr;
extern short timer0_on;
extern void rsi_vblank();								// 2Ea,2Ga,2Ha
extern void activa_timer0(int init);					// 2Eb
//extern void desactiva_timer0();						// 2Ec
extern void rsi_timer0();								// 2Ed


	// RSI_timer1.s //
extern short timer1_on;
extern void activa_timer1(int init);					// 2Fb
//extern void desactiva_timer1();						// 2Fc
extern void rsi_timer1();								// 2Fd


	// RSI_timer2.s //
//extern short update_gel;
extern short timer2_on;
extern void activa_timer2();							// 2Gb
extern void desactiva_timer2();							// 2Gc
extern void rsi_timer2();								// 2Gd


	// RSI_timer3.s //
//extern short update_bg3;
extern short timer3_on;
extern void activa_timer3();							// 2Hb
extern void desactiva_timer3();							// 2Hc
extern void rsi_timer3();								// 2Hd
