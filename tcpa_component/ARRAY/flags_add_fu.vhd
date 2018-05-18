--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    13:43:23 10/20/05
-- Design Name:    
-- Module Name:    flags_add_fu - Behavioral
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library wppa_instance_v1_01_a;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

entity flags_add_fu is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME : string;
		-- cadence translate_on	
		INSTR_WIDTH   : positive range 1 to 64 := 64; 
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH);

	port(
		clk, rst       : in  std_logic;
		instructions   : in  std_logic_vector(INSTR_WIDTH - 1 downto 0); 
		CO             : out std_logic;
		first_summand  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		second_summand : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		sum_select     : in  std_logic_vector(1 downto 0);
		sum_enable     : in  std_logic_vector(0 downto 0);
		sum            : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		flags          : out std_logic_vector(MAX_NUM_FLAGS - 1 downto 0)
	);

end flags_add_fu;

architecture Behavioral of flags_add_fu is
	signal internal_sum : std_logic_vector(2 + DATA_WIDTH - 1 downto 0); -- 1 Carry bit and 1 Negative bit
	--signal CI,CO :std_logic; -- Carry out signal
	signal negative_flag, zero_flag, carry_flag, overflow_flag : std_logic := '0';
	signal internal_flags            : std_logic_vector(3 downto 0);
	signal registered_internal_flags : std_logic_vector(3 downto 0);

	signal internal_first_summand  : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal internal_second_summand : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal nop : std_logic;
begin
	TEST_MACROMODELING : IF MACROMODELING GENERATE
		ENABLE_GENERATION : FOR i in 0 to DATA_WIDTH - 1 GENERATE
			internal_first_summand(i)  <= first_summand(i) AND sum_enable(0);
			internal_second_summand(i) <= second_summand(i) AND sum_enable(0);

		END GENERATE ENABLE_GENERATION;

	END GENERATE TEST_MACROMODELING;

	TEST_FALSE_MACROMODELING : IF NOT (MACROMODELING) GENERATE
		DISABLE_GENERATION : FOR i in 0 to DATA_WIDTH - 1 GENERATE
			internal_first_summand(i)  <= first_summand(i);
			internal_second_summand(i) <= second_summand(i);

		END GENERATE DISABLE_GENERATION;

	END GENERATE TEST_FALSE_MACROMODELING;

	CLK_GATING_REVERSED_MEMORY : if CLOCK_GATING and REVERSED_CLOCK_GATING and MEMORY_CLOCK_GATING generate
		flags <= registered_internal_flags;

	END GENERATE CLK_GATING_REVERSED_MEMORY;

	CLK_GATING_REVERSED : if CLOCK_GATING and REVERSED_CLOCK_GATING and (not MEMORY_CLOCK_GATING) generate
		flags <= internal_flags;

	END GENERATE CLK_GATING_REVERSED;

	CLK_GATING_NOT_REVERSED : if CLOCK_GATING and not REVERSED_CLOCK_GATING generate
		flags <= internal_flags;

	END GENERATE CLK_GATING_NOT_REVERSED;

	NOT_CLK_GATING : if not CLOCK_GATING generate
		flags <= internal_flags;

	END GENERATE NOT_CLK_GATING;

	-- Assign the sum output and flag output to the internal signals

	sum <= internal_sum(DATA_WIDTH - 1 downto 0);

	--===============================================================================
	--===============================================================================


	set_flags : process(clk, internal_flags)
	begin
		if clk'event and clk = '0' then
			if rst = '1' then
				registered_internal_flags <= (others => '0');

			else
				registered_internal_flags <= internal_flags;

			end if;

		end if;

	end process;

	--===============================================================================
	--===============================================================================
	--if all bits of instruction vector are '1', nop is true
	nop <= '1' when ((instructions = (INSTR_WIDTH -1 downto 0 => '1'))) else '0';

	summation_with_flags_p : process(internal_first_summand, internal_second_summand, sum_select, sum_enable)
	begin

		--if sum_enable(0) = '1' then
		case sum_select is
			when "00" =>                -- ADD operation


				internal_sum <= (internal_first_summand(DATA_WIDTH - 1) & internal_first_summand(DATA_WIDTH - 1) & internal_first_summand) + (internal_second_summand(DATA_WIDTH - 1) & internal_second_summand(DATA_WIDTH - 1) & internal_second_summand);

			when "01" =>                -- SUB operation

				--internal_sum <= 	signed(internal_first_summand(DATA_WIDTH - 1) & internal_first_summand(DATA_WIDTH -1)  & internal_first_summand) - 
				--					signed(internal_second_summand(DATA_WIDTH - 1) & internal_second_summand(DATA_WIDTH -1) & internal_second_summand); 

				internal_sum <= (internal_first_summand(DATA_WIDTH - 1) & internal_first_summand(DATA_WIDTH - 1) & internal_first_summand) - (internal_second_summand(DATA_WIDTH - 1) & internal_second_summand(DATA_WIDTH - 1) & internal_second_summand);

			when "10" =>                -- CONST1 operation, second operand propagation, used for ICNI

				internal_sum(DATA_WIDTH - 1 downto 0) <= internal_second_summand;

			when "11" =>                -- CONST2 operation, first operand propagation, used for ICN 

				internal_sum(DATA_WIDTH - 1 downto 0) <= internal_first_summand;

			when others =>
				internal_sum <= (others => '0');

		end case;
	--else -- sum_enable(0) = '0'
	--
	--		if OPERAND_ISOLATION = true then
	--		 
	--		 	internal_sum <= internal_sum; --(others => '0'); -- LATCH OUTPUT on enable = '0'
	--
	--		else
	--
	--			internal_sum <= (others => '0');
	--
	--		end if;
	--
	--end if;


	end process summation_with_flags_p;

	--===============================================================================
	--===============================================================================

	flags_set_p : process(clk, internal_sum, first_summand, second_summand, nop, instructions)
	--flags_set_p :process(clk)

	begin
		--
		--if clk'event and clk = '1' then
		--
		--	if rst = '1'	then
		--
		--			internal_flags <= (others => '0');
		--
		--	else
		--
	if(nop = '0') then

		--================================================================================
		-- 	flags(0) => ZERO FLAG: 
		--						result of the subtraction by the first adder FU was equal to 0
		--================================================================================
		-- 	flags(1) => OVERFLOW FLAG:
		--						the operands result of the addition by the first adder FU was 
		--================================================================================
		-- 	flags(2) => NEGATIVE FLAG:
		--						result of the subtraction by the first adder FU was negative
		--================================================================================
		-- 	flags(3) => CARRY FLAG:
		--						result of the addition by the first adder FU was too big
		--================================================================================

		-- Setting the CARRY flag
		CO                <= internal_sum(DATA_WIDTH);
		internal_flags(3) <= internal_sum(DATA_WIDTH);

		--================================================================================
		--Ericles: Commenting the code bellow, because the mapping for NEGATIVE and OVERFLOW looks wrong. 
		--The Flag must mapped as C-O-N-Z, instead of C-N-O-Z. This point was solved as described in the 
		--next code lines 266 and 269

		--			-- Setting the NEGATIVE flag
		--			internal_flags(2) <= internal_sum(1+DATA_WIDTH);                                  

		--================================================================================
		-- Setting the OVERFLOW flag
		--      	internal_flags(1) <= (internal_sum(DATA_WIDTH-1) xor internal_sum(1+DATA_WIDTH));
		--	internal_sum(1+DATA_WIDTH) xor internal_sum(DATA_WIDTH) 
		--	xor first_summand(DATA_WIDTH-1) xor second_summand(DATA_WIDTH-1);  
		--================================================================================
		-- Setting the NEGATIVE flag
		internal_flags(1) <= internal_sum(1 + DATA_WIDTH);
		--================================================================================
		-- Setting the OVERFLOW flag
		internal_flags(2) <= (internal_sum(DATA_WIDTH - 1) xor internal_sum(1 + DATA_WIDTH));
		--================================================================================

		-- Setting the ZERO flag			
		if (internal_sum = 0) then
			internal_flags(0) <= '1';

		else
			internal_flags(0) <= '0';

		end if;
	else
		internal_flags <= (others=>'0');
	end if;
	--================================================================================

	--	end if;
	--
	--end if;

	end process flags_set_p;

end Behavioral;
