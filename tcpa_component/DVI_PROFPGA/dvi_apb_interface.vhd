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
library grlib;
    use grlib.amba.all;
    use grlib.stdlib.all;
    use grlib.devices.all;
library unisim;
    use unisim.vcomponents.all;
entity dvi_apb_interface is
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
end entity dvi_apb_interface;

architecture rtl of dvi_apb_interface is
  constant REVISION : integer := 0;
  
  constant pconfig : apb_config_type := (
    0 => ahb_device_reg (CONTRIBUTOR_ID, DEVICE_ID, 0, REVISION, 0),
    1 => apb_iobar(paddr, pmask));

begin
  dvi_cfg_addr  <= std_ulogic_vector(apbi.paddr(dvi_cfg_addr'length+1 downto 2)); 
  dvi_cfg_wdata <= std_ulogic_vector(apbi.pwdata(dvi_cfg_wdata'range)); 
  dvi_cfg_we    <= apbi.pwrite; 
  dvi_cfg_en    <= apbi.psel(pindex) and apbi.penable; 

  prdata : process(dvi_cfg_rdata)
  begin
    apbo.prdata <= (others => '0');
    apbo.prdata(dvi_cfg_rdata'range) <= std_logic_vector(dvi_cfg_rdata);
  end process;
  apbo.pirq <= (others => '0');
  apbo.pconfig <= pconfig;
  apbo.pindex <= pindex;

end architecture rtl;

