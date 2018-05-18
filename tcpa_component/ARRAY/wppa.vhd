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
-- Create Date:    13:28:31 02/18/06
-- Design Name:    
-- Module Name:    WPPA - Behavioral
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
-- pragma translate_off
-- cadence translate_on
----library CADENCE;
----use cadence.attributes.all;
-- pragma translate_on
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use STD.TEXTIO.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.all;
use wppa_instance_v1_01_a.DEFAULT_LIB.all;
use wppa_instance_v1_01_a.ARRAY_LIB.all;
use wppa_instance_v1_01_a.TYPE_LIB.all;
use wppa_instance_v1_01_a.INVASIC_LIB.all;

entity WPPA is
	generic(

		-- cadence translate_off        

		INSTANCE_NAME          : string                                                           := "?";
		WPPA_SIZE              : string                                                           := "?x?";

		-- cadence translate_on                                 

		wppa_generics          : t_wppa_generics                                                  := DEFAULT_WPPA_GENERICS;

		--###########################################################################
		-- Bus protocol parameters, do not add to or delete
		--###########################################################################
		C_AWIDTH               : integer                                                          := 32;
		C_DWIDTH               : integer                                                          := 32;
		C_NUM_CE               : integer                                                          := 16;
		--###########################################################################


		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

		------------------------------------------                                      
		-- VERTICAL number of WPPEs in the array
		N                      : integer range MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL     := CUR_DEFAULT_NUM_WPPE_VERTICAL;
		------------------------------------------
		-- HORIZONTAL number of WPPEs in the array
		M                      : integer range MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL := CUR_DEFAULT_NUM_WPPE_HORIZONTAL;
		------------------------------------------                                      
		-- Number of WPPEs which are connected to external devices
		-- on the array's TOP
		EXTERNAL_TOP_M         : integer range MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL := CUR_DEFAULT_TOP_EXTERNAL_NUM_WPPE_HORIZONTAL;
		------------------------------------------
		-- Number of WPPEs which are connected to external devices
		-- on the array's BOTTOM
		EXTERNAL_BOTTOM_M      : integer range MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL := CUR_DEFAULT_BOTTOM_EXTERNAL_NUM_WPPE_HORIZONTAL;
		------------------------------------------                                      
		-- Number of WPPEs which are connected to external devices
		-- on the arrray's LEFT SIDE
		EXTERNAL_LEFT_N        : integer range MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL     := CUR_DEFAULT_LEFT_EXTERNAL_NUM_WPPE_VERTICAL;
		------------------------------------------
		-- Number of WPPEs which are connected to external devices
		-- on the array's RIGHT SIDE
		EXTERNAL_RIGHT_N       : integer range MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL     := CUR_DEFAULT_RIGHT_EXTERNAL_NUM_WPPE_VERTICAL;
		------------------------------------------

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		------------------------------------------
		ADDR_WIDTH             : positive range 1 to MAX_ADDR_WIDTH                               := CUR_DEFAULT_ADDR_WIDTH;
		------------------------------------------
		NUM_OF_INPUT_REG       : positive range 1 to MAX_INPUT_REG_NUM                            := CUR_DEFAULT_INPUT_REG_NUM;
		------------------------------------------
		NUM_OF_CONTROL_INPUTS  : integer range 0 to MAX_NUM_CONTROL_INPUTS                        := CUR_DEFAULT_NUM_CONTROL_INPUTS;
		--                                      ------------------------------------------
		NUM_OF_CONTROL_OUTPUTS : integer range 0 to MAX_NUM_CONTROL_OUTPUTS                       := CUR_DEFAULT_NUM_CONTROL_OUTPUTS;
		------------------------------------------

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		-- GENERICS FOR THE EXTERNAL OCB BUS TO EXTERNAL PROCESSOR
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		BUS_ADDR_WIDTH         : integer range MIN_BUS_ADDR_WIDTH to MAX_BUS_ADDR_WIDTH           := CUR_DEFAULT_BUS_ADDR_WIDTH;

		BUS_DATA_WIDTH         : integer range MIN_BUS_DATA_WIDTH to MAX_BUS_DATA_WIDTH           := CUR_DEFAULT_BUS_DATA_WIDTH;
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		-- GENERICS FOR THE GLOBAL CONFIGURATION MEMORY
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		------------------------------------------
		SOURCE_MEM_SIZE        : positive range 2 to MAX_SOURCE_MEM_SIZE                          := CUR_DEFAULT_SOURCE_MEM_SIZE;
		------------------------------------------
		SOURCE_ADDR_WIDTH      : positive range 1 to MAX_ADDR_WIDTH                               := CUR_DEFAULT_SOURCE_ADDR_WIDTH;
		------------------------------------------
		SOURCE_DATA_WIDTH      : positive range 1 to 128                                          := CUR_DEFAULT_SOURCE_DATA_WIDTH;
		------------------------------------------

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		-- GENERICS FOR THE WP PROCESSORS AND THEIR INTERCONNECT WRAPPERS
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		------------------------------------------

		--		ADJ_MATRIX_ARRAY_ALL   : t_adj_matrix_array_all(1 to 4, 1 to 4);
		--		--:= (others => (others => CUR_DEFAULT_ADJACENCY_MATRIX));
		--		------------------------------------------                                                                                                                      
		--		WPPE_GENERICS          : t_wppe_generics_array(1 to 4, 1 to 4)
		--	   --:= (others => (others => CUR_DEFAULT_WPPE_GENERICS_RECORD))


		--Ericles Sousa: Making the array size flexible. The parameters is comming from the TCPA editor.
		--In the past the user needed to change them by hand.
		ADJ_MATRIX_ARRAY_ALL   : t_adj_matrix_array_all(1 to CUR_DEFAULT_NUM_WPPE_VERTICAL, 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL);
		------------------------------------------                                                                                                                      
		WPPE_GENERICS          : t_wppe_generics_array(1 to CUR_DEFAULT_NUM_WPPE_VERTICAL, 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL)
	------------------------------------------
	);

	port(

		--###########################################################################
		-- OPB  BUS  INTERFACE SIGNALS
		--###########################################################################
		--    Bus2IP_Addr : in  std_logic_vector(0 to C_AWIDTH-1);
		--    Bus2IP_Data : in  std_logic_vector(0 to C_DWIDTH-1);
		--    Bus2IP_BE   : in  std_logic_vector(0 to C_DWIDTH/8-1);
		--    Bus2IP_RdCE : in  std_logic_vector(0 to C_NUM_CE-1);
		--    Bus2IP_WrCE : in  std_logic_vector(0 to C_NUM_CE-1);
		--    IP2Bus_Data : out std_logic_vector(0 to C_DWIDTH-1);
		--###########################################################################


		--/////////////////////////////////////////////////--

		clk_in, rst                     : in  std_logic;

		--                      BUS_ADDR_I :in std_logic_vector(BUS_ADDR_WIDTH -1 downto 0);
		--                      BUS_DATA_I :in std_logic_vector(BUS_DATA_WIDTH -1 downto 0);
		--                      BUS_DATA_O :out std_logic_vector(BUS_DATA_WIDTH -1 downto 0);
		--                      BUS_WE_I   :in std_logic;
		--
		--/////////////////////////////////////////////////--

		--    EXTERNAL_TOP_north_out : out
		--    std_logic_vector(EXTERNAL_TOP_M *SOUTH_INPUT_WIDTH *SOUTH_PIN_NUM -1 downto 0);
		--    EXTERNAL_TOP_north_in  : in
		--    std_logic_vector(EXTERNAL_TOP_M *NORTH_INPUT_WIDTH *NORTH_PIN_NUM -1 downto 0);
		--
		--    --/////////////////////////////////////////////////--
		--
		--    EXTERNAL_BOTTOM_south_out : out
		--    std_logic_vector(EXTERNAL_BOTTOM_M *NORTH_INPUT_WIDTH *NORTH_PIN_NUM -1 downto 0);
		--    EXTERNAL_BOTTOM_south_in  : in
		--    std_logic_vector(EXTERNAL_BOTTOM_M *SOUTH_INPUT_WIDTH *SOUTH_PIN_NUM -1 downto 0);
		--
		--    --/////////////////////////////////////////////////--
		--
		--    EXTERNAL_LEFT_west_out : out
		--    std_logic_vector(EXTERNAL_LEFT_N *EAST_INPUT_WIDTH *EAST_PIN_NUM -1 downto 0);
		--    EXTERNAL_LEFT_west_in  : in
		--    std_logic_vector(EXTERNAL_LEFT_N *WEST_INPUT_WIDTH *WEST_PIN_NUM -1 downto 0);
		--
		--    --/////////////////////////////////////////////////--
		--
		--    EXTERNAL_RIGHT_east_out        : out
		--    std_logic_vector(EXTERNAL_RIGHT_N *WEST_INPUT_WIDTH *WEST_PIN_NUM -1 downto 0); 
		--    EXTERNAL_RIGHT_east_in         : in
		--    std_logic_vector(EXTERNAL_RIGHT_N *EAST_INPUT_WIDTH *EAST_PIN_NUM -1 downto 0);
		--    --/////////////////////////////////////////////////--
		--    
		--    
		----#################
		----### CTRL_ICN: ###
		----############################################################
		-------------------------------------------------------------------------------------------------------
		--    EXTERNAL_TOP_north_out_ctrl    : out
		--    std_logic_vector(EXTERNAL_TOP_M *SOUTH_INPUT_WIDTH_CTRL *SOUTH_PIN_NUM_CTRL -1 downto 0);
		--    EXTERNAL_TOP_north_in_ctrl     : in
		--    std_logic_vector(EXTERNAL_TOP_M *NORTH_INPUT_WIDTH_CTRL *NORTH_PIN_NUM_CTRL -1 downto 0);
		-------------------------------------------------------------------------------------------------------
		--    EXTERNAL_BOTTOM_south_out_ctrl : out
		--    std_logic_vector(EXTERNAL_BOTTOM_M *NORTH_INPUT_WIDTH_CTRL *NORTH_PIN_NUM_CTRL -1 downto 0);
		--    EXTERNAL_BOTTOM_south_in_ctrl  : in
		--    std_logic_vector(EXTERNAL_BOTTOM_M *SOUTH_INPUT_WIDTH_CTRL *SOUTH_PIN_NUM_CTRL -1 downto 0);
		-------------------------------------------------------------------------------------------------------
		--    EXTERNAL_LEFT_west_out_ctrl    : out
		--    std_logic_vector(EXTERNAL_LEFT_N *EAST_INPUT_WIDTH_CTRL *EAST_PIN_NUM_CTRL -1 downto 0);
		--    EXTERNAL_LEFT_west_in_ctrl     : in
		--    std_logic_vector(EXTERNAL_LEFT_N *WEST_INPUT_WIDTH_CTRL *WEST_PIN_NUM_CTRL -1 downto 0);
		-------------------------------------------------------------------------------------------------------
		--    EXTERNAL_RIGHT_east_out_ctrl   : out
		--    std_logic_vector(EXTERNAL_RIGHT_N *WEST_INPUT_WIDTH_CTRL *WEST_PIN_NUM_CTRL -1 downto 0);
		--    EXTERNAL_RIGHT_east_in_ctrl    : in
		--    std_logic_vector(EXTERNAL_RIGHT_N *EAST_INPUT_WIDTH_CTRL *EAST_PIN_NUM_CTRL -1 downto 0); 
		-----------------------------------------------------------------------------------------------------                           
		--##########################
		-- cadence translate_off                        
		-- ***** ASTRA
		--algo_type                 : out std_logic;
		--                      to_input_img_mem_algo_type      : out std_logic;
		--                      to_output_img_mem_algo_type     : out std_logic;

		-- Bus 
		wppa_bus_input_interface     : in  t_wppa_bus_input_interface;
		wppa_bus_output_interface    : out t_wppa_bus_output_interface;
		-- Data 
		wppa_data_input              : in  t_wppa_data_input_interface;
		wppa_data_output             : out t_wppa_data_output_interface;
		-- Control 
		wppa_ctrl_input              : in  t_wppa_ctrl_input_interface;
		wppa_ctrl_output             : out t_wppa_ctrl_output_interface;
		-- Memory 
		wppa_memory_input_interface  : in  t_wppa_memory_input_interface;
		wppa_memory_output_interface : out t_wppa_memory_output_interface;

		tcpa_config_done             : out std_logic;
		fault_injection              : in t_fault_injection_module;
		tcpa_config_done_vector      : out std_logic_vector(31 downto 0);
		error_status                 : out t_error_status;
		ctrl_programmable_depth      : in  t_ctrl_programmable_depth;
		en_programmable_fd_depth     : in  t_en_programmable_fd_depth;
		programmable_fd_depth        : in  t_programmable_fd_depth;
		enable_tcpa                  : in  std_logic;
		pc_debug_out                 : out t_pc_debug_outs;

		icp_program_interface        : in  t_prog_intfc;
		invasion_input               : in  t_inv_sig;
		invasion_output              : out t_inv_sig;

		parasitary_invasion_input    : in  t_inv_sig;
		parasitary_invasion_output   : out t_inv_sig

	-- Configuration
	--					wppa_config_interface     :in  t_wppa_config_input_interface 


	);

-- cadence translate_on
-- pragma translate_off
----attribute TEMPLATE of WPPA: entity is TRUE;
-- pragma translate_on

end WPPA;

architecture Behavioral of WPPA is
	--Ericles
	signal clk : std_logic;
	signal ctrl_out                : std_logic_vector(3 downto 0) := "0000";
	signal configuration_done      : t_configuration_done;
	signal vliw_config_en          : std_logic;
	signal icn_config_en           : std_logic;
	signal common_config_reset     : std_logic;
	signal fault_injection_sig     : t_fault_injection_module; 

	signal error_reg           : std_logic;
	signal error_flag_reg      : std_logic_vector((CUR_DEFAULT_NUM_WPPE_VERTICAL*CUR_DEFAULT_NUM_WPPE_HORIZONTAL)-1 downto 0);
	signal sig_error_flag      : t_array;
	signal sig_error_diagnosis : t_array_error_diagnosis;

	signal inv_border : t_inv_sig;
	signal count_down : t_count_down;
	type t_inv_X_out_Y_in is array (integer range <>, integer range <>) of t_inv_sig;

	signal inv_N_out_S_in : t_inv_X_out_Y_in(WPPA_generics.N - 1 downto 1, WPPA_generics.M downto 1);
	signal inv_S_out_N_in : t_inv_X_out_Y_in(WPPA_generics.N - 1 downto 1, WPPA_generics.M downto 1);
	signal inv_W_out_E_in : t_inv_X_out_Y_in(WPPA_generics.N downto 1, WPPA_generics.M - 1 downto 1);
	signal inv_E_out_W_in : t_inv_X_out_Y_in(WPPA_generics.N downto 1, WPPA_generics.M - 1 downto 1);

	signal inv_prog_data  : t_prog_data;
	signal inv_prog_addr  : t_prog_addr;
	signal inv_prog_wr_en : std_logic;
	signal inv_start      : std_logic;

	signal integer_string : string(1 to 80) := (others => ' ');

	-- cadence translate_off        

	CONSTANT TOP_LEVEL_INSTANCE_NAME : string := INSTANCE_NAME;

	-- cadence translate_on 
	--====================================================================================
	-- ADDITIONAL ARRAYED TYPE DECLARATIONS
	--====================================================================================

	type t_internal_EAST_OUT_west_in_connections is array (integer range <>, integer range <>) of std_logic_vector(WEST_PIN_NUM * WEST_INPUT_WIDTH - 1 downto 0);
	type t_internal_WEST_OUT_east_in_connections is array (integer range <>, integer range <>) of std_logic_vector(EAST_PIN_NUM * EAST_INPUT_WIDTH - 1 downto 0);

	type t_internal_NORTH_OUT_south_in_connections is array (integer range <>, integer range <>) of std_logic_vector(SOUTH_PIN_NUM * SOUTH_INPUT_WIDTH - 1 downto 0);
	type t_internal_SOUTH_OUT_north_in_connections is array (integer range <>, integer range <>) of std_logic_vector(NORTH_PIN_NUM * NORTH_INPUT_WIDTH - 1 downto 0);
	--##########################
	--########## CTRL_ICN: #####
	type t_internal_EAST_OUT_west_in_connections_ctrl is array (integer range <>, integer range <>) of std_logic_vector(WEST_PIN_NUM_CTRL * WEST_INPUT_WIDTH_CTRL - 1 downto 0);
	type t_internal_WEST_OUT_east_in_connections_ctrl is array (integer range <>, integer range <>) of std_logic_vector(EAST_PIN_NUM_CTRL * EAST_INPUT_WIDTH_CTRL - 1 downto 0);

	type t_internal_NORTH_OUT_south_in_connections_ctrl is array (integer range <>, integer range <>) of std_logic_vector(SOUTH_PIN_NUM_CTRL * SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);
	type t_internal_SOUTH_OUT_north_in_connections_ctrl is array (integer range <>, integer range <>) of std_logic_vector(NORTH_PIN_NUM_CTRL * NORTH_INPUT_WIDTH_CTRL - 1 downto 0);
	--##########################                                                                            
	--------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------
	--type t_pc_debug_outs is array (integer range <>, integer range <>) of std_logic_vector(wppa_generics.ADDR_WIDTH - 1 downto 0);
	--------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------
	type t_in_fifos_write_ens is array (integer range <>, integer range <>) of std_logic_vector(wppa_generics.NUM_OF_INPUT_REG - 1 downto 0);
	--------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	--type t_ctrl_inputs    is array (integer range<>, integer range<>)
	--                                                                              of std_logic_vector(NUM_OF_CONTROL_INPUTS -1 downto 0);
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	--type t_ctrl_outputs   is array (integer range<>, integer range<>)
	--                                                                              of std_logic_vector(NUM_OF_CONTROL_OUTPUTS -1 downto 0);
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------


	signal zero_signal : std_logic;

	--##################################################################################
	--##################################################################################

	--***********************************
	-- POWER SHUTOFF AUXILIARY SIGNAL
	--***********************************

	signal FF_START_DETECTION_BUS : std_logic;

	--***********************************

	signal internal_conf_mask_horizontal : std_logic_vector(1 to wppa_generics.M);
	signal internal_conf_mask_vertical   : std_logic_vector(1 to wppa_generics.N);

	--##################################################################################
	--##################################################################################


	--====================================================================================
	-- INTERNAL (INTER)CONNECT SIGNALS DECLARATION
	--====================================================================================

	signal INTERNAL_EAST_OUT_west_in_connections : t_internal_EAST_OUT_west_in_connections(1 to wppa_generics.N, 1 to (wppa_generics.M - 1));
	signal INTERNAL_WEST_OUT_east_in_connections : t_internal_WEST_OUT_east_in_connections(1 to wppa_generics.N, 1 to (wppa_generics.M - 1));

	signal INTERNAL_NORTH_OUT_south_in_connections    : t_internal_NORTH_OUT_south_in_connections(1 to (wppa_generics.N - 1), 1 to wppa_generics.M);
	signal INTERNAL_SOUTH_OUT_north_in_connections    : t_internal_SOUTH_OUT_north_in_connections(1 to (wppa_generics.N - 1), 1 to wppa_generics.M);
	--====================================================================================
	--################
	--### CTRL_ICN:###                                      
	-----------------------------------------------------------------------------------------------------
	signal INTERNAL_EAST_OUT_west_in_connections_ctrl : t_internal_EAST_OUT_west_in_connections_ctrl(1 to wppa_generics.N, 1 to (wppa_generics.M - 1));
	signal INTERNAL_WEST_OUT_east_in_connections_ctrl : t_internal_WEST_OUT_east_in_connections_ctrl(1 to wppa_generics.N, 1 to (wppa_generics.M - 1));

	signal INTERNAL_NORTH_OUT_south_in_connections_ctrl : t_internal_NORTH_OUT_south_in_connections_ctrl(1 to (wppa_generics.N - 1), 1 to wppa_generics.M);
	signal INTERNAL_SOUTH_OUT_north_in_connections_ctrl : t_internal_SOUTH_OUT_north_in_connections_ctrl(1 to (wppa_generics.N - 1), 1 to wppa_generics.M);
	-----------------------------------------------------------------------------------------------------
	--################

	--====================================================================================
	--====================================================================================
	-- INTERNAL SIGNALS DECLARATION, FOR THOSE SIGNALS, WHICH SHOULD NOT
	-- BE CONNECTED TO ANY EXTERNAL SOURCES, BUT ARE PRESENT AT THE
	-- CORRESPONDING WPPE ENTITIES IN THE FIRST AND LAST ROW AND IN THE
	-- FIRST AND LAST COLUMN OF THE PROCESSOR ARRAY
	--====================================================================================
	--====================================================================================

	--====================================================================================
	signal INternal_TOP_north_out    : std_logic_vector(wppa_generics.M * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto 0);
	signal INternal_TOP_north_in     : std_logic_vector(wppa_generics.M * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto 0);
	--====================================================================================
	signal INternal_BOTTOM_south_out : std_logic_vector(wppa_generics.M * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto 0);
	signal INternal_BOTTOM_south_in  : std_logic_vector(wppa_generics.M * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto 0);
	--====================================================================================
	signal INternal_LEFT_west_out    : std_logic_vector(wppa_generics.N * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto 0);
	signal INternal_LEFT_west_in     : std_logic_vector(wppa_generics.N * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto 0);
	--====================================================================================
	signal INternal_RIGHT_east_out   : std_logic_vector(wppa_generics.N * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto 0);
	signal INternal_RIGHT_east_in    : std_logic_vector(wppa_generics.N * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto 0);

	--################
	--### CTRL_ICN:###
	------------------------------------------------------------------------------
	signal INternal_TOP_north_out_ctrl    : std_logic_vector(wppa_generics.M * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto 0);
	signal INternal_TOP_north_in_ctrl     : std_logic_vector(wppa_generics.M * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto 0);
	------------------------------------------------------------------------------
	signal INternal_BOTTOM_south_out_ctrl : std_logic_vector(wppa_generics.M * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto 0);
	signal INternal_BOTTOM_south_in_ctrl  : std_logic_vector(wppa_generics.M * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto 0);
	------------------------------------------------------------------------------
	signal INternal_LEFT_west_out_ctrl    : std_logic_vector(wppa_generics.N * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto 0);
	signal INternal_LEFT_west_in_ctrl     : std_logic_vector(wppa_generics.N * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto 0);
	------------------------------------------------------------------------------
	signal INternal_RIGHT_east_out_ctrl   : std_logic_vector(wppa_generics.N * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto 0);
	signal INternal_RIGHT_east_in_ctrl    : std_logic_vector(wppa_generics.N * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto 0);
	------------------------------------------------------------------------------
	--################
	--====================================================================================
	--====================================================================================

	--====================================================================================
	-- INTERNAL ARRAYED CONTROL AND DEBUG SIGNALS DECLARATION
	--====================================================================================

	signal internal_debug_registers : std_logic_vector((wppa_generics.C_NUM_CE - 9) * wppa_generics.C_DWIDTH - 1 downto 0);

	signal GLOBAL_pc_debug_outs : t_pc_debug_outs;

	signal GLOBAL_input_fifos_write_ens : t_in_fifos_write_ens(1 to wppa_generics.N, 1 to wppa_generics.M);

	--signal GLOBAL_ctrl_inputs			:t_ctrl_inputs( 1 to N, 1 to M);
	--signal GLOBAL_ctrl_outputs			:t_ctrl_outputs(1 to N, 1 to M);

	signal GLOBAL_config_mem_addr : std_logic_vector(wppa_generics.SOURCE_ADDR_WIDTH - 1 downto 0);
	signal GLOBAL_config_mem_data : std_logic_vector(wppa_generics.SOURCE_DATA_WIDTH - 1 downto 0);
	signal config_data_out        : std_logic_vector(wppa_generics.SOURCE_DATA_WIDTH - 1 downto 0);

	-- ***** ASTRA
	signal algo_type           : std_logic;

	signal wppa_input  : std_logic_vector(7 downto 0); -- PE[0 0], IN_0
	signal wppa_output : std_logic_vector(7 downto 0); -- PE[0 1], OUT_0

	--#################################################################################
	-- CONFIGURATION MANAGER SIGNALS: 
	--signal offset				:std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH-1  downto 0);
	--signal dnumber				:std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH-1  downto 0);
	--signal conf_type			:std_logic_vector(CUR_DEFAULT_CONFIG_TYPE_WIDTH-1  downto 0);
	signal source_data : std_logic_vector(CUR_DEFAULT_SOURCE_DATA_WIDTH - 1 downto 0);
	signal conf_done   : std_logic;
	--signal conf_en				:std_logic;

	signal dtab_addr      : std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
	signal dtab_data      : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal dtab_we        : std_logic;
	signal source_select  : std_logic_vector(CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH - 1 downto 0);
	signal CM_source_addr : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal GlobCtrl_BE    : std_logic_vector(0 to wppa_generics.C_DWIDTH / 8 - 1);
	signal GlobCtrl_Data  : std_logic_vector(0 to wppa_generics.C_DWIDTH - 1);
	signal GlobCtrl_WrCE  : std_logic_vector(0 to wppa_generics.C_NUM_CE - 1);
	--#################################################################################
	signal dtab_out       : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal GC_source_addr : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);

	signal source_mux_data_inputs : std_logic_vector(
		(CUR_DEFAULT_SOURCE_ADDR_WIDTH * CUR_DEFAULT_SOURCE_MUX_NUM_OF_INPUTS) - 1 downto 0);
	signal source_mux_output : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	-- ***** astra
	signal clk_tmp           : std_logic;

	signal clk_gating_select     : std_logic;
	signal NEG_clk_gating_select : std_logic;
	signal clk_gating_clk        : std_logic;

	signal clk_gated_clk : std_logic;

	signal switch_counter : integer;    --    := 0;

	signal internal_conf_en : std_logic;
	signal ready_out        : std_logic;

	type t_clock_gating_state is (clk_init, free_init_end, clk_config, free_ready);
	signal clk_gating_state : t_clock_gating_state; -- := clk_init;


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

	--#################################################################################
	--#################################################################################

	-- C O M P O N E N T   D E C L A R A T I O N
	-- G L O B A L  C O N F I G U R A T I O N   M E M O R Y

	--#################################################################################
	--#################################################################################


	signal PC2CM_conf_en   : std_logic;
	signal PC2CM_offset    : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal PC2CM_dnumber   : std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
	signal PC2CM_conf_type : std_logic_vector(CUR_DEFAULT_CONFIG_TYPE_WIDTH - 1 downto 0);

	COMPONENT plb_controller
		PORT(
			clk           : IN  std_logic;
			rst           : IN  std_logic;
			Bus2IP_Addr   : IN  std_logic_vector(0 to 31);
			Bus2IP_Data   : IN  std_logic_vector(0 to 31);
			Bus2IP_BE     : IN  std_logic_vector(0 to 3);
			Bus2IP_RdCE   : IN  std_logic_vector(0 to 15);
			Bus2IP_WrCE   : IN  std_logic_vector(0 to 15);
			conf_en_out   : out std_logic;
			offset_out    : out std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
			dnumber_out   : out std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
			conf_type_out : out std_logic_vector(CUR_DEFAULT_CONFIG_TYPE_WIDTH - 1 downto 0)
		);
	END COMPONENT;

	COMPONENT config_memory is
		generic(

			-- cadence translate_off	

			INSTANCE_NAME : string;

			-- cadence translate_on				
			--Ericles Sousa on 19 Dec 2014. Increasing the memory size and ADDR_WIDTH
			MEM_SIZE      : positive range 32 to 32 * 1024 := CUR_DEFAULT_SOURCE_MEM_SIZE;
			DATA_WIDTH    : positive range 1 to 128        := CUR_DEFAULT_SOURCE_DATA_WIDTH; -- Maximum Instruction word width for all FUs (VLIW word width)
			ADDR_WIDTH    : positive range 1 to 32         := CUR_DEFAULT_SOURCE_ADDR_WIDTH
		);

		port(
			clk       : in  std_logic;
			rst       : in  std_logic;
			cfg_reset : in  std_logic;
			we        : in  std_logic;
			d_in      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			addr      : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			d_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end COMPONENT config_memory;

	--#################################################################################
	--#################################################################################

	-- C O M P O N E N T   D E C L A R A T I O N
	-- G L O B A L   C O N F I G U R A T I O N   C O N T R O L L E R

	--#################################################################################
	--#################################################################################

	COMPONENT GLOBAL_CONTROLLER is
		generic(

			-- cadence translate_off	

			INSTANCE_NAME     : string;

			-- cadence translate_on					
			--###########################################################################
			-- Bus protocol parameters, do not add to or delete
			--###########################################################################
			C_AWIDTH          : integer                                                          := 32;
			C_DWIDTH          : integer                                                          := 32;
			C_NUM_CE          : integer                                                          := 16;
			--###########################################################################


			--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

			------------------------------------------					
			-- VERTICAL number of WPPEs in the array
			N                 : integer range MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL     := CUR_DEFAULT_NUM_WPPE_VERTICAL;
			------------------------------------------
			-- HORIZONTAL number of WPPEs in the array
			M                 : integer range MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL := CUR_DEFAULT_NUM_WPPE_HORIZONTAL;
			------------------------------------------					

			--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			-- Generic variables of the OCB bus to external processor core

			BUS_ADDR_WIDTH    : integer range 8 to 32                                            := CUR_DEFAULT_BUS_ADDR_WIDTH;
			BUS_DATA_WIDTH    : integer range 8 to 32                                            := CUR_DEFAULT_BUS_DATA_WIDTH;

			SOURCE_DATA_WIDTH : positive range 1 to 128                                          := CUR_DEFAULT_SOURCE_DATA_WIDTH;
			SOURCE_ADDR_WIDTH : positive range 1 to MAX_ADDR_WIDTH                               := CUR_DEFAULT_SOURCE_ADDR_WIDTH
		);

		port(

			--###########################################################################
			-- OPB  BUS  INTERFACE SIGNALS
			--###########################################################################
			Bus2IP_Addr                   : in  std_logic_vector(0 to C_AWIDTH - 1);
			Bus2IP_Data                   : in  std_logic_vector(0 to C_DWIDTH - 1);
			Bus2IP_BE                     : in  std_logic_vector(0 to C_DWIDTH / 8 - 1);
			Bus2IP_RdCE                   : in  std_logic_vector(0 to C_NUM_CE - 1);
			Bus2IP_WrCE                   : in  std_logic_vector(0 to C_NUM_CE - 1);
			IP2Bus_Data                   : out std_logic_vector(0 to C_DWIDTH - 1);
			--###########################################################################

			debug_registers               : in  std_logic_vector((C_NUM_CE - 9) * C_DWIDTH - 1 downto 0);

			clk                           : in  std_logic;
			rst                           : in  std_logic;

			--		-- OCB Bus signals to external processor core
			--		ADDR_I :in std_logic_vector(BUS_ADDR_WIDTH -1 downto 0);
			--		DATA_I :in std_logic_vector(BUS_DATA_WIDTH -1 downto 0);
			--		DATA_O :out std_logic_vector(BUS_DATA_WIDTH -1 downto 0);
			--		WE_I	 :in std_logic;
			--
			-- (Re-)Configuration-enable bit vector
			-- vertical
			CONFIGURATION_MASK_VERTICAL   : out std_logic_vector(1 to M); --N);

			-- (Re-)Configuration-enable bit vector
			-- horizontal
			CONFIGURATION_MASK_HORIZONTAL : out std_logic_vector(1 to N); --M);					

			source_data_in                : in  std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);
			source_data_out               : out std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);

			-- Address signal to external global configuration memory
			source_addr_out               : out std_logic_vector(SOURCE_ADDR_WIDTH - 1 downto 0);

			ALGO_TYPE_out                 : out std_logic;

			common_config_reset           : out std_logic;
			vliw_config_en                : out std_logic;
			icn_config_en                 : out std_logic;
			config_done                   : out std_logic
		);

	END COMPONENT GLOBAL_CONTROLLER;

	--#################################################################################
	--#################################################################################

	-- C O M P O N E N T   D E C L A R A T I O N
	-- I N T E R C O N N E C T    W R A P P E R   F O R    A 
	-- W E A K L Y    P R O G R A M M A B L E    P R O C E S S O R 

	--#################################################################################
	--#################################################################################


	component wppe_icn_wrapper is
		generic(
			--Ericles:
			N                     : integer                 := 0;
			M                     : integer                 := 0;

			-- cadence translate_off	

			INSTANCE_NAME         : string;

			-- cadence translate_on				
			--*************************
			-- INTERCONNECT Wrapper GENERICs
			--*************************
			ADJACENCY_MATRIX_CTRL : t_adjacency_matrix_ctrl := CUR_DEFAULT_ADJACENCY_MATRIX_CTRL;
			ADJACENCY_MATRIX      : t_adjacency_matrix      := CUR_DEFAULT_ADJACENCY_MATRIX;

			--*************************
			-- Weakly Programmable Processing Element's (WPPE) GENERICs
			--*************************

			WPPE_GENERICS_RECORD  : t_wppe_generics_record  := CUR_DEFAULT_WPPE_GENERICS_RECORD
		);

		port(

			--***********************************
			-- POWER SHUTOFF AUXILIARY SIGNAL
			--***********************************

			ff_start_detection            : in  std_logic;

			--***********************************

			------------------------------------------
			------------------------------------------
			clk, rst                      : in  std_logic;

			vertical_set_to_config        : in  std_logic;
			horizontal_set_to_config      : in  std_logic;
			------------------------------------------
			------------------------------------------
			pc_debug_out                  : out std_logic_vector(
				WPPE_GENERICS_RECORD.ADDR_WIDTH - 1 downto 0);
			------------------------------------------
			------------------------------------------
			input_fifos_write_en          : in  std_logic_vector(
				WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1 downto 0);
			------------------------------------------
			------------------------------------------
			--			ctrl_inputs		  :in	std_logic_vector(
			--							WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS -1 downto  0); -- 1 Bit width
			--			------------------------------------------
			--			ctrl_outputs	  :out std_logic_vector(
			--							WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS -1 downto  0); -- 1 Bit width
			------------------------------------------
			------------------------------------------
			config_mem_data               : in  std_logic_vector(
				WPPE_GENERICS_RECORD.SOURCE_DATA_WIDTH - 1 downto 0);
			------------------------------------------
			------------------------------------------
			north_inputs                  : in  std_logic_vector(NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto 0);
			north_outputs                 : out std_logic_vector(SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto 0);
			------------------------------------------
			------------------------------------------
			south_inputs                  : in  std_logic_vector(SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto 0);
			south_outputs                 : out std_logic_vector(NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto 0);
			------------------------------------------
			------------------------------------------
			east_inputs                   : in  std_logic_vector(EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto 0);
			east_outputs                  : out std_logic_vector(WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto 0);
			------------------------------------------
			------------------------------------------
			west_inputs                   : in  std_logic_vector(WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto 0);
			west_outputs                  : out std_logic_vector(EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto 0);
			------------------------------------------
			------------------------------------------
			--###############################################
			--###### CTRL_ICN INPUTS and OUTPUTS: ###########			
			north_inputs_ctrl             : in  std_logic_vector(NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto 0);
			north_outputs_ctrl            : out std_logic_vector(SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto 0);
			---------------------------------------------------------------
			south_inputs_ctrl             : in  std_logic_vector(SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto 0);
			south_outputs_ctrl            : out std_logic_vector(NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto 0);
			---------------------------------------------------------------
			east_inputs_ctrl              : in  std_logic_vector(EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto 0);
			east_outputs_ctrl             : out std_logic_vector(WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto 0);
			---------------------------------------------------------------
			west_inputs_ctrl              : in  std_logic_vector(WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto 0);
			west_outputs_ctrl             : out std_logic_vector(EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto 0);
			---------------------------------------------------------------

			vliw_config_en                : in std_logic;
			icn_config_en                 : in std_logic;
			common_config_reset           : in std_logic;
			--Ericles Sousa on 16 Dec 2014: setting the configuration_done signal. I will be connected to the top file
			mask                          : in std_logic_vector(CUR_DEFAULT_DATA_WIDTH-1 downto 0);
			fu_sel                        : in std_logic_vector(CUR_DEFAULT_NUM_OF_FUS-1 downto 0); 
			pe_sel                        : in std_logic; 
			error_flag                    : out std_logic;
			error_diagnosis               : out std_logic_vector(MAX_NUM_ERROR_DIAGNOSIS-1 downto 0);
			configuration_done            : out std_logic;
			ctrl_programmable_input_depth : in  t_ctrl_programmable_input_depth;
			en_programmable_fd_depth      : in  t_en_programmable_input_fd_depth;
			programmable_fd_depth         : in  t_programmable_input_fd_depth;
			count_down                    : in  std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto 0);
			enable_tcpa                   : in  std_logic;

			inv_interface_north_in        : in  t_inv_sig;
			inv_interface_west_in         : in  t_inv_sig;
			inv_interface_east_in         : in  t_inv_sig;
			inv_interface_south_in        : in  t_inv_sig;

			inv_interface_north_out       : out t_inv_sig;
			inv_interface_west_out        : out t_inv_sig;
			inv_interface_east_out        : out t_inv_sig;
			inv_interface_south_out       : out t_inv_sig;

			inv_prog_data                 : in  t_prog_data;
			inv_prog_addr                 : in  t_prog_addr;
			inv_prog_wr_en                : in  std_logic;
			inv_start                     : in  std_logic
		);

	end component wppe_icn_wrapper;

	--##########################################
	--###################### ASTRA: ############

	--#################################################################################
	--####################### ASTRA ###################################################
	-- C O M P O N E N T   D E C L A R A T I O N
	-- C O N F I G U R A T I O N      M A N A G E R   
	--#################################################################################

	component configuration_manager is
		generic(

			-- cadence translate_off	
			INSTANCE_NAME : string  := "?";
			-- cadence translate_on

			HEADER_WIDTH  : integer := 5 * CUR_DEFAULT_SOURCE_ADDR_WIDTH + 1 + CUR_DEFAULT_ICN_RATIO_WIDTH + CUR_DEFAULT_VLIW_RATIO_WIDTH + CUR_DEFAULT_NUM_WPPE_VERTICAL + CUR_DEFAULT_NUM_WPPE_HORIZONTAL + CUR_DEFAULT_COUNT_DOWN_WIDTH + CUR_DEFAULT_DOMAIN_TYPE_WIDTH;
			--###########################################################################
			-- Bus protocol parameters, do not add to or delete
			--###########################################################################
			C_AWIDTH      : integer := 32;
			C_DWIDTH      : integer := 32;
			C_NUM_CE      : integer := 16
		--###########################################################################
		);

		port(

			--***********************************
			-- POWER SHUTOFF AUXILIARY SIGNAL
			--***********************************

			ff_start_detection : out std_logic;

			--***********************************

			clk                : in  std_logic;
			rst                : in  std_logic;

			dtab_data_daddr_in : in  std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
			offset_in          : in  std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
			dnumber_in         : in  std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
			conf_type_in       : in  std_logic_vector(CUR_DEFAULT_CONFIG_TYPE_WIDTH - 1 downto 0);
			source_data_in     : in  std_logic_vector(CUR_DEFAULT_SOURCE_DATA_WIDTH - 1 downto 0);
			--source_load_data_in	: in  std_logic_vector(CUR_DEFAULT_SOURCE_DATA_WIDTH-1  downto 0);
			conf_done_in       : in  std_logic;
			conf_en_in         : in  std_logic;

			ready_out          : out std_logic;

			count_down         : out t_count_down;
			--source_load_data_out	: out  std_logic_vector(CUR_DEFAULT_SOURCE_DATA_WIDTH-1  downto 0);
			dtab_addr_dnumber  : out std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
			dtab_data_daddr    : out std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
			--source_we					: out  std_logic;
			dtab_we            : out std_logic;
			source_select      : out std_logic_vector(CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH - 1 downto 0);
			source_addr        : out std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
			--###########################################################################
			-- OPB  BUS  INTERFACE SIGNALS
			--###########################################################################
			GlobCtrl_BE        : out std_logic_vector(0 to C_DWIDTH / 8 - 1);
			GlobCtrl_Data      : out std_logic_vector(0 to C_DWIDTH - 1);
			GlobCtrl_WrCE      : out std_logic_vector(0 to C_NUM_CE - 1)
		--###########################################################################
		);
	end component configuration_manager;

	--#################################################################################
	--####################### ASTRA ###################################################
	-- C O M P O N E N T   D E C L A R A T I O N
	-- D O M A I N    A D D R E S S    M E M O R Y   
	--#################################################################################

	component domain_address_memory is
		generic(

			-- cadence translate_off	
			INSTANCE_NAME : string   := "?";
			-- cadence translate_on

			MEM_SIZE      : positive := CUR_DEFAULT_MAX_DOMAIN_NUM;
			DATA_WIDTH    : positive := CUR_DEFAULT_SOURCE_ADDR_WIDTH;
			ADDR_WIDTH    : positive := CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH
		);

		port(
			clk   : in  std_logic;
			we    : in  std_logic;
			rst   : in  std_logic;
			addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			d_in  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			d_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component domain_address_memory;

	--#################################################################################
	--####################### ASTRA ###################################################
	-- C O M P O N E N T   D E C L A R A T I O N
	-- W P P E   M U X   
	--#################################################################################

	component wppe_multiplexer is
		generic(
			-- cadence translate_off
			INSTANCE_NAME     : string                 := "?";
			-- cadence translate_on

			INPUT_DATA_WIDTH  : positive range 1 to 64 := CUR_DEFAULT_SOURCE_ADDR_WIDTH; --16;
			OUTPUT_DATA_WIDTH : positive range 1 to 64 := CUR_DEFAULT_SOURCE_ADDR_WIDTH; --32;
			SEL_WIDTH         : positive range 1 to 16 := CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH; --3;		
			NUM_OF_INPUTS     : positive range 1 to 64 := CUR_DEFAULT_SOURCE_MUX_NUM_OF_INPUTS --8	

		);

		port(
			data_inputs : in  std_logic_vector(INPUT_DATA_WIDTH * NUM_OF_INPUTS - 1 downto 0);
			sel         : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			output      : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
		);

	end component;

--#################################################################################
--####################### ASTRA ###################################################
-- C O M P O N E N T   D E C L A R A T I O N
-- I M A G E   L O A D E R S  
--#################################################################################

--COMPONENT input_image_loader is
--	port(
--		clk       :in std_logic;
--		rst       :in std_logic;
--		algo_type :in std_logic;
--		re        :out std_logic;
--		addr      :out std_logic_vector(16 downto 0));  
--END COMPONENT;
--
--COMPONENT output_image_loader is
--	port(
--		clk       :in std_logic;
--		rst       :in std_logic;
--		algo_type  :in std_logic;
--		we        :out std_logic;
--		addr      :out std_logic_vector(16 downto 0));
--END COMPONENT;

--signal wppa_bus_input_interface  		 :t_wppa_bus_input_interface; 
--signal wppa_bus_output_interface 		 :t_wppa_bus_output_interface; 
---- Data											
--signal wppa_data_input           		 :t_wppa_data_input_interface; 
--signal wppa_data_output          		 :t_wppa_data_output_interface; 
---- Control										
--signal wppa_ctrl_input           		 :t_wppa_ctrl_input_interface; 
--signal wppa_ctrl_output          		 :t_wppa_ctrl_output_interface; 
---- Memory										
--signal wppa_memory_input_interface  	 :t_wppa_memory_input_interface; 
--signal wppa_memory_output_interface 	 :t_wppa_memory_output_interface; 
---- Configuration								
--signal wppa_config_interface      		 :t_wppa_config_input_interface;

--### ARCHITECTURE BEGIN ###

--#####################################
--#####################################
BEGIN                                   --################################
	--#####################################
	--#####################################


	-- shravan: 24Aug2012 : increasing bit-widths of fields in invasion command
	--inv_border <= "0000" & "0000" & "0000" & "0011";
	inv_border <= "00000" & "00000" & "00000" & "00011";

	inv_prog_data  <= icp_program_interface(PROG_ADDR_WIDTH + PROG_DATA_WIDTH + 1 downto PROG_ADDR_WIDTH + 2);
	inv_prog_addr  <= icp_program_interface(PROG_ADDR_WIDTH + 1 downto 2);
	inv_prog_wr_en <= icp_program_interface(1);
	inv_start      <= icp_program_interface(0);

	zero_signal <= '0';

	----*** ASTRA
	--##############################################################################

--	NEG_clk_gating_select <= NOT clk_gating_select;
--
--	CLK_GATING : if CLOCK_GATING generate
--		clk_gated_clk <= clk_gating_clk;
--	end generate;
--
--	NO_CLK_GATING : if not CLOCK_GATING generate
--		clk_gated_clk <= clk;
--	end generate;

	PLB_CONTROLLER_INST : plb_controller
		port map(
			clk           => clk,
			rst           => rst,
			Bus2IP_Addr   => wppa_bus_input_interface.Bus2IP_Addr,
			Bus2IP_Data   => wppa_bus_input_interface.Bus2IP_Data,
			Bus2IP_BE     => wppa_bus_input_interface.Bus2IP_BE,
			Bus2IP_RdCE   => wppa_bus_input_interface.Bus2IP_RdCE,
			Bus2IP_WrCE   => wppa_bus_input_interface.Bus2IP_WrCE,
			--      IP2Bus_Data   => IP2Bus_Data,

			conf_en_out   => PC2CM_conf_en,
			offset_out    => PC2CM_offset,
			dnumber_out   => PC2CM_dnumber,
			conf_type_out => PC2CM_conf_type
		);

	--conf_en <= conf_en_in;

	--== SOURCE_MEM_MUX-SELECT = 0 => DOMAIN_TAB
	--source_mux_data_inputs(CUR_DEFAULT_SOURCE_ADDR_WIDTH-1 downto 0) <= dtab_out;

	--== SOURCE_MEM_MUX-SELECT = 1 => GLOBAL_CONTROLLER
	source_mux_data_inputs(CUR_DEFAULT_SOURCE_ADDR_WIDTH * 2 - 1 downto CUR_DEFAULT_SOURCE_ADDR_WIDTH) <= GC_source_addr;

	--== SOURCE_MEM_MUX-SELECT = 2 => CONFIGURATION_MANAGER
	source_mux_data_inputs(CUR_DEFAULT_SOURCE_ADDR_WIDTH * 3 - 1 downto CUR_DEFAULT_SOURCE_ADDR_WIDTH * 2) <= CM_source_addr;

	--#################################################################################
	--  INternal_TOP_north_in(7 downto 0)  <= wppa_memory_input_interface.from_input_img_mem_data;
	--  INternal_TOP_north_in(15 downto 8) <= (others => '0');
	--  wppa_memory_output_interface.to_output_img_mem_data <= INternal_TOP_north_out(47 downto 40);

	----*** astra 
	--set_debug_regs :process(clk,rst)
	--
	--begin
	--
	--if clk'event and  clk = '1' then
	--
	--	if rst = '1' then
	--
	--		internal_debug_registers <= (others => '0');
	--
	--	else
	--
	internal_debug_registers(wppa_generics.C_DWIDTH - 1 downto 0)                          <= wppa_data_input.EXTERNAL_TOP_north_in(wppa_generics.C_DWIDTH - 1 downto 0);
	internal_debug_registers(2 * wppa_generics.C_DWIDTH - 1 downto wppa_generics.C_DWIDTH) <= INternal_TOP_north_out(wppa_generics.C_DWIDTH - 1 downto 0);
	--	end if;
	--
	--end if;
	--
	--end process;

	--USER logic implementation added here


	--====================================================================================
	-- CONNECT THE EXTERNAL VECTOR SIGNALS WITH INternal_... ARRAY'ed SIGNALS
	--====================================================================================

	INternal_TOP_north_in                   <= wppa_data_input.EXTERNAL_TOP_north_in;
	wppa_data_output.EXTERNAL_TOP_north_out <= INternal_TOP_north_out;

	INternal_BOTTOM_south_in                   <= wppa_data_input.EXTERNAL_BOTTOM_south_in;
	wppa_data_output.EXTERNAL_BOTTOM_south_out <= INternal_BOTTOM_south_out;

	INternal_LEFT_west_in                   <= wppa_data_input.EXTERNAL_LEFT_west_in;
	wppa_data_output.EXTERNAL_LEFT_west_out <= INternal_LEFT_west_out;

	INternal_RIGHT_east_in                   <= wppa_data_input.EXTERNAL_RIGHT_east_in;
	wppa_data_output.EXTERNAL_RIGHT_east_out <= INternal_RIGHT_east_out;

	--################
	--### CTRL_ICN ###	
	INternal_TOP_north_in_ctrl                   <= wppa_ctrl_input.EXTERNAL_TOP_north_in_ctrl;
	wppa_ctrl_output.EXTERNAL_TOP_north_out_ctrl <= INternal_TOP_north_out_ctrl;

	INternal_BOTTOM_south_in_ctrl                   <= wppa_ctrl_input.EXTERNAL_BOTTOM_south_in_ctrl;
	wppa_ctrl_output.EXTERNAL_BOTTOM_south_out_ctrl <= INternal_BOTTOM_south_out_ctrl;

	INternal_LEFT_west_in_ctrl                   <= wppa_ctrl_input.EXTERNAL_LEFT_west_in_ctrl;
	wppa_ctrl_output.EXTERNAL_LEFT_west_out_ctrl <= INternal_LEFT_west_out_ctrl;

	INternal_RIGHT_east_in_ctrl                   <= wppa_ctrl_input.EXTERNAL_RIGHT_east_in_ctrl;
	wppa_ctrl_output.EXTERNAL_RIGHT_east_out_ctrl <= INternal_RIGHT_east_out_ctrl;

	--################

	--##########################################
	--###################### ASTRA: ############

	--#################################################################################
	--####################### ASTRA ###################################################
	-- C O M P O N E N T   I N S T A N T I A T I O N
	-- C O N F I G U R A T I O N      M A N A G E R   
	--#################################################################################


	CONFIG_MANAGER : configuration_manager
		-- cadence translate_off	
		generic map(
			INSTANCE_NAME => TOP_LEVEL_INSTANCE_NAME & "/CONFIG_MANAGER"
		)
		-- cadence translate_on
		port map(
			--***********************************
			-- POWER SHUTOFF AUXILIARY SIGNAL
			--***********************************

			ff_start_detection => FF_START_DETECTION_BUS,

			--***********************************		
			clk                => clk, --clk_gated_clk, --clk,
			rst                => rst,
			dtab_data_daddr_in => dtab_out,
			offset_in          => PC2CM_offset,
			dnumber_in         => PC2CM_dnumber,
			conf_type_in       => PC2CM_conf_type,
			source_data_in     => source_data,
			conf_done_in       => conf_done,
			conf_en_in         => PC2CM_conf_en, --conf_en_in,

			ready_out          => ready_out,
			count_down         => count_down,
			dtab_addr_dnumber  => dtab_addr,
			dtab_data_daddr    => dtab_data,
			dtab_we            => dtab_we,
			source_select      => source_select,
			source_addr        => CM_source_addr,
			GlobCtrl_BE        => GlobCtrl_BE,
			GlobCtrl_Data      => GlobCtrl_Data,
			GlobCtrl_WrCE      => GlobCtrl_WrCE
		);

	--#################################################################################
	--####################### ASTRA ###################################################
	-- C O M P O N E N T   I N S T A N T I A T I O N
	-- D O M A I N    A D D R E S S    M E M O R Y   
	--#################################################################################

	DTAB_MEMORY : domain_address_memory
		-- cadence translate_off
		generic map(
			INSTANCE_NAME => TOP_LEVEL_INSTANCE_NAME & "/DTAB_MEMORY"
		)
		-- cadence translate_on
		port map(
			clk   => clk, --clk_gated_clk,     --clk,
			rst   => rst,
			we    => dtab_we,
			addr  => dtab_addr,
			d_in  => dtab_data,
			d_out => dtab_out
		);

	--#################################################################################

--	CLK_GATING_MUX_GEN : if CLOCK_GATING generate

		--	CLK_GATING_MUX: mux_2_1_1bit
		---- cadence translate_off	
		-- 	  generic map(
		--
		--		   INSTANCE_NAME => TOP_LEVEL_INSTANCE_NAME & "/CLK_GATING_MUX"
		--
		--	   )
		---- cadence translate_on	   
		--		port map(
		--		
		--	      input0 => clk,
		--	      input1 => '0',
		--	      sel         => clk_gating_select,
		--			output      => clk_gating_clk
		--	);

--		CLK_GATING_MUX : my_CG_MOD
--			port map(
--				ck_in  => clk,
--				enable => NEG_clk_gating_select, --not clk_gating_select,
--				test   => zero_signal,  --'0',
--				ck_out => clk_gating_clk
--			);
--
--	END GENERATE CLK_GATING_MUX_GEN;

	--####################### ASTRA ###################################################
	-- C O M P O N E N T   I N S T A N T I A T I O N
	-- W P P E   M U X   
	--#################################################################################

	SRC_MEM_MUX : wppe_multiplexer
		generic map(

			-- cadence translate_off	
			INSTANCE_NAME     => TOP_LEVEL_INSTANCE_NAME & "/SRC_MEM_MUX",
			-- cadence translate_on

			INPUT_DATA_WIDTH  => wppa_generics.SOURCE_ADDR_WIDTH,
			OUTPUT_DATA_WIDTH => wppa_generics.SOURCE_ADDR_WIDTH,
			SEL_WIDTH         => CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH,
			NUM_OF_INPUTS     => CUR_DEFAULT_SOURCE_MUX_NUM_OF_INPUTS
		)
		port map(
			data_inputs => source_mux_data_inputs,
			sel         => source_select,
			output      => source_mux_output
		);

	--#################################################################################
	--####################### ASTRA ###################################################
	-- C O M P O N E N T   I N S T A N T I A T I O N
	-- I M A G E   L O A D E R S  
	--#################################################################################

	--output_img_loader: output_image_loader
	--	port map(
	--		clk       => clk,--clk_tmp,
	--		rst       => common_config_reset, --rst, --
	--		--algo_type => '1', -- EDGE DETECTION
	--		algo_type => algo_type,
	--		we        => wppa_memory_output_interface.to_output_img_mem_we,
	--		addr      => wppa_memory_output_interface.to_output_img_mem_addr);
	--      
	--input_img_loader: input_image_loader
	--	port map(
	--		clk       => clk, --clk_tmp,
	--		rst       => common_config_reset, --rst, --
	--		--algo_type => '1', -- EDGE DETECTION
	--		algo_type => algo_type,
	--		re        => wppa_memory_output_interface.to_input_img_mem_re,
	--		addr      => wppa_memory_output_interface.to_input_img_mem_addr);     

	--###################### ASTRA #############
	--##########################################


	--#################################################################################
	--#################################################################################

	-- C O M P O N E N T   I N S T A N T I O A T I O N
	-- G L O B A L  C O N F I G U R A T I O N   M E M O R Y

	--#################################################################################
	--#################################################################################

	--PPC_CHECK_F_GLB_CFG_MEMORY :IF not CONFIG_PPC GENERATE

	--GLOBAL_CONFIGURATION_MEMORY :config_memory

	--	generic map(

	-- cadence translate_off	

	--			INSTANCE_NAME => TOP_LEVEL_INSTANCE_NAME & "/GLOBAL_CONFIGURATION_MEMORY",

	-- cadence translate_on				
	--			MEM_SIZE   	=> wppa_generics.SOURCE_MEM_SIZE,
	--			DATA_WIDTH	=> wppa_generics.SOURCE_DATA_WIDTH,
	--			ADDR_WIDTH	=> wppa_generics.SOURCE_ADDR_WIDTH
	--	)

	--	port map(

	--		addr  => source_mux_output,-- GLOBAL_config_mem_addr,
	--		d_out => source_data,--config_data_out,
	--		d_in  => "00000000000000000000000000000000", --(others => '0'),
	--		we		=> '0',

	--		clk   => clk, --clk_gated_clk, --clk,
	--		rst   => rst,
	--		cfg_reset => common_config_reset


	--		);

	--END GENERATE PPC_CHECK_F_GLB_CFG_MEMORY;		
	--Ericles Sousa on 19 Dec 2014. Fixing the index for "to_input_mem_addr".
	wppa_memory_output_interface.to_input_mem_addr(31 downto CUR_DEFAULT_SOURCE_ADDR_WIDTH)    <= (others => '0');
	wppa_memory_output_interface.to_input_mem_addr(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0) <= source_mux_output;
	source_data                                                                                <= wppa_memory_input_interface.from_input_mem_data;

	PPC_CHECK_GLB_CFG_MEMORY : IF CONFIG_PPC GENERATE
		GLOBAL_CONFIGURATION_MEMORY : config_memory
			generic map(

				-- cadence translate_off	

				INSTANCE_NAME => TOP_LEVEL_INSTANCE_NAME & "/GLOBAL_CONFIGURATION_MEMORY",

				-- cadence translate_on				
				MEM_SIZE      => wppa_generics.SOURCE_MEM_SIZE,
				DATA_WIDTH    => wppa_generics.SOURCE_DATA_WIDTH,
				ADDR_WIDTH    => wppa_generics.SOURCE_ADDR_WIDTH
			)
			port map(
				clk       => clk, --clk_gated_clk, --clk,
				rst       => rst,
				cfg_reset => common_config_reset,
				addr      => GLOBAL_config_mem_addr,
				d_out     => config_data_out,
				d_in      => "00000000000000000000000000000000",
				we        => '0'
			);

	end GENERATE PPC_CHECK_GLB_CFG_MEMORY;

	--#################################################################################
	--#################################################################################

	-- C O M P O N E N T   I N S T A N T I A T I O N
	-- G L O B A L   C O N F I G U R A T I O N   C O N T R O L L E R

	--#################################################################################
	--#################################################################################

	PPC_CHECK_F_GLB_CFG_CONTROLLER : IF not CONFIG_PPC GENERATE
		GLOBAL_CONFIG_CONTROLLER : GLOBAL_CONTROLLER
			generic map(

				-- cadence translate_off

				INSTANCE_NAME     => TOP_LEVEL_INSTANCE_NAME & "/GLOBAL_CONFIG_CONTROLLER",

				-- cadence translate_on	 			
				C_AWIDTH          => wppa_generics.C_AWIDTH,
				C_DWIDTH          => wppa_generics.C_DWIDTH,
				C_NUM_CE          => wppa_generics.C_NUM_CE,

				--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

				------------------------------------------					
				-- VERTICAL number of WPPEs in the array
				N                 => wppa_generics.N,
				------------------------------------------
				-- HORIZONTAL number of WPPEs in the array
				M                 => wppa_generics.M,
				------------------------------------------					

				--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				-- Generic variables of the OCB bus to external processor core

				BUS_ADDR_WIDTH    => wppa_generics.BUS_ADDR_WIDTH,
				BUS_DATA_WIDTH    => wppa_generics.BUS_DATA_WIDTH,
				SOURCE_ADDR_WIDTH => wppa_generics.SOURCE_ADDR_WIDTH,
				SOURCE_DATA_WIDTH => wppa_generics.SOURCE_DATA_WIDTH
			)
			port map(
				Bus2IP_Addr                   => wppa_bus_input_interface.Bus2IP_Addr,
				Bus2IP_Data                   => GlobCtrl_Data, --Bus2IP_Data,      
				Bus2IP_BE                     => GlobCtrl_BE, --Bus2IP_BE,        
				Bus2IP_RdCE                   => wppa_bus_input_interface.Bus2IP_RdCE,
				Bus2IP_WrCE                   => GlobCtrl_WrCE, --Bus2IP_WrCE,      
				IP2Bus_Data                   => wppa_bus_output_interface.IP2Bus_Data,
				debug_registers               => internal_debug_registers,
				clk                           => clk, --clk_gated_clk, --clk,
				rst                           => rst,

				--              -- OCB Bus signals to external processor core
				--              ADDR_I => BUS_ADDR_I,
				--              DATA_I => BUS_DATA_I,
				--              DATA_O => BUS_DATA_O,
				--              WE_I     => BUS_WE_I,
				--
				-- (Re-)Configuration-enable bit vector
				-- vertical
				CONFIGURATION_MASK_VERTICAL   => internal_conf_mask_horizontal, --internal_conf_mask_vertical,

				-- (Re-)Configuration-enable bit vector
				-- horizontal
				CONFIGURATION_MASK_HORIZONTAL => internal_conf_mask_vertical, --internal_conf_mask_horizontal,

				source_data_in                => source_data, --config_data_out,
				source_data_out               => GLOBAL_config_mem_data,
				-- Address signal to external global configuration memory
				source_addr_out               => GC_source_addr, --GLOBAL_config_mem_addr,

				ALGO_TYPE_out                 => algo_type,
				common_config_reset           => common_config_reset,
				vliw_config_en                => vliw_config_en,
				icn_config_en                 => icn_config_en,
				config_done                   => conf_done
			);

	END GENERATE PPC_CHECK_F_GLB_CFG_CONTROLLER;

	PPC_CHECK_GLB_CFG_CONTROLLER : IF CONFIG_PPC GENERATE
		GLOBAL_CONFIG_CONTROLLER : GLOBAL_CONTROLLER
			generic map(

				-- cadence translate_off

				INSTANCE_NAME     => TOP_LEVEL_INSTANCE_NAME & "/GLOBAL_CONFIG_CONTROLLER",

				-- cadence translate_on                         
				C_AWIDTH          => wppa_generics.C_AWIDTH,
				C_DWIDTH          => wppa_generics.C_DWIDTH,
				C_NUM_CE          => wppa_generics.C_NUM_CE,

				--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

				------------------------------------------                                      
				-- VERTICAL number of WPPEs in the array
				N                 => wppa_generics.N,
				------------------------------------------
				-- HORIZONTAL number of WPPEs in the array
				M                 => wppa_generics.M,
				------------------------------------------                                      

				--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				-- Generic variables of the OCB bus to external processor core

				BUS_ADDR_WIDTH    => wppa_generics.BUS_ADDR_WIDTH,
				BUS_DATA_WIDTH    => wppa_generics.BUS_DATA_WIDTH,
				SOURCE_ADDR_WIDTH => wppa_generics.SOURCE_ADDR_WIDTH,
				SOURCE_DATA_WIDTH => wppa_generics.SOURCE_DATA_WIDTH
			)
			port map(
				Bus2IP_Addr                   => wppa_bus_input_interface.Bus2IP_Addr,
				Bus2IP_Data                   => wppa_bus_input_interface.Bus2IP_Data,
				Bus2IP_BE                     => wppa_bus_input_interface.Bus2IP_BE,
				Bus2IP_RdCE                   => wppa_bus_input_interface.Bus2IP_RdCE,
				Bus2IP_WrCE                   => wppa_bus_input_interface.Bus2IP_WrCE,
				IP2Bus_Data                   => wppa_bus_output_interface.IP2Bus_Data,
				debug_registers               => internal_debug_registers,
				clk                           => clk, --clk_gated_clk, --clk,
				rst                           => rst,

				--              -- OCB Bus signals to external processor core
				--              ADDR_I => BUS_ADDR_I,
				--              DATA_I => BUS_DATA_I,
				--              DATA_O => BUS_DATA_O,
				--              WE_I     => BUS_WE_I,
				--
				-- (Re-)Configuration-enable bit vector
				-- vertical
				CONFIGURATION_MASK_VERTICAL   => internal_conf_mask_horizontal, --internal_conf_mask_vertical,

				-- (Re-)Configuration-enable bit vector
				-- horizontal
				CONFIGURATION_MASK_HORIZONTAL => internal_conf_mask_vertical, --internal_conf_mask_horizontal,

				source_data_in                => config_data_out,
				source_data_out               => GLOBAL_config_mem_data,
				-- Address signal to external global configuration memory
				source_addr_out               => GLOBAL_config_mem_addr,
				ALGO_TYPE_out                 => algo_type,
				vliw_config_en                => vliw_config_en,
				icn_config_en                 => icn_config_en,
				common_config_reset           => common_config_reset
			);

	END GENERATE PPC_CHECK_GLB_CFG_CONTROLLER;

	--#################################################################################
	--#################################################################################

	-- C O M P O N E N T   I N S T A N T I A T I O N S
	-- I N T E R C O N N E C T    W R A P P E R   F O R    A 
	-- W E A K L Y    P R O G R A M M A B L E    P R O C E S S O R 

	--#################################################################################
	--#################################################################################

	--====================================================================================
	--====================================================================================
	ROW_WPPE_GENERATION_LOOP : FOR i in 1 to wppa_generics.N GENERATE
		COLUMN_WPPE_GENERATION_LOOP : FOR j in 1 to wppa_generics.M GENERATE

			------------------------------------
			-- CHECK whether WPPE is 
			-- in the FIRST ROW ==> FRC
			------------------------------------
			FIRST_ROW_CHECK : IF i = 1 GENERATE

				--**********************************
				-- CHECK whether WPPE is 
				-- in the FIRST C O L U M N
				--**********************************
				FRC_FIRST_COLUMN_CHECK : IF j = 1 GENERATE
					first_row_first_column_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,

							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/first_row_first_column_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on 
							--ADJACENCY_MATRIX                => ADJ_MATRIX_ARRAY(i, j),

							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(

							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							---------------------------------------------------
							north_inputs                  => INternal_TOP_north_in( -- "EXTERNAL TOP CONNECTION"
								j * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto (j - 1) * NORTH_INPUT_WIDTH * NORTH_PIN_NUM),
							north_outputs                 => INternal_TOP_north_out( -- "EXTERNAL TOP CONNECTION"
								j * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto (j - 1) * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs                  => INTERNAL_NORTH_OUT_south_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"                                                                                                                                                        
							south_outputs                 => INTERNAL_SOUTH_OUT_north_in_connections(i,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs                   => INTERNAL_WEST_OUT_east_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs                  => INTERNAL_EAST_OUT_west_in_connections(i,
								j),
							---------------------------------------------------
							west_inputs                   => INternal_LEFT_west_in( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto (i - 1) * WEST_INPUT_WIDTH * WEST_PIN_NUM),
							west_outputs                  => INTERNAL_LEFT_west_out( -- "EXTERNAL CONNCECTION"
								i * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto (i - 1) * EAST_INPUT_WIDTH * EAST_PIN_NUM),
							---------------------------------------------------

							--#################
							--### ICN_CTRL: ###
							north_inputs_ctrl             => INternal_TOP_north_in_ctrl( -- "EXTERNAL TOP CONNECTION"
								j * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto (j - 1) * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL),
							north_outputs_ctrl            => INternal_TOP_north_out_ctrl( -- "EXTERNAL TOP CONNECTION"
								j * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto (j - 1) * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs_ctrl             => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"                                                                                                                                                        
							south_outputs_ctrl            => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs_ctrl              => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs_ctrl             => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							west_inputs_ctrl              => INternal_LEFT_west_in_ctrl( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto (i - 1) * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL),
							west_outputs_ctrl             => INTERNAL_LEFT_west_out_ctrl( -- "EXTERNAL CONNCECTION"
								i * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto (i - 1) * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL),

							--#################
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => open,
							inv_interface_west_out        => invasion_output,
							inv_interface_east_out        => inv_E_out_W_in(i,
								j),
							inv_interface_south_out       => inv_S_out_N_in(i,
								j),
							inv_interface_north_in        => inv_border,
							inv_interface_west_in         => invasion_input,
							inv_interface_east_in         => inv_W_out_E_in(i,
								j),
							inv_interface_south_in        => inv_N_out_S_in(i,
								j),
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE FRC_FIRST_COLUMN_CHECK;
				--**********************************
				-- CHECK whether WPPE is 
				-- in the LAST C O L U M N
				--**********************************
				FRC_LAST_COLUMN_CHECK : IF j = wppa_generics.M GENERATE
					first_row_last_column_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,
							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/first_row_last_column_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on                                                                                 
							--ADJACENCY_MATRIX                => ADJ_MATRIX_ARRAY(i, j),

							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(
							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							north_inputs                  => INternal_TOP_north_in( -- "EXTERNAL TOP CONNECTION"
								j * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto (j - 1) * NORTH_INPUT_WIDTH * NORTH_PIN_NUM),
							north_outputs                 => INternal_TOP_north_out( -- "EXTERNAL TOP CONNECTION"
								j * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto (j - 1) * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs                  => INTERNAL_NORTH_OUT_south_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"                                                                                                                                                        
							south_outputs                 => INTERNAL_SOUTH_OUT_north_in_connections(i,
								j),
							---------------------------------------------------
							east_inputs                   => INternal_RIGHT_east_in( -- "EXTERNAL RIGHT CONNECTION"
								i * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto (i - 1) * EAST_INPUT_WIDTH * EAST_PIN_NUM),
							east_outputs                  => INternal_RIGHT_east_out( -- "EXTERNAL RIGHT CONNECTION"
								i * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto (i - 1) * WEST_INPUT_WIDTH * WEST_PIN_NUM),
							---------------------------------------------------
							-- "GET THE WEST INPUTS from (i, J-1) WPPE" !!!

							west_inputs                   => INTERNAL_EAST_OUT_west_in_connections(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS to (i, J-1) WPPE" !!!

							west_outputs                  => INTERNAL_WEST_OUT_east_in_connections(i,
								j - 1),
							---------------------------------------------------
							--#################
							--### ICN_CTRL: ###
							north_inputs_ctrl             => INternal_TOP_north_in_ctrl( -- "EXTERNAL TOP CONNECTION"
								j * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto (j - 1) * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL),
							north_outputs_ctrl            => INternal_TOP_north_out_ctrl( -- "EXTERNAL TOP CONNECTION"
								j * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto (j - 1) * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs_ctrl             => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"                                                                                                                                                        
							south_outputs_ctrl            => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							east_inputs_ctrl              => INternal_RIGHT_east_in_ctrl( -- "EXTERNAL RIGHT CONNECTION"
								i * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto (i - 1) * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL),
							east_outputs_ctrl             => INternal_RIGHT_east_out_ctrl( -- "EXTERNAL RIGHT CONNECTION"
								i * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto (i - 1) * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL),
							---------------------------------------------------
							-- "GET THE WEST INPUTS from (i, J-1) WPPE" !!!

							west_inputs_ctrl              => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS to (i, J-1) WPPE" !!!

							west_outputs_ctrl             => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j - 1),
							---------------------------------------------------                                                                             

							--#################
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => open,
							inv_interface_west_out        => inv_W_out_E_in(i,
								j - 1),
							inv_interface_east_out        => open,
							inv_interface_south_out       => inv_S_out_N_in(i,
								j),
							inv_interface_north_in        => inv_border,
							inv_interface_west_in         => inv_E_out_W_in(i,
								j - 1),
							inv_interface_east_in         => inv_border,
							inv_interface_south_in        => inv_N_out_S_in(i,
								j),
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE FRC_LAST_COLUMN_CHECK;
				--**********************************
				-- CHECK whether WPPE is 
				-- WHETER in the FIRST
				-- NOR in the LAST C O L U M N
				--**********************************
				FRC_NOT_FIRST_NOT_LAST_COLUMN_CHECK : IF j > 1 AND j < wppa_generics.M GENERATE
					first_row_middle_columns_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,
							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/first_row_middle_columns_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on                                                                                 
							--ADJACENCY_MATRIX                => ADJ_MATRIX_ARRAY(i, j),

							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(
							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							---------------------------------------------------
							north_inputs                  => INternal_TOP_north_in( -- "EXTERNAL TOP CONNECTION"
								j * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto (j - 1) * NORTH_INPUT_WIDTH * NORTH_PIN_NUM),
							north_outputs                 => INternal_TOP_north_out( -- "EXTERNAL TOP CONNECTION"
								j * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto (j - 1) * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs                  => INTERNAL_NORTH_OUT_south_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"                                                                                                                                                        
							south_outputs                 => INTERNAL_SOUTH_OUT_north_in_connections(i,
								j),
							---------------------------------------------------
							east_inputs                   => INTERNAL_WEST_OUT_east_in_connections(i,
								j),
							east_outputs                  => INTERNAL_EAST_OUT_west_in_connections(i,
								j),
							---------------------------------------------------
							-- "GET THE WEST INPUTS from (i, J-1) WPPE" !!!

							west_inputs                   => INTERNAL_EAST_OUT_west_in_connections(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS to (i, J-1) WPPE" !!!

							west_outputs                  => INTERNAL_WEST_OUT_east_in_connections(i,
								j - 1),
							---------------------------------------------------

							--#################
							--### ICN_CTRL: ###
							north_inputs_ctrl             => INternal_TOP_north_in_ctrl( -- "EXTERNAL TOP CONNECTION"
								j * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto (j - 1) * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL),
							north_outputs_ctrl            => INternal_TOP_north_out_ctrl( -- "EXTERNAL TOP CONNECTION"
								j * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto (j - 1) * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs_ctrl             => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"                                                                                                                                                        
							south_outputs_ctrl            => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							east_inputs_ctrl              => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j),
							east_outputs_ctrl             => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							-- "GET THE WEST INPUTS from (i, J-1) WPPE" !!!

							west_inputs_ctrl              => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS to (i, J-1) WPPE" !!!

							west_outputs_ctrl             => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j - 1),
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => open,
							inv_interface_west_out        => inv_W_out_E_in(i,
								j - 1),
							inv_interface_east_out        => inv_E_out_W_in(i,
								j),
							inv_interface_south_out       => inv_S_out_N_in(i,
								j),
							inv_interface_north_in        => inv_border,
							inv_interface_west_in         => inv_E_out_W_in(i,
								j - 1),
							inv_interface_east_in         => inv_W_out_E_in(i,
								j),
							inv_interface_south_in        => inv_N_out_S_in(i,
								j),
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE FRC_NOT_FIRST_NOT_LAST_COLUMN_CHECK;
			--**********************************
			--**********************************
			END GENERATE FIRST_ROW_CHECK;
			------------------------------------
			-- CHECK whether WPPE is 
			-- in the LAST ROW ==> LRC
			------------------------------------
			LAST_ROW_CHECK : IF i = wppa_generics.N GENERATE
				--**********************************
				-- CHECK whether WPPE is 
				-- in the FIRST C O L U M N
				--**********************************
				LRC_FIRST_COLUMN_CHECK : IF j = 1 GENERATE
					last_row_first_column_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,
							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/last_row_first_column_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on                                                                                 
							--ADJACENCY_MATRIX                => ADJ_MATRIX_ARRAY(i, j),

							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(
							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							---------------------------------------------------
							-- "GET THE NORTH INPUTS from (I-1, J) WPPE" !!!

							north_inputs                  => INTERNAL_SOUTH_OUT_north_in_connections(i - 1,
								j),
							-- "SEND THE NORTH INPUTS to (I-1, J) WPPE" !!!

							north_outputs                 => INTERNAL_NORTH_OUT_south_in_connections(i - 1,
								j),
							---------------------------------------------------
							south_inputs                  => INternal_BOTTOM_south_in( -- "EXTERNAL CONNECTION"
								j * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto (j - 1) * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM),
							south_outputs                 => INternal_BOTTOM_south_out( -- "EXTERNAL_CONNECTION"
								j * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto (j - 1) * NORTH_INPUT_WIDTH * NORTH_PIN_NUM),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs                   => INTERNAL_WEST_OUT_east_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs                  => INTERNAL_EAST_OUT_west_in_connections(i,
								j),
							---------------------------------------------------
							west_inputs                   => INternal_LEFT_west_in( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto (i - 1) * WEST_INPUT_WIDTH * WEST_PIN_NUM),
							west_outputs                  => INternal_LEFT_west_out( -- "EXTERNAL CONNECTION"
								i * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto (i - 1) * EAST_INPUT_WIDTH * EAST_PIN_NUM),
							---------------------------------------------------
							--#################
							--### ICN_CTRL: ###
							-- "GET THE NORTH INPUTS from (I-1, J) WPPE" !!!

							north_inputs_ctrl             => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i - 1,
								j),
							-- "SEND THE NORTH INPUTS to (I-1, J) WPPE" !!!

							north_outputs_ctrl            => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i - 1,
								j),
							---------------------------------------------------
							south_inputs_ctrl             => INternal_BOTTOM_south_in_ctrl( -- "EXTERNAL CONNECTION"
								j * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto (j - 1) * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL),
							south_outputs_ctrl            => INternal_BOTTOM_south_out_ctrl( -- "EXTERNAL_CONNECTION"
								j * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto (j - 1) * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs_ctrl              => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs_ctrl             => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							west_inputs_ctrl              => INternal_LEFT_west_in_ctrl( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto (i - 1) * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL),
							west_outputs_ctrl             => INternal_LEFT_west_out_ctrl( -- "EXTERNAL CONNECTION"
								i * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto (i - 1) * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL),
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => inv_N_out_S_in(i - 1,
								j),
							inv_interface_west_out        => parasitary_invasion_output,
							inv_interface_east_out        => inv_E_out_W_in(i,
								j),
							inv_interface_south_out       => open,
							inv_interface_north_in        => inv_S_out_N_in(i - 1,
								j),
							inv_interface_west_in         => parasitary_invasion_input,
							inv_interface_east_in         => inv_W_out_E_in(i,
								j),
							inv_interface_south_in        => inv_border,
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE LRC_FIRST_COLUMN_CHECK;
				--**********************************
				-- CHECK whether WPPE is 
				-- in the LAST C O L U M N
				--**********************************
				LRC_LAST_COLUMN_CHECK : IF j = wppa_generics.M GENERATE
					last_row_last_column_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,
							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/last_row_last_column_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on                                                                                 
							--ADJACENCY_MATRIX                => ADJ_MATRIX_ARRAY(i, j),

							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(
							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							---------------------------------------------------
							-- "GET THE NORTH INPUTS from (I-1, J) WPPE" !!!

							north_inputs                  => INTERNAL_SOUTH_OUT_north_in_connections(i - 1,
								j),
							-- "SEND THE NORTH INPUTS to (I-1, J) WPPE" !!!

							north_outputs                 => INTERNAL_NORTH_OUT_south_in_connections(i - 1,
								j),
							---------------------------------------------------
							south_inputs                  => INternal_BOTTOM_south_in( -- "EXTERNAL CONNECTION"
								j * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto (j - 1) * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM),
							south_outputs                 => INternal_BOTTOM_south_out( -- "EXTERNAL_CONNECTION"
								j * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto (j - 1) * NORTH_INPUT_WIDTH * NORTH_PIN_NUM),
							---------------------------------------------------
							east_inputs                   => INternal_RIGHT_east_in( -- "EXTERNAL CONNECTION"
								i * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto (i - 1) * EAST_INPUT_WIDTH * EAST_PIN_NUM),
							east_outputs                  => INternal_RIGHT_east_out( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto (i - 1) * WEST_INPUT_WIDTH * WEST_PIN_NUM),
							---------------------------------------------------
							-- "GET THE WEST INPUTS from (i, J-1) WPPE" !!!

							west_inputs                   => INTERNAL_EAST_OUT_west_in_connections(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS to (i, J-1) WPPE" !!!

							west_outputs                  => INTERNAL_WEST_OUT_east_in_connections(i,
								j - 1),
							---------------------------------------------------

							--#################
							--### ICN_CTRL: ###
							-- "GET THE NORTH INPUTS from (I-1, J) WPPE" !!!

							north_inputs_ctrl             => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i - 1,
								j),
							-- "SEND THE NORTH INPUTS to (I-1, J) WPPE" !!!

							north_outputs_ctrl            => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i - 1,
								j),
							---------------------------------------------------
							south_inputs_ctrl             => INternal_BOTTOM_south_in_ctrl( -- "EXTERNAL CONNECTION"
								j * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto (j - 1) * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL),
							south_outputs_ctrl            => INternal_BOTTOM_south_out_ctrl( -- "EXTERNAL_CONNECTION"
								j * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto (j - 1) * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL),
							---------------------------------------------------
							east_inputs_ctrl              => INternal_RIGHT_east_in_ctrl( -- "EXTERNAL CONNECTION"
								i * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto (i - 1) * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL),
							east_outputs_ctrl             => INternal_RIGHT_east_out_ctrl( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto (i - 1) * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL),
							---------------------------------------------------
							-- "GET THE WEST INPUTS from (i, J-1) WPPE" !!!

							west_inputs_ctrl              => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS to (i, J-1) WPPE" !!!

							west_outputs_ctrl             => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j - 1),
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => inv_N_out_S_in(i - 1,
								j),
							inv_interface_west_out        => inv_W_out_E_in(i,
								j - 1),
							inv_interface_east_out        => open,
							inv_interface_south_out       => open,
							inv_interface_north_in        => inv_S_out_N_in(i - 1,
								j),
							inv_interface_west_in         => inv_E_out_W_in(i,
								j - 1),
							inv_interface_east_in         => inv_border,
							inv_interface_south_in        => inv_border,
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE LRC_LAST_COLUMN_CHECK;
				--**********************************
				-- CHECK whether WPPE is 
				-- WHETER in the FIRST
				-- NOR in the LAST C O L U M N
				--**********************************
				LRC_NOT_FIRST_NOT_LAST_COLUMN_CHECK : IF j > 1 AND j < wppa_generics.M GENERATE
					last_row_middle_columns_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,
							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/last_row_middle_columns_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on                                                                                 
							--ADJACENCY_MATRIX                => ADJ_MATRIX_ARRAY(i, j),

							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(
							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							---------------------------------------------------
							-- "GET THE NORTH INPUTS FROM (I-1, j) WPPE" !!!

							north_inputs                  => INTERNAL_SOUTH_OUT_north_in_connections(i - 1,
								j),
							-- "SEND THE NORTH OUTPUTS TO (I-1, j) WPPE" !!!                                                                                                                                        

							north_outputs                 => INTERNAL_NORTH_OUT_south_in_connections(i - 1,
								j),
							---------------------------------------------------
							south_inputs                  => INternal_BOTTOM_south_in( -- "EXTERNAL CONNECTION"
								j * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto (j - 1) * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM),
							south_outputs                 => INternal_BOTTOM_south_out( -- "EXTERNAL CONNECTION"
								j * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto (j - 1) * NORTH_INPUT_WIDTH * NORTH_PIN_NUM),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs                   => INTERNAL_WEST_OUT_east_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs                  => INTERNAL_EAST_OUT_west_in_connections(i,
								j),
							---------------------------------------------------
							-- "GET THE WEST INPUTS FROM (i, J-1) WPPE" !!!

							west_inputs                   => INTERNAL_EAST_OUT_west_in_connections(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS TO (i, J-1) WPPE" !!!

							west_outputs                  => INTERNAL_WEST_OUT_east_in_connections(i,
								j - 1),
							---------------------------------------------------

							--#################
							--### ICN_CTRL: ###
							-- "GET THE NORTH INPUTS FROM (I-1, j) WPPE" !!!

							north_inputs_ctrl             => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i - 1,
								j),
							-- "SEND THE NORTH OUTPUTS TO (I-1, j) WPPE" !!!                                                                                                                                        

							north_outputs_ctrl            => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i - 1,
								j),
							---------------------------------------------------
							south_inputs_ctrl             => INternal_BOTTOM_south_in_ctrl( -- "EXTERNAL CONNECTION"
								j * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto (j - 1) * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL),
							south_outputs_ctrl            => INternal_BOTTOM_south_out_ctrl( -- "EXTERNAL CONNECTION"
								j * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto (j - 1) * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs_ctrl              => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs_ctrl             => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							-- "GET THE WEST INPUTS FROM (i, J-1) WPPE" !!!

							west_inputs_ctrl              => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS TO (i, J-1) WPPE" !!!

							west_outputs_ctrl             => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j - 1),
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => inv_N_out_S_in(i - 1,
								j),
							inv_interface_west_out        => inv_W_out_E_in(i,
								j - 1),
							inv_interface_east_out        => inv_E_out_W_in(i,
								j),
							inv_interface_south_out       => open,
							inv_interface_north_in        => inv_S_out_N_in(i - 1,
								j),
							inv_interface_west_in         => inv_E_out_W_in(i,
								j - 1),
							inv_interface_east_in         => inv_W_out_E_in(i,
								j),
							inv_interface_south_in        => inv_border,
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE LRC_NOT_FIRST_NOT_LAST_COLUMN_CHECK;
			--**********************************
			--**********************************
			END GENERATE LAST_ROW_CHECK;
			------------------------------------
			-- CHECK whether WPPE is WHETHER in 
			-- the FIRST ROW 
			-- NOR in the LAST ROW ==> NFNLRC
			------------------------------------ 
			NOT_FIRST_NOT_LAST_ROW_CHECK : IF i > 1 AND i < wppa_generics.N GENERATE
				--**********************************
				-- CHECK whether WPPE is 
				-- in the FIRST C O L U M N
				--**********************************
				NFNLRC_FIRST_COLUMN_CHECK : IF j = 1 GENERATE
					middle_row_first_column_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,
							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/middle_row_first_column_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on                                                                                 
							--ADJACENCY_MATRIX                => ADJ_MATRIX_ARRAY(i, j),

							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(
							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							---------------------------------------------------
							-- "GET NORTH INPUTS FROM (I-1, j) WPPE" !!!

							north_inputs                  => INTERNAL_SOUTH_OUT_north_in_connections(i - 1,
								j),
							-- "SEND NORTH OUTPUTS TO (I-1, j) WPPE" !!!

							north_outputs                 => INTERNAL_NORTH_OUT_south_in_connections(i - 1,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs                  => INTERNAL_NORTH_OUT_south_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"
							south_outputs                 => INTERNAL_SOUTH_OUT_north_in_connections(i,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs                   => INTERNAL_WEST_OUT_east_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs                  => INTERNAL_EAST_OUT_west_in_connections(i,
								j),
							---------------------------------------------------
							west_inputs                   => INternal_LEFT_west_in( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto (i - 1) * WEST_INPUT_WIDTH * WEST_PIN_NUM),
							west_outputs                  => INternal_LEFT_west_out( -- "EXTERNAL CONNECTION"
								i * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto (i - 1) * EAST_INPUT_WIDTH * EAST_PIN_NUM),
							---------------------------------------------------

							--#################
							--### ICN_CTRL: ###                                                                             
							-- "GET NORTH INPUTS FROM (I-1, j) WPPE" !!!

							north_inputs_ctrl             => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i - 1,
								j),
							-- "SEND NORTH OUTPUTS TO (I-1, j) WPPE" !!!

							north_outputs_ctrl            => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i - 1,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs_ctrl             => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"
							south_outputs_ctrl            => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs_ctrl              => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs_ctrl             => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							west_inputs_ctrl              => INternal_LEFT_west_in_ctrl( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto (i - 1) * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL),
							west_outputs_ctrl             => INternal_LEFT_west_out_ctrl( -- "EXTERNAL CONNECTION"
								i * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto (i - 1) * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL),
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => inv_N_out_S_in(i - 1,
								j),
							inv_interface_west_out        => open,
							inv_interface_east_out        => inv_E_out_W_in(i,
								j),
							inv_interface_south_out       => inv_S_out_N_in(i,
								j),
							inv_interface_north_in        => inv_S_out_N_in(i - 1,
								j),
							inv_interface_west_in         => inv_border,
							inv_interface_east_in         => inv_W_out_E_in(i,
								j),
							inv_interface_south_in        => inv_N_out_S_in(i,
								j),
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE NFNLRC_FIRST_COLUMN_CHECK;
				--**********************************
				-- CHECK whether WPPE is 
				-- in the LAST C O L U M N
				--**********************************
				NFNLRC_LAST_COLUMN_CHECK : IF j = wppa_generics.M GENERATE
					middle_row_last_column_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,
							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/middle_row_last_column_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on                                                                                 
							--ADJACENCY_MATRIX                => ADJ_MATRIX_ARRAY(i, j),

							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(
							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							---------------------------------------------------
							-- "GET THE NORTH INPUTS FROM (I-1, j) WPPE"

							north_inputs                  => INTERNAL_SOUTH_OUT_north_in_connections(i - 1,
								j),
							-- "SEND THE NORTH OUTPUTS TO (I-1, j) WPPE"

							north_outputs                 => INTERNAL_NORTH_OUT_south_in_connections(i - 1,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs                  => INTERNAL_NORTH_OUT_south_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"
							south_outputs                 => INTERNAL_SOUTH_OUT_north_in_connections(i,
								j),
							---------------------------------------------------
							east_inputs                   => INternal_RIGHT_east_in( -- "EXTERNAL CONNECTION"
								i * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto (i - 1) * EAST_INPUT_WIDTH * EAST_PIN_NUM),
							east_outputs                  => INternal_RIGHT_east_out( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto (i - 1) * WEST_INPUT_WIDTH * WEST_PIN_NUM),
							---------------------------------------------------
							-- "GET THE WEST INPUTS FROM (i, J-1) WPPE" !!!

							west_inputs                   => INTERNAL_EAST_OUT_west_in_connections(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS TO (i, J-1) WPPE" !!!

							west_outputs                  => INTERNAL_WEST_OUT_east_in_connections(i,
								j - 1),
							---------------------------------------------------

							--#################
							--### ICN_CTRL: ###             
							-- "GET THE NORTH INPUTS FROM (I-1, j) WPPE"

							north_inputs_ctrl             => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i - 1,
								j),
							-- "SEND THE NORTH OUTPUTS TO (I-1, j) WPPE"

							north_outputs_ctrl            => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i - 1,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs_ctrl             => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"
							south_outputs_ctrl            => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							east_inputs_ctrl              => INternal_RIGHT_east_in_ctrl( -- "EXTERNAL CONNECTION"
								i * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto (i - 1) * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL),
							east_outputs_ctrl             => INternal_RIGHT_east_out_ctrl( -- "EXTERNAL CONNECTION"
								i * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto (i - 1) * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL),
							---------------------------------------------------
							-- "GET THE WEST INPUTS FROM (i, J-1) WPPE" !!!

							west_inputs_ctrl              => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS TO (i, J-1) WPPE" !!!

							west_outputs_ctrl             => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j - 1),
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => inv_N_out_S_in(i - 1,
								j),
							inv_interface_west_out        => inv_W_out_E_in(i,
								j - 1),
							inv_interface_east_out        => open,
							inv_interface_south_out       => inv_S_out_N_in(i,
								j),
							inv_interface_north_in        => inv_S_out_N_in(i - 1,
								j),
							inv_interface_west_in         => inv_E_out_W_in(i,
								j - 1),
							inv_interface_east_in         => inv_border,
							inv_interface_south_in        => inv_N_out_S_in(i,
								j),
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE NFNLRC_LAST_COLUMN_CHECK;
				--**********************************
				-- CHECK whether WPPE is 
				-- WHETER in the FIRST
				-- NOR in the LAST C O L U M N
				--**********************************
				NFNLRC_NOT_FIRST_NOT_LAST_COLUMN_CHECK : IF j > 1 AND j < wppa_generics.M GENERATE
					middle_row_middle_column_wppe_icn : wppe_icn_wrapper
						generic map(
							--Ericles:
							N                     => i,
							M                     => j,
							-- cadence translate_off        

							INSTANCE_NAME         => TOP_LEVEL_INSTANCE_NAME & "/middle_row_middle_column_wppe_icn_" & Int_to_string(i) & "_" & Int_to_string(j),

							-- cadence translate_on                                                                                 
							ADJACENCY_MATRIX      => get_adj_matrix_data(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							ADJACENCY_MATRIX_CTRL => get_adj_matrix_ctrl(ADJ_MATRIX_ARRAY_ALL(i,
									j)),
							--ADJACENCY_MATRIX              => ADJ_MATRIX_ARRAY(i, j),

							WPPE_GENERICS_RECORD  => WPPE_GENERICS(i,
								j)
						)
						port map(
							--***********************************
							-- POWER SHUTOFF AUXILIARY SIGNAL
							--***********************************

							ff_start_detection            => FF_START_DETECTION_BUS,

							--***********************************
							---------------------------------------------------
							clk                           => clk,
							rst                           => rst,
							vertical_set_to_config        => internal_conf_mask_vertical(i),
							horizontal_set_to_config      => internal_conf_mask_horizontal(j),
							---------------------------------------------------
							pc_debug_out                  => GLOBAL_pc_debug_outs(i,
								j),
							input_fifos_write_en          => GLOBAL_input_fifos_write_ens(i,
								j),
							---------------------------------------------------
							--                                                                              ctrl_inputs                             => GLOBAL_ctrl_inputs(i, j),
							--                                                                              ctrl_outputs                    => GLOBAL_ctrl_outputs(i, j),
							---------------------------------------------------
							config_mem_data               => GLOBAL_config_mem_data, -- GLOBAL CONFIGURATION BUS
							---------------------------------------------------
							---------------------------------------------------
							-- "GET THE NORTH INPUTS FROM (I-1, j) WPPE" !!!

							north_inputs                  => INTERNAL_SOUTH_OUT_north_in_connections(i - 1,
								j),
							-- "SEND THE NORTH OUTPUTS TO (I-1, j) WPPE" !!!

							north_outputs                 => INTERNAL_NORTH_OUT_south_in_connections(i - 1,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs                  => INTERNAL_NORTH_OUT_south_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"
							south_outputs                 => INTERNAL_SOUTH_OUT_north_in_connections(i,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs                   => INTERNAL_WEST_OUT_east_in_connections(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs                  => INTERNAL_EAST_OUT_west_in_connections(i,
								j),
							---------------------------------------------------
							-- "GET THE WEST INPUTS FROM (i, J-1) WPPE" !!!

							west_inputs                   => INTERNAL_EAST_OUT_west_in_connections(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS TO (i, J-1) WPPE" !!!

							west_outputs                  => INTERNAL_WEST_OUT_east_in_connections(i,
								j - 1),
							---------------------------------------------------

							--#################
							--### ICN_CTRL: ###                             
							-- "GET THE NORTH INPUTS FROM (I-1, j) WPPE" !!!

							north_inputs_ctrl             => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i - 1,
								j),
							-- "SEND THE NORTH OUTPUTS TO (I-1, j) WPPE" !!!

							north_outputs_ctrl            => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i - 1,
								j),
							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							south_inputs_ctrl             => INTERNAL_NORTH_OUT_south_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"

							south_outputs_ctrl            => INTERNAL_SOUTH_OUT_north_in_connections_ctrl(i,
								j),

							---------------------------------------------------
							-- "INTERNAL CONNECTION"
							east_inputs_ctrl              => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j),
							-- "INTERNAL CONNECTION"
							east_outputs_ctrl             => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j),
							---------------------------------------------------
							-- "GET THE WEST INPUTS FROM (i, J-1) WPPE" !!!

							west_inputs_ctrl              => INTERNAL_EAST_OUT_west_in_connections_ctrl(i,
								j - 1),
							-- "SEND THE WEST OUTPUTS TO (i, J-1) WPPE" !!!

							west_outputs_ctrl             => INTERNAL_WEST_OUT_east_in_connections_ctrl(i,
								j - 1),
							vliw_config_en                => vliw_config_en,
							icn_config_en                 => icn_config_en,
							common_config_reset           => common_config_reset,
							configuration_done            => configuration_done(i,
								j),
							mask                          => fault_injection_sig.mask,
							fu_sel                        => fault_injection_sig.fu_sel,
							pe_sel                        => fault_injection_sig.pe_sel(i-1,j-1),
							error_flag                    => sig_error_flag(i-1, j-1),
							error_diagnosis               => sig_error_diagnosis(i-1, j-1),
							ctrl_programmable_input_depth => ctrl_programmable_depth(i,
								j),
							en_programmable_fd_depth      => en_programmable_fd_depth(i,
								j),
							programmable_fd_depth         => programmable_fd_depth(i,
								j),
							count_down                    => count_down(i - 1,
								j - 1),
							enable_tcpa                   => enable_tcpa,
							inv_interface_north_out       => inv_N_out_S_in(i - 1,
								j),
							inv_interface_west_out        => inv_W_out_E_in(i,
								j - 1),
							inv_interface_east_out        => inv_E_out_W_in(i,
								j),
							inv_interface_south_out       => inv_S_out_N_in(i,
								j),
							inv_interface_north_in        => inv_S_out_N_in(i - 1,
								j),
							inv_interface_west_in         => inv_E_out_W_in(i,
								j - 1),
							inv_interface_east_in         => inv_W_out_E_in(i,
								j),
							inv_interface_south_in        => inv_N_out_S_in(i,
								j),
							inv_prog_data                 => inv_prog_data,
							inv_prog_addr                 => inv_prog_addr,
							inv_prog_wr_en                => inv_prog_wr_en,
							inv_start                     => inv_start
						);

				END GENERATE NFNLRC_NOT_FIRST_NOT_LAST_COLUMN_CHECK;
			--**********************************
			--**********************************
			END GENERATE NOT_FIRST_NOT_LAST_ROW_CHECK;
		------------------------------------
		------------------------------------ 

		
		END GENERATE COLUMN_WPPE_GENERATION_LOOP; -- j = 1 ... M

	END GENERATE ROW_WPPE_GENERATION_LOOP; -- i = 1 .. N

	---- ***** ASTRA
	--input_img_mem_algo_type  <= '0';
	--output_img_mem_algo_type <= '0';
	--
	--to_input_img_mem_algo_type  <= input_img_mem_algo_type;
	--to_output_img_mem_algo_type <= output_img_mem_algo_type;
	--
	---- ***** astra


	--assign_control_signals :process(clk, rst)
	--
	--variable internal_bit :std_logic;
	--
	--begin
	--
	--if clk'event and clk = '1' then
	--
	--       if rst = '1' then
	--
	--              GLOBAL_input_fifos_write_ens <= (others => (others => (others => '0')));
	--              GLOBAL_ctrl_inputs <= (others => (others => (others => '0')));
	--              internal_bit := '0';
	--
	--      else
	--
	--              if internal_bit = '0' then
	--                
	--                      GLOBAL_input_fifos_write_ens <= (others => (others => (others => '1')));
	--                      GLOBAL_ctrl_inputs <= (others => (others => (others => '1')));
	--                      internal_bit := '1';
	--                      internal_bit := '1';
	--
	--              else
	--
	--              GLOBAL_input_fifos_write_ens <= (others => (others => (others => '1')));
	--              GLOBAL_ctrl_inputs <= (others => (others => (others => '0')));
	--              internal_bit := '0';
	--              
	--
	--              end if;
	--
	--
	--
	--      end if;
	--
	--end if;
	--
	--
	--end process;

	----#######################################################################
	--   clock_gating: process(conf_en_in, ready_out, conf_done)
	--   begin
	--      if conf_en_in'event and conf_en_in = '1' then
	--          clk_gating_select <= '0';
	--          switch_counter <= switch_counter + 1; 
	--      end if;
	--      
	--      if ready_out'event and ready_out = '1' and conf_done = '0' then
	--          clk_gating_select <= '1'; --separate from CLOCK
	--          switch_counter <= switch_counter + 1;
	--      end if;
	--      
	--      if conf_done'event and conf_done = '0' and ready_out = '1' then
	--          clk_gating_select <= '1'; --separate from CLOCK
	--          switch_counter <= switch_counter + 1;
	--      end if;
	--   end process clock_gating;
	----#######################################################################


	--#######################################################################
	--type t_clock_gating_state is (clk_init, free_init_end, clk_config, free_ready);
	clock_gating_pr : process(clk, rst)
		variable initialized        : std_logic; -- := '0';
		variable internal_conf_done : std_logic; -- := '0'; 

	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				initialized        := '0';
				internal_conf_done := '0';

				clk_gating_select <= '0'; -- CONNECT TO CLOCK
				clk_gating_state  <= clk_init;
				switch_counter    <= 0;

			else                        -- rst = '0'

				if initialized = '0' then
					if ready_out = '1' then
						initialized       := '1';
						clk_gating_select <= '1'; --separate from CLOCK

						switch_counter   <= switch_counter + 1;
						clk_gating_state <= free_init_end;
					end if;

				else                    --==: if initialized	= '0'

					if ready_out = '1' then
						if PC2CM_conf_en = '1' then
							clk_gating_select <= '0';
							switch_counter    <= switch_counter + 1;
							clk_gating_state  <= clk_config;
						end if;         --==: if conf_en_in = '1'

						if internal_conf_done = '1' and clk_gating_select = '0' then
							internal_conf_done := '0';
							clk_gating_select  <= '1'; --separate from CLOCK
							switch_counter     <= switch_counter + 1;
							clk_gating_state   <= free_ready;
						end if;         --==: if conf_done = '0' 	

					else                --==: if ready_out = '1' 

						if conf_done = '1' then
							internal_conf_done := '1';
						end if;         --==: if config_done = '1'

					end if;             --==: if ready_out = '1' 

				end if;                 --==: if initialized	= '0' 
			end if;                     -- rst = '1'
		end if;                         --==: if clk'event and clk = '1'

	end process clock_gating_pr;
	--#######################################################################  
	--proc_tcpa_config_done : process(rst, clk, configuration_done)
	proc_tcpa_config_done : process(rst, clk)
	begin
		if rst = '1' then
			tcpa_config_done <= '1';
			--tcpa_config_done <= '0';
			tcpa_config_done_vector <= (others=>'0');

		elsif rising_edge(clk) then
			tcpa_config_done_vector(0) <= configuration_done(1,1);
			tcpa_config_done_vector(1) <= configuration_done(1,2);
			tcpa_config_done_vector(2) <= configuration_done(1,3);
			tcpa_config_done_vector(3) <= configuration_done(1,4);
			tcpa_config_done_vector(4) <= configuration_done(2,1);
			tcpa_config_done_vector(5) <= configuration_done(2,2);
			tcpa_config_done_vector(6) <= configuration_done(2,3);
			tcpa_config_done_vector(7) <= configuration_done(2,4);
--			tcpa_config_done_vector(8) <= configuration_done(3,1);
--			tcpa_config_done_vector(9) <= configuration_done(3,2);
--			tcpa_config_done_vector(10) <= configuration_done(3,3);
--			tcpa_config_done_vector(11) <= configuration_done(3,4);
--			tcpa_config_done_vector(12) <= configuration_done(4,1);
--			tcpa_config_done_vector(13) <= configuration_done(4,2);
--			tcpa_config_done_vector(14) <= configuration_done(4,3);
--			tcpa_config_done_vector(15) <= configuration_done(4,4);
			for i in 1 to CUR_DEFAULT_NUM_WPPE_VERTICAL - 1 loop
				for j in 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL - 1 loop
					--It means, if any PEs is not configured, we assume that the TCPA is not fully configured
					tcpa_config_done <= (configuration_done(i, j) and configuration_done(i + 1, j + 1));
				end loop;
			end loop;
				fault_injection_sig <= fault_injection;
		end if;
	end process;


	error_handler : process(clk, sig_error_flag, rst) 
	variable flag : std_logic;
	begin
		if(rst = '1') then
			error_status.irq <= '0';
			error_reg <= '0';
			error_flag_reg <= (others=>'0');
			flag := '0';
			error_status.index <= (others=>'0');
			--error_status.pe_rows_and_columns <= (others=>(others=>'0'));
			error_status.row <= (others => '0');
			error_status.column <= (others => '0');

		elsif clk'event and clk='1' then
			for i in 0 to CUR_DEFAULT_NUM_WPPE_VERTICAL - 1 loop
				for j in 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL - 1 loop
					error_flag_reg(j+i*CUR_DEFAULT_NUM_WPPE_HORIZONTAL) <= sig_error_flag(i,j);
					if(sig_error_flag(i,j) = '1') then
						--error_status.pe_rows_and_columns is a two dimensional array. 
						--Rows are mapped to 'j' indexes and each column value corresponds to a bit position 'i' inside the row
						-- For example, if PE(m.n) is faulty, error_status.pe_rows_and_columns(m)(n) will be set to '1', otherwise, '0'
						--error_status.pe_rows_and_columns(i)(j) <= '1';
						error_status.index(j+i*CUR_DEFAULT_NUM_WPPE_HORIZONTAL) <= sig_error_flag(i, j);
						error_status.row(j) <= '1';
						error_status.column(i) <= '1';
					end if;
				end loop;
			end loop;
			if(not ((error_flag_reg = (CUR_DEFAULT_NUM_WPPE_VERTICAL*CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1 downto 0 => '0')) )) then
				error_status.irq <= '1'; 
			else
				error_status.irq <= '0'; 
			end if;

		end if;
	end process;

	config_en_holder : process(PC2CM_conf_en, clk)
	begin
		if clk'event and clk = '1' then
			--Ericles: used to bring all PCs to top level
			pc_debug_out <= GLOBAL_pc_debug_outs; 

			if PC2CM_conf_en = '1' then
				internal_conf_en <= '1';
			elsif internal_conf_en = '1' then
				internal_conf_en <= '0';
			end if;
		end if;
	end process config_en_holder;


	--Enabling multi-Region Clock Buffer
	--BUFMR_o: BUFMR port map(I=> clk_in, O => clk);
	--BUFG_0: BUFG port map(I=> clk_in, O => clk);
	clk <= clk_in;

	end Behavioral;


