-- =============================================================================
--!  @project      frame buffer tcpa
-- =============================================================================
--!  @file         dvi_output_color_box.vhd
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

entity dvi_output_color_box is
  generic (
    STD_FRAME_IN_HOFFSET       : integer  range   0 to 2046 :=    0;
    STD_FRAME_IN_VOFFSET       : integer  range   0 to 1022 :=    0;
    STD_FRAME_BOX1_X1          : integer  range   0 to 2046 :=    0;
    STD_FRAME_BOX1_Y1          : integer  range   0 to 1022 :=    0;
    STD_FRAME_BOX1_X2          : integer  range   0 to 2046 :=    0;
    STD_FRAME_BOX1_Y2          : integer  range   0 to 1022 :=    0;
    STD_FRAME_BOX2_X1          : integer  range   0 to 2046 :=    0;
    STD_FRAME_BOX2_Y1          : integer  range   0 to 1022 :=    0;
    STD_FRAME_BOX2_X2          : integer  range   0 to 2046 :=    0;
    STD_FRAME_BOX2_Y2          : integer  range   0 to 1022 :=    0;
    STD_FRAME_BOX3_X1          : integer  range   0 to 2046 :=    0;
    STD_FRAME_BOX3_Y1          : integer  range   0 to 1022 :=    0;
    STD_FRAME_BOX3_X2          : integer  range   0 to 2046 :=    0;
    STD_FRAME_BOX3_Y2          : integer  range   0 to 1022 :=    0;
    STD_FRAME_BOX4_X1          : integer  range   0 to 2046 :=    0;
    STD_FRAME_BOX4_Y1          : integer  range   0 to 1022 :=    0;
    STD_FRAME_BOX4_X2          : integer  range   0 to 2046 :=    0;
    STD_FRAME_BOX4_Y2          : integer  range   0 to 1022 :=    0;
    STD_COLOR_BOX1             : integer  range   0 to 16777215 := 255; -- x"0000FF"
    STD_COLOR_BOX2             : integer  range   0 to 16777215 := 16711680; -- x"FF0000"
    STD_COLOR_BOX3             : integer  range   0 to 16777215 := 65535; -- x"00FFFF"
    STD_COLOR_BOX4             : integer  range   0 to 16777215 := 16776960; -- x"FFFF00"
    STD_DVI_OUT_EN             : integer  range   0 to    1 :=    1;
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
    dvi_in_clk  : in   std_ulogic;                      -- td1_clkio_p_5_srcc
    cfg_clk     : in std_ulogic;
    reset : in std_ulogic;

    dvi_out_cfg_wdata : in  std_ulogic_vector(23 downto 0);
    dvi_out_cfg_rdata : out std_ulogic_vector(23 downto 0);
    dvi_out_cfg_addr  : in  std_ulogic_vector(3 downto 0);
    dvi_out_cfg_we    : in  std_ulogic;
    dvi_out_cfg_en    : in  std_ulogic;

    dvi_in_data         : in   std_ulogic_vector(23 downto 0);
    dvi_in_de           : in   std_ulogic;                      -- td1_io_026_n_13
    dvi_in_hsync        : in   std_ulogic;                      -- td1_io_024_n_12
    dvi_in_vsync        : in   std_ulogic;                      -- td1_io_025_p_12
    dvi_in_valid        : in   std_ulogic;                      -- td1_io_025_p_12

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
end entity dvi_output_color_box;

architecture rtl of dvi_output_color_box is
  type tc_states is (idle, running);

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
  signal r_frame_in_hoffset        : unsigned(10 downto 0);
  signal r_frame_in_voffset        : unsigned(10 downto 0);
  signal r_frame_select_box        : unsigned(1 downto 0);
  signal r_frame_box1_x1           : unsigned(10 downto 0);
  signal r_frame_box1_y1           : unsigned(10 downto 0);
  signal r_frame_box1_x2           : unsigned(10 downto 0);
  signal r_frame_box1_y2           : unsigned(10 downto 0);
  signal r_frame_box2_x1            : unsigned(10 downto 0);
  signal r_frame_box2_y1            : unsigned(10 downto 0);
  signal r_frame_box2_x2            : unsigned(10 downto 0);
  signal r_frame_box2_y2            : unsigned(10 downto 0);
  signal r_frame_out_box1_x1       : unsigned(10 downto 0);
  signal r_frame_out_box1_y1       : unsigned(10 downto 0);
  signal r_frame_out_box1_x2       : unsigned(10 downto 0);
  signal r_frame_out_box1_y2       : unsigned(10 downto 0);
  signal r_frame_out_box2_x1        : unsigned(10 downto 0);
  signal r_frame_out_box2_y1        : unsigned(10 downto 0);
  signal r_frame_out_box2_x2        : unsigned(10 downto 0);
  signal r_frame_out_box2_y2        : unsigned(10 downto 0);
  signal r_frame_out_box3_x1        : unsigned(10 downto 0);
  signal r_frame_out_box3_y1        : unsigned(10 downto 0);
  signal r_frame_out_box3_x2        : unsigned(10 downto 0);
  signal r_frame_out_box3_y2        : unsigned(10 downto 0);
  signal r_frame_out_box4_x1        : unsigned(10 downto 0);
  signal r_frame_out_box4_y1        : unsigned(10 downto 0);
  signal r_frame_out_box4_x2        : unsigned(10 downto 0);
  signal r_frame_out_box4_y2        : unsigned(10 downto 0);


  signal r_frame_out_black_hoffset : unsigned(c_frame_out_black_hoffset'range);
  signal r_frame_out_black_voffset : unsigned(c_frame_out_black_voffset'range);
  signal r_frame_out_black_hactive : unsigned(c_frame_out_black_hactive'range);
  signal r_frame_out_black_vactive : unsigned(c_frame_out_black_vactive'range);

  signal r_dvi_out_de : std_logic;
  signal r_dvi_out_hsync        : std_logic;
  signal r_dvi_out_vsync        : std_logic;
  signal r_dvi_out_vsync_1      : std_logic;
  signal r_dvi_out_data         : std_ulogic_vector(23 downto 0);

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
  signal r_frame_out_active_hsync  : std_ulogic;
  signal r_frame_out_active_vsync  : std_ulogic;
  signal r_dvi_out_xboard_config : std_ulogic_vector(12 downto 0);

  signal r_dvi_out_cfg_rdata : std_ulogic_vector(dvi_out_cfg_rdata'range);
  signal r_px_used : std_ulogic;
  signal r_dvi_out_frame_end : std_ulogic;

  signal tc_hcounter : unsigned(10 downto 0);
  signal tc_vcounter : unsigned(10 downto 0);
  signal hoffset_counter : unsigned(10 downto 0);
  signal voffset_counter : unsigned(10 downto 0);

  signal w_dvi_in_hsync : std_ulogic;
  signal w_dvi_in_vsync : std_ulogic;

  signal r_dvi_in_hsync_ref : std_ulogic;
  signal r_dvi_in_vsync_ref : std_ulogic;

  signal r_active_frame : std_ulogic;

  signal px_box1 : std_ulogic;
  signal px_box2  : std_ulogic;

  signal r_dvi_in_data  : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_de    : std_ulogic;
  signal r_dvi_in_hsync : std_ulogic;
  signal r_dvi_in_vsync : std_ulogic;
  signal r_dvi_in_valid : std_ulogic;
  
  signal r_color_box1 : std_ulogic_vector(23 downto 0);
  signal r_color_box2 : std_ulogic_vector(23 downto 0);
  signal r_color_box3 : std_ulogic_vector(23 downto 0);
  signal r_color_box4 : std_ulogic_vector(23 downto 0);

begin
  dvi_out_cfg_rdata <= r_dvi_out_cfg_rdata;

  input_data : process(dvi_in_clk)
  begin
    if(rising_edge(dvi_in_clk))then
      r_dvi_in_data  <= dvi_in_data;
      r_dvi_in_de    <= dvi_in_de;
      r_dvi_in_hsync <= dvi_in_hsync;
      r_dvi_in_vsync <= dvi_in_vsync;
      r_dvi_in_valid <= dvi_in_valid;
    end if;
  end process;

  -------------------------------------------------------------------------------------------------
  -- Configuration of timing controller -----------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  config : process(cfg_clk, reset)
  begin
    if(reset = '1')then
      r_frame_in_hoffset <= to_unsigned(STD_FRAME_IN_HOFFSET, r_frame_in_hoffset'length);
      r_frame_in_voffset <= to_unsigned(STD_FRAME_IN_VOFFSET, r_frame_in_voffset'length);
      r_frame_select_box <= "00";
      r_frame_box1_x1  <= to_unsigned(STD_FRAME_BOX1_X1, r_frame_box1_x1'length);
      r_frame_box1_y1  <= to_unsigned(STD_FRAME_BOX1_Y1, r_frame_box1_y1'length);
      r_frame_box1_x2  <= to_unsigned(STD_FRAME_BOX1_X2, r_frame_box1_x2'length);
      r_frame_box1_y2  <= to_unsigned(STD_FRAME_BOX1_Y2, r_frame_box1_y2'length);
      r_frame_box2_x1  <= to_unsigned(STD_FRAME_BOX2_X1, r_frame_box2_x1'length);
      r_frame_box2_y1  <= to_unsigned(STD_FRAME_BOX2_Y1, r_frame_box2_y1'length);
      r_frame_box2_x2  <= to_unsigned(STD_FRAME_BOX2_X2, r_frame_box2_x2'length);
      r_frame_box2_y2  <= to_unsigned(STD_FRAME_BOX2_Y2, r_frame_box2_y2'length);
      r_frame_box3_x1  <= to_unsigned(STD_FRAME_BOX3_X1, r_frame_box3_x1'length);
      r_frame_box3_y1  <= to_unsigned(STD_FRAME_BOX3_Y1, r_frame_box3_y1'length);
      r_frame_box3_x2  <= to_unsigned(STD_FRAME_BOX3_X2, r_frame_box3_x2'length);
      r_frame_box3_y2  <= to_unsigned(STD_FRAME_BOX3_Y2, r_frame_box3_y2'length);
      r_frame_box4_x1  <= to_unsigned(STD_FRAME_BOX4_X1, r_frame_box4_x1'length);
      r_frame_box4_y1  <= to_unsigned(STD_FRAME_BOX4_Y1, r_frame_box4_y1'length);
      r_frame_box4_x2  <= to_unsigned(STD_FRAME_BOX4_X2, r_frame_box4_x2'length);
      r_frame_box4_y2  <= to_unsigned(STD_FRAME_BOX4_Y2, r_frame_box4_y2'length);
      r_color_box1 <= std_ulogic_vector(to_unsigned(STD_FRAME_COLOR_BOX1, r_color_box1'length));
      r_color_box2 <= std_ulogic_vector(to_unsigned(STD_FRAME_COLOR_BOX2, r_color_box2'length));
      r_color_box3 <= std_ulogic_vector(to_unsigned(STD_FRAME_COLOR_BOX3, r_color_box3'length));
      r_color_box4 <= std_ulogic_vector(to_unsigned(STD_FRAME_COLOR_BOX4, r_color_box4'length));

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
      r_frame_out_active_hsync  <= r_frame_out_active_hsync;
      r_frame_out_active_vsync  <= r_frame_out_active_vsync;
      r_dvi_out_xboard_config <= r_dvi_out_xboard_config; 

      if((dvi_out_cfg_en and dvi_out_cfg_we) = '1')then
        case(dvi_out_cfg_addr)is
          when "0000" => r_frame_in_hoffset <= unsigned(dvi_out_cfg_wdata(r_frame_in_hoffset'range));
          when "0001" => r_frame_in_voffset <= unsigned(dvi_out_cfg_wdata(r_frame_in_voffset'range));
          when "0010" => r_frame_select_box <= unsigned(dvi_out_cfg_wdata(r_frame_select_box'range));
          when "0011" => 
            case(r_frame_select_box)is
              when "00" => r_frame_box1_x1 <= unsigned(dvi_out_cfg_wdata(r_frame_box1_x1'range));
              when "01" => r_frame_box2_x1 <= unsigned(dvi_out_cfg_wdata(r_frame_box2_x1'range));
              when "10" => r_frame_box3_x1 <= unsigned(dvi_out_cfg_wdata(r_frame_box3_x1'range));
              when "11" => r_frame_box4_x1 <= unsigned(dvi_out_cfg_wdata(r_frame_box4_x1'range));
            end case
          when "0100" => r_frame_box1_y1
            case(r_frame_select_box)is
              when "00" => r_frame_box1_y1 <= unsigned(dvi_out_cfg_wdata(r_frame_box1_y1'range));
              when "01" => r_frame_box2_y1 <= unsigned(dvi_out_cfg_wdata(r_frame_box2_y1'range));
              when "10" => r_frame_box3_y1 <= unsigned(dvi_out_cfg_wdata(r_frame_box3_y1'range));
              when "11" => r_frame_box4_y1 <= unsigned(dvi_out_cfg_wdata(r_frame_box4_y1'range));
            end case
          when "0101" => r_frame_box1_x2
            case(r_frame_select_box)is
              when "00" => r_frame_box1_x2 <= unsigned(dvi_out_cfg_wdata(r_frame_box1_x2'range));
              when "01" => r_frame_box2_x2 <= unsigned(dvi_out_cfg_wdata(r_frame_box2_x2'range));
              when "10" => r_frame_box3_x2 <= unsigned(dvi_out_cfg_wdata(r_frame_box3_x2'range));
              when "11" => r_frame_box4_x2 <= unsigned(dvi_out_cfg_wdata(r_frame_box4_x2'range));
            end case
          when "0110" => r_frame_box1_y2
            case(r_frame_select_box)is
              when "00" => r_frame_box1_y2 <= unsigned(dvi_out_cfg_wdata(r_frame_box1_y2'range));
              when "01" => r_frame_box2_y2 <= unsigned(dvi_out_cfg_wdata(r_frame_box2_y2'range));
              when "10" => r_frame_box3_y2 <= unsigned(dvi_out_cfg_wdata(r_frame_box3_y2'range));
              when "11" => r_frame_box4_y2 <= unsigned(dvi_out_cfg_wdata(r_frame_box4_y2'range));
            end case
          when "0111" => r_color_box1 <= dvi_out_cfg_wdata(r_color_box1'range);
            case(r_frame_select_box)is
              when "00" => r_color_box1 <= unsigned(dvi_out_cfg_wdata(r_color_box1'range));
              when "01" => r_color_box2 <= unsigned(dvi_out_cfg_wdata(r_color_box2'range));
              when "10" => r_color_box3 <= unsigned(dvi_out_cfg_wdata(r_color_box3'range));
              when "11" => r_color_box4 <= unsigned(dvi_out_cfg_wdata(r_color_box4'range));
            end case
          when "1000" => r_dvi_out_xboard_config  <= dvi_out_cfg_wdata(r_dvi_out_xboard_config'range);
          when others => null;
        end case;
      else 
        r_dvi_out_cfg_rdata <= (others => '0');
        case(dvi_out_cfg_addr)is
          when "0000" => r_dvi_out_cfg_rdata(r_frame_in_hoffset'range) <= std_ulogic_vector(r_frame_in_hoffset);
          when "0001" => r_dvi_out_cfg_rdata(r_frame_in_voffset'range) <= std_ulogic_vector(r_frame_in_voffset);
          when "0010" => r_dvi_out_cfg_rdata(r_frame_select_box'range) <= std_ulogic_vector(r_frame_select_box);
          when "0011" => 
            case(r_frame_select_box)is
              when "00" => r_dvi_out_cfg_rdata(r_frame_box1_x1'range) <= std_ulogic_vector(r_frame_box1_x1);
              when "01" => r_dvi_out_cfg_rdata(r_frame_box2_x1'range) <= std_ulogic_vector(r_frame_box2_x1);
              when "10" => r_dvi_out_cfg_rdata(r_frame_box3_x1'range) <= std_ulogic_vector(r_frame_box3_x1);
              when "11" => r_dvi_out_cfg_rdata(r_frame_box4_x1'range) <= std_ulogic_vector(r_frame_box4_x1);
            end case
          when "0100" => r_dvi_out_cfg_rdata(r_frame_box1_y1'range) <= std_ulogic_vector(r_frame_box1_y1);
            case(r_frame_select_box)is
              when "00" => r_dvi_out_cfg_rdata(r_frame_box1_y1'range) <= std_ulogic_vector(r_frame_box1_y1);
              when "01" => r_dvi_out_cfg_rdata(r_frame_box2_y1'range) <= std_ulogic_vector(r_frame_box2_y1);
              when "10" => r_dvi_out_cfg_rdata(r_frame_box3_y1'range) <= std_ulogic_vector(r_frame_box3_y1);
              when "11" => r_dvi_out_cfg_rdata(r_frame_box4_y1'range) <= std_ulogic_vector(r_frame_box4_y1);
            end case
          when "0101" => r_dvi_out_cfg_rdata(r_frame_box1_x2'range) <= std_ulogic_vector(r_frame_box1_x2);
            case(r_frame_select_box)is
              when "00" => r_dvi_out_cfg_rdata(r_frame_box1_x2'range) <= std_ulogic_vector(r_frame_box1_x2);
              when "01" => r_dvi_out_cfg_rdata(r_frame_box2_x2'range) <= std_ulogic_vector(r_frame_box2_x2);
              when "10" => r_dvi_out_cfg_rdata(r_frame_box3_x2'range) <= std_ulogic_vector(r_frame_box3_x2);
              when "11" => r_dvi_out_cfg_rdata(r_frame_box4_x2'range) <= std_ulogic_vector(r_frame_box4_x2);
            end case
          when "0110" => r_dvi_out_cfg_rdata(r_frame_box1_y2'range) <= std_ulogic_vector(r_frame_box1_y2);
            case(r_frame_select_box)is
              when "00" => r_dvi_out_cfg_rdata(r_frame_box1_y2'range) <= std_ulogic_vector(r_frame_box1_y2);
              when "01" => r_dvi_out_cfg_rdata(r_frame_box2_y2'range) <= std_ulogic_vector(r_frame_box2_y2);
              when "10" => r_dvi_out_cfg_rdata(r_frame_box3_y2'range) <= std_ulogic_vector(r_frame_box3_y2);
              when "11" => r_dvi_out_cfg_rdata(r_frame_box4_y2'range) <= std_ulogic_vector(r_frame_box4_y2);
            end case
          when "0111" => r_dvi_out_cfg_rdata(r_color_box1'range) <= r_color_box1;
            case(r_frame_select_box)is
              when "00" => r_dvi_out_cfg_rdata(r_color_box1'range) <= std_ulogic_vector(r_color_box1);
              when "01" => r_dvi_out_cfg_rdata(r_color_box2'range) <= std_ulogic_vector(r_color_box2);
              when "10" => r_dvi_out_cfg_rdata(r_color_box3'range) <= std_ulogic_vector(r_color_box3);
              when "11" => r_dvi_out_cfg_rdata(r_color_box4'range) <= std_ulogic_vector(r_color_box4);
            end case
          when "1000" => r_dvi_out_cfg_rdata(r_dvi_out_xboard_config'range) <= r_dvi_out_xboard_config;
          when others => null;
        end case;

      end if;

    end if;
  end process;

  -------------------------------------------------------------------------------------------------
  -- write pixels to hdmi out - blacken border if necessary ---------------------------------------
  -------------------------------------------------------------------------------------------------

  timingController : process(dvi_in_clk, reset, r_dvi_in_valid)
  begin
  
    if((reset or (not r_dvi_in_valid)) = '1') then
      tc_vcounter <= to_unsigned(0, tc_vcounter'length);
      tc_hcounter <= to_unsigned(0, tc_hcounter'length);
      hoffset_counter <= (others => '0');
      voffset_counter <= (others => '0');
      r_dvi_in_hsync_ref <= '0';
      r_dvi_in_vsync_ref <= '0';
      r_dvi_out_de <= '0';
      r_dvi_out_hsync <= '0';
      r_dvi_out_vsync <= '0';
      r_dvi_out_data <= x"000000";
      r_frame_out_box1_x1 <= (others => '0');
      r_frame_out_box1_y1 <= (others => '0');
      r_frame_out_box1_x2 <= (others => '0');
      r_frame_out_box1_y2 <= (others => '0');
      r_frame_out_box2_x1  <= (others => '0');
      r_frame_out_box2_y1  <= (others => '0');
      r_frame_out_box2_x2  <= (others => '0');
      r_frame_out_box2_y2  <= (others => '0');
      r_frame_out_box3_x1  <= (others => '0');
      r_frame_out_box3_y1  <= (others => '0');
      r_frame_out_box3_x2  <= (others => '0');
      r_frame_out_box3_y2  <= (others => '0');
      r_frame_out_box4_x1  <= (others => '0');
      r_frame_out_box4_y1  <= (others => '0');
      r_frame_out_box4_x2  <= (others => '0');
      r_frame_out_box4_y2  <= (others => '0');
      r_active_frame <= '0';

    elsif(rising_edge(dvi_in_clk)) then
      r_frame_out_box1_x1 <= r_frame_out_box1_x1;
      r_frame_out_box1_y1 <= r_frame_out_box1_y1;
      r_frame_out_box1_x2 <= r_frame_out_box1_x2;
      r_frame_out_box1_y2 <= r_frame_out_box1_y2;
      r_frame_out_box2_x1 <= r_frame_out_box2_x1;
      r_frame_out_box2_y1 <= r_frame_out_box2_y1;
      r_frame_out_box2_x2 <= r_frame_out_box2_x2;
      r_frame_out_box2_y2 <= r_frame_out_box2_y2;
      r_frame_out_box3_x1 <= r_frame_out_box3_x1;
      r_frame_out_box3_y1 <= r_frame_out_box3_y1;
      r_frame_out_box3_x2 <= r_frame_out_box3_x2;
      r_frame_out_box3_y2 <= r_frame_out_box3_y2;
      r_frame_out_box4_x1 <= r_frame_out_box4_x1;
      r_frame_out_box4_y1 <= r_frame_out_box4_y1;
      r_frame_out_box4_x2 <= r_frame_out_box4_x2;
      r_frame_out_box4_y2 <= r_frame_out_box4_y2;
      r_active_frame <= r_active_frame;
       
      r_dvi_out_data <= r_dvi_in_data;
      if(hoffset_counter = r_frame_in_hoffset and voffset_counter = r_frame_in_voffset)then
        if(((tc_hcounter = r_frame_out_box1_x1 or tc_hcounter = r_frame_out_box1_x2) and 
           tc_vcounter >= r_frame_out_box1_y1 and tc_vcounter <= r_frame_out_box1_y2) or
           ((tc_vcounter = r_frame_out_box1_y1 or tc_vcounter = r_frame_out_box1_y2) and
           tc_hcounter >= r_frame_out_box1_x1 and tc_hcounter <= r_frame_out_box1_x2))then
          r_dvi_out_data <= r_color_box1;
        end if;
        if(((tc_hcounter = r_frame_out_box2_x1 or tc_hcounter = r_frame_out_box2_x2) and 
           tc_vcounter >= r_frame_out_box2_y1 and tc_vcounter <= r_frame_out_box2_y2) or
           ((tc_vcounter = r_frame_out_box2_y1 or tc_vcounter = r_frame_out_box2_y2) and
           tc_hcounter >= r_frame_out_box2_x1 and tc_hcounter <= r_frame_out_box2_x2))then
          r_dvi_out_data <= r_color_box2;
        end if;
        if(((tc_hcounter = r_frame_out_box3_x1 or tc_hcounter = r_frame_out_box3_x2) and 
           tc_vcounter >= r_frame_out_box3_y1 and tc_vcounter <= r_frame_out_box3_y2) or
           ((tc_vcounter = r_frame_out_box3_y1 or tc_vcounter = r_frame_out_box3_y2) and
           tc_hcounter >= r_frame_out_box3_x1 and tc_hcounter <= r_frame_out_box3_x2))then
          r_dvi_out_data <= r_color_box3;
        end if;
        if(((tc_hcounter = r_frame_out_box4_x1 or tc_hcounter = r_frame_out_box4_x2) and 
           tc_vcounter >= r_frame_out_box4_y1 and tc_vcounter <= r_frame_out_box4_y2) or
           ((tc_vcounter = r_frame_out_box4_y1 or tc_vcounter = r_frame_out_box4_y2) and
           tc_hcounter >= r_frame_out_box4_x1 and tc_hcounter <= r_frame_out_box4_x2))then
          r_dvi_out_data <= r_color_box4;
        end if;
      end if;
                          
      r_dvi_out_de <= r_dvi_in_de;
      r_dvi_out_hsync <= r_dvi_in_hsync;
      r_dvi_out_vsync <= r_dvi_in_vsync;

      hoffset_counter <= hoffset_counter;
      voffset_counter <= voffset_counter;
      tc_hcounter <= tc_hcounter;
      tc_vcounter <= tc_vcounter;
      r_dvi_in_hsync_ref <= r_dvi_in_hsync_ref;
      r_dvi_in_vsync_ref <= r_dvi_in_vsync_ref;

      if(r_dvi_out_de = '1')then
        r_dvi_in_hsync_ref <= not r_dvi_in_hsync;
        r_dvi_in_vsync_ref <= not r_dvi_in_vsync;

        r_active_frame <= '1';

        if(hoffset_counter = r_frame_in_hoffset)then
          tc_hcounter <= tc_hcounter + to_unsigned(1, tc_hcounter'length);
        else
          hoffset_counter <= hoffset_counter +1;
        end if;
        
      end if;

      if(w_dvi_in_hsync = '1') then
        if(r_active_frame = '1')then
          if(voffset_counter = r_frame_in_voffset)then
            tc_vcounter <= tc_vcounter + to_unsigned(1, tc_vcounter'length);
          else
            voffset_counter <= voffset_counter +1;
          end if;
        end if;

        hoffset_counter <= to_unsigned(0, tc_hcounter'length);
        tc_hcounter <= to_unsigned(0, tc_hcounter'length);
      end if;

      if(w_dvi_in_vsync = '1') then
        voffset_counter <= to_unsigned(0, tc_hcounter'length);
        tc_vcounter <= to_unsigned(0, tc_vcounter'length);

        r_frame_out_box1_x1 <= r_frame_box1_x1;
        r_frame_out_box1_y1 <= r_frame_box1_y1;
        r_frame_out_box1_x2 <= r_frame_box1_x2;
        r_frame_out_box1_y2 <= r_frame_box1_y2;
        r_frame_out_box2_x1 <= r_frame_box2_x1;
        r_frame_out_box2_y1 <= r_frame_box2_y1;
        r_frame_out_box2_x2 <= r_frame_box2_x2;
        r_frame_out_box2_y2 <= r_frame_box2_y2;
        r_frame_out_box3_x1 <= r_frame_box3_x1;
        r_frame_out_box3_y1 <= r_frame_box3_y1;
        r_frame_out_box3_x2 <= r_frame_box3_x2;
        r_frame_out_box3_y2 <= r_frame_box3_y2;
        r_frame_out_box4_x1 <= r_frame_box4_x1;
        r_frame_out_box4_y1 <= r_frame_box4_y1;
        r_frame_out_box4_x2 <= r_frame_box4_x2;
        r_frame_out_box4_y2 <= r_frame_box4_y2;

        r_active_frame <= '0';

      end if;

    end if;

  end process;

  w_dvi_in_hsync <= (r_dvi_in_hsync_ref and (not r_dvi_in_hsync) and r_dvi_out_hsync) or ((not r_dvi_in_hsync_ref) and r_dvi_in_hsync and not r_dvi_out_hsync);
  w_dvi_in_vsync <= (r_dvi_in_vsync_ref and (not r_dvi_in_vsync) and r_dvi_out_vsync) or ((not r_dvi_in_vsync_ref) and r_dvi_in_vsync and not r_dvi_out_vsync);

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

  dvi_out_data         <= r_dvi_out_data; 
  dvi_out_de           <= r_dvi_out_de; 
  dvi_out_hsync        <= r_dvi_out_hsync; 
  dvi_out_idclk_p      <= dvi_in_clk; 
  dvi_out_vsync        <= r_dvi_out_vsync; 

end architecture rtl;

  
