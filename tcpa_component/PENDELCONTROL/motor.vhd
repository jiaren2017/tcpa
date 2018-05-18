--
-- Description:
--:
-- Extension of file file motor_initial_version.
-- 18.02.2016. added 2 new registers. with the form of local variable within prcess, still working on with two different precesses to handle Reading and Writing
-- 
-- 
library ieee; 
use ieee.std_logic_1164.all;
library grlib; 
use grlib.amba.all; use grlib.devices.all;
library gaisler; 
use gaisler.misc.all;

entity motor is
  generic (
	pindex : integer := 0;
	paddr : integer := 0;
	pmask : integer := 16#fff#);
  port (
	rst : in std_ulogic;
	clk : in std_ulogic;
	apbi : in apb_slv_in_type;
	apbo : out apb_slv_out_type;
	led_blink : out std_logic_vector(4 downto 0));
end;


architecture rtl of motor is
    constant REVISION : integer := 0;
    
    constant PCONFIG : apb_config_type := (
	0 => ahb_device_reg (VENDOR_CONTRIB, CONTRIB_CORE1, 0, REVISION, 0),
	1 => apb_iobar(paddr, pmask));
    
    type registers is record
	    reg : std_logic_vector(31 downto 0);
    end record;
    
    signal r, rin : registers;
   
   begin
    comb : process(rst, r, apbi)
	        variable readdata : std_logic_vector(31 downto 0);
	        variable reg0, reg1 : registers; -- reg0 for Writing,reg1 for Reading
            begin
	        reg1 := r;

	        -- write registers
	        if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
	              case apbi.paddr(4 downto 2) is
		          when "000" => reg0.reg := apbi.pwdata; -- write data from apbo write bus
		          when others => null;
	              end case;
	        end if;
		
	        -- read register
	        readdata := (others => '0');
	        case apbi.paddr(4 downto 2) is
	              when "001" => readdata := reg1.reg(31 downto 0);
	              when others => null;
	        end case;
	
	        -- system reset
	        if rst = '0' then 
	            reg0.reg := (others => '0');
	            reg1.reg := (others => '0');
	            readdata := (others => '0');
	        end if;
	
	        rin <= reg0;
	        apbo.prdata <= readdata; -- drive apb read bus
	        led_blink <= readdata(4 downto 0);
    end process;
    
    apbo.pirq <= (others => '0');
    apbo.pindex <= pindex;
    apbo.pconfig <= PCONFIG;
    -- No IRQ
    -- VHDL generic
    -- Config constant
    -- registers
    regs : process(clk)
    begin
	  if rising_edge(clk) then 
	    r <= rin; 
	  end if;
    end process;
    -- boot message
    -- pragma translate_off
--     bootmsg : report_version
-- 	  generic map ("apb_example" & tost(pindex) &": Example core rev " & tost(REVISION));
    -- pragma translate_on
end;
