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


library IEEE;
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;

package type_lib is

	--===============================================================================--		
	--             POWER CONTROLLER TYPES
	--===============================================================================--		

	CONSTANT POWER_GATING         : boolean               := false;
	CONSTANT POWER_UP_CYCLE_COUNT : integer range 0 to 16 := 3; --5;

	CONSTANT MACROMODELING     : boolean := false;
	CONSTANT OPERAND_ISOLATION : boolean := false;

	CONSTANT AN  : std_logic := '1';
	CONSTANT AUS : std_logic := '0';

	CONSTANT n_AN  : std_logic := '0';
	CONSTANT n_AUS : std_logic := '1';

	CONSTANT pso_bit          : integer range 0 to 5 := 0;
	CONSTANT nrestore_bit     : integer range 0 to 5 := 1;
	CONSTANT iso_bit          : integer range 0 to 5 := 2;
	CONSTANT save_bit         : integer range 0 to 5 := 3;
	CONSTANT clk_so_bit       : integer range 0 to 5 := 4;
	CONSTANT pwr_up_reset_bit : integer range 0 to 5 := 5;

	CONSTANT slave_clk_so_bit : integer range 0 to 1 := 0;

	CONSTANT power_down_bit       : integer range 0 to 1 := 0;
	CONSTANT power_down_ready_bit : integer range 0 to 1 := 1;

	--===============================================================================--		
	--                POWER CONTROLLER TYPES
	--===============================================================================--		


	--===============================================================================--		
	--             CONTROL REGFILE GENERICS TYPES
	--===============================================================================--		
	type t_control_regfile_generics is record

		--*******************************************************************************--
		-- GENERICS FOR THE NUMBER OF READ AND WRITE PORTS TO CONTROL REGISTER FILE
		--*******************************************************************************--

		NUM_OF_CTRL_READ_PORTS  : positive range 1 to MAX_NUM_CTRL_READ_PORTS;
		NUM_OF_CTRL_WRITE_PORTS : positive range 1 to MAX_NUM_CTRL_WRITE_PORTS;

		--*******************************************************************************--
		-- GENERICS FOR THE NUMBER OF CONTROL REGISTERS, NUMBER OF CONTROL INPUT, 
		-- AND CONTROL OUTPUT REGISTERS --
		--*******************************************************************************--

		CTRL_REG_NUM : positive range 1 to MAX_NUM_CONTROL_REGS;

		NUM_OF_CTRL_OUTPUTS : integer range 0 to MAX_NUM_CONTROL_OUTPUTS;
		NUM_OF_CTRL_INPUTS  : integer range 0 to MAX_NUM_CONTROL_INPUTS;

		BEGIN_CTRL_OUTPUTS : integer range -MAX_NUM_CONTROL_REGS to MAX_NUM_CONTROL_REGS;
		END_CTRL_OUTPUTS   : integer range -MAX_NUM_CONTROL_REGS to MAX_NUM_CONTROL_REGS;

		--*******************************************************************************--
		-- GENERICS FOR THE CONTROL REGISTER WIDTH --
		--*******************************************************************************--

		CTRL_REG_WIDTH : positive range 1 to MAX_CTRL_REG_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE ADDRESS WIDTH
		--*******************************************************************************--

		CTRL_REGFILE_ADDR_WIDTH : positive range 1 to MAX_CTRL_REGFILE_ADDR_WIDTH;

	end record;

	CONSTANT CUR_DEFAULT_CONTROL_REGFILE_GENERICS : t_control_regfile_generics := (
		CUR_DEFAULT_NUM_CTRL_READ_PORTS,
		CUR_DEFAULT_NUM_CTRL_WRITE_PORTS,
		CUR_DEFAULT_NUM_CONTROL_REGS,
		CUR_DEFAULT_NUM_CONTROL_OUTPUTS,
		CUR_DEFAULT_NUM_CONTROL_INPUTS,
		13,
		15,
		CUR_DEFAULT_CTRL_REG_WIDTH,
		CUR_DEFAULT_CTRL_REGFILE_ADDR_WIDTH
	);

	--===============================================================================--		
	--             WPPA GENERICS TYPES
	--===============================================================================--		

	type t_wppa_generics is record

		--###########################################################################
		-- Bus protocol parameters, do not add to or delete
		--###########################################################################
		C_AWIDTH : integer;             --           := 32;
		C_DWIDTH : integer;             --           := 32;
		C_NUM_CE : integer;             --           := 16;
		--###########################################################################

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

		------------------------------------------                  
		-- VERTICAL number of WPPEs in the array
		N                 : integer range MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL; -- := CUR_DEFAULT_NUM_WPPE_VERTICAL;
		------------------------------------------
		-- HORIZONTAL number of WPPEs in the array
		M                 : integer range MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL; -- := CUR_DEFAULT_NUM_WPPE_HORIZONTAL;
		------------------------------------------                  
		-- Number of WPPEs which are connected to external devices
		-- on the array's TOP
		EXTERNAL_TOP_M    : integer range MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL; -- := CUR_DEFAULT_TOP_EXTERNAL_NUM_WPPE_HORIZONTAL;
		------------------------------------------
		-- Number of WPPEs which are connected to external devices
		-- on the array's BOTTOM
		EXTERNAL_BOTTOM_M : integer range MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL; -- := CUR_DEFAULT_BOTTOM_EXTERNAL_NUM_WPPE_HORIZONTAL;
		------------------------------------------                  
		-- Number of WPPEs which are connected to external devices
		-- on the arrray's LEFT SIDE
		EXTERNAL_LEFT_N   : integer range MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL; -- := CUR_DEFAULT_LEFT_EXTERNAL_NUM_WPPE_VERTICAL;
		------------------------------------------
		-- Number of WPPEs which are connected to external devices
		-- on the array's RIGHT SIDE
		EXTERNAL_RIGHT_N  : integer range MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL; -- := CUR_DEFAULT_RIGHT_EXTERNAL_NUM_WPPE_VERTICAL;
		------------------------------------------

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		------------------------------------------
		ADDR_WIDTH       : positive range 1 to MAX_ADDR_WIDTH; -- := CUR_DEFAULT_ADDR_WIDTH;
		------------------------------------------
		NUM_OF_INPUT_REG : positive range 1 to MAX_INPUT_REG_NUM; -- := CUR_DEFAULT_INPUT_REG_NUM;

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		-- GENERICS FOR THE EXTERNAL OCB BUS TO EXTERNAL PROCESSOR
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		BUS_ADDR_WIDTH : integer range MIN_BUS_ADDR_WIDTH to MAX_BUS_ADDR_WIDTH; -- := CUR_DEFAULT_BUS_ADDR_WIDTH;
		BUS_DATA_WIDTH : integer range MIN_BUS_DATA_WIDTH to MAX_BUS_DATA_WIDTH; -- := CUR_DEFAULT_BUS_DATA_WIDTH;      
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		-- GENERICS FOR THE GLOBAL CONFIGURATION MEMORY
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		------------------------------------------
		SOURCE_MEM_SIZE   : positive range 2 to MAX_SOURCE_MEM_SIZE;
		--; -- := CUR_DEFAULT_SOURCE_MEM_SIZE;
		------------------------------------------
		SOURCE_ADDR_WIDTH : positive range 1 to MAX_ADDR_WIDTH; -- := CUR_DEFAULT_SOURCE_ADDR_WIDTH; 
		------------------------------------------
		SOURCE_DATA_WIDTH : positive range 1 to 128; -- := CUR_DEFAULT_SOURCE_DATA_WIDTH;
	------------------------------------------

	end record t_wppa_generics;

	CONSTANT DEFAULT_WPPA_GENERICS : t_wppa_generics := (
		32,
		32,
		16,

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

		------------------------------------------                  
		-- VERTICAL number of WPPEs in the array
		CUR_DEFAULT_NUM_WPPE_VERTICAL,
		------------------------------------------
		-- HORIZONTAL number of WPPEs in the array
		CUR_DEFAULT_NUM_WPPE_HORIZONTAL,
		------------------------------------------                  
		-- Number of WPPEs which are connected to external devices
		-- on the array's TOP
		CUR_DEFAULT_TOP_EXTERNAL_NUM_WPPE_HORIZONTAL,
		------------------------------------------
		-- Number of WPPEs which are connected to external devices
		-- on the array's BOTTOM
		CUR_DEFAULT_BOTTOM_EXTERNAL_NUM_WPPE_HORIZONTAL,
		------------------------------------------                  
		-- Number of WPPEs which are connected to external devices
		-- on the arrray's LEFT SIDE
		CUR_DEFAULT_LEFT_EXTERNAL_NUM_WPPE_VERTICAL,
		------------------------------------------
		-- Number of WPPEs which are connected to external devices
		-- on the array's RIGHT SIDE
		CUR_DEFAULT_RIGHT_EXTERNAL_NUM_WPPE_VERTICAL,
		------------------------------------------

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		------------------------------------------
		CUR_DEFAULT_ADDR_WIDTH,
		------------------------------------------
		CUR_DEFAULT_INPUT_REG_NUM,
		------------------------------------------
		--        NUM_OF_CONTROL_INPUTS  => CUR_DEFAULT_NUM_CONTROL_INPUTS,
		--        ------------------------------------------
		--        NUM_OF_CONTROL_OUTPUTS => CUR_DEFAULT_NUM_CONTROL_OUTPUTS,
		------------------------------------------

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		-- GENERICS FOR THE EXTERNAL OCB BUS TO EXTERNAL PROCESSOR
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		32,
		32,
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		-- GENERICS FOR THE GLOBAL CONFIGURATION MEMORY
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		------------------------------------------
		CUR_DEFAULT_SOURCE_MEM_SIZE,
		------------------------------------------
		CUR_DEFAULT_SOURCE_ADDR_WIDTH,
		------------------------------------------
		CUR_DEFAULT_SOURCE_DATA_WIDTH
	------------------------------------------
	);

	--===============================================================================--		
	--             WPPA SIGNAL TYPES
	--===============================================================================--		

	type t_wppa_bus_input_interface is record
		--###########################################################################
		-- OPB  BUS  INTERFACE SIGNALS
		--###########################################################################
		Bus2IP_Addr : std_logic_vector(0 to 32 - 1);
		Bus2IP_Data : std_logic_vector(0 to 32 - 1);
		Bus2IP_BE   : std_logic_vector(0 to 32 / 8 - 1);
		Bus2IP_RdCE : std_logic_vector(0 to 16 - 1);
		Bus2IP_WrCE : std_logic_vector(0 to 16 - 1);
	end record t_wppa_bus_input_interface;

	type t_wppa_bus_output_interface is record
		IP2Bus_Data : std_logic_vector(0 to 32 - 1);
	--###########################################################################
	end record t_wppa_bus_output_interface;

	type t_wppa_data_input_interface is record
		--/////////////////////////////////////////////////--
		EXTERNAL_TOP_north_in    : std_logic_vector(CUR_DEFAULT_TOP_EXTERNAL_NUM_WPPE_HORIZONTAL * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_BOTTOM_south_in : std_logic_vector(CUR_DEFAULT_BOTTOM_EXTERNAL_NUM_WPPE_HORIZONTAL * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_LEFT_west_in    : std_logic_vector(CUR_DEFAULT_LEFT_EXTERNAL_NUM_WPPE_VERTICAL * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_RIGHT_east_in   : std_logic_vector(CUR_DEFAULT_RIGHT_EXTERNAL_NUM_WPPE_VERTICAL * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto 0);
	--/////////////////////////////////////////////////--
	end record t_wppa_data_input_interface;

	type t_wppa_data_output_interface is record
		--/////////////////////////////////////////////////--
		EXTERNAL_TOP_north_out    : std_logic_vector(CUR_DEFAULT_TOP_EXTERNAL_NUM_WPPE_HORIZONTAL * SOUTH_INPUT_WIDTH * SOUTH_PIN_NUM - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_BOTTOM_south_out : std_logic_vector(CUR_DEFAULT_BOTTOM_EXTERNAL_NUM_WPPE_HORIZONTAL * NORTH_INPUT_WIDTH * NORTH_PIN_NUM - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_LEFT_west_out    : std_logic_vector(CUR_DEFAULT_LEFT_EXTERNAL_NUM_WPPE_VERTICAL * EAST_INPUT_WIDTH * EAST_PIN_NUM - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_RIGHT_east_out   : std_logic_vector(CUR_DEFAULT_RIGHT_EXTERNAL_NUM_WPPE_VERTICAL * WEST_INPUT_WIDTH * WEST_PIN_NUM - 1 downto 0);
	--/////////////////////////////////////////////////--
	end record t_wppa_data_output_interface;

	type t_wppa_ctrl_output_interface is record
		--/////////////////////////////////////////////////--
		EXTERNAL_TOP_north_out_ctrl    : std_logic_vector(CUR_DEFAULT_TOP_EXTERNAL_NUM_WPPE_HORIZONTAL * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_BOTTOM_south_out_ctrl : std_logic_vector(CUR_DEFAULT_BOTTOM_EXTERNAL_NUM_WPPE_HORIZONTAL * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_LEFT_west_out_ctrl    : std_logic_vector(CUR_DEFAULT_LEFT_EXTERNAL_NUM_WPPE_VERTICAL * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_RIGHT_east_out_ctrl   : std_logic_vector(CUR_DEFAULT_RIGHT_EXTERNAL_NUM_WPPE_VERTICAL * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto 0);
	--/////////////////////////////////////////////////--
	end record t_wppa_ctrl_output_interface;

	type t_wppa_ctrl_input_interface is record
		--/////////////////////////////////////////////////--
		EXTERNAL_TOP_north_in_ctrl    : std_logic_vector(CUR_DEFAULT_TOP_EXTERNAL_NUM_WPPE_HORIZONTAL * NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_BOTTOM_south_in_ctrl : std_logic_vector(CUR_DEFAULT_BOTTOM_EXTERNAL_NUM_WPPE_HORIZONTAL * SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_LEFT_west_in_ctrl    : std_logic_vector(CUR_DEFAULT_LEFT_EXTERNAL_NUM_WPPE_VERTICAL * WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto 0);
		--/////////////////////////////////////////////////--
		EXTERNAL_RIGHT_east_in_ctrl   : std_logic_vector(CUR_DEFAULT_RIGHT_EXTERNAL_NUM_WPPE_VERTICAL * EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto 0);
	--/////////////////////////////////////////////////--
	end record t_wppa_ctrl_input_interface;

	type t_wppa_memory_input_interface is record
		from_input_mem_data : std_logic_vector(31 downto 0);
	end record t_wppa_memory_input_interface;

	type t_wppa_memory_output_interface is record
		to_input_mem_re    : std_logic;
		to_input_mem_addr  : std_logic_vector(31 downto 0);
		to_output_mem_we   : std_logic;
		to_output_mem_addr : std_logic_vector(31 downto 0);
		to_output_mem_data : std_logic_vector(31 downto 0);
	end record t_wppa_memory_output_interface;

	type t_wppa_config_input_interface is record
		conf_en_in   : std_logic;
		offset_in    : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
		dnumber_in   : std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
		conf_type_in : std_logic_vector(CUR_DEFAULT_CONFIG_TYPE_WIDTH - 1 downto 0);
	end record t_wppa_config_input_interface;

	type t_wppa_interface is record
		-- BUS
		wppa_bus_input_interface     : t_wppa_bus_input_interface;
		wppa_bus_output_interface    : t_wppa_bus_output_interface;
		-- Data
		wppa_data_input              : t_wppa_data_input_interface;
		wppa_data_output             : t_wppa_data_output_interface;
		-- Control
		wppa_ctrl_input              : t_wppa_ctrl_input_interface;
		wppa_ctrl_output             : t_wppa_ctrl_output_interface;
		-- Memory
		wppa_memory_input_interface  : t_wppa_memory_input_interface;
		wppa_memory_output_interface : t_wppa_memory_output_interface;
		-- Configuration
		wppa_config_interface        : t_wppa_config_input_interface;
	end record t_wppa_interface;

	--===============================================================================--		
	--             FLAGS SIGNAL TYPES
	--===============================================================================--		

	CONSTANT MAX_NUM_FLAGS : positive range 1 to 8 := 4;

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

	CONSTANT LOG_MAX_NUM_FU       : integer range 1 to 8 := log_width(MAX_NUM_FU);
	CONSTANT LOG_MAX_NUM_FLAGS    : integer range 1 to 8 := log_width(MAX_NUM_FLAGS);
	CONSTANT LOG_MAX_NUM_CTRL_SIG : integer range 1 to 8 := log_width(MAX_NUM_CONTROL_REGS + MAX_NUM_CONTROL_INPUTS + MAX_NUM_CONTROL_OUTPUTS);

	type t_adder_flags is record
		flags : std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0);
	end record;

	type t_mul_flags is record
		flags : std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0);
	end record;

	type t_logic_flags is record
		flags : std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0);
	end record;

	type t_shift_flags is record
		flags : std_logic_vector(MAX_NUM_FU * MAX_NUM_FLAGS downto 0);
	end record;

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

	type t_flag_selects is record
		SEL_FU        : std_logic_vector(2 downto 0);
		SEL_FU_NO     : std_logic_vector(LOG_MAX_NUM_FU - 1 downto 0);
		SEL_FLAG      : std_logic_vector(LOG_MAX_NUM_FLAGS - 1 downto 0);
		SEL_CTRL_FLAG : std_logic_vector(LOG_MAX_NUM_CTRL_SIG - 1 downto 0);
	end record t_flag_selects;

	type t_flag_controls is array (integer range <>) of t_flag_selects;

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

	type t_FU_flags_values is record
		ADDER_flags : t_adder_flags;
		MUL_flags   : t_mul_flags;
		LOGIC_flags : t_logic_flags;
		SHIFT_flags : t_shift_flags;
		CTRL_flags  : std_logic_vector(MAX_NUM_CONTROL_REGS + MAX_NUM_CONTROL_INPUTS + MAX_NUM_CONTROL_OUTPUTS downto 0);

	end record t_FU_flags_values;

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

	--===============================================================================--		
	--===============================================================================--		

	--Ericles Sousa on 16 Dec 2014
	type t_configuration_done is array (1 to CUR_DEFAULT_NUM_WPPE_VERTICAL, 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL) of std_logic;

	type t_ctrl_programmable_input_depth is array (CUR_DEFAULT_NUM_CONTROL_INPUTS - 1 downto 0) of integer range 0 to 1023;
	--type t_ctrl_programmable_input_depth is array(CUR_DEFAULT_NUM_CONTROL_INPUTS-1 downto 0) of integer range 0 to 511;
	type t_ctrl_programmable_depth is array (1 to CUR_DEFAULT_NUM_WPPE_VERTICAL, 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL) of t_ctrl_programmable_input_depth;

	--For some bugs on TCPA editor, we cannot subtract CUR_DEFAULT_NUM_FB_FIFO!
	--The programmable depth ranges from 0 to 65535
	type t_programmable_input_fd_depth is array (CUR_DEFAULT_NUM_FB_FIFO downto 0) of std_logic_vector(15 downto 0);
	--type t_programmable_input_fd_depth is array(CUR_DEFAULT_NUM_FB_FIFO downto 0) of std_logic_vector(3 downto 0);
	type t_programmable_fd_depth is array (1 to CUR_DEFAULT_NUM_WPPE_VERTICAL, 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL) of t_programmable_input_fd_depth;

	type t_en_programmable_input_fd_depth is array (CUR_DEFAULT_NUM_FB_FIFO downto 0) of std_logic;
	type t_en_programmable_fd_depth is array (1 to CUR_DEFAULT_NUM_WPPE_VERTICAL, 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL) of t_en_programmable_input_fd_depth;

	--type t_programmable_fd_depth is array(0 to 31) of std_logic_vector(CUR_DEFAULT_FIFO_ADDR_WIDTH-1 downto 0);
	--type t_en_programmable_fd_depth is array(0 to 31) of std_logic;

	--type t_count_down is array (0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1, 0 to CUR_DEFAULT_NUM_WPPE_VERTICAL-1) of std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto 0);
	type t_count_down is array (0 to CUR_DEFAULT_NUM_WPPE_VERTICAL-1, 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1) of std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto 0);
	type t_pc_debug_outs is array (1 to CUR_DEFAULT_NUM_WPPE_VERTICAL,  1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL) of std_logic_vector(CUR_DEFAULT_ADDR_WIDTH-1 downto 0);

--	type t_tcpa_ic is array (0 to CUR_DEFAULT_NUM_WPPE_VERTICAL-1, 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1) of std_logic_vector(0 to NUM_OF_IC_SIGNALS - 1);

	--Fault injection module
	type t_pe_rows_and_columns is array (CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1 downto 0) of std_logic_vector(CUR_DEFAULT_NUM_WPPE_VERTICAL-1 downto 0);
	type t_array is array (0 to CUR_DEFAULT_NUM_WPPE_VERTICAL-1, 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1) of std_logic;
	type t_fault_injection_module is record
		mask        : std_logic_vector(CUR_DEFAULT_DATA_WIDTH-1 downto 0);
		fu_sel      : std_logic_vector(CUR_DEFAULT_NUM_OF_FUS-1 downto 0);
		pe_sel      : t_array;
	end record t_fault_injection_module;

	constant MAX_NUM_OF_PE_ROWS      : integer := 32;
	constant MAX_NUM_OF_PE_COLUMNS   : integer := 32;
	constant MAX_NUM_ERROR_DIAGNOSIS : integer := 2;
	type t_array_error_diagnosis is array (CUR_DEFAULT_NUM_WPPE_VERTICAL-1 downto 0, CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1 downto 0) of std_logic_vector(MAX_NUM_ERROR_DIAGNOSIS-1 downto 0);
	type t_error_status is record
		irq       : std_logic;
--		pe_rows_and_columns : t_pe_rows_and_columns;
		row       : std_logic_vector(MAX_NUM_OF_PE_ROWS - 1 downto 0);  
		column    : std_logic_vector(MAX_NUM_OF_PE_ROWS - 1 downto 0);  
		index     : std_logic_vector(31 downto 0);  
		--When the Error Handling Unit (EHU) is integrated, it shall provide a MAX_NUM_ERROR_DIAGNOSIS (bit) information per PE 
		diagnosis  : t_array_error_diagnosis;  
	end record t_error_status;

end type_lib;

package body type_lib is
end type_lib;
