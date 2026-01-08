#include <unistd.h> // for usleep

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include <stdio.h>
#include "altera_avalon_i2c.h"

#define ADXL345_I2C_ADDR 0x53
#define REG_POWER_CTL    0x2D
#define REG_DATAX0       0x32

ALT_AVALON_I2C_DEV_t *i2c_dev;



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

// --- Fonctions utilitaires I2C ---
void init_adxl345() {
    uint8_t config[2] = {REG_POWER_CTL, 0x08}; // Mode mesure
    alt_avalon_i2c_master_target_set_address(i2c_dev, ADXL345_I2C_ADDR);
    alt_avalon_i2c_master_tx(i2c_dev, config, 2, ALT_AVALON_I2C_NO_INTERRUPTS);
}

int16_t read_axis_x() {
    uint8_t reg = REG_DATAX0;
    uint8_t data[2];
    alt_avalon_i2c_master_tx(i2c_dev, &reg, 1, ALT_AVALON_I2C_NO_INTERRUPTS);
    alt_avalon_i2c_master_rx(i2c_dev, data, 2, ALT_AVALON_I2C_NO_INTERRUPTS);
    return (int16_t)((data[1] << 8) | data[0]);
}

int main() {
	printf("Hello world\n")
    i2c_dev = alt_avalon_i2c_open(I2C_0_NAME);
    if (i2c_dev == NULL) return -1;

    init_adxl345();
    
    printf("Niveau à bulle 10 LEDs opérationnel.\n");

    while (1) {
        int16_t x_val = read_axis_x();
        unsigned int led_mask = 0;

        // Répartition sur 10 LEDs (de 0 à 9)
        // Les valeurs de X vont d'environ -250 (gauche) à +250 (droite)
        
        if (x_val < -200)      led_mask = (1 << 9); // LED tout à gauche
        else if (x_val < -150) led_mask = (1 << 8);
        else if (x_val < -100) led_mask = (1 << 7);
        else if (x_val < -50)  led_mask = (1 << 6);
        else if (x_val < -15)  led_mask = (1 << 5);
        else if (x_val < 15)   led_mask = (1 << 4) | (1 << 5); // Centre parfait : 2 LEDs
        else if (x_val < 50)   led_mask = (1 << 4);
        else if (x_val < 100)  led_mask = (1 << 3);
        else if (x_val < 150)  led_mask = (1 << 2);
        else if (x_val < 200)  led_mask = (1 << 1);
        else                   led_mask = (1 << 0); // LED tout à droite

        // On envoie le masque de 10 bits au PIO
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, led_mask);

        usleep(40000); // 40ms 
    }
    return 0;
}