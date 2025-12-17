library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_encoder is
end entity tb_encoder;

architecture sim of tb_encoder is
    constant CLK_PERIOD : time := 20 ns;  -- horloge à 50 MHz
    constant MAX_COUNT  : natural := 480;

    signal i_clk : std_logic := '0';
    signal A     : std_logic := '0';
    signal B     : std_logic := '0';
    signal S     : natural range 0 to MAX_COUNT;

    component encoder
        generic (
            constant MAX_COUNT : natural
        );
        port (
            i_clk : in  std_logic;
            A     : in  std_logic;
            B     : in  std_logic;
            S     : out natural range 0 to MAX_COUNT
        );
    end component;

begin
    -- Instanciation du DUT
    dut : encoder
        generic map (MAX_COUNT => MAX_COUNT)
        port map (
            i_clk => i_clk,
            A     => A,
            B     => B,
            S     => S
        );

    -- Génération de l'horloge
    i_clk <= not i_clk after CLK_PERIOD/2;

    -- Stimuli : simulation de rotations
    stimulus : process
        procedure rotate_cw(steps : natural) is
        begin
            for i in 1 to steps loop
                -- Séquence CW : 00 → 10 → 11 → 01 → 00
                A <= '1'; wait for 4*CLK_PERIOD;
                B <= '1'; wait for 4*CLK_PERIOD;
                A <= '0'; wait for 4*CLK_PERIOD;
                B <= '0'; wait for 4*CLK_PERIOD;
            end loop;
        end procedure;

        procedure rotate_ccw(steps : natural) is
        begin
            for i in 1 to steps loop
                -- Séquence CCW : 00 → 01 → 11 → 10 → 00
                B <= '1'; wait for 4*CLK_PERIOD;
                A <= '1'; wait for 4*CLK_PERIOD;
                B <= '0'; wait for 4*CLK_PERIOD;
                A <= '0'; wait for 4*CLK_PERIOD;
            end loop;
        end procedure;
    begin
        wait for 10*CLK_PERIOD;

        report "Début simulation : position initiale = " & integer'image(S);

        rotate_cw(10);   -- +10
        report "Après 10 pas CW : S = " & integer'image(S);

        rotate_ccw(5);   -- -5
        report "Après 5 pas CCW : S = " & integer'image(S);

        rotate_cw(480);  -- on atteint le max
        report "Après tentative de dépassement max : S = " & integer'image(S);

        rotate_ccw(500); -- on descend jusqu'à 0
        report "Après descente vers 0 : S = " & integer'image(S);

        wait for 100*CLK_PERIOD;
        report "Fin de la simulation";
        wait;
    end process;
end architecture sim;