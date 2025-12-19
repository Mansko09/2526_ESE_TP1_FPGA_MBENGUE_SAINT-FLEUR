library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library pll;
use pll.all;

entity telecran is
    port (
        -- FPGA
        i_clk_50: in std_logic;

        -- HDMI
        io_hdmi_i2c_scl       : inout std_logic;
        io_hdmi_i2c_sda       : inout std_logic;
        o_hdmi_tx_clk        : out std_logic;
        o_hdmi_tx_d          : out std_logic_vector(23 downto 0);
        o_hdmi_tx_de         : out std_logic;
        o_hdmi_tx_hs         : out std_logic;
        i_hdmi_tx_int        : in std_logic;
        o_hdmi_tx_vs         : out std_logic;

        -- KEYs
        i_rst_n : in std_logic;
		  
        -- LEDs
        o_leds : out std_logic_vector(9 downto 0);
        o_de10_leds : out std_logic_vector(7 downto 0);

        -- Encodeurs
        i_left_ch_a  : in std_logic;
        i_left_ch_b  : in std_logic;
        i_left_pb    : in std_logic;
        i_right_ch_a : in std_logic;
        i_right_ch_b : in std_logic;
        i_right_pb   : in std_logic
    );
end entity telecran;

architecture rtl of telecran is

    ------------------------------------------------------------------
    -- Components
    ------------------------------------------------------------------
    component I2C_HDMI_Config 
        port (
            iCLK : in std_logic;
            iRST_N : in std_logic;
            I2C_SCLK : out std_logic;
            I2C_SDAT : inout std_logic;
            HDMI_TX_INT : in std_logic
        );
    end component;

    component pll 
        port (
            refclk   : in std_logic;
            rst      : in std_logic;
            outclk_0 : out std_logic;
            locked   : out std_logic
        );
    end component;

    component hdmi_controler
        generic (
            h_res  : integer;
            v_res  : integer;
            h_sync : integer;
            h_fp   : integer;
            h_bp   : integer;
            v_sync : integer;
            v_fp   : integer;
            v_bp   : integer
        );
        port (
            i_clk           : in  std_logic;
            i_rst_n         : in  std_logic;
            o_hdmi_hs       : out std_logic;
            o_hdmi_vs       : out std_logic;
            o_hdmi_de       : out std_logic;
            o_pixel_en      : out std_logic;
            o_pixel_address : out natural;
            o_x_counter     : out natural;
            o_y_counter     : out natural
        );
    end component;

    component encoder
        generic (
            MAX_COUNT : natural := 480
        );
        port (
            i_clk : in  std_logic;
            A     : in  std_logic;
            B     : in  std_logic;
            S     : out natural range 0 to MAX_COUNT
        );
    end component;

    component gestion_encodeurs
        port (
            i_x_counter : in natural;
            i_y_counter : in natural;
            i_x_enc     : in natural;
            i_y_enc     : in natural;
            o_pixel_data : out std_logic_vector(23 downto 0)
        );
    end component;

    ------------------------------------------------------------------
    -- Constants
    ------------------------------------------------------------------
    constant h_res : natural := 720;
    constant v_res : natural := 480;

    ------------------------------------------------------------------
    -- Signals
    ------------------------------------------------------------------
    signal s_clk_27 : std_logic;
    signal s_rst_n  : std_logic;

    -- HDMI internal signals
    signal s_hdmi_hs : std_logic;
    signal s_hdmi_vs : std_logic;
    signal s_hdmi_de : std_logic;
    signal s_x       : natural;
    signal s_y       : natural;

    -- Encodeur positions
    signal h_val     : natural range 0 to h_res := 0; -- encodeur horizontal
    signal v_val     : natural range 0 to v_res := 0; -- encodeur vertical

    -- Gestion encodeurs pixel
    signal s_pixel_data : std_logic_vector(23 downto 0);

begin

    ------------------------------------------------------------------
    -- Default outputs
    ------------------------------------------------------------------
    o_leds      <= (others => '0');
    o_de10_leds <= (others => '0');

    ------------------------------------------------------------------
    -- PLL : 50 MHz -> 27 MHz
    ------------------------------------------------------------------
    pll0 : pll
        port map (
            refclk   => i_clk_50,
            rst      => not i_rst_n,
            outclk_0 => s_clk_27,
            locked   => s_rst_n
        );

    ------------------------------------------------------------------
    -- ADV7513 configuration (I2C)
    ------------------------------------------------------------------
    I2C_HDMI_Config0 : I2C_HDMI_Config
        port map (
            iCLK        => i_clk_50,
            iRST_N      => i_rst_n,
            I2C_SCLK    => io_hdmi_i2c_scl,
            I2C_SDAT    => io_hdmi_i2c_sda,
            HDMI_TX_INT => i_hdmi_tx_int
        );

    ------------------------------------------------------------------
    -- HDMI controller
    ------------------------------------------------------------------
    hdmi_ctrl0 : hdmi_controler
        generic map (
            h_res  => h_res,
            v_res  => v_res,
            h_sync => 61,
            h_fp   => 58,
            h_bp   => 18,
            v_sync => 5,
            v_fp   => 30,
            v_bp   => 9
        )
        port map (
            i_clk           => s_clk_27,
            i_rst_n         => s_rst_n,
            o_hdmi_hs       => s_hdmi_hs,
            o_hdmi_vs       => s_hdmi_vs,
            o_hdmi_de       => s_hdmi_de,
            o_pixel_en      => open,
            o_pixel_address => open,
            o_x_counter     => s_x,
            o_y_counter     => s_y
        );

    ------------------------------------------------------------------
    -- Encodeurs
    ------------------------------------------------------------------
    encodeur0 : encoder
        generic map(MAX_COUNT => v_res)
        port map(
            i_clk => i_clk_50,
            A     => i_left_ch_a,
            B     => i_left_ch_b,
            S     => v_val
        );

    encodeur1 : encoder
        generic map(MAX_COUNT => h_res)
        port map(
            i_clk => i_clk_50,
            A     => i_right_ch_a,
            B     => i_right_ch_b,
            S     => h_val
        );

    ------------------------------------------------------------------
    -- Pixel unique selon encodeurs
    ------------------------------------------------------------------
    gest_enc0 : gestion_encodeurs
        port map(
            i_x_counter => s_x,
            i_y_counter => s_y,
            i_x_enc     => h_val,
            i_y_enc     => v_val,
            o_pixel_data => s_pixel_data
        );

    ------------------------------------------------------------------
    -- HDMI physical outputs
    ------------------------------------------------------------------
    o_hdmi_tx_clk <= s_clk_27;
    o_hdmi_tx_hs  <= s_hdmi_hs;
    o_hdmi_tx_vs  <= s_hdmi_vs;
    o_hdmi_tx_de  <= s_hdmi_de;
    o_hdmi_tx_d   <= s_pixel_data;

end architecture rtl;
