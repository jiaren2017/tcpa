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
-- Create Date:    11:35:56 09/13/05
-- Design Name:    
-- Module Name:    wppe_multiplexer - Behavioral
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


use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;

entity wppe_multiplexer is
	generic(

		-- cadence translate_off
		INSTANCE_NAME     : string                 := "?";
		-- cadence translate_on		

		INPUT_DATA_WIDTH  : positive range 1 to 64 := 16;
		OUTPUT_DATA_WIDTH : positive range 1 to 64 := 16;
		SEL_WIDTH         : positive range 1 to 32 := 1;
		NUM_OF_FUS        : positive range 1 to 32 := 1;
		BRANCH_FLAG_INDEX : positive range 1 to 32 := 1;
		NUM_OF_INPUTS     : positive range 1 to 64 := 2
	);

	port(
		data_inputs : in  std_logic_vector(INPUT_DATA_WIDTH * NUM_OF_INPUTS - 1 downto 0);
		sel         : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
		output      : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
	);

end wppe_multiplexer;

architecture Behavioral of wppe_multiplexer is
	signal internal_data_inputs : std_logic_vector((INPUT_DATA_WIDTH * 2 ** SEL_WIDTH) - 1 downto 0);

	function general_multiplexer_function(
		---------------------------------------------------------
		-- Current number of bits to be tested
		-- in the current run of the function
		cur_sel_width  : in positive range 1 to 16;
		---------------------------------------------------------
		-- Values of the select bits to be tested  		 
		sel            : in std_logic_vector(SEL_WIDTH - 1 downto 0);
		---------------------------------------------------------
		-- Which input, from the (2^cur_sel_width) 
		-- possible/given, should be chosen,
		-- if the select signal has the right value
		current_target : in positive range 1 to 256;
		---------------------------------------------------------
		-- The values of all input signals were put
		-- together to one big std_logic_vector with the
		-- following layout: 
		-- | input_x | input_x-1 | ... | input_2 | input_1 |
		-- |              ...                      2  1  0 |
		data_inputs    : in std_logic_vector(INPUT_DATA_WIDTH * (2 ** SEL_WIDTH) - 1 downto 0)
		)
		-- The right branch target is returned						
		return std_logic_vector;

	function general_multiplexer_function(
		---------------------------------------------------------
		-- Current number of bits to be tested
		-- in the current run of the function
		cur_sel_width  : in positive range 1 to 16;
		---------------------------------------------------------
		-- Values of the flags to be tested  		 
		sel            : in std_logic_vector(SEL_WIDTH - 1 downto 0);
		---------------------------------------------------------									 
		-- Which input, from the (2^cur_sel_width) 
		-- possible/given, should be chosen,
		-- if the select signal has the righ value
		current_target : in positive range 1 to 256;
		---------------------------------------------------------
		-- The values of all data inputs were put
		-- together to one big std_logic_vector with the
		-- following layout: 
		-- | input_x | input_x-1 | ... | input_2 | input_1 |
		-- |              ...                      2  1  0 |
		data_inputs    : in std_logic_vector(INPUT_DATA_WIDTH * (2 ** SEL_WIDTH) - 1 downto 0)
		)
		-- The right branch target is returned						
		return std_logic_vector is
		variable target : std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);

	begin
		if cur_sel_width = 1 then
			if sel(0) = '0' then
				target(INPUT_DATA_WIDTH - 1 downto 0) := data_inputs(INPUT_DATA_WIDTH * current_target - 1 downto INPUT_DATA_WIDTH * (current_target - 1));
			--else
			elsif sel(0) = '1' then
				target(INPUT_DATA_WIDTH - 1 downto 0) := data_inputs(INPUT_DATA_WIDTH * (current_target + 1) - 1 downto INPUT_DATA_WIDTH * current_target);
			end if;

		else
			if (sel(cur_sel_width - 1) = '0') then
				target(INPUT_DATA_WIDTH - 1 downto 0) := general_multiplexer_function(cur_sel_width - 1, sel, current_target, data_inputs);

			else
				target(INPUT_DATA_WIDTH - 1 downto 0) := general_multiplexer_function(cur_sel_width - 1, sel, current_target + 2 ** (cur_sel_width - 1), data_inputs);

			end if;

		end if;

		return target;

	end general_multiplexer_function;

begin

	--	internal_data_inputs((INPUT_DATA_WIDTH*2**SEL_WIDTH) -1 downto INPUT_DATA_WIDTH*NUM_OF_INPUTS) <= (others => '0');
	internal_data_inputs((INPUT_DATA_WIDTH * 2 ** SEL_WIDTH) - 1 downto INPUT_DATA_WIDTH * NUM_OF_INPUTS) <= (others=>'0');
	internal_data_inputs(INPUT_DATA_WIDTH * NUM_OF_INPUTS - 1 downto 0) <= data_inputs;

	ASSIGN_OUTPUT : process(data_inputs, sel, internal_data_inputs)
	begin
		IF NUM_OF_INPUTS > 1 THEN
								--general_multiplexer_function(cur_sel_width, sel, current_target, data_inputs)	
			--output(INPUT_DATA_WIDTH - 1 downto 0) <= general_multiplexer_function(SEL_WIDTH, sel, 1, internal_data_inputs);
			--Ericles: Added support to decode multiple flags from the same type of functional unit. 
			--Previously, only flags from functional unit index 0 were evaluated
			output(INPUT_DATA_WIDTH - 1 downto 0) <= general_multiplexer_function(SEL_WIDTH, sel, BRANCH_FLAG_INDEX, internal_data_inputs);
		ELSE
			output(INPUT_DATA_WIDTH - 1 downto 0) <= internal_data_inputs(INPUT_DATA_WIDTH - 1 downto 0);

		END IF;

	END PROCESS ASSIGN_OUTPUT;

end Behavioral;



