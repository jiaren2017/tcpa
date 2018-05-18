-- =============================================================================
--!  @project      frame buffer tcpa
-- =============================================================================
--!  @file         dvi_output_interface.vhd
--!  @author       Marcel Brand
--!  @email        marcel.brand@fau.de
--!  @brief        profpga dvi frame buffer with sram
-- =============================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.log2;
    use ieee.math_real.ceil;
library unisim;
    use unisim.vcomponents.all;

entity dvi_output_interface is
  generic (
    ADDR_W                     : positive                   :=   22;
    STD_FRAME_IN_WIDTH         : positive range   1 to 2046 :=  720;
    STD_FRAME_IN_HEIGHT        : positive range   1 to 1022 :=  527;
    STD_FRAME_OUT_WIDTH        : positive range   1 to 2046 :=  640;
    STD_FRAME_OUT_HEIGHT       : positive range   1 to 1022 :=  480; 
    STD_FRAME_OUT_HSYNC        : positive range   1 to  640 :=   96;  
    STD_FRAME_OUT_HFRONT       : positive range   1 to  640 :=   16;
    STD_FRAME_OUT_HBACK        : positive range   1 to  640 :=   48;
    STD_FRAME_OUT_VSYNC        : positive range   1 to  480 :=    2;
    STD_FRAME_OUT_VFRONT       : positive range   1 to  480 :=   10;
    STD_FRAME_OUT_VBACK        : positive range   1 to  480 :=   33;
    STD_DVI_OUT_EN             : integer  range   0 to    1 :=    1;
    STD_FRAME_OUT_ACTIVE_HSYNC : integer  range   0 to    1 :=    0;
    STD_FRAME_OUT_ACTIVE_VSYNC : integer  range   0 to    1 :=    0;
    STD_FRAME_OUT_PERMUTATION  : integer  range   0 to   63 :=    0;
    STD_DVI_OUT_A3_DK3         : integer  range   0 to    1 :=    0; 
    STD_DVI_OUT_BSEL_SCL       : integer  range   0 to    1 :=    1; 
    STD_DVI_OUT_CTL            : integer  range   0 to    3 :=    0; 
    STD_DVI_OUT_DKEN           : integer  range   0 to    1 :=    0; 
    STD_DVI_OUT_DSEL_SDA       : integer  range   0 to    1 :=    0; 
    STD_DVI_OUT_EDGE           : integer  range   0 to    1 :=    1; 
    STD_DVI_OUT_IDCLK_N        : integer  range   0 to    1 :=    0; 
    STD_DVI_OUT_ISEL_NRST      : integer  range   0 to    1 :=    0; 
    STD_DVI_OUT_MSEN_PO1       : integer  range   0 to    1 :=    0; 
    STD_DVI_OUT_NHPD           : integer  range   0 to    1 :=    1; 
    STD_DVI_OUT_NOC            : integer  range   0 to    1 :=    0; 
    STD_DVI_OUT_NPD            : integer  range   0 to    1 :=    1 
  );
  port (
    dvi_out_clk : in std_ulogic;
    cfg_clk     : in std_ulogic;

    reset : in std_ulogic;

    px_request_addr  : out std_ulogic_vector(ADDR_W-1 downto 0);
    px_request_en    : out std_ulogic;
    px_request_ready : in  std_ulogic;

    px_data  : in  std_ulogic_vector(23 downto 0);
    px_valid : in  std_ulogic;
    px_used  : out std_ulogic;

    dvi_out_cfg_wdata : in  std_ulogic_vector(12 downto 0);
    dvi_out_cfg_rdata : out std_ulogic_vector(12 downto 0);
    dvi_out_cfg_addr  : in  std_ulogic_vector(3 downto 0);
    dvi_out_cfg_we    : in  std_ulogic;
    dvi_out_cfg_en    : in  std_ulogic;

    dvi_out_frame_end : out std_ulogic;

    -- pins which are connected to motherboard connector td1 
    -- and connector ba1 on x-board eb-pds-dvi-r1 
    dvi_out_a3_dk3       : out   std_ulogic;                      -- td1_io_034_n_17
    dvi_out_bsel_scl     : out   std_ulogic;                      -- td1_io_035_p_17
    dvi_out_ctl          : out   std_ulogic_vector(1 downto 0);
    dvi_out_data         : out   std_ulogic_vector(23 downto 0);
    dvi_out_de           : out   std_ulogic;                      -- td1_io_026_n_13
    dvi_out_dken         : out   std_ulogic;                      -- td1_io_028_n_14
    dvi_out_dsel_sda     : out   std_ulogic;                      -- td1_io_036_n_18
    dvi_out_edge         : out   std_ulogic;                      -- td1_io_027_p_13
--  dvi_out_edid_scl     : inout std_ulogic;                      -- td1_io_104_n_52
--  dvi_out_edid_sda     : inout std_ulogic;                      -- td1_io_105_p_52
    dvi_out_hsync        : out   std_ulogic;                      -- td1_io_024_n_12
    dvi_out_idclk_n      : out   std_ulogic;                      -- td1_clkio_n_5_srcc
    dvi_out_idclk_p      : out   std_ulogic;                      -- td1_clkio_p_5_srcc
    dvi_out_isel_nrst    : out   std_ulogic;                      -- td1_io_031_p_15
    dvi_out_msen_po1     : out   std_ulogic;                      -- td1_io_029_p_14
    dvi_out_nhpd         : out   std_ulogic;                      -- td1_io_038_n_19
    dvi_out_noc          : out   std_ulogic;                      -- td1_io_037_p_18
    dvi_out_npd          : out   std_ulogic;                      -- td1_io_030_n_15
    dvi_out_vsync        : out   std_ulogic                       -- td1_io_025_p_12
  );
end entity dvi_output_interface;

architecture rtl of dvi_output_interface is
  type tc_states is (idle, running);
  attribute dont_touch : string;

  signal c_frame_out_wfull         : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_WFULL+1))))-1 downto 0);
  signal c_frame_out_hfull         : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_HFULL+1))))-1 downto 0);
  signal c_frame_out_hsync_start   : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_HSYNC_START+1))))-1 downto 0);
  signal c_frame_out_hsync_end     : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_HSYNC_END+1))))-1 downto 0);
  signal c_frame_out_vsync_start   : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_VSYNC_START+1))))-1 downto 0);
  signal c_frame_out_vsync_end     : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_VSYNC_END+1))))-1 downto 0);
  signal r_frame_out_wfull         : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_WFULL+1))))-1 downto 0);
  signal r_frame_out_hfull         : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_HFULL+1))))-1 downto 0);
  signal r_frame_out_hsync_start   : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_HSYNC_START+1))))-1 downto 0);
  signal r_frame_out_hsync_end     : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_HSYNC_END+1))))-1 downto 0);
  signal r_frame_out_vsync_start   : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_VSYNC_START+1))))-1 downto 0);
  signal r_frame_out_vsync_end     : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_VSYNC_END+1))))-1 downto 0);
  signal c_frame_out_black_hoffset : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_BLACK_HOFFSET+1))))-1 downto 0);
  signal c_frame_out_black_voffset : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_BLACK_VOFFSET+1))))-1 downto 0);
  signal c_frame_out_black_hactive : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_BLACK_HACTIVE+1))))-1 downto 0);
  signal c_frame_out_black_vactive : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_OUT_BLACK_VACTIVE+1))))-1 downto 0);

  signal r_frame_out_black_hoffset : unsigned(c_frame_out_black_hoffset'range);
  signal r_frame_out_black_voffset : unsigned(c_frame_out_black_voffset'range);
  signal r_frame_out_black_hactive : unsigned(c_frame_out_black_hactive'range);
  signal r_frame_out_black_vactive : unsigned(c_frame_out_black_vactive'range);

  signal r_px_request_addr  : unsigned(ADDR_W-1 downto 0);
  signal r_next_line        : unsigned(ADDR_W-1 downto 0);
  signal r_px_request_en    : std_ulogic;

  signal r_dvi_out_de : std_logic;
  attribute dont_touch of r_dvi_out_de : signal is "true";
  signal r_dvi_out_hsync        : std_logic;
  attribute dont_touch of r_dvi_out_hsync : signal is "true";
  signal r_dvi_out_vsync        : std_logic;
  attribute dont_touch of r_dvi_out_vsync : signal is "true";
  signal r_dvi_out_vsync_1      : std_logic;
  signal r_dvi_out_data         : std_logic_vector(23 downto 0);
  attribute dont_touch of r_dvi_out_data : signal is "true";

  signal tc_state : tc_states;
  signal req_state : tc_states;

  signal r_frame_in_width : unsigned(10 downto 0);
  signal r_frame_in_height : unsigned(10 downto 0);

  signal r_frame_out_width    : unsigned(10 downto 0);
  signal r_frame_out_height   : unsigned(10 downto 0);
  signal r_frame_out_hsync    : unsigned(10 downto 0);
  signal r_frame_out_hfront   : unsigned(10 downto 0);
  signal r_frame_out_hback    : unsigned(10 downto 0);
  signal r_frame_out_vsync    : unsigned(10 downto 0);
  signal r_frame_out_vfront   : unsigned(10 downto 0);
  signal r_frame_out_vback    : unsigned(10 downto 0);
  signal r_dvi_out_en       : std_ulogic;
  signal r_dvi_out_en_cfg_0 : std_ulogic;
  signal r_dvi_out_en_cfg_1 : std_ulogic;
  signal r_dvi_out_en_tc_0  : std_ulogic;
  signal r_dvi_out_en_tc_1  : std_ulogic;
  signal r_frame_out_active_hsync  : std_ulogic;
  signal r_frame_out_active_vsync  : std_ulogic;
  signal r_frame_out_permutation : std_ulogic_vector(5 downto 0);
  signal r_dvi_out_xboard_config : std_ulogic_vector(12 downto 0);

  signal r_dvi_out_cfg_rdata : std_ulogic_vector(dvi_out_cfg_rdata'range);
  signal r_px_used : std_ulogic;
  signal r_dvi_out_frame_end : std_ulogic;
  attribute dont_touch of r_dvi_out_frame_end : signal is "true";

  signal tc_hcounter : unsigned(c_frame_out_wfull'length-1 downto 0);
  signal tc_vcounter : unsigned(c_frame_out_hfull'length-1 downto 0);
  signal req_hcounter : unsigned(r_frame_out_width'length-1 downto 0);
  signal req_vcounter : unsigned(r_frame_out_height'length-1 downto 0);

  signal px_data_permutation : std_ulogic_vector(23 downto 0);

begin
  px_used <= r_px_used;
  dvi_out_frame_end <= r_dvi_out_frame_end;
  px_request_addr <= std_ulogic_vector(r_px_request_addr);
  px_request_en   <= r_px_request_en;
  dvi_out_cfg_rdata <= r_dvi_out_cfg_rdata;

  -------------------------------------------------------------------------------------------------
  -- frame calculations without clock -------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  frame_calculations : process(r_frame_in_width, r_frame_out_width)
  begin
      if(r_frame_in_width > r_frame_out_width)then
        c_frame_out_black_hoffset <= (others => '0');
      else
        c_frame_out_black_hoffset <= (r_frame_out_width - r_frame_in_width) srl 1;
      end if;
  end process;

  frame_calculations_1 : process(r_frame_out_height, r_frame_in_height)
  begin
      if(r_frame_in_height > r_frame_out_height)then
        c_frame_out_black_voffset <= (others => '0');
      else
        c_frame_out_black_voffset <= (r_frame_out_height - r_frame_in_height) srl 1;
      end if;
  end process;

  c_frame_out_black_hactive <= r_frame_out_width  - c_frame_out_black_hoffset;
  c_frame_out_black_vactive <= r_frame_out_height - c_frame_out_black_voffset;

  c_frame_out_wfull         <= r_frame_out_width  + r_frame_out_hsync + r_frame_out_hfront + r_frame_out_hback;
  c_frame_out_hfull         <= r_frame_out_height + r_frame_out_vsync + r_frame_out_vfront + r_frame_out_vback;
  c_frame_out_hsync_start   <= r_frame_out_width  + r_frame_out_hfront;
  c_frame_out_hsync_end     <= r_frame_out_width  + r_frame_out_hfront + r_frame_out_hsync;
  c_frame_out_vsync_start   <= r_frame_out_height + r_frame_out_vfront;
  c_frame_out_vsync_end     <= r_frame_out_height + r_frame_out_vfront + r_frame_out_vsync;
  
  -------------------------------------------------------------------------------------------------
  -- Configuration of timing controller -----------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  config : process(cfg_clk, reset)
  begin
    if(reset = '1')then
      r_frame_in_width      <= to_unsigned(STD_FRAME_IN_WIDTH, r_frame_in_width'length);
      r_frame_in_height     <= to_unsigned(STD_FRAME_IN_HEIGHT, r_frame_in_height'length);
      r_frame_out_width     <= to_unsigned(STD_FRAME_OUT_WIDTH, r_frame_out_width'length);
      r_frame_out_height    <= to_unsigned(STD_FRAME_OUT_HEIGHT, r_frame_out_height'length);
      r_frame_out_hsync     <= to_unsigned(STD_FRAME_OUT_HSYNC, r_frame_out_hsync'length);
      r_frame_out_hfront    <= to_unsigned(STD_FRAME_OUT_HFRONT, r_frame_out_hfront'length);
      r_frame_out_hback     <= to_unsigned(STD_FRAME_OUT_HBACK, r_frame_out_hback'length);
      r_frame_out_vsync     <= to_unsigned(STD_FRAME_OUT_VSYNC, r_frame_out_vsync'length);
      r_frame_out_vfront    <= to_unsigned(STD_FRAME_OUT_VFRONT, r_frame_out_vfront'length);
      r_frame_out_vback     <= to_unsigned(STD_FRAME_OUT_VBACK, r_frame_out_vback'length);
      r_frame_out_permutation <= std_ulogic_vector(to_unsigned(STD_FRAME_OUT_PERMUTATION, r_frame_out_permutation'length));


      if(STD_DVI_OUT_EN = 0)then
        r_dvi_out_en     <= '0';
      else
        r_dvi_out_en     <= '1';
      end if;

      if(STD_FRAME_OUT_ACTIVE_HSYNC = 0)then
        r_frame_out_active_hsync  <= '0';
      else
        r_frame_out_active_hsync  <= '1';
      end if;

      if(STD_FRAME_OUT_ACTIVE_VSYNC = 0)then
        r_frame_out_active_vsync  <= '0';
      else
        r_frame_out_active_vsync  <= '1';
      end if;

      if(STD_DVI_OUT_A3_DK3 = 0)then
        r_dvi_out_xboard_config(12) <= '0';
      else 
        r_dvi_out_xboard_config(12) <= '1';
      end if;

      if(STD_DVI_OUT_BSEL_SCL = 0)then
        r_dvi_out_xboard_config(11) <= '0';
      else 
        r_dvi_out_xboard_config(11) <= '1';
      end if;

      if(STD_DVI_OUT_CTL = 0)then
        r_dvi_out_xboard_config(10 downto 9) <= "00";
      elsif(STD_DVI_OUT_CTL = 1)then
        r_dvi_out_xboard_config(10 downto 9) <= "01";
      elsif(STD_DVI_OUT_CTL = 2)then
        r_dvi_out_xboard_config(10 downto 9) <= "10";
      else 
        r_dvi_out_xboard_config(10 downto 9) <= "11";
      end if;

      if(STD_DVI_OUT_DKEN = 0)then
        r_dvi_out_xboard_config(8) <= '0';
      else 
        r_dvi_out_xboard_config(8) <= '1';
      end if;

      if(STD_DVI_OUT_DSEL_SDA = 0)then
        r_dvi_out_xboard_config(7) <= '0';
      else 
        r_dvi_out_xboard_config(7) <= '1';
      end if;

      if(STD_DVI_OUT_EDGE = 0)then
        r_dvi_out_xboard_config(6) <= '0';
      else 
        r_dvi_out_xboard_config(6) <= '1';
      end if;

      if(STD_DVI_OUT_IDCLK_N = 0)then
        r_dvi_out_xboard_config(5) <= '0';
      else 
        r_dvi_out_xboard_config(5) <= '1';
      end if;

      if(STD_DVI_OUT_ISEL_NRST = 0)then
        r_dvi_out_xboard_config(4) <= '0';
      else 
        r_dvi_out_xboard_config(4) <= '1';
      end if;

      if(STD_DVI_OUT_MSEN_PO1 = 0)then
        r_dvi_out_xboard_config(3) <= '0';
      else 
        r_dvi_out_xboard_config(3) <= '1';
      end if;

      if(STD_DVI_OUT_NHPD = 0)then
        r_dvi_out_xboard_config(2) <= '0';
      else 
        r_dvi_out_xboard_config(2) <= '1';
      end if;

      if(STD_DVI_OUT_NOC = 0)then
        r_dvi_out_xboard_config(1) <= '0';
      else 
        r_dvi_out_xboard_config(1) <= '1';
      end if;

      if(STD_DVI_OUT_NPD = 0)then
        r_dvi_out_xboard_config(0) <= '0';
      else 
        r_dvi_out_xboard_config(0) <= '1';
      end if;

      r_dvi_out_cfg_rdata <= (others => '0');

    elsif(rising_edge(cfg_clk))then
      r_frame_in_width     <= r_frame_in_width;
      r_frame_in_height    <= r_frame_in_height;
      r_frame_out_width    <= r_frame_out_width;
      r_frame_out_height   <= r_frame_out_height;
      r_frame_out_hsync    <= r_frame_out_hsync;
      r_frame_out_hfront   <= r_frame_out_hfront;
      r_frame_out_hback    <= r_frame_out_hback;
      r_frame_out_vsync    <= r_frame_out_vsync;
      r_frame_out_vfront   <= r_frame_out_vfront;
      r_frame_out_vback    <= r_frame_out_vback;
      r_dvi_out_en       <= r_dvi_out_en;
      r_frame_out_active_hsync  <= r_frame_out_active_hsync;
      r_frame_out_active_vsync  <= r_frame_out_active_vsync;
      r_dvi_out_xboard_config <= r_dvi_out_xboard_config; 

      if((dvi_out_cfg_en and dvi_out_cfg_we) = '1')then
        r_dvi_out_en <= '0';
        case(dvi_out_cfg_addr)is
          when "0000" => 
            if(r_dvi_out_en = '1')then
              r_dvi_out_en     <= dvi_out_cfg_wdata(0);
            else
              r_dvi_out_en     <= dvi_out_cfg_wdata(0) and not r_dvi_out_en_cfg_1 and not px_valid;
            end if;
          when "0001" => r_frame_in_width  <= unsigned(dvi_out_cfg_wdata(r_frame_in_width'range));
          when "0010" => r_frame_in_height <= unsigned(dvi_out_cfg_wdata(r_frame_in_height'range));
          when "0011" => r_frame_out_width  <= unsigned(dvi_out_cfg_wdata(r_frame_out_width'range));
          when "0100" => r_frame_out_height <= unsigned(dvi_out_cfg_wdata(r_frame_out_height'range));
          when "0101" => r_frame_out_hsync  <= unsigned(dvi_out_cfg_wdata(r_frame_out_hsync'range));
          when "0110" => r_frame_out_hfront <= unsigned(dvi_out_cfg_wdata(r_frame_out_hfront'range));
          when "0111" => r_frame_out_hback  <= unsigned(dvi_out_cfg_wdata(r_frame_out_hback'range));
          when "1000" => r_frame_out_vsync  <= unsigned(dvi_out_cfg_wdata(r_frame_out_vsync'range));
          when "1001" => r_frame_out_vfront <= unsigned(dvi_out_cfg_wdata(r_frame_out_vfront'range));
          when "1010" => r_frame_out_vback  <= unsigned(dvi_out_cfg_wdata(r_frame_out_vback'range));
          when "1011" => r_frame_out_active_hsync  <= dvi_out_cfg_wdata(0);
          when "1100" => r_frame_out_active_vsync  <= dvi_out_cfg_wdata(0);
          when "1101" => r_frame_out_permutation  <= dvi_out_cfg_wdata(r_frame_out_permutation'range);
          when "1110" => r_dvi_out_xboard_config  <= dvi_out_cfg_wdata(r_dvi_out_xboard_config'range);
          when others => r_dvi_out_en     <= r_dvi_out_en;
        end case;
      else 
        r_dvi_out_cfg_rdata <= (others => '0');
        case(dvi_out_cfg_addr)is
          when "0000" => r_dvi_out_cfg_rdata(2 downto 0) <= px_valid & r_dvi_out_en_cfg_1 & r_dvi_out_en;
          when "0001" => r_dvi_out_cfg_rdata(r_frame_in_width'range) <= std_ulogic_vector(r_frame_in_width);
          when "0010" => r_dvi_out_cfg_rdata(r_frame_in_height'range) <= std_ulogic_vector(r_frame_in_height);
          when "0011" => r_dvi_out_cfg_rdata(r_frame_out_width'range) <= std_ulogic_vector(r_frame_out_width);
          when "0100" => r_dvi_out_cfg_rdata(r_frame_out_height'range) <= std_ulogic_vector(r_frame_out_height);
          when "0101" => r_dvi_out_cfg_rdata(r_frame_out_hsync'range) <= std_ulogic_vector(r_frame_out_hsync);
          when "0110" => r_dvi_out_cfg_rdata(r_frame_out_hfront'range) <= std_ulogic_vector(r_frame_out_hfront);
          when "0111" => r_dvi_out_cfg_rdata(r_frame_out_hback'range) <= std_ulogic_vector(r_frame_out_hback);
          when "1000" => r_dvi_out_cfg_rdata(r_frame_out_vsync'range) <= std_ulogic_vector(r_frame_out_vsync);
          when "1001" => r_dvi_out_cfg_rdata(r_frame_out_vfront'range) <= std_ulogic_vector(r_frame_out_vfront);
          when "1010" => r_dvi_out_cfg_rdata(r_frame_out_vback'range) <= std_ulogic_vector(r_frame_out_vback);
          when "1011" => r_dvi_out_cfg_rdata(0) <= r_frame_out_active_hsync;
          when "1100" => r_dvi_out_cfg_rdata(0) <= r_frame_out_active_vsync;
          when "1101" => r_dvi_out_cfg_rdata(r_frame_out_permutation'range) <= r_frame_out_permutation;
          when "1110" => r_dvi_out_cfg_rdata(r_dvi_out_xboard_config'range) <= r_dvi_out_xboard_config;
          when others => null;
        end case;

      end if;

      r_dvi_out_en_cfg_0 <= r_dvi_out_en_tc_1;
      r_dvi_out_en_cfg_1 <= r_dvi_out_en_cfg_0;

    end if;
  end process;

  -------------------------------------------------------------------------------------------------
  -- en signal clock region transition ------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  en : process(dvi_out_clk)
  begin
  
    if(rising_edge(dvi_out_clk)) then
      r_dvi_out_en_tc_0 <= r_dvi_out_en;
      r_dvi_out_en_tc_1 <= r_dvi_out_en_tc_0;

    end if;

  end process;

  -------------------------------------------------------------------------------------------------
  -- write pixels to hdmi out - blacken border if necessary ---------------------------------------
  -------------------------------------------------------------------------------------------------

  timingController : process(dvi_out_clk, reset, r_dvi_out_en_tc_1)
  begin
  
    if((reset or (not r_dvi_out_en_tc_1)) = '1') then
      tc_vcounter <= to_unsigned(0, tc_vcounter'length);
      tc_hcounter <= to_unsigned(0, tc_hcounter'length);
      r_dvi_out_de <= '0';
      r_dvi_out_hsync <= '0';
      r_dvi_out_vsync <= '0';
      r_dvi_out_data <= x"000000";
      r_dvi_out_frame_end <= '0';
      r_px_used <= '1';

      r_frame_out_black_hoffset <= (others => '0');
      r_frame_out_black_hactive <= (others => '0');
      r_frame_out_black_voffset <= (others => '0');
      r_frame_out_black_vactive <= (others => '0');

      r_frame_out_wfull         <= (others => '0');
      r_frame_out_hfull         <= (others => '0');
      r_frame_out_hsync_start   <= (others => '0');
      r_frame_out_hsync_end     <= (others => '0');
      r_frame_out_vsync_start   <= (others => '0');
      r_frame_out_vsync_end     <= (others => '0');

      tc_state <= idle;
    elsif(rising_edge(dvi_out_clk)) then
      tc_state <= tc_state;

      r_frame_out_black_hoffset <= c_frame_out_black_hoffset;
      r_frame_out_black_hactive <= c_frame_out_black_hactive;
      r_frame_out_black_voffset <= c_frame_out_black_voffset;
      r_frame_out_black_vactive <= c_frame_out_black_vactive;

      r_frame_out_wfull         <= c_frame_out_wfull;
      r_frame_out_hfull         <= c_frame_out_hfull;
      r_frame_out_hsync_start   <= c_frame_out_hsync_start;
      r_frame_out_hsync_end     <= c_frame_out_hsync_end;
      r_frame_out_vsync_start   <= c_frame_out_vsync_start;
      r_frame_out_vsync_end     <= c_frame_out_vsync_end;

      r_px_used <= '0';

      r_dvi_out_frame_end <= (r_dvi_out_vsync and (not r_dvi_out_vsync_1) and r_frame_out_active_vsync) or ((not r_dvi_out_vsync) and r_dvi_out_vsync_1 and not r_frame_out_active_vsync);

      case (tc_state) is
        when idle =>
          tc_vcounter <= to_unsigned(0, tc_vcounter'length);
          tc_hcounter <= to_unsigned(0, tc_hcounter'length);
          r_dvi_out_de <= '0';
          r_dvi_out_hsync <= '0';
          r_dvi_out_vsync <= '0';
          r_dvi_out_data <= r_dvi_out_data;
          if(px_valid = '1')then
            tc_state <= running;
          end if;
          

        when running =>
          if((tc_hcounter >= r_frame_out_black_hoffset and tc_hcounter < r_frame_out_black_hactive) and
             (tc_vcounter >= r_frame_out_black_voffset and tc_vcounter < r_frame_out_black_vactive))then
            if(px_valid = '1')then
              r_dvi_out_data <= std_logic_vector(px_data);
              r_px_used <= '1';
            end if;
          else
            r_dvi_out_data <= x"000000";
          end if;

          if ((tc_hcounter < r_frame_out_width) and (tc_vcounter < r_frame_out_height)) then
            r_dvi_out_de <= '1';
          else
            r_dvi_out_de <= '0';
          end if;

          if ((tc_hcounter >= c_frame_out_hsync_start) and (tc_hcounter < c_frame_out_hsync_end)) then 
            r_dvi_out_hsync <= r_frame_out_active_hsync;
          else
            r_dvi_out_hsync <= not r_frame_out_active_hsync;
          end if;

          if ((tc_vcounter >= c_frame_out_vsync_start) and (tc_vcounter < c_frame_out_vsync_end)) then
            r_dvi_out_vsync <= r_frame_out_active_vsync;
          else
            r_dvi_out_vsync <= not r_frame_out_active_vsync;
          end if;

          if(tc_hcounter >= r_frame_out_wfull-1) then
              tc_hcounter <= to_unsigned(0, tc_hcounter'length);
              if(tc_vcounter >= r_frame_out_hfull-1) then
                tc_vcounter <= to_unsigned(0, tc_vcounter'length);
              else
                tc_vcounter <= tc_vcounter + to_unsigned(1, tc_vcounter'length);
              end if;
          else
            tc_hcounter <= tc_hcounter + to_unsigned(1, tc_hcounter'length);
            tc_vcounter <= tc_vcounter;
          end if;
      
        when others =>
          tc_vcounter <= to_unsigned(0, tc_vcounter'length);
          tc_hcounter <= to_unsigned(0, tc_hcounter'length);
          r_dvi_out_de <= '0';
          r_dvi_out_hsync <= '0';
          r_dvi_out_vsync <= '0';
          r_dvi_out_data <= x"000000";
          tc_state <= idle;

      end case;

      r_dvi_out_vsync_1 <= r_dvi_out_vsync;

    end if;

  end process;

  -------------------------------------------------------------------------------------------------
  -- request pixels from frame buffer -------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  requestPixels : process(dvi_out_clk, reset, r_dvi_out_en_tc_1)
  begin
  
    if((reset or (not r_dvi_out_en_tc_1)) = '1') then
      req_vcounter <= to_unsigned(0, req_vcounter'length);
      req_hcounter <= to_unsigned(0, req_hcounter'length);
      r_px_request_addr  <= (others => '0');
      r_px_request_en    <= '0';
      r_next_line <= (others => '0');
      r_next_line(r_frame_in_width'range) <= r_frame_in_width;

      req_state <= idle;
    elsif(rising_edge(dvi_out_clk)) then
      req_state <= req_state;
      req_vcounter <= req_vcounter;
      req_hcounter <= req_hcounter;

      r_px_request_addr  <= r_px_request_addr;
      r_px_request_en    <= '0';

      case (req_state) is
        when idle =>
          req_vcounter <= to_unsigned(0, req_vcounter'length);
          req_hcounter <= to_unsigned(0, req_hcounter'length);
          if(px_request_ready = '1')then
            r_px_request_addr <= (others => '0');
            r_px_request_en    <= '1';
            req_state <= running;
          end if;
          
        when running =>
          if(r_dvi_out_frame_end = '1')then
            req_state <= idle;
          end if;

--      when running =>
--        if(px_request_ready = '1')then
--          
--          if((req_hcounter >= r_frame_out_black_hoffset and req_hcounter < r_frame_out_black_hactive) and
--             (req_vcounter >= r_frame_out_black_voffset and req_vcounter < r_frame_out_black_vactive))then
--              r_px_request_en    <= '1';
--          end if;
--          
--          if(r_px_request_en = '1')then
--              r_px_request_addr <= r_px_request_addr +1;
--          end if;

--          if(req_hcounter >= r_frame_out_width) then
--              req_hcounter <= to_unsigned(0, req_hcounter'length);
--              if(req_vcounter >= r_frame_out_black_voffset)then
--                r_px_request_addr <= (others => '0');
--                r_px_request_addr(r_next_line'range) <= r_next_line;
--                r_next_line <= r_next_line + r_frame_in_width;
--              end if;
--              if(req_vcounter >= r_frame_out_height-1) then
--                req_vcounter <= to_unsigned(0, req_vcounter'length);
--                r_px_request_addr <= (others => '0');
--                r_next_line <= (others => '0');
--                r_next_line(r_frame_in_width'range) <= r_frame_in_width;
--              else
--                req_vcounter <= req_vcounter + to_unsigned(1, req_vcounter'length);
--              end if;
--          else
--            req_hcounter <= req_hcounter + to_unsigned(1, req_hcounter'length);
--          end if;
--        end if;
      
        when others =>
          req_vcounter <= to_unsigned(0, req_vcounter'length);
          req_hcounter <= to_unsigned(0, req_hcounter'length);
          r_px_request_addr  <= (others => '1');
          r_px_request_en    <= '0';
    
          req_state <= idle;
  
      end case;

    end if;

  end process;

  -------------------------------------------------------------------------------------------------
  -- static dvi configuration ---------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  dvi_out_a3_dk3       <= r_dvi_out_xboard_config(12); -- '0'; --  out   std_ulogic;                      -- td1_io_034_n_17
  dvi_out_bsel_scl     <= r_dvi_out_xboard_config(11); -- '1'; --  out   std_ulogic;                      -- td1_io_035_p_17
  dvi_out_ctl          <= r_dvi_out_xboard_config(10 downto 9); -- "00"; --  out   std_ulogic_vector(1 downto 0);
  dvi_out_dken         <= r_dvi_out_xboard_config(8); -- '0'; --  out   std_ulogic;                      -- td1_io_028_n_14
  dvi_out_dsel_sda     <= r_dvi_out_xboard_config(7); -- '0'; --  out   std_ulogic;                      -- td1_io_036_n_18
  dvi_out_edge         <= r_dvi_out_xboard_config(6); -- '1'; --  out   std_ulogic;                      -- td1_io_027_p_13
  dvi_out_idclk_n      <= r_dvi_out_xboard_config(5); -- '0'; --  out   std_ulogic;                      -- td1_clkio_n_5_srcc
  dvi_out_isel_nrst    <= r_dvi_out_xboard_config(4); -- '0'; --  out   std_ulogic;                      -- td1_io_031_p_15
  dvi_out_msen_po1     <= r_dvi_out_xboard_config(3); -- '0'; --  out   std_ulogic;                      -- td1_io_029_p_14
  dvi_out_nhpd         <= r_dvi_out_xboard_config(2); -- '1'; --  out   std_ulogic;                      -- td1_io_038_n_19
  dvi_out_noc          <= r_dvi_out_xboard_config(1); -- '0'; --  out   std_ulogic;                      -- td1_io_037_p_18
  dvi_out_npd          <= r_dvi_out_xboard_config(0); -- '1'; --  out   std_ulogic;                      -- td1_io_030_n_15

  -------------------------------------------------------------------------------------------------
  -- dvi out --------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  px_data_permutation( 7 downto  0) <= px_data(15 downto  8) when r_frame_out_permutation(1 downto 0) = "10" else
                                       px_data(23 downto 16) when r_frame_out_permutation(1 downto 0) = "11" else
                                       px_data( 7 downto  0);
  px_data_permutation(15 downto  8) <= px_data( 7 downto  0) when r_frame_out_permutation(3 downto 2) = "01" else
                                       px_data(23 downto 16) when r_frame_out_permutation(3 downto 2) = "11" else
                                       px_data(15 downto  8);
  px_data_permutation(23 downto 16) <= px_data( 7 downto  0) when r_frame_out_permutation(5 downto 4) = "01" else
                                       px_data(15 downto  8) when r_frame_out_permutation(5 downto 4) = "10" else
                                       px_data(23 downto 16);
  dvi_out_data         <= px_data_permutation when r_px_used = '1' else x"000000"; 
  dvi_out_de           <= r_dvi_out_de; 
  dvi_out_hsync        <= r_dvi_out_hsync; 
  dvi_out_idclk_p      <= dvi_out_clk; 
  dvi_out_vsync        <= r_dvi_out_vsync; 

end architecture rtl;

  
