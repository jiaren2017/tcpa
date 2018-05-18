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

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:02:22 08/09/2014 
-- Design Name: 
-- Module Name:    general_Multiplexer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity general_Multiplexer is
	generic(
		--###########################################################################
		-- general_Multiplexer parameters, do not add to or delete
		--###########################################################################
		SEL_WIDTH  : integer range 0 to 32 := 8;
		DATA_WIDTH : integer range 0 to 32 := 32
	--###########################################################################		
	);
	port(
		select_val   : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
		data_input  : in  std_logic_vector(SEL_WIDTH * DATA_WIDTH - 1 downto 0);
		data_output : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end general_Multiplexer;

architecture Behavioral of general_Multiplexer is
	function general_multiplexer_function(
		---------------------------------------------------------
		-- Current number of bits to be tested
		-- in the current run of the function
		cur_sel_width : in positive range 1 to 16;
		---------------------------------------------------------
		-- Values of the select bits to be tested  		 
		sel           : in std_logic_vector(SEL_WIDTH - 1 downto 0);
		---------------------------------------------------------
		-- The values of all input signals were put
		-- together to one big std_logic_vector with the
		-- following layout: 
		-- | input_x | input_x-1 | ... | input_2 | input_1 |
		-- |              ...                      2  1  0 |
		data_inputs   : in std_logic_vector(DATA_WIDTH * SEL_WIDTH - 1 downto 0)
		)
		-- The right branch target is returned						
		return std_logic_vector;

	function general_multiplexer_function(
		cur_sel_width : in positive range 1 to 16;
		sel           : in std_logic_vector(SEL_WIDTH - 1 downto 0);
		data_inputs   : in std_logic_vector(DATA_WIDTH * SEL_WIDTH - 1 downto 0)
		) return std_logic_vector is
		variable target : std_logic_vector(DATA_WIDTH - 1 downto 0);

	begin
		if cur_sel_width = 1 then
			if sel(0) = '0' then
				target(DATA_WIDTH - 1 downto 0) := (others => '0');
			else
				target(DATA_WIDTH - 1 downto 0) := data_inputs(DATA_WIDTH - 1 downto 0);
			end if;
		else
			if (sel(cur_sel_width - 1) = '0') then
				target(DATA_WIDTH - 1 downto 0) := general_multiplexer_function(cur_sel_width - 1, sel, data_inputs);
			else
				target(DATA_WIDTH - 1 downto 0) := data_inputs(cur_sel_width * DATA_WIDTH - 1 downto (cur_sel_width - 1) * DATA_WIDTH);
			end if;
		end if;
		return target;
	end general_multiplexer_function;

	signal tmp_data_input : std_logic_vector(SEL_WIDTH * DATA_WIDTH - 1 downto 0);
begin
	tmp_data_input <= data_input;

	OUTPUT_PROC : process(select_val, tmp_data_input) is
	begin
		data_output <= general_multiplexer_function(SEL_WIDTH, select_val, tmp_data_input);
	end process OUTPUT_PROC;
end Behavioral;

