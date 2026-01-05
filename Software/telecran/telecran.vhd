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
    -- Constants
    ------------------------------------------------------------------
    constant h_res : natural := 720;
    constant v_res : natural := 480;
    constant fb_size : natural := h_res * v_res;
	 
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
	 
	component dpram
		 generic (
			  mem_size   : natural := fb_size;
			  data_width : natural := 8
		 );
		 port (
			  i_clk_a  : in std_logic;
			  i_clk_b  : in std_logic;
			  i_data_a : in std_logic_vector(data_width-1 downto 0);
			  i_data_b : in std_logic_vector(data_width-1 downto 0);
			  i_addr_a : in natural range 0 to mem_size-1;
			  i_addr_b : in natural range 0 to mem_size-1;
			  i_we_a   : in std_logic;
			  i_we_b   : in std_logic;
			  o_q_a    : out std_logic_vector(data_width-1 downto 0);
			  o_q_b    : out std_logic_vector(data_width-1 downto 0)
		 );
	end component;

    ------------------------------------------------------------------
    -- Signals
    ------------------------------------------------------------------
    signal s_clk_27 : std_logic;
    signal s_rst_n  : std_logic;

    signal s_hdmi_hs : std_logic;
    signal s_hdmi_vs : std_logic;
    signal s_hdmi_de : std_logic;
    signal s_x       : natural;
    signal s_y       : natural;

    signal h_val     : natural range 0 to h_res := 0;
    signal v_val     : natural range 0 to v_res := 0;

    signal s_cursor_pixel : std_logic_vector(23 downto 0);
    signal s_pixel_data : std_logic_vector(23 downto 0);
	 
    signal fb_addr_a, fb_addr_b : natural range 0 to fb_size-1;
    signal fb_we_a : std_logic;
    signal fb_q_b  : std_logic_vector(7 downto 0);
	 signal fb_data_a : std_logic_vector(7 downto 0);


    ------------------------------------------------------------------
    -- EFFACEMENT
    ------------------------------------------------------------------
    type clear_state_t is (IDLE, CLEARING);
    signal clear_state : clear_state_t := IDLE;

    signal clear_addr : natural range 0 to fb_size-1 := 0;

    signal pb_sync, pb_prev : std_logic;
    signal clear_request   : std_logic;
	 

begin

    ------------------------------------------------------------------
    -- Default outputs
    ------------------------------------------------------------------
    o_leds      <= (others => '0');
    o_de10_leds <= (others => '0');

    ------------------------------------------------------------------
    -- PLL
    ------------------------------------------------------------------
    pll0 : pll
        port map (
            refclk   => i_clk_50,
            rst      => not i_rst_n,
            outclk_0 => s_clk_27,
            locked   => s_rst_n
        );

    ------------------------------------------------------------------
    -- HDMI I2C
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

    o_hdmi_tx_clk <= s_clk_27;
    o_hdmi_tx_hs  <= s_hdmi_hs;
    o_hdmi_tx_vs  <= s_hdmi_vs;
    o_hdmi_tx_de  <= s_hdmi_de;
    o_hdmi_tx_d   <= s_pixel_data;

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
    -- Cursor overlay 
    ------------------------------------------------------------------
    gest_enc0 : gestion_encodeurs
        port map(
            i_x_counter => s_x,
            i_y_counter => s_y,
            i_x_enc     => h_val,
            i_y_enc     => v_val,
            o_pixel_data => s_cursor_pixel
        );

    ------------------------------------------------------------------
    -- Détection appui bouton 
    ------------------------------------------------------------------
    process(i_clk_50)
    begin
        if rising_edge(i_clk_50) then
            pb_sync <= i_left_pb;
            pb_prev <= pb_sync;
        end if;
    end process;

    clear_request <= '1' when (pb_prev = '1' and pb_sync = '0') else '0';

    ------------------------------------------------------------------
    -- Machine d'état effacement 
    ------------------------------------------------------------------
    process(i_clk_50)
    begin
        if rising_edge(i_clk_50) then
            if i_rst_n = '0' then
                clear_state <= IDLE;
                clear_addr  <= 0;
            else
                case clear_state is
                    when IDLE =>
                        if clear_request = '1' then
                            clear_state <= CLEARING;
                            clear_addr  <= 0;
                        end if;

                    when CLEARING =>
                        if clear_addr = fb_size-1 then
                            clear_state <= IDLE;
                        else
                            clear_addr <= clear_addr + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Framebuffer addressing 
    ------------------------------------------------------------------
    fb_addr_a <= clear_addr when clear_state = CLEARING
                 else v_val * h_res + h_val;

    fb_addr_b <= s_y * h_res + s_x;

    fb_we_a <= '1' when clear_state = CLEARING else
               '1' when (s_x = h_val and s_y = v_val and s_hdmi_de = '1')
               else '0';

    ------------------------------------------------------------------
    -- Framebuffer RAM 
    ------------------------------------------------------------------
	 fb_data_a <= (others => '0') when clear_state = CLEARING else x"FF";

    ram0 : dpram
        port map (
            i_clk_a  => i_clk_50,
            i_clk_b  => s_clk_27,
            i_data_a => fb_data_a,
            i_data_b => (others => '0'),
            i_addr_a => fb_addr_a,
            i_addr_b => fb_addr_b,
            i_we_a   => fb_we_a,
            i_we_b   => '0',
            o_q_a    => open,
            o_q_b    => fb_q_b
        );

    ------------------------------------------------------------------
    -- Display logic
    ------------------------------------------------------------------
    process(s_clk_27)
    begin
        if rising_edge(s_clk_27) then
            if s_hdmi_de = '1' then
                if fb_q_b /= x"00" then
                    s_pixel_data <= x"FFFFFF";
                else
                    s_pixel_data <= x"000000";
                end if;
            else
                s_pixel_data <= (others => '0');
            end if;
        end if;
    end process;

end architecture rtl;
