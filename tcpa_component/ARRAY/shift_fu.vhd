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
-- Create Date:    11:10:11 09/13/05
-- Design Name:    
-- Module Name:    shift_fu - Behavioral
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

entity shift_fu is
	generic(
		-- cadence translate_off		
		INSTANCE_NAME : string;
		-- cadence translate_on				
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH);

	port(
		flags          : out std_logic_vector(MAX_NUM_FLAGS - 1 downto 0);
		first_operand  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		second_operand : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		shift_select   : in  std_logic_vector(1 downto 0);
		shift_enable   : in  std_logic_vector(0 downto 0);
		result         : out std_logic_vector(DATA_WIDTH - 1 downto 0)

	--				first_operand		:in  unsigned(DATA_WIDTH -1 downto 0);
	--				second_operand 	:in  unsigned(DATA_WIDTH -1 downto 0);
	--				shift_select		:in  std_logic_vector(2 downto 0);
	--				shift_enable		:in  std_logic_vector(0 downto 0);
	--				result				:out unsigned(DATA_WIDTH -1 downto 0)
	);

end shift_fu;

architecture Behavioral of shift_fu is
	signal internal_first_operand  : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal internal_second_operand : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin
	TEST_MACROMODELING : IF MACROMODELING GENERATE
		ENABLE_GENERATION : FOR i in 0 to DATA_WIDTH - 1 GENERATE
			internal_first_operand(i)  <= first_operand(i) AND shift_enable(0);
			internal_second_operand(i) <= second_operand(i) AND shift_enable(0);

		END GENERATE ENABLE_GENERATION;

	END GENERATE TEST_MACROMODELING;

	TEST_FALSE_MACROMODELING : IF NOT (MACROMODELING) GENERATE
		DISABLE_GENERATION : FOR i in 0 to DATA_WIDTH - 1 GENERATE
			internal_first_operand(i)  <= first_operand(i);
			internal_second_operand(i) <= second_operand(i);

		END GENERATE DISABLE_GENERATION;

	END GENERATE TEST_FALSE_MACROMODELING;

	shifting_p : process(internal_first_operand, internal_second_operand, shift_select)
		variable help              : std_logic_vector(DATA_WIDTH * 2 - 1 downto 0);
		variable mask_for_division : std_logic_vector(63 downto 0) := x"FFFFFFFFFFFFFFFF";
		variable shift_number      : integer range 0 to DATA_WIDTH;

	begin
		shift_number := conv_integer(internal_second_operand(log_width(DATA_WIDTH) - 1 downto 0));

		case shift_select is
			when "00" =>                -- LOGICAL SHIFT LEFT  ==> SHL/SHL_I

				help := (others => '0');

				help(DATA_WIDTH + shift_number - 1 downto shift_number) := internal_first_operand;

				result <= help(DATA_WIDTH - 1 downto 0);

			when "01" =>                -- LOGICAL SHIFT RIGHT	 ==> SHR/SHR_I

				help := (others => '0');

				--Ericles, inserting "if" and "else" condition to support negative division (shift right), 
				--it was tested on Modelsim and it is working fine!
				--The solution is based on 2's complement
				--if(internal_first_operand(31) = '1') then
				if (internal_first_operand(CUR_DEFAULT_DATA_WIDTH - 1) = '1') then
					help(DATA_WIDTH - 1 downto 0) := not (internal_first_operand - 1);
					help(DATA_WIDTH - 1 downto 0) := help(DATA_WIDTH + shift_number - 1 downto shift_number);
					help(DATA_WIDTH - 1 downto 0) := (not (help(DATA_WIDTH - 1 downto 0)) + 1);
					result                        <= help(DATA_WIDTH - 1 downto 0);
				else
					help(DATA_WIDTH - 1 downto 0) := internal_first_operand;
					result                        <= help(DATA_WIDTH + shift_number - 1 downto shift_number);
				end if;

			when "10" =>                -- ARITHMETICAL SHIFT RIGHT ==> ASHR/ASHR_I

				help := (others => '0');

				help(DATA_WIDTH - 1 downto 0) := internal_first_operand;

			--			result <= 
			--				internal_first_operand(DATA_WIDTH -1) & help(DATA_WIDTH+shift_number-2 downto shift_number);


			when others =>
				if NOT OPERAND_ISOLATION then
					help := (others => '0');

					result <= (others => '0');

				end if;

		end case;
		--TODO: Carry, Overflow, Negative, and Zero flags for SHIFT Units
		flags <= (others =>'0');
	end process shifting_p;

end Behavioral;
