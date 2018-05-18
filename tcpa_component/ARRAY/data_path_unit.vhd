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
-- Engineer:
--
-- Create Date:    13:16:28 12/28/05
-- Design Name:    
-- Module Name:    data_path_unit - Behavioral
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

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_path_unit is
	generic(
		-- cadence translate_off		
		INSTANCE_NAME : string;
		-- cadence translate_on			
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH
	);

	port(
		dpu_enable : in  std_logic;
		operand    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		result     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);

end data_path_unit;

architecture Behavioral of data_path_unit is
begin
	assign : process(operand, dpu_enable)
	begin
		if dpu_enable = '1' then
			result <= operand;

		else
			if NOT OPERAND_ISOLATION then
				result <= (others => '0');

			end if;

		end if;

	end process assign;

end Behavioral;
