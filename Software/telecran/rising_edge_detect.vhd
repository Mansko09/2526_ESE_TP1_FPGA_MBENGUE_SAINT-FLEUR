library ieee;
use ieee.std_logic_1164.all;

entity rising_edge_detect is
    port (
        i_clk   : in std_logic;
        A    : in std_logic;
		  E 	 : out std_logic
    );
end entity rising_edge_detect;

architecture rtl of rising_edge_detect is
    signal e_sig, a_curr, a_prev : std_logic  := '0';
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if a_prev='0' and a_curr='1' then
                e_sig <='1';
            else
                e_sig <= '0';
            end if;
				a_curr <= A;
				a_prev <= a_curr;
        end if;
        
    end process;
	E <= e_sig;
	 
end architecture rtl;