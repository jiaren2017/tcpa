-- =============================================================================
--!  @project      frame buffer tcpa
-- =============================================================================
--!  @file         dvi_input_interface.vhd
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

entity dvi_input_interface is
  generic (
    STD_FRAME_OUT_WIDTH      : positive range   1 to 2046 := 640;
    STD_FRAME_OUT_HEIGHT     : positive range   1 to 1022 := 480;
    STD_SKIP_PX              : integer  range   0 to   15 :=   0;
    STD_SKIP_ROW             : integer  range   0 to   15 :=   0;
    STD_FRAME_IN_PERMUTATION : integer  range   0 to   63 :=   0;
    STD_SIGNAL_ROW           : positive range   1 to 1022 :=   1;
    STD_DVI_IN_EN            : integer  range   0 to    1 :=   1;
    STD_DVI_IN_DFO           : integer  range   0 to    1 :=   0;
    STD_DVI_IN_NPD           : integer  range   0 to    1 :=   1;
    STD_DVI_IN_NPDO          : integer  range   0 to    1 :=   1;
    STD_DVI_IN_NSTAG         : integer  range   0 to    1 :=   1;
    STD_DVI_IN_OCK_INV       : integer  range   0 to    1 :=   0;
    STD_DVI_IN_PIX           : integer  range   0 to    1 :=   0;
    STD_DVI_IN_ST            : integer  range   0 to    1 :=   1;
    ADDR_W                   : positive                   :=  22
  );
  port (
    cfg_clk : std_ulogic;
    reset : std_ulogic;

    -- pins which are connected to motherboard connector td1 
    -- and connector ba1 on x-board eb-pds-dvi-r1 
    dvi_in_ctl           : in    std_ulogic_vector(1 downto 0);
    dvi_in_data_e        : in    std_ulogic_vector(23 downto 0);
    dvi_in_data_o        : in    std_ulogic_vector(23 downto 0);
    dvi_in_de            : in    std_ulogic;                      -- td1_io_089_p_44
    dvi_in_dfo           : out   std_ulogic;                      -- td1_io_094_n_47
--  dvi_in_edid_scl      : inout std_ulogic;                      -- td1_io_100_n_50
--  dvi_in_edid_sda      : inout std_ulogic;                      -- td1_io_101_p_50
    dvi_in_hsync         : in    std_ulogic;                      -- td1_io_087_p_43
    dvi_in_npd           : out   std_ulogic;                      -- td1_io_095_p_47
    dvi_in_npdo          : out   std_ulogic;                      -- td1_io_096_n_48
    dvi_in_nstag         : out   std_ulogic;                      -- td1_io_098_n_49
    dvi_in_ock_inv       : out   std_ulogic;                      -- td1_io_090_n_45
    dvi_in_odck          : in    std_ulogic;                      -- td1_clkio_p_0_mrcc
    dvi_in_pix           : out   std_ulogic;                      -- td1_io_099_p_49
    dvi_in_scdt          : in    std_ulogic;                      -- td1_io_091_p_45
    dvi_in_st            : out   std_ulogic;                      -- td1_io_097_p_48
    dvi_in_vsync         : in    std_ulogic;                      -- td1_io_088_n_44

    px_addr  : out std_ulogic_vector(ADDR_W-1 downto 0);
    px_data  : out std_ulogic_vector(23 downto 0);
    px_valid : out std_ulogic;

    dvi_in_cfg_addr  : in  std_ulogic_vector(3 downto 0);
    dvi_in_cfg_wdata : in  std_ulogic_vector(10 downto 0);
    dvi_in_cfg_rdata : out std_ulogic_vector(10 downto 0);
    dvi_in_cfg_we    : in  std_ulogic;
    dvi_in_cfg_en    : in  std_ulogic;

    frame_width  : out unsigned(10 downto 0);
    frame_height : out unsigned(10 downto 0);
    frame_ctl : out std_ulogic_vector(1 downto 0)
  );
end entity dvi_input_interface;






architecture rtl of dvi_input_interface is
  type dvi_in_states is (idle, get_sync, wait_for_frame_ctl, wait_for_en, wait_for_next_line, get_in_frame_width, wait_for_sync, wait_for_pixels, get_in_frame_pixels);

  -- outputs of the clock domains
  signal dvi_in_start   : std_ulogic;

  signal c_frame_in_crop_hoffset   : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_IN_CROP_HOFFSET+1))))-1 downto 0);
  signal c_frame_in_crop_voffset   : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_IN_CROP_VOFFSET+1))))-1 downto 0);
  signal c_frame_in_crop_hactive   : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_IN_CROP_HACTIVE+1))))-1 downto 0);
  signal c_frame_in_crop_vactive   : unsigned(10 downto 0); -- unsigned(integer(ceil(log2(real(FRAME_IN_CROP_VACTIVE+1))))-1 downto 0);

  signal r_dvi_in_active_hsync     : std_ulogic;
  signal r_dvi_in_active_vsync     : std_ulogic;

  signal r_frame_in_crop_hoffset   : unsigned(c_frame_in_crop_hoffset'range);
  signal r_frame_in_crop_voffset   : unsigned(c_frame_in_crop_voffset'range);
  signal r_frame_in_crop_hactive   : unsigned(c_frame_in_crop_hactive'range);
  signal r_frame_in_crop_vactive   : unsigned(c_frame_in_crop_vactive'range);

  signal r_dvi_out_frame_vsync, r_dvi_out_frame_vsync_1 : std_ulogic;

  signal r_dvi_in_frame_state : dvi_in_states;
  signal r_dvi_in_frame_width : unsigned(10 downto 0);
  signal r_dvi_in_frame_height : unsigned(10 downto 0);
  signal r_dvi_in_frame_hsync : unsigned(10 downto 0);
  signal r_dvi_in_frame_hfront : unsigned(10 downto 0);
  signal r_dvi_in_frame_hback : unsigned(10 downto 0);
  signal r_dvi_in_frame_to_hsync : unsigned(10 downto 0);
  signal r_dvi_in_frame_to_hback : unsigned(10 downto 0);
  signal r_dvi_in_frame_hfull : unsigned(10 downto 0);
  signal r_dvi_in_frame_vsync : unsigned(10 downto 0);
  signal r_dvi_in_frame_vfront : unsigned(10 downto 0);
  signal r_dvi_in_frame_vback : unsigned(10 downto 0);
  signal r_dvi_in_frame_to_vsync : unsigned(10 downto 0);
  signal r_dvi_in_frame_to_vback : unsigned(10 downto 0);
  signal r_dvi_in_frame_vfull : unsigned(10 downto 0);
  signal r_dvi_in_frame_width_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_height_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_hsync_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_hfront_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_hback_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_to_hsync_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_to_hback_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_hfull_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_vsync_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_vfront_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_vback_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_to_vsync_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_to_vback_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_vfull_stable : unsigned(10 downto 0);
  signal r_dvi_in_frame_hcounter : unsigned(10 downto 0);
  signal r_dvi_in_frame_vcounter : unsigned(10 downto 0);

  signal r_error_infifo  : std_ulogic;
  signal r_error_outfifo : std_ulogic;
  signal r_led : std_ulogic_vector(7 downto 0);

  signal infifo_dvi_in_reset_n : std_ulogic;
  signal infifo_sram_reset_n : std_ulogic;
  signal r_first_frame_done : std_ulogic;

  signal r_px_addr  : unsigned(ADDR_W-1 downto 0);
  signal r_px_data  : std_ulogic_vector(23 downto 0);
  signal r_px_valid : std_ulogic;

  signal r_frame_out_width      : unsigned(10 downto 0);
  signal r_frame_out_height     : unsigned(10 downto 0);
  signal r_skip_px              : unsigned( 3 downto 0);
  signal r_skip_row             : unsigned( 3 downto 0);
  signal r_dvi_in_en            : std_ulogic;
  signal r_dvi_in_xboard_config : std_ulogic_vector(6 downto 0);

  signal r_dvi_in_cfg_rdata : std_ulogic_vector(10 downto 0);
  signal r_skip_counter_x       : unsigned(r_skip_px'range);
  signal r_skip_counter_y       : unsigned(r_skip_row'range);

  signal r_frame_in_permutation : std_ulogic_vector(5 downto 0);
  signal r_signal_row : unsigned(r_dvi_in_frame_hfull'range);

  signal r_frame_ctl : std_ulogic_vector(1 downto 0);

  signal r_dvi_in_ctl    : std_ulogic_vector(1 downto 0);
  signal r_dvi_in_data_e : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_data_o : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_de     : std_ulogic;
  signal r_dvi_in_hsync  : std_ulogic;
  signal r_dvi_in_scdt   : std_ulogic;
  signal r_dvi_in_vsync  : std_ulogic;


  component ssram_ctrl_top -- ProDesign ProFPGA SSRAM Controller
      generic(
          PERFORMANCE_MODE : string := "LOW_LATENCY";          -- "LOW_LATENCY" or "SPEED"
          FPGA_TECH        : string := "XV7S";                 -- "XV7S", "XVUS"
          CLK_PERIOD_PS    : positive := 3000;                 -- (fastest) period of memory clock
          STARTUP_TIME_US  : positive := 20;                   -- time to PLL lock
          USE_IDELAY_CTRL  : string := "TRUE";                 -- "TRUE" if IDELAY_CTRL should be instantiated, "FALSE" otherwise
          ADDR_W           : positive := 22;                   -- width of the address bus
          DQ_PINS          : positive := 18;                   -- number of DQ pins
          GROUPS           : positive := 2                     -- number of byte write enable pins
      );
      port(
          -- clock and reset signals
          clk             : in    std_logic;                               -- clock for memory and internal interface
          reset           : in    std_logic;                               -- reset synchronous to clk
          clk200          : in    std_logic;                               -- 200MHz clock required if USE_IDELAY_CTRL="TRUE"
          clk200_reset    : in    std_logic;                               -- reset synchronous to clk200
          -- management interface
          ready           : out   std_logic;                               -- becomes high if initialization and read leveling is done
          read_latency    : out   std_logic_vector (3 downto 0);           -- read latency value (valid of ready is high)
          read2write_nops : out   std_logic_vector (3 downto 0);           -- number of NOP cycles between transition from read to write operation
          windows_size    : out   std_logic_vector (15 downto 0);          -- read data windows size determined during read leveling (in TAPs)
          windows_start   : out   std_logic_vector (15 downto 0);          -- read data window start TAP
          -- internal memory interface
          addr            : in    std_logic_vector (ADDR_W-2 downto 0);    -- memory address
          en              : in    std_logic;                               -- enable
          we              : in    std_logic;                               -- write enable
          bwe             : in    std_logic_vector (2*GROUPS-1 downto 0);  -- byte write enable
          wdata           : in    std_logic_vector (2*DQ_PINS-1 downto 0); -- write data
          rdata           : out   std_logic_vector (2*DQ_PINS-1 downto 0); -- read data
          rvalid          : out   std_logic;                               -- read data valid
          -- external memory interface
          sram_k_p        : out   std_logic;                               -- SSRAM clock
          sram_k_n        : out   std_logic;                               -- SSRAM clock (negated)
          sram_a          : out   std_logic_vector (ADDR_W-1 downto 0);    -- SSRAM address
          sram_dq         : inout std_logic_vector (DQ_PINS-1 downto 0);   -- SSRAM data
          sram_bws_n      : out   std_logic_vector (GROUPS-1 downto 0);    -- SSRAM byte write strobe
          sram_rnw        : out   std_logic;                               -- SSRAM read/nwrite enable
          sram_ld_n       : out   std_logic                                -- SSRAM address load
      );
  end component;
begin
  dvi_in_cfg_rdata <= r_dvi_in_cfg_rdata;
  px_valid <= r_px_valid;
  frame_ctl <= r_frame_ctl;
  px_addr <= std_ulogic_vector(r_px_addr);

  px_data( 7 downto  0) <= r_px_data(15 downto  8) when r_frame_in_permutation(1 downto 0) = "10" else
                                       r_px_data(23 downto 16) when r_frame_in_permutation(1 downto 0) = "11" else
                                       r_px_data( 7 downto  0);
  px_data(15 downto  8) <= r_px_data( 7 downto  0) when r_frame_in_permutation(3 downto 2) = "01" else
                                       r_px_data(23 downto 16) when r_frame_in_permutation(3 downto 2) = "11" else
                                       r_px_data(15 downto  8);
  px_data(23 downto 16) <= r_px_data( 7 downto  0) when r_frame_in_permutation(5 downto 4) = "01" else
                                       r_px_data(15 downto  8) when r_frame_in_permutation(5 downto 4) = "10" else
                                       r_px_data(23 downto 16);

  -------------------------------------------------------------------------------------------------
  -- Configuration of timing controller -----------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  config : process(cfg_clk, reset)
  begin
    if(reset = '1')then
      r_frame_out_width    <= to_unsigned(integer(STD_FRAME_OUT_WIDTH), r_frame_out_width'length);
      r_frame_out_height   <= to_unsigned(integer(STD_FRAME_OUT_HEIGHT), r_frame_out_height'length);
      r_skip_px    <= to_unsigned(integer(STD_SKIP_PX), r_skip_px'length);
      r_skip_row   <= to_unsigned(integer(STD_SKIP_ROW), r_skip_row'length);
      r_frame_in_permutation <= std_ulogic_vector(to_unsigned(STD_FRAME_IN_PERMUTATION, r_frame_in_permutation'length));
      r_signal_row <= to_unsigned(integer(STD_SIGNAL_ROW), r_signal_row'length);

      if(STD_DVI_IN_EN = 0)then
        r_dvi_in_en     <= '0';
      else
        r_dvi_in_en     <= '1';
      end if;

      if(STD_DVI_IN_DFO = 0)then
        r_dvi_in_xboard_config(6) <= '0';
      else
        r_dvi_in_xboard_config(6) <= '1';
      end if;

      if(STD_DVI_IN_NPD = 0)then
        r_dvi_in_xboard_config(5) <= '0';
      else
        r_dvi_in_xboard_config(5) <= '1';
      end if;

      if(STD_DVI_IN_NPDO = 0)then
        r_dvi_in_xboard_config(4) <= '0';
      else
        r_dvi_in_xboard_config(4) <= '1';
      end if;

      if(STD_DVI_IN_NSTAG = 0)then
        r_dvi_in_xboard_config(3) <= '0';
      else
        r_dvi_in_xboard_config(3) <= '1';
      end if;

      if(STD_DVI_IN_OCK_INV = 0)then
        r_dvi_in_xboard_config(2) <= '0';
      else
        r_dvi_in_xboard_config(2) <= '1';
      end if;

      if(STD_DVI_IN_PIX = 0)then
        r_dvi_in_xboard_config(1) <= '0';
      else
        r_dvi_in_xboard_config(1) <= '1';
      end if;

      if(STD_DVI_IN_ST = 0)then
        r_dvi_in_xboard_config(0) <= '0';
      else
        r_dvi_in_xboard_config(0) <= '1';
      end if;

    elsif(rising_edge(cfg_clk))then
      r_frame_out_width    <= r_frame_out_width;
      r_frame_out_height   <= r_frame_out_height;
      r_dvi_in_en     <= r_dvi_in_en;

      if((dvi_in_cfg_en and dvi_in_cfg_we) = '1')then
        r_dvi_in_en <= '0';
        case(dvi_in_cfg_addr)is
          when "0000" => r_dvi_in_en     <= dvi_in_cfg_wdata(0);
          when "0001" => r_frame_out_width  <= unsigned(dvi_in_cfg_wdata(r_frame_out_width'range));
          when "0010" => r_frame_out_height <= unsigned(dvi_in_cfg_wdata(r_frame_out_height'range));
          when "0011" => r_skip_px  <= unsigned(dvi_in_cfg_wdata(r_skip_px'range));
          when "0100" => r_skip_row <= unsigned(dvi_in_cfg_wdata(r_skip_row'range));
          when "0101" => r_frame_in_permutation  <= dvi_in_cfg_wdata(r_frame_in_permutation'range);
          when "0110" => r_signal_row  <= unsigned(dvi_in_cfg_wdata(r_signal_row'range));
          when "0111" => r_dvi_in_xboard_config <= dvi_in_cfg_wdata(r_dvi_in_xboard_config'range);
          when others => r_dvi_in_en     <= r_dvi_in_en;
        end case;
      else
        r_dvi_in_cfg_rdata <= (others => '0');
        case(dvi_in_cfg_addr)is
          when "0000" => r_dvi_in_cfg_rdata(0) <= r_dvi_in_en; 
                         r_dvi_in_cfg_rdata(4) <= r_dvi_in_scdt; 
                         r_dvi_in_cfg_rdata(8) <= dvi_in_start; 
          when "0001" => r_dvi_in_cfg_rdata(r_dvi_in_frame_width_stable'range) <= std_ulogic_vector(r_dvi_in_frame_width_stable);
          when "0010" => r_dvi_in_cfg_rdata(r_dvi_in_frame_hfull_stable'range) <= std_ulogic_vector(r_dvi_in_frame_hfull_stable);
          when "0011" => r_dvi_in_cfg_rdata(r_dvi_in_frame_height_stable'range) <= std_ulogic_vector(r_dvi_in_frame_height_stable);
          when "0100" => r_dvi_in_cfg_rdata(r_frame_out_width'range) <= std_ulogic_vector(r_frame_out_width);
          when "0101" => r_dvi_in_cfg_rdata(r_frame_out_height'range) <= std_ulogic_vector(r_frame_out_height);
          when "0110" => r_dvi_in_cfg_rdata(r_skip_px'range) <= std_ulogic_vector(r_skip_px);
          when "0111" => r_dvi_in_cfg_rdata(r_skip_row'range) <= std_ulogic_vector(r_skip_row);
          when "1000" => r_dvi_in_cfg_rdata(r_frame_in_permutation'range) <= std_ulogic_vector(r_frame_in_permutation);
          when "1001" => r_dvi_in_cfg_rdata(r_signal_row'range) <= std_ulogic_vector(r_signal_row);
          when "1010" => r_dvi_in_cfg_rdata(r_dvi_in_xboard_config'range) <= r_dvi_in_xboard_config;
          when others => null;
        end case;
      end if;
    end if;
  end process;


  -------------------------------------------------------------------------------------------------
  -- frame calculations without clock -------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  frame_calculations : process(r_dvi_in_frame_width_stable, r_dvi_in_frame_height_stable)
  begin
      if(r_dvi_in_frame_width_stable > r_frame_out_width)then
        c_frame_in_crop_hoffset <= (r_dvi_in_frame_width_stable - r_frame_out_width) srl 1;
        frame_width <= r_frame_out_width;
      else
        c_frame_in_crop_hoffset <= (others => '0');
        frame_width <= r_dvi_in_frame_width_stable;
      end if;
  end process;

  frame_calculations_1 : process(r_dvi_in_frame_width_stable, r_dvi_in_frame_height_stable)
  begin
      if(r_dvi_in_frame_height_stable > r_frame_out_height)then
        c_frame_in_crop_voffset <= (r_dvi_in_frame_height_stable - r_frame_out_height) srl 1;
        frame_height <= r_frame_out_height;
      else
        c_frame_in_crop_voffset <= (others => '0');
        frame_height <= r_dvi_in_frame_height_stable;
      end if;
  end process;

  c_frame_in_crop_hactive   <= r_dvi_in_frame_width_stable  - c_frame_in_crop_hoffset;
  c_frame_in_crop_vactive   <= r_dvi_in_frame_height_stable - c_frame_in_crop_voffset;

  -------------------------------------------------------------------------------------------------
  -- enabling frame buffer (wait until start of next frame) ---------------------------------------
  -- write input frame to fifo --------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  frame_input : process (dvi_in_odck, r_dvi_in_en, r_dvi_in_scdt)
  begin
    if ( ( reset or (not r_dvi_in_en) or not r_dvi_in_scdt) = '1') then
      dvi_in_start <= '0';
      r_frame_ctl <= (others => '0');
      r_dvi_in_frame_width <= (others => '0');
      r_dvi_in_frame_height <= (others => '0');
      r_dvi_in_frame_hfull <= (others => '0');
      r_dvi_in_frame_width_stable <= (others => '0');
      r_dvi_in_frame_height_stable <= (others => '0');
      r_dvi_in_frame_hfull_stable <= (others => '0');
      r_dvi_in_frame_hcounter <= (others => '0');
      r_dvi_in_frame_vcounter <= (others => '0');

      r_dvi_in_active_hsync <= '0';
      r_dvi_in_active_vsync <= '0';
      r_frame_in_crop_hoffset   <= (others => '0');
      r_frame_in_crop_voffset   <= (others => '0');
      r_frame_in_crop_hactive   <= (others => '0');
      r_frame_in_crop_vactive   <= (others => '0');

      r_error_infifo <= '0';
      r_px_addr <= (others => '1');
      r_px_valid <= '0';
      r_px_data <= (others => '0');

      r_skip_counter_x <= (others => '0');
      r_skip_counter_y <= (others => '0');

      r_dvi_in_frame_state <= idle;

    elsif (rising_edge(dvi_in_odck)) then
      -- wait for end of frame before filling the fifos
      dvi_in_start <= dvi_in_start;
      r_frame_ctl <= (others => '0');
      
      r_dvi_in_frame_state <= r_dvi_in_frame_state;
      r_dvi_in_frame_width <= r_dvi_in_frame_width;
      r_dvi_in_frame_hfull <= r_dvi_in_frame_hfull;
      r_dvi_in_frame_hcounter <= r_dvi_in_frame_hcounter;
      r_dvi_in_frame_vcounter <= r_dvi_in_frame_vcounter;

      r_dvi_in_frame_width_stable <= r_dvi_in_frame_width_stable;
      r_dvi_in_frame_height_stable <= r_dvi_in_frame_height_stable;
      r_dvi_in_frame_hfull_stable <= r_dvi_in_frame_hfull_stable;

      r_dvi_in_active_hsync <= r_dvi_in_active_hsync;
      r_dvi_in_active_vsync <= r_dvi_in_active_vsync;
      r_frame_in_crop_hoffset   <= c_frame_in_crop_hoffset;
      r_frame_in_crop_voffset   <= c_frame_in_crop_voffset;
      r_frame_in_crop_hactive   <= c_frame_in_crop_hactive;
      r_frame_in_crop_vactive   <= c_frame_in_crop_vactive;

      r_error_infifo <= r_error_infifo;
      r_px_valid <= '0';
      r_px_addr <= r_px_addr;
      r_px_data <= r_dvi_in_data_e;

      r_skip_counter_x <= r_skip_counter_x;
      r_skip_counter_y <= r_skip_counter_y;


      case(r_dvi_in_frame_state)is
        when idle =>
          r_dvi_in_frame_hcounter <= (others => '0');
          r_dvi_in_frame_vcounter <= (others => '0');
          r_dvi_in_frame_width <= (others => '0');
          r_dvi_in_frame_height <= (others => '0');
          r_dvi_in_frame_hsync <= (others => '0');
          r_dvi_in_frame_hfront <= (others => '0');
          r_dvi_in_frame_hback <= (others => '0');
          r_dvi_in_frame_to_hsync <= (others => '0');
          r_dvi_in_frame_to_hback <= (others => '0');
          r_dvi_in_frame_hfull <= (others => '0');
          r_dvi_in_frame_vsync <= (others => '0');
          r_dvi_in_frame_vfront <= (others => '0');
          r_dvi_in_frame_vback <= (others => '0');
          r_dvi_in_frame_to_vsync <= (others => '0');
          r_dvi_in_frame_to_vback <= (others => '0');
          r_dvi_in_frame_vfull <= (others => '0');
          dvi_in_start <= '0';

          r_dvi_in_frame_state <= get_sync;

        when get_sync =>
          if(r_dvi_in_de = '1')then
            r_dvi_in_active_hsync <= not r_dvi_in_hsync;
            r_dvi_in_active_vsync <= not r_dvi_in_vsync;
            r_dvi_in_frame_state <= wait_for_frame_ctl;
          end if;

        when wait_for_frame_ctl =>
          if(r_dvi_in_vsync = r_dvi_in_active_vsync)then
            r_dvi_in_frame_state <= wait_for_en;
          end if;

        when wait_for_en =>
          if(r_dvi_in_de = '1')then
            r_dvi_in_frame_width <= r_dvi_in_frame_width + 1;
            r_dvi_in_frame_state <= get_in_frame_width;
          end if;

        when get_in_frame_width =>
          r_dvi_in_frame_hfull <= r_dvi_in_frame_hfull + 1;
          if(r_dvi_in_de = '1')then
            r_dvi_in_frame_width <= r_dvi_in_frame_width + 1;
          elsif(r_dvi_in_frame_width_stable = r_dvi_in_frame_width)then
            r_dvi_in_frame_width <= (others => '0');
            r_dvi_in_frame_height <= r_dvi_in_frame_height + 1;
            r_dvi_in_frame_vcounter <= r_dvi_in_frame_vcounter + 1;
            r_dvi_in_frame_state <= wait_for_next_line;

          else
            r_dvi_in_frame_width_stable <= r_dvi_in_frame_width;
            r_dvi_in_frame_state <= idle;
          end if;

        when wait_for_next_line =>
          r_dvi_in_frame_hfull <= r_dvi_in_frame_hfull + 1;

          if(r_dvi_in_de = '1')then
            r_dvi_in_frame_width <= r_dvi_in_frame_width + 1;
            r_dvi_in_frame_hfull <= r_dvi_in_frame_width + 1;
            r_dvi_in_frame_hfull_stable <= r_dvi_in_frame_hfull;
            r_dvi_in_frame_state <= get_in_frame_width;
          end if;

          if(r_dvi_in_vsync = r_dvi_in_active_vsync)then
            if(r_dvi_in_frame_height_stable = r_dvi_in_frame_height)then
              r_dvi_in_frame_state <= wait_for_sync;
            else
              r_dvi_in_frame_height_stable <= r_dvi_in_frame_height;
              r_dvi_in_frame_state <= idle;
            end if;
          end if;
       
        when wait_for_sync =>
          r_dvi_in_frame_hcounter <= (others => '0');
          r_dvi_in_frame_vcounter <= (others => '0');
          if(r_dvi_in_vsync = r_dvi_in_active_vsync)then
            r_dvi_in_frame_state <= wait_for_pixels;
          end if;
       
        when wait_for_pixels =>
          if(r_dvi_in_de = '1')then
            if((r_dvi_in_frame_hcounter >= r_frame_in_crop_hoffset and r_dvi_in_frame_hcounter < r_frame_in_crop_hactive) and
               (r_dvi_in_frame_vcounter >= r_frame_in_crop_voffset and r_dvi_in_frame_vcounter < r_frame_in_crop_vactive) and
               (r_skip_counter_x = r_skip_px and r_skip_counter_y = r_skip_row))then
              r_px_valid <= '1';
              r_px_addr <= r_px_addr +1;
            end if;

            if(r_skip_counter_x = r_skip_px)then
              r_skip_counter_x <= (others => '0');
            else
              r_skip_counter_x <= r_skip_counter_x +1;
            end if;
            
            dvi_in_start <= '1';

            r_dvi_in_frame_hcounter <= r_dvi_in_frame_hcounter + to_unsigned(1, r_dvi_in_frame_hcounter'length);
            r_dvi_in_frame_state <= get_in_frame_pixels;
          end if;

          if(r_dvi_in_vsync = r_dvi_in_active_vsync)then
            r_dvi_in_frame_vcounter <= (others => '0');
            r_px_addr <= (others => '1');
          end if;

        when get_in_frame_pixels =>
          if(r_dvi_in_de = '1')then
            if((r_dvi_in_frame_hcounter >= r_frame_in_crop_hoffset and r_dvi_in_frame_hcounter < r_frame_in_crop_hactive) and
               (r_dvi_in_frame_vcounter >= r_frame_in_crop_voffset and r_dvi_in_frame_vcounter < r_frame_in_crop_vactive) and
               (r_skip_counter_x = r_skip_px and r_skip_counter_y = r_skip_row))then
              r_px_valid <= '1';
              r_px_addr <= r_px_addr +1;
            end if;

            if(r_skip_counter_x = r_skip_px)then
              r_skip_counter_x <= (others => '0');
            else
              r_skip_counter_x <= r_skip_counter_x +1;
            end if;

            r_dvi_in_frame_hcounter <= r_dvi_in_frame_hcounter + to_unsigned(1, r_dvi_in_frame_hcounter'length);
          else
            r_dvi_in_frame_hcounter <= (others => '0');
            r_dvi_in_frame_vcounter <= r_dvi_in_frame_vcounter + 1;

            r_skip_counter_x <= (others => '0');
            
            if(r_skip_counter_y = r_skip_row)then
              r_skip_counter_y <= (others => '0');
            else
              r_skip_counter_y <= r_skip_counter_y +1;
            end if;
            
            r_dvi_in_frame_state <= wait_for_pixels;
          end if;
          

        when others => r_dvi_in_frame_state <= idle;
      end case;

      if(dvi_in_start = '1')then
        if(r_dvi_in_vsync = r_dvi_in_active_vsync)then
          r_frame_ctl(0) <= '1';
        end if;

        if(r_dvi_in_frame_vcounter > r_signal_row)then
          r_frame_ctl(1) <= '1';
        end if;
      end if;


    end if;
  end process;



  dvi_reg_input : process(dvi_in_odck, dvi_in_scdt)
  begin
    if(dvi_in_scdt = '0')then
      r_dvi_in_ctl    <= (others => '0');
      r_dvi_in_data_e <= (others => '0');
      r_dvi_in_data_o <= (others => '0');
      r_dvi_in_de     <= '0';
      r_dvi_in_hsync  <= '0';
      r_dvi_in_scdt   <= '0';
      r_dvi_in_vsync  <= '0';
    elsif(rising_edge(dvi_in_odck))then
      r_dvi_in_ctl    <= dvi_in_ctl;
      r_dvi_in_data_e <= dvi_in_data_e;
      r_dvi_in_data_o <= dvi_in_data_o;
      r_dvi_in_de     <= dvi_in_de;
      r_dvi_in_hsync  <= dvi_in_hsync;
      r_dvi_in_scdt   <= dvi_in_scdt;
      r_dvi_in_vsync  <= dvi_in_vsync;
    end if;

  end process;


  -------------------------------------------------------------------------------------------------
  -- static dvi configuration ---------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  dvi_in_dfo           <= r_dvi_in_xboard_config(6); -- '0';
  dvi_in_npd           <= r_dvi_in_xboard_config(5); -- '1';
  dvi_in_npdo          <= r_dvi_in_xboard_config(4); -- '1';
  dvi_in_nstag         <= r_dvi_in_xboard_config(3); -- '1';
  dvi_in_ock_inv       <= r_dvi_in_xboard_config(2); -- '0';
  dvi_in_pix           <= r_dvi_in_xboard_config(1); -- '0';
  dvi_in_st            <= r_dvi_in_xboard_config(0); -- '1';

end architecture rtl;

  
