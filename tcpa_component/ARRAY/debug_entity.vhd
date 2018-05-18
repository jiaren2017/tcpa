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
-- Create Date:    16:54:14 10/30/05
-- Design Name:    
-- Module Name:    debug_entity - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library wppa_instance_v1_01_a;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debug_entity is
	generic(
		-- cadence translate_off		
		INSTANCE_NAME : string;

		-- cadence translate_on		

		MS_MATRIX     : t_multi_source_info_matrix;
		BEGIN_DATA    : natural range 0 to 512 := 2;
		END_DATA      : natural range 0 to 512 := 2;
		BEGIN_SEL     : natural range 0 to 512 := 2;
		END_SEL       : natural range 0 to 512 := 2;
		NAME          : string
	);

	port(
		clk, rst : in std_logic
	);

end debug_entity;

architecture Behavioral of debug_entity is
	signal clock, reset : std_logic;

begin
	clock <= clk;
	reset <= rst;

--	MS_MATRIX = (
--	(5,   2,  7,  1,  1,  2,  1,  1,  1,  1), 
--	
--	(16, 16, 16, 16, 16, 16, 16, 16, 16, 16), 
--	(3, 1, 3, 1, 1, 1, 1, 1, 1, 1), 
--
--	(5,    2,   7,   1,  1,  2,  1,  1,  1,  1), 	
--	(0,   80,   0, 112,  0, 16,  0, 16,  0, 16), 
--	(79, 111, 111, 127, 15, 47, 15, 31, 15, 31), 
--	
--	(0, 3, 4, 7, 8, 9, 10, 11, 12, 13), 
--	(2, 3, 6, 7, 8, 9, 10, 11, 12, 13))


end Behavioral;
