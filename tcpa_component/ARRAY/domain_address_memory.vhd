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


library IEEE;
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

----library wppa_instance_v1_00_a;
----use wppa_instance_v1_00_a.all;
----
----use wppa_instance_v1_00_a.WPPE_LIB.ALL;
----use wppa_instance_v1_00_a.DEFAULT_LIB.ALL;

--use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
--use wppa_instance_v1_01_a.ARRAY_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity domain_address_memory is
	generic(

		-- cadence translate_off	
		INSTANCE_NAME : string   := "?";
		-- cadence translate_on

		MEM_SIZE      : positive := CUR_DEFAULT_MAX_DOMAIN_NUM;
		DATA_WIDTH    : positive := CUR_DEFAULT_SOURCE_ADDR_WIDTH;
		ADDR_WIDTH    : positive := CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH
	);

	port(
		clk   : in  std_logic;
		we    : in  std_logic;
		rst   : in  std_logic;
		addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		d_in  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		d_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);

end domain_address_memory;

architecture Behavioral of domain_address_memory is

	--type		t_ram is array (MEM_SIZE -1 downto 0) of std_logic_vector(DATA_WIDTH -1 downto 0);
	type t_ram is array (0 to MEM_SIZE - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	CONSTANT NULL_VECTOR : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

	signal ram : t_ram;
--:= (
--"0000000000100000000011100000000XXXXXXXXXXXXXXXX00010110111000000001010011000000000000101100111001000110111000000100010011000000",
--"0000000000100000000011100000000XXXXXXXXXXXXXXXX000001110000000000010111000000000000000101001000XXXXXXXXXXXXXXXX0100010101000000",
--"0000000000100000000011100000000XXXXXXXXXXXXXXXX000001110110000000000101010000000000000101010110XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
--"0000000000000000001000000001010XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01001000001000000100001000000000",
--"0000000000000000001000000001010XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX00001000000000100000001000000010",
--"0000000000000000000000000000000XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
--"0000000000000000000000000000000XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
--"0000000000000000000000000000000XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
--);
--

--CONSTANT actual_addr_width :positive range 1 to MAX_ADDR_WIDTH := log_width(MEM_SIZE);


begin
	process(clk, addr, we, d_in, ram)
	begin
		if clk'event and clk = '1' then

			--				if rst = '1' then
			--
			--								
			--					 ram <= (others => (others => '0'));
			--	  			
			--				else

			if we = '1' then            -- write enable


				ram(conv_integer(addr(ADDR_WIDTH - 1 downto 0))) <= d_in;
			--ram(conv_integer(addr(actual_addr_width - 1 downto 0))) <= d_in;

			--			end if;
			--			
			--			end if;

			-- NOT : elsif rst = '1' ... !!!!!
			-- BUT : if rst = '1' .... !!!!
			--
			--			if rst = '1' then -- optional reset
			--			  
			--			  	ram <= (others => (others => '1'));
			--	
			else
				d_out <= ram(conv_integer(addr(ADDR_WIDTH - 1 downto 0))) OR NULL_VECTOR;
			--d_out <= ram(conv_integer(addr(actual_addr_width - 1 downto 0))) ;

			end if;

		end if;
	--end if;		

	end process;

end Behavioral;
