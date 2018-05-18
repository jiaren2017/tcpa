
 --	Package File Template
 --
 --	Purpose: This package defines supplemental types, subtypes,
 --		 constants, and functions


 library IEEE;
 use IEEE.STD_LOGIC_1164.all;
 use IEEE.STD_LOGIC_ARITH.ALL;


 library wppa_instance_v1_01_a;
 use wppa_instance_v1_01_a.ALL;
 use wppa_instance_v1_01_a.WPPE_LIB.ALL;
 use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

 package array_lib is

 constant dbg : boolean := true;--false;--true;
 --if dbg then
 --	report "!!! DBG_ASTRA: ";
 --end if;

 --*******************************************************************************--
 --*******************************************************************************--
 type t_wppe_generics_record is record


 CONFIG_REG_WIDTH       :integer range MIN_CONFIG_REG_WIDTH to MAX_CONFIG_REG_WIDTH;



 --*************************
 -- WPPE GENERICs
 --*************************

 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER OF BRANCH FLAGS
 --*******************************************************************************--

 NUM_OF_BRANCH_FLAGS :integer range 0 to 8;

 --*****************************************************************************************--
 -- GENERICS FOR THE NUMBER OF CONTROL REGISTERS, CONTROL INPUTS and CONTROL OUTPUTS
 --*****************************************************************************************--

 NUM_OF_CONTROL_REGS    :integer range 0 to MAX_NUM_CONTROL_REGS;
 NUM_OF_CONTROL_INPUTS  :integer range 0 to MAX_NUM_CONTROL_INPUTS;
 NUM_OF_CONTROL_OUTPUTS :integer range 0 to MAX_NUM_CONTROL_OUTPUTS;

 --*******************************************************************************--
 -- GENERICS FOR THE CONTROL REGISTER WIDTH --
 --*******************************************************************************--

 CTRL_REG_WIDTH			 :positive range 1 to MAX_CTRL_REG_WIDTH;

 --*******************************************************************************--
 -- GENERICS FOR THE ADDRESS WIDTH
 --*******************************************************************************--

 CTRL_REGFILE_ADDR_WIDTH	:positive range 1 to
 MAX_CTRL_REGFILE_ADDR_WIDTH;


 --*******************************************************************************--
 -- GENERICS FOR CONFIGURATION MEMORY
 --*******************************************************************************--

 SOURCE_ADDR_WIDTH	:positive range 1 to MAX_ADDR_WIDTH;
 SOURCE_DATA_WIDTH :positive range 1 to 128;

 --*******************************************************************************--
 -- Turning the ASSERT ... messages on for simulation and off for synthesis
 --*******************************************************************************--

 --	SIMULATION			:BOOLEAN;


 --*******************************************************************************--
 -- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
 --*******************************************************************************--

 INSTR_WIDTH			:positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH;

 --*******************************************************************************--
 -- GENERICS FOR THE CURRENT BRANCH INSTRUCTION WIDTH
 --*******************************************************************************--

 BRANCH_INSTR_WIDTH 	:positive range MIN_BRANCH_INSTR_WIDTH
 to MAX_BRANCH_INSTR_WIDTH;

 --*******************************************************************************--
 -- GENERICS FOR THE INSTRUCTION MEMORY SIZE
 --*******************************************************************************--

 MEM_SIZE				:positive range MIN_MEM_SIZE to MAX_MEM_SIZE;

 --*******************************************************************************--
 -- GENERICS FOR THE ADDRESS AND DATA WIDTHS
 --*******************************************************************************--

 ADDR_WIDTH			:positive range 1 to MAX_ADDR_WIDTH;
 REG_FILE_ADDR_WIDTH	:positive range 1 to MAX_REG_FILE_ADDR_WIDTH;
 DATA_WIDTH			:positive range 1 to MAX_DATA_WIDTH;

 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
 --*******************************************************************************--

 NUM_OF_ADD_FU		:integer range 0 to MAX_NUM_FU;
 NUM_OF_MUL_FU		:integer range 0 to MAX_NUM_FU;
 NUM_OF_DIV_FU		:integer range 0 to MAX_NUM_FU;
 NUM_OF_LOGIC_FU	    :integer range 0 to MAX_NUM_FU;
 NUM_OF_SHIFT_FU	    :integer range 0 to MAX_NUM_FU;
 NUM_OF_DPU_FU		:integer range 0 to MAX_NUM_FU;
 NUM_OF_CPU_FU		:integer range 0 to MAX_NUM_FU;


 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER OF INPUT AND OUTPUT REGISTERS
 --*******************************************************************************--

 NUM_OF_OUTPUT_REG	:positive range 1 to MAX_OUTPUT_REG_NUM;
 NUM_OF_INPUT_REG	:positive range 1 to MAX_INPUT_REG_NUM;

 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER OF THE GENERAL PURPOSE REGISTERS
 --*******************************************************************************--

 GEN_PUR_REG_NUM	 :integer range 0 to MAX_GEN_PUR_REG_NUM;

 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER AND SIZE OF additional FIFOs --
 --*******************************************************************************--

 NUM_OF_FEEDBACK_FIFOS     :integer range 0 to MAX_NUM_FB_FIFO;
 -- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
 TYPE_OF_FEEDBACK_FIFO_RAM :std_logic_vector(CUR_DEFAULT_NUM_FB_FIFO downto 0);
 SIZES_OF_FEEDBACK_FIFOS   :t_fifo_sizes(CUR_DEFAULT_NUM_FB_FIFO  downto 0);
 FB_FIFOS_ADDR_WIDTH		  :t_fifo_sizes(CUR_DEFAULT_NUM_FB_FIFO  downto 0);

 -- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
 TYPE_OF_INPUT_FIFO_RAM    :std_logic_vector(CUR_DEFAULT_INPUT_REG_NUM -1 downto 0);
 SIZES_OF_INPUT_FIFOS      :t_fifo_sizes(CUR_DEFAULT_INPUT_REG_NUM -1     downto 0);
 INPUT_FIFOS_ADDR_WIDTH    :t_fifo_sizes(CUR_DEFAULT_INPUT_REG_NUM -1     downto 0);

 --*******************************************************************************--
 -- GENERICS FOR THE WIDH OF ALL REGISTERS
 --*******************************************************************************--

 GEN_PUR_REG_WIDTH			:positive range 1 to MAX_GEN_PUR_REG_WIDTH;



 end record t_wppe_generics_record;
 --===============================================================================--

 CONSTANT CUR_DEFAULT_WPPE_GENERICS_RECORD	  :t_wppe_generics_record :=
 (

 CUR_DEFAULT_CONFIG_REG_WIDTH,

 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER OF BRANCH FLAGS
 --*******************************************************************************--

 CUR_DEFAULT_BRANCH_FLAGS_NUM,

 --*****************************************************************************************--
 -- GENERICS FOR THE NUMBER OF CONTROL REGISTERS, CONTROL INPUTS and CONTROL OUTPUTS
 --*****************************************************************************************--

 CUR_DEFAULT_NUM_CONTROL_REGS,
 CUR_DEFAULT_NUM_CONTROL_INPUTS,
 CUR_DEFAULT_NUM_CONTROL_OUTPUTS,

 --*******************************************************************************--
 -- GENERICS FOR THE CONTROL REGISTER WIDTH --
 --*******************************************************************************--

 CUR_DEFAULT_CTRL_REG_WIDTH,

 --*******************************************************************************--
 -- GENERICS FOR THE ADDRESS WIDTH
 --*******************************************************************************--

 CUR_DEFAULT_CTRL_REGFILE_ADDR_WIDTH,


 --*******************************************************************************--
 -- GENERICS FOR CONFIGURATION MEMORY
 --*******************************************************************************--

 CUR_DEFAULT_SOURCE_ADDR_WIDTH,
 CUR_DEFAULT_SOURCE_DATA_WIDTH,

 --*******************************************************************************--
 -- Turning the ASSERT ... messages on for simulation and off for synthesis
 --*******************************************************************************--

 --					CUR_DEFAULT_SIMULATION,


 --*******************************************************************************--
 -- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
 --*******************************************************************************--

 CUR_DEFAULT_INSTR_WIDTH,

 --*******************************************************************************--
 -- GENERICS FOR THE CURRENT BRANCH INSTRUCTION WIDTH
 --*******************************************************************************--

 CUR_DEFAULT_BRANCH_INSTR_WIDTH,

 --*******************************************************************************--
 -- GENERICS FOR THE INSTRUCTION MEMORY SIZE
 --*******************************************************************************--

 CUR_DEFAULT_MEM_SIZE,

 --*******************************************************************************--
 -- GENERICS FOR THE ADDRESS AND DATA WIDTHS
 --*******************************************************************************--

 CUR_DEFAULT_ADDR_WIDTH,
 CUR_DEFAULT_REG_FILE_ADDR_WIDTH,
 CUR_DEFAULT_DATA_WIDTH,

 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
 --*******************************************************************************--

 CUR_DEFAULT_NUM_ADD_FU,
 CUR_DEFAULT_NUM_MUL_FU,
 CUR_DEFAULT_NUM_DIV_FU,
 CUR_DEFAULT_NUM_LOGIC_FU,
 CUR_DEFAULT_NUM_SHIFT_FU,
 CUR_DEFAULT_NUM_DPU_FU,
 CUR_DEFAULT_NUM_CPU_FU,


 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER OF INPUT AND OUTPUT REGISTERS
 --*******************************************************************************--

 CUR_DEFAULT_OUTPUT_REG_NUM,
 CUR_DEFAULT_INPUT_REG_NUM,

 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER OF THE GENERAL PURPOSE REGISTERS
 --*******************************************************************************--

 CUR_DEFAULT_GEN_PUR_REG_NUM,

 --*******************************************************************************--
 -- GENERICS FOR THE NUMBER AND SIZE OF additional FIFOs --
 --*******************************************************************************--

 CUR_DEFAULT_NUM_FB_FIFO,
 -- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
 (others => '1'),
 (others => CUR_DEFAULT_FIFO_SIZE),
 (others => CUR_DEFAULT_FIFO_ADDR_WIDTH),

 -- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
 (others => '1'),
 (others => CUR_DEFAULT_FIFO_SIZE),
 (others => CUR_DEFAULT_FIFO_ADDR_WIDTH),

 --*******************************************************************************--
 -- GENERICS FOR THE WIDH OF ALL REGISTERS
 --*******************************************************************************--

 CUR_DEFAULT_GEN_PUR_REG_WIDTH

 );
 --*******************************************************************************--
 --*******************************************************************************--


 --===============================================================================--
 --===============================================================================--

 --*************************
 -- Wrapper GENERICs
 --*************************

 CONSTANT	NORTH_INPUT_WIDTH 	    :integer := 32;
 CONSTANT	NORTH_PIN_NUM			:integer := 5;

 CONSTANT	SOUTH_INPUT_WIDTH		:integer := 32;
 CONSTANT	SOUTH_PIN_NUM			:integer := 5;

 CONSTANT	EAST_INPUT_WIDTH		:integer := 32;
 CONSTANT	EAST_PIN_NUM			:integer := 5;

 CONSTANT	WEST_INPUT_WIDTH		:integer := 32;
 CONSTANT	WEST_PIN_NUM			:integer := 5;

 ------------ ICN-CTRL ------------------------
 CONSTANT	NORTH_INPUT_WIDTH_CTRL 	:integer := 1;
 CONSTANT	NORTH_PIN_NUM_CTRL		:integer := 1;

 CONSTANT	SOUTH_INPUT_WIDTH_CTRL	:integer := 1;
 CONSTANT	SOUTH_PIN_NUM_CTRL		:integer := 1;

 CONSTANT	EAST_INPUT_WIDTH_CTRL	:integer := 1;
 CONSTANT	EAST_PIN_NUM_CTRL		:integer := 1;

 CONSTANT	WEST_INPUT_WIDTH_CTRL	:integer := 1;
 CONSTANT	WEST_PIN_NUM_CTRL		:integer := 1;

 --*******************************************************************************--
 -- ADJACENCY MATRIX CONSTANTS --
 --*******************************************************************************--


 CONSTANT ADJ_MATRIX_OUTS :integer :=   SOUTH_PIN_NUM    +  -- !=! NORTH_OUTPUT_NUM
    WEST_PIN_NUM     +  -- !=! EAST_OUTPUT_NUM
    NORTH_PIN_NUM    +  -- !=! SOUTH_OUTPUT_NUM
    EAST_PIN_NUM     +  -- !=! WEST_OUTPUT_NUM
5; --CUR_DEFAULT_INPUT_REG_NUM;
 
 CONSTANT ADJ_MATRIX_INS  :integer :=   NORTH_PIN_NUM + 
    EAST_PIN_NUM  +
    SOUTH_PIN_NUM +
    WEST_PIN_NUM  +
5; --CUR_DEFAULT_OUTPUT_REG_NUM;
 
 
 type	t_adjacency_matrix is array(0 to ADJ_MATRIX_INS -1)
     of  std_logic_vector(0 to ADJ_MATRIX_OUTS -1);
 
 type  t_multi_source_info_matrix is array(0 to 6, 0 to ADJ_MATRIX_OUTS -1) of integer range -1 to 16384;
 
 type t_adj_matrix_array is array(integer range<>, integer range<>) of t_adjacency_matrix;
 type t_wppe_generics_array is array(integer range<>, integer range<>) of t_wppe_generics_record;



 --##########################################
 --====== ICN-CTRL CONSTANTS, TYPES ==========
 CONSTANT ADJ_MATRIX_OUTS_CTRL :integer :=   SOUTH_PIN_NUM_CTRL    +  -- !=! NORTH_OUTPUT_NUM_CTRL
    WEST_PIN_NUM_CTRL     +  -- !=! EAST_OUTPUT_NUM_CTRL
    NORTH_PIN_NUM_CTRL    +  -- !=! SOUTH_OUTPUT_NUM_CTRL
    EAST_PIN_NUM_CTRL     +  -- !=! WEST_OUTPUT_NUM_CTRL
2; --CUR_DEFAULT_NUM_CONTROL_INPUTS;

 CONSTANT ADJ_MATRIX_INS_CTRL  :integer :=   NORTH_PIN_NUM_CTRL +
    EAST_PIN_NUM_CTRL  +
    SOUTH_PIN_NUM_CTRL +
    WEST_PIN_NUM_CTRL  +
2; --CUR_DEFAULT_NUM_CONTROL_OUTPUTS;

 CONSTANT ADJ_MATRIX_OUTS_ALL :integer :=  ADJ_MATRIX_OUTS + ADJ_MATRIX_OUTS_CTRL;
 CONSTANT ADJ_MATRIX_INS_ALL :integer :=  ADJ_MATRIX_INS + ADJ_MATRIX_INS_CTRL;

 type	t_adjacency_matrix_ctrl is array(0 to ADJ_MATRIX_INS_CTRL -1) of  std_logic_vector(0 to ADJ_MATRIX_OUTS_CTRL -1);
 type	t_adjacency_matrix_all is array(0 to ADJ_MATRIX_INS_ALL -1) of  std_logic_vector(0 to ADJ_MATRIX_OUTS_ALL -1);

 type  t_multi_source_info_matrix_ctrl is array(0 to 6, 0 to ADJ_MATRIX_OUTS -1) of integer range -1 to 16384;

 type t_adj_matrix_array_ctrl is array(integer range<>, integer range<>) of t_adjacency_matrix_ctrl;
 type t_adj_matrix_array_all is array(integer range<>, integer range<>) of t_adjacency_matrix_all;


 --====== ICN-CTRL CONSTNTS, TYPES ==========
 --##########################################

 CONSTANT CUR_DEFAULT_ADJACENCY_MATRIX_CTRL :t_adjacency_matrix_ctrl := (others => (others => '0'));
 CONSTANT CUR_DEFAULT_ADJACENCY_MATRIX :t_adjacency_matrix := (others => (others => '0'));

 CONSTANT CUR_DEFAULT_ADJACENCY_MATRIX_CTRL_1 :t_adjacency_matrix_ctrl := (others => (others => '1'));
 CONSTANT CUR_DEFAULT_ADJACENCY_MATRIX_1 :t_adjacency_matrix := (others => (others => '1'));

 -- Layout of the adjacency matrix:
 --======================================================
 --          | N | E | S | W | Pin | ---> :OUTPUTS (1 ... x) each
 --======================================================
 --	INPUTS: (1 ... y each)
 --  |  |
 --  |  |
 -- \    /
 --  \  /
 --   \/
 -------------------------------------------------------
 --	 	  N	|   |   |   |   |     |
 -------------------------------------------------------
 --	 	  E	|   |   |   |   |     |
 -------------------------------------------------------
 --	 	  S	|   |   |   |   |     |
 -------------------------------------------------------
 --	 	  W	|   |   |   |   |     |
 -------------------------------------------------------
 --	   Pout	|   |   |   |   |     |
 --======================================================

 -- Layout of the MULTI_SOURCE_MATRIX:

 -- MULTI_SOURCE_MATRIX :t_multi_source_info_matrix := (
 --
 --	0 ==> Number of drivers for the single output signal
 --	(N2, E2, S2, W2, Pin2)
 --	 e.g. (1,  2,  0,  0,  0,  0,  0,  0,  0,  0),
 --
 --	1 ==> -- Maximum driver width for the single output signal
 --  (N2, E2, S2, W2, Pin2)
 --	e.g. (16, 16, 16, 16, 16, 16, 16, 16, 16, 16),
 --
 --	2 ==> -- Multiplexer select width for the single output signal
 --	(N2, E2, S2, W2, Pin2)
 --	e.g. ( 1,  1,  1,  1,  1,  1,  1,  1,  1,  1),
 --
 --	3 ==> -- Begin of the DATA for the current output signal in the
 --  global output_mux_ins vector for the (N2, E2, S2, W2, Pin2) outputs
 --	e.g. ( 0,  32,  0, 32,  0,  32,  0,  32,  0,  32),
 --
 --	4 ==> -- End of the DATA for the current output signal in the
 --	global output_mux_ins vector for the (N2, E2, S2, W2, Pin2) outputs
 --	e.g. ( 31, 63, 31, 63, 31,  63,  31, 63,  31,  63),
 --
 --	5 ==> -- Begin of the SELECT for the current output signal in the
 --	global mux_selects-vector for the (N2, E2, S2, W2, Pin2) outputs
 --	e.g. ( 0, 1, 2, 3, 4, 5, 6,  7,  8,  9),
 --
 --	6 ==> -- End of the SELECT for the current output signal in the
 --	global mux_selects-vector for the (N2, E2, S2, W2, Pin2) outputs
 --	e.g. ( 0, 1, 2, 3, 4, 5, 6,  7,  8,  9)
 --

 -- Calculate the ending position of the given input signal
 -- in the global multiplexer_in-vector for all input signals
 -- for the given multi-source driven output signal
 FUNCTION calculate_driver_end(ADJACENCY_MATRIX    :in t_adjacency_matrix;
   MULTI_SOURCE_MATRIX :in t_multi_source_info_matrix;
   input :in integer;
   output :in integer) RETURN integer;

 -- Calculate the beginning position of the given input signal
 -- in the global multiplexer_in-vector for all input signals
 -- for the given multi-source driven output signal
 FUNCTION calculate_driver_begin(ADJACENCY_MATRIX    :in t_adjacency_matrix;
   MULTI_SOURCE_MATRIX :in t_multi_source_info_matrix;
   input :in integer;
   output :in integer) RETURN integer;


 FUNCTION calculate_out_driver_width_sel_width_driver_num_max_driver_width(
   ADJACENCY_MATRIX    :in t_adjacency_matrix;
   NUM_OF_OUTPUT_REG   :in integer;
   GEN_PUR_REG_WIDTH   :in integer;
   output_nr :in integer;
   out_dr_width :in std_logic;
   sel :in std_logic;
   dr_num :in std_logic;
   max_dr_width :in std_logic
 ) RETURN integer;

 FUNCTION calculate_output_driver_boundaries(ADJACENCY_MATRIX    :in t_adjacency_matrix;
   OUTPUT_REG_NUM :in integer;
   GEN_PUR_REG_WIDTH :in integer;
   output_nr :in integer;
   offset    :in integer
 )
 RETURN 	integer;


 FUNCTION fill_out_the_multisource_matrix(ADJACENCY_MATRIX    :in t_adjacency_matrix;
   NUM_OF_OUTPUT_REG   :in integer;
   NUM_OF_INPUT_REG    :in integer;
   GEN_PUR_REG_WIDTH   :in integer
 ) RETURN t_multi_source_info_matrix;

 PROCEDURE fill_out_the_select_boundaries(MS_MATRIX :inout t_multi_source_info_matrix;
   NUM_OF_INPUT_REG :in integer);

 FUNCTION calculate_total_signal_width(MS_MATRIX :in t_multi_source_info_matrix;
   calc_begin :in integer; calc_end :in integer;
   sel_or_data :in std_logic) -- '0' ==> total sel width
   -- '1' ==> total data width
 RETURN integer;
 -----------------------------------------------------------------------------------------------

 --####################################
 --====== ICN-CTRL FUNCTIONS ==========

 FUNCTION get_mask_vector(MATRIX :in t_adjacency_matrix_all; is_outs_vector: boolean)
 RETURN std_logic_vector;

 FUNCTION get_adj_matrix_data(MATRIX :in t_adjacency_matrix_all)
 RETURN t_adjacency_matrix;

 FUNCTION get_adj_matrix_ctrl(MATRIX :in t_adjacency_matrix_all)
 RETURN t_adjacency_matrix_ctrl;


 function slv_to_string(inp : std_logic_vector) return string;

 -------------------------------------------------------------
 --###########################################################
 --------- CHANGED FROM ICN-DATA TO ICN-CTRL: ----------------
 FUNCTION calculate_driver_end_ctrl(ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl;
   MULTI_SOURCE_MATRIX :in t_multi_source_info_matrix_ctrl;
   input :in integer;
   output :in integer) RETURN integer;
 ----------------------------------------------------------------------------------------------
 FUNCTION calculate_driver_begin_ctrl(ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl;
   MULTI_SOURCE_MATRIX :in t_multi_source_info_matrix_ctrl;
   input :in integer;
   output :in integer) RETURN integer;
 ------------------------------------------------------------------------------------------------
 --
 FUNCTION calculate_out_driver_width_sel_width_driver_num_max_driver_width_ctrl(
   ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl;
   NUM_OF_OUTPUT_REG   :in integer;
   CTRL_REG_WIDTH   :in integer;
   output_nr :in integer;
   out_dr_width :in std_logic;
   sel :in std_logic;
   dr_num :in std_logic;
   max_dr_width :in std_logic
 ) RETURN integer;
 ------------------------------------------------------------------------------------------------
 FUNCTION calculate_output_driver_boundaries_ctrl(ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl;
   OUTPUT_REG_NUM :in integer;
   CTRL_REG_WIDTH :in integer;
   output_nr :in integer;
   offset    :in integer
 )
 RETURN 	integer;
 --
 ------------------------------------------------------------------------------------------------
 FUNCTION fill_out_the_multisource_matrix_ctrl(ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl;
   NUM_OF_OUTPUT_REG   :in integer;
   NUM_OF_INPUT_REG    :in integer;
   CTRL_REG_WIDTH   :in integer
 ) RETURN t_multi_source_info_matrix_ctrl;
 ------------------------------------------------------------------------------------------------
 PROCEDURE fill_out_the_select_boundaries_ctrl(MS_MATRIX :inout t_multi_source_info_matrix_ctrl;
   NUM_OF_INPUT_REG :in integer);
 ------------------------------------------------------------------------------------------------
 FUNCTION calculate_total_signal_width_ctrl(MS_MATRIX :in t_multi_source_info_matrix_ctrl;
   calc_begin :in integer; calc_end :in integer;
   sel_or_data :in std_logic) -- '0' ==> total sel width
   -- '1' ==> total data width
 RETURN integer;
 ----------------------------------------------------------------------------------------------
 --====== ICN-CTRL FUNCTIONS ==========
 --####################################

 end array_lib;

 package body array_lib is


 --===========================================================================
 --===========================================================================

 FUNCTION calculate_total_signal_width(MS_MATRIX :in t_multi_source_info_matrix;
   calc_begin :in integer; calc_end :in integer;
   sel_or_data :in std_logic)
 RETURN integer IS

 variable total_sel_width, total_data_width :integer;

 BEGIN

     total_sel_width  := 0;
 	total_data_width := 0;

     FOR output in calc_begin to calc_end LOOP
 --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 --			if MS_MATRIX(0, output) > 1 then
 			total_sel_width  := total_sel_width + MS_MATRIX(2, output);
 --			end if;
 --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         IF MS_MATRIX(4, output) > total_data_width THEN -- search for the maximum data width

            total_data_width := MS_MATRIX(4, output);

         END IF;

     END LOOP;

 	if sel_or_data = '0' then

 		return total_sel_width;

 	else

 		return total_data_width;

 	end if;


 END calculate_total_signal_width;

 --===========================================================================
 --===========================================================================

 PROCEDURE fill_out_the_select_boundaries(MS_MATRIX :inout t_multi_source_info_matrix;
 													  NUM_OF_INPUT_REG :in integer) IS

 variable current_begin  :integer range 0 to 4096;

 BEGIN

 	current_begin := 0;

 --===========================================================================
 -- NORTH OUTPUTS

 		FOR output in 0 to SOUTH_PIN_NUM -1 LOOP

 			if(MS_MATRIX(2, output) > 0) then

 				MS_MATRIX(5, output) := current_begin;

 					current_begin := current_begin + MS_MATRIX(2, output);

 				MS_MATRIX(6, output) := current_begin-1;

 			else

 				MS_MATRIX(5, output) := 0;
 				MS_MATRIX(6, output) := 0;


 			end if;


 	END LOOP; -- for all NORTH_OUTPUTS

 	current_begin := 0;		-- Reset the begin for the next "group" of signals

 --===========================================================================
 -- EAST OUTPUTS

 	FOR output in SOUTH_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM -1 LOOP

 			if(MS_MATRIX(2, output) > 0) then

 				MS_MATRIX(5, output) := current_begin;

 					current_begin := current_begin + MS_MATRIX(2, output);

 				MS_MATRIX(6, output) := current_begin-1;

 			else

 				MS_MATRIX(5, output) := 0;
 				MS_MATRIX(6, output) := 0;


 			end if;

 	END LOOP; -- for all east outputs

 	current_begin := 0;		-- Reset the begin for the next "group" of signals

 --===========================================================================
 -- SOUTH OUTPUTS

 	FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM
 				  to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM -1 LOOP

 			if(MS_MATRIX(2, output) > 0) then

 				MS_MATRIX(5, output) := current_begin;

 					current_begin := current_begin + MS_MATRIX(2, output);

 				MS_MATRIX(6, output) := current_begin-1;

 			else

 				MS_MATRIX(5, output) := 0;
 				MS_MATRIX(6, output) := 0;


 			end if;


 	END LOOP; -- for all SOUTH_OUTPUTS

 	current_begin := 0;		-- Reset the begin for the next "group" of signals
 
 --===========================================================================
 -- WEST OUTPUTS

  	FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM
 			  to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM -1 LOOP

 			if(MS_MATRIX(2, output) > 0) then

 				MS_MATRIX(5, output) := current_begin;

 					current_begin := current_begin + MS_MATRIX(2, output);

 				MS_MATRIX(6, output) := current_begin-1;

 			else

 				MS_MATRIX(5, output) := 0;
 				MS_MATRIX(6, output) := 0;


 			end if;


 	END LOOP; -- for all WEST_OUTPUTS

 	current_begin := 0;		-- Reset the begin for the next "group" of signals

 --===========================================================================
 -- WPPE INPUTS

 	FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM
 				  to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + NUM_OF_INPUT_REG-1 LOOP

 			if(MS_MATRIX(2, output) > 0) then

 				MS_MATRIX(5, output) := current_begin;

 					current_begin := current_begin + MS_MATRIX(2, output);

 				MS_MATRIX(6, output) := current_begin-1;

 			else

 				MS_MATRIX(5, output) := 0;
 				MS_MATRIX(6, output) := 0;


 			end if;


 	END LOOP; -- for all WPPE INPUTS

 	current_begin := 0;		-- Reset the begin for the next "group" of signals



 END fill_out_the_select_boundaries;

 --===========================================================================
 --===========================================================================

 FUNCTION calculate_output_driver_boundaries(ADJACENCY_MATRIX    :in t_adjacency_matrix;
 														OUTPUT_REG_NUM :in integer;
 														GEN_PUR_REG_WIDTH :in integer;
 														 output_nr :in integer;
 															offset :in integer  -- begin offset
 														   )
 											RETURN 	integer IS

 	variable drivers_end :integer range 0 to 4096 := 0;

 	BEGIN

 	drivers_end   := offset;

 	-------------------------------------------------------------
 	-- Going through NORTH inputs
 	FOR i in 0 to NORTH_PIN_NUM-1 LOOP

 		if ADJACENCY_MATRIX(i)(output_nr) = '1' then

 				drivers_end := drivers_end + NORTH_INPUT_WIDTH;

 		end if;

 
 	END LOOP;
    -------------------------------------------------------------
 	-- Going through EAST inputs
 	FOR i in NORTH_PIN_NUM to NORTH_PIN_NUM + EAST_PIN_NUM-1 LOOP

 		if ADJACENCY_MATRIX(i)(output_nr) = '1' then

 				drivers_end := drivers_end + EAST_INPUT_WIDTH;

 		end if;


 	END LOOP;
 	-------------------------------------------------------------
 	-- Going through SOUTH inputs
 		FOR i in NORTH_PIN_NUM + EAST_PIN_NUM
 					to NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM-1 LOOP
 
 		if ADJACENCY_MATRIX(i)(output_nr) = '1' then

 				drivers_end := drivers_end + SOUTH_INPUT_WIDTH;

 		end if;

 	END LOOP;
 	-------------------------------------------------------------
 	-- Going through WEST inputs
 	FOR i in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM
 					to NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM-1 LOOP

 		if ADJACENCY_MATRIX(i)(output_nr) = '1' then

 				drivers_end := drivers_end + WEST_INPUT_WIDTH;

 		end if;

 	END LOOP;
 	-------------------------------------------------------------
 	-- Going through WPPE outputs
 	FOR i in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM
 					to  NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM + OUTPUT_REG_NUM-1 LOOP

 		if ADJACENCY_MATRIX(i)(output_nr) = '1' then

 				drivers_end := drivers_end + GEN_PUR_REG_WIDTH;

 		end if;

 
 	END LOOP;


   	if(drivers_end > 0) then

 		return drivers_end - 1;

 	else

 		return 0;

 	end if;


 END calculate_output_driver_boundaries;


 --===========================================================================
	FUNCTION fill_out_the_multisource_matrix(	ADJACENCY_MATRIX    :in t_adjacency_matrix;																  
																	NUM_OF_OUTPUT_REG   :in integer;																		  
																	NUM_OF_INPUT_REG    :in integer;																		  
																	GEN_PUR_REG_WIDTH   :in integer																		  
																) RETURN t_multi_source_info_matrix IS																	  
																																													  
																																													  
			variable MS_MATRIX :t_multi_source_info_matrix;																											  
																																													  
			variable drivers_end :integer range 0 to 4096 := 0;																									  
			variable drivers_begin :integer range 0 to 4096 := 0;																									  
			variable new_drivers_begin :integer range 0 to 4096 := 0;																							  
																																													  
			BEGIN																																									  
																																													  
			FOR output in 0 to ADJ_MATRIX_OUTS-1 LOOP -- for all outputs																						  
																																													  
																																													  
				MS_MATRIX(0, output) := calculate_out_driver_width_sel_width_driver_num_max_driver_width(												  
													ADJACENCY_MATRIX,																											  
													NUM_OF_OUTPUT_REG,																										  
													GEN_PUR_REG_WIDTH,																										  
													output,																														  
													'0', --out_dr_width;																										  
													'0', --sel;																													  
													'1', --dr_num;																												  
													'0'  --max_dr_width																										  
												);																																	  
																																													  
				MS_MATRIX(1, output) := calculate_out_driver_width_sel_width_driver_num_max_driver_width(												  
													ADJACENCY_MATRIX,																											  
													NUM_OF_OUTPUT_REG,																										  
													GEN_PUR_REG_WIDTH,																										  
													output,																														  
													'0', --out_dr_width;																										  
													'0', --sel;																													  
													'0', --dr_num;																												  
													'1'  --max_dr_width																										  
												);																																	  
																																													  
				MS_MATRIX(2, output) := calculate_out_driver_width_sel_width_driver_num_max_driver_width(												  
													ADJACENCY_MATRIX,																											  
													NUM_OF_OUTPUT_REG,																										  
													GEN_PUR_REG_WIDTH,																										  
													output,																														  
													'0', --out_dr_width;																										  
													'1', --sel;																													  
													'0', --dr_num;																												  
													'0'  --max_dr_width																										  
												);																																	  
																																													  
																																													  
			END LOOP;	-- for all outputs																																  
																																													  
		-- Layout of the global drivers vector for NORTH or EAST or SOUTH or WEST or Pin output signals												  
		------------------------------------------------------------------------------------															  
		-- DRIVERS for the north_output_x   | 	  ...   | DRIVERS for the north_output 0																	  
		------------------------------------------------------------------------------------															  
		-- last_driver & ... & first_driver | &  ... & | last_driver & ... & first_driver																  
		------------------------------------------------------------------------------------															  
		--	Z			...					Y		|	...	  | X				...				2	1	 0																  
		------------------------------------------------------------------------------------															  
																																													  
																																													  
			FOR output in 0 to SOUTH_PIN_NUM-1 LOOP -- for all NORTH outputs																					  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries(																									  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	GEN_PUR_REG_WIDTH,																						  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
		    																																										  
				MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then																																	  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- NORTH output																																		  
																																												  
		--========================================================================																			  
		--========================================================================																			  
																																													  
				new_drivers_begin := 0; -- RESET the begin of drivers for the next 																			  
											   -- "group" = EAST outputs																									  
																																													  
		--========================================================================																			  
			FOR output in SOUTH_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM-1 LOOP -- for all EAST outputs												  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries(																									  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	GEN_PUR_REG_WIDTH,																						  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
			   MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then			  -- TODO 																											  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- EAST outputs																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
																																													  
				new_drivers_begin := 0; -- RESET the begin of drivers for the next 																			  
											   -- "group" = SOUTH outputs																									  
																																													  
		--========================================================================																			  
			FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM 																												  
									to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM-1 LOOP -- for all SOUTH outputs										  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries(																									  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	GEN_PUR_REG_WIDTH,																						  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
			   MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then			  -- TODO 																											  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- SOUTH outputs																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
																																													  
				new_drivers_begin := 0; -- RESET the begin of drivers for the next 																			  
											   -- "group" = WEST outputs																									  
																																													  
		--========================================================================																			  
			FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM 																							  
									to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM-1 LOOP -- for all WEST outputs					  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries(																									  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	GEN_PUR_REG_WIDTH,																						  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
			   MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then			  -- TODO 																											  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- WEST outputs																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
																																													  
				new_drivers_begin := 0; -- RESET the begin of drivers for the next 																			  
											   -- "group" = Pin outputs																									  
																																													  
		--========================================================================																			  
			FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM 																		  
					to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + NUM_OF_INPUT_REG -1 LOOP -- for all WPPE inputs			  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries(																									  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	GEN_PUR_REG_WIDTH,																						  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
			   MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then			  -- TODO 																											  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- WPPE inputs																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
			fill_out_the_select_boundaries(MS_MATRIX, NUM_OF_INPUT_REG);																						  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
			return MS_MATRIX;																																					  
																																													  
																																													  
		END fill_out_the_multisource_matrix;																															  
																																													  
																																													  
																																													  
																																													  
		--===========================================================================																		  
																																													  
		FUNCTION calculate_out_driver_width_sel_width_driver_num_max_driver_width(																			  
																ADJACENCY_MATRIX    :in t_adjacency_matrix; 															  
																NUM_OF_OUTPUT_REG   :in integer;																			  
																GEN_PUR_REG_WIDTH   :in integer;																			  
																output_nr  :in integer;																						  
																out_dr_width :in std_logic;																				  
																sel :in std_logic;																							  
																dr_num :in std_logic;																						  
																max_dr_width :in std_logic																					  
													 ) RETURN integer IS																										  
																																													  
					variable sel_width :integer range 0 to 31;																										  
					variable max_driver_width :integer range 0 to MAX_DATA_WIDTH;																				  
					variable curr_width :integer range 0 to 2047;																									  
																																													  
			BEGIN																																									  
																																													  
					sel_width := 0;																																			  
					max_driver_width := 0;																																	  
																																													  
				-------------------------------------------------------------																					  
				-- Going through NORTH inputs																																  
				FOR i in 0 to NORTH_PIN_NUM-1 LOOP																														  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
						sel_width := sel_width + 1;																														  
																																													  
						curr_width := curr_width + NORTH_INPUT_WIDTH;																								  
																																													  
						if NORTH_INPUT_WIDTH > max_driver_width then																									  
																																													  
								max_driver_width := NORTH_INPUT_WIDTH;																									  
																																													  
						end if;																																					  
																																													  
																																													  
					end if;																																						  
																																													  
																																													  
				END LOOP;																																						  
		-------------------------------------------------------------																							  
				-- Going through EAST inputs																																  
				FOR i in NORTH_PIN_NUM to NORTH_PIN_NUM + EAST_PIN_NUM-1 LOOP																					  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
						sel_width := sel_width + 1;																														  
																																													  
						curr_width := curr_width + EAST_INPUT_WIDTH;																									  
																																													  
						if EAST_INPUT_WIDTH > max_driver_width then																									  
																																													  
								max_driver_width := EAST_INPUT_WIDTH;																									  
																																													  
						end if;																																					  
																																													  
																																													  
					end if;																																						  
																																													  
				END LOOP;																																						  
		-------------------------------------------------------------																							  
				-- Going through SOUTH inputs																																  
				FOR i in NORTH_PIN_NUM + EAST_PIN_NUM to NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM-1 LOOP											  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
						sel_width := sel_width + 1;																														  
																																													  
						curr_width := curr_width + SOUTH_INPUT_WIDTH;																								  
																																													  
						if SOUTH_INPUT_WIDTH > max_driver_width then																									  
																																													  
								max_driver_width := SOUTH_INPUT_WIDTH;																									  
																																													  
						end if;																																					  
																																													  
																																													  
					end if;																																						  
																																													  
				END LOOP;																																						  
		-------------------------------------------------------------																							  
				-- Going through WEST inputs																																  
				FOR i in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM 																							  
									to NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM-1 LOOP													  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
						sel_width := sel_width + 1;																														  
																																													  
						curr_width := curr_width + WEST_INPUT_WIDTH;																									  
																																													  
						if WEST_INPUT_WIDTH > max_driver_width then																									  
																																													  
								max_driver_width := WEST_INPUT_WIDTH;																									  
																																													  
						end if;																																					  
																																													  
					end if;																																						  
																																													  
				END LOOP;																																						  
		-------------------------------------------------------------																							  
				-- Going through Pout inputs																																  
				FOR i in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM 																		  
								to NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM + NUM_OF_OUTPUT_REG -1 LOOP							  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
					sel_width := sel_width + 1;																															  
																																													  
					curr_width := curr_width + GEN_PUR_REG_WIDTH;																									  
																																													  
					if GEN_PUR_REG_WIDTH > max_driver_width then																										  
																																													  
								max_driver_width := GEN_PUR_REG_WIDTH;																									  
																																													  
						end if;																																					  
																																													  
																																													  
					end if;																																						  
																																													  
				END LOOP;																																						  
																																													  
				if(sel = '1') then																																			  
																																													  
					return log_width(sel_width);																															  
																																													  
				elsif (max_dr_width = '1') then																															  
																																													  
					return max_driver_width;																																  
																																													  
				elsif (out_dr_width = '1') then																															  
																																													  
					return curr_width;																																		  
																																													  
				elsif (dr_num = '1') then-- sel_width = number of drivers for the given output signal													  
																																													  
					return sel_width;																																			  
																																													  
				else																																								  
																																													  
					return -2;																																					  
																																													  
				end if;																																							  
																																													  
		END calculate_out_driver_width_sel_width_driver_num_max_driver_width;																				  
																																													  
		--===========================================================================																		  
		FUNCTION calculate_driver_end(ADJACENCY_MATRIX    :in t_adjacency_matrix; 																			  
												  MULTI_SOURCE_MATRIX :in t_multi_source_info_matrix; 															  
												  input :in integer; 																										  
												  output :in integer) RETURN integer IS																				  
																																													  
			variable position :integer;																																	  
																																													  
			BEGIN																																									  
																																													  
				position := 0;																																					  
																																													  
				for i in 0 to input loop 																																	  
																																													  
						position := position + 																																  
							conv_integer(ADJACENCY_MATRIX(i)(output))*MULTI_SOURCE_MATRIX(1, output); -- data_width for the input signal		  
																																													  
			  end loop;																																							  
																																													  
				if(position + MULTI_SOURCE_MATRIX(3, output) > 0) then  																							  
																																													  
					return position-1 + 																																		  
							MULTI_SOURCE_MATRIX(3, output); -- BEGIN offset in MULTI_SOURCE_MATRIX(3, output) !!-- to get the BEGIN of the Driver position 
																																													  
				else																																								  
					  																																								  
					return MULTI_SOURCE_MATRIX(3, output);																												  
																																													  
				end if;																																							  
																																													  
		END calculate_driver_end;																																			  
		--===========================================================================																		  
																																													  
		FUNCTION calculate_driver_begin(ADJACENCY_MATRIX    :in t_adjacency_matrix; 																		  
												  MULTI_SOURCE_MATRIX :in t_multi_source_info_matrix; 															  
												  input :in integer; 																										  
												  output :in integer) RETURN integer IS																				  
																																													  
			variable position :integer;																																	  
																																													  
			BEGIN																																									  
																																													  
				position := 0;																																					  
																																													  
				if (input > 0) then																																			  
																																													  
					for i in 0 to input -1 loop 																															  
																																													  
						position := position + 																																  
							conv_integer(ADJACENCY_MATRIX(i)(output))*MULTI_SOURCE_MATRIX(1, output); -- data_width for the input signal		  
					end loop;																																					  
																																													  
																																													  
					return position 								-- to get the BEGIN of the Driver position													  
						 + MULTI_SOURCE_MATRIX(3, output); -- BEGIN offset in MULTI_SOURCE_MATRIX(3, output) !!										  
																																													  
																																													  
				else																																								  
																																													  
					return MULTI_SOURCE_MATRIX(3, output); -- BEGIN offset in MULTI_SOURCE_MATRIX(3, output) !!										  
																																													  
				end if;																																							  
																																													  
																																													  
		END calculate_driver_begin;																																		  
																																													  
				--####################################	 
				--====== ICN-CTRL FUNCTIONS ==========	 
				--------------------------------------------------------------------------------------	 
					FUNCTION get_mask_vector(MATRIX :in t_adjacency_matrix_all; is_outs_vector: boolean) 
									RETURN std_logic_vector IS																 
																																	 
						variable ptr: integer := 0; --:= N_Data;														 
						variable mask_outs: std_logic_vector (0 to ADJ_MATRIX_OUTS_ALL-1);					 
						variable mask_ins: std_logic_vector (0 to ADJ_MATRIX_INS_ALL-1);						 
																																	 
																																	 
					BEGIN																											 
																																	 
						if is_outs_vector then																				 
																																	 
							for i in 0 to SOUTH_PIN_NUM-1 loop  														 
								mask_outs(i) := '1'; 																	 	 
							end loop;																							 
																																	 
							for i in SOUTH_PIN_NUM 																			 
							to       SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL-1 											 
							loop  																	  							 
								mask_outs(i) := '0'; 																		 
							end loop;																							 
																																	
							for i in SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL 												 
									to       SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									 
									         WEST_PIN_NUM -1 																 
									loop  					  																	 
										mask_outs(i) := '1'; 																
									end loop;																					
																																	
									for i in SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									 
									         WEST_PIN_NUM 																	
									to       SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									 
									         WEST_PIN_NUM  + WEST_PIN_NUM_CTRL -1 									 
									loop  													  									 
										mask_outs(i) := '0'; 																
									end loop;																					
																																	
																																	
																																	
									for i in SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									 
									         WEST_PIN_NUM  + WEST_PIN_NUM_CTRL										
									to  SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
									    WEST_PIN_NUM  + WEST_PIN_NUM_CTRL  + 											
										 NORTH_PIN_NUM-1 																		
								   loop  								  														
										mask_outs(i) := '1'; 																
									end loop;																					
																																	
									for i in SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									
									         WEST_PIN_NUM  + WEST_PIN_NUM_CTRL + 									
												NORTH_PIN_NUM									  								
									to SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
									   WEST_PIN_NUM  + WEST_PIN_NUM_CTRL  + 											
										NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL-1 											
									loop  	  																					
										mask_outs(i) := '0'; 																
									end loop;																					
																																	
									for i in SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									
									         WEST_PIN_NUM  + WEST_PIN_NUM_CTRL + 									
												NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL 										
									to SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
									   WEST_PIN_NUM  + WEST_PIN_NUM_CTRL + 											
										NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
										EAST_PIN_NUM-1 																		
									loop  																						
										mask_outs(i) := '1'; 																
									end loop;																					
																																	
									for i in SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									
									         WEST_PIN_NUM  + WEST_PIN_NUM_CTRL  + 									
												NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
												EAST_PIN_NUM 																	
									to SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
									   WEST_PIN_NUM  + WEST_PIN_NUM_CTRL  + 											
										NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
										EAST_PIN_NUM  + EAST_PIN_NUM_CTRL-1 											
									loop  																			  			
										mask_outs(i) := '0'; 																
									end loop;																					
																																	
																																	
									for i in SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									
									         WEST_PIN_NUM  + WEST_PIN_NUM_CTRL  + 									
												NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
												EAST_PIN_NUM  + EAST_PIN_NUM_CTRL 										
									to SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
									   WEST_PIN_NUM  + WEST_PIN_NUM_CTRL  + 											
										NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
										EAST_PIN_NUM  + EAST_PIN_NUM_CTRL  + 											
										CUR_DEFAULT_INPUT_REG_NUM-1 														
									loop  									  													
										mask_outs(i) := '1'; 																
									end loop;																					
																																	
									for i in SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									
									         WEST_PIN_NUM  + WEST_PIN_NUM_CTRL  + 									
												NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
												EAST_PIN_NUM  + EAST_PIN_NUM_CTRL  + 									
												CUR_DEFAULT_INPUT_REG_NUM 												  	
									to SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
									   WEST_PIN_NUM  + WEST_PIN_NUM_CTRL  + 											
										NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
										EAST_PIN_NUM  + EAST_PIN_NUM_CTRL  + 											
										CUR_DEFAULT_INPUT_REG_NUM + CUR_DEFAULT_NUM_CONTROL_INPUTS-1 			
									loop  																						
										mask_outs(i) := '0'; 																
									end loop;																					
																																	
									return mask_outs;																			
																																	
								else																								
																																	
									for i in 0 to NORTH_PIN_NUM-1 loop  												
										mask_ins(i) := '1'; 																	
									end loop;																					
																																	
									for i in NORTH_PIN_NUM 																	
									to NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL-1 											
									loop  																	  					
										mask_ins(i) := '0'; 																	
									end loop;																					
																																	
									for i in NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL 										
									to  NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
									    EAST_PIN_NUM-1 																		
									loop  					  																	
										mask_ins(i) := '1'; 																	
									end loop;																					
																																	
									for i in NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
									         EAST_PIN_NUM 																	
									to NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
									   EAST_PIN_NUM  + EAST_PIN_NUM_CTRL-1 											
									loop  													  									
										mask_ins(i) := '0'; 																	
									end loop;																					
																																	
																																	
									for i in NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
									         EAST_PIN_NUM  + EAST_PIN_NUM_CTRL										
									to NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
									   EAST_PIN_NUM  + EAST_PIN_NUM_CTRL  + 											
										SOUTH_PIN_NUM-1 																		
									loop  								  														
										mask_ins(i) := '1'; 																	
									end loop;																					
																																	
									for i in NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
									         EAST_PIN_NUM  + EAST_PIN_NUM_CTRL  + 									
												SOUTH_PIN_NUM									  								
									to NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
									   EAST_PIN_NUM  + EAST_PIN_NUM_CTRL + 											
										SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL-1 											
									loop  	  																					
										mask_ins(i) := '0'; 																	
									end loop;																					
																																	
																																	
									for i in NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
									         EAST_PIN_NUM  + EAST_PIN_NUM_CTRL + 									
												SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL		  								
									to NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
									   EAST_PIN_NUM  + EAST_PIN_NUM_CTRL  + 											
										SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
										WEST_PIN_NUM-1 																		
									loop  																						
										mask_ins(i) := '1'; 																	
									end loop;																					
																																	
									for i in NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
									         EAST_PIN_NUM  + EAST_PIN_NUM_CTRL + 									
												SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									
												WEST_PIN_NUM																	
									to NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
									   EAST_PIN_NUM  + EAST_PIN_NUM_CTRL + 											
										SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
										WEST_PIN_NUM  + WEST_PIN_NUM_CTRL-1 											
									loop  																			  			
										mask_ins(i) := '0'; 																	
									end loop;																					
																																	
																																	
									for i in NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
									         EAST_PIN_NUM  + EAST_PIN_NUM_CTRL + 									
												SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									
												WEST_PIN_NUM + WEST_PIN_NUM_CTRL 										
									to NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
									   EAST_PIN_NUM  + EAST_PIN_NUM_CTRL + 											
										SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
										WEST_PIN_NUM + WEST_PIN_NUM_CTRL + 												
										CUR_DEFAULT_OUTPUT_REG_NUM -1 													
									loop  									  													
										mask_ins(i) := '1'; 																	
									end loop;																					
																																	
									for i in NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 									
									         EAST_PIN_NUM  + EAST_PIN_NUM_CTRL + 									
												SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 									
												WEST_PIN_NUM  + WEST_PIN_NUM_CTRL + 									
												CUR_DEFAULT_OUTPUT_REG_NUM 												
									to NORTH_PIN_NUM + NORTH_PIN_NUM_CTRL + 											
									   EAST_PIN_NUM  + EAST_PIN_NUM_CTRL + 											
										SOUTH_PIN_NUM + SOUTH_PIN_NUM_CTRL + 											
										WEST_PIN_NUM  + WEST_PIN_NUM_CTRL + 											
										CUR_DEFAULT_OUTPUT_REG_NUM	+ CUR_DEFAULT_NUM_CONTROL_OUTPUTS-1 		
									loop  																						
										mask_ins(i) := '0'; 																	
									end loop;																					
																																	
									return mask_ins;																			
								end if;																							
																																	
							END  get_mask_vector;																			
																												            
		---------------------------------------------------------------																						  
		FUNCTION get_adj_matrix_data(MATRIX :in t_adjacency_matrix_all)																						  
				RETURN t_adjacency_matrix IS																																  
																																													  
			variable ptr_outs		: integer := -1;--0;																													  
			variable ptr_ins		: integer := -1;--0;																													  
			variable mask_outs	: std_logic_vector (0 to ADJ_MATRIX_OUTS_ALL-1);																			  
			variable mask_ins		: std_logic_vector (0 to ADJ_MATRIX_INS_ALL-1);																				  
			variable adj_matrix	: t_adjacency_matrix;																												  
		BEGIN																																										  
																																													  
			mask_outs := get_mask_vector(MATRIX, true);																												  
			mask_ins := get_mask_vector(MATRIX, false);																												  
																																													  
		--if dbg then																																							  
		--	report "!!! DBG_ASTRA: FUNCTION get_adj_matrix_data:";																								  
		--	report "!!! DBG_ASTRA: mask_outs: " & slv_to_string(mask_outs);																					  
		--	report "!!! DBG_ASTRA: mask_ins:  " & slv_to_string(mask_ins);																						  
		--end if;																																								  
																																													  
			for j in 0 to ADJ_MATRIX_INS_ALL-1 loop																													  
																																													  
				if mask_ins(j) = '1' then																																	  
					ptr_ins := ptr_ins + 1;																																	  
				end if;																																							  
																																													  
				for i in 0 to ADJ_MATRIX_OUTS_ALL-1 loop																												  
																																													  
					if mask_ins(j) = '1' and mask_outs(i) = '1' then																								  
						ptr_outs := ptr_outs + 1;																															  
		-------------																																							  
		--if dbg then																																							  
		--REPORT "!!! DBG_ASTRA:  adj_matrix(" & integer'image(ptr_ins) &  ")(" & integer'image(ptr_outs) 											  
		--	& ") := MATRIX(" & integer'image(j) & ")(" & integer'image(i) & ")";  																			  
		--end if;																																								  
		--------							                                                    
 -- IF (ptr_ins < 	ADJ_MATRIX_INS) AND                                                      
 --        (ptr_outs < 	ADJ_MATRIX_OUTS) THEN				                                      
						adj_matrix(ptr_ins)(ptr_outs) := MATRIX(j)(i);																								  
 -- END IF; 
																																													  
					end if;																																						  
																																													  
				end loop;																																						  
				ptr_outs := -1;																																				  
			end loop;																																							  
																																													  
			return adj_matrix;																																				  
																																													  
		END get_adj_matrix_data;																																			  
		---------------------------------------------------------------																						  
		FUNCTION get_adj_matrix_ctrl(MATRIX :in t_adjacency_matrix_all)																						  
				RETURN t_adjacency_matrix_ctrl IS																														  
																																													  
			variable ptr_outs		: integer := -1;--0;																													  
			variable ptr_ins		: integer := -1;--0;																													  
			variable mask_outs	: std_logic_vector (0 to ADJ_MATRIX_OUTS_ALL-1);																			  
			variable mask_ins		: std_logic_vector (0 to ADJ_MATRIX_INS_ALL-1);																				  
			variable adj_matrix	: t_adjacency_matrix_ctrl;																											  
		BEGIN																																										  
																																													  
			mask_outs := get_mask_vector(MATRIX, true);																												  
			mask_ins := get_mask_vector(MATRIX, false);																												  
																																													  
		--if dbg then																																							  
		--	report "!!! DBG_ASTRA: FUNCTION get_adj_matrix_ctrl:";																								  
		--	report "!!! DBG_ASTRA: mask_outs: " & slv_to_string(mask_outs);																					  
		--	report "!!! DBG_ASTRA: mask_ins:  " & slv_to_string(mask_ins);																						  
		--end if;																																								  
																																													  
			for j in 0 to ADJ_MATRIX_INS_ALL-1 loop																													  
																																													  
				if mask_ins(j) = '0' then																																	  
					ptr_ins := ptr_ins + 1;																																	  
				end if;																																							  
																																													  
				for i in 0 to ADJ_MATRIX_OUTS_ALL-1 loop																												  
																																													  
					if mask_ins(j) = '0' and mask_outs(i) = '0' then																								  
						ptr_outs := ptr_outs + 1;																															  
		-------------																																							  
		--if dbg then																																							  
		--REPORT "!!! DBG_ASTRA:  adj_matrix(" & integer'image(ptr_ins) &  ")(" & integer'image(ptr_outs) 											  
		--	& ") := MATRIX(" & integer'image(j) & ")(" & integer'image(i) & ")";  																			  
		--end if;																																								  
		--------																																									  
 --IF (ptr_ins < 	ADJ_MATRIX_INS_CTRL) AND                                                      
 --        (ptr_outs < 	ADJ_MATRIX_OUTS_CTRL) THEN				                                      
						adj_matrix(ptr_ins)(ptr_outs) := MATRIX(j)(i);																								  
																																													  
	--				end if;																																						  
 END IF; 
																																													  
				end loop;																																						  
				ptr_outs := -1;																																				  
			end loop;																																							  
																																													  
			return adj_matrix;																																				  
																																													  
		END get_adj_matrix_ctrl;																																			  
																																													  
		----------------------------------------------------------------																						  
		function slv_to_string(inp : std_logic_vector) return string	is																						  
			alias vec : std_logic_vector(1 to inp'length) is inp;																									  
			variable result : string(vec'range);																														  
		begin																																										  
			for i in vec'range loop																																			  
		--		result(i) := to_char(vec(i));																																  
				if vec(i) = '1' then																																			  
					result(i) := '1';																																			  
				elsif	vec(i) = '0' then																																		  
					result(i) := '0';																																			  
				else																																								  
					result(i) := '?';																																			  
				end if;																																							  
			end loop;																																							  
			return result;																																						  
		end slv_to_string;																																					  
																																													  
		----																																										  
		---- convert a std_logic_vector to a string																													  
		----																																										  
		--function to_string(inp : std_logic_vector)																													  
		--return string																																						  
		--is																																										  
		--alias vec : std_logic_vector(1 to inp'length) is inp;																									  
		--variable result : string(vec'range);																															  
		--begin																																									  
		--for i in vec'range loop																																			  
		--result(i) := to_char(vec(i));																																	  
		--end loop;																																								  
		--return result;																																						  
		--end;																																									  
																																													  
																																													  
		--###########################################################																							  
		--------- CHANGED FROM ICN-DATA TO ICN-CTRL BEGIN: ----------																							  
																																													  
		FUNCTION calculate_total_signal_width_ctrl(MS_MATRIX :in t_multi_source_info_matrix_ctrl; 													  
														  calc_begin :in integer; calc_end :in integer;																  
														  sel_or_data :in std_logic)																						  
							RETURN integer IS																																	  
																																													  
				variable total_sel_width, total_data_width :integer;																								  
																																													  
		BEGIN																																										  
																																													  
				total_sel_width  := 0;																																		  
				total_data_width := 0;																																		  
																																													  
				FOR output in calc_begin to calc_end LOOP																												  
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!																													  
		--			if MS_MATRIX(0, output) > 1 then																														  
						total_sel_width  := total_sel_width + MS_MATRIX(2, output);																				  
		--			end if;																																						  
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!																												  
					IF MS_MATRIX(4, output) > total_data_width THEN -- search for the maximum data width												  
																																													  
						total_data_width := MS_MATRIX(4, output);																										  
																																													  
					END IF;																																						  
																																													  
				END LOOP;																																						  
																																													  
				if sel_or_data = '0' then																																	  
																																													  
					return total_sel_width;																																	  
																																													  
				else																																								  
																																													  
					return total_data_width;																																  
																																													  
				end if;																																							  
																																													  
																																													  
		END calculate_total_signal_width_ctrl;																															  
		--																																											  
		----===========================================================================																	  
		----===========================================================================																	  
		--																																											  
		----------- CHANGED FROM ICN-DATA TO ICN-CTRL ----------------																							  
		PROCEDURE fill_out_the_select_boundaries_ctrl(MS_MATRIX :inout t_multi_source_info_matrix_ctrl;												  
															  NUM_OF_INPUT_REG :in integer) IS																			  
																																													  
			variable current_begin  :integer range 0 to 4096;																										  
																																													  
			BEGIN																																									  
																																													  
				current_begin := 0;																																			  
																																													  
		--===========================================================================																		  
		-- NORTH OUTPUTS																																						  
																																													  
				FOR output in 0 to SOUTH_PIN_NUM_CTRL -1 LOOP																										  
																																													  
						if(MS_MATRIX(2, output) > 0) then																												  
																																													  
							MS_MATRIX(5, output) := current_begin;																										  
																																													  
								current_begin := current_begin + MS_MATRIX(2, output);																			  
																																													  
							MS_MATRIX(6, output) := current_begin-1;																									  
																																													  
						else																																						  
																																													  
							MS_MATRIX(5, output) := 0;																														  
							MS_MATRIX(6, output) := 0;																														  
																																													  
																																													  
						end if;																																					  
																																													  
																																													  
				END LOOP; -- for all NORTH_OUTPUTS																														  
																																													  
				current_begin := 0;		-- Reset the begin for the next "group" of signals																	  
																																													  
		--===========================================================================																		  
		-- EAST OUTPUTS																																						  
																																													  
				FOR output in SOUTH_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL -1 LOOP														  
																																													  
						if(MS_MATRIX(2, output) > 0) then																												  
																																													  
							MS_MATRIX(5, output) := current_begin;																										  
																																													  
								current_begin := current_begin + MS_MATRIX(2, output);																			  
																																													  
							MS_MATRIX(6, output) := current_begin-1;																									  
																																													  
						else																																						  
																																													  
							MS_MATRIX(5, output) := 0;																														  
							MS_MATRIX(6, output) := 0;																														  
																																													  
																																													  
						end if;																																					  
																																													  
				END LOOP; -- for all east outputs																														  
																																													  
				current_begin := 0;		-- Reset the begin for the next "group" of signals																	  
																																													  
		--===========================================================================																		  
		-- SOUTH OUTPUTS																																						  
																																													  
				FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL 																								  
							  to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL -1 LOOP														  
																																													  
						if(MS_MATRIX(2, output) > 0) then																												  
																																													  
							MS_MATRIX(5, output) := current_begin;																										  
																																													  
								current_begin := current_begin + MS_MATRIX(2, output);																			  
																																													  
							MS_MATRIX(6, output) := current_begin-1;																									  
																																													  
						else																																						  
																																													  
							MS_MATRIX(5, output) := 0;																														  
							MS_MATRIX(6, output) := 0;																														  
																																													  
																																													  
						end if;																																					  
																																													  
																																													  
				END LOOP; -- for all SOUTH_OUTPUTS																														  
																																													  
				current_begin := 0;		-- Reset the begin for the next "group" of signals																	  
																																													  
		--===========================================================================																		  
		-- WEST OUTPUTS																																						  
																																													  
				FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL																	  
							  to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL -1 LOOP								  
																																													  
						if(MS_MATRIX(2, output) > 0) then																												  
																																													  
							MS_MATRIX(5, output) := current_begin;																										  
																																													  
								current_begin := current_begin + MS_MATRIX(2, output);																			  
																																													  
							MS_MATRIX(6, output) := current_begin-1;																									  
																																													  
						else																																						  
																																													  
							MS_MATRIX(5, output) := 0;																														  
							MS_MATRIX(6, output) := 0;																														  
																																													  
																																													  
						end if;																																					  
																																													  
																																													  
				END LOOP; -- for all WEST_OUTPUTS																														  
																																													  
				current_begin := 0;		-- Reset the begin for the next "group" of signals																	  
																																													  
		--===========================================================================																		  
		-- WPPE INPUTS																																							  
																																													  
				FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL										  
							  to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL										  
									+ NUM_OF_INPUT_REG-1 LOOP																												  
																																													  
						if(MS_MATRIX(2, output) > 0) then																												  
																																													  
							MS_MATRIX(5, output) := current_begin;																										  
																																													  
								current_begin := current_begin + MS_MATRIX(2, output);																			  
																																													  
							MS_MATRIX(6, output) := current_begin-1;																									  
																																													  
						else																																						  
																																													  
							MS_MATRIX(5, output) := 0;																														  
							MS_MATRIX(6, output) := 0;																														  
																																													  
																																													  
						end if;																																					  
																																													  
																																													  
				END LOOP; -- for all WPPE INPUTS																															  
																																													  
				current_begin := 0;		-- Reset the begin for the next "group" of signals																	  
																																													  
																																													  
																																													  
		END fill_out_the_select_boundaries_ctrl;																														  
		--																																											  
		----===========================================================================																	  
		----===========================================================================																	  
		----------- CHANGED FROM ICN-DATA TO ICN-CTRL ----------------																							  
		FUNCTION calculate_output_driver_boundaries_ctrl(ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl;											  
																	OUTPUT_REG_NUM :in integer;																			  
																	CTRL_REG_WIDTH :in integer;																			  
																	 output_nr :in integer;																					  
																		offset :in integer  -- begin offset																  
																	   )																											  
														RETURN 	integer IS																									  
																																													  
				variable drivers_end :integer range 0 to 4096 := 0;																								  
																																													  
				BEGIN																																								  
																																													  
				drivers_end   := offset;																																	  
																																													  
				-------------------------------------------------------------																					  
				-- Going through NORTH inputs																																  
				FOR i in 0 to NORTH_PIN_NUM_CTRL-1 LOOP																												  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
							drivers_end := drivers_end + NORTH_INPUT_WIDTH_CTRL;																					  
																																													  
					end if;																																						  
																																													  
																																													  
				END LOOP;																																						  
			   -------------------------------------------------------------																					  
				-- Going through EAST inputs																																  
				FOR i in NORTH_PIN_NUM_CTRL to NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL-1 LOOP																  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
							drivers_end := drivers_end + EAST_INPUT_WIDTH_CTRL;																					  
																																													  
					end if;																																						  
																																													  
																																													  
				END LOOP;																																						  
				-------------------------------------------------------------																					  
				-- Going through SOUTH inputs																																  
				FOR i in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL 																									  
								to NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL-1 LOOP														  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
							drivers_end := drivers_end + SOUTH_INPUT_WIDTH_CTRL;																					  
																																													  
					end if;																																						  
																																													  
				END LOOP;																																						  
				-------------------------------------------------------------																					  
				-- Going through WEST inputs																																  
				FOR i in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL 																		  
								to NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL-1 LOOP								  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
							drivers_end := drivers_end + WEST_INPUT_WIDTH_CTRL;																					  
																																													  
					end if;																																						  
																																													  
				END LOOP;																																						  
				-------------------------------------------------------------																					  
				-- Going through WPPE outputs																																  
				FOR i in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL 												  
								to  NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL										  
										+ OUTPUT_REG_NUM-1 LOOP																												  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
							drivers_end := drivers_end + CTRL_REG_WIDTH;																								  
																																													  
					end if;																																						  
																																													  
																																													  
				END LOOP;																																						  
																																													  
																																													  
			  	if(drivers_end > 0) then																																	  
																																													  
					return drivers_end - 1;																																	  
																																													  
				else																																								  
																																													  
					return 0;																																					  
																																													  
				end if;																																							  
																																													  
																																													  
		END calculate_output_driver_boundaries_ctrl;																													  
		--																																											  
		--																																											  
		----===========================================================================																	  
		--#############################################################################																	  
																																													  
		----------- CHANGED FROM ICN-DATA TO ICN-CTRL ----------------																							  
		FUNCTION fill_out_the_multisource_matrix_ctrl(	ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl;											  
																	NUM_OF_OUTPUT_REG   :in integer;																		  
																	NUM_OF_INPUT_REG    :in integer;																		  
																	CTRL_REG_WIDTH   :in integer																			  
																) RETURN t_multi_source_info_matrix_ctrl IS															  
																																													  
			variable MS_MATRIX :t_multi_source_info_matrix_ctrl;																									  
																																													  
			variable drivers_end :integer range 0 to 4096 := 0;																									  
			variable drivers_begin :integer range 0 to 4096 := 0;																									  
			variable new_drivers_begin :integer range 0 to 4096 := 0;																							  
																																													  
			BEGIN																																									  
																																													  
			FOR output in 0 to ADJ_MATRIX_OUTS_CTRL-1 LOOP -- for all outputs																					  
																																													  
																																													  
				MS_MATRIX(0, output) := calculate_out_driver_width_sel_width_driver_num_max_driver_width_ctrl(										  
													ADJACENCY_MATRIX,																											  
													NUM_OF_OUTPUT_REG,																										  
													CTRL_REG_WIDTH,																											  
													output,																														  
													'0', --out_dr_width;																										  
													'0', --sel;																													  
													'1', --dr_num;																												  
													'0'  --max_dr_width																										  
												);																																	  
																																													  
				MS_MATRIX(1, output) := calculate_out_driver_width_sel_width_driver_num_max_driver_width_ctrl(										  
													ADJACENCY_MATRIX,																											  
													NUM_OF_OUTPUT_REG,																										  
													CTRL_REG_WIDTH,																											  
													output,																														  
													'0', --out_dr_width;																										  
													'0', --sel;																													  
													'0', --dr_num;																												  
													'1'  --max_dr_width																										  
												);																																	  
																																													  
				MS_MATRIX(2, output) := calculate_out_driver_width_sel_width_driver_num_max_driver_width_ctrl(										  
													ADJACENCY_MATRIX,																											  
													NUM_OF_OUTPUT_REG,																										  
													CTRL_REG_WIDTH,																											  
													output,																														  
													'0', --out_dr_width;																										  
													'1', --sel;																													  
													'0', --dr_num;																												  
													'0'  --max_dr_width																										  
												);																																	  
																																													  
																																													  
			END LOOP;	-- for all outputs																																  
																																													  
		-- Layout of the global drivers vector for NORTH or EAST or SOUTH or WEST or Pin output signals												  
		------------------------------------------------------------------------------------															  
		-- DRIVERS for the north_output_x   | 	  ...   | DRIVERS for the north_output 0																	  
		------------------------------------------------------------------------------------															  
		-- last_driver & ... & first_driver | &  ... & | last_driver & ... & first_driver																  
		------------------------------------------------------------------------------------															  
		--	Z			...					Y		|	...	  | X				...				2	1	 0																  
		------------------------------------------------------------------------------------															  
																																													  
			FOR output in 0 to SOUTH_PIN_NUM_CTRL-1 LOOP -- for all NORTH outputs																			  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries_ctrl(																							  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	CTRL_REG_WIDTH,																							  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
		    																																										  
				MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then																																	  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
			END LOOP; -- NORTH output																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
				new_drivers_begin := 0; -- RESET the begin of drivers for the next 																			  
											   -- "group" = EAST outputs																									  
																																													  
		--========================================================================																			  
			FOR output in SOUTH_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL-1 LOOP -- for all EAST outputs							  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries_ctrl(																							  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	CTRL_REG_WIDTH,																							  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
			   MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then			  -- TODO 																											  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- EAST outputs																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
				new_drivers_begin := 0; -- RESET the begin of drivers for the next 																			  
											   -- "group" = SOUTH outputs																									  
																																													  
		--========================================================================																			  
			FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL 																									  
									to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL-1 LOOP -- for all SOUTH outputs					  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries_ctrl(																							  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	CTRL_REG_WIDTH,																							  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
			   MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then			  -- TODO 																											  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- SOUTH outputs																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
				new_drivers_begin := 0; -- RESET the begin of drivers for the next 																			  
											   -- "group" = WEST outputs																									  
		--========================================================================																			  
			FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL 																		  
									to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL																  
											+ EAST_PIN_NUM_CTRL-1 LOOP -- for all WEST outputs																		  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries_ctrl(																							  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	CTRL_REG_WIDTH,																							  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
			   MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then			  -- TODO 																											  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- WEST outputs																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
				new_drivers_begin := 0; -- RESET the begin of drivers for the next 																			  
												-- "group" = Pin outputs																									  
		--========================================================================																			  
			FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL 											  
					to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL													  
							+ NUM_OF_INPUT_REG -1 LOOP -- for all WPPE inputs																						  
																																													  
				drivers_begin := new_drivers_begin;																														  
				drivers_end   := new_drivers_begin;																														  
																																													  
				drivers_end := calculate_output_driver_boundaries_ctrl(																							  
				 													ADJACENCY_MATRIX,																							  
																	NUM_OF_OUTPUT_REG,																						  
																	CTRL_REG_WIDTH,																							  
																	output,																										  
																	drivers_begin -- as offset																				  
																);																													  
																																													  
			   MS_MATRIX(3, output) :=	drivers_begin;																													  
				MS_MATRIX(4, output) := drivers_end;																													  
																																													  
				if( drivers_end > 0) then			  -- TODO 																											  
																																													  
					new_drivers_begin := drivers_end + 1;																												  
																																													  
				else																																								  
																																													  
					new_drivers_begin := 0;																																	  
																																													  
				end if;																																							  
																																													  
																																													  
			END LOOP; -- WPPE inputs																																		  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
			fill_out_the_select_boundaries_ctrl(MS_MATRIX, NUM_OF_INPUT_REG);																					  
																																													  
		--========================================================================																			  
		--========================================================================																			  
																																													  
			return MS_MATRIX;																																					  
																																													  
																																													  
		END fill_out_the_multisource_matrix_ctrl;																														  
		--===========================================================================																		  
		--###########################################################################																		  
		--===========================================================================																		  
		--																																											  
		--																																											  
		----===========================================================================																	  
		----------- CHANGED FROM ICN-DATA TO ICN-CTRL ----------------																							  
		FUNCTION calculate_out_driver_width_sel_width_driver_num_max_driver_width_ctrl(																	  
																ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl; 													  
																NUM_OF_OUTPUT_REG   :in integer;																			  
																CTRL_REG_WIDTH   :in integer;																				  
																output_nr  :in integer;																						  
																out_dr_width :in std_logic;																				  
																sel :in std_logic;																							  
																dr_num :in std_logic;																						  
																max_dr_width :in std_logic																					  
													 ) RETURN integer IS																										  
																																													  
					variable sel_width :integer range 0 to 31;																										  
					variable max_driver_width :integer range 0 to MAX_DATA_WIDTH;																				  
					variable curr_width :integer range 0 to 2047;																									  
																																													  
			BEGIN																																									  
																																													  
					sel_width := 0;																																			  
					max_driver_width := 0;																																	  
																																													  
				-------------------------------------------------------------																					  
				-- Going through NORTH inputs																																  
				FOR i in 0 to NORTH_PIN_NUM_CTRL-1 LOOP																												  
																																													  
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										  
																																													  
						sel_width := sel_width + 1;																														  
																																													  
						curr_width := curr_width + NORTH_INPUT_WIDTH_CTRL;																							  
																																													  
						if NORTH_INPUT_WIDTH_CTRL > max_driver_width then																							  
																																													  
								max_driver_width := NORTH_INPUT_WIDTH_CTRL;																							  
																																													  
						end if;																																					  
																																													  
																																													  
					end if;																																						  
																																													  
																																													  
				END LOOP;																																						  
		-------------------------------------------------------------																							 
				-- Going through EAST inputs																																 
				FOR i in NORTH_PIN_NUM_CTRL to NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL-1 LOOP																 
																																													 
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										 
																																													 
						sel_width := sel_width + 1;																														 
																																													 
						curr_width := curr_width + EAST_INPUT_WIDTH_CTRL;																							 
																																													 
						if EAST_INPUT_WIDTH_CTRL > max_driver_width then																							 
																																													 
								max_driver_width := EAST_INPUT_WIDTH_CTRL;																							 
																																													 
						end if;																																					 
																																													 
																																													 
					end if;																																						 
																																													 
				END LOOP;																																						 
		-------------------------------------------------------------																							 
				-- Going through SOUTH inputs																																 
				FOR i in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL																										 
					to NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL-1 LOOP																	 
																																													 
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										 
																																													 
						sel_width := sel_width + 1;																														 
																																													 
						curr_width := curr_width + SOUTH_INPUT_WIDTH_CTRL;																							 
																																													 
						if SOUTH_INPUT_WIDTH_CTRL > max_driver_width then																							 
																																													 
								max_driver_width := SOUTH_INPUT_WIDTH_CTRL;																							 
																																													 
						end if;																																					 
																																													 
																																													 
					end if;																																						 
																																													 
				END LOOP;																																						 
		-------------------------------------------------------------																							 
				-- Going through WEST inputs																																 
				FOR i in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL 																		 
									to NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL-1 LOOP							 
																																													 
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										 
																																													 
						sel_width := sel_width + 1;																														 
																																													 
						curr_width := curr_width + WEST_INPUT_WIDTH_CTRL;																							 
																																													 
						if WEST_INPUT_WIDTH_CTRL > max_driver_width then																							 
																																													 
								max_driver_width := WEST_INPUT_WIDTH_CTRL;																							 
																																													 
						end if;																																					 
																																													 
					end if;																																						 
																																													 
				END LOOP;																																						 
		-------------------------------------------------------------																							 
				-- Going through Pout inputs																																 
				FOR i in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL 												 
								to NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL																	 
									+ WEST_PIN_NUM_CTRL + NUM_OF_OUTPUT_REG -1 LOOP																					 
																																													 
					if ADJACENCY_MATRIX(i)(output_nr) = '1' then																										 
																																													 
					sel_width := sel_width + 1;																															 
																																													 
					curr_width := curr_width + CTRL_REG_WIDTH;																										 
																																													 
					if CTRL_REG_WIDTH > max_driver_width then																											 
																																													 
								max_driver_width := CTRL_REG_WIDTH;																										 
																																													 
						end if;																																					 
																																													 
																																													 
					end if;																																						 
																																													 
				END LOOP;																																						 
																																													 
				if(sel = '1') then																																			 
																																													 
					return log_width(sel_width);																															 
																																													 
				elsif (max_dr_width = '1') then																															 
																																													 
					return max_driver_width;																																 
																																													 
				elsif (out_dr_width = '1') then																															 
																																													 
					return curr_width;																																		 
																																													 
				elsif (dr_num = '1') then-- sel_width = number of drivers for the given output signal													 
																																													 
					return sel_width;																																			 
																																													 
				else																																								 
																																													 
					return -2;																																					 
																																													 
				end if;																																							 
																																													 
		END calculate_out_driver_width_sel_width_driver_num_max_driver_width_ctrl;																			 
																																													 
		--===========================================================================																		 
		--------- CHANGED FROM ICN-DATA TO ICN-CTRL ----------------																							 
		FUNCTION calculate_driver_end_ctrl(ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl; 															 
												  MULTI_SOURCE_MATRIX :in t_multi_source_info_matrix_ctrl; 														 
												  input :in integer; 																										 
												  output :in integer) RETURN integer IS																				 
																																													 
			variable position :integer;																																	 
																																													 
			BEGIN																																									 
																																													 
				position := 0;																																					 
																																													 
				for i in 0 to input loop 																																	 
																																													 
						position := position + 																																 
							conv_integer(ADJACENCY_MATRIX(i)(output))*MULTI_SOURCE_MATRIX(1, output); -- data_width for the input signal		 
																																													 
			  end loop;																																							 
																																													 
				if(position + MULTI_SOURCE_MATRIX(3, output) > 0) then  																							 
																																													 
					return position-1 + 																																		 
							MULTI_SOURCE_MATRIX(3, output); -- BEGIN offset in MULTI_SOURCE_MATRIX(3, output) !!-- to get the BEGIN of the Driver position 
																																													 
				else																																								 
					  																																								 
					return MULTI_SOURCE_MATRIX(3, output);																												 
																																													 
				end if;																																							 
																																													 
		END calculate_driver_end_ctrl;																																	 
		--===========================================================================																		 
		--------- CHANGED FROM ICN-DATA TO ICN-CTRL ----------------																							 
		FUNCTION calculate_driver_begin_ctrl(ADJACENCY_MATRIX    :in t_adjacency_matrix_ctrl; 															 
												  MULTI_SOURCE_MATRIX :in t_multi_source_info_matrix_ctrl; 														 
												  input :in integer; 																										 
												  output :in integer) RETURN integer IS																				 
																																													 
			variable position :integer;																																	 
																																													 
			BEGIN																																									 
																																													 
				position := 0;																																					 
																																													 
				if (input > 0) then																																			 
																																													 
					for i in 0 to input -1 loop 																															 
																																													 
						position := position + 																																 
							conv_integer(ADJACENCY_MATRIX(i)(output))*MULTI_SOURCE_MATRIX(1, output); -- data_width for the input signal		 
					end loop;																																					 
																																													 
																																													 
					return position 								-- to get the BEGIN of the Driver position													 
						 + MULTI_SOURCE_MATRIX(3, output); -- BEGIN offset in MULTI_SOURCE_MATRIX(3, output) !!										 
																																													 
																																													 
				else																																								 
																																													 
					return MULTI_SOURCE_MATRIX(3, output); -- BEGIN offset in MULTI_SOURCE_MATRIX(3, output) !!										 
																																													 
				end if;																																							 
																																													 
																																													 
		END calculate_driver_begin_ctrl;																																	 
																																													 
		--------- CHANGED FROM ICN-DATA TO ICN-CTRL END-------------- 																							 
		--###########################################################																							 
																																													 
		--====== ICN-CTRL FUNCTIONS ==========																															 
		--####################################																															 
																																													 
	 																																												 
		end array_lib;
