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
-- Create Date:    13:33:58 10/15/05
-- Design Name:    
-- Module Name:    mult_instr_decoder - Behavioral
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
use IEEE.STD_LOGIC_SIGNED.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mult_instr_decoder is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME           : string;
		-- cadence translate_on			

		--###################################
		--### SRECO: REGISTER FILE OFFSET ###
		RF_OFFSET               : positive range 1 to CUR_DEFAULT_MAX_REG_FILE_OFFSET := CUR_DEFAULT_REG_FILE_OFFSET;
		--###########################

		--*******************************************************************************--
		-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
		--*******************************************************************************--

		INSTR_WIDTH             : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH   := CUR_DEFAULT_INSTR_WIDTH;

		BEGIN_OPCODE            : positive range 1 to 32                              := 15; -- 16 bit Instruction width
		END_OPCODE              : positive range 1 to 32                              := 13; -- 3  bit Opcode width

		BEGIN_OP_1              : positive range 1 to 32                              := 8; -- 4 bit RegField => 16 Register
		END_OP_1                : positive range 1 to 32                              := 5;

		BEGIN_OP_2              : positive range 1 to 32                              := 4; -- 4 bit RegField => 16 Register
		-- shravan : 20120327 : END_OP_2 value can be zero, hence modifying its definition to be integer
		--		END_OP_2				:positive range 1 to 32 := 1;
		END_OP_2                : integer range 0 to 31                               := 1;

		BEGIN_RES               : positive range 1 to 32                              := 12; -- 4 bit RegField => 16 Register
		END_RES                 : positive range 1 to 32                              := 9;

		BEGIN_IMMED             : positive range 1 to 32                              := 4; -- 5 bit Immediate

		BEGIN_CONST             : positive range 1 to 32                              := 8; -- 9 bit Constant

		--*******************************************************************************--
		-- GENERIC FOR THE REGISTER FILE ADDRESS WIDTH
		--*******************************************************************************--

		REG_FILE_ADDR_WIDTH     : positive range 1 to MAX_REG_FILE_ADDR_WIDTH         := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

		DATA_WIDTH              : positive range 1 to MAX_DATA_WIDTH                  := CUR_DEFAULT_DATA_WIDTH;

		-- The width of the first operands input multiplexer select-signal  = 1

		SECOND_OP_MUX_SEL_WIDTH : positive                                            := 1
	);

	port(
		-- Operation select for the multiplier
		mult_fu_select       : out std_logic_vector(1 downto 0);

		clk, rst             : in  std_logic;

		mult_enable          : out std_logic_vector(0 downto 0);
		------------------------
		-- CURRENT INSTRUCTION FOR THE MULTIPLIER-- 
		------------------------		

		instruction_in       : in  std_logic_vector(INSTR_WIDTH - 1 downto 0);

		------------------------
		-- MULTIPLIER READ ADDRESS PORTS FOR REGISTER FILE -- 
		------------------------

		-- For register addressation 2 read ports are needed

		first_op_addr        : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);
		second_op_addr       : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);

		-- Immediate operand output
		-- This output is also used as a signal for a constant, which
		-- must be loaded into a register. The width of the constant
		-- is always bigger than that of the immediate operand
		-- Thus the bigger value of DATA_WIDTH for the vector is used

		immediate_operand    : out std_logic_vector(DATA_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--MULTIPLIER write ADDRESS PORT FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

		res_addr             : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- MULTIPLIER WRITE ENABLE PORT FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		res_write_en         : out std_logic;

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- MULTIPLEXER SELECT SIGNALS -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^		 

		second_op_mux_select : out std_logic_vector(SECOND_OP_MUX_SEL_WIDTH - 1 downto 0)
	);

end mult_instr_decoder;

architecture Behavioral of mult_instr_decoder is
	signal registered_instruction : std_logic_vector(INSTR_WIDTH - 1 downto 0);

begin

	--register_insruction :process(clk, rst)
	--
	--begin
	--
	--if clk'event and clk = '1' then
	--	if rst = '1' then

	--		registered_instruction <= (others => '1');
	--	
	--	else
	--	
	registered_instruction <= instruction_in; --registered_instruction;
	--	
	--	end if;
	--	
	--end if;
	--
	--
	--end process;


	--===============================================================================--
	--===============================================================================--
	instr_decode : process(registered_instruction, rst)
		variable opcode : std_logic_vector(2 downto 0); -- :integer range 0 to 16; --


	begin

		--===============================================================================--
		-- Get the different fields from the INSTRUCTION WORD into local variables
		--===============================================================================--

		opcode := registered_instruction(BEGIN_OPCODE downto END_OPCODE); -- conv_integer(registered_instruction(BEGIN_OPCODE downto END_OPCODE)); --

		CASE opcode IS

			--WHEN 0 =>
			WHEN "000" =>

				-- Enable the Multiplier
				mult_fu_select       <= "00"; -- MULT operation
				mult_enable          <= "1";
				-----------------------------------------------------------------------------------
				-- 1.1 RESET the immediate constant for the second operand
				-- to avoid redundant inferred latches
				--immediate_operand <= (others => '0');
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and
				first_op_addr        <= registered_instruction(BEGIN_OP_1 downto END_OP_1);
				second_op_mux_select <= "1";
				--===============================================================================--
				-- 3. Assign the address of the register for the second operand
				second_op_addr       <= registered_instruction(BEGIN_OP_2 downto END_OP_2);
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand
				res_addr             <= registered_instruction(BEGIN_RES downto END_RES);
				res_write_en         <= '1';
			--===============================================================================--

			--WHEN 1 => (MULTI)
			WHEN "001" =>
				-- Enable the Multiplier
				mult_fu_select                                           <= "00"; -- MULT operation
				mult_enable                                              <= "1";
				-----------------------------------------------------------------------------------
				-- 1.1 Set the immediate operand for the second operand
				immediate_operand(DATA_WIDTH - 1 downto BEGIN_IMMED + 1) <= (others => registered_instruction(BEGIN_IMMED));
				immediate_operand(BEGIN_IMMED downto 0)                  <= registered_instruction(BEGIN_IMMED downto 0);
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and
				first_op_addr                                            <= registered_instruction(BEGIN_OP_1 downto END_OP_1);
				--===============================================================================--
				-- 3. Reset the address for the second operand to avoid redundant latches
				-- 3.1 And set the multiplexer select signal to 0
				--second_op_addr 	<= (others => '0');
				-- to 0 <==> ImmediateOperand_Input for the second operand
				second_op_mux_select                                     <= (others => '0');
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand
				res_addr                                                 <= registered_instruction(BEGIN_RES downto END_RES);
				res_write_en                                             <= '1';
			--===============================================================================--	

			--WHEN 2 => (MUCST)
			WHEN "010" =>
				-- Enable the Multiplier
				mult_fu_select                                           <= "10"; -- CONST1 operation, second operand propagation, used for ICNI
				mult_enable                                              <= "1";
				-----------------------------------------------------------------------------------
				-- 1.1 Set the immediate operand to the value of the constant for the second operand
				immediate_operand(DATA_WIDTH - 1 downto BEGIN_CONST + 1) <= (others => registered_instruction(BEGIN_CONST));
				immediate_operand(BEGIN_CONST downto 0)                  <= registered_instruction(BEGIN_CONST downto 0);
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and
				-- 2.1 Set the multiplexer select signal 
				--	first_op_addr <= (others => '0');
				--===============================================================================--
				-- 3. Reset the address for the second operand to avoid redundant latches
				-- 3.1 And set the multiplexer select signal to 0
				--	second_op_addr <= (others => '0');
				-- to 0 <==> ImmediateOperand_Input for the second operand
				second_op_mux_select                                     <= (others => '0');
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand
				res_addr                                                 <= registered_instruction(BEGIN_RES downto END_RES);
				-- 4.1 Set the WRITE_ENABLE signal for the register file to 1 to indicate 
				-- write operation for the result
				res_write_en                                             <= '1';
			--===============================================================================--	    


			--########################				  	
			--##### SRECO IMMEDIATE ##
			-------------------
			-- OPCODE is ICNI
			------------------- 
			--------------------------------------
			--	FORMAT: ICNI C_REG  VALUE
			--	C_REG = CTRL_REG NUMBER = 0..4	   
			--------------------------------------

			--WHEN 5 =>				  	
			WHEN "101" =>
				-- Enable the Multiplier
				mult_fu_select                                           <= "10"; -- CONST1 operation, second operand propagation, used for ICNI
				mult_enable                                              <= "1";
				-----------------------------------------------------------------------------------
				-- 1.1 Set the immediate operand to the value of the constant for the second operand
				immediate_operand(DATA_WIDTH - 1 downto BEGIN_CONST + 1) <= (others => registered_instruction(BEGIN_CONST));
				immediate_operand(BEGIN_CONST downto 0)                  <= registered_instruction(BEGIN_CONST downto 0);
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and
				-- 2.1 Set the multiplexer select signal 
				--	first_op_addr <= (others => '0');
				--===============================================================================--
				-- 3. Reset the address for the second operand to avoid redundant latches
				-- 3.1 And set the multiplexer select signal to 0
				--		second_op_addr <= (others => '0');
				-- to 0 <==> ImmediateOperand_Input for the second operand
				second_op_mux_select                                     <= (others => '0');
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand
				res_addr                                                 <= registered_instruction(BEGIN_RES downto END_RES) + RF_OFFSET;
				-- 4.1 Set the WRITE_ENABLE signal for the register file to 1 to indicate 
				-- write operation for the result
				res_write_en                                             <= '1';
			--===============================================================================--	    


			--########################				  	
			--##### SRECO REGISTER  ##				  	
			-------------------
			-- OPCODE is ICN
			-------------------
			--------------------------------------	
			--	FORMAT: ICN C_REG  SOURCE_REG
			--	C_REG = CTRL_REG NUMBER = 0..4	   	
			--------------------------------------	
			--WHEN 6 =>
			WHEN "110" =>
				--"11" =>  		  -- CONST2 operation, first operand propagation, used for ICN
				-- Enable the Multiplier
				mult_fu_select       <= "11"; -- CONST2 operation, first operand propagation, used for ICN
				mult_enable          <= "1";
				-----------------------------------------------------------------------------------
				-- 1.1 Set the immediate operand
				--	immediate_operand <= (others => '0');
				--===============================================================================--
				-- 2. Assign the address of the register for the first operand and
				first_op_addr        <= registered_instruction(BEGIN_OP_1 downto END_OP_1);
				--===============================================================================--
				-- 3. Reset the address for the second operand to avoid redundant latches
				-- 3.1 And set the multiplexer select signal to 0
				--	second_op_addr 	<= (others => '0');
				-- to 0 <==> ImmediateOperand_Input for the second operand
				second_op_mux_select <= (others => '0');
				--===============================================================================--
				-- 4. Assign the address of the register for the result operand
				res_addr             <= registered_instruction(BEGIN_RES downto END_RES) + RF_OFFSET;
				res_write_en         <= '1';
			--===============================================================================--

			WHEN OTHERS =>

				-- Disable the Multiplier

				mult_enable  <= "0";
				res_write_en <= '0';

				IF NOT OPERAND_ISOLATION then
					immediate_operand    <= (others => '0');
					second_op_mux_select <= (others => '0');

					first_op_addr  <= (others => '0');
					second_op_addr <= (others => '0');
					res_addr       <= (others => '0');

				end if;

		END CASE;

	end process instr_decode;
--===============================================================================--
--===============================================================================--


end Behavioral;
