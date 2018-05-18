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
library unisim;
    use unisim.vcomponents.all;
library profpga;
    use profpga.afifo_core_pkg.all;
    use profpga.generic_ram_comp.all;

entity frame_buffer is
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
end entity frame_buffer;

architecture rtl of frame_buffer is
  type buffer_states is (idle, write_frame, read, sram_nops, write, wait_for_fifo);
  attribute dont_touch : string;

  constant PX_IN_FIFO_ALMOST_FULL       : positive := 2**(PX_FIFO_ADDR_WIDTH)-6;
  constant PX_IN_FIFO_ALMOST_EMPTY      : positive := 1;
  constant PX_OUT_FIFO_ALMOST_FULL      : positive := 2**(PX_FIFO_ADDR_WIDTH)-7;
  constant PX_OUT_FIFO_ALMOST_EMPTY     : positive := 5;

  -- outputs of the clock domains
  signal internal_reset   : std_ulogic;
  signal internal_reset_n : std_ulogic;

  signal px_in_fifo_wr_reset_n : std_ulogic;
  signal px_in_fifo_wr_data    : std_ulogic_vector(PX_FIFO_DATA_WIDTH + ADDR_W -1 downto 0);
  signal px_in_fifo_wr_full    : std_ulogic;
  signal px_in_fifo_wr_diff    : std_ulogic_vector(PX_FIFO_ADDR_WIDTH downto 0);
  signal px_in_fifo_wr_en      : std_ulogic;

  signal px_in_fifo_rd_reset_n : std_ulogic;
  signal px_in_fifo_rd_data    : std_ulogic_vector(px_in_fifo_wr_data'length-1 downto 0);
  signal px_in_fifo_rd_empty   : std_ulogic;
  signal px_in_fifo_rd_en      : std_ulogic;
  signal px_in_fifo_rd_diff    : std_ulogic_vector(PX_FIFO_ADDR_WIDTH downto 0);
  signal r_max_writes    : unsigned(PX_FIFO_ADDR_WIDTH downto 0);

  signal px_out_request_fifo_wr_reset_n : std_ulogic;
  signal px_out_request_fifo_wr_data    : std_ulogic_vector(ADDR_W-1 downto 0);
  signal px_out_request_fifo_wr_en      : std_ulogic;
  signal px_out_request_fifo_wr_full    : std_ulogic;
  signal px_out_request_fifo_wr_diff    : std_ulogic_vector(PX_FIFO_ADDR_WIDTH downto 0);

  signal px_out_request_fifo_rd_data    : std_ulogic_vector(ADDR_W-1 downto 0);
  signal px_out_request_fifo_rd_empty   : std_ulogic;
  signal px_out_request_fifo_rd_en      : std_ulogic;
  signal px_out_request_fifo_rd_diff    : std_ulogic_vector(PX_FIFO_ADDR_WIDTH downto 0);
  signal px_out_request_fifo_rd_reset_n : std_ulogic;

  signal px_out_fifo_wr_reset_n : std_ulogic;
  signal px_out_fifo_wr_data    : std_ulogic_vector(ADDR_W +PX_FIFO_DATA_WIDTH-1 downto 0);
  signal px_out_fifo_wr_en      : std_ulogic;
  signal px_out_fifo_wr_full    : std_ulogic;
  signal px_out_fifo_wr_diff    : std_ulogic_vector(PX_FIFO_ADDR_WIDTH downto 0);

  signal px_out_fifo_rd_data    : std_ulogic_vector(ADDR_W +PX_FIFO_DATA_WIDTH-1 downto 0);
  signal px_out_fifo_rd_empty   : std_ulogic;
  signal px_out_fifo_rd_en      : std_ulogic;
  signal px_out_fifo_rd_diff    : std_ulogic_vector(PX_FIFO_ADDR_WIDTH downto 0);
  signal px_out_fifo_rd_reset_n : std_ulogic;

  signal r_max_read_requests : unsigned(PX_FIFO_ADDR_WIDTH downto 0);
  signal r_max_reads         : unsigned(PX_FIFO_ADDR_WIDTH downto 0);

  signal mem_wr_enable : std_ulogic;
  signal mem_wr_address : std_ulogic_vector(PX_FIFO_ADDR_WIDTH-1 downto 0);
  signal mem_wr_data : std_ulogic_vector(PX_FIFO_DATA_WIDTH +ADDR_W -1 downto 0);
  signal mem_rd_enable : std_ulogic;
  signal mem_rd_address : std_ulogic_vector(PX_FIFO_ADDR_WIDTH-1 downto 0);
  signal mem_rd_data : std_ulogic_vector(PX_FIFO_DATA_WIDTH +ADDR_W -1 downto 0);

  signal mem_o_wr_enable : std_ulogic;
  signal mem_o_wr_address : std_ulogic_vector(PX_FIFO_ADDR_WIDTH-1 downto 0);
  signal mem_o_wr_data : std_ulogic_vector(ADDR_W +PX_FIFO_DATA_WIDTH-1 downto 0);
  signal mem_o_rd_enable : std_ulogic;
  signal mem_o_rd_address : std_ulogic_vector(PX_FIFO_ADDR_WIDTH-1 downto 0);
  signal mem_o_rd_data : std_ulogic_vector(ADDR_W +PX_FIFO_DATA_WIDTH-1 downto 0);

  signal mem_req_wr_enable : std_ulogic;
  signal mem_req_wr_address : std_ulogic_vector(PX_FIFO_ADDR_WIDTH-1 downto 0);
  signal mem_req_wr_data : std_ulogic_vector(ADDR_W-1 downto 0);
  signal mem_req_rd_enable : std_ulogic;
  signal mem_req_rd_address : std_ulogic_vector(PX_FIFO_ADDR_WIDTH-1 downto 0);
  signal mem_req_rd_data : std_ulogic_vector(ADDR_W-1 downto 0);


  signal sram_ready           :    std_logic;                               -- becomes high if initialization and read leveling is done
  signal sram_read_latency    :    std_logic_vector (4 downto 0);           -- number of NOP cycles between transition from read to write operation
  signal sram_read2write_nops :    std_logic_vector (3 downto 0);           -- number of NOP cycles between transition from read to write operation
  signal sram_addr            :    std_logic_vector (ADDR_W-2 downto 0);    -- memory address
  signal sram_bwe             :    std_logic_vector (3 downto 0);           -- byte write enable
  signal sram_en              :    std_logic;                               -- enable
  signal sram_we              :    std_logic;                               -- write enable
  signal sram_wdata           :    std_logic_vector (2*DQ_PINS-1 downto 0); -- write data
  signal sram_rdata           :    std_logic_vector (2*DQ_PINS-1 downto 0); -- read data
  signal sram_rvalid          :    std_logic;                               -- read data valid

  signal c_px_max_addr                : unsigned(PX_FIFO_ADDR_WIDTH downto 0);
  signal c_px_in_fifo_almost_full     : unsigned(PX_FIFO_ADDR_WIDTH downto 0);
  signal c_px_in_fifo_almost_empty    : unsigned(integer(ceil(log2(real(PX_IN_FIFO_ALMOST_EMPTY+1))))-1 downto 0);
  signal c_px_out_fifo_almost_full    : unsigned(PX_FIFO_ADDR_WIDTH downto 0);
  signal c_px_out_fifo_almost_empty   : unsigned(sram_read_latency'length-1 downto 0);

  signal r_dvi_in_active_hsync     : std_ulogic;
  signal r_dvi_in_active_vsync     : std_ulogic;
  signal r_dvi_in_frame_vsync_1    : std_ulogic;
  signal r_dvi_in_frame_vsync_2    : std_ulogic;
  signal r_dvi_in_frame_vsync_transition    : std_ulogic;

  signal buffer_sm_state : buffer_states;

  signal wframe : std_logic;
  signal rframe : std_logic;
  signal sram_action_counter : unsigned(3 downto 0);
  signal w_px_out_fifo_almost_full : std_logic;
  signal w_px_out_fifo_almost_empty : std_logic;
  signal w_px_in_fifo_almost_full : std_logic;
  signal w_px_in_fifo_almost_empty : std_logic;

  signal r_error_px_in_fifo  : std_ulogic;
  signal r_error_px_out_fifo : std_ulogic;
  signal r_led : std_ulogic_vector(7 downto 0);

  signal r_first_frame_done : std_ulogic;

  signal r_freeze_frame_1, r_freeze_frame_2 : std_ulogic;
  signal r_frame_in_ctl_1, r_frame_in_ctl_2, r_frame_in_ctl_3 : std_ulogic_vector(1 downto 0);
  signal r_dvi_cfg_frame_end, r_dvi_cfg_frame_end_1, r_dvi_cfg_frame_end_2, r_dvi_cfg_frame_end_3 : std_ulogic_vector(1 downto 0);
  signal r_dvi_fb_single_color_write : std_ulogic;
  signal r_dvi_fb_single_color_write_sram : std_ulogic;
  signal r_dvi_fb_single_color_read : std_ulogic;
  signal r_dvi_fb_single_color_read_sram : std_ulogic;

  signal r_dvi_fb_en : std_ulogic_vector(1 downto 0);

  signal color_addr_fifo_wr_data : std_logic_vector ( 1 downto 0 );
  signal color_addr_fifo_wr_en   : std_logic;
  signal color_addr_fifo_rd_en   : std_logic;
  signal color_addr_fifo_rd_data : std_logic_vector ( 1 downto 0 );

  signal read_addr : unsigned(ADDR_W-1 downto 0);
  signal read_out_addr_offset : unsigned(1 downto 0);
  signal read_out_next_addr : unsigned(ADDR_W-1 downto 0);
  signal read_lock : unsigned(sram_read_latency'range);

  signal sram_reset : std_logic;
  signal internal_sram_reset : std_logic;

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

  component fifo_generator_0 is
    port (
      clk : in std_logic;
      rst : in std_logic;
      din : in std_logic_vector ( 1 downto 0 );
      wr_en : in std_logic;
      rd_en : in std_logic;
      dout : out std_logic_vector ( 1 downto 0 );
      full : out std_logic;
      empty : out std_logic
    );
  end component;
begin
  sram_doff_n <= '1';
  c_px_max_addr <= to_unsigned(2**PX_FIFO_ADDR_WIDTH-1, c_px_max_addr'length);
  c_px_in_fifo_almost_full   <= c_px_max_addr -unsigned(sram_read2write_nops) -4;
  c_px_in_fifo_almost_empty  <= to_unsigned(PX_IN_FIFO_ALMOST_EMPTY, c_px_in_fifo_almost_empty'length);
  c_px_out_fifo_almost_full  <= c_px_max_addr -unsigned(sram_read_latency);
  sram_read_latency(sram_read_latency'length-1) <= '0';
  c_px_out_fifo_almost_empty <= unsigned(sram_read_latency) +3; -- to_unsigned(PX_OUT_FIFO_ALMOST_EMPTY, c_px_out_fifo_almost_empty'length);

  internal_reset   <= reset or (not sram_ready) or not r_dvi_fb_en(0);
  internal_reset_n <= not internal_reset;

  -------------------------------------------------------------------------------------------------
  -- Configuration of timing controller -----------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  config : process(cfg_clk, reset)
  begin
    if(reset = '1')then
      r_dvi_fb_en <= (others => '0');

      if(STD_DVI_IN_EN = 0)then
        r_dvi_fb_en(0)  <= '0';
      else
        r_dvi_fb_en(0)  <= '1';
      end if;

      if(SINGLE_COLOR_WRITE = 0)then
        r_dvi_fb_single_color_write <= '0';
      else
        r_dvi_fb_single_color_write <= '1';
      end if;

      if(SINGLE_COLOR_READ  = 0)then
        r_dvi_fb_single_color_read <= '0';
      else
        r_dvi_fb_single_color_read <= '1';
      end if;

      r_dvi_cfg_frame_end <= (others => '0');

    elsif(rising_edge(cfg_clk))then
      r_dvi_fb_en     <= r_dvi_fb_en;
      r_dvi_cfg_frame_end <= (others => '0');

      if((dvi_fb_cfg_en and dvi_fb_cfg_we) = '1')then
        case(dvi_fb_cfg_addr)is
          when "0000" => r_dvi_fb_en                  <= dvi_fb_cfg_wdata(r_dvi_fb_en'range);
          when "0001" => r_dvi_fb_single_color_write  <= dvi_fb_cfg_wdata(0);
          when "0010" => r_dvi_fb_single_color_read   <= dvi_fb_cfg_wdata(0);
          when "0011" => r_dvi_cfg_frame_end          <= dvi_fb_cfg_wdata(r_dvi_cfg_frame_end'range);
          when others => null;
        end case;
      else
        dvi_fb_cfg_rdata <= (others => '0');
        case(dvi_fb_cfg_addr)is
          when "0000" => dvi_fb_cfg_rdata(r_dvi_fb_en'range) <= r_dvi_fb_en; 
                         dvi_fb_cfg_rdata(r_dvi_fb_en'length) <= sram_ready;
                         dvi_fb_cfg_rdata(r_dvi_fb_en'length+1) <= r_first_frame_done;

          when "0001" => dvi_fb_cfg_rdata(0) <= r_dvi_fb_single_color_write;
          when "0010" => dvi_fb_cfg_rdata(0) <= r_dvi_fb_single_color_read;
          when others => null;
        end case;
      end if;
    end if;
  end process;


  -------------------------------------------------------------------------------------------------
  -- generic async fifo - input pixels ------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

--  px_in_fifo_rd_en <= sram_en and sram_we;
  reset_in_fifo_sram : process(sram_clk)begin
    if(rising_edge(sram_clk))then
      px_in_fifo_rd_reset_n <= internal_reset_n;
    end if;
  end process;

  reset_in_fifo_dvi_in : process(dvi_in_clk)begin
    if(rising_edge(dvi_in_clk))then
      px_in_fifo_wr_reset_n <= internal_reset_n;
    end if;
  end process;

  px_in_ready        <= (not px_in_fifo_wr_full) and px_in_fifo_wr_reset_n;
  px_in_fifo_wr_data <= px_in_data & px_in_addr;
  px_in_fifo_wr_en   <= px_in_valid;
  
  -- FIFO core
  i_afifo_core : afifo_core
    generic map(
      DATA_WIDTH               => (PX_FIFO_DATA_WIDTH + ADDR_W),
      ADDR_WIDTH               => PX_FIFO_ADDR_WIDTH,
      FIRST_WORD_FALLS_THROUGH => true
    ) 
    port map(
      --Write clock domain
      wr_clk                 => dvi_in_clk,
      wr_reset_n             => px_in_fifo_wr_reset_n,
      wr_enable_i            => px_in_fifo_wr_en,
      wr_data_i              => px_in_fifo_wr_data,
      wr_full_o              => px_in_fifo_wr_full,
      wr_diff_o              => px_in_fifo_wr_diff,
      -- Read clock domain
      rd_clk                 => sram_clk,
      rd_reset_n             => px_in_fifo_rd_reset_n,
      rd_enable_i            => px_in_fifo_rd_en,
      rd_data_o              => px_in_fifo_rd_data,
      rd_empty_o             => px_in_fifo_rd_empty,
      rd_diff_o              => px_in_fifo_rd_diff,
      -- Memory interface
      wea_o                  => mem_wr_enable,
      addra_o                => mem_wr_address,
      dataa_o                => mem_wr_data,
      enb_o                  => mem_rd_enable,
      addrb_o                => mem_rd_address,
      datab_i                => mem_rd_data
    );

  -- FIFO storage memory
  u_dl_generic_dpram : generic_dpram
    generic map(
      DATA_W   => (PX_FIFO_DATA_WIDTH + ADDR_W),
      ADDR_W   => PX_FIFO_ADDR_WIDTH
    ) 
    port map(
      clk1   => dvi_in_clk,
      ce1    => '1',
      we1    => mem_wr_enable,
      addr1  => mem_wr_address,
      wdata1 => mem_wr_data,
      rdata1 => open,

      clk2   => sram_clk,
      ce2    => mem_rd_enable,
      we2    => '0',
      addr2  => mem_rd_address,
      wdata2 => (others => '0'),
      rdata2 => mem_rd_data
    );


  -------------------------------------------------------------------------------------------------
  -- generic async fifo - read requests -----------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  reset_out_request_fifo_sram : process(sram_clk)begin
    if(rising_edge(sram_clk))then
      px_out_request_fifo_rd_reset_n <= internal_reset_n;
    end if;
  end process;

  reset_out_request_fifo_dvi_out : process(dvi_out_clk)begin
    if(rising_edge(dvi_out_clk))then
      px_out_request_fifo_wr_reset_n <= internal_reset_n;
    end if;
  end process;


  px_out_request_fifo_wr_en <= px_out_req;
  px_out_request_fifo_wr_data <= px_out_addr;
  px_out_ready <= (not px_out_request_fifo_wr_full) and px_out_request_fifo_wr_reset_n and r_first_frame_done;


  -- FIFO core
  i_afifo_core_out_request : afifo_core
    generic map(
      DATA_WIDTH               => ADDR_W,
      ADDR_WIDTH               => PX_FIFO_ADDR_WIDTH,
      FIRST_WORD_FALLS_THROUGH => true
    ) 
    port map(
      --Write clock domain
      wr_clk                 => dvi_out_clk,
      wr_reset_n             => px_out_request_fifo_wr_reset_n,
      wr_enable_i            => px_out_request_fifo_wr_en,
      wr_data_i              => px_out_request_fifo_wr_data,
      wr_full_o              => px_out_request_fifo_wr_full,
      wr_diff_o              => px_out_request_fifo_wr_diff,
      -- Read clock domain
      rd_clk                 => sram_clk,
      rd_reset_n             => px_out_request_fifo_rd_reset_n,
      rd_enable_i            => px_out_request_fifo_rd_en,
      rd_data_o              => px_out_request_fifo_rd_data,
      rd_empty_o             => px_out_request_fifo_rd_empty,
      rd_diff_o              => px_out_request_fifo_rd_diff,
      -- Memory interface
      wea_o                  => mem_req_wr_enable,
      addra_o                => mem_req_wr_address,
      dataa_o                => mem_req_wr_data,
      enb_o                  => mem_req_rd_enable,
      addrb_o                => mem_req_rd_address,
      datab_i                => mem_req_rd_data
    );

  -- FIFO storage memory
  u_ul_generic_dpram_out_request : generic_dpram
    generic map(
      ADDR_W   => PX_FIFO_ADDR_WIDTH,
      DATA_W   => ADDR_W
    ) 
    port map(
      clk1   => dvi_out_clk,
      ce1    => '1',
      we1    => mem_req_wr_enable,
      addr1  => mem_req_wr_address,
      wdata1 => mem_req_wr_data,
      rdata1 => open,

      clk2   => sram_clk,
      ce2    => mem_req_rd_enable,
      we2    => '0',
      addr2  => mem_req_rd_address,
      wdata2 => (others => '0'),
      rdata2 => mem_req_rd_data
    );
  
  -------------------------------------------------------------------------------------------------
  -- generic async fifo - dvi out -----------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  single_color_read_pr : process(sram_clk)begin
    if(rising_edge(sram_clk))then
      r_dvi_fb_single_color_read_sram <= r_dvi_fb_single_color_read;
    end if;
  end process;

  px_out_fifo_wr_reset_n <= internal_reset_n and px_out_request_fifo_rd_empty;
  px_out_fifo_rd_reset_n <= internal_reset_n and not px_out_request_fifo_wr_en; -- and px_out_request_fifo_rd_empty;

  px_out_fifo_rd_en <= px_out_rcvd;
  px_out_data <= px_out_fifo_rd_data;
  px_out_valid <= (not px_out_fifo_rd_empty) and px_out_fifo_rd_reset_n;

  px_out_fifo_wr_en   <= sram_rvalid when read_lock = 0 else
                         '0';
--px_out_fifo_wr_data <= std_ulogic_vector(sram_rdata(PX_FIFO_DATA_WIDTH-1 downto 0));
  px_out_fifo_wr_data(ADDR_W +7 downto ADDR_W) <= std_ulogic_vector(sram_rdata(15 downto  8)) when (r_dvi_fb_single_color_read_sram = '1' and read_out_addr_offset(1 downto 0) = "01") else
                                     std_ulogic_vector(sram_rdata(23 downto 16)) when (r_dvi_fb_single_color_read_sram = '1' and read_out_addr_offset(1 downto 0) = "10") else
                                     std_ulogic_vector(sram_rdata(7 downto 0)); -- when others;
  px_out_fifo_wr_data(px_out_fifo_wr_data'length-1 downto ADDR_W +8) <= (others => '0') when r_dvi_fb_single_color_read_sram = '1'
                                                        else std_ulogic_vector(sram_rdata(PX_FIFO_DATA_WIDTH-1 downto  8));
  px_out_fifo_wr_data(ADDR_W-1 downto 0) <= std_ulogic_vector(read_out_next_addr);

  -- FIFO core
  i_afifo_core_out : afifo_core
    generic map(
      DATA_WIDTH               => PX_FIFO_DATA_WIDTH +ADDR_W,
      ADDR_WIDTH               => PX_FIFO_ADDR_WIDTH,
      FIRST_WORD_FALLS_THROUGH => true
    ) 
    port map(
      --Write clock domain
      wr_clk                 => sram_clk,
      wr_reset_n             => px_out_fifo_wr_reset_n,
      wr_enable_i            => px_out_fifo_wr_en,
      wr_data_i              => px_out_fifo_wr_data,
      wr_full_o              => px_out_fifo_wr_full,
      wr_diff_o              => px_out_fifo_wr_diff,
      -- Read clock domain
      rd_clk                 => dvi_out_clk,
      rd_reset_n             => px_out_fifo_rd_reset_n,
      rd_enable_i            => px_out_fifo_rd_en,
      rd_data_o              => px_out_fifo_rd_data,
      rd_empty_o             => px_out_fifo_rd_empty,
      rd_diff_o              => px_out_fifo_rd_diff,
      -- Memory interface
      wea_o                  => mem_o_wr_enable,
      addra_o                => mem_o_wr_address,
      dataa_o                => mem_o_wr_data,
      enb_o                  => mem_o_rd_enable,
      addrb_o                => mem_o_rd_address,
      datab_i                => mem_o_rd_data
    );

  -- FIFO storage memory
  u_ul_generic_dpram : generic_dpram
    generic map(
      ADDR_W   => PX_FIFO_ADDR_WIDTH,
      DATA_W   => PX_FIFO_DATA_WIDTH +ADDR_W
    ) 
    port map(
      clk1   => sram_clk,
      ce1    => '1',
      we1    => mem_o_wr_enable,
      addr1  => mem_o_wr_address,
      wdata1 => mem_o_wr_data,
      rdata1 => open,

      clk2   => dvi_out_clk,
      ce2    => mem_o_rd_enable,
      we2    => '0',
      addr2  => mem_o_rd_address,
      wdata2 => (others => '0'),
      rdata2 => mem_o_rd_data
    );
  

  -------------------------------------------------------------------------------------------------
  -- read and write SM for SRAM - 250 MHz ---------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  r_led(3) <= px_in_fifo_rd_empty;

  internal_reset_sram_process : process(sram_clk)begin
    if(rising_edge(sram_clk))then
      internal_sram_reset <= internal_reset;
    end if;
  end process;

  buffer_sm : process (sram_clk, internal_sram_reset)
  begin
    if(internal_sram_reset = '1' )then
      buffer_sm_state <= idle;
      sram_en <= '0';
      sram_we <= '0';
      wframe <= '0';
      rframe <= '1';
      sram_action_counter <= (others => '0');
      w_px_out_fifo_almost_full <= '0';
      w_px_out_fifo_almost_empty <= '0';
      w_px_in_fifo_almost_full <= '0';
      w_px_in_fifo_almost_empty <= '0';
      r_frame_in_ctl_1 <= (others => '0');
      r_frame_in_ctl_2 <= (others => '0');
      r_frame_in_ctl_3 <= (others => '0');
      r_dvi_cfg_frame_end_1 <= (others => '0');
      r_dvi_cfg_frame_end_2 <= (others => '0');
      r_dvi_cfg_frame_end_3 <= (others => '0');
      px_in_fifo_rd_en <= '0';
      px_out_request_fifo_rd_en <= '0';
      r_first_frame_done <= '0';
      r_max_writes <= (others => '0');
      r_led(2 downto 0) <= "111";
      read_addr <= (others => '0');
      read_out_next_addr <= (others => '0');
      read_out_next_addr(2) <= '1';
      read_out_addr_offset <= (others => '0');
      r_max_read_requests <= (others => '0');
      r_max_reads <= (others => '0');
      read_lock <= (others => '0');

    elsif(rising_edge(sram_clk))then
      buffer_sm_state <= buffer_sm_state;
      sram_en <= '0';
      sram_we <= '0';
      px_in_fifo_rd_en <= '0';
      px_out_request_fifo_rd_en <= '0';
      wframe <= wframe;
      rframe <= rframe;
      sram_action_counter <= to_unsigned(2, sram_action_counter'length);

      r_first_frame_done <= r_first_frame_done;
      r_max_writes <= (others => '0');
      r_max_reads <= c_px_max_addr;
      r_max_read_requests <= r_max_read_requests;
      read_addr <= read_addr;
      read_out_next_addr <= read_out_next_addr;
      read_out_addr_offset <= read_out_addr_offset;
      read_lock <= read_lock;

      if((sram_en and not sram_we) = '1')then
        if(r_dvi_fb_single_color_read_sram = '1')then
          if(read_addr(1 downto 0) = "00")then
            read_addr <= read_addr(read_addr'length-1 downto 2) & "01";
          elsif(read_addr(1 downto 0) = "01")then
            read_addr <= read_addr(read_addr'length-1 downto 2) & "10";
          else
            read_addr <= (read_addr(read_addr'length-1 downto 2)+1) & "00";
          end if;
        else
          read_addr <= (read_addr(read_addr'length-1 downto 2)+1) & "00";
        end if;
      end if;

      if(read_lock = 0 and sram_rvalid = '1')then
        if(r_dvi_fb_single_color_read_sram = '1')then
          if(read_out_next_addr(1 downto 0) = "00")then
            read_out_next_addr <= read_out_next_addr(read_out_next_addr'length-1 downto 2) & "01";
          elsif(read_out_next_addr(1 downto 0) = "01")then
            read_out_next_addr <= read_out_next_addr(read_out_next_addr'length-1 downto 2) & "10";
          else
            read_out_next_addr <= (read_out_next_addr(read_out_next_addr'length-1 downto 2) +1) & "00";
          end if;

          if(read_out_addr_offset = "00")then
            read_out_addr_offset <= "01";
          elsif(read_out_addr_offset = "01")then
            read_out_addr_offset <= "10";
          else
            read_out_addr_offset <= "00";
          end if;
        else
          read_out_next_addr <= (read_out_next_addr(read_out_next_addr'length-1 downto 2) +1) & "00";
          read_out_addr_offset <= "00";
        end if;
      end if;

      if(read_lock > 0)then
        read_lock <= read_lock -1;
      end if;

      if(unsigned(px_out_fifo_wr_diff) <= c_px_out_fifo_almost_empty)then
          w_px_out_fifo_almost_empty <= '1';
      else
          w_px_out_fifo_almost_empty <= '0';
      end if;

      if(unsigned(px_in_fifo_rd_diff) >= c_px_in_fifo_almost_full)then
          w_px_in_fifo_almost_full <= '1';
      else
          w_px_in_fifo_almost_full <= '0';
      end if;

      if(((r_frame_in_ctl_2(0) and not r_frame_in_ctl_3(0)) or
          (r_dvi_cfg_frame_end_2(0) and not r_dvi_cfg_frame_end_3(0))) = '1')then
        wframe <= not rframe;
      end if;

      if(((r_frame_in_ctl_2(1) and not r_frame_in_ctl_3(1)) or
          (r_dvi_cfg_frame_end_2(1) and not r_dvi_cfg_frame_end_3(1))) = '1')then
        r_first_frame_done <= '1';
        rframe <= not rframe;
      end if;


      case (buffer_sm_state) is
        when idle =>
          r_led(2 downto 0) <= "111";
          r_first_frame_done <= '0';
          if (px_in_fifo_rd_empty = '0')then
            buffer_sm_state <= sram_nops;
          end if;
          
--      read frame from sram to dvi out
        when read =>
          r_led(2 downto 0) <= "100";

          if(((w_px_in_fifo_almost_full and not w_px_out_fifo_almost_empty) or 
             not r_first_frame_done) = '1' or
             r_max_reads >= c_px_out_fifo_almost_full)then

            if(unsigned(sram_read2write_nops) > 1)then
              buffer_sm_state <= sram_nops;
            else
              r_max_writes <= unsigned(px_in_fifo_rd_diff);
              buffer_sm_state <= write;
            end if;
          else
            sram_en <= '1';
            if(r_max_read_requests > 0)then
              read_addr <= unsigned(px_out_request_fifo_rd_data(ADDR_W-1 downto 0));
              read_out_addr_offset <= unsigned(px_out_request_fifo_rd_data(1 downto 0));
              if(r_dvi_fb_single_color_read_sram = '1')then
                if(px_out_request_fifo_rd_data(1 downto 0) = "00")then
                  read_out_next_addr <= unsigned(px_out_request_fifo_rd_data(read_out_next_addr'length-1 downto 2)) & "01";
                elsif(px_out_request_fifo_rd_data(1 downto 0) = "01")then
                  read_out_next_addr <= unsigned(px_out_request_fifo_rd_data(read_out_next_addr'length-1 downto 2)) & "10";
                else
                  read_out_next_addr <= (unsigned(px_out_request_fifo_rd_data(read_out_next_addr'length-1 downto 2)) +1) & "00";
                end if;
              else
                read_out_next_addr <= (unsigned(px_out_request_fifo_rd_data(read_out_next_addr'length-1 downto 2)) +1) & "00";
              end if;
              read_lock <= unsigned(sram_read_latency);
              px_out_request_fifo_rd_en <= '1';
              r_max_read_requests <= r_max_read_requests -1;
            end if;
            r_max_reads <= r_max_reads +1;
          end if;
          

        when sram_nops =>
          if(sram_action_counter < unsigned(sram_read2write_nops))then
            sram_action_counter <= sram_action_counter + to_unsigned(1, sram_action_counter'length);
          else
            r_max_writes <= unsigned(px_in_fifo_rd_diff);
            buffer_sm_state <= write;
          end if;

--      write in frame to sram
        when write =>
          r_led(2 downto 0) <= "101";
          if((w_px_out_fifo_almost_empty and r_first_frame_done and (not w_px_in_fifo_almost_full) and (not px_out_request_fifo_rd_empty) ) = '1' or
--        if((w_px_out_fifo_almost_empty and (not w_px_in_fifo_almost_full) and (not px_out_request_fifo_rd_empty) ) = '1' or
             r_max_writes = 0)then
            r_max_reads <= unsigned(px_out_fifo_wr_diff);
            r_max_read_requests <= unsigned(px_out_request_fifo_rd_diff);
            buffer_sm_state <= read;
          else
            px_in_fifo_rd_en <= '1';
            sram_en <= '1';
            sram_we <= '1';
            r_max_writes <= r_max_writes -1;

          end if;


          
        when others =>
          buffer_sm_state <= idle;
      end case;
        
        r_freeze_frame_1 <= r_dvi_fb_en(1);
        r_freeze_frame_2 <= r_freeze_frame_1;

        r_frame_in_ctl_1 <= frame_in_ctl;
        r_frame_in_ctl_2(0) <= r_frame_in_ctl_1(0);
        r_frame_in_ctl_2(1) <= (not r_freeze_frame_2) and r_frame_in_ctl_1(1);
        r_frame_in_ctl_3 <= r_frame_in_ctl_2;

        r_dvi_cfg_frame_end_1 <= r_dvi_cfg_frame_end;
        r_dvi_cfg_frame_end_2 <= r_dvi_cfg_frame_end_1;
        r_dvi_cfg_frame_end_3 <= r_dvi_cfg_frame_end_2;
    end if;
  end process;

  -------------------------------------------------------------------------------------------------
  -- sram controller ------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------
  
  single_color_write_pr : process(sram_clk)begin
    if(rising_edge(sram_clk))then
      r_dvi_fb_single_color_write_sram <= r_dvi_fb_single_color_write;
    end if;
  end process;

  sram_wdata_selection : process(px_in_fifo_rd_data, r_dvi_fb_single_color_write_sram)
  begin
    sram_wdata <= (others => '0');
    if(r_dvi_fb_single_color_write_sram = '1')then
      sram_wdata(15 downto 0) <= std_logic_vector(px_in_fifo_rd_data(7 downto 0)) & std_logic_vector(px_in_fifo_rd_data(7 downto 0));
      sram_wdata(DQ_PINS+15 downto DQ_PINS) <= std_logic_vector(px_in_fifo_rd_data(7 downto 0)) & std_logic_vector(px_in_fifo_rd_data(7 downto 0));
    else
      sram_wdata(PX_FIFO_DATA_WIDTH-1 downto 0) <= std_logic_vector(px_in_fifo_rd_data(px_in_fifo_rd_data'length-1 downto ADDR_W));
    end if;
  end process;
  sram_addr <= (std_logic(rframe) & std_logic_vector(read_addr(read_addr'length-1 downto 2))) when (sram_en and not sram_we) = '1' 
               else (std_logic(wframe) & std_logic_vector(px_in_fifo_rd_data(ADDR_W-1 downto 2)));
  sram_bwe <= "0001" when r_dvi_fb_single_color_write_sram = '1' and px_in_fifo_rd_data(1 downto 0) = "00" else
              "0010" when r_dvi_fb_single_color_write_sram = '1' and px_in_fifo_rd_data(1 downto 0) = "01" else
              "0100" when r_dvi_fb_single_color_write_sram = '1' and px_in_fifo_rd_data(1 downto 0) = "10" else
              "1111";

  sram_rst : process(sram_clk)begin
    if(rising_edge(sram_clk))then
      sram_reset <= reset;
    end if;
  end process;

  ssram_ctrl : ssram_ctrl_top -- ProDesign ProFPGA SSRAM Controller
      generic map(
          PERFORMANCE_MODE => "SPEED",              -- "LOW_LATENCY" or "SPEED"
          FPGA_TECH        => "XV7S",               -- "XV7S", "XVUS"
          CLK_PERIOD_PS    => 4000,                 -- (fastest) period of memory clock
          STARTUP_TIME_US  => 20,                   -- time to PLL lock
          USE_IDELAY_CTRL  => "FALSE",              -- "TRUE" if IDELAY_CTRL should be instantiated, "FALSE" otherwise
          ADDR_W           => ADDR_W,               -- width of the address bus
          DQ_PINS          => DQ_PINS,              -- number of DQ pins
          GROUPS           => GROUPS                -- number of byte write enable pins
      )
      port map(
          -- clock and reset signals
          clk             => sram_clk,              -- clock for memory and internal interface
          reset           => sram_reset,                 -- reset synchronous to clk
          clk200          => clk200,                -- 200MHz clock required if USE_IDELAY_CTRL="TRUE"
          clk200_reset    => reset,                 -- reset synchronous to clk200
          -- management interface
          ready           => sram_ready,            -- becomes high if initialization and read leveling is done
          read_latency    => sram_read_latency(3 downto 0),     -- read latency value (valid of ready is high)
          read2write_nops => sram_read2write_nops,  -- number of NOP cycles between transition from read to write operation
          windows_size    => open,                  -- read data windows size determined during read leveling (in TAPs)
          windows_start   => open,                  -- read data window start TAP
          -- internal memory interface
          addr            => sram_addr,             -- memory address
          en              => sram_en,               -- enable
          we              => sram_we,               -- write enable
          bwe             => sram_bwe,                  -- byte write enable
          wdata           => sram_wdata,            -- write data
          rdata           => sram_rdata,            -- read data
          rvalid          => sram_rvalid,           -- read data valid
          -- external memory interface
          sram_k_p        => sram_k_p,              -- SSRAM clock
          sram_k_n        => sram_k_n,              -- SSRAM clock (negated)
          sram_a          => sram_a,                -- SSRAM address
          sram_dq         => sram_dq,               -- SSRAM data
          sram_bws_n      => sram_bws_n,            -- SSRAM byte write strobe
          sram_rnw        => sram_rnw,              -- SSRAM read/nwrite enable
          sram_ld_n       => sram_ld_n              -- SSRAM address load
      );

end architecture rtl;

  
