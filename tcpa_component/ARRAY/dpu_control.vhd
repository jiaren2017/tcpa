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
-- Create Date:    13:36:51 12/28/05
-- Design Name:    
-- Module Name:    dpu_control - Behavioral
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

entity dpu_control is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME       : string                                              := "???";
		-- cadence translate_on	

		--###################################
		--### SRECO: REGISTER FILE OFFSET ###
		RF_OFFSET           : positive range 1 to CUR_DEFAULT_MAX_REG_FILE_OFFSET := CUR_DEFAULT_REG_FILE_OFFSET;
		--###########################

		--*******************************************************************************--
		-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
		--*******************************************************************************--

		INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH   := CUR_DEFAULT_INSTR_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
		--*******************************************************************************--

		NUM_OF_DPU_FU       : integer range 0 to MAX_NUM_FU                       := CUR_DEFAULT_NUM_DPU_FU;

		--*******************************************************************************--
		-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
		--*******************************************************************************--

		DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH                  := CUR_DEFAULT_DATA_WIDTH;
		REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH         := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE REGISTER FIELD WIDTH IN THE INSTRUCTION
		--*******************************************************************************--

		-- Width of the register field in the instruction = log_2(GEN_PUR_REG_NUM)

		REG_FIELD_WIDTH     : positive range 1 to MAX_REG_FIELD_WIDTH             := CUR_DEFAULT_REG_FIELD_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
		--*******************************************************************************--

		OPCODE_FIELD_WIDTH  : positive range 1 to MAX_OPCODE_FIELD_WIDTH          := CUR_DEFAULT_OPCODE_FIELD_WIDTH
	);

	port(

		------------------------
		-- INSTRUCTIONS FOR THE DPU UNITS -- 
		------------------------		

		instr_vector    : in  std_logic_vector(NUM_OF_DPU_FU * INSTR_WIDTH - 1 downto 0);

		------------------------
		-- DPU READ ADDRESS PORTS FOR REGISTER FILE -- 
		------------------------

		dpu_source_addr : out std_logic_vector(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		------------------------
		-- DPU READ DATA PORTS FOR REGISTER FILE -- 
		------------------------

		dpu_source_data : in  std_logic_vector(NUM_OF_DPU_FU * DATA_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- DPUs write ADDRESS PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

		dpu_write_addr  : out std_logic_vector(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- DPU WRITE DATA PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		dpu_write_data  : out std_logic_vector(NUM_OF_DPU_FU * DATA_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- DPU WRITE ENABLE PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		dpu_write_en    : out std_logic_vector(1 to NUM_OF_DPU_FU)
	);

end dpu_control;

architecture Behavioral of dpu_control is

	--===============================================================================--
	-- CONSTANTS
	--===============================================================================--

	CONSTANT BEGIN_OPCODE : positive := (INSTR_WIDTH - 1);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3) ==> opcode = conv_int(instruction_in(15 downto 13) ==> OK
	CONSTANT END_OPCODE   : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH);

	CONSTANT BEGIN_RES : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 1);
	CONSTANT END_RES   : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - REG_FIELD_WIDTH);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3, REG_FIELD_WIDTH = 4} ==> regf_res_addr(i) <= instr(i)(12 .. 9) ==> OK

	CONSTANT BEGIN_CONST : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - REG_FIELD_WIDTH - 1);

	CONSTANT BEGIN_OP_1 : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - REG_FIELD_WIDTH - 1);
	CONSTANT END_OP_1   : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 2 * REG_FIELD_WIDTH);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3, REG_FIELD_WIDTH = 4} ==> regf_1_op_addr(i) <= instr(i)(8 .. 5) ==> OK


	-- The width of the constant operand in the instruction word

	CONSTANT CONST_OP_FIELD_WIDTH : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - REG_FIELD_WIDTH);

	--===============================================================================--
	-- ADDITIONAL TYPES DECLARATIONS
	--===============================================================================--

	-- Instructions, Address and data line arrayed data types
	type t_InstrVec is array (natural range <>) of std_logic_vector(INSTR_WIDTH - 1 downto 0);
	type t_addr_array is array (integer range <>) of std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);
	type t_data_array is array (integer range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	--===============================================================================--
	--===============================================================================--

	-- Multiplexer arrayed data types
	type t_second_op_mux_sel_array is array (integer range <>) of std_logic_vector(0 downto 0);

	type t_mux_second_op_data_in_array is array (integer range <>) -- = 2 ==> ConstantOperand + RegFileOutput
	of std_logic_vector(2 * DATA_WIDTH - 1 downto 0);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Instructions for the several data path units --

	-- instructions(1) is the instruction word for the 
	-- first data path unit
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	signal instructions : t_InstrVec(1 to NUM_OF_DPU_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Constant operands signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- Decoder's constant operands for the DPUs
	signal constant_operands : t_data_array(1 to NUM_OF_DPU_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Register file signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- Register file read addresses for source operand
	signal regf_source_addr : t_addr_array(1 to NUM_OF_DPU_FU);

	-- Register file read data  for 1. and 2. operand
	signal regf_source_data : t_data_array(1 to NUM_OF_DPU_FU);

	-- Register file write addresses for result
	signal regf_write_addr : t_addr_array(1 to NUM_OF_DPU_FU);

	-- Register file write data  for result
	signal regf_write_data : t_data_array(1 to NUM_OF_DPU_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- DPU's control signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- DPU CONTROL PORTS -- 

	signal dpu_enables : t_1BitArray(1 to NUM_OF_DPU_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Input operands multiplexer signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- Intermediate signal for the input operands mux data input
	-- otherwise with signal concatenation & .. & error:
	-- "HDLParser:864 actual input signal is not a signal"

	signal intermed_second_op_mux_data_ins : t_mux_second_op_data_in_array(1 to NUM_OF_DPU_FU);

	-- Array of select signals for the first operand input multiplexers
	signal second_op_mux_selects : t_second_op_mux_sel_array(1 to NUM_OF_DPU_FU);

	signal second_op_mux_outs : t_data_array(1 to NUM_OF_DPU_FU);

	--===============================================================================--
	-- DPU COMPONENT DECLARATION --
	--===============================================================================--
	component data_path_unit
		generic(
			-- cadence translate_off		
			INSTANCE_NAME : string;
			-- cadence translate_on				
			DATA_WIDTH    : positive range 1 to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH);

		port(
			dpu_enable : in  std_logic;
			operand    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			result     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component data_path_unit;

	--===============================================================================--
	--===============================================================================--

	--===============================================================================--
	-- MULTIPLEXER COMPONENT DECLARATION --
	--===============================================================================--
	-- Simple two input to one output multiplexer for the second operand selection

	component mux_2_1 is
		generic(
			-- cadence translate_off			
			INSTANCE_NAME : string;
			-- cadence translate_on			
			DATA_WIDTH    : positive range 1 to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH
		);

		port(
			data_inputs : in  std_logic_vector(2 * DATA_WIDTH - 1 downto 0);
			sel         : in  std_logic;
			output      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component mux_2_1;

	--===============================================================================--
	--===============================================================================--


	--===============================================================================--
	-- DPU INSTRUCTION DECODER COMPONENT DECLARATION --
	--===============================================================================--

	component dpu_instr_decoder is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME       : string;
			-- cadence translate_on		

			--###################################
			--### SRECO: REGISTER FILE OFFSET ###
			RF_OFFSET           : positive range 1 to CUR_DEFAULT_MAX_REG_FILE_OFFSET       := CUR_DEFAULT_REG_FILE_OFFSET;
			--###########################

			--*******************************************************************************--
			-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
			--*******************************************************************************--

			INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH         := CUR_DEFAULT_INSTR_WIDTH;

			BEGIN_OPCODE        : positive range MIN_INSTR_WIDTH - 1 to MAX_INSTR_WIDTH - 1 := CUR_DEFAULT_INSTR_WIDTH - 1;
			END_OPCODE          : positive range 1 to MAX_INSTR_WIDTH - 1                   := CUR_DEFAULT_INSTR_WIDTH - CUR_DEFAULT_OPCODE_FIELD_WIDTH;

			BEGIN_OP_1          : positive range 1 to (MAX_INSTR_WIDTH - 3)                 := 8; -- 4 bit RegField => 16 Register
			END_OP_1            : positive range 1 to (MAX_INSTR_WIDTH - 3)                 := 5;

			BEGIN_RES           : positive range 1 to (MAX_INSTR_WIDTH - 2)                 := 12; -- 4 bit RegField => 16 Register
			END_RES             : positive range 1 to (MAX_INSTR_WIDTH - 2)                 := 9;

			BEGIN_CONST         : positive range 1 to (MAX_INSTR_WIDTH - 4)                 := 8; -- 9 bit Constant

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH                        := CUR_DEFAULT_DATA_WIDTH;
			REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH               := CUR_DEFAULT_REG_FILE_ADDR_WIDTH
		);

		port(
			dpu_enable           : out std_logic_vector(0 downto 0);

			------------------------
			-- CURRENT INSTRUCTION FOR THE DPU -- 
			------------------------		

			instruction_in       : in  std_logic_vector(INSTR_WIDTH - 1 downto 0);

			------------------------
			-- DPU READ ADDRESS PORTS FOR REGISTER FILE -- 
			------------------------

			source_op_addr       : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- DPU write ADDRESS PORT FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

			res_addr             : out std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- DPU WRITE ENABLE PORT FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			res_write_en         : out std_logic;

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- DPU CONSTANT OPERAND --
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			constant_operand     : out std_logic_vector(DATA_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- MULTIPLEXER SELECT SIGNALS -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^		 

			second_op_mux_select : out std_logic_vector(0 downto 0)
		);

	end component dpu_instr_decoder;

--===============================================================================--
--===============================================================================--


begin

	--===============================================================================--
	-- Conversions from INternal indexed array of signals to 
	-- EXternal, (big) std_logic_vector - Signals
	--===============================================================================--
	conv : FOR i in 1 to NUM_OF_DPU_FU GENERATE

		-- Assign the instructions from EXternal (big) vector to the INternal indexed instruction array
		-- so that the instruction word for the 1. dpu is under the index 1 in the instruction array:
		-- instructions(1)

		instructions(i) <= instr_vector(INSTR_WIDTH * i - 1 downto INSTR_WIDTH * (i - 1));

		-- Assign the read addresses from INternal address array to EXternal (big) vector 
		-- so that the address for the source operand of the 1. dpu is under
		-- dpu_source_addr(REG_FILE_ADDR_WIDTH -1 downto 0) 

		dpu_source_addr(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1)) <= regf_source_addr(i);

		-- Assign the register file data from EXternal (big) vector to the INternal indexed data array
		-- so that the register data for the source operand of the first DPU is under
		-- regf_source_data(1)

		regf_source_data(i) <= dpu_source_data(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1));

		-- Assign the write addresses and data from INternal address array to EXternal (big) vector 
		-- so that the write address of the result of the first dpu is under
		-- dpu_write_addr(REG_FILE_ADDR_WIDTH -1 downto 0) and the write data of the result of the first DPU
		-- is under dpu_write_data(DATA_WIDTH -1 downto 0)

		dpu_write_addr(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1)) <= regf_write_addr(i);
		dpu_write_data(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1))                   <= regf_write_data(i);

	END GENERATE;

	--===============================================================================--
	-- Layout of the GenralPurpose, Input, and Output Registers in the Register Address Space:


	-------------------------------
	-- Register {(GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG + NUM_OF_INPUT_REG + NUM_OF_FEEDBACK_FIFO -1}
	-- <==> Last FEED BACK FIFO
	-------------------------------

	-- ... --

	-------------------------------
	-- Register {(GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG + NUM_OF_INPUT_REG}
	-- <==> First FEED BACK FIFO
	-------------------------------
	-------------------------------
	-------------------------------
	-- Register {(GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG + NUM_OF_INPUT_REG -1}
	-- <==> Last input FIFO
	-------------------------------

	-- ... --

	-------------------------------
	-- Register {(GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG}
	-- <==> First input FIFO
	-------------------------------
	-------------------------------
	-- Register {(GEN_PUR_REG_NUM - 1) + NUM_OF_OUTPUT_REG}
	-- <==> Last output Register
	-------------------------------

	-- ... --

	-- Register GEN_PUR_REG_NUM 
	-- <==> First output Register
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

	--===============================================================================--
	-- Layout of the signals from InputRegisters & RegisterFile & ConstantOperand on the
	-- input multiplexers:

	-- Second Operand input multiplexer:
	--------------------------------------------
	-- |   RegFile_input      |   ConstantOp		  |
	--	|  2*d_w - 1	... d_w | data_width-1 ... 0 |
	-- |-------------------------------------------|
	-- |  		  1	 		  |			0			  |
	--------------------------------------------


	intermed : FOR i in 1 to NUM_OF_DPU_FU GENERATE
		intermed_second_op_mux_data_ins(i) <= (regf_source_data(i)(DATA_WIDTH - 1 downto 0) & constant_operands(i)(DATA_WIDTH - 1 downto 0));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--


	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- DPU COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	dpus : for i in 1 to NUM_OF_DPU_FU generate
		dpu : component data_path_unit
			generic map(
				-- cadence translate_off					
				INSTANCE_NAME => INSTANCE_NAME & "/dpu_" & Int_to_string(i),
				-- cadence translate_on						
				DATA_WIDTH    => DATA_WIDTH)
			port map(
				operand    => second_op_mux_outs(i),
				dpu_enable => dpu_enables(i)(0),
				result     => regf_write_data(i)
			);

	end generate dpus;

	--===============================================================================--
	--===============================================================================--

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- SECOND OPERAND MULTIPLEXER GENERATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	second_operands_input_mux : for i in 1 to NUM_OF_DPU_FU generate
		second_op_mux : component mux_2_1
			generic map(
				-- cadence translate_off					
				INSTANCE_NAME => INSTANCE_NAME & "/second_op_mux_" & Int_to_string(i),
				-- cadence translate_on	
				DATA_WIDTH    => DATA_WIDTH)
			port map(
				data_inputs => intermed_second_op_mux_data_ins(i),
				sel         => second_op_mux_selects(i)(0),
				output      => second_op_mux_outs(i)
			);

	end generate second_operands_input_mux;

	--===============================================================================--
	--===============================================================================--


	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- ADDER INSTRUCTION DECODERs GENERATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	dpu_in_decs : for i in 1 to NUM_OF_DPU_FU generate
		dpu_in_dec : component dpu_instr_decoder
			generic map(

				-- cadence translate_off	
				INSTANCE_NAME       => INSTANCE_NAME & "/dpu_in_dec_" & Int_to_string(i),
				-- cadence translate_on	
				--*******************************************************************************--
				-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
				--*******************************************************************************--

				INSTR_WIDTH         => INSTR_WIDTH,
				BEGIN_OPCODE        => BEGIN_OPCODE,
				END_OPCODE          => END_OPCODE,
				BEGIN_OP_1          => BEGIN_OP_1,
				END_OP_1            => END_OP_1,
				BEGIN_RES           => BEGIN_RES,
				END_RES             => END_RES,
				BEGIN_CONST         => BEGIN_CONST,

				--*******************************************************************************--
				-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
				--*******************************************************************************--

				DATA_WIDTH          => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH => REG_FILE_ADDR_WIDTH
			)
			port map(
				dpu_enable           => dpu_enables(i),

				------------------------
				-- CURRENT INSTRUCTION FOR THE DPU -- 
				------------------------		

				instruction_in       => instructions(i),

				------------------------
				-- DPU READ ADDRESS PORT FOR REGISTER FILE -- 
				------------------------

				source_op_addr       => regf_source_addr(i),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DPU write ADDRESS PORT FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				res_addr             => regf_write_addr(i),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DPU WRITE ENABLE PORT FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				res_write_en         => dpu_write_en(NUM_OF_DPU_FU - i + 1), -- INVERSED ORDER NEEDED in REG_FILE !!!


				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DPU CONSTANT OPERAND --
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				constant_operand     => constant_operands(i),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- MULTIPLEXER SELECT SIGNALS -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^		 

				second_op_mux_select => second_op_mux_selects(i)
			);

	end generate dpu_in_decs;

--===============================================================================--
--===============================================================================--


end Behavioral;
