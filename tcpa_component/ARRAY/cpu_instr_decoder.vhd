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
-- Create Date:    14:34:21 12/28/05
-- Design Name:    
-- Module Name:    cpu_instr_decoder - Behavioral
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

entity cpu_instr_decoder is
	generic(

		-- cadence translate_off	
		INSTANCE_NAME           : string;
		-- cadence translate_on			
		--*******************************************************************************--
		-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
		--*******************************************************************************--

		INSTR_WIDTH             : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH         := CUR_DEFAULT_INSTR_WIDTH;

		BEGIN_OPCODE            : positive range MIN_INSTR_WIDTH - 1 to MAX_INSTR_WIDTH - 1 := CUR_DEFAULT_INSTR_WIDTH - 1;
		END_OPCODE              : positive range 1 to MAX_INSTR_WIDTH - 1                   := CUR_DEFAULT_INSTR_WIDTH - CUR_DEFAULT_OPCODE_FIELD_WIDTH;

		BEGIN_OP_1              : positive range 1 to (MAX_INSTR_WIDTH - 3)                 := 8; -- 4 bit RegField => 16 Register
		END_OP_1                : positive range 1 to (MAX_INSTR_WIDTH - 3)                 := 5;

		BEGIN_RES               : positive range 1 to (MAX_INSTR_WIDTH - 2)                 := 12; -- 4 bit RegField => 16 Register
		END_RES                 : positive range 1 to (MAX_INSTR_WIDTH - 2)                 := 9;

		BEGIN_CONST             : positive range 1 to (MAX_INSTR_WIDTH - 4)                 := 8; -- 1 bit Constant

		--*******************************************************************************--
		-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
		--*******************************************************************************--

		CTRL_REG_WIDTH          : positive range 1 to MAX_CTRL_REG_WIDTH                    := CUR_DEFAULT_CTRL_REG_WIDTH;
		CTRL_REGFILE_ADDR_WIDTH : positive range 1 to MAX_CTRL_REGFILE_ADDR_WIDTH           := CUR_DEFAULT_CTRL_REGFILE_ADDR_WIDTH
	);

	port(
		cpu_enable           : out std_logic_vector(0 downto 0);

		------------------------
		-- CURRENT INSTRUCTION FOR THE CPU -- 
		------------------------		

		instruction_in       : in  std_logic_vector(INSTR_WIDTH - 1 downto 0);

		------------------------
		-- CPU READ ADDRESS PORTS FOR REGISTER FILE -- 
		------------------------

		source_op_addr       : out std_logic_vector(CTRL_REGFILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- CPU write ADDRESS PORT FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

		res_addr             : out std_logic_vector(CTRL_REGFILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- CPU WRITE ENABLE PORT FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		res_write_en         : out std_logic;

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- CPU CONSTANT OPERAND --
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		constant_operand     : out std_logic_vector(CTRL_REG_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- MULTIPLEXER SELECT SIGNALS -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^		 

		second_op_mux_select : out std_logic_vector(0 downto 0)
	);

end cpu_instr_decoder;

architecture Behavioral of cpu_instr_decoder is
begin
	instr_decode : process(instruction_in)
		variable opcode : std_logic_vector(2 downto 0); --:integer range 0 to 16; --

	begin

		--===============================================================================--
		-- Get the different fields from the INSTRUCTION WORD into local variables
		--===============================================================================--

		opcode := instruction_in(BEGIN_OPCODE downto END_OPCODE); --conv_integer(instruction_in(BEGIN_OPCODE downto END_OPCODE)); --


		--==============================================
		-- Get the OPCODE from the instruction word
		--==============================================

		-------------------
		-- OPCODE is MOVE
		-------------------

		CASE opcode IS

			--	WHEN 0 =>
			WHEN "000" =>

				-- Enable the CPU

				cpu_enable <= "1";

				--===============================================================================--
				--===============================================================================--
				-- 1. Assign the address of the register for the first operand and

				source_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

				--===============================================================================--
				--===============================================================================--
				-- 2. Set the multiplexer select signal to 1

				constant_operand <= (others => '0');

				-- to 1 <==> RegisterFile_Input for the second operand

				second_op_mux_select <= "1";

				--===============================================================================--
				--===============================================================================--
				-- 3. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				res_write_en <= '1';

			--===============================================================================--
			--===============================================================================--			


			-------------------
			-- OPCODE is CONST
			-------------------

			--WHEN 1 =>
			WHEN "001" =>

				-- Enable the CPU

				cpu_enable <= "1";

				-----------------------------------------------------------------------------------
				-- 1. Set the constant operand to the value of the constant for the second operand

				--	constant_operand(CTRL_REG_WIDTH -1 downto BEGIN_CONST + 1) <= (others => '0');
				constant_operand(CTRL_REG_WIDTH - 1 downto CTRL_REG_WIDTH - 1)
				--<= instruction_in(BEGIN_CONST downto BEGIN_CONST);
				<= instruction_in(0 downto 0);

				--===============================================================================--
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand 

				source_op_addr <= (others => '0');

				-- 2.1 Set the multiplexer select signal to 0

				-- to 0 <==> ConstantOperand_Input for the second operand

				second_op_mux_select <= (others => '0');

				--===============================================================================--
				--===============================================================================--
				-- 3. Assign the address of the register for the result operand

				res_addr <= instruction_in(BEGIN_RES downto END_RES);

				-- 3.1 Set the WRITE_ENABLE signal for the register file to 1 to indicate 
				--     write operation for the result

				res_write_en <= '1';

			-------------------
			-- DEFAULT 
			-------------------

			WHEN OTHERS =>

				--Disable the CPU

				cpu_enable <= "0";

				-- Reset all signals to constant 0
				-- to avoid redundant inferred latches

				constant_operand <= (others => '0');

				second_op_mux_select <= (others => '0');

				res_addr     <= (others => '0');
				res_write_en <= '0';

				source_op_addr <= (others => '0');

		END CASE;

	end process instr_decode;
--===============================================================================--
--===============================================================================--


end Behavioral;
