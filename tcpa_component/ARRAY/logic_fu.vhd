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
-- Company: 	Universitaet Erlangen-Nuernberg 
--						Informatik Lehrstuhl 12 
--						Hardware/Software Codesign

-- Engineer:	Dmitrij Kissler
--
-- Create Date:    11:09:56 09/13/05
-- Design Name:    
-- Module Name:    logic_fu - Behavioral
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
library IEEE;
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

entity logic_fu is
	generic(
		-- cadence translate_off		
		INSTANCE_NAME : string;
		-- cadence translate_on			
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH);

	port(
		first_operand  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		second_operand : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		logic_enable   : in  std_logic_vector(0 downto 0);
		logic_select   : in  std_logic_vector(1 downto 0);
		result         : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		flags          : out std_logic_vector(MAX_NUM_FLAGS - 1 downto 0)
	);

end logic_fu;

architecture Behavioral of logic_fu is
	signal internal_first_operand  : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal internal_second_operand : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin
	flags <= (others => '0');

	TEST_MACROMODELING : IF MACROMODELING GENERATE
		ENABLE_GENERATION : FOR i in 0 to DATA_WIDTH - 1 GENERATE
			internal_first_operand(i)  <= first_operand(i) AND logic_enable(0);
			internal_second_operand(i) <= second_operand(i) AND logic_enable(0);

		END GENERATE ENABLE_GENERATION;

	END GENERATE TEST_MACROMODELING;

	TEST_FALSE_MACROMODELING : IF NOT (MACROMODELING) GENERATE
		DISABLE_GENERATION : FOR i in 0 to DATA_WIDTH - 1 GENERATE
			internal_first_operand(i)  <= first_operand(i);
			internal_second_operand(i) <= second_operand(i);

		END GENERATE DISABLE_GENERATION;

	END GENERATE TEST_FALSE_MACROMODELING;

	logic_p : process(internal_first_operand, internal_second_operand, logic_select)
	begin
		case logic_select is
			when "00" =>
				result <= internal_first_operand AND internal_second_operand;

			when "01" =>
				result <= internal_first_operand OR internal_second_operand;

			when "10" =>
				result <= internal_first_operand XOR internal_second_operand;

			when "11" =>
				result <= NOT internal_first_operand;

			when others =>
				result <= internal_first_operand;

		end case;

	end process logic_p;

end Behavioral;
