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
-- Create Date:    11:09:24 09/13/05
-- Design Name:    
-- Module Name:    mult_fu - Behavioral
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
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.STD_LOGIC_SIGNED.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mult_fu is
	generic(
		-- cadence translate_off		
		INSTANCE_NAME : string;
		-- cadence translate_on			
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH);

	port(
		first_operand  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		second_operand : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		mult_select    : in  std_logic_vector(1 downto 0);
		mult_enable    : in  std_logic_vector(0 downto 0);
		--				product			:out std_logic_vector(2*DATA_WIDTH - 1 downto 0)
		product        : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		flags          : out std_logic_vector(MAX_NUM_FLAGS - 1 downto 0)
	);

end mult_fu;

architecture Behavioral of mult_fu is
	signal internal_product : std_logic_vector(2 * DATA_WIDTH - 1 downto 0);
	signal negative_flag, zero_flag, carry_flag, overflow_flag : std_logic := '0';

	signal internal_first_operand  : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal internal_second_operand : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

	--TEST_MACROMODELING: IF MACROMODELING GENERATE

	--	ENABLE_GENERATION :FOR i in 0 to DATA_WIDTH -1 GENERATE

	--		internal_first_operand(i)  <= first_operand(i)  AND mult_enable(0);
	--		internal_second_operand(i) <= second_operand(i) AND mult_enable(0);

	--	END GENERATE ENABLE_GENERATION;

	--END GENERATE TEST_MACROMODELING;


	--TEST_FALSE_MACROMODELING: IF NOT(MACROMODELING) GENERATE

	DISABLE_GENERATION : FOR i in 0 to DATA_WIDTH - 1 GENERATE
		internal_first_operand(i)  <= first_operand(i);
		internal_second_operand(i) <= second_operand(i);

	END GENERATE DISABLE_GENERATION;

	--END GENERATE TEST_FALSE_MACROMODELING;


	product <= internal_product(DATA_WIDTH - 1 downto 0);

	--multiply :process(first_operand, second_operand, internal_product, mult_enable)
	--begin
	--	if mult_enable = "1" then
	--		internal_product <= first_operand * second_operand;	
	--		product          <= internal_product(DATA_WIDTH -1 downto 0);
	--	else
	--		internal_product <= (others => '0');
	--		product          <= (others => '0');
	--	end if;
	--end process;


	----------------------------------------------------------------------------------------------
	multiply : process(internal_first_operand, internal_second_operand, internal_product, mult_select, mult_enable)
	begin
		if mult_enable(0) = '1' then
			case mult_select is
				when "00" =>            -- MULT operation
					internal_product <= internal_first_operand * internal_second_operand;

				when "01" =>            -- RESERVED
					internal_product <= (others => '0');

				when "10" =>            -- CONST1 operation, second operand propagation, used for ICNI
					internal_product(DATA_WIDTH - 1 downto 0) <= internal_second_operand;

				when "11" =>            -- CONST2 operation, first operand propagation, used for ICN 
					internal_product(DATA_WIDTH - 1 downto 0) <= internal_first_operand;

				when others =>
					internal_product <= (others => '0');
			end case;
		else                            -- mult_enable(0) = '0'

			--		if OPERAND_ISOLATION = true then

			--		 	internal_product <= internal_product; --(others => '0'); -- LATCH OUTPUT on enable = '0'

			--		else

			internal_product <= (others => '0');

		--		end if;

		end if;

	end process multiply;
----------------------------------------------------------------------------------------------	
	--Ericles: Added logic for generating flag values. TODO: Negative, Carry and Overflow flags...
	flags_set_p : process(mult_enable, internal_product, internal_first_operand, internal_second_operand)
	begin

		--Ericles: The Flags are mapped in the following order: C-O-N-Z, instead of C-N-O-Z. 
		--This fix is compatible with the TCPA C++ simulator (also know as WPPE Simulator)
		if(mult_enable(0) = '1') then

			-- Setting the ZERO flag (Z)		
			if (internal_product = 0) then
				flags(0) <= '1';
				zero_flag <= '1';
	
			else
				flags(0) <= '0';
				zero_flag <= '0';
			end if;
	
			-- Setting the NEGATIVE flag (N)
			flags(1) <= internal_product(1 + DATA_WIDTH);
			negative_flag <= internal_product(1 + DATA_WIDTH);
	
			-- Setting the OVERFLOW flag (O)
			flags(2) <= (internal_product(DATA_WIDTH - 1) xor internal_product(1 + DATA_WIDTH));
			overflow_flag <= (internal_product(DATA_WIDTH - 1) xor internal_product(1 + DATA_WIDTH));
	
			-- Setting the CARRY flag (C)
			flags(3) <= internal_product(DATA_WIDTH);
			carry_flag <= internal_product(DATA_WIDTH);
		else
			flags         <= (others=>'0');
			zero_flag     <= '0';
			negative_flag <= '0';
			overflow_flag <= '0';
			carry_flag    <= '0';
		end if;
	--================================================================================

	--	end if;
	--
	--end if;

	end process flags_set_p;
end Behavioral;

