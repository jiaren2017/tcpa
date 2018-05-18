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

package dvi_profpga is
  component dvi2ahb_top is
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
  --  dvi_out_clk : in std_ulogic;
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
  end component dvi2ahb_top;

  component ahb2dvi_top is
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
  end component ahb2dvi_top;

  component dvi_in2out_top is
    generic (
      hindex              : integer := 0;
      haddr               : integer := 16#400#;
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
  end component dvi_in2out_top;

  component dvi_output_color_box is
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
  end component dvi_output_color_box;

  component dvi_ahb_interface is
    generic (
      hindex               : integer                    := 0;
      haddr                : integer                    := 16#400#;
      hirq                 : integer                    := 0;
      AHB_WAIT_CYCLES      : integer                    := 1;
      ADDR_W               : positive                   := 22
    );
    port (
      amba_clk : in std_ulogic;
      reset : in std_ulogic;
      
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type;

      px_in_addr  : out std_ulogic_vector(ADDR_W-1 downto 0);
      px_in_data  : out std_ulogic_vector(23 downto 0);
      px_in_valid : out std_ulogic;
      px_in_ready : in  std_ulogic;

      px_out_request_addr  : out std_ulogic_vector(ADDR_W-1 downto 0);
      px_out_request_en    : out std_ulogic;
      px_out_request_ready : in  std_ulogic;

      px_out_data  : in  std_ulogic_vector(ADDR_W +23 downto 0);
      px_out_valid : in  std_ulogic;
      px_out_used  : out std_ulogic;

      frame_in_ctl : in std_ulogic_vector(1 downto 0)
    );
  end component dvi_ahb_interface;

  component dvi_apb_interface is
    generic (
      pindex               : integer                    := 0;
      paddr                : integer                    := 16#400#;
      pmask                : integer                    := 16#FFF#;
      addr_w               : positive                   := 4;
      data_w               : positive range 1 to 32     := 11;
      CONTRIBUTOR_ID       : integer;
      DEVICE_ID            : integer
    );
    port (
      apbi : in  apb_slv_in_type;
      apbo : out apb_slv_out_type;

      dvi_cfg_addr  : out std_ulogic_vector(addr_w-1 downto 0);
      dvi_cfg_wdata : out std_ulogic_vector(data_w-1 downto 0);
      dvi_cfg_rdata : in  std_ulogic_vector(data_w-1 downto 0);
      dvi_cfg_we    : out std_ulogic;
      dvi_cfg_en    : out std_ulogic
    );
  end component dvi_apb_interface;

  component dvi_input_interface is
    generic (
      STD_FRAME_OUT_WIDTH    : positive range   1 to 2046 := 640;
      STD_FRAME_OUT_HEIGHT   : positive range   1 to 1022 := 480;
      STD_SKIP_PX            : integer  range   0 to   15 :=   0;
      STD_SKIP_ROW           : integer  range   0 to   15 :=   0;
      STD_DVI_IN_EN          : integer  range   0 to    1 :=   1;
      STD_DVI_IN_DFO         : integer  range   0 to    1 :=   0;
      STD_DVI_IN_NPD         : integer  range   0 to    1 :=   1;
      STD_DVI_IN_NPDO        : integer  range   0 to    1 :=   1;
      STD_DVI_IN_NSTAG       : integer  range   0 to    1 :=   1;
      STD_DVI_IN_OCK_INV     : integer  range   0 to    1 :=   0;
      STD_DVI_IN_PIX         : integer  range   0 to    1 :=   0;
      STD_DVI_IN_ST          : integer  range   0 to    1 :=   1;
      ADDR_W                 : positive                   :=  22
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
  end component dvi_input_interface;

  component dvi_output_interface is
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
  end component dvi_output_interface;

  component frame_buffer is
    generic (
      PX_FIFO_DATA_WIDTH : positive range   8 to   32 :=   24;
      PX_FIFO_ADDR_WIDTH : positive range   1 to   10 :=    5;
      ADDR_W             : positive                   :=   22;  -- width of the address bus
      DQ_PINS            : positive                   :=   18;  -- number of DQ pins
      GROUPS             : positive                   :=    2;  -- number of byte write enable pins
      STD_DVI_IN_EN      : integer                    :=    1;
      SINGLE_COLOR_WRITE : integer                    :=    0;
      SINGLE_COLOR_READ  : integer                    :=    0
    );
    port (
      
      -- clock/sync (driven by mainboard)
      -- Only using clocks 0 to 4 (i.e. not 5, 6, or 7)
      cfg_clk     : in std_ulogic;
      clk200      : in std_ulogic;
      sram_clk    : in std_ulogic;
      dvi_in_clk  : in std_ulogic;
      dvi_out_clk : in std_ulogic;
      
      reset       : in std_ulogic;

      px_in_data   : in  std_ulogic_vector(PX_FIFO_DATA_WIDTH -1 downto 0);
      px_in_addr   : in  std_ulogic_vector(ADDR_W-1 downto 0);
      px_in_valid  : in  std_ulogic;
      px_in_ready  : out std_ulogic;
      frame_in_ctl : in  std_ulogic_vector(1 downto 0);

      px_out_req   : in  std_ulogic;
      px_out_addr  : in  std_ulogic_vector(ADDR_W-1 downto 0);
      px_out_rcvd  : in  std_ulogic;
      px_out_ready : out std_ulogic;
      px_out_data  : out std_ulogic_vector(ADDR_W +PX_FIFO_DATA_WIDTH -1 downto 0);
      px_out_valid : out std_ulogic;

      dvi_fb_cfg_addr  : in  std_ulogic_vector(3 downto 0);
      dvi_fb_cfg_wdata : in  std_ulogic_vector(10 downto 0);
      dvi_fb_cfg_rdata : out std_ulogic_vector(10 downto 0);
      dvi_fb_cfg_we    : in  std_ulogic;
      dvi_fb_cfg_en    : in  std_ulogic;

      -- SSRAM interface
      sram_k_p    : out   std_logic;
      sram_k_n    : out   std_logic;
      sram_a      : out   std_logic_vector (ADDR_W-1 downto 0);
      sram_dq     : inout std_logic_vector (DQ_PINS-1 downto 0);
      sram_bws_n  : out   std_logic_vector (GROUPS-1 downto 0);
      sram_rnw    : out   std_logic;
      sram_ld_n   : out   std_logic;
      sram_doff_n : out   std_logic
    );
  end component frame_buffer;

  component rgb2yuv is
      port ( clk : in std_ulogic;
             red : in std_ulogic_vector (7 downto 0);
             green : in std_ulogic_vector (7 downto 0);
             blue : in std_ulogic_vector (7 downto 0);
             y : out std_ulogic_vector (7 downto 0);
             u : out std_ulogic_vector (7 downto 0);
             v : out std_ulogic_vector (7 downto 0));
  end component rgb2yuv;

  component div_16bit is
    port (
        clk : in std_ulogic;
        dividend  : in unsigned(7 downto 0);
        divisor   : in unsigned(7 downto 0);
        result    : out unsigned(15 downto 0)
    );
  end component;
  
  component div_s16bit is
    port (
        clk : in std_ulogic;
        dividend  : in signed(8 downto 0);
        divisor   : in signed(8 downto 0);
        result    : out signed(16 downto 0)
    );
  end component;
    
 component mul_16bit is
    port (
        clk : in std_ulogic;
        multiplicant: in unsigned(15 downto 0);
        multiplier : in unsigned(15 downto 0);
        result    : out unsigned(31 downto 0)
    );
  end component;
    
  component sub_s16bit is
    port (
        clk : in std_ulogic;
        minuend  : in unsigned(7 downto 0);
        subtrahend   : in unsigned(7 downto 0);
        result    : out signed(8 downto 0)
    );
  end component;
    
  component add_s16bit is
    port (
        clk : in std_ulogic;
        summand1  : in signed(16 downto 0);
        summand2  : in signed(16 downto 0);
        result    : out signed(16 downto 0)
    );
  end component;
    
  component maxmin is
    port(
      clk : in std_logic;
      A, B, C : in unsigned(7 downto 0);
      max_i : out unsigned(1 downto 0);
      min_i : out unsigned(1 downto 0)
    );
  end component;
    
  component mux_3_1_8bit is
    port(
      clk : in std_logic;
      A, B, C : in unsigned(7 downto 0);
      control : in unsigned(1 downto 0);
      result : out unsigned(7 downto 0)
    );
  end component;
        
  component mux_3_1_s16bit is
    port(
      clk : in std_logic;
      A, B, C : in signed(16 downto 0);
      control : in unsigned(1 downto 0);
      result : out signed(16 downto 0)
    );
  end component;
  
  component rgb2hsv is
    generic (
      ADDR_W : positive
    );
    port ( 
      clk : in std_ulogic;

      r : in std_ulogic_vector (7 downto 0);
      g : in std_ulogic_vector (7 downto 0);
      b : in std_ulogic_vector (7 downto 0);
      addr_in : in std_ulogic_vector(ADDR_W-1 downto 0);
      valid_in : in std_ulogic;
 
      h : out std_ulogic_vector (7 downto 0);
      s : out std_ulogic_vector (7 downto 0);
      v : out std_ulogic_vector (7 downto 0);
      addr : out std_ulogic_vector(ADDR_W-1 downto 0);
      valid : out std_ulogic
    );
  end component;

  component beeper is
    generic (
      COUNTER_WIDTH : positive;
      DIVIDER_WIDTH : positive
    );
    port (
      beeper_clk : in std_ulogic;
      cfg_clk    : in std_ulogic;
      reset : in std_ulogic;

      beeper_cfg_wdata : in  std_ulogic_vector(max(COUNTER_WIDTH, DIVIDER_WIDTH)-1 downto 0);
      beeper_cfg_rdata : out std_ulogic_vector(max(COUNTER_WIDTH, DIVIDER_WIDTH)-1 downto 0);
      beeper_cfg_addr  : in  std_ulogic_vector(1 downto 0);
      beeper_cfg_we    : in  std_ulogic;
      beeper_cfg_en    : in  std_ulogic;

      beeper_out        : out std_ulogic
    );
  component entity beeper;

  component beeper_top is
    generic (
      COUNTER_WIDTH : positive range 1 to 32;
      DIVIDER_WIDTH : positive range 1 to 32;
      PINDEX        : integer;
      PADDR         : integer
    );
    port (
      beeper_clk : in std_ulogic;
      amba_clk   : in std_ulogic;
      reset : in std_ulogic;

      beeper_out        : out std_ulogic;
      
      apbi               : in  apb_slv_in_type;
      apbo               : out apb_slv_out_type
    
    );
  end component beeper_top;

end package;

