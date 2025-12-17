library ieee;
use ieee.std_logic_1164.all;

entity TP1_FPGA is
    port (
        i_clk   : in std_logic;
        i_rst_n : in std_logic;
        led0    : out std_logic;
		  led1    : out std_logic;
		  led2    : out std_logic;
		  led3    : out std_logic;
		  led4    : out std_logic;
		  led5    : out std_logic;
		  led6    : out std_logic;
		  led7    : out std_logic;
		  led8    : out std_logic;
		  led9    : out std_logic
    );
end entity TP1_FPGA;

architecture rtl of TP1_FPGA is
    signal r_led : std_logic_vector (9 downto 0) := (others =>'0');
begin
    process(i_clk, i_rst_n)
        variable period_cnt : natural range 0 to 50000000 := 0;
		  variable i : natural range 0 to 9 := 0;
    begin
        if i_rst_n = '0' then
            period_cnt := 0;
            r_led   <= (others =>'0');

        elsif rising_edge(i_clk) then
            if period_cnt = 50000000 then
                period_cnt := 0;
					 i := 0;
                r_led   <=  (others =>'0');	 
				elsif (period_cnt mod 5000000 = 0) then
                period_cnt := period_cnt + 1;
                r_led(i)   <=  '1';	
					 i := i+1;
            else
                period_cnt := period_cnt + 1;
            end if;
        end if;
    end process;

    led0 <= r_led(0);
	 led1 <= r_led(1);
	 led2 <= r_led(2);
	 led3 <= r_led(3);
	 led4 <= r_led(4);
	 led5 <= r_led(5);
	 led6 <= r_led(6);
	 led7 <= r_led(7);
	 led8 <= r_led(8);
	 led9 <= r_led(9);
	 
end architecture rtl;
