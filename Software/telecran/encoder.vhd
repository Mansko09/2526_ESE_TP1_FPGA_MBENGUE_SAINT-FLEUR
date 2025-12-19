library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
    generic (
        constant MAX_COUNT     : natural := 480;
        constant CLK_FREQ      : natural := 50_000_000;
        constant DEBOUNCE_TIME : natural := 200000      -- number of stable cycles
    );
    port (
        i_clk : in  std_logic;
        A     : in  std_logic;
        B     : in  std_logic;
        S     : out natural range 0 to MAX_COUNT
    );
end entity encoder;

architecture rtl of encoder is

    --------------------------------------------------------------------
    -- Input synchronization (equivalent to A1/A2, B1/B2)
    --------------------------------------------------------------------
    signal A1, A2 : std_logic := '0';
    signal B1, B2 : std_logic := '0';

    --------------------------------------------------------------------
    -- Debounce logic (same principle as the working TP encoder)
    --------------------------------------------------------------------
    signal A_debounced, B_debounced : std_logic := '0';
    signal A_prev, B_prev           : std_logic := '0';

    signal A_cnt, B_cnt : natural range 0 to DEBOUNCE_TIME := 0;

    --------------------------------------------------------------------
    -- Internal counter
    --------------------------------------------------------------------
    signal S_int : natural range 0 to MAX_COUNT := 0;

begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then

            ----------------------------------------------------------------
            -- Synchronize inputs
            ----------------------------------------------------------------
            A1 <= A;
            A2 <= A1;
            B1 <= B;
            B2 <= B1;

            ----------------------------------------------------------------
            -- Debounce channel A
            ----------------------------------------------------------------
            if A2 = A_debounced then
                A_cnt <= 0;
            else
                if A_cnt < DEBOUNCE_TIME then
                    A_cnt <= A_cnt + 1;
                else
                    A_debounced <= A2;
                    A_cnt <= 0;
                end if;
            end if;

            ----------------------------------------------------------------
            -- Debounce channel B
            ----------------------------------------------------------------
            if B2 = B_debounced then
                B_cnt <= 0;
            else
                if B_cnt < DEBOUNCE_TIME then
                    B_cnt <= B_cnt + 1;
                else
                    B_debounced <= B2;
                    B_cnt <= 0;
                end if;
            end if;

            ----------------------------------------------------------------
            -- Quadrature decoding
            ----------------------------------------------------------------
            if (A_debounced = '1' and A_prev = '0') then
                if B_debounced = '0' then
                    if S_int < MAX_COUNT then
                        S_int <= S_int + 1;
                    end if;
                else
                    if S_int > 0 then
                        S_int <= S_int - 1;
                    end if;
                end if;

            elsif (B_debounced = '1' and B_prev = '0') then
                if A_debounced = '1' then
                    if S_int < MAX_COUNT then
                        S_int <= S_int + 1;
                    end if;
                else
                    if S_int > 0 then
                        S_int <= S_int - 1;
                    end if;
                end if;
            end if;

            ----------------------------------------------------------------
            -- Store previous states
            ----------------------------------------------------------------
            A_prev <= A_debounced;
            B_prev <= B_debounced;

            ----------------------------------------------------------------
            -- Output assignment
            ----------------------------------------------------------------
            S <= S_int;

        end if;
    end process;

end architecture rtl;
