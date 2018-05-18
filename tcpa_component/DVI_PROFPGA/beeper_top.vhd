-- =============================================================================
--!  @project      beeper apb top module
-- =============================================================================
--!  @file         beeper_top.vhd
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
library dvi_profpga_lib;
    use dvi_profpga_lib.dvi_profpga.all;   use unisim.vcomponents.all;

entity beeper_top is
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
end entity beeper_top;

architecture rtl of beeper_top is

  signal w_beeper_cfg_addr  : std_ulogic_vector(0 downto 0);
  signal w_beeper_cfg_wdata : std_ulogic_vector(max(COUNTER_WIDTH, DIVIDER_WIDTH)-1 downto 0);
  signal w_beeper_cfg_rdata : std_ulogic_vector(max(COUNTER_WIDTH, DIVIDER_WIDTH)-1 downto 0);
  signal w_beeper_cfg_we    : std_ulogic;
  signal w_beeper_cfg_en    : std_ulogic;

begin

  beeper_i : beeper 
  generic map(
    COUNTER_WIDTH => COUNTER_WIDTH,
    DIVIDER_WIDTH => DIVIDER_WIDTH
  )
  port map(
    beeper_clk => beeper_clk,
    cfg_clk    => amba_clk, 
    reset => reset,

    beeper_cfg_wdata => w_beeper_cfg_wdata,
    beeper_cfg_rdata => w_beeper_cfg_rdata,
    beeper_cfg_addr  => w_beeper_cfg_addr,
    beeper_cfg_we    => w_beeper_cfg_we,
    beeper_cfg_en    => w_beeper_cfg_en,

    beeper_out => beeper_out
  );

  apb_beeper : dvi_apb_interface 
  generic map(
    pindex               => pindex,
    paddr                => paddr,
    pmask                => 16#fff#,
    addr_w               => 1,
    data_w               => max(COUNTER_WIDTH, DIVIDER_WIDTH),
    CONTRIBUTOR_ID       => 16#CC#,
    DEVICE_ID            => 16#003#
  )
  port map(
    apbi => apbi,
    apbo => apbo,

    dvi_cfg_addr  => w_beeper_cfg_addr,
    dvi_cfg_wdata => w_beeper_cfg_wdata,
    dvi_cfg_rdata => w_beeper_cfg_rdata,
    dvi_cfg_we    => w_beeper_cfg_we,
    dvi_cfg_en    => w_beeper_cfg_en
  );

end architecture rtl;

  
