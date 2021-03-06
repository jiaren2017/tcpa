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
-- Create Date:    14:56:26 10/17/05
-- Design Name:    
-- Module Name:    logic_instr_decoder - Behavioral
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

entity logic_instr_decoder is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME           : string;
		-- cadence translate_on			 
		--*******************************************************************************--
		-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
		--*******************************************************************************--

		INSTR_WIDTH             : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH := CUR_DEFAULT_INSTR_WIDTH;

		BEGIN_OPCODE            : positive range 1 to 32                            := 15; -- 16 bit Instruction width
		END_OPCODE              : positive range 1 to 32                            := 13; -- 3  bit Opcode width

		BEGIN_OP_1              : positive range 1 to 32                            := 8; -- 4 bit RegField => 16 Register
		END_OP_1                : positive range 1 to 32                            := 5;

		BEGIN_OP_2              : positive range 1 to 32                            := 4; -- 4 bit RegField => 16 Register
		-- shravan : 20120327 : END_OP_2 value can be zero, hence modifying its definition to be integer

		--		END_OP_2				:positive range 1 to 32 := 1;
		END_OP_2                : integer range 0 to 31                             := 1;

		BEGIN_RES               : positive range 1 to 32                            := 12; -- 4 bit RegField => 16 Register
		END_RES                 : positive range 1 to 32                            := 9;

		BEGIN_IMMED             : positive range 1 to 32                            := 4; -- 5 bit Immediate

		BEGIN_CONST             : positive range 1 to 32                            := 8; -- 9 bit Constant


		--*******************************************************************************--
		-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
		--*******************************************************************************--

		DATA_WIDTH              : positive range 1 to MAX_DATA_WIDTH                := CUR_DEFAULT_DATA_WIDTH;
		REG_FILE_ADDR_WIDTH     : positive range 1 to MAX_REG_FILE_ADDR_WIDTH       := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

		-- The width of the first operands input multiplexer select-signal = 1

		SECOND_OP_MUX_SEL_WIDTH : positive                                          := 1
	);

	port(

		------------------------
		-- CURRENT INSTRUCTION FOR THE LOGIC -- 
		------------------------		

		instruction_in       : in  std_logic_vector(INSTR_WIDTH - 1 downto 0);

		------------------------
		-- LOGIC FU READ ADDRESS PORTS FOR REGISTER FILE -- 
		------------------------

		-- For register addressation 2 read ports are needed

		first_op_addr        : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);
		second_op_addr       : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);

		-- Operation select for the logic FU 

		logic_fu_select      : out std_logic_vector(1 downto 0);

		-- Immediate operand output
		-- This output is also used as a signal for a constant, which
		-- must be loaded into a register. The width of the constant
		-- is always bigger than that of the immediate operand
		-- Thus the bigger value of DATA_WIDTH for the vector is used

		immediate_operand    : out std_logic_vector(DATA_WIDTH - 1 downto 0);

		-- Constant operand output

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- LOGIC FU write ADDRESS PORT FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

		res_addr             : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- LOGIC FU WRITE ENABLE PORT FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		res_write_en         : out std_logic;

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- MULTIPLEXER SELECT SIGNALS -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^		 

		second_op_mux_select : out std_logic_vector(SECOND_OP_MUX_SEL_WIDTH - 1 downto 0)
	);

end logic_instr_decoder;

architecture Behavioral of logic_instr_decoder is
begin
	instr_decode : process(instruction_in)
		variable opcode : std_logic_vector(2 downto 0); -- :integer range 0 to 16; --


	begin

		--===============================================================================--
		-- Get the different fields from the INSTRUCTION WORD into local variables
		--===============================================================================--

		opcode := instruction_in(BEGIN_OPCODE downto END_OPCODE); --conv_integer(instruction_in(BEGIN_OPCODE downto END_OPCODE)); --

		--==============================================
		-- Get the OPCODE from the instruction word
		--==============================================

		-------------------
		-- OPCODE is logical AND
		-------------------

		CASE opcode IS

			--WHEN 0 =>
			WHEN "000" =>

				--===============================================================================--
				-- 1. Assign the function code for the adder unit to logical AND operation


				logic_fu_select <= "00";

				-----------------------------------------------------------------------------------
				-- 1.1 RESET the immediate constant for the second operand
				-- to avoid redundant inferred latches

				immediate_operand <= (others => '0');

				--===============================================================================--
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and

				first_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

				--===============================================================================--
				--===============================================================================--
				-- 3. Assign the address of the register for the second operand

				second_op_addr       <= instruction_in(BEGIN_OP_2 downto END_OP_2);
				second_op_mux_select <= "1";

				--===============================================================================--
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				res_write_en <= '1';

			--===============================================================================--
			--===============================================================================--			

			-------------------
			-- OPCODE is logical OR
			-------------------

			--WHEN 1 =>
			WHEN "001" =>

				--===============================================================================--
				-- 1. Assign the function code for the adder unit	to logical OR operation

				logic_fu_select <= "01";

				-----------------------------------------------------------------------------------
				-- 1.1 RESET the immediate constant for the second operand
				-- to avoid redundant inferred latches

				immediate_operand <= (others => '0');

				--===============================================================================--
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand 

				first_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

				--===============================================================================--
				--===============================================================================--
				-- 3. Assign the address of the register for the second operand

				second_op_addr       <= instruction_in(BEGIN_OP_2 downto END_OP_2);
				second_op_mux_select <= "1";

				--===============================================================================--
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				res_write_en <= '1';

			-------------------
			-- OPCODE is logical XOR
			-------------------

			-- WHEN 2 =>			
			WHEN "010" =>

				--===============================================================================--
				-- 1. Assign the function code for the adder unit	to logical XOR operation	

				logic_fu_select <= "10";

				-----------------------------------------------------------------------------------
				-----------------------------------------------------------------------------------
				-- 1.1 RESET the immediate constant for the second operand
				-- to avoid redundant inferred latches

				immediate_operand <= (others => '0');

				--===============================================================================--
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand 

				first_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

				--===============================================================================--
				--===============================================================================--
				-- 3. Assign the address of the register for the second operand

				second_op_addr       <= instruction_in(BEGIN_OP_2 downto END_OP_2);
				second_op_mux_select <= "1";

				--===============================================================================--
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				res_write_en <= '1';

			-------------------
			-- OPCODE is logical NEG
			-------------------


			--WHEN 3	=>			
			WHEN "011" =>

				--===============================================================================--
				-- 1. Assign the function code for the adder unit	to logical NEG operation	

				logic_fu_select <= "11";

				-----------------------------------------------------------------------------------
				-----------------------------------------------------------------------------------
				-----------------------------------------------------------------------------------
				-- 1.1 RESET the immediate constant for the second operand
				-- to avoid redundant inferred latches

				immediate_operand <= (others => '0');

				--===============================================================================--
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand 

				first_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

				--===============================================================================--
				--===============================================================================--
				-- 3. Assign the address of the register for the second operand

				second_op_addr       <= instruction_in(BEGIN_OP_2 downto END_OP_2);
				second_op_mux_select <= "1";

				--===============================================================================--
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				res_write_en <= '1';

			-------------------
			-- OPCODE is logical ANDI
			-------------------


			--WHEN 4 =>			
			WHEN "100" =>

				--===============================================================================--
				-- 1. Assign the function code for the adder unit	to logical AND operation	

				logic_fu_select <= "00";

				-----------------------------------------------------------------------------------

				-- 1.1 Set the immediate operand for the second operand

				immediate_operand(DATA_WIDTH - 1 downto BEGIN_IMMED + 1) <= (others => '0');
				immediate_operand(BEGIN_IMMED downto 0)                  <= instruction_in(BEGIN_IMMED downto 0);

				--===============================================================================--
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and

				first_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

				--===============================================================================--
				--===============================================================================--
				-- 3. Reset the address for the second operand to avoid redundant latches
				-- 3.1 And set the multiplexer select signal to 0

				second_op_addr <= (others => '0');

				-- to 0 <==> ImmediateOperand_Input for the second operand

				second_op_mux_select <= (others => '0');

				--===============================================================================--
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				res_write_en <= '1';

			--===============================================================================--
			--===============================================================================--	


			-------------------
			-- OPCODE is logical ORI
			-------------------


			--WHEN 5 =>			
			WHEN "101" =>

				--===============================================================================--
				-- 1. Assign the function code for the adder unit	to logical OR operation	

				logic_fu_select <= "01";

				-----------------------------------------------------------------------------------

				-- 1.1 Set the immediate operand for the second operand

				immediate_operand(DATA_WIDTH - 1 downto BEGIN_IMMED + 1) <= (others => '0');
				immediate_operand(BEGIN_IMMED downto 0)                  <= instruction_in(BEGIN_IMMED downto 0);

				--===============================================================================--
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and

				first_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

				--===============================================================================--
				--===============================================================================--
				-- 3. Reset the address for the second operand to avoid redundant latches
				-- 3.1 And set the multiplexer select signal to 0

				second_op_addr <= (others => '0');

				-- to 0 <==> ImmediateOperand_Input for the second operand

				second_op_mux_select <= (others => '0');

				--===============================================================================--
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				res_write_en <= '1';

			--WHEN 6 =>			
			WHEN "110" =>

				--===============================================================================--
				-- 1. Assign the function code for the adder unit	to logical XOR operation	

				logic_fu_select <= "10";

				-----------------------------------------------------------------------------------

				-- 1.1 Set the immediate operand for the second operand

				immediate_operand(DATA_WIDTH - 1 downto BEGIN_IMMED + 1) <= (others => '0');
				immediate_operand(BEGIN_IMMED downto 0)                  <= instruction_in(BEGIN_IMMED downto 0);

				--===============================================================================--
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and

				first_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

				--===============================================================================--
				--===============================================================================--
				-- 3. Reset the address for the second operand to avoid redundant latches
				-- 3.1 And set the multiplexer select signal to 0

				second_op_addr <= (others => '0');

				-- to 0 <==> ImmediateOperand_Input for the second operand

				second_op_mux_select <= (others => '0');

				--===============================================================================--
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				res_write_en <= '1';

			-------------------
			-- DEFAULT 
			-------------------
			-------------------

			WHEN OTHERS =>
				res_write_en <= '0';

				IF NOT OPERAND_ISOLATION THEN

					-- Reset all signals to constant 0
					-- to avoid redundant inferred latches

					logic_fu_select   <= "00";
					immediate_operand <= (others => '0');

					first_op_addr <= (others => '0');

					second_op_addr       <= (others => '0');
					second_op_mux_select <= (others => '0');

					res_addr <= (others => '0');

				END IF;

		END CASE;

	end process instr_decode;
--===============================================================================--
--===============================================================================--


end Behavioral;
