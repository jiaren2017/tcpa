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
-- Module Name:    control_path_unit - Behavioral
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_path_unit is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME  : string;
		-- cadence translate_on			
		CTRL_REG_WIDTH : positive range 1 to MAX_CTRL_REG_WIDTH := CUR_DEFAULT_CTRL_REG_WIDTH
	);

	port(
		cpu_enable : in  std_logic;
		operand    : in  std_logic_vector(CTRL_REG_WIDTH - 1 downto 0);
		result     : out std_logic_vector(CTRL_REG_WIDTH - 1 downto 0)
	);

end control_path_unit;

architecture Behavioral of control_path_unit is
begin
	assign : process(operand, cpu_enable)
	begin
		if cpu_enable = '1' then
			result <= operand;

		else
			result <= (others => '0');

		end if;

	end process assign;

end Behavioral;
