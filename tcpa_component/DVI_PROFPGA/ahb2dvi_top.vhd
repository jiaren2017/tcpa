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

entity ahb2dvi_top is
  generic (
    hindex              : integer := 0;
    haddr               : integer := 16#400#;
    pindex              : integer := 1;
    paddr               : integer := 1;
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
    dvi_out_clk : in std_ulogic;
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
end entity ahb2dvi_top;

architecture rtl of ahb2dvi_top is

  signal px_in_addr  : std_ulogic_vector(ADDR_W -1 downto 0);
  signal px_in_data  : std_ulogic_vector(23 downto 0);
  signal px_in_valid : std_ulogic;
  signal px_in_ready : std_ulogic;
  
  signal dvi_cfg_addr   : std_ulogic_vector(5 downto 0);
  signal r_dvi_cfg_addr : std_ulogic_vector(1 downto 0);
  signal dvi_cfg_wdata  : std_ulogic_vector(12 downto 0);
  signal dvi_cfg_rdata  : std_ulogic_vector(12 downto 0);
  signal dvi_cfg_we     : std_ulogic;
  signal dvi_cfg_en     : std_ulogic;

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

  signal dvi_fb_cfg_addr  : std_ulogic_vector(3 downto 0);
  signal dvi_fb_cfg_wdata : std_ulogic_vector(10 downto 0);
  signal dvi_fb_cfg_rdata : std_ulogic_vector(10 downto 0);
  signal dvi_fb_cfg_we    : std_ulogic;
  signal dvi_fb_cfg_en    : std_ulogic;

  signal dvi_cb_cfg_addr  : std_ulogic_vector(3 downto 0);
  signal dvi_cb_cfg_wdata : std_ulogic_vector(12 downto 0);
  signal dvi_cb_cfg_rdata : std_ulogic_vector(12 downto 0);
  signal dvi_cb_cfg_we    : std_ulogic;
  signal dvi_cb_cfg_en    : std_ulogic;

  signal dvi_in_frame_width  : unsigned(10 downto 0);
  signal dvi_in_frame_height : unsigned(10 downto 0);
  signal dvi_in_frame_ctl    : std_ulogic_vector(1 downto 0);

  signal px_out_addr  : std_ulogic_vector(ADDR_W-1 downto 0);
  signal px_out_req   : std_ulogic;
  signal px_out_ready : std_ulogic;

  signal px_out_data  : std_ulogic_vector(ADDR_W +23 downto 0);
  signal px_out_valid : std_ulogic;
  signal px_out_rcvd  : std_ulogic;
  
  signal dvi_cb_out_data  : std_ulogic_vector(23 downto 0);
  signal dvi_cb_out_de    : std_ulogic;
  signal dvi_cb_out_hsync : std_ulogic;
  signal dvi_cb_out_vsync : std_ulogic;

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


---------------------------------------------------------------------------------------------------
---- write pixels to hdmi out - blacken border if necessary ---------------------------------------
---------------------------------------------------------------------------------------------------

  px_out_addr(1 downto 0) <= "00";

  dvi_output : dvi_output_interface
  generic map(
    ADDR_W                     => ADDR_W -2,
    STD_FRAME_IN_WIDTH         => 1024,
    STD_FRAME_IN_HEIGHT        =>  527,
    STD_FRAME_OUT_WIDTH        =>  640,
    STD_FRAME_OUT_HEIGHT       =>  480, 
    STD_FRAME_OUT_HSYNC        =>   96,  
    STD_FRAME_OUT_HFRONT       =>   16,
    STD_FRAME_OUT_HBACK        =>   48,
    STD_FRAME_OUT_VSYNC        =>    2,
    STD_FRAME_OUT_VFRONT       =>   10,
    STD_FRAME_OUT_VBACK        =>   33,
    STD_DVI_OUT_EN             =>    1,
    STD_FRAME_OUT_ACTIVE_HSYNC =>    0,
    STD_FRAME_OUT_ACTIVE_VSYNC =>    0,
    STD_DVI_OUT_A3_DK3         =>    0, 
    STD_DVI_OUT_BSEL_SCL       =>    1, 
    STD_DVI_OUT_CTL            =>    0, 
    STD_DVI_OUT_DKEN           =>    0, 
    STD_DVI_OUT_DSEL_SDA       =>    0, 
    STD_DVI_OUT_EDGE           =>    1, 
    STD_DVI_OUT_IDCLK_N        =>    0, 
    STD_DVI_OUT_ISEL_NRST      =>    0, 
    STD_DVI_OUT_MSEN_PO1       =>    0, 
    STD_DVI_OUT_NHPD           =>    1, 
    STD_DVI_OUT_NOC            =>    0, 
    STD_DVI_OUT_NPD            =>    1 
  )
  port map(
    dvi_out_clk => dvi_out_clk,
    cfg_clk => amba_clk,
    reset => reset,


    px_request_addr  => px_out_addr(px_out_addr'length-1 downto 2),
    px_request_en    => px_out_req,
    px_request_ready => px_out_ready,

    px_data  => px_out_data(px_out_data'length-1 downto px_out_data'length-24),
    px_valid => px_out_valid,
    px_used  => px_out_rcvd,

    dvi_out_cfg_wdata => dvi_out_cfg_wdata,
    dvi_out_cfg_rdata => dvi_out_cfg_rdata,
    dvi_out_cfg_addr  => dvi_out_cfg_addr,
    dvi_out_cfg_we    => dvi_out_cfg_we,
    dvi_out_cfg_en    => dvi_out_cfg_en,

    dvi_out_frame_end => open,

    -- pins which are connected to motherboard connector td1 
    -- and connector ba1 on x-board eb-pds-dvi-r1 
    dvi_out_a3_dk3       => open,
    dvi_out_bsel_scl     => open,
    dvi_out_ctl          => open,
    dvi_out_data         => dvi_cb_out_data,
    dvi_out_de           => dvi_cb_out_de,
    dvi_out_dken         => open,
    dvi_out_dsel_sda     => open,
    dvi_out_edge         => open,
    dvi_out_hsync        => dvi_cb_out_hsync,
    dvi_out_idclk_n      => open,
    dvi_out_idclk_p      => open,
    dvi_out_isel_nrst    => open,
    dvi_out_msen_po1     => open,
    dvi_out_nhpd         => open,
    dvi_out_noc          => open,
    dvi_out_npd          => open,
    dvi_out_vsync        => dvi_cb_out_vsync 
  );

  -------------------------------------------------------------------------------------------------
  -- frame buffer to ahb interface ----------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  dvi2ahb : dvi_ahb_interface
    generic map(
      hindex               => hindex, --  integer                    := 0;
      haddr                => haddr, --  integer                    := 16#400#;
      AHB_WAIT_CYCLES      => 1,
      ADDR_W               => ADDR_W  --  positive                   :=  22;
    )
    port map(
      amba_clk => amba_clk, --  std_ulogic;
      reset => reset, --  std_ulogic;
      
      ahbsi => ahbsi, --  ahb_slv_in_type;
      ahbso => ahbso, --  ahb_slv_out_type;
  
      px_in_addr  => px_in_addr, --  out std_ulogic_vector(ADDR_W-1 downto 0)
      px_in_data  => px_in_data, --  out std_ulogic_vector(23 downto 0);
      px_in_valid => px_in_valid, --  out std_ulogic;
      px_in_ready => px_in_ready, --  in  std_ulogic;
  
      px_out_request_addr  => open, --  out std_ulogic_vector(ADDR_W-1 downto 0);
      px_out_request_en    => open, --  out std_ulogic;
      px_out_request_ready => '1', --  in  std_ulogic;
  
      px_out_data  => (others => '0'), --  in  std_ulogic_vector(23 downto 0);
      px_out_valid => '1', --  in  std_ulogic;
      px_out_used  => open, --  out std_ulogic;
  
      frame_in_ctl => "00"  --  in std_ulogic_vector(1 downto 0)
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
      dvi_in_clk  => amba_clk, --  in std_ulogic;
      dvi_out_clk => dvi_out_clk, --  in std_ulogic;
      
      reset   => reset, --  in std_ulogic;
  
      px_in_data   => px_in_data, --  in  std_ulogic_vector(23 downto 0);
      px_in_addr   => px_in_addr, --  in  std_ulogic_vector(ADDR_W-2 downto 0);
      px_in_valid  => px_in_valid, --  in  std_ulogic;
      px_in_ready  => px_in_ready, --  out std_ulogic;
      frame_in_ctl => "00",
  
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
      dvi_in_clk  => dvi_out_clk,
      cfg_clk     => amba_clk,
      reset => reset,
  
      dvi_out_cfg_wdata => dvi_cb_cfg_wdata,
      dvi_out_cfg_rdata => dvi_cb_cfg_rdata,
      dvi_out_cfg_addr  => dvi_cb_cfg_addr,
      dvi_out_cfg_we    => dvi_cb_cfg_we,
      dvi_out_cfg_en    => dvi_cb_cfg_en,
  
      dvi_in_data         => dvi_cb_out_data,
      dvi_in_de           => dvi_cb_out_de,
      dvi_in_hsync        => dvi_cb_out_hsync,
      dvi_in_vsync        => dvi_cb_out_vsync,
      dvi_in_valid        => '1',
  
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


  apb_dvi_output : dvi_apb_interface 
  generic map(
    pindex               => pindex,
    paddr                => paddr,
    pmask                => pmask,
    addr_w               => 6,
    data_w               => 13,
    CONTRIBUTOR_ID       => 16#CC#,
    DEVICE_ID            => 16#001#
  )
  port map(
    apbi => apbi,
    apbo => apbo,

    dvi_cfg_addr  => dvi_cfg_addr, --  out std_ulogic_vector(ADDR_W-1 downto 0);
    dvi_cfg_wdata => dvi_cfg_wdata, --  out std_ulogic_vector(10 downto 0);
    dvi_cfg_rdata => dvi_cfg_rdata, --  in  std_ulogic_vector(10 downto 0);
    dvi_cfg_we    => dvi_cfg_we, --  out std_ulogic;
    dvi_cfg_en    => dvi_cfg_en  --  out std_ulogic;
  );

  dvi_cfg_rdata <= dvi_out_cfg_rdata       when r_dvi_cfg_addr = "10" else
                   "00" & dvi_fb_cfg_rdata when r_dvi_cfg_addr = "01" else
                   dvi_cb_cfg_rdata        when r_dvi_cfg_addr = "11" else
                   (others => '0');

  dvi_out_cfg_addr  <= dvi_cfg_addr(3 downto 0);
  dvi_out_cfg_wdata <= dvi_cfg_wdata(dvi_out_cfg_wdata'range);
  dvi_out_cfg_we    <= dvi_cfg_we;
  dvi_out_cfg_en    <= dvi_cfg_en and dvi_cfg_addr(5) and not dvi_cfg_addr(4);

  dvi_fb_cfg_addr  <= dvi_cfg_addr(3 downto 0);
  dvi_fb_cfg_wdata <= dvi_cfg_wdata(dvi_fb_cfg_wdata'range);
  dvi_fb_cfg_we    <= dvi_cfg_we;
  dvi_fb_cfg_en    <= dvi_cfg_en and not dvi_cfg_addr(5) and dvi_cfg_addr(4);

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

end architecture rtl;

  
