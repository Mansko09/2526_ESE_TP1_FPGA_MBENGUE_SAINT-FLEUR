library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Led_encodeur is
    port (
        -- Clock
        i_clk   : in std_logic;

        -- Active low reset
        i_rst_n : in std_logic;

        -- Encoder signals
        enc_A  : in std_logic;
        enc_B  : in std_logic;

        -- LEDs
        led0 : out std_logic;
        led1 : out std_logic;
        led2 : out std_logic;
        led3 : out std_logic;
        led4 : out std_logic;
        led5 : out std_logic;
        led6 : out std_logic;
        led7 : out std_logic;
        led8 : out std_logic;
        led9 : out std_logic
    );
end entity Led_encodeur;

architecture rtl of Led_encodeur is

    --------------------------------------------------------------------
    -- Constants
    --------------------------------------------------------------------
    constant MAX_COUNT : natural := 480;

    --------------------------------------------------------------------
    -- Internal signals
    --------------------------------------------------------------------
    signal pos : natural range 0 to MAX_COUNT := 0;
    signal led_vector : std_logic_vector(9 downto 0) := (others => '0');

    --------------------------------------------------------------------
    -- Edge detector components
    --------------------------------------------------------------------
    component rising_edge_detect
        port (
            i_clk : in std_logic;
            A     : in std_logic;
            E     : out std_logic
        );
    end component;

    component falling_edge_detect
        port (
            i_clk : in std_logic;
            A     : in std_logic;
            E     : out std_logic
        );
    end component;

    --------------------------------------------------------------------
    -- Edge detection signals
    --------------------------------------------------------------------
    signal a_rising, a_falling : std_logic;
    signal b_rising, b_falling : std_logic;

begin

    --------------------------------------------------------------------
    -- Edge detector instances
    --------------------------------------------------------------------
    red_A : rising_edge_detect
        port map (i_clk => i_clk, A => enc_A, E => a_rising);

    fed_A : falling_edge_detect
        port map (i_clk => i_clk, A => enc_A, E => a_falling);

    red_B : rising_edge_detect
        port map (i_clk => i_clk, A => enc_B, E => b_rising);

    fed_B : falling_edge_detect
        port map (i_clk => i_clk, A => enc_B, E => b_falling);

    --------------------------------------------------------------------
    -- Encoder position counter
    --------------------------------------------------------------------
    encoder_proc : process(i_clk, i_rst_n)
        variable dir : integer range -1 to 1 := 0;
    begin
        if i_rst_n = '0' then
            pos <= 0;

        elsif rising_edge(i_clk) then
            dir := 0;

            -- Clockwise
            if (a_rising = '1' and enc_B = '0') or
               (a_falling = '1' and enc_B = '1') then
                dir := 1;

            -- Counter clockwise
            elsif (b_rising = '1' and enc_A = '0') or
                  (b_falling = '1' and enc_A = '1') then
                dir := -1;
            end if;

            -- Saturated counter
            if dir = 1 and pos < MAX_COUNT then
                pos <= pos + 1;
            elsif dir = -1 and pos > 0 then
                pos <= pos - 1;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- LED bargraph display
    --------------------------------------------------------------------
    led_display : process(i_clk, i_rst_n)
        variable segment : natural;
    begin
        if i_rst_n = '0' then
            led_vector <= (others => '0');

        elsif rising_edge(i_clk) then
            segment := pos / 48;

            led_vector <= (others => '0');

            if segment > 0 then
                led_vector(segment-1 downto 0) <= (others => '1');
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Output mapping
    --------------------------------------------------------------------
    led0 <= led_vector(0);
    led1 <= led_vector(1);
    led2 <= led_vector(2);
    led3 <= led_vector(3);
    led4 <= led_vector(4);
    led5 <= led_vector(5);
    led6 <= led_vector(6);
    led7 <= led_vector(7);
    led8 <= led_vector(8);
    led9 <= led_vector(9);

end architecture rtl;
