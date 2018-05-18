---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  
-- Project Name:  
--
-- Engineer:     
-- Create Date:   
-- Description:  
--
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ericles Sousa
--
-- Create Date:    11:06:00 09/13/05
-- Design Name:    
-- Module Name:    instr_memory - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity instr_memory is
	generic(
		--Ericles:
		-- cadence translate_off
		N             : integer                                     := 0;
		M             : integer                                     := 0;
		INSTANCE_NAME : string                                      := "memory";
		-- cadence translate_on				
		MEM_SIZE      : positive range MIN_MEM_SIZE to MAX_MEM_SIZE := 128; --CUR_DEFAULT_MEM_SIZE;
		DATA_WIDTH    : positive range 1 to 1024                    := 128;
		ADDR_WIDTH    : positive range 1 to MAX_ADDR_WIDTH          := 4 --CUR_DEFAULT_ADDR_WIDTH
	);

	port(
		clk   : in  std_logic;
		we    : in  std_logic;
		addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		di    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		d_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);

end instr_memory;

architecture syn of instr_memory is
	--  The following function calculates the address width based on specified RAM depth
	function clogb2( depth : natural) return integer is
	variable temp    : integer := depth;
	variable ret_val : integer := 0; 
	begin					
	    while temp > 1 loop
	        ret_val := ret_val + 1;
	        temp    := temp / 2;     
	    end loop;
		
	    return ret_val;
	end function;

	--type t_ram is array (MEM_SIZE downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	-- Ensure that the memory depth is a power of 2. Then, this memory will be completly mapped as block RAM
	--type t_ram is array (2**(clogb2(MEM_SIZE))-1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type t_ram is array (2*MEM_SIZE-1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal ram : t_ram;

begin
	process(clk)
	begin
		if clk'event and clk = '1' then
			if we = '1' then            -- write enable
				ram(to_integer(unsigned(addr))) <= di;
			end if;			
			d_out <= ram(to_integer(unsigned(addr)));
		end if;
	end process;

end syn;

