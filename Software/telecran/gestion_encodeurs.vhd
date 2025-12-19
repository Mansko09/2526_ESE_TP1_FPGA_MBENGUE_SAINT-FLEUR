library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gestion_encodeurs is
    port (
        i_x_counter : in natural;
        i_y_counter : in natural;
        i_x_enc     : in natural;
        i_y_enc     : in natural;
        o_pixel_data : out std_logic_vector(23 downto 0)
    );
end entity;

architecture rtl of gestion_encodeurs is
		  constant PIXEL_SIZE : natural := 8;  -- taille du pixel (8x8)
begin
    process(i_x_counter, i_y_counter, i_x_enc, i_y_enc)
    begin
        --if (i_x_counter = i_x_enc) and (i_y_counter = i_y_enc) then
            --o_pixel_data <= x"FFFFFF"; -- blanc
        --else
            --o_pixel_data <= x"000000"; -- noir
        --end if;


			if (i_x_counter >= i_x_enc and i_x_counter < i_x_enc + PIXEL_SIZE) and
				(i_y_counter >= i_y_enc and i_y_counter < i_y_enc + PIXEL_SIZE) then
				 o_pixel_data <= x"FFFFFF"; -- bloc blanc
			else
				 o_pixel_data <= x"000000"; -- noir
			end if;

    end process;
end architecture rtl;
