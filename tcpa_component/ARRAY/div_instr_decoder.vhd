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
-- Create Date:    11:54:17 10/16/05
-- Design Name:    
-- Module Name:    div_instr_decoder - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.all;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity div_instr_decoder is
	generic(

		--*******************************************************************************--
		-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
		--*******************************************************************************--

		INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH := CUR_DEFAULT_INSTR_WIDTH;

		BEGIN_OPCODE        : positive range 1 to 32                            := 15; -- 16 bit Instruction width
		END_OPCODE          : positive range 1 to 32                            := 13; -- 3  bit Opcode width

		BEGIN_OP_1          : positive range 1 to 32                            := 8; -- 4 bit RegField => 16 Register
		END_OP_1            : positive range 1 to 32                            := 5;

		BEGIN_OP_2          : positive range 1 to 32                            := 4; -- 4 bit RegField => 16 Register
		END_OP_2            : positive range 1 to 32                            := 1;

		BEGIN_RES           : positive range 1 to 32                            := 12; -- 4 bit RegField => 16 Register
		END_RES             : positive range 1 to 32                            := 9;

		--*******************************************************************************--
		-- GENERIC FOR THE REGISTER FILE ADDRESS WIDTH
		--*******************************************************************************--

		REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH       := CUR_DEFAULT_REG_FILE_ADDR_WIDTH
	);

	port(
		rst            : in  std_logic;

		div_enable     : out std_logic;

		------------------------
		-- CURRENT INSTRUCTION FOR THE DIVIDER-- 
		------------------------		

		instruction_in : in  std_logic_vector(INSTR_WIDTH - 1 downto 0);

		------------------------
		-- DIVIDER READ ADDRESS PORTS FOR REGISTER FILE -- 
		------------------------

		-- For register addressation 2 read ports are needed

		first_op_addr  : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);
		second_op_addr : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--DIVIDER write ADDRESS PORT FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

		res_addr       : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- DIVIDER WRITE ENABLE PORT FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		res_write_en   : out std_logic
	);

end div_instr_decoder;

architecture Behavioral of div_instr_decoder is
begin

	--===============================================================================--
	--===============================================================================--
	instr_decode : process(instruction_in, rst)
		variable opcode : std_logic_vector(2 downto 0); -- :integer range 0 to 16;--


	begin

		--===============================================================================--
		-- Get the different fields from the INSTRUCTION WORD into local variables
		--===============================================================================--

		IF rst = '1' THEN
			div_enable <= '0';

			first_op_addr  <= (others => '0');
			second_op_addr <= (others => '0');
			res_addr       <= (others => '0');
			res_write_en   <= '0';

		ELSE
			opcode := instruction_in(BEGIN_OPCODE downto END_OPCODE); -- conv_integer(instruction_in(BEGIN_OPCODE downto END_OPCODE)); --

			CASE opcode IS

				--WHEN 0 =>
				WHEN "000" =>

					--===============================================================================--
					--===============================================================================--
					-- 1. Enable the DIVIDER FU

					div_enable <= '1';

					--===============================================================================--
					--===============================================================================--
					-- 2. Assign the address of the register for the first operand and

					first_op_addr <= instruction_in(BEGIN_OP_1 downto END_OP_1);

					--===============================================================================--
					--===============================================================================--
					-- 3. Assign the address of the register for the second operand

					second_op_addr <= instruction_in(BEGIN_OP_2 downto END_OP_2);

					--===============================================================================--
					--===============================================================================--
					-- 4. Assign the address of the register for the result operand

					res_addr <= instruction_in(BEGIN_RES downto END_RES);

					res_write_en <= '1';

				WHEN OTHERS =>
					div_enable <= '0';

					first_op_addr  <= (others => '0');
					second_op_addr <= (others => '0');
					res_addr       <= (others => '0');
					res_write_en   <= '0';

			END CASE;

		END IF;                         -- rst = 

	end process instr_decode;
--===============================================================================--
--===============================================================================--


end Behavioral;
