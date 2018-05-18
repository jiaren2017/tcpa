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
-- Create Date:    14:56:07 10/17/05
-- Design Name:    
-- Module Name:    logic_control - Behavioral
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

entity logic_control is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME       : string;
		-- cadence translate_on			
		--*******************************************************************************--
		-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
		--*******************************************************************************--

		INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH := CUR_DEFAULT_INSTR_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
		--*******************************************************************************--

		NUM_OF_LOGIC_FU     : integer range 0 to MAX_NUM_FU                     := CUR_DEFAULT_NUM_LOGIC_FU;

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
		flags_vector         : out std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0); --:out t_logic_flags;

		------------------------
		-- INSTRUCTIONS FOR THE LOGIC UNITS -- 
		------------------------		

		instr_vector         : in  std_logic_vector(NUM_OF_LOGIC_FU * INSTR_WIDTH - 1 downto 0);

		------------------------
		-- LOGICS READ ADDRESS PORTS FOR REGISTER FILE -- 
		------------------------

		-- For register addressation 2 read ports for every FU is needed

		logic_1_op_read_addr : out std_logic_vector(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);
		logic_2_op_read_addr : out std_logic_vector(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		------------------------
		-- LOGICS READ DATA PORTS FOR REGISTER FILE -- 
		------------------------

		-- For register addressation 2 read ports for every FU is needed

		logic_1_op_read_data : in  std_logic_vector(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0);
		logic_2_op_read_data : in  std_logic_vector(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- LOGICS write ADDRESS PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

		logic_write_addr     : out std_logic_vector(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- LOGICS WRITE DATA PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		logic_write_data     : out std_logic_vector(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0);

		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- LOGICS WRITE ENABLE PORTS FOR REGISTER FILE -- 
		--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		logic_write_en       : out std_logic_vector(1 to NUM_OF_LOGIC_FU)
	);

end logic_control;

architecture Behavioral of logic_control is

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

	CONSTANT BEGIN_IMMED : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 2 * REG_FIELD_WIDTH - 1);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3, REG_FIELD_WIDTH = 4} ==> immediate_op <= instr(i)(4 .. 0) ==> OK

	CONSTANT BEGIN_OP_2 : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 2 * REG_FIELD_WIDTH - 1);
	-- shravan : 20120523 : END_OP_2 value can be zero, hence modifying its definition to be integer
	--CONSTANT	END_OP_2			:positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 3*REG_FIELD_WIDTH);
	CONSTANT END_OP_2   : integer  := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - 3 * REG_FIELD_WIDTH);
	-- E.G: {INSTR_WIDTH = 16, OPCODE_F_W = 3, REG_FIELD_WIDTH = 4} ==> regf_2_op_addr(i) <= instr(i)(4 .. 1) ==> OK


	-- The width of the constant operand in the instruction word

	CONSTANT CONST_OP_FIELD_WIDTH : positive := (INSTR_WIDTH - OPCODE_FIELD_WIDTH - REG_FIELD_WIDTH);

	-- The width of the second operands input multiplexer select-signal
	-- is = 2 ==> (RegFileData)) + (ImmediateOperand) 

	CONSTANT SECOND_OP_MUX_SEL_WIDTH : positive := 1;

	--===============================================================================--
	-- ADDITIONAL TYPES DECLARATIONS
	--===============================================================================--

	-- Instructions, Address and data line arrayed data types
	type t_InstrVec is array (natural range <>) of std_logic_vector(INSTR_WIDTH - 1 downto 0);
	type t_addr_array is array (integer range <>) of std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);
	type t_data_array is array (integer range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	-- Multiplexer arrayed data types
	type t_second_op_mux_sel_array is array (integer range <>) of std_logic_vector(SECOND_OP_MUX_SEL_WIDTH - 1 downto 0);

	type t_mux_second_op_data_in_array is array (integer range <>) -- = 2 ==> ImmediateOperand + RegFileOutput
	of std_logic_vector(2 * DATA_WIDTH - 1 downto 0);

	--===============================================================================--
	--===============================================================================--

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Instructions for the several logic FUs  --

	-- instructions(1) is the instruction word for the 
	-- first logic FU
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	signal instructions : t_InstrVec(1 to NUM_OF_LOGIC_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Register file signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- Register file read addresses for 1. and 2. operand
	signal regf_1_op_addr : t_addr_array(1 to NUM_OF_LOGIC_FU);
	signal regf_2_op_addr : t_addr_array(1 to NUM_OF_LOGIC_FU);

	-- Register file read data  for 1. and 2. operand
	signal regf_1_op_data : t_data_array(1 to NUM_OF_LOGIC_FU);
	signal regf_2_op_data : t_data_array(1 to NUM_OF_LOGIC_FU);

	-- Register file write addresses for result
	signal regf_res_addr : t_addr_array(1 to NUM_OF_LOGIC_FU);

	-- Register file write data  for result
	signal regf_res_data : t_data_array(1 to NUM_OF_LOGIC_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Immediate operands signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- Decoder's immediate operands for the logic FU FUs
	signal immediate_operands : t_data_array(1 to NUM_OF_LOGIC_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- logic FUs' control signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- LOGICS CONTROL PORTS -- 
	signal logic_fu_selects : t_2BitArray(1 to NUM_OF_LOGIC_FU);
	signal logic_fu_enables : t_1BitArray(1 to NUM_OF_LOGIC_FU);

	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	-- Input operands multiplexer signals --
	--"""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	-- Intermediate signal for the input operands mux data input
	-- otherwise with signal concatenation & .. & error:
	-- "HDLParser:864 actual input signal is not a signal"

	signal intermed_second_op_mux_data_ins : t_mux_second_op_data_in_array(1 to NUM_OF_LOGIC_FU);

	-- Array of select signals for the first operand input multiplexers
	signal second_op_mux_selects : t_second_op_mux_sel_array(1 to NUM_OF_LOGIC_FU);

	signal second_op_mux_outs : t_data_array(1 to NUM_OF_LOGIC_FU);

	--===============================================================================--
	-- LOGIC COMPONENT DECLARATION --
	--===============================================================================--
	component logic_fu
		generic(
			-- cadence translate_off		
			INSTANCE_NAME : string;
			-- cadence translate_on			
			DATA_WIDTH    : positive range 1 to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH);

		port(
			first_operand  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			second_operand : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			logic_enable   : in  std_logic_vector(0 downto 0);
			logic_select   : in  std_logic_vector(1 downto 0);
			result         : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			flags          : out std_logic_vector(MAX_NUM_FLAGS - 1 downto 0)
		);

	end component logic_fu;

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
	-- LOGIC INSTRUCTION DECODER COMPONENT DECLARATION --
	--===============================================================================--

	component logic_instr_decoder is
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

	end component logic_instr_decoder;

--===============================================================================--
--===============================================================================--


begin

	--===============================================================================--
	-- Conversions from INternal indexed array of signals to 
	-- EXternal, (big) std_logic_vector - Signals
	--===============================================================================--
	conv : FOR i in 1 to NUM_OF_LOGIC_FU GENERATE

		-- Assign the instructions from EXternal (big) vector to the INternal indexed instruction array
		-- so that the instruction word for the 1. logic FU is under the index 1 in the instruction array ==>
		-- instructions(1)

		instructions(i) <= instr_vector(INSTR_WIDTH * i - 1 downto INSTR_WIDTH * (i - 1));

		-- Assign the read addresses from INternal address array to EXternal (big) vector 
		-- so that the address for the first operand of the 1. logic FU is under
		-- logic_1_op_read_addr(REG_FILE_ADDR_WIDTH -1 downto 0) 

		logic_1_op_read_addr(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1)) <= regf_1_op_addr(i);
		logic_2_op_read_addr(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1)) <= regf_2_op_addr(i);

		-- Assign the register file data from EXternal (big) vector to the INternal indexed data array
		-- so that the register data for the first operand of the first logic FU is under
		-- regf_1_op_data(1)

		regf_1_op_data(i) <= logic_1_op_read_data(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1));
		regf_2_op_data(i) <= logic_2_op_read_data(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1));

		-- Assign the write addresses and data from INternal address array to EXternal (big) vector 
		-- so that the write address of the result of the first logic FU is under
		-- logic_write_addr(REG_FILE_ADDR_WIDTH -1 downto 0) and the write data of the result of the first logic FU is under
		-- logic_write_data(DATA_WIDTH -1 downto 0)

		logic_write_addr(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1)) <= regf_res_addr(i);
		logic_write_data(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1))                   <= regf_res_data(i);

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
	-- Layout of the signals from InputRegisters & RegisterFile & ImmediateOperand on the
	-- input multiplexers:

	-- Second Operand input multiplexer:
	--------------------------------------------
	-- |   RegFile_input      |   ImmediateOp		  |
	--	|  2*d_w - 1	... d_w | data_width-1 ... 0 |
	-- |-------------------------------------------|
	-- |  		  1	 		  |			0			  |
	--------------------------------------------


	intermed : FOR i in 1 to NUM_OF_LOGIC_FU GENERATE
		intermed_second_op_mux_data_ins(i) <= (regf_2_op_data(i)(DATA_WIDTH - 1 downto 0) & immediate_operands(i)(DATA_WIDTH - 1 downto 0));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- LOGIC GENERATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	logic_fus : for i in 1 to NUM_OF_LOGIC_FU generate
		logic : component logic_fu
			generic map(
				-- cadence translate_off					
				INSTANCE_NAME => INSTANCE_NAME & "/logic_" & Int_to_string(i),
				-- cadence translate_on	
				DATA_WIDTH    => DATA_WIDTH)
			port map(
				first_operand  => regf_1_op_data(i),
				second_operand => second_op_mux_outs(i),
				logic_enable   => logic_fu_enables(i),
				logic_select   => logic_fu_selects(i),
				flags          => flags_vector(MAX_NUM_FLAGS * i - 1 downto MAX_NUM_FLAGS * (i - 1)),
				result         => regf_res_data(i)
			);

	end generate logic_fus;

	--===============================================================================--
	--===============================================================================--

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- SECOND OPERAND MULTIPLEXER GENERATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	second_operands_input_mux : for i in 1 to NUM_OF_LOGIC_FU generate
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
	-- LOGIC INSTRUCTION DECODERs GENERATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	logic_in_dec : for i in 1 to NUM_OF_LOGIC_FU generate
		logic_instr_decode : component logic_instr_decoder
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME           => INSTANCE_NAME & "/logic_instr_decode_" & Int_to_string(i),
				-- cadence translate_on	
				--*******************************************************************************--
				-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
				--*******************************************************************************--

				INSTR_WIDTH             => INSTR_WIDTH,
				BEGIN_OPCODE            => BEGIN_OPCODE,
				END_OPCODE              => END_OPCODE,
				BEGIN_OP_1              => BEGIN_OP_1,
				END_OP_1                => END_OP_1,
				BEGIN_OP_2              => BEGIN_OP_2,
				END_OP_2                => END_OP_2,
				BEGIN_RES               => BEGIN_RES,
				END_RES                 => END_RES,
				BEGIN_IMMED             => BEGIN_IMMED,

				--*******************************************************************************--
				-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
				--*******************************************************************************--

				DATA_WIDTH              => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH     => REG_FILE_ADDR_WIDTH,

				--*******************************************************************************--
				-- GENERICS FOR THE WIDTH OF SECOND OP MULTIPLEXER
				--*******************************************************************************--

				-- The width of the first operands input multiplexer select-signal
				-- is log_2(NUMBER_OF_INPUT_REGISTERS + 1 (RegFileData))

				SECOND_OP_MUX_SEL_WIDTH => SECOND_OP_MUX_SEL_WIDTH
			)
			port map(

				------------------------
				-- CURRENT INSTRUCTION FOR THE LOGIC -- 
				------------------------		

				instruction_in       => instructions(i),

				------------------------
				-- LOGIC READ ADDRESS PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports are needed

				first_op_addr        => regf_1_op_addr(i),
				second_op_addr       => regf_2_op_addr(i),

				-- Operation select for the logic FU 

				logic_fu_select      => logic_fu_selects(i),

				-- Immediate operand output
				-- This output is also used as a signal for a constant, which
				-- must be loaded into a register. The width of the constant
				-- is always bigger than that of the immediate operand
				-- Thus the bigger value of DATA_WIDTH for the vector is used

				immediate_operand    => immediate_operands(i),

				-- Constant operand output

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- LOGIC write ADDRESS PORT FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				res_addr             => regf_res_addr(i),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- LOGIC WRITE ENABLE PORT FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				res_write_en         => logic_write_en(NUM_OF_LOGIC_FU - i + 1),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- MULTIPLEXER SELECT SIGNALS -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^		 

				second_op_mux_select => second_op_mux_selects(i)
			);

	end generate logic_in_dec;

--===============================================================================--
--===============================================================================--


end Behavioral;
