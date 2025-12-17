library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
	generic(
		constant MAX_COUNT : natural := 480
	);
    port (
        i_clk   : in std_logic;
        A    : in std_logic;
		  B    : in std_logic;
		  S 	 : out natural range 0 to MAX_COUNT -- out ports cannot be read inside the architecture
			
    );
end entity encoder;

architecture rtl of encoder is

component rising_edge_detect 
		port (
        i_clk   : in std_logic;
        A    : in std_logic;
		  E 	 : out std_logic
    );
	 end component;
	 
	 component falling_edge_detect 
		port (
        i_clk   : in std_logic;
        A    : in std_logic;
		  E 	 : out std_logic
    );
	 end component;
	 signal a_rising: std_logic;
	 signal a_falling: std_logic;
	 signal b_rising: std_logic;
	 signal b_falling: std_logic;
	 signal S_int : natural range 0 to MAX_COUNT := 0; -- internal signals can be read and modified
begin
	 red_A : component rising_edge_detect
			port map(
        i_clk=> i_clk,
        A => A,
		  E => a_rising
    );
	  fed_A : component falling_edge_detect
			port map(
        i_clk=> i_clk,
        A => A,
		  E => a_falling
    );
	  red_B : component rising_edge_detect
			port map(
        i_clk=> i_clk,
        A => B,
		  E => b_rising
    );
	  fed_B : component falling_edge_detect
			port map(
        i_clk=> i_clk,
        A => B,
		  E => b_falling
    );
    process(i_clk)
		  variable i : integer range -1 to 1 := 0;
    begin
	 

	 
	 if rising_edge(i_clk) then
        if a_rising = '1' and B='0' then
				i := 1;
			
			elsif a_falling = '0' and B='1' then
				i := 1;
			
			elsif b_rising = '1' and A='0' then
				i := -1;

			elsif b_falling = '0' and A='1' then
				i := -1;
			else 
				i:= 0 ;
			end if;
			
			if (i = 1 and S_int < MAX_COUNT) then
            S_int <= S_int + 1;
			elsif (i = -1 and S_int > 0) then
            S_int <= S_int - 1;
        end if;
		  
		end if;
--		S <= S+i;
		S <= S_int;
    end process;

end architecture rtl;
