library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hdmi_controler is
    generic( 
        h_res  : integer := 720;
        v_res  : integer := 480;
        h_sync : integer := 61;
        h_fp   : integer := 18;
        h_bp   : integer := 58;
        v_sync : integer := 5;
        v_fp   : integer := 30;
        v_bp   : integer := 9
    );
    port (
        i_clk           : in  STD_LOGIC;
        i_rst_n         : in  STD_LOGIC;
        o_hdmi_hs       : out STD_LOGIC;
        o_hdmi_vs       : out STD_LOGIC;
        o_hdmi_de       : out STD_LOGIC;
        o_pixel_en      : out STD_LOGIC;
        o_pixel_address : out natural;
        o_x_counter     : out natural;
        o_y_counter     : out natural
    );
end hdmi_controler;

architecture rtl of hdmi_controler is

    -- Horizontal timing
    constant h_start : integer := h_sync + h_bp;
    constant h_end   : integer := h_start + h_res;
    constant h_total : integer := h_end + h_fp;

    -- Vertical timing
    constant v_start : integer := v_sync + v_bp;
    constant v_end   : integer := v_start + v_res;
    constant v_total : integer := v_end + v_fp;

    -- Counters
    signal r_h_count : integer range 0 to h_total := 0;
    signal r_v_count : integer range 0 to v_total := 0;

    -- Active flags
    signal h_active  : std_logic := '0';
    signal v_active  : std_logic := '0';

    -- Pixel counters
    signal x_cnt     : natural range 0 to h_res := 0;
    signal y_cnt     : natural range 0 to v_res := 0;
	 
	 signal s_hdmi_de : std_logic;

begin

    -- ===============================================================
    -- Horizontal Counter + HSync + X counter
    -- ===============================================================
    h_proc: process(i_clk, i_rst_n)
    begin
        if i_rst_n = '0' then
            r_h_count   <= 0;
            o_hdmi_hs   <= '1';
            h_active    <= '0';
            x_cnt       <= 0;
            o_x_counter <= 0;
        elsif rising_edge(i_clk) then
            -- Roll over
            if r_h_count = h_total then
                r_h_count <= 0;
            else
                r_h_count <= r_h_count + 1;
            end if;

            -- HSync: low during sync pulse
            if r_h_count < h_sync then
                o_hdmi_hs <= '0';
            else
                o_hdmi_hs <= '1';
            end if;

            -- Active video
            if r_h_count = h_start then
                h_active <= '1';
                x_cnt <= 0;
                o_x_counter <= 0;
            elsif r_h_count = h_end then
                h_active <= '0';
            elsif h_active = '1' then
                x_cnt <= x_cnt + 1;
                o_x_counter <= x_cnt + 1;
            end if;
        end if;
    end process;

    -- ===============================================================
    -- Vertical Counter + VSync + Y counter
    -- ===============================================================
    v_proc: process(i_clk, i_rst_n)
    begin
        if i_rst_n = '0' then
            r_v_count   <= 0;
            o_hdmi_vs   <= '1';
            v_active    <= '0';
            y_cnt       <= 0;
            o_y_counter <= 0;
        elsif rising_edge(i_clk) then
            if r_h_count = h_total then  -- End of line
                -- Roll over vertical
                if r_v_count = v_total then
                    r_v_count <= 0;
                else
                    r_v_count <= r_v_count + 1;
                end if;

                -- VSync
                if r_v_count < v_sync then
                    o_hdmi_vs <= '0';
                else
                    o_hdmi_vs <= '1';
                end if;

                -- Active video
                if r_v_count = v_start then
                    v_active <= '1';
                    y_cnt <= 0;
                    o_y_counter <= 0;
                elsif r_v_count = v_end then
                    v_active <= '0';
                elsif v_active = '1' then
                    y_cnt <= y_cnt + 1;
                    o_y_counter <= y_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- ===============================================================
    -- Output logic
    -- ===============================================================
s_hdmi_de <= h_active and v_active;

o_hdmi_de  <= s_hdmi_de;
o_pixel_en <= s_hdmi_de;

o_pixel_address <= x_cnt + y_cnt * h_res when s_hdmi_de = '1' else 0;

end rtl;