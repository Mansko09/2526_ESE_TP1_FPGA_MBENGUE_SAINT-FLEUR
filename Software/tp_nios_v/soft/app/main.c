#include <unistd.h> // for usleep

#include "system.h"
#include "altera_avalon_pio_regs.h"

int main (void)
{
	printf("Hello, world!\n");

	return 0;
}

int chenillard(int delay_us)
{
	int nombre_leds=10;
	printf("Lancement du chenillard...\n");
	while (1)
	{
		// Turn on each LED in sequence
		for (int i = 0; i < nombre_leds; i++)
		{
			IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 1 << i);
			usleep(delay_us);
		}
		// Turn off each LED in reverse sequence
		for (int i = 6; i >= 0; i--)
		{
			IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 1 << i);
			usleep(delay_us);
		}
	}
	return 0;
}