library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
    generic (
        CLK_FREQ      : natural := 50_000_000;  -- Hz
        DEBOUNCE_TIME : natural := 10_000_000   -- cycles (~10 ms)
    );
    port (
        i_clk    : in  std_logic;
        i_signal : in  std_logic;
        o_signal : out std_logic
    );
end entity debounce;

architecture rtl of debounce is
    signal counter : natural range 0 to DEBOUNCE_TIME := 0;
    signal stable  : std_logic := '0';
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_signal /= stable then
                counter <= counter + 1;
                if counter >= DEBOUNCE_TIME - 1 then
                    stable  <= i_signal;
                    counter <= 0;
                end if;
            else
                counter <= 0;
            end if;
        end if;
    end process;

    o_signal <= stable;
end rtl;