-- =============================================================================
--!  @project      frame buffer tcpa
-- =============================================================================
--!  @file         frame_buffer.vhd
--!  @author       Marcel Brand
--!  @email        marcel.brand@fau.de
--!  @brief        profpga dvi frame buffer with sram
-- =============================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.log2;
    use ieee.math_real.ceil;
library grlib;
    use grlib.amba.all;
    use grlib.stdlib.all;
    use grlib.devices.all;
library unisim;
    use unisim.vcomponents.all;
library dvi_profpga_lib;
    use dvi_profpga_lib.dvi_profpga.all;

entity dvi2ahb_top is
  generic (
    hindex              : integer := 0;
    haddr               : integer := 16#400#;
    hirq                : integer := 0;
    pindex              : integer := 0;
    paddr               : integer := 0;
    pmask               : integer := 16#FFF#;

    ADDR_W             : positive                   :=   22;  -- width of the address bus
    DQ_PINS            : positive                   :=   18;  -- number of DQ pins
    GROUPS             : positive                   :=    2   -- number of byte write enable pins
  );
  port (
    
    -- clock/sync (driven by mainboard)
    -- Only using clocks 0 to 4 (i.e. not 5, 6, or 7)
    amba_clk    : in std_ulogic;
    sram_clk    : in std_ulogic;
    clk200      : in std_ulogic;
    
    reset       : in std_ulogic;

    ahbsi              : in  ahb_slv_in_type;
    ahbso              : out ahb_slv_out_type;
    apbi               : in  apb_slv_in_type;
    apbo               : out apb_slv_out_type;

    -- SSRAM interface
    sram_k_p    : out   std_logic;
    sram_k_n    : out   std_logic;
    sram_a      : out   std_logic_vector (ADDR_W-1 downto 0);
    sram_dq     : inout std_logic_vector (DQ_PINS-1 downto 0);
    sram_bws_n  : out   std_logic_vector (GROUPS-1 downto 0);
    sram_rnw    : out   std_logic;
    sram_ld_n   : out   std_logic;
    sram_doff_n : out   std_logic;


    -- pins which are connected to motherboard connector td1 
    -- and connector ba1 on x-board eb-pds-dvi-r1 
    dvi_in_ctl           : in    std_ulogic_vector(1 downto 0);
    dvi_in_data_e        : in    std_ulogic_vector(23 downto 0);
    dvi_in_data_o        : in    std_ulogic_vector(23 downto 0);
    dvi_in_de            : in    std_ulogic;                      -- td1_io_089_p_44
    dvi_in_dfo           : out   std_ulogic;                      -- td1_io_094_n_47
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

    dvi_out_a3_dk3       : out   std_ulogic;                      -- td1_io_034_n_17
    dvi_out_bsel_scl     : out   std_ulogic;                      -- td1_io_035_p_17
    dvi_out_ctl          : out   std_ulogic_vector(1 downto 0);
    dvi_out_data         : out   std_ulogic_vector(23 downto 0);
    dvi_out_de           : out   std_ulogic;                      -- td1_io_026_n_13
    dvi_out_dken         : out   std_ulogic;                      -- td1_io_028_n_14
    dvi_out_dsel_sda     : out   std_ulogic;                      -- td1_io_036_n_18
    dvi_out_edge         : out   std_ulogic;                      -- td1_io_027_p_13
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
end entity dvi2ahb_top;

architecture rtl of dvi2ahb_top is

  signal px_in_addr  : std_ulogic_vector(ADDR_W -1 downto 0);
  signal px_in_data  : std_ulogic_vector(23 downto 0);
  signal px_in_valid : std_ulogic;
  signal px_in_ready : std_ulogic;

  signal dvi_cfg_addr    : std_ulogic_vector(5 downto 0);
  signal r_dvi_cfg_addr  : std_ulogic_vector(1 downto 0);
  signal dvi_cfg_wdata   : std_ulogic_vector(23 downto 0);
  signal dvi_cfg_rdata   : std_ulogic_vector(23 downto 0);
  signal dvi_cfg_we      : std_ulogic;
  signal dvi_cfg_en      : std_ulogic;
  
  signal dvi_in_cfg_addr  : std_ulogic_vector(3 downto 0);
  signal dvi_in_cfg_wdata : std_ulogic_vector(10 downto 0);
  signal dvi_in_cfg_rdata : std_ulogic_vector(10 downto 0);
  signal dvi_in_cfg_we    : std_ulogic;
  signal dvi_in_cfg_en    : std_ulogic;
  
  signal dvi_out_cfg_addr  : std_ulogic_vector(3 downto 0);
  signal dvi_out_cfg_wdata : std_ulogic_vector(12 downto 0);
  signal dvi_out_cfg_rdata : std_ulogic_vector(12 downto 0);
  signal dvi_out_cfg_we    : std_ulogic;
  signal dvi_out_cfg_en    : std_ulogic;
  
  signal dvi_cb_cfg_addr  : std_ulogic_vector(3 downto 0);
  signal dvi_cb_cfg_wdata : std_ulogic_vector(23 downto 0);
  signal dvi_cb_cfg_rdata : std_ulogic_vector(23 downto 0);
  signal dvi_cb_cfg_we    : std_ulogic;
  signal dvi_cb_cfg_en    : std_ulogic;

  signal dvi_fb_cfg_addr  : std_ulogic_vector(3 downto 0);
  signal dvi_fb_cfg_wdata : std_ulogic_vector(10 downto 0);
  signal dvi_fb_cfg_rdata : std_ulogic_vector(10 downto 0);
  signal dvi_fb_cfg_we    : std_ulogic;
  signal dvi_fb_cfg_en    : std_ulogic;

  signal dvi_in_frame_width  : unsigned(10 downto 0);
  signal dvi_in_frame_height : unsigned(10 downto 0);
  signal dvi_in_frame_ctl    : std_ulogic_vector(1 downto 0);

  signal px_out_addr  : std_ulogic_vector(ADDR_W-1 downto 0);
  signal px_out_req   : std_ulogic;
  signal px_out_ready : std_ulogic;

  signal px_out_data  : std_ulogic_vector(ADDR_W +23 downto 0);
  signal px_out_valid : std_ulogic;
  signal px_out_rcvd  : std_ulogic;

  signal r_dvi_in_ctl    : std_ulogic_vector(1 downto 0);
  signal r_dvi_in_data_e : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_data_o : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_de     : std_ulogic;
  signal r_dvi_in_hsync  : std_ulogic;
  signal r_dvi_in_scdt   : std_ulogic;
  signal r_dvi_in_vsync  : std_ulogic;

  signal r_dvi_in_ctl_input    : std_ulogic_vector(1 downto 0);
  signal r_dvi_in_data_e_input : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_data_o_input : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_de_input     : std_ulogic;
  signal r_dvi_in_hsync_input  : std_ulogic;
  signal r_dvi_in_scdt_input   : std_ulogic;
  signal r_dvi_in_vsync_input  : std_ulogic;

  signal r_dvi_in_ctl_propagate    : std_ulogic_vector(1 downto 0);
  signal r_dvi_in_data_e_propagate : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_data_o_propagate : std_ulogic_vector(23 downto 0);
  signal r_dvi_in_de_propagate     : std_ulogic;
  signal r_dvi_in_hsync_propagate  : std_ulogic;
  signal r_dvi_in_scdt_propagate   : std_ulogic;
  signal r_dvi_in_vsync_propagate  : std_ulogic;

  signal r_px_in_addr  : std_ulogic_vector(ADDR_W-1 downto 0);
  signal r_px_in_data  : std_ulogic_vector(23 downto 0);
  signal r_px_in_valid : std_ulogic;

begin

  -------------------------------------------------------------------------------------------------
  -- enabling frame buffer (wait until start of next frame) ---------------------------------------
  -- write input frame to fifo --------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  px_in_addr(1 downto 0) <= "00";


  dvi_in : dvi_input_interface
  generic map(
    STD_FRAME_OUT_WIDTH    => 640,
    STD_FRAME_OUT_HEIGHT   => 480,
    STD_DVI_IN_EN          =>   1,
    STD_DVI_IN_DFO         =>   0,
    STD_DVI_IN_NPD         =>   1,
    STD_DVI_IN_NPDO        =>   1,
    STD_DVI_IN_NSTAG       =>   1,
    STD_DVI_IN_OCK_INV     =>   0,
    STD_DVI_IN_PIX         =>   0,
    STD_DVI_IN_ST          =>   1,
    ADDR_W                 =>  ADDR_W -2
  )
  port map(
    cfg_clk => amba_clk,
    reset   => reset,

    -- pins which are connected to motherboard connector td1 
    -- and connector ba1 on x-board eb-pds-dvi-r1 
    dvi_in_ctl           => r_dvi_in_ctl_input,
    dvi_in_data_e        => r_dvi_in_data_e_input,
    dvi_in_data_o        => r_dvi_in_data_o_input,
    dvi_in_de            => r_dvi_in_de_input,                      -- td1_io_089_p_44
    dvi_in_dfo           => dvi_in_dfo,                      -- td1_io_094_n_47
    dvi_in_hsync         => r_dvi_in_hsync_input,                      -- td1_io_087_p_43
    dvi_in_npd           => dvi_in_npd,                      -- td1_io_095_p_47
    dvi_in_npdo          => dvi_in_npdo,                      -- td1_io_096_n_48
    dvi_in_nstag         => dvi_in_nstag,                      -- td1_io_098_n_49
    dvi_in_ock_inv       => dvi_in_ock_inv,                      -- td1_io_090_n_45
    dvi_in_odck          => dvi_in_odck,                      -- td1_clkio_p_0_mrcc
    dvi_in_pix           => dvi_in_pix,                      -- td1_io_099_p_49
    dvi_in_scdt          => r_dvi_in_scdt_input,                      -- td1_io_091_p_45
    dvi_in_st            => dvi_in_st,                      -- td1_io_097_p_48
    dvi_in_vsync         => r_dvi_in_vsync_input,                      -- td1_io_088_n_44

    px_addr  => px_in_addr(ADDR_W-1 downto 2),
    px_data  => px_in_data,
    px_valid => px_in_valid,

    dvi_in_cfg_addr  => dvi_in_cfg_addr,
    dvi_in_cfg_wdata => dvi_in_cfg_wdata,
    dvi_in_cfg_rdata => dvi_in_cfg_rdata,
    dvi_in_cfg_we    => dvi_in_cfg_we,
    dvi_in_cfg_en    => dvi_in_cfg_en,

    frame_width  => dvi_in_frame_width,
    frame_height => dvi_in_frame_height,
    frame_ctl    => dvi_in_frame_ctl
  );

  color_converter : RGB2YUV
    port map ( 
      clk => dvi_in_odck,
      red   => px_in_data( 7 downto  0),
      green => px_in_data(15 downto  8),
      blue  => px_in_data(23 downto 16),
      y => r_px_in_data( 7 downto  0),
      u => r_px_in_data(15 downto  8),
      v => r_px_in_data(23 downto 16)
    );

  delay_input : process(dvi_in_odck)
  begin
    if(rising_edge(dvi_in_odck))then
      r_px_in_valid <= px_in_valid;
      r_px_in_addr <= px_in_addr;
    end if;
  end process;


  -------------------------------------------------------------------------------------------------
  -- frame buffer to ahb interface ----------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  dvi2ahb : dvi_ahb_interface
    generic map(
      hindex               => hindex, --  integer                    := 0;
      haddr                => haddr, --  integer                    := 16#400#;
      hirq                 => hirq,
      AHB_WAIT_CYCLES      => 1,
      ADDR_W               => ADDR_W  --  positive                   :=  22;
    )
    port map(
      amba_clk => amba_clk, --  std_ulogic;
      reset => reset, --  std_ulogic;
      
      ahbsi => ahbsi, --  ahb_slv_in_type;
      ahbso => ahbso, --  ahb_slv_out_type;
  
      px_in_addr  => open, --  out std_ulogic_vector(ADDR_W-1 downto 0)
      px_in_data  => open, --  out std_ulogic_vector(23 downto 0);
      px_in_valid => open, --  out std_ulogic;
      px_in_ready => '0', --  in  std_ulogic;
  
      px_out_request_addr  => px_out_addr, --  out std_ulogic_vector(ADDR_W-1 downto 0);
      px_out_request_en    => px_out_req, --  out std_ulogic;
      px_out_request_ready => px_out_ready, --  in  std_ulogic;
  
      px_out_data  => px_out_data, --  in  std_ulogic_vector(23 downto 0);
      px_out_valid => px_out_valid, --  in  std_ulogic;
      px_out_used  => px_out_rcvd, --  out std_ulogic;
  
      frame_in_ctl => dvi_in_frame_ctl
    );



  -------------------------------------------------------------------------------------------------
  -- read and write SM for SRAM - 250 MHz ---------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  frame_buffer_i : frame_buffer
    generic map(
      PX_FIFO_DATA_WIDTH =>   24, --  positive range   8 to   32 :=   24;
      PX_FIFO_ADDR_WIDTH =>    5, --  positive range   1 to   10 :=    5;
      ADDR_W             => ADDR_W, --  positive                   :=   22;  -- width of the address bus
      DQ_PINS            =>   18, --  positive                   :=   18;  -- number of DQ pins
      GROUPS             =>    2, --  positive                   :=    2   -- number of byte write enable pins
      SINGLE_COLOR_WRITE =>    0,
      SINGLE_COLOR_READ  =>    0
    )
    port map(
      
      -- clock/sync (driven by mainboard)
      -- Only using clocks 0 to 4 (i.e. not 5, 6, or 7)
      cfg_clk     => amba_clk, --  in std_ulogic;
      clk200      => clk200, --  in std_ulogic;
      sram_clk    => sram_clk, --  in std_ulogic;
      dvi_in_clk  => dvi_in_odck, --  in std_ulogic;
      dvi_out_clk => amba_clk, --  in std_ulogic;
      
      reset   => reset, --  in std_ulogic;
  
      px_in_data   => r_px_in_data, --  in  std_ulogic_vector(23 downto 0);
      px_in_addr   => r_px_in_addr, --  in  std_ulogic_vector(ADDR_W-2 downto 0);
      px_in_valid  => r_px_in_valid, --  in  std_ulogic;
      px_in_ready  => px_in_ready, --  out std_ulogic;
      frame_in_ctl => dvi_in_frame_ctl,
  
      px_out_req   => px_out_req, --  in  std_ulogic;
      px_out_addr  => px_out_addr, --  in  std_ulogic_vector(ADDR_W-2 downto 0);
      px_out_rcvd  => px_out_rcvd, --  in  std_ulogic;
      px_out_ready => px_out_ready, --  out std_ulogic;
      px_out_data  => px_out_data, --  out std_ulogic_vector(23 downto 0);
      px_out_valid => px_out_valid, --  out std_ulogic;
  
      dvi_fb_cfg_addr  => dvi_fb_cfg_addr,
      dvi_fb_cfg_wdata => dvi_fb_cfg_wdata,
      dvi_fb_cfg_rdata => dvi_fb_cfg_rdata,
      dvi_fb_cfg_we    => dvi_fb_cfg_we,
      dvi_fb_cfg_en    => dvi_fb_cfg_en,
  
      -- SSRAM interface
      sram_k_p    => sram_k_p, --  out   std_logic;
      sram_k_n    => sram_k_n, --  out   std_logic;
      sram_a      => sram_a, --  out   std_logic_vector (ADDR_W-1 downto 0);
      sram_dq     => sram_dq, --  inout std_logic_vector (DQ_PINS-1 downto 0);
      sram_bws_n  => sram_bws_n, --  out   std_logic_vector (GROUPS-1 downto 0);
      sram_rnw    => sram_rnw, --  out   std_logic;
      sram_ld_n   => sram_ld_n, --  out   std_logic;
      sram_doff_n => sram_doff_n  --  out   std_logic,
    );

  -----------------------------------------------------------------------
  --  Bounding Box  -----------------------------------------------------
  -----------------------------------------------------------------------

  color_box : dvi_output_color_box
    generic map (
      STD_FRAME_IN_HOFFSET  =>    0,
      STD_FRAME_IN_VOFFSET  =>    0,
      STD_FRAME_BOX1_X1     =>    0,
      STD_FRAME_BOX1_Y1     =>    0,
      STD_FRAME_BOX1_X2     =>    1,
      STD_FRAME_BOX1_Y2     =>    1,
      STD_FRAME_BOX2_X1     =>    2,
      STD_FRAME_BOX2_Y1     =>    0,
      STD_FRAME_BOX2_X2     =>    3,
      STD_FRAME_BOX2_Y2     =>    1,
      STD_FRAME_COLOR_BOX1  =>  255,     -- x"0000FF"
      STD_FRAME_COLOR_BOX2  => 16711680, -- x"FF0000"
      STD_DVI_OUT_EN        =>    1,
      STD_DVI_OUT_A3_DK3    =>    0, 
      STD_DVI_OUT_BSEL_SCL  =>    1, 
      STD_DVI_OUT_CTL       =>    0, 
      STD_DVI_OUT_DKEN      =>    0, 
      STD_DVI_OUT_DSEL_SDA  =>    0, 
      STD_DVI_OUT_EDGE      =>    1, 
      STD_DVI_OUT_IDCLK_N   =>    0, 
      STD_DVI_OUT_ISEL_NRST =>    0, 
      STD_DVI_OUT_MSEN_PO1  =>    0, 
      STD_DVI_OUT_NHPD      =>    1, 
      STD_DVI_OUT_NOC       =>    0, 
      STD_DVI_OUT_NPD       =>    1 
    )
    port map(
      dvi_in_clk  => dvi_in_odck,
      cfg_clk     => amba_clk,
      reset => reset,
  
      dvi_out_cfg_wdata => dvi_cb_cfg_wdata,
      dvi_out_cfg_rdata => dvi_cb_cfg_rdata,
      dvi_out_cfg_addr  => dvi_cb_cfg_addr,
      dvi_out_cfg_we    => dvi_cb_cfg_we,
      dvi_out_cfg_en    => dvi_cb_cfg_en,
  
      dvi_in_data         => r_dvi_in_data_e_propagate,
      dvi_in_de           => r_dvi_in_de_propagate,
      dvi_in_hsync        => r_dvi_in_hsync_propagate,
      dvi_in_vsync        => r_dvi_in_vsync_propagate,
      dvi_in_valid        => r_dvi_in_scdt_propagate,
  
      -- pins which are connected to motherboard connector td1 
      -- and connector ba1 on x-board eb-pds-dvi-r1 
      dvi_out_a3_dk3       => dvi_out_a3_dk3,
      dvi_out_bsel_scl     => dvi_out_bsel_scl,
      dvi_out_ctl          => dvi_out_ctl,
      dvi_out_data         => dvi_out_data,
      dvi_out_de           => dvi_out_de,
      dvi_out_dken         => dvi_out_dken,
      dvi_out_dsel_sda     => dvi_out_dsel_sda,
      dvi_out_edge         => dvi_out_edge,
      dvi_out_hsync        => dvi_out_hsync,
      dvi_out_idclk_n      => dvi_out_idclk_n,
      dvi_out_idclk_p      => dvi_out_idclk_p,
      dvi_out_isel_nrst    => dvi_out_isel_nrst,
      dvi_out_msen_po1     => dvi_out_msen_po1,
      dvi_out_nhpd         => dvi_out_nhpd,
      dvi_out_noc          => dvi_out_noc,
      dvi_out_npd          => dvi_out_npd,
      dvi_out_vsync        => dvi_out_vsync
    );

  -------------------------------------------------------------------------------------------------
  -- APB interface  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  apb_dvi : dvi_apb_interface 
  generic map(
    pindex               => pindex,
    paddr                => paddr,
    pmask                => pmask,
    addr_w               => 6,
    data_w               => 24
  )
  port map(
    apbi => apbi,
    apbo => apbo,

    dvi_cfg_addr  => dvi_cfg_addr,
    dvi_cfg_wdata => dvi_cfg_wdata,
    dvi_cfg_rdata => dvi_cfg_rdata,
    dvi_cfg_we    => dvi_cfg_we,
    dvi_cfg_en    => dvi_cfg_en
  );

  dvi_cfg_rdata <= "0000000000000" & dvi_in_cfg_rdata when r_dvi_cfg_addr = "00" else
                   "0000000000000" & dvi_fb_cfg_rdata when r_dvi_cfg_addr = "01" else
                   dvi_cb_cfg_rdata        when r_dvi_cfg_addr = "11" else
                   (others => '0');

  dvi_in_cfg_addr  <= dvi_cfg_addr(3 downto 0);
  dvi_in_cfg_wdata <= dvi_cfg_wdata(dvi_in_cfg_wdata'range);
  dvi_in_cfg_we    <= dvi_cfg_we;
  dvi_in_cfg_en    <= dvi_cfg_en and (not dvi_cfg_addr(5)) and not dvi_cfg_addr(4);

  dvi_fb_cfg_addr  <= dvi_cfg_addr(3 downto 0);
  dvi_fb_cfg_wdata <= dvi_cfg_wdata(dvi_fb_cfg_wdata'range);
  dvi_fb_cfg_we    <= dvi_cfg_we;
  dvi_fb_cfg_en    <= dvi_cfg_en and (not dvi_cfg_addr(5)) and dvi_cfg_addr(4);

  dvi_cb_cfg_addr  <= dvi_cfg_addr(3 downto 0);
  dvi_cb_cfg_wdata <= dvi_cfg_wdata(dvi_cb_cfg_wdata'range);
  dvi_cb_cfg_we    <= dvi_cfg_we;
  dvi_cb_cfg_en    <= dvi_cfg_en and dvi_cfg_addr(5) and dvi_cfg_addr(4);

  apb_addr : process(amba_clk)
  begin
    if(rising_edge(amba_clk))then
      r_dvi_cfg_addr <= dvi_cfg_addr(dvi_cfg_addr'length -1 downto dvi_cfg_addr'length-2);
    end if;
  end process;


  -------------------------------------------------------------------------------------------------
  -- DVI input regs  ------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

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

  dvi_reg_input_interface : process(dvi_in_odck, dvi_in_scdt)
  begin
    if(dvi_in_scdt = '0')then
      r_dvi_in_ctl_input    <= (others => '0');
      r_dvi_in_data_e_input <= (others => '0');
      r_dvi_in_data_o_input <= (others => '0');
      r_dvi_in_de_input     <= '0';
      r_dvi_in_hsync_input  <= '0';
      r_dvi_in_scdt_input   <= '0';
      r_dvi_in_vsync_input  <= '0';
    elsif(rising_edge(dvi_in_odck))then
      r_dvi_in_ctl_input    <= r_dvi_in_ctl;
      r_dvi_in_data_e_input <= r_dvi_in_data_e;
      r_dvi_in_data_o_input <= r_dvi_in_data_o;
      r_dvi_in_de_input     <= r_dvi_in_de;
      r_dvi_in_hsync_input  <= r_dvi_in_hsync;
      r_dvi_in_scdt_input   <= r_dvi_in_scdt;
      r_dvi_in_vsync_input  <= r_dvi_in_vsync;
    end if;

  end process;

  dvi_reg_input_propagate : process(dvi_in_odck, dvi_in_scdt)
  begin
    if(dvi_in_scdt = '0')then
      r_dvi_in_ctl_propagate    <= (others => '0');
      r_dvi_in_data_e_propagate <= (others => '0');
      r_dvi_in_data_o_propagate <= (others => '0');
      r_dvi_in_de_propagate     <= '0';
      r_dvi_in_hsync_propagate  <= '0';
      r_dvi_in_scdt_propagate   <= '0';
      r_dvi_in_vsync_propagate  <= '0';
    elsif(rising_edge(dvi_in_odck))then
      r_dvi_in_ctl_propagate    <= r_dvi_in_ctl;
      r_dvi_in_data_e_propagate <= r_dvi_in_data_e;
      r_dvi_in_data_o_propagate <= r_dvi_in_data_o;
      r_dvi_in_de_propagate     <= r_dvi_in_de;
      r_dvi_in_hsync_propagate  <= r_dvi_in_hsync;
      r_dvi_in_scdt_propagate   <= r_dvi_in_scdt;
      r_dvi_in_vsync_propagate  <= r_dvi_in_vsync;
    end if;

  end process;


end architecture rtl;

  
