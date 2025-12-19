library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder_tb is
end entity encoder_tb;

architecture sim of encoder_tb is

    -- Déclarations des composants à tester
    component encoder is
        generic(
            constant MAX_COUNT : natural := 480
        );
        port (
            i_clk   : in  std_logic;
            A       : in  std_logic;
            B       : in  std_logic;
            S       : out natural range 0 to MAX_COUNT
        );
    end component;

    -- Composants détecteurs d'arêtes (ils doivent exister dans ton projet)
    component rising_edge_detect
        port (
            i_clk : in  std_logic;
            A     : in  std_logic;
            E     : out std_logic
        );
    end component;

    component falling_edge_detect
        port (
            i_clk : in  std_logic;
            A     : in  std_logic;
            E     : out std_logic
        );
    end component;

    -- Signaux
    signal i_clk : std_logic := '0';
    signal A     : std_logic := '0';
    signal B     : std_logic := '0';
    signal S     : natural range 0 to 480;

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz

begin

    -- Instanciation de l'encodeur
    DUT: encoder
        generic map (
            MAX_COUNT => 480
        )
        port map (
            i_clk => i_clk,
            A     => A,
            B     => B,
            S     => S
        );

    -- Génération de l'horloge
    clk_process: process
    begin
        wait for CLK_PERIOD/2;
        i_clk <= not i_clk;
    end process;

    -- Stimuli
    stim_proc: process
    begin
        -- Initialisation
        A <= '0';
        B <= '0';
        wait for 20 ns;

        -- Rotation horaire (sens positif) : séquence A puis B en quadrature
        -- 1. A monte (B=0)
        A <= '1'; wait for 40 ns;
        -- 2. B monte (A=1)
        B <= '1'; wait for 40 ns;
        -- 3. A descend (B=1)
        A <= '0'; wait for 40 ns;
        -- 4. B descend (A=0)
        B <= '0'; wait for 40 ns;

        -- Encore 3 pas dans le sens positif
        for i in 1 to 3 loop
            A <= '1'; wait for 40 ns;
            B <= '1'; wait for 40 ns;
            A <= '0'; wait for 40 ns;
            B <= '0'; wait for 40 ns;
        end loop;

        wait for 50 ns;

        -- Rotation anti-horaire (sens négatif)
        -- 1. B monte (A=0)
        B <= '1'; wait for 40 ns;
        -- 2. A monte (B=1)
        A <= '1'; wait for 40 ns;
        -- 3. B descend (A=1)
        B <= '0'; wait for 40 ns;
        -- 4. A descend (B=0)
        A <= '0'; wait for 40 ns;

        -- Encore 2 pas dans le sens négatif
        for i in 1 to 2 loop
            B <= '1'; wait for 40 ns;
            A <= '1'; wait for 40 ns;
            B <= '0'; wait for 40 ns;
            A <= '0'; wait for 40 ns;
        end loop;

        wait for 100 ns;

        -- Test des limites (on atteint MAX_COUNT puis on essaie d'aller plus haut)
        report "Fin de la simulation";
        wait;
    end process;

end architecture sim;