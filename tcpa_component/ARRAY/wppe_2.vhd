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
-- Create Date:    11:03:30 09/13/05
-- Design Name:    
-- Module Name:    wppe_2 - Behavioral
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
Library UNISIM;
use UNISIM.vcomponents.all;
-- pragma translate_off
-- cadence translate_on

----library CADENCE;
----use cadence.attributes.all;
-- pragma translate_on

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;

use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;
use wppa_instance_v1_01_a.INVASIC_LIB.ALL;

entity wppe_2 is
	generic(

		--Ericles:
		N                    : integer                := 0;
		M                    : integer                := 0;

		-- cadence translate_off	
		INSTANCE_NAME        : string                 := "???";
		-- cadence translate_on				
		--*************************
		-- Weakly Programmable Processing Element's (WPPE) GENERICs
		--*************************

		WPPE_GENERICS_RECORD : t_wppe_generics_record := CUR_DEFAULT_WPPE_GENERICS_RECORD

	--*****************************************************************************************--

	);

	port(
		set_to_config                 : in  std_logic;
		ff_start_detection            : in  std_logic;

		pc_debug_out                  : out std_logic_vector(WPPE_GENERICS_RECORD.ADDR_WIDTH - 1 downto 0);

		input_registers               : in  std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG * WPPE_GENERICS_RECORD.DATA_WIDTH - 1 downto 0);
		output_registers              : out std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG * WPPE_GENERICS_RECORD.DATA_WIDTH - 1 downto 0);

		ctrl_inputs                   : in  std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS * WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
		ctrl_outputs                  : out std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS * WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

		input_fifos_write_en          : in  std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1 downto 0);

		config_mem_data               : in  std_logic_vector(WPPE_GENERICS_RECORD.SOURCE_DATA_WIDTH - 1 downto 0);

		--Ericles Sousa on 16 Dec 2014: setting the configuration_done signal. I will be connected to the top file
		configuration_done            : out std_logic;
		mask                          : in std_logic_vector(WPPE_GENERICS_RECORD.DATA_WIDTH-1 downto 0);
		fu_sel                        : in std_logic_vector(CUR_DEFAULT_NUM_OF_FUS-1 downto 0); 
		pe_sel                        : in std_logic;
		error_flag                    : out std_logic;
		error_diagnosis               : out std_logic_vector(MAX_NUM_ERROR_DIAGNOSIS-1 downto 0);
		vliw_config_en                : in std_logic;
		icn_config_en                 : in std_logic;
		common_config_reset           : in std_logic;
		ctrl_programmable_input_depth : in  t_ctrl_programmable_input_depth;
		en_programmable_fd_depth      : in  t_en_programmable_input_fd_depth;
		programmable_fd_depth         : in  t_programmable_input_fd_depth;
		count_down                    : in  std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto 0);
		enable_tcpa                   : in  std_logic;
		config_reg_we                 : out std_logic;
		config_reg_data               : out std_logic_vector(WPPE_GENERICS_RECORD.CONFIG_REG_WIDTH - 1 downto 0);
		config_reg_addr               : out std_logic_vector(2 downto 0);

		clk_in, rst                      : in  std_logic
	);

-- pragma translate_off
-- cadence translate_on
----attribute TEMPLATE of wppe_2: entity is TRUE;
-- pragma translate_on

end wppe_2;

architecture Behavioral of wppe_2 is
	signal clk : std_logic;

	----*******************************************************************************--
	--		-- GENERIC FOR THE WIDTH OF THE INTERCONNECT CONFIGURATION REGISTER
	--		-- IN THE INTERCONNECT WRAPPER COMPONENT
	----*******************************************************************************--

	CONSTANT CONFIG_REG_WIDTH : positive := WPPE_GENERICS_RECORD.CONFIG_REG_WIDTH;

	----*******************************************************************************--
	--		-- GENERICS FOR THE NUMBER OF BRANCH FLAGS
	----*******************************************************************************--
	--
	CONSTANT NUM_OF_BRANCH_FLAGS     : integer  := WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS;
	--
	----*****************************************************************************************--
	--		-- GENERICS FOR THE NUMBER OF CONTROL REGISTERS, CONTROL INPUTS and CONTROL OUTPUTS
	----*****************************************************************************************--
	--
	CONSTANT NUM_OF_CONTROL_REGS     : integer  := WPPE_GENERICS_RECORD.NUM_OF_CONTROL_REGS;
	CONSTANT NUM_OF_CONTROL_INPUTS   : integer  := WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS;
	CONSTANT NUM_OF_CONTROL_OUTPUTS  : integer  := WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS;
	--
	----*******************************************************************************--
	--		-- GENERICS FOR THE CONTROL REGISTER WIDTH --
	----*******************************************************************************--
	--
	CONSTANT CTRL_REG_WIDTH          : positive := WPPE_GENERICS_RECORD.CTRL_REG_WIDTH;
	--			
	----*******************************************************************************--
	--		-- GENERICS FOR THE ADDRESS WIDTH
	----*******************************************************************************--
	--
	CONSTANT CTRL_REGFILE_ADDR_WIDTH : positive := WPPE_GENERICS_RECORD.CTRL_REGFILE_ADDR_WIDTH;
	--
	--
	----*******************************************************************************--
	--		-- GENERICS FOR CONFIGURATION MEMORY
	----*******************************************************************************--
	--
	CONSTANT SOURCE_ADDR_WIDTH       : positive := WPPE_GENERICS_RECORD.SOURCE_ADDR_WIDTH;
	CONSTANT SOURCE_DATA_WIDTH       : positive := WPPE_GENERICS_RECORD.SOURCE_DATA_WIDTH;
	--		
	----*******************************************************************************--
	--		-- Turning the ASSERT ... messages on for simulation and off for synthesis
	----*******************************************************************************--
	--
	----	CONSTANT	SIMULATION	:BOOLEAN := WPPE_GENERICS_RECORD.SIMULATION;
	--
	----*******************************************************************************--
	--		-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
	----*******************************************************************************--
	--
	CONSTANT INSTR_WIDTH             : positive := WPPE_GENERICS_RECORD.INSTR_WIDTH;
	--
	----*******************************************************************************--
	--		-- GENERICS FOR THE CURRENT BRANCH INSTRUCTION WIDTH
	----*******************************************************************************--
	--
	CONSTANT BRANCH_INSTR_WIDTH      : positive := WPPE_GENERICS_RECORD.BRANCH_INSTR_WIDTH;
	--
	----*******************************************************************************--
	--		-- GENERICS FOR THE INSTRUCTION MEMORY SIZE
	----*******************************************************************************--
	--
	CONSTANT MEM_SIZE                : positive := WPPE_GENERICS_RECORD.MEM_SIZE;
	--
	----*******************************************************************************--
	--		-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
	----*******************************************************************************--
	--
	CONSTANT ADDR_WIDTH              : positive := WPPE_GENERICS_RECORD.ADDR_WIDTH;
	CONSTANT DATA_WIDTH              : positive := WPPE_GENERICS_RECORD.DATA_WIDTH;
	--
	CONSTANT REG_FILE_ADDR_WIDTH     : positive := WPPE_GENERICS_RECORD.REG_FILE_ADDR_WIDTH;
	--		
	----*******************************************************************************--
	--		-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
	----*******************************************************************************--
	--	
	CONSTANT NUM_OF_ADD_FU           : integer  := WPPE_GENERICS_RECORD.NUM_OF_ADD_FU;
	CONSTANT NUM_OF_MUL_FU           : integer  := WPPE_GENERICS_RECORD.NUM_OF_MUL_FU;
	CONSTANT NUM_OF_DIV_FU           : integer  := WPPE_GENERICS_RECORD.NUM_OF_DIV_FU;
	CONSTANT NUM_OF_LOGIC_FU         : integer  := WPPE_GENERICS_RECORD.NUM_OF_LOGIC_FU;
	CONSTANT NUM_OF_SHIFT_FU         : integer  := WPPE_GENERICS_RECORD.NUM_OF_SHIFT_FU;
	CONSTANT NUM_OF_DPU_FU           : integer  := WPPE_GENERICS_RECORD.NUM_OF_DPU_FU;
	CONSTANT NUM_OF_CPU_FU           : integer  := WPPE_GENERICS_RECORD.NUM_OF_CPU_FU;
	CONSTANT NUM_OF_FUS              : integer  := CUR_DEFAULT_NUM_OF_FUS;
	--		
	----*******************************************************************************--
	--	  -- GENERICS FOR THE NUMBER OF INPUT AND OUTPUT REGISTERS 
	----*******************************************************************************--
	--
	CONSTANT NUM_OF_OUTPUT_REG       : positive := WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG;
	CONSTANT NUM_OF_INPUT_REG        : positive := WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG;
	--
	----*******************************************************************************--
	--		-- GENERICS FOR THE NUMBER OF THE GENERAL PURPOSE REGISTERS
	----*******************************************************************************--
	--
	CONSTANT GEN_PUR_REG_NUM         : integer  := WPPE_GENERICS_RECORD.GEN_PUR_REG_NUM;
	--
	----*******************************************************************************--
	--		-- GENERICS FOR THE NUMBER AND SIZE OF additional FIFOs --
	----*******************************************************************************--
	--	 
	CONSTANT NUM_OF_FEEDBACK_FIFOS   : integer  := WPPE_GENERICS_RECORD.NUM_OF_FEEDBACK_FIFOS;
	--	  -- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM

	-- shravan : 20120316 : TYPE_OF_FEEDBACK_FIFO_RAM bit width computation corrected, subtract 1 from NUM_OF_FEEDBACK_FIFOS
	--CONSTANT TYPE_OF_FEEDBACK_FIFO_RAM :std_logic_vector(NUM_OF_FEEDBACK_FIFOS  downto 0) 
	--										:= WPPE_GENERICS_RECORD.TYPE_OF_FEEDBACK_FIFO_RAM;

	CONSTANT TYPE_OF_FEEDBACK_FIFO_RAM : std_logic_vector(NUM_OF_FEEDBACK_FIFOS - 1 downto 0) := WPPE_GENERICS_RECORD.TYPE_OF_FEEDBACK_FIFO_RAM;

	-- shravan : 20120316 : SIZES_OF_FEEDBACK_FIFO_RAM bit width computation corrected, subtract 1 from NUM_OF_FEEDBACK_FIFOS
	--CONSTANT SIZES_OF_FEEDBACK_FIFOS :t_fifo_sizes(NUM_OF_FEEDBACK_FIFOS  downto 0)  
	--										:= WPPE_GENERICS_RECORD.SIZES_OF_FEEDBACK_FIFOS;
	CONSTANT SIZES_OF_FEEDBACK_FIFOS : t_fifo_sizes(NUM_OF_FEEDBACK_FIFOS - 1 downto 0) := WPPE_GENERICS_RECORD.SIZES_OF_FEEDBACK_FIFOS;

	-- shravan : 20120316 : FB_FIFO_ADDR_WIDTH bit width computation corrected, subtract 1 from NUM_OF_FEEDBACK_FIFOS
	--CONSTANT FB_FIFOS_ADDR_WIDTH	:t_fifo_sizes(NUM_OF_FEEDBACK_FIFOS  downto 0) 
	--										:= WPPE_GENERICS_RECORD.FB_FIFOS_ADDR_WIDTH;

	CONSTANT FB_FIFOS_ADDR_WIDTH : t_fifo_sizes(NUM_OF_FEEDBACK_FIFOS - 1 downto 0) := WPPE_GENERICS_RECORD.FB_FIFOS_ADDR_WIDTH;

	--
	--	  -- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
	CONSTANT TYPE_OF_INPUT_FIFO_RAM : std_logic_vector(NUM_OF_INPUT_REG - 1 downto 0) := WPPE_GENERICS_RECORD.TYPE_OF_INPUT_FIFO_RAM;
	CONSTANT SIZES_OF_INPUT_FIFOS   : t_fifo_sizes(NUM_OF_INPUT_REG - 1 downto 0)     := WPPE_GENERICS_RECORD.SIZES_OF_INPUT_FIFOS;
	CONSTANT INPUT_FIFOS_ADDR_WIDTH : t_fifo_sizes(NUM_OF_INPUT_REG - 1 downto 0)     := WPPE_GENERICS_RECORD.INPUT_FIFOS_ADDR_WIDTH;
	--
	--
	----*******************************************************************************--
	--		-- GENERICS FOR THE WIDH OF ALL REGISTERS
	----*******************************************************************************--
	--
	CONSTANT GEN_PUR_REG_WIDTH      : positive                                        := WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH;

	--### SRECO: COMMON OFFSET = REGFILE SIZE
	CONSTANT RF_OFFSET : positive := (GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG + NUM_OF_INPUT_REG + NUM_OF_FEEDBACK_FIFOS);
	--================================================================================--
	-- 		CHECKING THE GLOBAL GENERICS FILE WPPE_2.VHD
	--================================================================================--
	-- cadence translate_off	
	FUNCTION check_local_generics RETURN BOOLEAN IS
		CONSTANT new_line : STRING(1 TO 1) := (1 => lf); -- For assertion reports
	BEGIN
		-- errors

		--===============================================================================--		
		ASSERT (MIN_INSTR_WIDTH <= INSTR_WIDTH AND INSTR_WIDTH <= MAX_INSTR_WIDTH)
			REPORT new_line & "===========================================================================================" & new_line & "ERROR in wppe_2.vhd : Instruction width: INSTR_WIDTH is > MAX_INSTR_WIDTH defined in wppe_lib.vhd" & new_line &
			"===========================================================================================" & new_line
			SEVERITY ERROR;

		--===============================================================================--		

		ASSERT (DATA_WIDTH <= MAX_DATA_WIDTH)
			REPORT new_line & "===========================================================================================" & new_line & "ERROR in wppe_2.vhd : Data width: DATA_WIDTH is > MAX_DATA_WIDTH defined in wppe_lib.vhd" & new_line &
			"===========================================================================================" & new_line
			SEVERITY ERROR;

		--===============================================================================--			

		ASSERT (ADDR_WIDTH <= MAX_ADDR_WIDTH)
			REPORT new_line & "===========================================================================================" & new_line & "ERROR wwppe_2.vhd : Address width: ADDR_WIDTH is > MAX_ADDR_WIDTH defined in wppe_lib.vhd" & new_line &
			"===========================================================================================" & new_line
			SEVERITY ERROR;

		--===============================================================================--		

		ASSERT (GEN_PUR_REG_NUM = (2 ** REG_FILE_ADDR_WIDTH - NUM_OF_INPUT_REG - NUM_OF_OUTPUT_REG))
			REPORT new_line & "===========================================================================================" & new_line & "ERROR in wppe_2.vhd : 2**REG_FILE_ADDR_WIDTH != INPUT_REG_NUM +" & new_line & "OUTPUT_REG_NUM + GEN_PUR_REG_NUM " & new_line &
			"Address width of the register file does not match the number of registers" & new_line & "===========================================================================================" & new_line
			SEVERITY ERROR;

		--===============================================================================--		

		ASSERT (MEM_SIZE = (2 ** ADDR_WIDTH))
			REPORT new_line & "===========================================================================================" & new_line & "ERROR in wppe_2.vhd : RAM Address width does not match the RAM size" & new_line & "MEM_SIZE != 2**ADDR_WIDTH " & new_line &
			"===========================================================================================" & new_line
			SEVERITY ERROR;

		--===============================================================================--		

		ASSERT (GEN_PUR_REG_WIDTH = DATA_WIDTH)
			REPORT new_line & "===========================================================================================" & new_line & "WARNING in wppe_2.vhd : the width of the registers varies from the data width of the entity" & new_line & "GEN_PUR_REG_WIDTH != DATA_WIDTH " & new_line &
			"===========================================================================================" & new_line
			SEVERITY WARNING;

		RETURN true;
	END check_local_generics;
	-- cadence translate_on	

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- CONSTANTS DECLARATION--
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	CONSTANT NUM_OF_ADDERS_NOT_NULL : integer := check_if_null(NUM_OF_ADD_FU);
	CONSTANT TOTAL_CTRL_REGS_NUM    : integer := (NUM_OF_CONTROL_INPUTS + NUM_OF_CONTROL_OUTPUTS); -- + NUM_OF_CONTROL_REGS);

	CONSTANT SUM_OF_FU : integer := NUM_OF_ADD_FU + NUM_OF_MUL_FU + NUM_OF_DIV_FU + NUM_OF_LOGIC_FU + NUM_OF_SHIFT_FU + NUM_OF_DPU_FU;

	CONSTANT BEGIN_OPCODE : positive := (INSTR_WIDTH - 1);
	CONSTANT END_OPCODE   : positive := (INSTR_WIDTH - CUR_DEFAULT_OPCODE_FIELD_WIDTH);

	CONSTANT BEGIN_BRANCH : positive := END_OPCODE - 1;

	------------------------------------------------------------------------
	-- Constants for the SELECT signals for the BRANCH FLAGS multiplexers
	------------------------------------------------------------------------

	-- to select the current ADDER FU flag from the NUM_OF_ADD_FU possible
	CONSTANT ADDER_FU_SEL_WIDTH : integer := log_width(NUM_OF_ADD_FU);

	-- 4 flags at each ADDER UNIT: ZERO-FLAG, NEG-FLAG, OVERFLOW-FLAG, CARRY-FLAG
	CONSTANT CUR_FLAG_SEL_WIDTH : integer := log_width(4 * NUM_OF_ADDERS_NOT_NULL + NUM_OF_CONTROL_REGS + NUM_OF_CONTROL_INPUTS);

	--TOTAL WIDTH of the FLAG_SELECT-FIELD in the BRANCH INSTRUCTION for one of the NUM_OF_BRANCH_FLAGS branch flags																																      
	CONSTANT TOTAL_FLAG_SEL_WIDTH : integer := 4 * ADDER_FU_SEL_WIDTH + CUR_FLAG_SEL_WIDTH;

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- INTERNAL TYPES DECLARATION
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	type t_data_array is array (integer range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal sig_ctrl_outputs : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS * WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

	--##############################################################################
	--    CLOCK GATING SIGNAL CONNECTION
	--##############################################################################

	signal MEMORY_gated_clock       : std_logic := '0'; -- FOR INSTRUCTION MEMORY OF WPPE	  
	signal REVERSED_gated_clock     : std_logic := '0'; -- FOR FUNCTIONAL LOGIC OF WPPE
	signal gated_clock              : std_logic := '0'; -- FOR RECONFIGRATION LOGIC OF WPPE	
	signal loader_gated_clock       : std_logic := '0'; -- FOR RECONFIGRATION LOGIC OF WPPE	
	signal LOADER_configuring_reset : std_logic := '0'; -- DELAYED configuring_reseg signal
	-- for proper WPPE functional logic
	-- initialization.
	signal clk_gate_enable          : std_logic := '0'; -- <=> registered LOADER_configuring_reset
	signal NEG_clk_gate_enable      : std_logic := '0';
	signal mem_clk_gate_enable      : std_logic := '0';
	signal loader_clk_gate_enable   : std_logic := '0';
	signal loader_idle              : std_logic := '0';

	--##############################################################################
	--##############################################################################


	signal zero_signal : std_logic;
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- VLIW INSTRUCTION VECTOR COMING FROM THE RAM MEMORY 
	-- AND THE WRITE ENABLE VECTOR FOR THE REGISTER FILE --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal instructions_vector : std_logic_vector(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH downto 0);
	signal regf_write_enables  : std_logic_vector(SUM_OF_FU downto 0);

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE ADDERS CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal sum_instructions_vector : std_logic_vector(NUM_OF_ADD_FU * INSTR_WIDTH downto 0);

	signal sum_1_op_read_addr : std_logic_vector(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal sum_1_op_read_data : std_logic_vector(NUM_OF_ADD_FU * DATA_WIDTH downto 0);

	signal sum_2_op_read_addr : std_logic_vector(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal sum_2_op_read_data : std_logic_vector(NUM_OF_ADD_FU * DATA_WIDTH downto 0);

	signal sum_selects : t_2BitArray(0 to NUM_OF_ADD_FU);
	signal sum_enables : t_1BitArray(0 to NUM_OF_ADD_FU);

	signal sum_regf_write_addr : std_logic_vector(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal sum_regf_write_data : std_logic_vector(NUM_OF_ADD_FU * DATA_WIDTH downto 0);

	signal sum_regf_wes : std_logic_vector(NUM_OF_ADD_FU downto 0);

	signal sum_flags        : t_4BitArray(0 to NUM_OF_ADD_FU);
	--signal sum_flags_vector		  :std_logic_vector(4*NUM_OF_ADD_FU downto 0);
	signal sum_flags_vector : std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0) := (others=>'0');
	--:t_adder_flags;

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE INPUTS of the BRANCH_FLAGS multiplexers --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal carry_flags    : std_logic_vector(NUM_OF_BRANCH_FLAGS downto 0);
	signal overflow_flags : std_logic_vector(NUM_OF_BRANCH_FLAGS downto 0);
	signal negative_flags : std_logic_vector(NUM_OF_BRANCH_FLAGS downto 0);
	signal zero_flags     : std_logic_vector(NUM_OF_BRANCH_FLAGS downto 0);

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE MULTIPLIERS CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal mult_instructions_vector : std_logic_vector(NUM_OF_MUL_FU * INSTR_WIDTH downto 0);
	signal mult_1_op_read_addr      : std_logic_vector(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal mult_1_op_read_data      : std_logic_vector(NUM_OF_MUL_FU * DATA_WIDTH downto 0);

	signal mult_2_op_read_addr : std_logic_vector(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal mult_2_op_read_data : std_logic_vector(NUM_OF_MUL_FU * DATA_WIDTH downto 0);

	signal mult_enables : t_1BitArray(0 to NUM_OF_MUL_FU);

	signal mult_regf_write_addr : std_logic_vector(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal mult_regf_write_data : std_logic_vector(NUM_OF_MUL_FU * DATA_WIDTH downto 0);

	signal mult_regf_wes : std_logic_vector(NUM_OF_MUL_FU downto 0);

	signal mul_flags_vector : std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0) := (others=>'0');
	--:t_mul_flags;

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE DIVIDERS CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	-- Signal array for the remainders from the different divider FUs
	signal div_remainders_array : t_data_array(0 to NUM_OF_DIV_FU);
	signal div_remainders       : std_logic_vector(NUM_OF_DIV_FU * DATA_WIDTH downto 0);

	signal div_instructions_vector : std_logic_vector(NUM_OF_DIV_FU * INSTR_WIDTH downto 0);
	signal div_1_op_read_addr      : std_logic_vector(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal div_1_op_read_data      : std_logic_vector(NUM_OF_DIV_FU * DATA_WIDTH downto 0);

	signal div_2_op_read_addr : std_logic_vector(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal div_2_op_read_data : std_logic_vector(NUM_OF_DIV_FU * DATA_WIDTH downto 0);

	signal div_enables : t_1BitArray(0 to NUM_OF_DIV_FU);

	signal div_regf_write_addr : std_logic_vector(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal div_regf_write_data : std_logic_vector(NUM_OF_DIV_FU * DATA_WIDTH downto 0);

	signal div_regf_wes : std_logic_vector(NUM_OF_DIV_FU downto 0);

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE LOGIC FUs CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal logic_instructions_vector : std_logic_vector(NUM_OF_LOGIC_FU * INSTR_WIDTH downto 0);
	signal logic_1_op_read_addr      : std_logic_vector(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal logic_1_op_read_data      : std_logic_vector(NUM_OF_LOGIC_FU * DATA_WIDTH downto 0);

	signal logic_2_op_read_addr : std_logic_vector(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal logic_2_op_read_data : std_logic_vector(NUM_OF_LOGIC_FU * DATA_WIDTH downto 0);

	signal logic_selects : t_2BitArray(0 to NUM_OF_LOGIC_FU);
	signal logic_enables : t_1BitArray(0 to NUM_OF_LOGIC_FU);

	signal logic_regf_write_addr : std_logic_vector(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal logic_regf_write_data : std_logic_vector(NUM_OF_LOGIC_FU * DATA_WIDTH downto 0);

	signal logic_regf_wes : std_logic_vector(NUM_OF_LOGIC_FU downto 0);

	signal logic_flags_vector : std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0) := (others=>'0');
	--:t_logic_flags;


	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE SHIFT FUs CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal shift_instructions_vector : std_logic_vector(NUM_OF_SHIFT_FU * INSTR_WIDTH downto 0);
	signal shift_1_op_read_addr      : std_logic_vector(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal shift_1_op_read_data      : std_logic_vector(NUM_OF_SHIFT_FU * DATA_WIDTH downto 0);

	signal shift_2_op_read_addr : std_logic_vector(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal shift_2_op_read_data : std_logic_vector(NUM_OF_SHIFT_FU * DATA_WIDTH downto 0);

	signal shift_selects : t_2BitArray(0 to NUM_OF_SHIFT_FU);
	signal shift_enables : t_1BitArray(0 to NUM_OF_SHIFT_FU);

	signal shift_regf_write_addr : std_logic_vector(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal shift_regf_write_data : std_logic_vector(NUM_OF_SHIFT_FU * DATA_WIDTH downto 0);

	signal shift_regf_wes : std_logic_vector(NUM_OF_SHIFT_FU downto 0);

	signal shift_flags_vector : std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0) := (others=>'0');
	--:t_shift_flags;

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE DPU (DATA PATH UNIT) COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal dpu_instructions_vector : std_logic_vector(NUM_OF_DPU_FU * INSTR_WIDTH downto 0);

	signal dpu_1_op_read_addr : std_logic_vector(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal dpu_1_op_read_data : std_logic_vector(NUM_OF_DPU_FU * DATA_WIDTH downto 0);

	signal dpu_enables : t_1BitArray(0 to NUM_OF_DPU_FU);

	signal dpu_regf_write_addr : std_logic_vector(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH downto 0);
	signal dpu_regf_write_data : std_logic_vector(NUM_OF_DPU_FU * DATA_WIDTH downto 0);

	signal dpu_regf_wes : std_logic_vector(NUM_OF_DPU_FU downto 0);

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE CPU (CONTROL PATH UNIT) COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal cpu_instructions_vector : std_logic_vector(NUM_OF_CPU_FU * INSTR_WIDTH downto 0);

	signal cpu_1_op_read_addr : std_logic_vector(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH downto 0);
	signal cpu_1_op_read_data : std_logic_vector(NUM_OF_CPU_FU * CTRL_REG_WIDTH downto 0);

	signal cpu_enables : t_1BitArray(0 to NUM_OF_CPU_FU);

	signal cpu_ctrl_regf_write_addr : std_logic_vector(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH downto 0);
	signal cpu_ctrl_regf_write_data : std_logic_vector(NUM_OF_CPU_FU * CTRL_REG_WIDTH downto 0);

	signal cpu_ctrl_regf_wes : std_logic_vector(NUM_OF_CPU_FU downto 0);

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE BRANCH FUs CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal branch_instruction : std_logic_vector(BRANCH_INSTR_WIDTH - 1 downto 0);
	signal branch_instruction_reg : std_logic_vector(BRANCH_INSTR_WIDTH - 1 downto 0);

	-- Program Counter Register

	signal pc : std_logic_vector(ADDR_WIDTH - 1 downto 0);

	signal multiplexed_flags : std_logic_vector(NUM_OF_BRANCH_FLAGS downto 0);

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE REGISTER FILE COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal regf_read_addr : std_logic_vector(REG_FILE_ADDR_WIDTH * (2 * SUM_OF_FU - NUM_OF_DPU_FU) downto 0);
	-- For DPU FU only one operand read addr/data needed !!!
	signal regf_read_data : std_logic_vector(DATA_WIDTH * (2 * SUM_OF_FU - NUM_OF_DPU_FU) downto 0);
	-- For DPU FU only one operand read addr/data needed !!!

	signal regf_write_addr : std_logic_vector(REG_FILE_ADDR_WIDTH * SUM_OF_FU downto 0);
	signal regf_write_data : std_logic_vector(DATA_WIDTH * SUM_OF_FU downto 0);

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE CONTROL REGISTER FILE COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal ctrl_regf_read_addr : std_logic_vector(CTRL_REGFILE_ADDR_WIDTH * NUM_OF_CPU_FU downto 0);
	signal ctrl_regf_read_data : std_logic_vector(CTRL_REG_WIDTH * NUM_OF_CPU_FU downto 0);

	signal ctrl_regf_write_enables : std_logic_vector(NUM_OF_CPU_FU downto 0);
	signal ctrl_regf_write_addr    : std_logic_vector(CTRL_REGFILE_ADDR_WIDTH * NUM_OF_CPU_FU downto 0);
	signal ctrl_regf_write_data    : std_logic_vector(CTRL_REG_WIDTH * NUM_OF_CPU_FU downto 0);

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS FOR THE BLOCK RAM MEMORY COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal mem_we      : std_logic;
	signal mem_addr_in : std_logic_vector(ADDR_WIDTH - 1 downto 0);

	signal memory_addr        : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal pc_multiplexer_ins : std_logic_vector(2 * ADDR_WIDTH - 1 downto 0);
	signal mem_data_in        : std_logic_vector(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH downto 0); -- SUM_OF_FU + BRANCH_INSTR.
	signal mem_data_out       : std_logic_vector(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH downto 0); -- SUM_OF_FU + BRANCH_INSTR.

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SIGNALS TO/FROM THE MEMORY LOADER COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	signal internal_config_reg_addr : std_logic_vector(2 downto 0);
	signal internal_config_reg_we   : std_logic;
	signal internal_config_reg_data : std_logic_vector(CONFIG_REG_WIDTH - 1 downto 0);

	signal configuring_reset     : std_logic;
	signal mem_config_done       : std_logic;
	signal en_instruction_memory : std_logic;
	signal test_rst              : std_logic;
	-- Signal to wait one cycle after the pc is initialized to get the first
	-- instruction into the FUs
	signal wait_cycle            : std_logic;
	signal second_wait_cycle     : std_logic;
	signal third_wait_cycle      : std_logic;

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- SELECT SIGNALS FOR THE BRANCH FLAG MULTIPLEXERS --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	--signal branch_flag_controls  :t_flag_controls(1 to CUR_DEFAULT_BRANCH_FLAGS_NUM);   -- See the "WPPE_LIB.vhd" library for definition
	signal branch_flag_controls_vector : std_logic_vector(
		WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS * ( -- See the "TYPE_LIB.vhd" library for definition
			3 +                         -- SEL_FU_WIDTH 
			LOG_MAX_NUM_FU +            -- log(MAX_NUM_FU)
			LOG_MAX_NUM_FLAGS +         -- log(MAX_NUM_FLAGS)
			LOG_MAX_NUM_CTRL_SIG        -- log(MAX_NUM_CTRL_SIG) 
		) - 1 downto 0);

	signal FU_flag_values        : t_FU_flags_values; -- See the "WPPE_LIB.vhd" library for definition
	signal FU_flag_values_vector : std_logic_vector(
		4 * (MAX_NUM_FU * MAX_NUM_FLAGS + 1) + MAX_NUM_CONTROL_REGS + MAX_NUM_CONTROL_INPUTS + MAX_NUM_CONTROL_OUTPUTS + 1 downto 0);

	signal branch_flag_values : std_logic_vector(1 to CUR_DEFAULT_BRANCH_FLAGS_NUM);

	signal branch_mux_ctrl_registers_out : std_logic_vector(CTRL_REG_WIDTH * (TOTAL_CTRL_REGS_NUM + NUM_OF_CONTROL_REGS) downto 0) := (others=>'0');

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	--  SIGNALS FOR SRECO (SELF RECONFIGURATIONS) --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	signal config_reg_data_vector : std_logic_vector(CUR_DEFAULT_CONFIG_REG_WIDTH * 2 - 1 downto 0);
	signal config_reg_addr_vector : std_logic_vector(5 downto 0);
	signal config_reg_we_vector   : std_logic_vector(1 downto 0);

	signal config_reg_data_mux_out : std_logic_vector(CUR_DEFAULT_CONFIG_REG_WIDTH - 1 downto 0);
	signal config_reg_addr_mux_out : std_logic_vector(2 downto 0);
	signal config_reg_we_mux_out   : std_logic;

	signal sreco_select : std_logic;

	signal config_reg_addr_memloader : std_logic_vector(2 downto 0);
	signal config_reg_addr_regfile   : std_logic_vector(2 downto 0);
	--
	signal config_reg_data_memloader : std_logic_vector(CUR_DEFAULT_CONFIG_REG_WIDTH - 1 downto 0);
	signal config_reg_data_regfile   : std_logic_vector(CUR_DEFAULT_CONFIG_REG_WIDTH - 1 downto 0);
	--
	signal config_reg_we_memloader   : std_logic;
	signal config_reg_we_regfile     : std_logic;

	signal sig_configuration_done        	  : std_logic;
	signal sig_ctrl_programmable_input_depth : t_ctrl_programmable_input_depth;
	signal sig_en_programmable_fd_depth      : t_en_programmable_input_fd_depth;
	signal sig_programmable_fd_depth         : t_programmable_input_fd_depth;
	signal sig_count_down                    : std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto 0);

	signal mask_r   : std_logic_vector(WPPE_GENERICS_RECORD.DATA_WIDTH-1 downto 0);
	signal fu_sel_r : std_logic_vector(CUR_DEFAULT_NUM_OF_FUS-1 downto 0); 
	signal pe_sel_r : std_logic;

	--====================================================================================
	-- User defined clock gating module
	-- rc_lps_ug.pdf, p. 120

	COMPONENT my_CG_MOD is
		port(
			ck_in  : in  std_logic;
			enable : in  std_logic;
			test   : in  std_logic;
			ck_out : out std_logic
		);
	END COMPONENT;
	--====================================================================================

	--Ericles Sousa on 08 Jan 2015
	--New conponent to control the start time of the PEs
	component start_manager is
		generic(
			--Ericles:
			N             : integer := 0;
			M             : integer := 0;
			INSTANCE_NAME : string  := "/Start_manager"
		);
		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			en         : in  std_logic;
			count_down : in  std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto 0);
			start      : out std_logic
		);
	end component;

	--===============================================================================--
	-- Generic ram_wrapper for (SY0A...) memory component --
	--===============================================================================--

	-- pragma translate_off
	-- cadence translate_on
	component ram_wrapper is
		generic(
			ADDR_WIDTH : integer range 1 to 32; --  := 3;
			DATA_WIDTH : integer range 1 to 256 --:= 128
		);

		port(
			addr  : IN  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			d_out : OUT std_logic_vector(DATA_WIDTH - 1 downto 0);
			di    : IN  std_logic_vector(DATA_WIDTH - 1 downto 0);
			we    : IN  std_logic;
			rst   : IN  std_logic;
			clk   : IN  std_logic
		);

	end component;

	-- pragma translate_on


	COMPONENT flags_sel_unit IS
		generic(
			-- cadence translate_off		  		
			INSTANCE_NAME        : string                 := "flags_sel_unit";
			-- cadence translate_on				
			WPPE_GENERICS_RECORD : t_wppe_generics_record := CUR_DEFAULT_WPPE_GENERICS_RECORD
		);
		port(
			branch_flag_controls_vector : in  std_logic_vector(
				WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS * ( -- See the "TYPE_LIB.vhd" library for definition
					3 +                 -- SEL_FU_WIDTH 
					LOG_MAX_NUM_FU +    -- log(MAX_NUM_FU)
					LOG_MAX_NUM_FLAGS + -- log(MAX_NUM_FLAGS)
					LOG_MAX_NUM_CTRL_SIG -- log(MAX_NUM_CTRL_SIG) 
				) - 1 downto 0);
			-- :in  t_flag_controls(1 to CUR_DEFAULT_BRANCH_FLAGS_NUM);   -- See the "WPPE_LIB.vhd" library for definition
			--	FU_flag_values        :in  t_FU_flags_values;  -- See the "WPPE_LIB.vhd" library for definition
			FU_flag_values_vector       : in  std_logic_vector(
				4 * (MAX_NUM_FU * MAX_NUM_FLAGS + 1) + MAX_NUM_CONTROL_REGS + MAX_NUM_CONTROL_INPUTS + MAX_NUM_CONTROL_OUTPUTS + 1 downto 0);
			branch_flag_values          : out std_logic_vector(1 to CUR_DEFAULT_BRANCH_FLAGS_NUM)
		);

	END COMPONENT;

	--===============================================================================--
	-- Generic memory loader/register initializer component --
	--===============================================================================--

	component generic_loader is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME               : string;
			-- cadence translate_on			
			SOURCE_ADDR_WIDTH           : positive range 1 to MAX_ADDR_WIDTH; -- := 7; --CUR_DEFAULT_ADDR_WIDTH;
			DESTIN_ADDR_WIDTH           : positive range 1 to MAX_ADDR_WIDTH; -- := 5; --CUR_DEFAULT_ADDR_WIDTH;
			SOURCE_DATA_WIDTH           : positive range 1 to 128; --:= 16;
			-- Because the VLIW instruction width is not always a multiple of 
			-- config mem size, the data of VLIW instruction is padded to
			-- be multiple of config mem size. Therefore a
			-- value for the padded ratio must be given => DESTIN_SOURCE_RATIO_CEILING
			DESTIN_SOURCE_RATIO_CEILING : positive range 1 to 32;

			-- shravan : 20120316 : increased range of DESTIN_DATA_WIDTH from (1 to 128) to (1 to 1024),  DEST_IN_DATA_WIDTH is the width of one full VLIW instruction, as the number of FUs increases VLIW instruction size can increase beyond 128     
			--		DESTIN_DATA_WIDTH :positive range 1 to 128 ; -- := 48;
			DESTIN_DATA_WIDTH           : positive range 1 to 1024; -- := 48;

			DUAL_DATA_WIDTH             : positive range 1 to 128; -- := CUR_DEFAULT_CONFIG_REG_WIDTH;
			INIT_SOURCE_ADDR            : integer range 0 to MAX_ADDR_WIDTH; -- := CUR_DEFAULT_CONFIG_START_ADDR;
			--END_DESTIN_ADDR  :positive range 1 to MAX_ADDR_WIDTH  := CUR_DEFAULT_MEM_SIZE -1
			--Ericles
			END_DESTIN_ADDR             : positive range 1 to 128 := CUR_DEFAULT_MEM_SIZE - 1
		);

		port(
			clk             : in  std_logic;
			rst             : in  std_logic;

			-- If set_to_config = '1', then this WPPE must be (RE-)configured
			set_to_config   : in  std_logic;
			enable_tcpa	: in std_logic;
			-- Signal showing the current state of configuring the memory and registers
			-- gives the reset signal for the WPPE-logic
			config_rst      : out std_logic;
			vliw_config_en  : in std_logic;
			icn_config_en   : in std_logic;
			mem_config_done : out std_logic;
			common_config_reset : in std_logic;

			source_data_in  : in  std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);

			idle            : out std_logic;
			destin_we       : out std_logic;
			dual_we         : out std_logic;
			destin_addr_out : out std_logic_vector(DESTIN_ADDR_WIDTH - 1 downto 0);
			dual_destin_out : out std_logic_vector(DUAL_DATA_WIDTH - 1 downto 0);
			destin_data_out : out std_logic_vector(DESTIN_DATA_WIDTH - 1 downto 0)
		);

	end component;

	--===============================================================================--
	-- 2 to 1 1-bit multiplexer component declaration --
	--===============================================================================--
	COMPONENT mux_2_1_1bit is
		-- cadence translate_off	
		generic(
			INSTANCE_NAME : string
		);
		-- cadence translate_on		
		port(
			input0 : in  std_logic;
			input1 : in  std_logic;
			sel    : in  std_logic;
			output : out std_logic
		);
	end COMPONENT mux_2_1_1bit;

	--===============================================================================--
	-- 2 to 1 multiplexer component declaration --
	--===============================================================================--
	component mux_2_1 is
		generic(
			-- cadence translate_off			
			INSTANCE_NAME : string;
			-- cadence translate_on			
			DATA_WIDTH    : positive range 1 to MAX_DATA_WIDTH -- := CUR_DEFAULT_DATA_WIDTH

		);

		port(
			data_inputs : in  std_logic_vector(2 * DATA_WIDTH - 1 downto 0);
			sel         : in  std_logic;
			output      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component;

	--===============================================================================--
	-- Generic multiplexer component declaration --
	--===============================================================================--

	component wppe_multiplexer is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME     : string;
			-- cadence translate_on			
			INPUT_DATA_WIDTH  : positive range 1 to 64; --:= 16;
			OUTPUT_DATA_WIDTH : positive range 1 to 64; --:= 16;
			SEL_WIDTH         : positive range 1 to 16; --:= 2;		
			NUM_OF_INPUTS     : positive range 1 to 64 -- := 4

		);

		port(
			data_inputs : in  std_logic_vector(INPUT_DATA_WIDTH * NUM_OF_INPUTS - 1 downto 0);
			sel         : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			output      : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
		);

	end component;

	--===============================================================================--
	-- BRANCH CONTROL UNIT DECLARATION --
	--===============================================================================--

	component branch_control is
		generic(
			-- cadence translate_off		  		
			INSTANCE_NAME        : string;
			-- cadence translate_on	
			WPPE_GENERICS_RECORD : t_wppe_generics_record;
			BRANCH_INSTR_WIDTH   : positive range MIN_BRANCH_INSTR_WIDTH to MAX_BRANCH_INSTR_WIDTH; -- ; -- := CUR_DEFAULT_BRANCH_INSTR_WIDTH;

			ADDR_WIDTH           : positive range MIN_ADDR_WIDTH to MAX_ADDR_WIDTH; --  ; -- := CUR_DEFAULT_ADDR_WIDTH;

			BRANCH_TARGET_WIDTH  : positive range MIN_BRANCH_TARGET_WIDTH to MAX_BRANCH_TARGET_WIDTH; --  ; -- := CUR_DEFAULT_BRANCH_TARGET_WIDTH;

			-- 55 bit default branch instruction width <==> Opcode + 4 branch targets a 13 bits !!!
			BEGIN_OPCODE         : positive range MIN_BRANCH_INSTR_WIDTH - 1 to MAX_BRANCH_INSTR_WIDTH - 1; -- := CUR_DEFAULT_BRANCH_OPCODE_BEGIN;
			END_OPCODE           : positive range MIN_BRANCH_INSTR_WIDTH - 1 - MAX_OPCODE_FIELD_WIDTH to MAX_BRANCH_INSTR_WIDTH - 1 - MAX_OPCODE_FIELD_WIDTH; -- := CUR_DEFAULT_BRANCH_OPCODE_END; 
			-- 3  bit Opcode width
			-- Number of flags which are evaluated by the branch unit
			-- This results in the total of 2**(NUM_OF_BRANCH_FLAGS) 
			-- branch targets.
			-- One of this branch targets is taken after the 
			-- evaluation of the flags
			NUM_OF_BRANCH_FLAGS  : integer range 0 to 8 -- := CUR_DEFAULT_BRANCH_FLAGS_NUM


		);

		port(
			clk, rst                    : in  std_logic;
			instruction_in              : in  std_logic_vector(BRANCH_INSTR_WIDTH - 1 downto 0);
			pc                          : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
			enable_tcpa                 : in  std_logic;
			branch_flag_controls_vector : out std_logic_vector(
				WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS * ( -- See the "TYPE_LIB.vhd" library for definition
					3 +                 -- SEL_FU_WIDTH 
					LOG_MAX_NUM_FU +    -- log(MAX_NUM_FU)
					LOG_MAX_NUM_FLAGS + -- log(MAX_NUM_FLAGS)
					LOG_MAX_NUM_CTRL_SIG -- log(MAX_NUM_CTRL_SIG) 
				) - 1 downto 0
			);
			--:out t_flag_controls(1 to CUR_DEFAULT_BRANCH_FLAGS_NUM);   -- See the "WPPE_LIB.vhd" library for definition
			branch_flag_values          : in  std_logic_vector(1 to CUR_DEFAULT_BRANCH_FLAGS_NUM)
		);

	end component;

	--===============================================================================--
	-- ADDERS CONTROL UNIT DECLARATION --
	--===============================================================================--

	component adds_control is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME       : string;
			-- cadence translate_on	

			--###################################
			--### SRECO: REGISTER FILE OFFSET ###
			RF_OFFSET           : positive range 1 to CUR_DEFAULT_MAX_REG_FILE_OFFSET := CUR_DEFAULT_REG_FILE_OFFSET;
			--###########################

			--*******************************************************************************--
			-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
			--*******************************************************************************--

			INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH; -- := CUR_DEFAULT_INSTR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
			--*******************************************************************************--

			NUM_OF_ADD_FU       : integer range 0 to MAX_NUM_FU; -- := CUR_DEFAULT_NUM_ADD_FU;

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH; -- := CUR_DEFAULT_DATA_WIDTH;
			REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH; -- := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE REGISTER FIELD WIDTH IN THE INSTRUCTION
			--*******************************************************************************--

			-- Width of the register field in the instruction = log_2(GEN_PUR_REG_NUM)

			REG_FIELD_WIDTH     : positive range 1 to MAX_REG_FIELD_WIDTH; -- := CUR_DEFAULT_REG_FIELD_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
			--*******************************************************************************--

			OPCODE_FIELD_WIDTH  : positive range 1 to MAX_OPCODE_FIELD_WIDTH -- := CUR_DEFAULT_OPCODE_FIELD_WIDTH

		);

		port(
			clk, rst           : in  std_logic;

			flags_vector       : out std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0); --:out t_adder_flags;
			--flags :out std_logic_vector(3 downto 0);

			------------------------
			-- INSTRUCTIONS FOR THE ADDER UNITS -- 
			------------------------		

			instr_vector       : in  std_logic_vector(NUM_OF_ADD_FU * INSTR_WIDTH - 1 downto 0);

			------------------------
			-- SUMMATORS READ ADDRESS PORTS FOR REGISTER FILE -- 
			------------------------

			-- For register addressation 2 read ports for every FU is needed

			sum_1_op_read_addr : out std_logic_vector(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);
			sum_2_op_read_addr : out std_logic_vector(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

			------------------------
			-- SUMMATORS READ DATA PORTS FOR REGISTER FILE -- 
			------------------------

			-- For register addressation 2 read ports for every FU is needed

			sum_1_op_read_data : in  std_logic_vector(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0);
			sum_2_op_read_data : in  std_logic_vector(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- SUMMATORS write ADDRESS PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

			sum_write_addr     : out std_logic_vector(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- SUMMATORS WRITE DATA PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			sum_write_data     : out std_logic_vector(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- SUMMATORS WRITE ENABLE PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			sum_write_en       : out std_logic_vector(1 to NUM_OF_ADD_FU)
		);

	end component adds_control;

	--===============================================================================--
	-- MULTIPLIERS CONTROL UNIT DECLARATION --
	--===============================================================================--

	component mult_control is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME       : string;
			-- cadence translate_on	

			--###################################
			--### SRECO: REGISTER FILE OFFSET ###
			RF_OFFSET           : positive range 1 to CUR_DEFAULT_MAX_REG_FILE_OFFSET := CUR_DEFAULT_REG_FILE_OFFSET;
			--###########################

			--*******************************************************************************--
			-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
			--*******************************************************************************--

			INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH; -- := CUR_DEFAULT_INSTR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
			--*******************************************************************************--

			NUM_OF_MUL_FU       : integer range 0 to MAX_NUM_FU; -- := CUR_DEFAULT_NUM_MUL_FU;

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH; -- := CUR_DEFAULT_DATA_WIDTH;
			REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH; -- := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;


			--*******************************************************************************--
			-- GENERICS FOR THE REGISTER FIELD WIDTH IN THE INSTRUCTION
			--*******************************************************************************--

			-- Width of the register field in the instruction = log_2(GEN_PUR_REG_NUM)

			REG_FIELD_WIDTH     : positive range 1 to MAX_REG_FIELD_WIDTH; -- := CUR_DEFAULT_REG_FIELD_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
			--*******************************************************************************--

			OPCODE_FIELD_WIDTH  : positive range 1 to MAX_OPCODE_FIELD_WIDTH -- := CUR_DEFAULT_OPCODE_FIELD_WIDTH

		);

		port(
			flags_vector        : out std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0); --:out t_mul_flags;

			clk, rst            : in  std_logic;

			------------------------
			-- INSTRUCTIONS FOR THE MULTIPLIER UNITS -- 
			------------------------		

			instr_vector        : in  std_logic_vector(NUM_OF_MUL_FU * INSTR_WIDTH - 1 downto 0);

			------------------------
			-- MULTIPLIERS READ ADDRESS PORTS FOR REGISTER FILE -- 
			------------------------

			-- For register addressation 2 read ports for every FU is needed

			mult_1_op_read_addr : out std_logic_vector(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);
			mult_2_op_read_addr : out std_logic_vector(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

			------------------------
			-- MULTIPLIERS READ DATA PORTS FOR REGISTER FILE -- 
			------------------------

			-- For register addressation 2 read ports for every FU is needed

			mult_1_op_read_data : in  std_logic_vector(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0);
			mult_2_op_read_data : in  std_logic_vector(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- MULTIPLIERS write ADDRESS PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

			mult_write_addr     : out std_logic_vector(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- MULTIPLIERS WRITE DATA PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			mult_write_data     : out std_logic_vector(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- MULTIPLIERS WRITE ENABLE PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			mult_write_en       : out std_logic_vector(1 to NUM_OF_MUL_FU)
		);

	end component mult_control;

	--===============================================================================--
	-- DIVIDERS CONTROL UNIT DECLARATION --
	--===============================================================================--

	component div_control is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME       : string;
			-- cadence translate_on			
			--*******************************************************************************--
			-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
			--*******************************************************************************--

			INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH; -- := CUR_DEFAULT_INSTR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
			--*******************************************************************************--

			NUM_OF_DIV_FU       : integer range 0 to MAX_NUM_FU; -- := CUR_DEFAULT_NUM_DIV_FU;

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH; -- := CUR_DEFAULT_DATA_WIDTH;
			REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH; -- := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE REGISTER FIELD WIDTH IN THE INSTRUCTION
			--*******************************************************************************--

			-- Width of the register field in the instruction = log_2(GEN_PUR_REG_NUM)

			REG_FIELD_WIDTH     : positive range 1 to MAX_REG_FIELD_WIDTH; -- := CUR_DEFAULT_REG_FIELD_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
			--*******************************************************************************--

			OPCODE_FIELD_WIDTH  : positive range 1 to MAX_OPCODE_FIELD_WIDTH -- := CUR_DEFAULT_OPCODE_FIELD_WIDTH

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

	end component div_control;

	--===============================================================================--
	-- LOGIC FUs CONTROL UNIT DECLARATION --
	--===============================================================================--

	component logic_control is
		generic(

			-- cadence translate_off	
			INSTANCE_NAME       : string;
			-- cadence translate_on					
			--*******************************************************************************--
			-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
			--*******************************************************************************--

			INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH; -- := CUR_DEFAULT_INSTR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
			--*******************************************************************************--

			NUM_OF_LOGIC_FU     : integer range 0 to MAX_NUM_FU; -- := CUR_DEFAULT_NUM_LOGIC_FU;

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH; -- := CUR_DEFAULT_DATA_WIDTH;
			REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH; -- := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE REGISTER FIELD WIDTH IN THE INSTRUCTION
			--*******************************************************************************--

			-- Width of the register field in the instruction = log_2(GEN_PUR_REG_NUM)

			REG_FIELD_WIDTH     : positive range 1 to MAX_REG_FIELD_WIDTH; -- := CUR_DEFAULT_REG_FIELD_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
			--*******************************************************************************--

			OPCODE_FIELD_WIDTH  : positive range 1 to MAX_OPCODE_FIELD_WIDTH -- := CUR_DEFAULT_OPCODE_FIELD_WIDTH

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

	end component logic_control;

	--===============================================================================--
	-- SHIFT FUs CONTROL UNIT DECLARATION --
	--===============================================================================--

	component shift_control is
		generic(

			-- cadence translate_off	
			INSTANCE_NAME       : string;
			-- cadence translate_on			
			--*******************************************************************************--
			-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
			--*******************************************************************************--

			INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH; -- := CUR_DEFAULT_INSTR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
			--*******************************************************************************--

			NUM_OF_SHIFT_FU     : integer range 0 to MAX_NUM_FU; -- := CUR_DEFAULT_NUM_SHIFT_FU;

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH; -- := CUR_DEFAULT_DATA_WIDTH;
			REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH; -- := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE REGISTER FIELD WIDTH IN THE INSTRUCTION
			--*******************************************************************************--

			-- Width of the register field in the instruction = log_2(GEN_PUR_REG_NUM)

			REG_FIELD_WIDTH     : positive range 1 to MAX_REG_FIELD_WIDTH; -- := CUR_DEFAULT_REG_FIELD_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
			--*******************************************************************************--

			OPCODE_FIELD_WIDTH  : positive range 1 to MAX_OPCODE_FIELD_WIDTH -- := CUR_DEFAULT_OPCODE_FIELD_WIDTH

		);

		port(
			flags_vector         : out std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0); --:out t_shift_flags;

			------------------------
			-- INSTRUCTIONS FOR THE SHIFT FU UNITS -- 
			------------------------		

			instr_vector         : in  std_logic_vector(NUM_OF_SHIFT_FU * INSTR_WIDTH - 1 downto 0);

			------------------------
			-- SHIFT FUs READ ADDRESS PORTS FOR REGISTER FILE -- 
			------------------------

			-- For register addressation 2 read ports for every FU is needed

			shift_1_op_read_addr : out std_logic_vector(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);
			shift_2_op_read_addr : out std_logic_vector(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

			------------------------
			-- SHIFT FUs READ DATA PORTS FOR REGISTER FILE -- 
			------------------------

			-- For register addressation 2 read ports for every FU is needed

			shift_1_op_read_data : in  std_logic_vector(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0);
			shift_2_op_read_data : in  std_logic_vector(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- SHIFT FUs write ADDRESS PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

			shift_write_addr     : out std_logic_vector(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- SHIFT FUs WRITE DATA PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			shift_write_data     : out std_logic_vector(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- SHIFT FUs WRITE ENABLE PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			shift_write_en       : out std_logic_vector(1 to NUM_OF_SHIFT_FU)
		);

	end component shift_control;

	--===============================================================================--
	-- DPU CONTROL UNIT DECLARATION --
	--===============================================================================--

	component dpu_control is
		generic(

			-- cadence translate_off	
			INSTANCE_NAME       : string;
			-- cadence translate_on

			--###################################
			--### SRECO: REGISTER FILE OFFSET ###
			RF_OFFSET           : positive range 1 to CUR_DEFAULT_MAX_REG_FILE_OFFSET := CUR_DEFAULT_REG_FILE_OFFSET;
			--###########################

			--*******************************************************************************--
			-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
			--*******************************************************************************--

			INSTR_WIDTH         : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH; -- := CUR_DEFAULT_INSTR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
			--*******************************************************************************--

			NUM_OF_DPU_FU       : integer range 0 to MAX_NUM_FU; -- := CUR_DEFAULT_NUM_DPU_FU;

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			DATA_WIDTH          : positive range 1 to MAX_DATA_WIDTH; -- := CUR_DEFAULT_DATA_WIDTH;
			REG_FILE_ADDR_WIDTH : positive range 1 to MAX_REG_FILE_ADDR_WIDTH; -- := CUR_DEFAULT_REG_FILE_ADDR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE REGISTER FIELD WIDTH IN THE INSTRUCTION
			--*******************************************************************************--

			-- Width of the register field in the instruction = log_2(GEN_PUR_REG_NUM)

			REG_FIELD_WIDTH     : positive range 1 to MAX_REG_FIELD_WIDTH; -- := CUR_DEFAULT_REG_FIELD_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
			--*******************************************************************************--

			OPCODE_FIELD_WIDTH  : positive range 1 to MAX_OPCODE_FIELD_WIDTH -- := CUR_DEFAULT_OPCODE_FIELD_WIDTH

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

	end component;

	--===============================================================================--
	-- CPU CONTROL UNIT DECLARATION --
	--===============================================================================--


	component cpu_control is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME           : string;
			-- cadence translate_on			 
			--*******************************************************************************--
			-- GENERICS FOR THE CURRENT INSTRUCTION WIDTH
			--*******************************************************************************--

			INSTR_WIDTH             : positive range MIN_INSTR_WIDTH to MAX_INSTR_WIDTH; -- := CUR_DEFAULT_INSTR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF SPECIFIC FUNCTIONAL UNITS
			--*******************************************************************************--

			NUM_OF_CPU_FU           : integer range 0 to MAX_NUM_FU; -- := CUR_DEFAULT_NUM_CPU_FU;

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			CTRL_REG_WIDTH          : positive range 1 to MAX_CTRL_REG_WIDTH; -- := CUR_DEFAULT_CTRL_REG_WIDTH;
			CTRL_REGFILE_ADDR_WIDTH : positive range 1 to MAX_CTRL_REGFILE_ADDR_WIDTH; -- := CUR_DEFAULT_CTRL_REGFILE_ADDR_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE CONTROL REGISTER FIELD WIDTH IN THE INSTRUCTION
			--*******************************************************************************--

			-- Width of the register field in the instruction = log_2(CTRL_REG_NUM)

			CTRL_REG_FIELD_WIDTH    : positive range 1 to MAX_REG_FIELD_WIDTH; -- := CUR_DEFAULT_REG_FIELD_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE WIDTH OF THE OPCODE-FIELD IN THE INSTRUCTION
			--*******************************************************************************--

			OPCODE_FIELD_WIDTH      : positive range 1 to MAX_OPCODE_FIELD_WIDTH -- := CUR_DEFAULT_OPCODE_FIELD_WIDTH

		);

		port(

			------------------------
			-- INSTRUCTIONS FOR THE CPU UNITS -- 
			------------------------		

			instr_vector    : in  std_logic_vector(NUM_OF_CPU_FU * INSTR_WIDTH - 1 downto 0);

			------------------------
			-- CPU READ ADDRESS PORTS FOR CONTROL REGISTER FILE -- 
			------------------------

			cpu_source_addr : out std_logic_vector(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH - 1 downto 0);

			------------------------
			-- CPU READ DATA PORTS FOR CONTROL REGISTER FILE -- 
			------------------------

			cpu_source_data : in  std_logic_vector(NUM_OF_CPU_FU * CTRL_REG_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- CPUs write ADDRESS PORTS FOR CONTROL REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

			cpu_write_addr  : out std_logic_vector(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- CPU WRITE DATA PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			cpu_write_data  : out std_logic_vector(NUM_OF_CPU_FU * CTRL_REG_WIDTH - 1 downto 0);

			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			-- CPU WRITE ENABLE PORTS FOR REGISTER FILE -- 
			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			cpu_write_en    : out std_logic_vector(1 to NUM_OF_CPU_FU)
		);

	end component;

	--===============================================================================--
	-- BLOCK RAM INSTRUCTION MEMORY COMPONENT DECLARATION --
	--===============================================================================--

	-- cadence translate_off								
	component instr_memory is
		generic(
			--Ericles:
			N             : integer := 0;
			M             : integer := 0;
			INSTANCE_NAME : string;
			MEM_SIZE      : positive range MIN_MEM_SIZE to MAX_MEM_SIZE; -- := CUR_DEFAULT_MEM_SIZE;
			DATA_WIDTH    : positive range 1 to 1024; -- Maximum Instruction word width for ALL FUs together (VLIW word width)
			ADDR_WIDTH    : positive range 1 to MAX_ADDR_WIDTH -- := CUR_DEFAULT_ADDR_WIDTH
		);

		port(
			clk   : in  std_logic;
			we    : in  std_logic;
			addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			di    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			d_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component;
	-- cadence translate_on

	--===============================================================================--
	-- CONTROL REGISTER FILE COMPONENT DECLARATION --
	--===============================================================================--


	component control_regfile is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME : string;
			-- cadence translate_on			  
			generics      : t_control_regfile_generics
		);

		port(
			ctrl_read_addresses_vector    : in  std_logic_vector(generics.CTRL_REGFILE_ADDR_WIDTH * generics.NUM_OF_CTRL_READ_PORTS - 1 downto 0);
			ctrl_read_data_vector         : out std_logic_vector(generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_READ_PORTS - 1 downto 0);

			ctrl_write_addresses_vector   : in  std_logic_vector(generics.CTRL_REGFILE_ADDR_WIDTH * generics.NUM_OF_CTRL_WRITE_PORTS - 1 downto 0);
			ctrl_write_data_vector        : in  std_logic_vector(generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_WRITE_PORTS - 1 downto 0);

			ctrl_wes                      : in  std_logic_vector(generics.NUM_OF_CTRL_WRITE_PORTS downto 1);

			ctrl_input_registers          : in  std_logic_vector(generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_INPUTS - 1 downto 0);
			ctrl_output_registers         : out std_logic_vector(generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_OUTPUTS - 1 downto 0);

			branch_mux_ctrl_registers_out : out std_logic_vector(generics.CTRL_REG_WIDTH * (generics.NUM_OF_CTRL_INPUTS + generics.NUM_OF_CTRL_OUTPUTS + generics.CTRL_REG_NUM) downto 0);

			ctrl_programmable_input_depth : in  t_ctrl_programmable_input_depth;

			clk, rst                      : in  std_logic
		);

	end component;

	--===============================================================================--
	-- REGISTER FILE COMPONENT DECLARATION --
	--===============================================================================--

	component reg_file is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME             : string;
			-- cadence translate_on				
			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF READ AND WRITE PORTS TO REGISTER FILE
			--*******************************************************************************--

			NUM_OF_READ_PORTS         : positive range 1 to MAX_NUM_MEM_READ_PORTS; -- := CUR_DEFAULT_NUM_MEM_READ_PORTS;
			NUM_OF_WRITE_PORTS        : positive range 1 to MAX_NUM_MEM_WRITE_PORTS; -- := CUR_DEFAULT_NUM_MEM_WRITE_PORTS;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER OF GENERAL PURPOSE, INPUT, AND OUTPUT REGISTERS --
			--*******************************************************************************--

			GEN_PUR_REG_NUM           : integer range 0 to MAX_GEN_PUR_REG_NUM; -- := CUR_DEFAULT_GEN_PUR_REG_NUM;

			NUM_OF_OUTPUT_REG         : integer range 0 to MAX_OUTPUT_REG_NUM; -- := CUR_DEFAULT_OUTPUT_REG_NUM;
			NUM_OF_INPUT_REG          : integer range 0 to MAX_INPUT_REG_NUM; -- := CUR_DEFAULT_INPUT_REG_NUM;

			BEGIN_OUTPUT_REGS         : integer range 0 to MAX_GEN_PUR_REG_NUM; -- := 13;
			END_OUTPUT_REGS           : integer range 0 to MAX_GEN_PUR_REG_NUM; -- := 15;

			--*******************************************************************************--
			-- GENERICS FOR THE NUMBER AND SIZE OF additional FIFOs --
			--*******************************************************************************--

			NUM_OF_FEEDBACK_FIFOS     : integer range 0 to MAX_NUM_FB_FIFO; -- := CUR_DEFAULT_NUM_FB_FIFO;

			-- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
			TYPE_OF_FEEDBACK_FIFO_RAM : std_logic_vector(CUR_DEFAULT_NUM_FB_FIFO downto 0); -- := (others => '1');
			SIZES_OF_FEEDBACK_FIFOS   : t_fifo_sizes(CUR_DEFAULT_NUM_FB_FIFO downto 0); -- := (others => CUR_DEFAULT_FIFO_SIZE);

			FB_FIFOS_ADDR_WIDTH       : t_fifo_sizes(CUR_DEFAULT_NUM_FB_FIFO downto 0); -- := (others => CUR_DEFAULT_FIFO_ADDR_WIDTH);

			-- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
			TYPE_OF_INPUT_FIFO_RAM    : std_logic_vector(CUR_DEFAULT_INPUT_REG_NUM - 1 downto 0); -- := (others => '1');
			SIZES_OF_INPUT_FIFOS      : t_fifo_sizes(CUR_DEFAULT_INPUT_REG_NUM - 1 downto 0); -- := (others => CUR_DEFAULT_FIFO_SIZE);
			INPUT_FIFOS_ADDR_WIDTH    : t_fifo_sizes(CUR_DEFAULT_INPUT_REG_NUM - 1 downto 0); -- := (others => CUR_DEFAULT_FIFO_ADDR_WIDTH);

			--*******************************************************************************--
			-- GENERICS FOR THE REGISTER WIDTH --
			--*******************************************************************************--

			GEN_PUR_REG_WIDTH         : positive range 1 to MAX_GEN_PUR_REG_WIDTH; -- ; -- := CUR_DEFAULT_GEN_PUR_REG_WIDTH;

			--*******************************************************************************--
			-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
			--*******************************************************************************--

			DATA_WIDTH                : positive range 1 to MAX_DATA_WIDTH; -- ; -- := CUR_DEFAULT_DATA_WIDTH;
			REG_FILE_ADDR_WIDTH       : positive -- := 5 --range 1 to MAX_REG_FILE_ADDR_WIDTH ; -- := CUR_DEFAULT_REG_FILE_ADDR_WIDTH

		);

		port(
			config_reg_data          : out std_logic_vector(CONFIG_REG_WIDTH - 1 downto 0);
			config_reg_addr          : out std_logic_vector(2 downto 0);
			config_reg_we            : out std_logic;

			read_addresses_vector    : in  std_logic_vector(REG_FILE_ADDR_WIDTH * NUM_OF_READ_PORTS - 1 downto 0);
			read_data_vector         : out std_logic_vector(DATA_WIDTH * NUM_OF_READ_PORTS - 1 downto 0);

			write_addresses_vector   : in  std_logic_vector(REG_FILE_ADDR_WIDTH * NUM_OF_WRITE_PORTS - 1 downto 0);
			write_data_vector        : in  std_logic_vector(DATA_WIDTH * NUM_OF_WRITE_PORTS - 1 downto 0);

			wes                      : in  std_logic_vector(NUM_OF_WRITE_PORTS downto 1);

			input_registers          : in  std_logic_vector(DATA_WIDTH * NUM_OF_INPUT_REG - 1 downto 0);
			output_registers         : out std_logic_vector(DATA_WIDTH * NUM_OF_OUTPUT_REG - 1 downto 0);
			input_fifos_write_en     : in  std_logic_vector(NUM_OF_INPUT_REG - 1 downto 0);
			en_programmable_fd_depth : in  t_en_programmable_input_fd_depth;
			programmable_fd_depth    : in  t_programmable_input_fd_depth;
			rst_fd_regs              : in  std_logic;
			clk, rst                 : in  std_logic
		);
	end component;

--#########
--#########
--#########
BEGIN                                   --###
	--#########
	--#########
	--#########

	zero_signal <= '0';

	mem_clk_gate_enable <= loader_clk_gate_enable OR ff_start_detection; --NOT (mem_config_done AND LOADER_configuring_reset);

	NEG_clk_gate_enable <= NOT clk_gate_enable;

	--##############################################################################
	--    CLOCK GATING SIGNAL CONNECTION
	--##############################################################################

	CLK_GATING_REVERSED_MEMORY : if CLOCK_GATING and REVERSED_CLOCK_GATING and MEMORY_CLOCK_GATING generate
		--   gated_clock              <=  clk and clk_gate_enable;--LOADER_configuring_reset; --and not(clk_gating_sel and (not configuring_reset)); -- and "NOT select" !!!

		CLK_GATING_MEMORY_loader_clk : my_CG_MOD
			port map(
				ck_in  => clk,
				enable => loader_clk_gate_enable,
				test   => zero_signal,  --'0',
				ck_out => loader_gated_clock
			);

		--  	  	CLK_GATING_MEMORY_normal_clk: my_CG_MOD   
		--			port map(
		--				ck_in  => clk,
		--				enable => clk_gate_enable,
		--				test	 => zero_signal,--'0',
		--				ck_out => gated_clock
		--			);

		-- "REVERSED" gated clock for the WPPE loader module
		--	REVERSED_gated_clock     <=  clk and NOT clk_gate_enable;--NOT LOADER_configuring_reset;

		CLK_GATING_MEMORY_reversed_clk : my_CG_MOD
			port map(
				ck_in  => clk,
				enable => NEG_clk_gate_enable, --not clk_gate_enable,
				test   => zero_signal,  --'0',
				ck_out => REVERSED_gated_clock
			);

		--	MEMORY_gated_clock       <=  clk and NOT (mem_config_done AND LOADER_configuring_reset); 

		CLK_GATING_MEMORY_memory_clk : my_CG_MOD
			port map(
				ck_in  => clk,
				enable => mem_clk_gate_enable, --NOT (mem_config_done AND LOADER_configuring_reset),
				test   => zero_signal,  --'0',
				ck_out => MEMORY_gated_clock
			);

	end generate;

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	CLK_GATING_REVERSED : if CLOCK_GATING and REVERSED_CLOCK_GATING and (not MEMORY_CLOCK_GATING) generate
		--   gated_clock              <=  clk and clk_gate_enable;--LOADER_configuring_reset; --and not(clk_gating_sel and (not configuring_reset)); -- and "NOT select" !!!

		CLK_GATING_REVERSED_normal_clk : my_CG_MOD
			port map(
				ck_in  => clk,
				enable => clk_gate_enable,
				test   => zero_signal,  --'0',
				ck_out => gated_clock
			);

		-- "REVERSED" gated clock for the WPPE loader module
		--	REVERSED_gated_clock     <=  clk and NOT clk_gate_enable;--NOT LOADER_configuring_reset;

		CLK_GATING_REVERSED_reversed_clk : my_CG_MOD
			port map(
				ck_in  => clk,
				enable => NEG_clk_gate_enable, --not clk_gate_enable,
				test   => zero_signal,  --'0',
				ck_out => REVERSED_gated_clock
			);

		-- MEMORY gated clock for the WPPE loader module
		MEMORY_gated_clock <= clk;
		loader_gated_clock <= clk;

	end generate;

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	CLK_GATING_NOT_REVERSED : if CLOCK_GATING and (NOT REVERSED_CLOCK_GATING) and (not MEMORY_CLOCK_GATING) generate
		--   gated_clock              <=  clk and clk_gate_enable;--NOT LOADER_configuring_reset; --and not(clk_gating_sel and (not configuring_reset)); -- and "NOT select" !!!

		CLK_GATING_NOT_REVERSED_normal_clk : my_CG_MOD
			port map(
				ck_in  => clk,
				enable => clk_gate_enable,
				test   => zero_signal,  --'0',
				ck_out => gated_clock
			);

		-- normal clock for the WPPE loader module
		REVERSED_gated_clock <= clk;
		MEMORY_gated_clock   <= clk;
		loader_gated_clock   <= clk;

	end generate;

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	NO_CLK_GATING : if not CLOCK_GATING generate
		gated_clock          <= clk;
		-- normal clock for the WPPE loader module
		REVERSED_gated_clock <= clk;
		MEMORY_gated_clock   <= clk;
		loader_gated_clock   <= clk;
	end generate;

	--##############################################################################
	--##############################################################################


	--################################################################################
	--################################################################################
	-- Connecting the ADDR_BUS, WE and DATA_BUS from
	-- MEMORY LOADER module to the 
	-- ADDR INPUT, DATA_INPUT and WE input for the 
	-- INTERCONNECT CONFIGURATION REGISTER FILE

	--	config_reg_addr <= internal_config_reg_addr;
	--	config_reg_data <= internal_config_reg_data;
	--	config_reg_we   <= internal_config_reg_we;

	config_reg_addr <= config_reg_addr_mux_out;
	config_reg_data <= config_reg_data_mux_out;
	config_reg_we   <= config_reg_we_mux_out;

	--	sreco_select <= configuring_reset;

	--	config_reg_addr_vector(5 downto 3) <= internal_config_reg_addr;
	--	config_reg_data_vector(CUR_DEFAULT_CONFIG_REG_WIDTH*2-1 downto CONFIG_REG_WIDTH) <= internal_config_reg_data;
	--	config_reg_we_vector(1)   <= internal_config_reg_we;

	config_reg_we_vector <= config_reg_we_memloader & config_reg_we_regfile;
	--	config_reg_we_vector(1)   <= config_reg_we_memloader;
	--	config_reg_we_vector(0)   <= config_reg_we_regfile;
	--
	--	sreco_select <= clk;

	config_reg_addr_vector <= config_reg_addr_memloader & config_reg_addr_regfile;
	--   config_reg_addr_vector(5 downto 3) <= config_reg_addr_memloader;
	--   config_reg_addr_vector(2 downto 0) <= config_reg_addr_regfile;

	config_reg_data_vector <= config_reg_data_memloader & config_reg_data_regfile;
	--	config_reg_data_vector(CUR_DEFAULT_CONFIG_REG_WIDTH*2-1 downto CONFIG_REG_WIDTH) <= config_reg_data_memloader;
	--	config_reg_data_vector(CUR_DEFAULT_CONFIG_REG_WIDTH-1 downto 0) <= config_reg_data_regfile;

		internal_config_reg_addr <= config_reg_addr_vector(5 downto 3);
		internal_config_reg_data <= config_reg_data_vector(CUR_DEFAULT_CONFIG_REG_WIDTH*2-1 downto CONFIG_REG_WIDTH);
		internal_config_reg_we <= config_reg_we_vector(1);

	--################################################################################
	--################################################################################

	pc_debug_out <= pc;

	--################################################################################
	--################################################################################

	--================================================================================--
	-- 	ASSIGNING the input signals for the pc_multiplexer
	--================================================================================--

	--pc_multiplexer_ins <= pc & registered_mem_addr_in;


	--================================================================================--
	-- 		CHECKING THE LOCAL GENERICS FOR WPPE_2.VHD
	--================================================================================--

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	--SIM_MODE :IF (simulation = true) GENERATE
	--
	--ASSERT (check_local_generics = true)
	--	REPORT "Local generics are contradictory"
	--	SEVERITY ERROR;
	--
	--END GENERATE SIM_MODE;

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	--CNN_CHECK_BRANCH_FLAGS :IF NUM_OF_BRANCH_FLAGS > 0 GENERATE
	--
	--	CNN_BRANCH_FLAG_MUX :FOR i in 1 to NUM_OF_BRANCH_FLAGS GENERATE
	--		
	--			 FU_flag_values.ADDER_flags.flags  <= sum_flags_vector.flags;
	--			 FU_flag_values.MUL_flags.flags	  <= mul_flags_vector.flags;
	--			 FU_flag_values.LOGIC_flags.flags  <= logic_flags_vector.flags;
	--			 FU_flag_values.SHIFT_flags.flags  <= shift_flags_vector.flags;
	--			 FU_flag_values.CTRL_flags(TOTAL_CTRL_REGS_NUM + NUM_OF_CONTROL_REGS downto 0)    	  
	--			 												  <= branch_mux_ctrl_registers_out(TOTAL_CTRL_REGS_NUM +
	--															                        NUM_OF_CONTROL_REGS downto 0);
	--
	--	END GENERATE CNN_BRANCH_FLAG_MUX;
	--
	--END GENERATE CNN_CHECK_BRANCH_FLAGS;
	--

	CONVERT_VECTOR_FU_FLAG_VALUES : FOR i in 1 to 1 GENERATE
		--MAX_NUM_FU = 20, MAX_NUM_FLAGS = 4
		--
		FU_flag_values_vector((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 1 - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * (1 - 1)) <= sum_flags_vector; -- FU_flag_values.ADDER_flags.flags;

		FU_flag_values_vector((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 2 - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * (2 - 1)) <= mul_flags_vector; --FU_flag_values.MUL_flags.flags;

		FU_flag_values_vector((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 3 - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * (3 - 1)) <= logic_flags_vector; --FU_flag_values.LOGIC_flags.flags;

		FU_flag_values_vector((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 4 - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * (4 - 1)) <= shift_flags_vector; --FU_flag_values.SHIFT_flags.flags;

		FU_flag_values_vector(
			TOTAL_CTRL_REGS_NUM + NUM_OF_CONTROL_REGS + (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 4 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 4) <= branch_mux_ctrl_registers_out(TOTAL_CTRL_REGS_NUM + NUM_OF_CONTROL_REGS downto 0); --FU_flag_values.CTRL_flags;

	END GENERATE CONVERT_VECTOR_FU_FLAG_VALUES;

	--=========================================================================================
	--=========================================================================================

	-- RESETTING THE NOT USED ARRAY SIGNALS E.G. div_remainders_array(0) to const = 0,
	-- because they are only needed, that in the case NUM_OF_SOMETHING_FU = 0
	-- no null-range expression occures: div_remainders_array(1 to NUM_OF_DIV_FU) 
	--																NUM_OF_DIV_FU = 0 ==>
	--												 div_remainders_array(1 to 0) !!! NOT OK

	--							thus:				 div_remainders_array(0 to NUM_OF_DIV_FU)
	--																NUM_OF_DIV_FU = 0 ==>
	--												 div_remainders_array(0 to 0) ==> OK 

	-- But the LOOPS for such signal always go from 1 to NUM_OF_SOMETHING_FU
	-- Thus the e.g. div_remainders(0) <= (others => '0');
	-- And it will be optimized away by the Synthesizer


	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- VLIW INSTRUCTION VECTOR COMING FROM THE RAM MEMORY 
	-- AND THE WRITE AND READ ENABLEs VECTOR FOR THE REGISTER FILE --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	--			instructions_vector(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH + 
	--											SUM_OF_FU*INSTR_WIDTH) <= '0'; 
	--			
	regf_write_enables(SUM_OF_FU) <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- RESETTING THE UNUSED SIGNALS FOR THE ADDERS CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	sum_instructions_vector(NUM_OF_ADD_FU * INSTR_WIDTH) <= '0';

	sum_1_op_read_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH) <= '0';
	sum_1_op_read_data(NUM_OF_ADD_FU * DATA_WIDTH)          <= '0';

	sum_2_op_read_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH) <= '0';
	sum_2_op_read_data(NUM_OF_ADD_FU * DATA_WIDTH)          <= '0';

	sum_selects(0) <= (others => '0');
	sum_enables(0) <= (others => '0');

	sum_flags(0) <= (others => '0');

	sum_regf_write_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH) <= '0';
	sum_regf_write_data(NUM_OF_ADD_FU * DATA_WIDTH)          <= '0';

	sum_regf_wes(NUM_OF_ADD_FU) <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	--  RESETTING THE UNUSED SIGNALS FOR THE MULTIPLIERS CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	mult_instructions_vector(NUM_OF_MUL_FU * INSTR_WIDTH)    <= '0';
	mult_1_op_read_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH) <= '0';
	mult_1_op_read_data(NUM_OF_MUL_FU * DATA_WIDTH)          <= '0';

	mult_2_op_read_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH) <= '0';
	mult_2_op_read_data(NUM_OF_MUL_FU * DATA_WIDTH)          <= '0';

	mult_enables(0) <= (others => '0');

	mult_regf_write_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH) <= '0';
	mult_regf_write_data(NUM_OF_MUL_FU * DATA_WIDTH)          <= '0';
	mult_regf_wes(NUM_OF_MUL_FU) <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	--  RESETTING THE UNUSED SIGNALS FOR THE DIVIDERS CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	-- Signal array for the remainders from the different divider FUs
	div_remainders_array(0)                    <= (others => '0');
	div_remainders(NUM_OF_DIV_FU * DATA_WIDTH) <= '0';

	div_instructions_vector(NUM_OF_DIV_FU * INSTR_WIDTH)    <= '0';
	div_1_op_read_addr(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH) <= '0';
	div_1_op_read_data(NUM_OF_DIV_FU * DATA_WIDTH)          <= '0';

	div_2_op_read_addr(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH) <= '0';
	div_2_op_read_data(NUM_OF_DIV_FU * DATA_WIDTH)          <= '0';

	div_enables(0) <= (others => '0');

	div_regf_write_addr(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH) <= '0';
	div_regf_write_data(NUM_OF_DIV_FU * DATA_WIDTH)          <= '0';

	div_regf_wes(NUM_OF_DIV_FU) <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- RESETTING THE UNUSED SIGNALS FOR THE LOGIC FUs CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	logic_instructions_vector(NUM_OF_LOGIC_FU * INSTR_WIDTH)    <= '0';
	logic_1_op_read_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH) <= '0';
	logic_1_op_read_data(NUM_OF_LOGIC_FU * DATA_WIDTH)          <= '0';

	logic_2_op_read_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH) <= '0';
	logic_2_op_read_data(NUM_OF_LOGIC_FU * DATA_WIDTH)          <= '0';

	logic_selects(0) <= (others => '0');
	logic_enables(0) <= (others => '0');

	logic_regf_write_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH) <= '0';
	logic_regf_write_data(NUM_OF_LOGIC_FU * DATA_WIDTH)          <= '0';

	logic_regf_wes(NUM_OF_LOGIC_FU) <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- RESETTING THE UNUSED SIGNALS FOR THE SHIFT FUs CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	shift_instructions_vector(NUM_OF_SHIFT_FU * INSTR_WIDTH)    <= '0';
	shift_1_op_read_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH) <= '0';
	shift_1_op_read_data(NUM_OF_SHIFT_FU * DATA_WIDTH)          <= '0';

	shift_2_op_read_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH) <= '0';
	shift_2_op_read_data(NUM_OF_SHIFT_FU * DATA_WIDTH)          <= '0';

	shift_selects(0) <= (others => '0');
	shift_enables(0) <= (others => '0');

	shift_regf_write_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH) <= '0';
	shift_regf_write_data(NUM_OF_SHIFT_FU * DATA_WIDTH)          <= '0';

	shift_regf_wes(NUM_OF_SHIFT_FU) <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- RESETTING THE UNUSED SIGNALS FOR THE CPU CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	cpu_instructions_vector(NUM_OF_CPU_FU * INSTR_WIDTH)        <= '0';
	cpu_1_op_read_addr(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH) <= '0';
	cpu_1_op_read_data(NUM_OF_CPU_FU * CTRL_REG_WIDTH)          <= '0';

	cpu_enables(0) <= (others => '0');

	cpu_ctrl_regf_write_addr(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH) <= '0';
	cpu_ctrl_regf_write_data(NUM_OF_CPU_FU * CTRL_REG_WIDTH)          <= '0';

	cpu_ctrl_regf_wes(NUM_OF_CPU_FU) <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- RESETTING THE UNUSED SIGNALS FOR THE DPU CONTROL COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	dpu_instructions_vector(NUM_OF_DPU_FU * INSTR_WIDTH)    <= '0';
	dpu_1_op_read_addr(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH) <= '0';
	dpu_1_op_read_data(NUM_OF_DPU_FU * DATA_WIDTH)          <= '0';

	dpu_enables(0) <= (others => '0');

	dpu_regf_write_addr(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH) <= '0';
	dpu_regf_write_data(NUM_OF_DPU_FU * DATA_WIDTH)          <= '0';

	dpu_regf_wes(NUM_OF_DPU_FU) <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	--  RESETTING THE UNUSED SIGNALS FOR THE CONTROL REGISTER FILE COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	ctrl_regf_read_addr(CTRL_REGFILE_ADDR_WIDTH * NUM_OF_CPU_FU) <= '0';
	ctrl_regf_read_data(CTRL_REG_WIDTH * NUM_OF_CPU_FU)          <= '0';

	ctrl_regf_write_addr(CTRL_REGFILE_ADDR_WIDTH * NUM_OF_CPU_FU) <= '0';
	ctrl_regf_write_data(CTRL_REG_WIDTH * NUM_OF_CPU_FU)          <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	--  RESETTING THE UNUSED SIGNALS FOR THE REGISTER FILE COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	regf_read_addr(REG_FILE_ADDR_WIDTH * (2 * SUM_OF_FU - NUM_OF_DPU_FU)) <= '0';
	-- For DPU FU only one operand read addr/data needed !!!
	regf_read_data(DATA_WIDTH * (2 * SUM_OF_FU - NUM_OF_DPU_FU))          <= '0';
	-- For DPU FU only one operand read addr/data needed !!!

	regf_write_addr(REG_FILE_ADDR_WIDTH * SUM_OF_FU) <= '0';
	--			regf_write_addr <= (others => '0');
	regf_write_data(DATA_WIDTH * SUM_OF_FU)          <= '0';

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
	-- RESETTING THE UNUSED  SIGNALS FOR THE BLOCK RAM MEMORY COMPONENT --
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

	mem_data_in(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH) <= '0'; -- SUM_OF_FU + BRANCH INSTR.

	mem_data_out(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH) <= '0'; -- SUM_OF_FU + BRANCH INSTR.

	--=========================================================================================
	--=========================================================================================										


	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	-- RESETTING THE UNUSED SIGNALS FOR THE NOT GENERATED FUs to const = 0
	-- They will be optimized away by the Synthesizer
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	--=========================================================================================
	SUM_RESET_COND : IF (NUM_OF_ADD_FU = 0) GENERATE

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
		-- RESETTING TO 0 THE SIGNALS FOR THE ADDERS CONTROL COMPONENT --
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

		sum_instructions_vector <= (others => '0');

		sum_1_op_read_addr <= (others => '0');
		sum_1_op_read_data <= (others => '0');

		sum_2_op_read_addr <= (others => '0');
		sum_2_op_read_data <= (others => '0');

		sum_selects <= (others => (others => '0'));
		sum_enables <= (others => (others => '0'));

		sum_flags         <= (others => (others => '0'));
		sum_flags_vector  <= (others => '0');
		multiplexed_flags <= (others => '0');

		sum_regf_write_addr <= (others => '0');
		sum_regf_write_data <= (others => '0');

		sum_regf_wes <= (others => '0');

	END GENERATE SUM_RESET_COND;
	--=========================================================================================

	MULT_RESET_COND : IF (NUM_OF_MUL_FU = 0) GENERATE

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
		-- SIGNALS FOR THE MULTIPLIERS CONTROL COMPONENT --
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

		mult_instructions_vector <= (others => '0');
		mult_1_op_read_addr      <= (others => '0');
		mult_1_op_read_data      <= (others => '0');

		mult_2_op_read_addr <= (others => '0');
		mult_2_op_read_data <= (others => '0');

		mult_enables <= (others => (others => '0'));

		mult_regf_write_addr <= (others => '0');
		mult_regf_write_data <= (others => '0');

		mult_regf_wes <= (others => '0');

	END GENERATE MULT_RESET_COND;
	--=========================================================================================


	DIV_RESET_COND : IF (NUM_OF_DIV_FU = 0) GENERATE

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
		-- SIGNALS FOR THE DIVIDERS CONTROL COMPONENT --
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

		-- Signal array for the remainders from the different divider FUs
		div_remainders_array <= (others => (others => '0'));
		div_remainders       <= (others => '0');

		div_instructions_vector <= (others => '0');
		div_1_op_read_addr      <= (others => '0');
		div_1_op_read_data      <= (others => '0');

		div_2_op_read_addr <= (others => '0');
		div_2_op_read_data <= (others => '0');

		div_enables <= (others => (others => '0'));

		div_regf_write_addr <= (others => '0');
		div_regf_write_data <= (others => '0');

		div_regf_wes <= (others => '0');

	END GENERATE DIV_RESET_COND;
	--=========================================================================================


	LOGIC_RESET_COND : IF (NUM_OF_LOGIC_FU = 0) GENERATE

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
		-- RESETTING TO 0 THE SIGNALS FOR THE LOGIC FUs CONTROL COMPONENT --
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

		logic_instructions_vector <= (others => '0');
		logic_1_op_read_addr      <= (others => '0');
		logic_1_op_read_data      <= (others => '0');

		logic_2_op_read_addr <= (others => '0');
		logic_2_op_read_data <= (others => '0');

		logic_selects <= (others => (others => '0'));
		logic_enables <= (others => (others => '0'));

		logic_regf_write_addr <= (others => '0');
		logic_regf_write_data <= (others => '0');

		logic_regf_wes <= (others => '0');

	END GENERATE LOGIC_RESET_COND;
	--=========================================================================================

	SHIFT_RESET_COND : IF (NUM_OF_SHIFT_FU = 0) GENERATE

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
		-- RESETTING TO 0 THE SIGNALS FOR THE SHIFT FUs CONTROL COMPONENT --
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

		shift_instructions_vector <= (others => '0');
		shift_1_op_read_addr      <= (others => '0');
		shift_1_op_read_data      <= (others => '0');

		shift_2_op_read_addr <= (others => '0');
		shift_2_op_read_data <= (others => '0');

		shift_selects <= (others => (others => '0'));
		shift_enables <= (others => (others => '0'));

		shift_regf_write_addr <= (others => '0');
		shift_regf_write_data <= (others => '0');

		shift_regf_wes <= (others => '0');

	END GENERATE SHIFT_RESET_COND;
	--=========================================================================================

	DPU_RESET_COND : IF (NUM_OF_DPU_FU = 0) GENERATE

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
		-- RESETTING TO 0 THE SIGNALS FOR THE DPU CONTROL COMPONENT --
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

		dpu_instructions_vector <= (others => '0');
		dpu_1_op_read_addr      <= (others => '0');
		dpu_1_op_read_data      <= (others => '0');

		dpu_enables <= (others => (others => '0'));

		dpu_regf_write_addr <= (others => '0');
		dpu_regf_write_data <= (others => '0');

		dpu_regf_wes <= (others => '0');

	END GENERATE DPU_RESET_COND;
	--=========================================================================================
	CPU_RESET_COND : IF (NUM_OF_CPU_FU = 0) GENERATE

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
		-- RESETTING TO 0 THE SIGNALS FOR THE CPU COMPONENT --
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--

		cpu_instructions_vector <= (others => '0');
		cpu_1_op_read_addr      <= (others => '0');
		cpu_1_op_read_data      <= (others => '0');

		cpu_enables <= (others => (others => '0'));

		cpu_ctrl_regf_write_addr <= (others => '0');
		cpu_ctrl_regf_write_data <= (others => '0');

		cpu_ctrl_regf_wes <= (others => '0');

	END GENERATE CPU_RESET_COND;
	--=========================================================================================


	--=========================================================================================
	--=========================================================================================


	-- CONNECTING THE OUTPUT SIGNALS CONTAINING THE
	-- REMAINDER VALUES OF THE DIVISION FROM THE
	-- DIVIDER FUs with the remainder array of the WPPE

	--=================================================================================--
	DIV_REMAINDERS_COND : IF (NUM_OF_DIV_FU > 0) GENERATE
		remainders : FOR i in 1 to NUM_OF_DIV_FU GENERATE
			div_remainders_array(i) <= div_remainders(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1));

		END GENERATE remainders;

	END GENERATE DIV_REMAINDERS_COND;
	--=================================================================================--

	--*************************************************************************************************************--
	--*************************************************************************************************************--
	--*************************************************************************************************************--
	--*************************************************************************************************************--


	----------------------------------------------
	----------------------------------------------
	CPU_COND_CONNECT : IF NUM_OF_CPU_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!--
		-- Connecting the read and write ports of the CONTROL register file with
		-- the read and write ports of the CPU functional units
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!--

		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--=================================================================================--
		-- Connecting the WRITE_ENABLE inputs of CONTROL REGISTER_FILE with write_enables of 
		-- CPU Functional Units
		--=================================================================================--
		CPU_CTRL_REGF_WRITE_EN_COND : IF (NUM_OF_CPU_FU > 0) GENERATE
			ctrl_regf_write_enables(NUM_OF_CPU_FU - 1 downto 0) <= cpu_ctrl_regf_wes(NUM_OF_CPU_FU - 1 downto 0);

		END GENERATE CPU_CTRL_REGF_WRITE_EN_COND;
		--=================================================================================--

		--=================================================================================--
		-- Connecting the READ_ADDRESS inputs of CONTROL REGISTER_FILE with OUTputs 
		-- cpu_read_addresses of CPUs
		--=================================================================================--

		--------------------------------
		---------------------------------
		-- CPUs READ ADDRESS SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		CPU_CTRL_REGF_READ_ADDR_COND : IF (NUM_OF_CPU_FU > 0) GENERATE
			ctrl_regf_read_addr(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH - 1 downto 0) <= cpu_1_op_read_addr(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE CPU_CTRL_REGF_READ_ADDR_COND;
		--=================================================================================--

		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--=================================================================================--
		-- Connecting the READ_DATA OUTputs of CTRL REGISTER_FILE with read_data INputs of FUs
		--=================================================================================--

		---------------------------------
		---------------------------------
		-- CPU DATA SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		CPU_CTRL_REGF_READ_DATA_COND : IF (NUM_OF_CPU_FU > 0) GENERATE
			cpu_1_op_read_data(NUM_OF_CPU_FU * CTRL_REG_WIDTH - 1 downto 0) <= ctrl_regf_read_data(CTRL_REG_WIDTH * NUM_OF_CPU_FU - 1 downto 0);

		END GENERATE CPU_CTRL_REGF_READ_DATA_COND;
		--=================================================================================--


		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--------------------------------
		---------------------------------
		-- CPUs WRITE ADDRESS SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		-- Connecting the WRITE_ADDRESS inputs of CONTROL REGISTER_FILE with 
		-- write_addresses OUTputs of CPU FUs
		--=================================================================================--

		--=================================================================================--
		CPU_CTRL_REGF_WRITE_ADDR_COND : IF (NUM_OF_CPU_FU > 0) GENERATE
			ctrl_regf_write_addr(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH - 1 downto 0) <= cpu_ctrl_regf_write_addr(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE CPU_CTRL_REGF_WRITE_ADDR_COND;
		--=================================================================================--

		--------------------------------
		---------------------------------
		-- CPUs WRITE DATA SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		-- Connecting the WRITE_DATA inputs of CONTROL REGISTER_FILE with 
		-- write_data OUTputs of CPU FUs
		--=================================================================================--

		--=================================================================================--
		CPU_CTRL_REGF_WRITE_DATA_COND : IF (NUM_OF_CPU_FU > 0) GENERATE
			ctrl_regf_write_data(NUM_OF_CPU_FU * CTRL_REG_WIDTH - 1 downto 0) <= cpu_ctrl_regf_write_data(NUM_OF_CPU_FU * CTRL_REG_WIDTH - 1 downto 0);

		END GENERATE CPU_CTRL_REGF_WRITE_DATA_COND;
	--=================================================================================--


	----------------------------------------------
	----------------------------------------------
	END GENERATE CPU_COND_CONNECT;
	----------------------------------------------
	----------------------------------------------


	--*************************************************************************************************************--
	--*************************************************************************************************************--
	--*************************************************************************************************************--
	--*************************************************************************************************************--

	----------------------------------------------
	----------------------------------------------
	COND_CONNECT : IF SUM_OF_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!--
		-- Connecting the read and write ports of the register file with
		-- the read and write ports of the functional units
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!--

		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--=================================================================================--
		-- Connecting the WRITE_ENABLE inputs of REGISTER_FILE with write_enables of Functional Units
		--=================================================================================--
		-- Layout is:
		--	regf_write_enables <= 
		--		(dpu_regf_wes & shift_regf_wes & logic_regf_wes & div_regf_wes & mult_regf_wes & sum_regf_wes)

		--=================================================================================--
		DPU_REGF_WRITE_EN_COND : IF (NUM_OF_DPU_FU > 0) GENERATE
			regf_write_enables(
				(NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) - 1 downto (NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU)
			) <= dpu_regf_wes(NUM_OF_DPU_FU - 1 downto 0);

		END GENERATE DPU_REGF_WRITE_EN_COND;
		--=================================================================================--
		SHIFT_REGF_WRITE_EN_COND : IF (NUM_OF_SHIFT_FU > 0) GENERATE
			regf_write_enables(
				(NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) - 1 downto (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU)
			) <= shift_regf_wes(NUM_OF_SHIFT_FU - 1 downto 0);

		END GENERATE SHIFT_REGF_WRITE_EN_COND;
		--=================================================================================--
		LOGIC_REGF_WRITE_EN_COND : IF (NUM_OF_LOGIC_FU > 0) GENERATE
			regf_write_enables((NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) - 1 downto (NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU)) <= logic_regf_wes(NUM_OF_LOGIC_FU - 1 downto 0);

		END GENERATE LOGIC_REGF_WRITE_EN_COND;
		--=================================================================================--
		DIV_REGF_WRITE_EN_COND : IF (NUM_OF_DIV_FU > 0) GENERATE
			regf_write_enables((NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) - 1 downto (NUM_OF_MUL_FU + NUM_OF_ADD_FU)) <= div_regf_wes(NUM_OF_DIV_FU - 1 downto 0);

		END GENERATE DIV_REGF_WRITE_EN_COND;
		--=================================================================================--
		MULT_REGF_WRITE_EN_COND : IF (NUM_OF_MUL_FU > 0) GENERATE
			regf_write_enables((NUM_OF_MUL_FU + NUM_OF_ADD_FU) - 1 downto NUM_OF_ADD_FU) <= mult_regf_wes(NUM_OF_MUL_FU - 1 downto 0);

		END GENERATE MULT_REGF_WRITE_EN_COND;
		--=================================================================================--
		SUM_REGF_WRITE_EN_COND : IF (NUM_OF_ADD_FU > 0) GENERATE
			regf_write_enables(NUM_OF_ADD_FU - 1 downto 0) <= sum_regf_wes(NUM_OF_ADD_FU - 1 downto 0);

		END GENERATE SUM_REGF_WRITE_EN_COND;
		--=================================================================================--


		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--=================================================================================--
		-- Connecting the READ_ADDRESS inputs of REGISTER_FILE with OUTputs read_addresses of FUs
		--=================================================================================--

		--------------------------------
		---------------------------------
		-- DPUs READ ADDRESS SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		DPU_REGF_READ_ADDR_COND : IF (NUM_OF_DPU_FU > 0) GENERATE

			-- The layout of the connection is:																

			-- Addresses_for_first_operands_of_DPU	&				
			--   ADDRESSES_for_second_operands_of_SHIFT & Addresses_for_first_operands_of_SHIFT	&				
			-- 	 ADDRESSES_for_second_operands_of_LOGIC & Addresses_for_first_operands_of_LOGIC	&				
			-- 	    ADDRESSES_for_second_operands_of_DIV & Addresses_for_first_operands_of_DIV			&				
			-- 			ADDRESSES_for_second_operands_of_MUL & Addresses_for_first_operands_of_MUL			&
			--					ADDRESSES_for_second_operands_of_SUM & Addresses_for_first_operands_of_SUM		

			regf_read_addr(
				(NUM_OF_DPU_FU + 2 * (NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU
					)
				) * REG_FILE_ADDR_WIDTH - 1 downto (NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU
				) * 2 * REG_FILE_ADDR_WIDTH) <= dpu_1_op_read_addr(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE DPU_REGF_READ_ADDR_COND;
		--=================================================================================--


		--------------------------------
		---------------------------------
		-- SHIFT FUs READ ADDRESS SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		SHIFT_REGF_READ_ADDR_COND : IF (NUM_OF_SHIFT_FU > 0) GENERATE

			-- The layout of the connection is:																

			-- ADDRESSES_for_second_operands_of_SHIFT & Addresses_for_first_operands_of_SHIFT	&				
			-- 	ADDRESSES_for_second_operands_of_LOGIC & Addresses_for_first_operands_of_LOGIC	&				
			-- 		ADDRESSES_for_second_operands_of_DIV & Addresses_for_first_operands_of_DIV			&				
			-- 			ADDRESSES_for_second_operands_of_MUL & Addresses_for_first_operands_of_MUL			&
			--					ADDRESSES_for_second_operands_of_SUM & Addresses_for_first_operands_of_SUM		

			regf_read_addr(
				(NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * REG_FILE_ADDR_WIDTH - 1 downto (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * REG_FILE_ADDR_WIDTH) <= (shift_2_op_read_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto
						0) & shift_1_op_read_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto 0));

		END GENERATE SHIFT_REGF_READ_ADDR_COND;
		--=================================================================================--

		---------------------------------
		---------------------------------
		-- LOGIC FUs READ ADDRESS SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		LOGIC_REGF_READ_ADDR_COND : IF (NUM_OF_LOGIC_FU > 0) GENERATE

			-- The layout of the connection is:																

			-- ADDRESSES_for_second_operands_of_SHIFT & Addresses_for_first_operands_of_SHIFT	&				
			-- 	ADDRESSES_for_second_operands_of_LOGIC & Addresses_for_first_operands_of_LOGIC	&				
			-- 		ADDRESSES_for_second_operands_of_DIV & Addresses_for_first_operands_of_DIV			&				
			-- 			ADDRESSES_for_second_operands_of_MUL & Addresses_for_first_operands_of_MUL			&
			--					ADDRESSES_for_second_operands_of_SUM & Addresses_for_first_operands_of_SUM		

			regf_read_addr((NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * REG_FILE_ADDR_WIDTH - 1 downto (NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * REG_FILE_ADDR_WIDTH) <= (logic_2_op_read_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0) &
					logic_1_op_read_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0));

		END GENERATE LOGIC_REGF_READ_ADDR_COND;
		--=================================================================================--

		---------------------------------
		---------------------------------
		-- DIVIDER READ ADDRESS SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		DIV_REGF_READ_ADDR_COND : IF (NUM_OF_DIV_FU > 0) GENERATE

			-- The layout of the connection is:																

			-- ADDRESSES_for_second_operands_of_SHIFT & Addresses_for_first_operands_of_SHIFT	&				
			-- 	ADDRESSES_for_second_operands_of_LOGIC & Addresses_for_first_operands_of_LOGIC	&				
			-- 		ADDRESSES_for_second_operands_of_DIV & Addresses_for_first_operands_of_DIV			&				
			-- 			ADDRESSES_for_second_operands_of_MUL & Addresses_for_first_operands_of_MUL			&
			--					ADDRESSES_for_second_operands_of_SUM & Addresses_for_first_operands_of_SUM	

			regf_read_addr((NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * REG_FILE_ADDR_WIDTH - 1 downto (NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * REG_FILE_ADDR_WIDTH) <= (div_2_op_read_addr(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH - 1 downto 0) & div_1_op_read_addr(NUM_OF_DIV_FU *
						REG_FILE_ADDR_WIDTH - 1 downto 0));

		END GENERATE DIV_REGF_READ_ADDR_COND;
		--=================================================================================--

		---------------------------------
		---------------------------------
		-- MULTIPLIER READ ADDRESS SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		MULT_REGF_READ_ADDR_COND : IF (NUM_OF_MUL_FU > 0) GENERATE

			-- ADDRESSES_for_second_operands_of_SHIFT & Addresses_for_first_operands_of_SHIFT	&				
			-- 	ADDRESSES_for_second_operands_of_LOGIC & Addresses_for_first_operands_of_LOGIC	&				
			-- 		ADDRESSES_for_second_operands_of_DIV & Addresses_for_first_operands_of_DIV			&				
			-- 			ADDRESSES_for_second_operands_of_MUL & Addresses_for_first_operands_of_MUL			&
			--					ADDRESSES_for_second_operands_of_SUM & Addresses_for_first_operands_of_SUM	

			regf_read_addr((NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * REG_FILE_ADDR_WIDTH - 1 downto NUM_OF_ADD_FU * 2 * REG_FILE_ADDR_WIDTH) <= (mult_2_op_read_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0) & mult_1_op_read_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0));

		END GENERATE MULT_REGF_READ_ADDR_COND;
		--=================================================================================--

		------------------------------
		------------------------------
		-- ADDER READ ADDRESS SIGNALS CONNECTION:
		------------------------------
		------------------------------

		--=================================================================================--
		SUM_REGF_READ_ADDR_COND : IF (NUM_OF_ADD_FU > 0) GENERATE

			-- The layout of the connection is:

			-- ADDRESSES_for_second_operands_of_SHIFT & Addresses_for_first_operands_of_SHIFT	&				
			-- 	ADDRESSES_for_second_operands_of_LOGIC & Addresses_for_first_operands_of_LOGIC	&				
			-- 		ADDRESSES_for_second_operands_of_DIV & Addresses_for_first_operands_of_DIV			&				
			-- 			ADDRESSES_for_second_operands_of_MUL & Addresses_for_first_operands_of_MUL			&
			--					ADDRESSES_for_second_operands_of_SUM & Addresses_for_first_operands_of_SUM	

			regf_read_addr(NUM_OF_ADD_FU * 2 * REG_FILE_ADDR_WIDTH - 1 downto 0) <= (sum_2_op_read_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0) & sum_1_op_read_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0));

		END GENERATE SUM_REGF_READ_ADDR_COND;
		--=================================================================================--


		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--=================================================================================--
		-- Connecting the READ_DATA OUTputs of REGISTER_FILE with read_data INputs of FUs
		--=================================================================================--
		---------------------------------
		---------------------------------
		-- DPU DATA SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		DPU_REGF_READ_DATA_COND : IF (NUM_OF_DPU_FU > 0) GENERATE

			-- Layout is:
			-- DATA_for_first_operands_of_DPU 	&
			--  DATA_for_second_operands_of_SHIFT & DATA_for_first_operands_of_SHIFT 	&
			-- 	DATA_for_second_operands_of_LOGIC & DATA_for_first_operands_of_LOGIC 	&
			-- 		DATA_for_second_operands_of_DIV & DATA_for_first_operands_of_DIV 			&
			-- 			DATA_for_second_operands_of_MUL & DATA_for_first_operands_of_MUL 			&
			-- 				DATA_for_second_operands_of_SUM & DATA_for_first_operands_of_SUM																				

			dpu_1_op_read_data(NUM_OF_DPU_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data(
					(NUM_OF_DPU_FU + 2 * NUM_OF_SHIFT_FU + 2 * NUM_OF_LOGIC_FU + 2 * NUM_OF_DIV_FU + 2 * NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * DATA_WIDTH);

		END GENERATE DPU_REGF_READ_DATA_COND;
		--=================================================================================--

		---------------------------------
		---------------------------------
		-- SHIFT FU DATA SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		SHIFT_REGF_READ_DATA_COND : IF (NUM_OF_SHIFT_FU > 0) GENERATE

			-- Layout is:
			-- DATA_for_second_operands_of_SHIFT & DATA_for_first_operands_of_SHIFT 	&
			-- 	DATA_for_second_operands_of_LOGIC & DATA_for_first_operands_of_LOGIC 	&
			-- 		DATA_for_second_operands_of_DIV & DATA_for_first_operands_of_DIV 			&
			-- 			DATA_for_second_operands_of_MUL & DATA_for_first_operands_of_MUL 			&
			-- 				DATA_for_second_operands_of_SUM & DATA_for_first_operands_of_SUM																				

			shift_2_op_read_data(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data(
					(NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * DATA_WIDTH - 1 downto (NUM_OF_SHIFT_FU + 2 * NUM_OF_LOGIC_FU + 2 * NUM_OF_DIV_FU + 2 * NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH);

			shift_1_op_read_data(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data(
					(NUM_OF_SHIFT_FU + 2 * NUM_OF_LOGIC_FU + 2 * NUM_OF_DIV_FU + 2 * NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * DATA_WIDTH);

		END GENERATE SHIFT_REGF_READ_DATA_COND;
		--=================================================================================--


		---------------------------------
		---------------------------------
		-- LOGIC FU DATA SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		LOGIC_REGF_READ_DATA_COND : IF (NUM_OF_LOGIC_FU > 0) GENERATE
			-- Layout is:
			-- DATA_for_second_operands_of_LOGIC & DATA_for_first_operands_of_LOGIC &
			-- 	DATA_for_second_operands_of_DIV & DATA_for_first_operands_of_DIV &
			-- 		DATA_for_second_operands_of_MUL & DATA_for_first_operands_of_MUL &
			-- 					DATA_for_second_operands_of_SUM & DATA_for_first_operands_of_SUM																				

			logic_2_op_read_data(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data((NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * DATA_WIDTH - 1 downto (NUM_OF_LOGIC_FU + 2 * NUM_OF_DIV_FU + 2 * NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH);

			logic_1_op_read_data(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data(
					(NUM_OF_LOGIC_FU + 2 * NUM_OF_DIV_FU + 2 * NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * DATA_WIDTH);

		END GENERATE LOGIC_REGF_READ_DATA_COND;
		--=================================================================================--

		---------------------------------
		---------------------------------
		-- DIVIDER DATA SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		DIV_REGF_READ_DATA_COND : IF (NUM_OF_DIV_FU > 0) GENERATE
			-- Layout is:
			-- DATA_for_second_operands_of_DIV & DATA_for_first_operands_of_DIV &
			-- 		DATA_for_second_operands_of_MUL & DATA_for_first_operands_of_MUL &
			-- 					DATA_for_second_operands_of_SUM & DATA_for_first_operands_of_SUM																				

			div_2_op_read_data(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data((NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * DATA_WIDTH - 1 downto (NUM_OF_DIV_FU + 2 * NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH);

			div_1_op_read_data(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data(
					(NUM_OF_DIV_FU + 2 * NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * DATA_WIDTH);

		END GENERATE DIV_REGF_READ_DATA_COND;
		--=================================================================================--

		---------------------------------
		---------------------------------
		-- MULTIPLIER DATA SIGNALS CONNECTION:
		---------------------------------
		---------------------------------

		--=================================================================================--
		MULT_REGF_READ_DATA_COND : IF (NUM_OF_MUL_FU > 0) GENERATE

			-- Layout is:
			-- DATA_for_second_operands_of_DIV & DATA_for_first_operands_of_DIV &
			-- 		DATA_for_second_operands_of_MUL & DATA_for_first_operands_of_MUL &
			-- 					DATA_for_second_operands_of_SUM & DATA_for_first_operands_of_SUM																				

			mult_2_op_read_data(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data((NUM_OF_MUL_FU + NUM_OF_ADD_FU) * 2 * DATA_WIDTH - 1 downto (NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH);

			mult_1_op_read_data(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data(
					(NUM_OF_MUL_FU + 2 * NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto 2 * NUM_OF_ADD_FU * DATA_WIDTH);

		END GENERATE MULT_REGF_READ_DATA_COND;
		--=================================================================================--

		------------------------------
		------------------------------
		-- ADDER DATA SIGNALS CONNECTION:
		------------------------------
		------------------------------

		--=================================================================================--
		SUM_REGF_READ_DATA_COND : IF (NUM_OF_ADD_FU > 0) GENERATE

			-- Layout is:
			-- DATA_for_second_operands_of_MUL & DATA_for_first_operands_of_MUL &
			-- 				DATA_for_second_operands_of_SUM & DATA_for_first_operands_of_SUM																				

			sum_2_op_read_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data(2 * NUM_OF_ADD_FU * DATA_WIDTH - 1 downto DATA_WIDTH * NUM_OF_ADD_FU);

			sum_1_op_read_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0) <= regf_read_data(DATA_WIDTH * NUM_OF_ADD_FU - 1 downto 0);

		END GENERATE SUM_REGF_READ_DATA_COND;
		--=================================================================================--															


		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--=================================================================================--
		-- Connecting the WRITE_ADDRESS inputs of REGISTER_FILE with write_addresses OUTputs of FUs
		--=================================================================================--

		-- Layout: 
		-- ADDRESSES_for_result_of_DPU   &
		-- ADDRESSES_for_result_of_SHIFT &
		-- ADDRESSES_for_result_of_LOGIC & ADDRESSES_for_result_of_DIV & 
		-- ADDRESSES_for_result_of_MULT  & ADDRESSES_for_result_of_SUM

		--=================================================================================--
		DPU_REGF_WRITE_ADDR_COND : IF (NUM_OF_DPU_FU > 0) GENERATE
			regf_write_addr(
				(NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH - 1 downto (NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH
			) <= dpu_regf_write_addr(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE DPU_REGF_WRITE_ADDR_COND;
		--=================================================================================--


		-- Layout: ADDRESSES_for_result_of_SHIFT &
		-- ADDRESSES_for_result_of_LOGIC & ADDRESSES_for_result_of_DIV & 
		-- ADDRESSES_for_result_of_MULT  & ADDRESSES_for_result_of_SUM

		--=================================================================================--
		SHIFT_REGF_WRITE_ADDR_COND : IF (NUM_OF_SHIFT_FU > 0) GENERATE
			regf_write_addr(
				(NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH - 1 downto (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH
			) <= shift_regf_write_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE SHIFT_REGF_WRITE_ADDR_COND;

		--=================================================================================--
		LOGIC_REGF_WRITE_ADDR_COND : IF (NUM_OF_LOGIC_FU > 0) GENERATE
			regf_write_addr((NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH - 1 downto (NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH) <= logic_regf_write_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE LOGIC_REGF_WRITE_ADDR_COND;
		--=================================================================================--
		DIV_REGF_WRITE_ADDR_COND : IF (NUM_OF_DIV_FU > 0) GENERATE
			regf_write_addr((NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH - 1 downto (NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH) <= div_regf_write_addr(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE DIV_REGF_WRITE_ADDR_COND;
		--=================================================================================--
		MULT_REGF_WRITE_ADDR_COND : IF (NUM_OF_MUL_FU > 0) GENERATE
			regf_write_addr((NUM_OF_MUL_FU + NUM_OF_ADD_FU) * REG_FILE_ADDR_WIDTH - 1 downto NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH) <= mult_regf_write_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE MULT_REGF_WRITE_ADDR_COND;
		--=================================================================================--
		SUM_REGF_WRITE_ADDR_COND : IF (NUM_OF_ADD_FU > 0) GENERATE
			regf_write_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0) <= sum_regf_write_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0);

		END GENERATE SUM_REGF_WRITE_ADDR_COND;
		--=================================================================================--

		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--=================================================================================--
		-- Connecting the WRITE_DATA inputs of REGISTER_FILE with write_data outputs of FUs
		--=================================================================================--

		-- Layout: 
		-- DATA_for_result_of_DPU &
		-- DATA_for_result_of_SHIFT &
		-- DATA_for_result_of_LOGIC & DATA_for_result_of_DIV & 
		-- DATA_for_result_of_MULT  & DATA_for_result_of_SUM  
		--=================================================================================--

		---------
		-- DPU --
		---------
		DPU_REGF_WRITE_DATA_COND : IF (NUM_OF_DPU_FU > 0) GENERATE
			
			FIM_XOR_DPU : IF (FAULT_INJECTION_MODULE_EN = TRUE) GENERATE
				SEL_FU_DPU : FOR i in 0 to NUM_OF_DPU_FU-1 generate
					regf_write_data(((i+1)*DATA_WIDTH + (NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) - 1 downto 
						(i*DATA_WIDTH) + (NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= 
						--dpu_regf_write_data(((i+1)*DATA_WIDTH) -1 downto (i*DATA_WIDTH)) xor mask_r when (fu_sel_r(NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+NUM_OF_LOGIC_FU+NUM_OF_SHIFT_FU+i) and pe_sel_r) = '1'
						dpu_regf_write_data(((i+1)*DATA_WIDTH)-1 downto (i*DATA_WIDTH)) xor mask_r(DATA_WIDTH-1 downto 0) when((unsigned(fu_sel_r) = (NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+NUM_OF_LOGIC_FU+NUM_OF_SHIFT_FU+i)) and pe_sel_r = '1')
--						mask_r(DATA_WIDTH-CUR_DEFAULT_NUM_OF_FUS-5 downto 0) & fu_sel_r(CUR_DEFAULT_NUM_OF_FUS-1 downto 0) & x"1" when pe_sel_r = '1'
--						else mask_r(DATA_WIDTH-CUR_DEFAULT_NUM_OF_FUS-5 downto 0) & fu_sel_r(CUR_DEFAULT_NUM_OF_FUS-1 downto 0) & x"2" when pe_sel_r = '0'
--						else mask_r(DATA_WIDTH-5 downto 0) & x"3" when((unsigned(fu_sel_r) = (NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+NUM_OF_LOGIC_FU+NUM_OF_SHIFT_FU+i)) and pe_sel_r = '1')
--						else mask_r(DATA_WIDTH-5 downto 0) & x"4" when((unsigned(fu_sel_r) = (NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+NUM_OF_LOGIC_FU+NUM_OF_SHIFT_FU+i)) and pe_sel_r = '0')
--Tested					(mask_r(DATA_WIDTH-5 downto 0) & x"4");
						else dpu_regf_write_data(((i+1)*DATA_WIDTH) -1 downto (i*DATA_WIDTH));
				END GENERATE SEL_FU_DPU;
			END GENERATE FIM_XOR_DPU;

			DEFAULT_DPU_OUTPUT : IF (FAULT_INJECTION_MODULE_EN = FALSE) GENERATE
					regf_write_data((NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto 
						(NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= 
						dpu_regf_write_data(NUM_OF_DPU_FU * DATA_WIDTH -1 downto 0);
			END GENERATE DEFAULT_DPU_OUTPUT;

		END GENERATE DPU_REGF_WRITE_DATA_COND;
		--=================================================================================--

		-- Layout: 
		-- DATA_for_result_of_SHIFT &
		-- DATA_for_result_of_LOGIC & DATA_for_result_of_DIV & 
		-- DATA_for_result_of_MULT  & DATA_for_result_of_SUM  
		--=================================================================================--

		-----------
		-- SHIFT --
		-----------
		SHIFT_REGF_WRITE_DATA_COND : IF (NUM_OF_SHIFT_FU > 0) GENERATE

			FIM_XOR_SHIFT : IF (FAULT_INJECTION_MODULE_EN = TRUE) GENERATE
				SEL_FU_SHIFT : FOR i in 0 to NUM_OF_SHIFT_FU-1 generate
	
					regf_write_data(((i+1)*DATA_WIDTH + (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) - 1 downto (i*DATA_WIDTH) + (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= 
--						shift_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r when (fu_sel_r(NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+NUM_OF_LOGIC_FU+i) and pe_sel_r) = '1'
						shift_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r when ((unsigned(fu_sel_r) = (NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+NUM_OF_LOGIC_FU+i)) and pe_sel_r = '1')
					else shift_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH));
--					regf_write_data((NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= 
--						shift_regf_write_data(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0) xor mask_r when (fu_sel_r(NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+NUM_OF_LOGIC_FU+i) and pe_sel_r) = '1'
--					else shift_regf_write_data(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0);

				END GENERATE SEL_FU_SHIFT;
			END GENERATE FIM_XOR_SHIFT;
	
			DEFAULT_SHIFT_OUTPUT : IF (FAULT_INJECTION_MODULE_EN = FALSE) GENERATE
					regf_write_data((NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= 
						shift_regf_write_data(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0);
			END GENERATE DEFAULT_SHIFT_OUTPUT;
			

		END GENERATE SHIFT_REGF_WRITE_DATA_COND;

		-----------
		-- LOGIC --
		-----------
		--=================================================================================--
		LOGIC_REGF_WRITE_DATA_COND : IF (NUM_OF_LOGIC_FU > 0) GENERATE
			FIM_XOR_LOGIC : IF (FAULT_INJECTION_MODULE_EN = TRUE) GENERATE
				SEL_FU_LOGIC : FOR i in 0 to NUM_OF_LOGIC_FU-1 generate
				
					regf_write_data((((i+1)*DATA_WIDTH) + (NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) - 1 downto (i*DATA_WIDTH) + ((NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH)) <= 
--						logic_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r  when (fu_sel_r(NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+i) and pe_sel_r) = '1'
						logic_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r  when ((unsigned(fu_sel_r) = (NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+i)) and pe_sel_r = '1')
					else logic_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH));
--					regf_write_data((NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= 
--						logic_regf_write_data(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0) xor mask_r  when (fu_sel_r(NUM_OF_ADD_FU+NUM_OF_MUL_FU+NUM_OF_DIV_FU+i) and pe_sel_r) = '1'
--					else logic_regf_write_data(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0);

				END GENERATE SEL_FU_LOGIC;
			END GENERATE FIM_XOR_LOGIC;

			DEFAULT_LOGIC_OUTPUT : IF (FAULT_INJECTION_MODULE_EN = FALSE) GENERATE
				regf_write_data((NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= logic_regf_write_data(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0);
			END GENERATE DEFAULT_LOGIC_OUTPUT;
			

		END GENERATE LOGIC_REGF_WRITE_DATA_COND;

		-------------
		-- DIVIDER --
		-------------
		--=================================================================================--
		DIV_REGF_WRITE_DATA_COND : IF (NUM_OF_DIV_FU > 0) GENERATE
			FIM_XOR_DIV : IF (FAULT_INJECTION_MODULE_EN = TRUE) GENERATE
				SEL_FU_DIV : FOR i in 0 to NUM_OF_DIV_FU-1 generate

					regf_write_data(((i+1)*DATA_WIDTH + (NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) - 1 downto (i*DATA_WIDTH) + ((NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH)) <= 
--					     div_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r when (fu_sel_r(NUM_OF_ADD_FU+NUM_OF_MUL_FU+i) and pe_sel_r) = '1' 
					     div_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r when ((unsigned(fu_sel_r) = (NUM_OF_ADD_FU+NUM_OF_MUL_FU+i)) and pe_sel_r = '1') 
					else div_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH));
--					regf_write_data((NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= 
--					     div_regf_write_data(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0) xor mask_r when (fu_sel_r(NUM_OF_ADD_FU+NUM_OF_MUL_FU+i) and pe_sel_r) = '1' 
--					else div_regf_write_data(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0);

				END GENERATE SEL_FU_DIV;
			END GENERATE FIM_XOR_DIV;

			DEFAULT_DIV_OUTPUT : IF (FAULT_INJECTION_MODULE_EN = FALSE) GENERATE
				regf_write_data((NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto (NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH) <= div_regf_write_data(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0);
			END GENERATE DEFAULT_DIV_OUTPUT;

		END GENERATE DIV_REGF_WRITE_DATA_COND;

		----------------
		-- MULTIPLIER --
		----------------
		--=================================================================================--
		MULT_REGF_WRITE_DATA_COND : IF (NUM_OF_MUL_FU > 0) GENERATE
			FIM_XOR_MUL : IF (FAULT_INJECTION_MODULE_EN = TRUE) GENERATE
				SEL_FU_MUL : FOR i in 0 to NUM_OF_MUL_FU-1 generate

					regf_write_data(((i+1)*DATA_WIDTH + (NUM_OF_ADD_FU) * DATA_WIDTH) - 1 downto (i*DATA_WIDTH) + (NUM_OF_ADD_FU * DATA_WIDTH)) <= 
--					     mult_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r when (fu_sel_r(NUM_OF_ADD_FU+i) and pe_sel_r) = '1'
					     mult_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r when ((unsigned(fu_sel_r) = (NUM_OF_ADD_FU+i)) and pe_sel_r = '1')
					else mult_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH));
--					regf_write_data((NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto NUM_OF_ADD_FU * DATA_WIDTH) <= 
--					     mult_regf_write_data(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0) xor mask_r when (fu_sel_r(NUM_OF_ADD_FU+i) and pe_sel_r) = '1'
--					else mult_regf_write_data(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0);

				END GENERATE SEL_FU_MUL;
			END GENERATE FIM_XOR_MUL;

			DEFAULT_MUL_OUTPUT : IF (FAULT_INJECTION_MODULE_EN = FALSE) GENERATE
				regf_write_data((NUM_OF_MUL_FU + NUM_OF_ADD_FU) * DATA_WIDTH - 1 downto NUM_OF_ADD_FU * DATA_WIDTH) <= mult_regf_write_data(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0);
			END GENERATE DEFAULT_MUL_OUTPUT;

		END GENERATE MULT_REGF_WRITE_DATA_COND;

		-----------
		-- ADDER --
		-----------
		--=================================================================================--
		SUM_REGF_WRITE_DATA_COND : IF (NUM_OF_ADD_FU > 0) GENERATE
			FIM_XOR_SUM : IF (FAULT_INJECTION_MODULE_EN = TRUE) GENERATE
				SEL_FU_ADD : FOR i in 0 to NUM_OF_ADD_FU-1 generate

					regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) <=
--					     sum_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r when (fu_sel_r(i) and pe_sel_r) = '1'
					     sum_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH)) xor mask_r when ((unsigned(fu_sel_r) = (i)) and pe_sel_r = '1')
					else sum_regf_write_data(((i+1)*DATA_WIDTH) - 1 downto (i*DATA_WIDTH));
--					regf_write_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0) <=
--					     sum_regf_write_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0) xor mask_r when (fu_sel_r(i) and pe_sel_r) = '1'
--					else sum_regf_write_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0);

				END GENERATE SEL_FU_ADD;
			END GENERATE FIM_XOR_SUM;

			DEFAULT_SUM_OUTPUT : IF (FAULT_INJECTION_MODULE_EN = FALSE) GENERATE
				regf_write_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0) <= sum_regf_write_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0);
			END GENERATE DEFAULT_SUM_OUTPUT;

		END GENERATE SUM_REGF_WRITE_DATA_COND;
		--=================================================================================--

		--*************************************************************************************************************--
		--*************************************************************************************************************--

		--=================================================================================--
		-- Connecting the instructions_vector for ALL FUs with the memory output 
		--=================================================================================--

		-- Layout:  
		--  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------						  
		-- |       BRANCH_inst (1!)            |              CPU_instrs 	          |              DPU_instrs 	          |              SHIFT_instrs           |             LOGIC_instrs        |         DIVS_instrs              |                MULS_instrs                 |         ADDERS_instrs         |
		-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------						  
		--	|	b_i_w!!! -1 ... i_w *num_cpu     |	i_w*num_cpu -1 ... i_w*num_dpu    |	i_w*num_dpu -1 ... i_w*num_shift     |	i_w*num_shift -1 ... i_w*num_log    | i_w*num_log -1 ... i_w*num_div  |	i_w*num_div -1 ... i_w *num_mul  | i_w*(num_mul+add_fu) - 1  ...  i_w*num_add |   i_w*num_add - 1	  ...   0  |
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		--		instructions_vector 		 <= mem_data_out;

		--=================================================================================--
		-- Connecting the xy_fu_instructions_vector for the SPECIFIC FUs with the 
		-- corresponding part of the global instructions_vector
		--=================================================================================--
		-- See process register_mem_loader_destination_addr at the end of the file !!!

		--		branch_instruction <= instructions_vector( BRANCH_INSTR_WIDTH +
		--				(NUM_OF_CPU_FU + NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU)*INSTR_WIDTH -1 
		--	  downto (NUM_OF_CPU_FU + NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH
		--			);
		--		--=================================================================================--
		CPU_INSTRUCTIONS_COND : IF (NUM_OF_CPU_FU > 0) GENERATE
			cpu_instructions_vector(NUM_OF_CPU_FU * INSTR_WIDTH - 1 downto 0) <= instructions_vector(
					(NUM_OF_CPU_FU + NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH - 1 downto (NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH);
		END GENERATE CPU_INSTRUCTIONS_COND;

		--=================================================================================--
		DPU_INSTRUCTIONS_COND : IF (NUM_OF_DPU_FU > 0) GENERATE
			dpu_instructions_vector(NUM_OF_DPU_FU * INSTR_WIDTH - 1 downto 0) <= instructions_vector(
					(NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH - 1 downto (NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH);
		END GENERATE DPU_INSTRUCTIONS_COND;
		--=================================================================================--
		SHIFT_INSTRUCTIONS_COND : IF (NUM_OF_SHIFT_FU > 0) GENERATE
			shift_instructions_vector(NUM_OF_SHIFT_FU * INSTR_WIDTH - 1 downto 0) <= instructions_vector(
					(NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH - 1 downto (NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH);
		END GENERATE SHIFT_INSTRUCTIONS_COND;
		--=================================================================================--
		LOGIC_INSTRUCTIONS_COND : IF (NUM_OF_LOGIC_FU > 0) GENERATE
			logic_instructions_vector(NUM_OF_LOGIC_FU * INSTR_WIDTH - 1 downto 0) <= instructions_vector((NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH - 1 downto (NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH);
		END GENERATE LOGIC_INSTRUCTIONS_COND;
		--=================================================================================--
		DIV_INSTRUCTIONS_COND : IF (NUM_OF_DIV_FU > 0) GENERATE
			div_instructions_vector(NUM_OF_DIV_FU * INSTR_WIDTH - 1 downto 0) <= instructions_vector((NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH - 1 downto (NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH);
		END GENERATE DIV_INSTRUCTIONS_COND;
		--=================================================================================--
		MULT_INSTRUCTIONS_COND : IF (NUM_OF_MUL_FU > 0) GENERATE
			mult_instructions_vector(NUM_OF_MUL_FU * INSTR_WIDTH - 1 downto 0) <= instructions_vector((NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH - 1 downto NUM_OF_ADD_FU * INSTR_WIDTH);

		END GENERATE MULT_INSTRUCTIONS_COND;
		--=================================================================================--
		SUM_INSTRUCTIONS_COND : IF (NUM_OF_ADD_FU > 0) GENERATE
			sum_instructions_vector(NUM_OF_ADD_FU * INSTR_WIDTH - 1 downto 0) <= instructions_vector(NUM_OF_ADD_FU * INSTR_WIDTH - 1 downto 0);

		END GENERATE SUM_INSTRUCTIONS_COND;
	--=================================================================================--


	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_CONNECT;
	----------------------------------------------
	----------------------------------------------

	--	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	--					-- GENERIC MULTIPLEXERS FOR CONTROL REGISTERS FLAGS, INSTANTIATION --
	--	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--


	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- BRANCH CONTROL AND FLAG SELECT COMPONENTS INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--


	flags_mux_unit : flags_sel_unit
		generic map(
			-- cadence translate_off		  		
			INSTANCE_NAME        => INSTANCE_NAME & "flags_mux_unit",
			-- cadence translate_on				
			WPPE_GENERICS_RECORD => WPPE_GENERICS_RECORD
		)
		port map(
			branch_flag_controls_vector => branch_flag_controls_vector, -- See the "WPPE_LIB.vhd" library for definition
			FU_flag_values_vector       => FU_flag_values_vector, -- See the "WPPE_LIB.vhd" library for definition
			branch_flag_values          => branch_flag_values
		);

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	test_rst <= configuring_reset or rst or en_instruction_memory;
	branch_ctr : branch_control
		generic map(
			-- cadence translate_off		  		
			INSTANCE_NAME        => INSTANCE_NAME & "/branch_ctr",
			-- cadence translate_on	
			WPPE_GENERICS_RECORD => WPPE_GENERICS_RECORD,
			BRANCH_INSTR_WIDTH   => BRANCH_INSTR_WIDTH,
			ADDR_WIDTH           => ADDR_WIDTH,
			-- shravan: 20120316: BRANCH_TARGET_WIDTH should be same as ADDR_WIDTH 
			--			BRANCH_TARGET_WIDTH => CUR_DEFAULT_BRANCH_TARGET_WIDTH,			

			BRANCH_TARGET_WIDTH  => ADDR_WIDTH,

			-- shravan : 20120317 : corrected BEGIN_OPCODE and END_OPCODE values of branch_instruction
			--			BEGIN_OPCODE		  => CUR_DEFAULT_BRANCH_OPCODE_BEGIN,
			--			END_OPCODE			  => CUR_DEFAULT_BRANCH_OPCODE_END,

			BEGIN_OPCODE         => (BRANCH_INSTR_WIDTH - 1),
			END_OPCODE           => (BRANCH_INSTR_WIDTH - 1) - (CUR_DEFAULT_OPCODE_FIELD_WIDTH) + 1,
			NUM_OF_BRANCH_FLAGS  => NUM_OF_BRANCH_FLAGS
		)
		port map(
			clk                         => REVERSED_gated_clock, --clk,
			rst                         => test_rst, --configuring_reset,
			--instruction_in              => branch_instruction_reg,
			instruction_in              => branch_instruction,
			pc                          => pc,
			enable_tcpa                 => enable_tcpa,
			branch_flag_controls_vector => branch_flag_controls_vector, -- See the "WPPE_LIB.vhd" library for definition
			branch_flag_values          => branch_flag_values
		);

	----------------------------------------------
	----------------------------------------------
	COND_ADDER : IF NUM_OF_ADD_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
		-- ADDERS CONTROL COMPONENT INSTANTIATION --
		--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

		add_instr_decode : adds_control
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME       => INSTANCE_NAME & "/add_instr_decode",
				-- cadence translate_on	

				--###################################
				--### SRECO: REGISTER FILE OFFSET ###
				RF_OFFSET           => RF_OFFSET,
				--###################################

				INSTR_WIDTH         => INSTR_WIDTH,
				NUM_OF_ADD_FU       => NUM_OF_ADD_FU,
				DATA_WIDTH          => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH => REG_FILE_ADDR_WIDTH,

				-- shravan : 20120326 : changing REG_FIELD_WIDTH to the REG_FILE_ADDR_WIDTH
				-- REG_FIELD_WIDTH	  => CUR_DEFAULT_REG_FIELD_WIDTH,

				REG_FIELD_WIDTH     => REG_FILE_ADDR_WIDTH,
				OPCODE_FIELD_WIDTH  => CUR_DEFAULT_OPCODE_FIELD_WIDTH
			)
			port map(
				clk                => REVERSED_gated_clock, --clk,
				rst                => configuring_reset,

				--flags => flags_from_adder, 

				flags_vector       => sum_flags_vector,

				------------------------
				-- INSTRUCTIONS FOR THE ADDER UNITS -- 
				------------------------		

				instr_vector       => sum_instructions_vector(NUM_OF_ADD_FU * INSTR_WIDTH - 1 downto 0),

				------------------------
				-- SUMMATORS READ ADDRESS PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				sum_1_op_read_addr => sum_1_op_read_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),
				sum_2_op_read_addr => sum_2_op_read_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				------------------------
				-- SUMMATORS READ DATA PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				sum_1_op_read_data => sum_1_op_read_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0),
				sum_2_op_read_data => sum_2_op_read_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- SUMMATORS write ADDRESS PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				sum_write_addr     => sum_regf_write_addr(NUM_OF_ADD_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- SUMMATORS WRITE DATA PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				sum_write_data     => sum_regf_write_data(NUM_OF_ADD_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- SUMMATORS WRITE ENABLE PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				sum_write_en       => sum_regf_wes(NUM_OF_ADD_FU - 1 downto 0)
			);

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_ADDER;
	----------------------------------------------
	----------------------------------------------

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- MULTIPLIERS CONTROL COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--


	----------------------------------------------
	----------------------------------------------
	COND_MULT : IF NUM_OF_MUL_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		mux_instr_decode : mult_control
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME       => INSTANCE_NAME & "/mux_instr_decode",
				-- cadence translate_on

				--###################################
				--### SRECO: REGISTER FILE OFFSET ###
				RF_OFFSET           => RF_OFFSET,
				--###################################

				INSTR_WIDTH         => INSTR_WIDTH,
				NUM_OF_MUL_FU       => NUM_OF_MUL_FU,
				DATA_WIDTH          => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH => REG_FILE_ADDR_WIDTH,

				-- shravan : 20120326 : changing REG_FIELD_WIDTH to the REG_FILE_ADDR_WIDTH
				--		REG_FIELD_WIDTH	  => CUR_DEFAULT_REG_FIELD_WIDTH,

				REG_FIELD_WIDTH     => REG_FILE_ADDR_WIDTH,
				OPCODE_FIELD_WIDTH  => CUR_DEFAULT_OPCODE_FIELD_WIDTH
			)
			port map(
				flags_vector        => mul_flags_vector,
				clk                 => REVERSED_gated_clock, --clk,
				rst                 => rst,
				------------------------
				-- INSTRUCTIONS FOR THE MULTIPLIER UNITS -- 
				------------------------		

				instr_vector        => mult_instructions_vector(NUM_OF_MUL_FU * INSTR_WIDTH - 1 downto 0),

				------------------------
				-- MULTIPLIER READ ADDRESS PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				mult_1_op_read_addr => mult_1_op_read_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),
				mult_2_op_read_addr => mult_2_op_read_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				------------------------
				-- MULTIPLIER READ DATA PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				mult_1_op_read_data => mult_1_op_read_data(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0),
				mult_2_op_read_data => mult_2_op_read_data(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- MULTIPLIER write ADDRESS PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				mult_write_addr     => mult_regf_write_addr(NUM_OF_MUL_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- MULTIPLIER WRITE DATA PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				mult_write_data     => mult_regf_write_data(NUM_OF_MUL_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- MULTIPLIER WRITE ENABLE PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				mult_write_en       => mult_regf_wes(NUM_OF_MUL_FU - 1 downto 0)
			);

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_MULT;
	----------------------------------------------
	----------------------------------------------


	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- DIVIDERS CONTROL COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	----------------------------------------------
	----------------------------------------------
	COND_DIV : IF NUM_OF_DIV_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		div_instr_decode : div_control
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME       => INSTANCE_NAME & "/div_instr_decode",
				-- cadence translate_on	
				INSTR_WIDTH         => INSTR_WIDTH,
				NUM_OF_DIV_FU       => NUM_OF_DIV_FU,
				DATA_WIDTH          => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH => REG_FILE_ADDR_WIDTH,

				-- shravan : 20120326 : changing REG_FIELD_WIDTH to the REG_FILE_ADDR_WIDTH
				--REG_FIELD_WIDTH	  => CUR_DEFAULT_REG_FIELD_WIDTH,

				REG_FIELD_WIDTH     => REG_FILE_ADDR_WIDTH,
				OPCODE_FIELD_WIDTH  => CUR_DEFAULT_OPCODE_FIELD_WIDTH
			)
			port map(
				clk                => REVERSED_gated_clock, --clk,
				rst                => configuring_reset,

				------------------------
				-- INSTRUCTIONS FOR THE MULTIPLIER UNITS -- 
				------------------------		

				instr_vector       => div_instructions_vector(NUM_OF_DIV_FU * INSTR_WIDTH - 1 downto 0),

				------------------------
				-- DIVIDER READ ADDRESS PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				div_1_op_read_addr => div_1_op_read_addr(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),
				div_2_op_read_addr => div_2_op_read_addr(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				------------------------
				-- DIVIDER READ DATA PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				div_1_op_read_data => div_1_op_read_data(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0),
				div_2_op_read_data => div_2_op_read_data(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DIVIDER write ADDRESS PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				div_write_addr     => div_regf_write_addr(NUM_OF_DIV_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DIVIDER WRITE DATA PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				div_write_data     => div_regf_write_data(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DIVIDER WRITE ENABLE PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				div_write_en       => div_regf_wes(NUM_OF_DIV_FU - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DIVIDERS REMAINDER VALUES -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				div_remainders     => div_remainders(NUM_OF_DIV_FU * DATA_WIDTH - 1 downto 0)
			);

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_DIV;
	----------------------------------------------
	----------------------------------------------

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- LOGICS CONTROL COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--


	----------------------------------------------
	----------------------------------------------
	COND_LOGIC : IF NUM_OF_LOGIC_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
		-- LOGIC FUs CONTROL COMPONENT INSTANTIATION --
		--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

		logic_instr_decode : logic_control
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME       => INSTANCE_NAME & "/logic_instr_decode",
				-- cadence translate_on	
				INSTR_WIDTH         => INSTR_WIDTH,
				NUM_OF_LOGIC_FU     => NUM_OF_LOGIC_FU,
				DATA_WIDTH          => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH => REG_FILE_ADDR_WIDTH,
				-- shravan : 20120326 : changing REG_FIELD_WIDTH to the REG_FILE_ADDR_WIDTH
				--			REG_FIELD_WIDTH	  => CUR_DEFAULT_REG_FIELD_WIDTH,

				REG_FIELD_WIDTH     => REG_FILE_ADDR_WIDTH,
				OPCODE_FIELD_WIDTH  => CUR_DEFAULT_OPCODE_FIELD_WIDTH
			)
			port map(
				flags_vector         => logic_flags_vector,
				------------------------
				-- INSTRUCTIONS FOR THE LOGIC UNITS -- 
				------------------------		

				instr_vector         => logic_instructions_vector(NUM_OF_LOGIC_FU * INSTR_WIDTH - 1 downto 0),

				------------------------
				-- LOGIC FUs READ ADDRESS PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				logic_1_op_read_addr => logic_1_op_read_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),
				logic_2_op_read_addr => logic_2_op_read_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				------------------------
				-- LOGIC FUs READ DATA PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				logic_1_op_read_data => logic_1_op_read_data(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0),
				logic_2_op_read_data => logic_2_op_read_data(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- LOGIC FUs write ADDRESS PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				logic_write_addr     => logic_regf_write_addr(NUM_OF_LOGIC_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- LOGIC FUs WRITE DATA PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				logic_write_data     => logic_regf_write_data(NUM_OF_LOGIC_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- LOGIC FUs WRITE ENABLE PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				logic_write_en       => logic_regf_wes(NUM_OF_LOGIC_FU - 1 downto 0)
			);

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_LOGIC;
	----------------------------------------------
	----------------------------------------------

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- SHIFT CONTROL COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	----------------------------------------------
	----------------------------------------------
	COND_SHIFT : IF NUM_OF_SHIFT_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
		-- SHIFT FUs CONTROL COMPONENT INSTANTIATION --
		--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

		shift_instr_decode : shift_control
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME       => INSTANCE_NAME & "/shift_instr_decode",
				-- cadence translate_on	
				INSTR_WIDTH         => INSTR_WIDTH,
				NUM_OF_SHIFT_FU     => NUM_OF_SHIFT_FU,
				DATA_WIDTH          => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH => REG_FILE_ADDR_WIDTH,

				-- shravan : 20120326 : changing REG_FIELD_WIDTH to the REG_FILE_ADDR_WIDTH
				--REG_FIELD_WIDTH	  => CUR_DEFAULT_REG_FIELD_WIDTH,

				REG_FIELD_WIDTH     => REG_FILE_ADDR_WIDTH,
				OPCODE_FIELD_WIDTH  => CUR_DEFAULT_OPCODE_FIELD_WIDTH
			)
			port map(
				flags_vector         => shift_flags_vector,
				------------------------
				-- INSTRUCTIONS FOR THE SHIFT UNITS -- 
				------------------------		

				instr_vector         => shift_instructions_vector(NUM_OF_SHIFT_FU * INSTR_WIDTH - 1 downto 0),

				------------------------
				-- SHIFT FUs READ ADDRESS PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				shift_1_op_read_addr => shift_1_op_read_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),
				shift_2_op_read_addr => shift_2_op_read_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				------------------------
				-- SHIFT FUs READ DATA PORTS FOR REGISTER FILE -- 
				------------------------

				-- For register addressation 2 read ports for every FU is needed

				shift_1_op_read_data => shift_1_op_read_data(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0),
				shift_2_op_read_data => shift_2_op_read_data(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- SHIFT FUs write ADDRESS PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				shift_write_addr     => shift_regf_write_addr(NUM_OF_SHIFT_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- SHIFT FUs WRITE DATA PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				shift_write_data     => shift_regf_write_data(NUM_OF_SHIFT_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- SHIFT FUs WRITE ENABLE PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				shift_write_en       => shift_regf_wes(NUM_OF_SHIFT_FU - 1 downto 0)
			);

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_SHIFT;
	----------------------------------------------
	----------------------------------------------

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- DPU CONTROL COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	----------------------------------------------
	----------------------------------------------
	COND_DPU : IF NUM_OF_DPU_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		dpu_instr_decode : dpu_control
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME       => INSTANCE_NAME & "/dpu_instr_decode",
				-- cadence translate_on	

				--###################################
				--### SRECO: REGISTER FILE OFFSET ###
				RF_OFFSET           => RF_OFFSET,
				--###################################

				INSTR_WIDTH         => INSTR_WIDTH,
				NUM_OF_DPU_FU       => NUM_OF_DPU_FU,
				DATA_WIDTH          => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH => REG_FILE_ADDR_WIDTH,

				-- shravan : 20120326 : changing REG_FIELD_WIDTH to the REG_FILE_ADDR_WIDTH
				--REG_FIELD_WIDTH	  => CUR_DEFAULT_REG_FIELD_WIDTH,

				REG_FIELD_WIDTH     => REG_FILE_ADDR_WIDTH,
				OPCODE_FIELD_WIDTH  => CUR_DEFAULT_OPCODE_FIELD_WIDTH
			)
			port map(

				------------------------
				-- INSTRUCTIONS FOR THE DPU UNITS -- 
				------------------------		

				instr_vector    => dpu_instructions_vector(NUM_OF_DPU_FU * INSTR_WIDTH - 1 downto 0),

				------------------------
				-- DPU READ ADDRESS PORTS FOR REGISTER FILE -- 
				------------------------

				dpu_source_addr => dpu_1_op_read_addr(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				------------------------
				-- DPU READ DATA PORTS FOR REGISTER FILE -- 
				------------------------

				dpu_source_data => dpu_1_op_read_data(NUM_OF_DPU_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DPU write ADDRESS PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	

				dpu_write_addr  => dpu_regf_write_addr(NUM_OF_DPU_FU * REG_FILE_ADDR_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DPU WRITE DATA PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				dpu_write_data  => dpu_regf_write_data(NUM_OF_DPU_FU * DATA_WIDTH - 1 downto 0),

				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				-- DPU WRITE ENABLE PORTS FOR REGISTER FILE -- 
				--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

				dpu_write_en    => dpu_regf_wes(NUM_OF_DPU_FU - 1 downto 0)
			);

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_DPU;
	----------------------------------------------
	----------------------------------------------

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- CPU CONTROL COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	----------------------------------------------
	----------------------------------------------
	COND_CPU : IF NUM_OF_CPU_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		cpu_instr_decode : cpu_control
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME           => INSTANCE_NAME & "/cpu_instr_decode",
				-- cadence translate_on	
				INSTR_WIDTH             => INSTR_WIDTH,
				NUM_OF_CPU_FU           => NUM_OF_CPU_FU,
				CTRL_REG_WIDTH          => CTRL_REG_WIDTH,
				CTRL_REGFILE_ADDR_WIDTH => CTRL_REGFILE_ADDR_WIDTH,

				-- shravan : 20120326 : changing CTRL_REG_FIELD_WIDTH to the CTRL_REG_FILE_ADDR_WIDTH
				--	CTRL_REG_FIELD_WIDTH		=>		CUR_DEFAULT_REG_FIELD_WIDTH,

				CTRL_REG_FIELD_WIDTH    => CTRL_REGFILE_ADDR_WIDTH,
				OPCODE_FIELD_WIDTH      => CUR_DEFAULT_OPCODE_FIELD_WIDTH
			)
			port map(
				instr_vector    => cpu_instructions_vector(NUM_OF_CPU_FU * INSTR_WIDTH - 1 downto 0),
				cpu_source_addr => cpu_1_op_read_addr(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH - 1 downto 0),
				cpu_source_data => cpu_1_op_read_data(NUM_OF_CPU_FU * CTRL_REG_WIDTH - 1 downto 0),
				cpu_write_addr  => cpu_ctrl_regf_write_addr(NUM_OF_CPU_FU * CTRL_REGFILE_ADDR_WIDTH - 1 downto 0),
				cpu_write_data  => cpu_ctrl_regf_write_data(NUM_OF_CPU_FU * CTRL_REG_WIDTH - 1 downto 0),
				cpu_write_en    => cpu_ctrl_regf_wes(NUM_OF_CPU_FU - 1 downto 0)
			);

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_CPU;
	----------------------------------------------
	----------------------------------------------

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- CONTROL REGISTER FILE COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	----------------------------------------------
	----------------------------------------------
	COND_CTRL_REGFILE : IF TOTAL_CTRL_REGS_NUM > 0 AND NUM_OF_CPU_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		control_register_file : component control_regfile
			generic map(
				-- cadence translate_off			
				INSTANCE_NAME => INSTANCE_NAME & "/control_register_file",
				-- cadence translate_on	
				--
				--					NUM_OF_CTRL_READ_PORTS  => NUM_OF_CPU_FU,
				--					NUM_OF_CTRL_WRITE_PORTS => NUM_OF_CPU_FU,
				--					CTRL_REG_NUM	 			=> NUM_OF_CONTROL_REGS,
				--
				--					NUM_OF_CTRL_OUTPUTS 		=> NUM_OF_CONTROL_OUTPUTS,
				--			   	NUM_OF_CTRL_INPUTS	   => NUM_OF_CONTROL_INPUTS,
				--
				--					BEGIN_CTRL_OUTPUTS		=> NUM_OF_CONTROL_REGS,
				--					END_CTRL_OUTPUTS        => NUM_OF_CONTROL_REGS + NUM_OF_CONTROL_OUTPUTS -1,
				--					CTRL_REG_WIDTH			   => CTRL_REG_WIDTH,
				--					CTRL_REGFILE_ADDR_WIDTH	=> CTRL_REGFILE_ADDR_WIDTH

				generics      => (NUM_OF_CPU_FU,
					NUM_OF_CPU_FU,
					NUM_OF_CONTROL_REGS,
					NUM_OF_CONTROL_OUTPUTS,
					NUM_OF_CONTROL_INPUTS,
					NUM_OF_CONTROL_REGS,
					(NUM_OF_CONTROL_REGS + NUM_OF_CONTROL_OUTPUTS - 1),
					CTRL_REG_WIDTH,
					CTRL_REGFILE_ADDR_WIDTH
				)
			)
			port map(
				ctrl_read_addresses_vector    => ctrl_regf_read_addr(CTRL_REGFILE_ADDR_WIDTH * NUM_OF_CPU_FU - 1 downto 0),
				ctrl_read_data_vector         => ctrl_regf_read_data(CTRL_REG_WIDTH * NUM_OF_CPU_FU - 1 downto 0),
				ctrl_write_addresses_vector   => ctrl_regf_write_addr(CTRL_REGFILE_ADDR_WIDTH * NUM_OF_CPU_FU - 1 downto 0),
				ctrl_write_data_vector        => ctrl_regf_write_data(CTRL_REG_WIDTH * NUM_OF_CPU_FU - 1 downto 0),
				ctrl_wes                      => ctrl_regf_write_enables(NUM_OF_CPU_FU - 1 downto 0),
				ctrl_input_registers          => ctrl_inputs,
				ctrl_output_registers         => sig_ctrl_outputs, --ctrl_outputs,
				branch_mux_ctrl_registers_out => branch_mux_ctrl_registers_out,
				ctrl_programmable_input_depth => sig_ctrl_programmable_input_depth,
				clk                           => clk, --REVERSED_gated_clock, --clk,
				rst                           => configuring_reset
			);
			ctrl_outputs <= sig_ctrl_outputs;
			--Ericles on March 15, 2017: While the Error Handling Unit (EHU, also called hw voter) is not integrated, we only perform software-based voting operation on TCPAs.
			--Thus, TCPAs need at least 2 output ICs and 2 Ctrl Processing Units. On the one hand, the first IC(s) will be connected to Global Controller.
			--On the other hand, the last IC is always used to signal an error. For instance, when no majority can be determined, 
			--the software voter signals an error by setting IC(last_index) = 1. Otherwise, IC(last_index) = 0.
			error_flag <= sig_ctrl_outputs(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS * WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1);
			--Error diagnosis will be controlled by EHUs
			error_diagnosis <= (others=>'0');

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_CTRL_REGFILE;
	----------------------------------------------
	----------------------------------------------
	--Ericles
	--	ctrl_outputs <= (others =>'0') when configuring_reset = '1' else		ctrl_outputs_tmp;


	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- GENERIC MULTIPLEXER FOR MEMORY ADDR_INPUT --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	--pc_multiplexer	:mux_2_1
	--
	--	generic map(
	--
	--			DATA_WIDTH	=> ADDR_WIDTH
	--	)
	--
	--	port map(
	--
	--			data_inputs	 => pc_multiplexer_ins,			
	--			sel	 	    => registered_mem_config_done,
	--			output		 => memory_addr
	--
	--	);
	--
	--

	--#################################
	--######## SRECO MULTIPLEXERS: ####

	--##################################
	-- MULTIPLEXER FOR SRECO ADDRESS --
	--##################################
	sreco_mux_addr : mux_2_1
		generic map(
			-- cadence translate_off	
			INSTANCE_NAME => INSTANCE_NAME & "/SRECO_MUX_ADDR",
			-- cadence translate_on	
			DATA_WIDTH    => 3
		)
		port map(
			data_inputs => config_reg_addr_vector,
			sel         => sreco_select, --configuring_reset,
			output      => config_reg_addr_mux_out --config_reg_addr

		);

	--##################################
	-- MULTIPLEXER FOR SRECO DATA --
	--##################################

	sreco_mux_data : mux_2_1
		generic map(
			-- cadence translate_off	
			INSTANCE_NAME => INSTANCE_NAME & "/SRECO_MUX_DATA",
			-- cadence translate_on	
			DATA_WIDTH    => CUR_DEFAULT_CONFIG_REG_WIDTH
		)
		port map(
			data_inputs => config_reg_data_vector,
			sel         => sreco_select, --configuring_reset,
			output      => config_reg_data_mux_out --config_reg_data--

		);

	--##################################
	-- MULTIPLEXER FOR SRECO WE --
	--##################################
	sreco_mux_we : mux_2_1_1bit
		-- cadence translate_off
		generic map(
			INSTANCE_NAME => INSTANCE_NAME & "/SRECO_MUX_WE"
		)
		-- cadence translate_on		
		port map(
			input0 => config_reg_we_vector(0),
			input1 => config_reg_we_vector(1),
			sel    => sreco_select,     --configuring_reset,
			output => config_reg_we_mux_out --config_reg_we--
		);

	--######## SRECO MULTIPLEXERS END ####
	--####################################


	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- REGISTER FILE COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	----------------------------------------------
	----------------------------------------------
	COND_REG_FILE : IF SUM_OF_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		register_file : reg_file
			generic map(
				-- cadence translate_off				
				INSTANCE_NAME             => INSTANCE_NAME & "/register_file",
				-- cadence translate_on	
				NUM_OF_READ_PORTS         => (2 * SUM_OF_FU - NUM_OF_DPU_FU),
				-- For DPU FU only one operand read addr/data needed !!!
				NUM_OF_WRITE_PORTS        => SUM_OF_FU,
				GEN_PUR_REG_NUM           => GEN_PUR_REG_NUM,
				NUM_OF_INPUT_REG          => NUM_OF_INPUT_REG,
				NUM_OF_OUTPUT_REG         => NUM_OF_OUTPUT_REG,
				BEGIN_OUTPUT_REGS         => GEN_PUR_REG_NUM,
				END_OUTPUT_REGS           => GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG - 1,
				NUM_OF_FEEDBACK_FIFOS     => NUM_OF_FEEDBACK_FIFOS,
				-- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM

				TYPE_OF_FEEDBACK_FIFO_RAM => TYPE_OF_FEEDBACK_FIFO_RAM,
				SIZES_OF_FEEDBACK_FIFOS   => SIZES_OF_FEEDBACK_FIFOS,
				FB_FIFOS_ADDR_WIDTH       => FB_FIFOS_ADDR_WIDTH,

				-- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM

				TYPE_OF_INPUT_FIFO_RAM    => TYPE_OF_INPUT_FIFO_RAM,
				SIZES_OF_INPUT_FIFOS      => SIZES_OF_INPUT_FIFOS,
				INPUT_FIFOS_ADDR_WIDTH    => INPUT_FIFOS_ADDR_WIDTH,
				GEN_PUR_REG_WIDTH         => GEN_PUR_REG_WIDTH,
				DATA_WIDTH                => DATA_WIDTH,
				REG_FILE_ADDR_WIDTH       => REG_FILE_ADDR_WIDTH
			)
			port map(
				config_reg_data          => config_reg_data_regfile, --config_reg_data_vector(CUR_DEFAULT_CONFIG_REG_WIDTH-1 downto 0),
				config_reg_addr          => config_reg_addr_regfile, --config_reg_addr_vector(2 downto 0),
				config_reg_we            => config_reg_we_regfile, --config_reg_we_vector(0),

				read_addresses_vector    => regf_read_addr(REG_FILE_ADDR_WIDTH * (2 * SUM_OF_FU - NUM_OF_DPU_FU) - 1 downto 0),
				-- For DPU FU only one operand read addr/data needed !!!

				read_data_vector         => regf_read_data(DATA_WIDTH * (2 * SUM_OF_FU - NUM_OF_DPU_FU) - 1 downto 0),
				write_addresses_vector   => regf_write_addr(REG_FILE_ADDR_WIDTH * SUM_OF_FU - 1 downto 0),
				write_data_vector        => regf_write_data(DATA_WIDTH * SUM_OF_FU - 1 downto 0),
				wes                      => regf_write_enables(SUM_OF_FU - 1 downto 0),
				input_registers          => input_registers,
				output_registers         => output_registers,
				input_fifos_write_en     => input_fifos_write_en,
				en_programmable_fd_depth => sig_en_programmable_fd_depth,
				programmable_fd_depth    => sig_programmable_fd_depth,
				rst_fd_regs              => test_rst,
				rst                      => test_rst, --configuring_reset,
				clk                      => REVERSED_gated_clock --clk

			);

	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_REG_FILE;
	----------------------------------------------
	----------------------------------------------	

	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- MEMORY LOADER COMPONENT INSTATIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--


	mem_loader : generic_loader
		generic map(

			-- cadence translate_off	
			INSTANCE_NAME               => INSTANCE_NAME & "/mem_loader",
			-- cadence translate_on	
			SOURCE_ADDR_WIDTH           => SOURCE_ADDR_WIDTH,
			DESTIN_ADDR_WIDTH           => ADDR_WIDTH,
			SOURCE_DATA_WIDTH           => SOURCE_DATA_WIDTH,
			DESTIN_SOURCE_RATIO_CEILING => CUR_DEFAULT_DESTIN_SOURCE_RATIO, --4,
			DESTIN_DATA_WIDTH           => BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH,
			DUAL_DATA_WIDTH             => CUR_DEFAULT_CONFIG_REG_WIDTH, --Ericles: This value has to be equal to ICN_REGISTER_WIDTH from TCPA Editor, --CUR_DEFAULT_CONFIG_REG_WIDTH,
			INIT_SOURCE_ADDR            => CUR_DEFAULT_CONFIG_START_ADDR,
			END_DESTIN_ADDR             => MEM_SIZE - 1 -- -1 !!!

		)
		port map(
			clk             => loader_gated_clock, --clk,
			rst             => rst,

			-- If set_to_config = '1', then this WPPE must be (RE-)configured

			set_to_config   => set_to_config,
			enable_tcpa	=> enable_tcpa,
			-- Signal showing the current state of configuring the memory and registers
			-- gives the reset signal for the WPPE-logic
			config_rst      => LOADER_configuring_reset, --configuring_reset,
			vliw_config_en   => vliw_config_en,
			icn_config_en   => icn_config_en,
		 	mem_config_done => mem_config_done,
			common_config_reset => common_config_reset,
			source_data_in  => config_mem_data,
			idle            => loader_idle,

			--dual_destin_out => internal_config_reg_data,
			--dual_we   => internal_config_reg_we,
			dual_destin_out => config_reg_data_memloader, --config_reg_data_vector(CUR_DEFAULT_CONFIG_REG_WIDTH*2-1 downto CUR_DEFAULT_CONFIG_REG_WIDTH),
			dual_we         => config_reg_we_memloader, --config_reg_we_vector(1),

			destin_we       => mem_we,
			destin_addr_out => mem_addr_in,
			destin_data_out => mem_data_in(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH - 1 downto 0)
		);

	--Ericles Sousa on 08 Jan 2015
	--New conponent to control the start time of the PEs
	start_mngr : start_manager
		generic map(
			--Ericles:
			N             => N,
			M             => M,
			INSTANCE_NAME => INSTANCE_NAME & "/Start_manager"
		)
		port map(
			clk        => clk,
			rst        => rst,
			en         => mem_config_done,
			count_down => sig_count_down,
			start      => en_instruction_memory
		);

	--
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
	-- BLOCK RAM MEMORY COMPONENT INSTANTIATION --
	--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

	----------------------------------------------
	----------------------------------------------
	COND_RAM : IF SUM_OF_FU > 0 GENERATE
		----------------------------------------------
		----------------------------------------------

		----------------------------------------------
		----------------------------------------------
		-- Instantiation of instr_memory for Xilinx
		----------------------------------------------
		----------------------------------------------


		-- pragma translate_on
		-- cadence translate_off
		--Ericles. defautl instr_mem instance fixed
		--			block_ram :instr_memory_new
		--			generic map (
		--						--Ericles:
		--						N => N,
		--						M => M,
		--						INSTANCE_NAME     => INSTANCE_NAME & "/block_ram",
		--						MEM_SIZE   	=> MEM_SIZE,
		--						DATA_WIDTH	=> BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH 
		--													+ SUM_OF_FU*INSTR_WIDTH,
		--						ADDR_WIDTH	=> ADDR_WIDTH
		--				)
		--	
		--				port map(
		--					clk  => MEMORY_gated_clock, --clk,
		--					we   => mem_we,
		--					addr => memory_addr,
		--					di   => mem_data_in(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH + SUM_OF_FU*INSTR_WIDTH -1 downto 0),
		--					ic	  => ctrl_inputs,
		--					oc   => ctrl_outputs,	--Ericles
		--					d_out   => mem_data_out(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH + SUM_OF_FU*INSTR_WIDTH -1 downto 0)	-- SUM_OF_FU + BRANCH_INSTR.
		--					);

		--Ericles. Uncomment only if a customized configuration is desired
		--	LOADING_PE_BYPASS_10_TO_13 : IF (M >= 1  and N = 2) GENERATE
		--		block_ram :instr_memory_for_bypass
		--		generic map (
		--					--Ericles:
		--					N => N,
		--					M => M,
		--					INSTANCE_NAME     => INSTANCE_NAME & "/block_ram",
		--					MEM_SIZE   	=> MEM_SIZE,
		--					DATA_WIDTH	=> BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH 
		--												+ SUM_OF_FU*INSTR_WIDTH,
		--					ADDR_WIDTH	=> ADDR_WIDTH
		--			)
		--
		--			port map(
		--				clk  => MEMORY_gated_clock, --clk,
		--				we   => mem_we,
		--				addr => memory_addr,
		--				di   => mem_data_in(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH + SUM_OF_FU*INSTR_WIDTH -1 downto 0),
		--				ic	  => ctrl_inputs,
		--				oc   => ctrl_outputs,	--Ericles			
		--				d_out   => mem_data_out(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH + SUM_OF_FU*INSTR_WIDTH -1 downto 0)	-- SUM_OF_FU + BRANCH_INSTR.
		--				);	
		--	END GENERATE LOADING_PE_BYPASS_10_TO_13;
		--	

		--Ericles. Uncomment for default applications using the old memory version
		block_ram : instr_memory
			generic map(
				--Ericles:
				N             => N,
				M             => M,
				INSTANCE_NAME => INSTANCE_NAME & "/block_ram",
				MEM_SIZE      => MEM_SIZE,
				DATA_WIDTH    => BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH,
				ADDR_WIDTH    => ADDR_WIDTH
			)
			port map(
				clk   => MEMORY_gated_clock, --clk,
				we    => mem_we,
				addr  => memory_addr,
				di    => mem_data_in(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH - 1 downto 0),
				d_out => mem_data_out(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU * INSTR_WIDTH + SUM_OF_FU * INSTR_WIDTH - 1 downto 0) -- SUM_OF_FU + BRANCH_INSTR.

			);

	-- cadence translate_on

	------------------------------------------------
	------------------------------------------------
	---- Instantiation of ram_wrapper for Cadence/Synopsys
	------------------------------------------------
	------------------------------------------------
	--
	--
	---- pragma translate_off
	---- cadence translate_off
	--MODELSIM_OFF :if not MODELSIM GENERATE
	---- cadence translate_on
	--			block_ram :ram_wrapper
	--
	--			generic map (
	--						DATA_WIDTH	=> BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH 
	--													+ SUM_OF_FU*INSTR_WIDTH,
	--						ADDR_WIDTH	=> ADDR_WIDTH
	--				)
	--	
	--				port map(
	--		
	--					clk  => MEMORY_gated_clock, --clk,
	--					we   => mem_we,
	--					rst  => rst,
	--					addr => memory_addr,
	--					di   => mem_data_in(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH + 
	--																		SUM_OF_FU*INSTR_WIDTH -1 downto 0),
	--					d_out   => mem_data_out(BRANCH_INSTR_WIDTH + NUM_OF_CPU_FU*INSTR_WIDTH 
	--													+ SUM_OF_FU*INSTR_WIDTH -1 downto 0)	-- SUM_OF_FU + BRANCH_INSTR.
	--
	--					);
	---- cadence translate_off
	--end generate MODELSIM_OFF;					
	---- pragma translate_on	
	---- cadence translate_on				
	----------------------------------------------
	----------------------------------------------
	END GENERATE COND_RAM;
	----------------------------------------------
	----------------------------------------------

	delayed_configuring_reset : process(clk, second_wait_cycle, rst)
	begin
		if rst = '1' then
			configuring_reset <= '1';

		elsif clk'event and clk = '1' then
			--configuring_reset <= '0'; 
			if second_wait_cycle = '1' then
				configuring_reset <= LOADER_configuring_reset; 

			end if;

		end if;
	end process delayed_configuring_reset;

	instructions_vector <= mem_data_out;

	set_instr_vector : process(clk, configuring_reset)
	begin
		if clk'event and clk = '1' then
--			instructions_vector <= mem_data_out;
--			branch_instruction_reg	<= branch_instruction;

			if configuring_reset = '1' then
				--	   instructions_vector <= (others => '1');
				third_wait_cycle <= '0';

			elsif third_wait_cycle = '1' then

			else
				third_wait_cycle <= '1';

			end if;

		end if;

	end process set_instr_vector;

	set_wait_cycles : process(clk, LOADER_configuring_reset)
	begin
		if clk'event and clk = '1' then
			if LOADER_configuring_reset = '1' then
				wait_cycle <= '1';

				if wait_cycle = '1' then
					second_wait_cycle <= '0';

				end if;

			-- To prevent the FUs from switching spouriously !!!

			-- instructions_vector <= (others => '1');

			else
				if wait_cycle = '0' then
					if second_wait_cycle = '1' then

					--	instructions_vector      <= mem_data_out;

					else
						second_wait_cycle <= '1';

					end if;

				else
					wait_cycle <= '0';

				end if;

			end if;

		end if;

	end process;

	register_mem_loader_destination_addr : process(clk, third_wait_cycle, mem_data_out, branch_instruction, configuring_reset, mem_config_done, pc, mem_addr_in) --, clk)

	begin
		if (mem_config_done = '1') then
			if LOADER_configuring_reset = '1' then
				memory_addr <= conv_std_logic_vector(0, ADDR_WIDTH); --(others => '1'); --

				branch_instruction <= (others => '1');

				--internal_config_reg_addr <= mem_addr_in(2 downto 0);
				--config_reg_addr_vector(5 downto 3) <= mem_addr_in(2 downto 0);
				config_reg_addr_memloader <= mem_addr_in(2 downto 0);

			else
				memory_addr <= pc;

				branch_instruction <= mem_data_out(BRANCH_INSTR_WIDTH + (NUM_OF_CPU_FU + NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU + NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH - 1 downto (NUM_OF_CPU_FU + NUM_OF_DPU_FU + NUM_OF_SHIFT_FU + NUM_OF_LOGIC_FU + NUM_OF_DIV_FU +
							                       NUM_OF_MUL_FU + NUM_OF_ADD_FU) * INSTR_WIDTH
					);

				--internal_config_reg_addr <= (others => '0');
				config_reg_addr_memloader <= (others => '0');
			end if;

		else
			memory_addr <= mem_addr_in;

			--internal_config_reg_addr <= (others => '0');
			--config_reg_addr_vector(5 downto 3) <= (others => '0');
			config_reg_addr_memloader <= mem_addr_in(2 downto 0); --(others => '0');

			branch_instruction <= (others => '1');

		end if;
		sig_configuration_done <= mem_config_done;
	end process;

	sreco_switching : process(clk)
	begin
		if clk'event and clk = '1' then
			if LOADER_configuring_reset = '1' then
				sreco_select <= '1';
			else
				sreco_select <= '0';
			end if;
		end if;
	end process;

	set_config_rst_register : process(clk, rst, LOADER_configuring_reset, loader_idle, set_to_config)
	begin
		if rst = '1' then
			clk_gate_enable        <= '1';
			loader_clk_gate_enable <= '1';

		elsif clk'event and clk = '1' then
			loader_clk_gate_enable <= (NOT loader_idle) OR set_to_config;

			if LOADER_configuring_reset = '1' then
				clk_gate_enable <= '1';

			elsif LOADER_configuring_reset = '0' then
				clk_gate_enable <= '0';

			else
				clk_gate_enable <= '1';

			end if;

		end if;

	--end if;

	end process;

	sync_process : process(clk) 
	begin
		if clk'event and clk = '1' then
			configuration_done      	 <= sig_configuration_done;
			sig_ctrl_programmable_input_depth<= ctrl_programmable_input_depth;
			sig_en_programmable_fd_depth  	<= en_programmable_fd_depth;
			sig_programmable_fd_depth	<= programmable_fd_depth;
			sig_count_down           	<= count_down;
			
			mask_r   <= mask;
			fu_sel_r <= fu_sel;
			pe_sel_r <= pe_sel;
		end if;	
	end process;

     clk <= clk_in;
     --BUFG_0 : BUFG port map(I=> clk_in, O => clk);
--   BUFR_inst : BUFR
--   generic map (BUFR_DIVIDE => "1",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
--                SIM_DEVICE =>  "7SERIES"  -- Must be set to "7SERIES" 
--	)
--   port map (
--      O => clk,     -- 1-bit output: Clock output port
--      CE => '1',   -- 1-bit input: Active high, clock enable (Divided modes only)
--      CLR => rst, -- 1-bit input: Active high, asynchronous clear (Divided modes only)
--      I => clk_in      -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
--   );



end Behavioral;
