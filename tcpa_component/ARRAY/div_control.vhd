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
-- Create Date:    11:54:00 10/16/05
-- Design Name:    
-- Module Name:    div_control - Behavioral
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
use wppa_instance_v1_01_a.TYPE_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity div_control is
	generic(

		--*******************************************************************************--
		-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
		--*******************************************************************************--

		INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH := CUR_DEFAULT_INSTR_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
		--*******************************************************************************--

		NUM_OF_DIV_FU       : integer range 0 to MAX_NUM_FU                     := CUR_DEFAULT_NUM_DIV_FU;

		--*******************************************************************************--
		-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
		--*******************************************************************************--

		DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH                := CUR_DEFAULT_DATA_WIDTH;
		REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH       := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE REGISTER FIELD WIDTH IN THE INSTRUCTION
		--*******************************************************************************--

		-- Width of the register field in the instruction = log_2(GEN_PUR_REG_NUM)

		REG_FIELD_WIDTH     : positive range 1 to MAX_REG_FIELD_WIDTH           := CUR_DEFAULT_REG_FIELD_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
		--*******************************************************************************--

		OPCODE_FIELD_WIDTH  : positive range 1 to MAX_OPCODE_FIELD_WIDTH        := CUR_DEFAULT_OPCODE_FIELD_WIDTH
	);

	port(
		clk, rst           : in  std_logic;

		------------------------
		-- INSTRUCTIONS FOR THE DIVIDER UNITS -- 
		------------------------		

		instr_vector       : in  std_logic_vector(NUM_OF_DIV_FU * INSTR_WIDTH - 1 downto 0);

		------------------------
		-- DIVIDERS READ ADDRESS PORTS FOR REGISTER FILE -- 
		------------------------

		-- For register addressation 2 read ports for every FU is needed

		div_1_op_read_addr : out std_logic_vector(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);
		div_2_op_read_addr : out std_logic_vector(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		------------------------
		-- DIVIDERS READ DATA PORTS FOR REGISTER FILE -- 
		------------------------

		-- For register addressation 2 read ports for every FU is needed

		div_1_op_read_data : in  std_logic_vector(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0);
		div_2_op_read_data : in  std_logic_vector(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- DIVIDERS write ADDRESS PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

		div_write_addr     : out std_logic_vector(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- DIVIDERS WRITE DATA PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		div_write_data     : out std_logic_vector(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- DIVIDERS WRITE ENABLE PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		div_write_en       : out std_logic_vector(1 to NUM_OF_DIV_FU);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- DIVIDERS REMAINDER VALUES -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		div_remainders     : out std_logic_vector(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0)
	);

end div_control;

architecture Behavioral of div_control is

	--===============================================================================--
	-- CONSTANTS
	--===============================================================================--

	CONSTANT BEGIN_OPCODE : positive := (INSTR_WIDTH - 1);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3) ==> opcode = conv_int(instruction_in(15 downto 13) ==> OK
	CONSTANT END_OPCODE   : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH);

	CONSTANT BEGIN_RES : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 1);
	CONSTANT END_RES   : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - REG_FIELD_WIDTH);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3, REG_FIELD_WIDTH = 4} ==> regf_res_addr(i) <= instr(i)(12 .. 9) ==> OK

	CONSTANT BEGIN_OP_1 : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - REG_FIELD_WIDTH - 1);
	CONSTANT END_OP_1   : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 2 * REG_FIELD_WIDTH);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3, REG_FIELD_WIDTH = 4} ==> regf_1_op_addr(i) <= instr(i)(8 .. 5) ==> OK

	CONSTANT BEGIN_OP_2 : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 2 * REG_FIELD_WIDTH - 1);
	CONSTANT END_OP_2   : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 3 * REG_FIELD_WIDTH);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3, REG_FIELD_WIDTH = 4} ==> regf_2_op_addr(i) <= instr(i)(4 .. 1) ==> OK


	--===============================================================================--
	-- ADDITIONAL TYPE DECLARATIONS
	--===============================================================================--

	-- Instructions, Address and data line arrayed data types
	type t_InstrVec is array (natural range <>) of std_logic_vector(INSTR_WIDTH - 1 downto 0);
	type t_addr_array is array (integer range <>) of std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);
	type t_data_array is array (integer range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	--===============================================================================--
	--===============================================================================--

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Instructions for the several dividers  --

	-- instructions(1) is the instruction word for the 
	-- first divider
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	signal instructions : t_InstrVec(1 to NUM_OF_DIV_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Register file signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- Register file read addresses for 1. and 2. operand
	signal regf_1_op_addr : t_addr_array(1 to NUM_OF_DIV_FU);
	signal regf_2_op_addr : t_addr_array(1 to NUM_OF_DIV_FU);

	-- Register file read data  for 1. and 2. operand
	signal regf_1_op_data : t_data_array(1 to NUM_OF_DIV_FU);
	signal regf_2_op_data : t_data_array(1 to NUM_OF_DIV_FU);

	-- Register file write addresses for result
	signal regf_res_addr : t_addr_array(1 to NUM_OF_DIV_FU);

	-- Register file write data  for result
	signal regf_res_data : t_data_array(1 to NUM_OF_DIV_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Remainder signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	signal remainders_array : t_data_array(1 to NUM_OF_DIV_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- dividers' control signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	signal div_fu_enables : t_1BitArray(1 to NUM_OF_DIV_FU);

	--===============================================================================--
	-- DIVIDER COMPONENT DECLARATION --
	--===============================================================================--
	component div_fu
		generic(DATA_WIDTH : positive range 1 to 32 := 32);

		port(
			dividend   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			divisor    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			div_enable : in  std_logic_vector(0 downto 0);
			quotient   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			clk        : in  std_logic;
			remainder  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component div_fu;

	--===============================================================================--
	--===============================================================================--

	--===============================================================================--
	-- DIVIDER INSTRUCTION DECODER COMPONENT DECLARATION --
	--===============================================================================--

	component div_instr_decoder is
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

	end component div_instr_decoder;

--===============================================================================--
--===============================================================================--


begin

	--===============================================================================--
	-- Conversions from INternal indexed array of signals to 
	-- EXternal, (big) std_logic_vector - Signals
	--===============================================================================--
	conv : FOR i in 1 to NUM_OF_DIV_FU GENERATE

		-- Assign the instructions from EXternal (big) vector to the INternal indexed instruction array
		-- so that the instruction word for the 1. divider is under the index 1 in the instruction array:
		-- instructions(1)

		instructions(i) <= instr_vector(INSTR_WIDTH * i - 1 downto INSTR_WIDTH * (i - 1));

		-- Assign the read addresses from INternal address array to EXternal (big) vector 
		-- so that the address for the first operand of the 1. divider is under
		-- div_1_op_read_addr(REG_FILE_ADDR_WIDTH -1 downto 0) 

		div_1_op_read_addr(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1)) <= regf_1_op_addr(i);
		div_2_op_read_addr(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1)) <= regf_2_op_addr(i);

		-- Assign the register file data from EXternal (big) vector to the INternal indexed data array
		-- so that the register data for the first operand of the first divider is under
		-- regf_1_op_data(1)

		regf_1_op_data(i) <= div_1_op_read_data(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1));
		regf_2_op_data(i) <= div_2_op_read_data(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1));

		-- Assign the write addresses and data from INternal address array to EXternal (big) vector 
		-- so that the write address of the result of the first divider is under
		-- div_write_addr(REG_FILE_ADDR_WIDTH -1 downto 0) and the write data of the result of the first divider is under
		-- div_write_data(DATA_WIDTH -1 downto 0)

		div_write_addr(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1)) <= regf_res_addr(i);
		div_write_data(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1))                   <= regf_res_data(i);

		-- Assign the remainder values to the EXternal std_logic_vector signal
		div_remainders(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1)) <= remainders_array(i);

	END GENERATE;

	--===============================================================================--
	-- Layout of the GenralPurpose, Input, and Output Registers in the Register Address Space:

	-------------------------------
	-------------------------------
	-- Register {(GEN_PUR_REG_NUM + NUM_OF_INPUT_REG + NUM_OF_OUTPUT_REG -1}
	-- <==> Last output Register/FIFO
	-------------------------------

	-- ... --

	-------------------------------
	-- Register {(GEN_PUR_REG_NUM + NUM_OF_INPUT_REG}
	-- <==> First output Register/FIFO
	-------------------------------
	-------------------------------
	-- Register {(GEN_PUR_REG_NUM - 1) + NUM_OF_INPUT_REG}
	-- <==> Last input Register/FIFO
	-------------------------------

	-- ... --

	-- Register GEN_PUR_REG_NUM 
	-- <==> First input Register/FIFO
	-------------------------------
	-------------------------------
	-- Register GEN_PUR_REG_NUM - 1
	-- <==> Last GenPurpose Register
	-------------------------------

	-- ... --

	-------------------------------
	-- Register 1 --
	-------------------------------
	-- Register 0 --
	-------------------------------
	-------------------------------


	--===============================================================================--
	--===============================================================================--

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- DIVIDER GENERATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	dividers : for i in 1 to NUM_OF_DIV_FU generate
		divid : component div_fu
			generic map(DATA_WIDTH => DATA_WIDTH)
			port map(
				dividend   => regf_1_op_data(i),
				divisor    => regf_2_op_data(i),
				div_enable => div_fu_enables(i),
				quotient   => regf_res_data(i),
				clk        => clk,
				remainder  => remainders_array(i)
			);

	end generate dividers;

	--===============================================================================--
	--===============================================================================--

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- DIVIDER INSTRUCTION DECODERs GENERATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	div_in_dec : for i in 1 to NUM_OF_DIV_FU generate
		div_instr_decode : component div_instr_decoder
			generic map(

				--*******************************************************************************--
				-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
				--*******************************************************************************--

				INSTR_WIDTH         => INSTR_WIDTH,
				BEGIN_OPCODE        => BEGIN_OPCODE,
				END_OPCODE          => END_OPCODE,
				BEGIN_OP_1          => BEGIN_OP_1,
				END_OP_1            => END_OP_1,
				BEGIN_OP_2          => BEGIN_OP_2,
				END_OP_2            => END_OP_2,
				BEGIN_RES           => BEGIN_RES,
				END_RES             => END_RES,
				REG_FILE_ADDR_WIDTH => REG_FILE_ADDR_WIDTH
			)
			port map(
				rst            => rst,
				div_enable     => div_fu_enables(i)(0),

				------------------------
				-- CURRENT INSTRUCTION FOR THE DIVIDER -- 
				------------------------		

				instruction_in => instructions(i),

				------------------------
				-- DIVIDER READ ADDRESS PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports are needed

				first_op_addr  => regf_1_op_addr(i),
				second_op_addr => regf_2_op_addr(i),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DIVIDER write ADDRESS PORT FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				res_addr       => regf_res_addr(i),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DIVIDER WRITE ENABLE PORT FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				res_write_en   => div_write_en(NUM_OF_DIV_FU - i + 1)
			);

	end generate div_in_dec;

--===============================================================================--
--===============================================================================--


end Behavioral;