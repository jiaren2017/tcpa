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
-- Create Date:    10:47:40 10/25/05
-- Design Name:    
-- Module Name:    connection - Behavioral
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

entity connection is
	generic(
		-- synopsys translate_off
		-- cadence translate_off

		INSTANCE_NAME     : string                                         := "?";
		-- synopsys translate_on
		-- cadence translate_on		
		INPUT_DATA_WIDTH  : integer range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH;
		OUTPUT_DATA_WIDTH : integer range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH
	);

	port(
		input_signal  : in  std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
		output_signal : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
	);

end connection;

architecture Behavioral of connection is
	signal intermediate_signal : std_logic_vector(INPUT_DATA_WIDTH + OUTPUT_DATA_WIDTH - 1 downto 0);

begin
	intermediate_signal(INPUT_DATA_WIDTH - 1 downto 0) <= input_signal;

	output_signal(OUTPUT_DATA_WIDTH - 1 downto 0) <= intermediate_signal(OUTPUT_DATA_WIDTH - 1 downto 0);

end Behavioral;
