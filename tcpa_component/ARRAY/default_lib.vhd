--	Package File Template
 --
 --	Purpose: This package defines supplemental types, subtypes, 
 --		 constants, and functions


 library IEEE;
 use IEEE.STD_LOGIC_1164.all;
 library wppa_instance_v1_01_a;
 use wppa_instance_v1_01_a.ALL;
 use wppa_instance_v1_01_a.WPPE_LIB.ALL;

 package DEFAULT_LIB is

 CONSTANT  OUTPUT_REGISTERED :boolean := false;
 CONSTANT  FPGA_SYN    :boolean := true;
 CONSTANT  MODELSIM   :boolean := true;
 CONSTANT  CONFIG_PPC :boolean := false;
 CONSTANT  FAULT_INJECTION_MODULE_EN : boolean := true;

 --==: CLOCK GATING Flag, set TRUE if CLOCK GATING desired
 CONSTANT  CLOCK_GATING :boolean := false;

 -- "REVERSED" (in relation to the (re)configuration phase) CLOCK GATING Flag
             -- if set true, all functional registers of the WPPE are separted from
             -- clk during the (re)configuration phase
 CONSTANT  REVERSED_CLOCK_GATING :boolean := false;
 --==: CLOCK GATING Flag, set TRUE if MEMORY CLOCK GATING desired
 CONSTANT  MEMORY_CLOCK_GATING :boolean := false;


 --***************************************************************
 --########################
 --### SRECO PARAMETER: ###
 CONSTANT  CUR_DEFAULT_REG_FILE_OFFSET : positive := 16;
 CONSTANT  CUR_DEFAULT_MAX_REG_FILE_OFFSET : positive := 32;

 --***************************************************************

 --===============================================================================--


 --***************************************************************
 --  BEGIN CONFIGURATION MANAGER PARAMETER
 --***************************************************************
 CONSTANT	CUR_DEFAULT_DOMAIN_TYPE_WIDTH :positive   := 2;
 CONSTANT	CUR_DEFAULT_DOMAIN_HEADER_RATIO :positive := 3;
 CONSTANT	CUR_DEFAULT_COUNT_DOWN_WIDTH :positive    := 1;
 CONSTANT	CUR_DEFAULT_ICN_RATIO_WIDTH :positive     := 3;
 CONSTANT	CUR_DEFAULT_VLIW_RATIO_WIDTH :positive    := 4;
 CONSTANT	CUR_DEFAULT_MAX_DOMAIN_NUM :positive      := 128;
 CONSTANT	CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH :positive := 7;
 CONSTANT	CUR_DEFAULT_CONFIG_TYPE_WIDTH :positive        := 2;
 CONSTANT	CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH :positive  := 2;
 CONSTANT	CUR_DEFAULT_SOURCE_MUX_NUM_OF_INPUTS :positive := 3;
 --***************************************************************
 -- END CONFIGURATION MANAGER PARAMETER
 --***************************************************************

 --===============================================================================--
 --===============================================================================--
 -- DEFAULT GLOBAL CONTROLLER
 -- CONFIGURATION REGISTER VALUES

 -- RATIO BETWEEN THE WIDTH OF THE VLIW MEMORY
 -- OF THE WPPE (e.g. 128 bit),
 -- and the width of the GLOBAL CONFIGURATION
 -- MEMORY (e.g. 32 bit)

 CONSTANT	CUR_DEFAULT_DESTIN_SOURCE_RATIO :positive := 9;
 
 -- RATIO BETWEEN THE WIDTH OF the
 -- GLOBAL CONFIGURATION MEMORY (e.g. 32 bit)
 -- and the width of the
 -- interconnect configuration registers
 -- in the ICN_WRAPPER component	(e.g. 8 bit)

  CONSTANT	CUR_DEFAULT_SOURCE_DUAL_RATIO	 :positive := 4;

 -- DEFAULT START ADDRESS OF THE CONFIGURATION
 -- TO BE LOADED TO SOME WPPE
 -- IN THE GLOBAL CONFIGURATION MEMORY
 -- (e.g. start_addr = 0)

 CONSTANT	CUR_DEFAULT_CONFIG_START_ADDR :integer := 0;

 -- DEFAULT END ADDRESS OF THE
 -- INSTRUCTION VLIW MEMORY CONFIGURATION DATA
 -- TO BE LOADED TO SOME WPPE
 -- IN THE GLOBAL CONFIGURATION MEMORY
 -- (e.g. start_addr = 0)

 CONSTANT	CUR_DEFAULT_VLIW_DATA_END_ADDR :positive := 32;

 -- DEFAULT END ADDRESS OF THE
 -- REGISTER INTERCONNECT CONFIGURATION DATA
 -- TO BE LOADED TO SOME WPPE
 -- IN THE GLOBAL CONFIGURATION MEMORY
 -- (e.g. start_addr = 0)

 CONSTANT	CUR_DEFAULT_ICN_DATA_END_ADDR :positive := 32;

 -- DEFAULT END ADDRESS OF THE
 -- REGISTER PRELOAD CONFIGURATION DATA
 -- TO BE LOADED TO SOME WPPE
 -- IN THE GLOBAL CONFIGURATION MEMORY
 -- (e.g. start_addr = 0)

 CONSTANT	CUR_DEFAULT_PRELOAD_DATA_END_ADDR :positive := 32;

 --===============================================================================--
 --===============================================================================--
 -- DEFAULT INTERCONNECT CONFIGURATION
 -- REGISTER WIDTH (FOR THE SELECT INPUTS OF ICN MULTIPLEXERS
 -- in the ICN_WRAPPER COMPONENT)

 CONSTANT CUR_DEFAULT_CONFIG_REG_WIDTH :integer range
 	MIN_CONFIG_REG_WIDTH to MAX_CONFIG_REG_WIDTH := 32;


 --===============================================================================--
 --===============================================================================--
 -- DEFAULT GLOBAL CONFIGURATION BUS ADDR WIDTH

 CONSTANT CUR_DEFAULT_BUS_ADDR_WIDTH :positive range
 	MIN_BUS_ADDR_WIDTH to MAX_BUS_ADDR_WIDTH := 32;

 -- DEFAULT GLOBAL CONFIGURATION BUS DATA WIDTH

 CONSTANT CUR_DEFAULT_BUS_DATA_WIDTH :positive range
 	MIN_BUS_DATA_WIDTH to MAX_BUS_DATA_WIDTH := 32;

 --===============================================================================--
 -- ###########
 CONSTANT CUR_DEFAULT_NUM_WPPE_VERTICAL :integer range
 	MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL := 4;
 -------------------------------------------------------------------------
 CONSTANT CUR_DEFAULT_RIGHT_EXTERNAL_NUM_WPPE_VERTICAL :integer range
 	MIN_NUM_WPPE_VERTICAL to CUR_DEFAULT_NUM_WPPE_VERTICAL := 4;
 -------------------------------------------------------------------------
 CONSTANT CUR_DEFAULT_LEFT_EXTERNAL_NUM_WPPE_VERTICAL :integer range
 	MIN_NUM_WPPE_VERTICAL to CUR_DEFAULT_NUM_WPPE_VERTICAL := 4;

 --===============================================================================--
 --===============================================================================--
 -- ###########
 CONSTANT CUR_DEFAULT_NUM_WPPE_HORIZONTAL :integer range
 	MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL := 4;
 -------------------------------------------------------------------------
 CONSTANT CUR_DEFAULT_TOP_EXTERNAL_NUM_WPPE_HORIZONTAL :integer range
 	MIN_NUM_WPPE_HORIZONTAL to CUR_DEFAULT_NUM_WPPE_HORIZONTAL := 4;
 -------------------------------------------------------------------------
 CONSTANT CUR_DEFAULT_BOTTOM_EXTERNAL_NUM_WPPE_HORIZONTAL :integer range
 	MIN_NUM_WPPE_HORIZONTAL to CUR_DEFAULT_NUM_WPPE_HORIZONTAL := 4;

 --===============================================================================--

 CONSTANT CUR_DEFAULT_SOURCE_ADDR_WIDTH :positive RANGE 1 to MAX_SOURCE_ADDR_WIDTH := 14;
 CONSTANT CUR_DEFAULT_SOURCE_DATA_WIDTH :positive RANGE 8 to MAX_SOURCE_DATA_WIDTH := 32;
 CONSTANT CUR_DEFAULT_SOURCE_MEM_SIZE   :positive RANGE 2 to MAX_SOURCE_MEM_SIZE := 16384;
 
 --===============================================================================--
 
 -- CURRENT DEFAULT NUMBER OF FEED-BACK FIFO --
 
 CONSTANT CUR_DEFAULT_NUM_FB_FIFO :integer RANGE 0 to MAX_NUM_FB_FIFO := 2;

 --===============================================================================--

 -- CURRENT DEFAULT FIFO SIZE --

 CONSTANT CUR_DEFAULT_FIFO_SIZE :POSITIVE RANGE MIN_FIFO_SIZE to MAX_FIFO_SIZE := 4;

 --===============================================================================--

 -- CURRENT DEFAULT FIFO ADDRESS WIDTH --

 CONSTANT CUR_DEFAULT_FIFO_ADDR_WIDTH
      :POSITIVE RANGE MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := 2;

 --===============================================================================--

 -- CURRENT DEFAULT INSTRUCTION_WIDTH --

 CONSTANT CUR_DEFAULT_INSTR_WIDTH :POSITIVE RANGE MIN_INSTR_WIDTH to MAX_INSTR_WIDTH := 16;

 --===============================================================================--

 -- CURRENT DEFAULT BRANCH INSTRUCTION_WIDTH --

 CONSTANT CUR_DEFAULT_BRANCH_INSTR_WIDTH
         :POSITIVE RANGE MIN_BRANCH_INSTR_WIDTH to MAX_BRANCH_INSTR_WIDTH := 49;
 
 --===============================================================================--
 --changed
 -- CURRENT DEFAULT BRANCH FLAGS NUMBER --

 CONSTANT CUR_DEFAULT_BRANCH_FLAGS_NUM :INTEGER := 2;

 --===============================================================================--

 -- CURRENT DEFAULT BRANCH TARGET WIDTH --

 CONSTANT CUR_DEFAULT_BRANCH_TARGET_WIDTH
           :POSITIVE RANGE MIN_BRANCH_TARGET_WIDTH to MAX_BRANCH_TARGET_WIDTH := 7;

 -- CURRENT DEFAULT BRANCH OPCODE BEGIN --

 CONSTANT CUR_DEFAULT_BRANCH_OPCODE_BEGIN :POSITIVE := 48;

 -- CURRENT DEFAULT BRANCH OPCODE END --

 CONSTANT CUR_DEFAULT_BRANCH_OPCODE_END :POSITIVE := 46;

 --===============================================================================--
 
 -- CURRENT DEFAULT ADDRESS AND DATA WIDTHS --

 CONSTANT CUR_DEFAULT_ADDR_WIDTH		 :POSITIVE RANGE 1 to MAX_ADDR_WIDTH := 7;
 CONSTANT CUR_DEFAULT_DATA_WIDTH		 :POSITIVE RANGE 1 to MAX_DATA_WIDTH := 32;
 
 -- Half of the DATA_WIDTH for the MULTIPLIERS
 CONSTANT CUR_DEFAULT_HALF_DATA_WIDTH :POSITIVE := CUR_DEFAULT_DATA_WIDTH /2;

 --===============================================================================--

 -- Register File address width

 CONSTANT CUR_DEFAULT_REG_FILE_ADDR_WIDTH :POSITIVE RANGE 1 to MAX_REG_FILE_ADDR_WIDTH := 4;

 --===============================================================================--

 -- CURRENT DEFAULT REGISTER WIDTH --

 CONSTANT CUR_DEFAULT_GEN_PUR_REG_WIDTH  :POSITIVE RANGE 1 to MAX_GEN_PUR_REG_WIDTH := 32;

 --===============================================================================--

 -- CURRENT DEFAULT NUMBER OF GENERAL PURPOSE REGISTER --

 CONSTANT CUR_DEFAULT_GEN_PUR_REG_NUM  :INTEGER RANGE 0 to MAX_GEN_PUR_REG_NUM := 2;
 CONSTANT CUR_DEFAULT_REG_FIELD_WIDTH  :POSITIVE RANGE 1 to MAX_REG_FIELD_WIDTH := 
 	CUR_DEFAULT_REG_FILE_ADDR_WIDTH;
  
 --===============================================================================--

 -- CURRENT DEFAULT WIDTH OF THE OPCODE FIELD --

 CONSTANT CUR_DEFAULT_OPCODE_FIELD_WIDTH  :POSITIVE RANGE 1 to MAX_OPCODE_FIELD_WIDTH := 3;
 
 --===============================================================================--

 -- CURRENT DEFAULT INPUT REGISTER NUMBER --

 CONSTANT CUR_DEFAULT_INPUT_REG_NUM :POSITIVE RANGE 1 to MAX_INPUT_REG_NUM := 5;
 
 --===============================================================================--

 -- CURRENT DEFAULT OUTPUT REGISTER NUMBER --

 CONSTANT CUR_DEFAULT_OUTPUT_REG_NUM :POSITIVE RANGE 1 to MAX_OUTPUT_REG_NUM := 5;
 
 --===============================================================================--
 -- CURRENT DEFAULT MEMORY SIZE --
 
 CONSTANT CUR_DEFAULT_MEM_SIZE :POSITIVE RANGE MIN_MEM_SIZE to MAX_MEM_SIZE := 96;
 
 --===============================================================================--

 -- CURRENT DEFAULT NUMBER OF MEMORY READ PORTS --

 CONSTANT CUR_DEFAULT_NUM_MEM_READ_PORTS :POSITIVE RANGE 1 to MAX_NUM_MEM_READ_PORTS := 4;

 --===============================================================================--

 -- CURRENT DEFAULT NUMBER OF MEMORY WRITE PORTS --

 CONSTANT CUR_DEFAULT_NUM_MEM_WRITE_PORTS :POSITIVE RANGE 1 to MAX_NUM_MEM_WRITE_PORTS := 2;

 --===============================================================================--

 -- CURRENT DEFAULT NUMBER OF FUNCTIONAL UNITS --

 CONSTANT CUR_DEFAULT_NUM_ADD_FU   :INTEGER RANGE 0 to MAX_NUM_FU   := 2;
 CONSTANT CUR_DEFAULT_NUM_MUL_FU   :INTEGER RANGE 0 to MAX_NUM_FU   := 1;
 CONSTANT CUR_DEFAULT_NUM_DIV_FU   :INTEGER RANGE 0 to MAX_NUM_FU   := 0;
 CONSTANT CUR_DEFAULT_NUM_LOGIC_FU :INTEGER RANGE 0 to MAX_NUM_FU := 1;
 CONSTANT CUR_DEFAULT_NUM_SHIFT_FU :INTEGER RANGE 0 to MAX_NUM_FU := 1;
 CONSTANT CUR_DEFAULT_NUM_DPU_FU   :INTEGER RANGE 0 to MAX_NUM_FU := 6;
 CONSTANT CUR_DEFAULT_NUM_CPU_FU   :INTEGER RANGE 0 to MAX_NUM_FU := 2;
 CONSTANT CUR_DEFAULT_NUM_OF_FUS   :INTEGER := CUR_DEFAULT_NUM_ADD_FU+
                                               CUR_DEFAULT_NUM_MUL_FU+
                                               CUR_DEFAULT_NUM_DIV_FU+
                                               CUR_DEFAULT_NUM_LOGIC_FU+
                                               CUR_DEFAULT_NUM_SHIFT_FU+
                                               CUR_DEFAULT_NUM_DPU_FU+
                                               CUR_DEFAULT_NUM_CPU_FU;

 --===============================================================================--

 -- CURRENT DEFAULT NUMBER OF  READ PORTS FOR CONTROL REGFILE --

 CONSTANT CUR_DEFAULT_NUM_CTRL_READ_PORTS :POSITIVE RANGE 1 to MAX_NUM_CTRL_READ_PORTS := 1;

 --===============================================================================--

 -- CURRENT DEFAULT NUMBER OF WRITE PORTS FOR CONTROL REGFILE --

 CONSTANT CUR_DEFAULT_NUM_CTRL_WRITE_PORTS :POSITIVE RANGE 1 to MAX_NUM_CTRL_WRITE_PORTS := 1;

 --===============================================================================--


 -- CONTROL Register File address width

 CONSTANT CUR_DEFAULT_CTRL_REGFILE_ADDR_WIDTH
 :POSITIVE RANGE 1 to MAX_CTRL_REGFILE_ADDR_WIDTH := 4;


 --===============================================================================--

 -- CURRENT DEFAULT CONTROL REGISTER WIDTH --

 CONSTANT CUR_DEFAULT_CTRL_REG_WIDTH  :POSITIVE RANGE 1 to MAX_CTRL_REG_WIDTH := 1;

 ----===============================================================================--

 -- CURRENT DEFAULT NUMBER OF CONTROL REGISTERS --

 CONSTANT CUR_DEFAULT_NUM_CONTROL_REGS :INTEGER RANGE 0 to MAX_NUM_CONTROL_REGS := 1;

 --===============================================================================--

 -- CURRENT DEFAULT NUMBER OF CONTROL INPUTS --
CONSTANT CUR_DEFAULT_NUM_CONTROL_INPUTS :INTEGER RANGE 0 to MAX_NUM_CONTROL_INPUTS := 2;

 --===============================================================================--

 -- CURRENT DEFAULT NUMBER OF CONTROL REGISTERS --

 CONSTANT CUR_DEFAULT_NUM_CONTROL_OUTPUTS :INTEGER RANGE 0 to MAX_NUM_CONTROL_OUTPUTS := 2;

 --===============================================================================--

 --===============================================================================--
 --===============================================================================--

 FUNCTION check_global_generics RETURN BOOLEAN;

 --===============================================================================--
 --===============================================================================--

 end DEFAULT_LIB;

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

 package body DEFAULT_LIB is

 FUNCTION check_global_generics RETURN BOOLEAN IS
 CONSTANT new_line : STRING(1 TO 1) := (1 => lf);  -- For assertion reports
 BEGIN
 -- errors

 --===============================================================================--
 ASSERT (CUR_DEFAULT_INSTR_WIDTH <= MAX_INSTR_WIDTH )
 REPORT

 new_line & "===========================================================================================" &
 new_line  & "ERROR in wppe_lib.vhd : Instruction width: CUR_DEFAULT_INSTR_WIDTH is > MAX_INSTR_WIDTH"     &
 new_line  & "===========================================================================================" & new_line

 SEVERITY ERROR;

 --===============================================================================--

 					ASSERT (CUR_DEFAULT_DATA_WIDTH   <= MAX_DATA_WIDTH)
 REPORT
 new_line	& "===========================================================================================" &
 new_line & "ERROR in wppe_lib.vhd : Data width: CUR_DEFAULT_DATA_WIDTH is > MAX_DATA_WIDTH" &
 new_line & "===========================================================================================" & new_line
 SEVERITY ERROR;

 					ASSERT (CUR_DEFAULT_HALF_DATA_WIDTH   = CUR_DEFAULT_DATA_WIDTH / 2)

 REPORT
 new_line	& "===========================================================================================" &
 new_line & "ERROR in wppe_lib.vhd : CUR_DEFAULT_HALF_DATA_WIDTH must be CUR_DEFAULT_DATA_WIDTH / 2 " &
 new_line & "===========================================================================================" & new_line
 SEVERITY ERROR;

 --===============================================================================--

 					ASSERT(CUR_DEFAULT_ADDR_WIDTH  <= MAX_ADDR_WIDTH)
 REPORT
 new_line	& "===========================================================================================" &
 new_line & "ERROR wppe_lib.vhd  : Address width: CUR_DEFAULT_ADDR_WIDTH is > MAX_ADDR_WIDTH" &
 new_line & "===========================================================================================" & new_line
 SEVERITY ERROR;

 --===============================================================================--

	ASSERT(CUR_DEFAULT_GEN_PUR_REG_NUM = (2**CUR_DEFAULT_REG_FILE_ADDR_WIDTH - CUR_DEFAULT_INPUT_REG_NUM -
 CUR_DEFAULT_OUTPUT_REG_NUM))

 REPORT
 new_line	& "===========================================================================================" &
 new_line & "ERROR in wppe_lib.vhd : 2**CUR_DEFAULT_REG_FILE_ADDR_WIDTH != CUR_DEFAULT_INPUT_REG_NUM + " &
 new_line & "CUR_DEFAULT_OUTPUT_REG_NUM + CUR_DEFAULT_GEN_PUR_REG_NUM " &
 new_line & "Address width of the register file does not match the number of registers" &
 new_line & "===========================================================================================" & new_line

 					SEVERITY ERROR;

 --===============================================================================--

 					ASSERT(CUR_DEFAULT_MEM_SIZE = (2**CUR_DEFAULT_ADDR_WIDTH))

 REPORT
 new_line & "===========================================================================================" &
 new_line & "ERROR in wppe_2.vhd : RAM Address width does not match the RAM size" &
 new_line & "CUR_DEFAULT_MEM_SIZE != 2**CUR_DEFAULT_ADDR_WIDTH " &
 new_line & "===========================================================================================" & new_line

 					SEVERITY ERROR;

 --===============================================================================--

 					ASSERT(CUR_DEFAULT_GEN_PUR_REG_WIDTH = CUR_DEFAULT_DATA_WIDTH)

 REPORT
 new_line & "===========================================================================================" &
 new_line & "WARNING in wppe_lib.vhd : the width of the registers varies from the data width of the entity" &
 new_line & "CUR_DEFAULT_GEN_PUR_REG_WIDTH != CUR_DEFAULT_DATA_WIDTH " &
 new_line & "===========================================================================================" & new_line

 					SEVERITY WARNING;

 RETURN true; 
 END check_global_generics;



 end DEFAULT_LIB;