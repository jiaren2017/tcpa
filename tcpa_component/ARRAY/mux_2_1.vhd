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
-- Create Date:    15:28:15 10/14/05
-- Design Name:    
-- Module Name:    mux_2_1 - Behavioral
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

entity mux_2_1 is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME : string;
		-- cadence translate_on		
		DATA_WIDTH    : positive range 1 to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH
	);
	port(
		data_inputs : in  std_logic_vector(2 * DATA_WIDTH - 1 downto 0);
		sel         : in  std_logic;
		output      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end mux_2_1;

architecture Behavioral of mux_2_1 is
	component wppe_multiplexer is
		generic(
			-- synopsys traslate_off	
			-- cadence translate_off
			INSTANCE_NAME     : string;
			-- cadence translate_on		
			INPUT_DATA_WIDTH  : positive range 1 to 64 := 16;
			OUTPUT_DATA_WIDTH : positive range 1 to 64 := 16;
			SEL_WIDTH         : positive range 1 to 16 := 2;
			NUM_OF_INPUTS     : positive range 1 to 64 := 4
		);

		port(
			data_inputs : in  std_logic_vector(INPUT_DATA_WIDTH * NUM_OF_INPUTS - 1 downto 0);
			sel         : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			output      : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
		);
	end component;

begin
	internal_mux : wppe_multiplexer
		generic map(
			-- synopsys traslate_off			
			-- cadence translate_off			
			INSTANCE_NAME     => INSTANCE_NAME & "/internal_mux",
			-- cadence translate_on		
			-- synopsys traslate_on	
			INPUT_DATA_WIDTH  => DATA_WIDTH,
			OUTPUT_DATA_WIDTH => DATA_WIDTH,
			SEL_WIDTH         => 1,
			NUM_OF_INPUTS     => 2
		)
		port map(
			data_inputs => data_inputs,
			sel(0)      => sel,
			output      => output
		);

end Behavioral;
