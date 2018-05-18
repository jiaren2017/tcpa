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
-- Create Date:    14:47:21 10/24/05
-- Design Name:    
-- Module Name:    wppe_icn_wrapper - Behavioral
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

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;
use wppa_instance_v1_01_a.INVASIC_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wppe_icn_wrapper is
	generic(

		--Ericles:
		N                     : integer                 := 0;
		M                     : integer                 := 0;
		-- cadence translate_off			
		INSTANCE_NAME         : string                  := "test_wppa/first_row_first_column_wppe_icn_1_1";

		-- cadence translate_on	
		--*************************
		-- INTERCONNECT Wrapper GENERICs
		--*************************


		--#############################################
		--######## REAL ADJ_MATRIXES: #################

		--#############################################
		------------------- PE[0,0] -------------------
		--					ADJACENCY_MATRIX		 :t_adjacency_matrix :=
		--(					 
		--"0010100010",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0010010000"
		--);
		--
		--				ADJACENCY_MATRIX_CTRL :t_adjacency_matrix_ctrl :=
		--(	 
		--"0010000011",
		--"0000000010",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0000000000",
		--"0010100000",
		--"0000100000"
		--);

		--#############################################
		----------- PE0[0,1] --------------------------
		--		ADJACENCY_MATRIX		 :t_adjacency_matrix :=
		--(	 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000010", 
		--"0000000001", 
		--"0000000010", 
		--"0000000000", 
		--"1000000000"
		--);
		--
		--		ADJACENCY_MATRIX_CTRL :t_adjacency_matrix_ctrl :=
		--(	
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000010", 
		--"0000000001", 
		--"0000000010", 
		--"0000000010", 
		--"1000000000", 
		--"1000000000"
		--);

		--#############################################
		----------- PE[1,0] ---------------------------
		--		ADJACENCY_MATRIX		 :t_adjacency_matrix :=
		--(	 
		--"0000000010", 
		--"0000000001", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0011000000"
		--);
		--
		--		ADJACENCY_MATRIX_CTRL :t_adjacency_matrix_ctrl :=
		--(	
		--"0000000011", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0010000000", 
		--"0001000000"
		--);
		--
		--
		--#############################################
		----------- PE[1,1] ---------------------------
		--		ADJACENCY_MATRIX		 :t_adjacency_matrix :=
		--(	 
		--"0000000010", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000010", 
		--"0000000001", 
		--"1100000000"
		--);
		--
		--		ADJACENCY_MATRIX_CTRL :t_adjacency_matrix_ctrl :=
		--(	
		--"0000000010", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000000", 
		--"0000000010", 
		--"0000000001", 
		--"1000000000", 
		--"0100000000"
		--);

		------------------------------------------------------------------------------------------------------------
		--######## END REAL ADJ_MATRIXES ##############
		--#############################################

		--======================= ??? =================================================================================================			
		ADJACENCY_MATRIX      : t_adjacency_matrix      := CUR_DEFAULT_ADJACENCY_MATRIX;
		--(
		----N	  E				S		 W				  PE_in
		--"00" & "10000000" & "00" & "00000000" & "1000", --N 0 .. 1 
		--"00" & "01000000" & "00" & "00000000" & "0100",
		--
		--"00" & "00000000" & "00" & "00000000" & "0010",	--E 0 .. 7
		--"00" & "00000000" & "00" & "00000000" & "0001",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--
		--"00" & "00000000" & "00" & "00000000" & "0000",	--S 0 .. 1
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--
		--"00" & "00000000" & "00" & "00000000" & "0000",	--W 0 .. 7
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",
		--"00" & "00000000" & "00" & "00000000" & "0000",	
		--
		--"00" & "00000000" & "10" & "00000000" & "0000", --PE_out 0 .. 1
		--"00" & "00000000" & "01" & "00000000" & "0000"
		--
		--);
		--
		ADJACENCY_MATRIX_CTRL : t_adjacency_matrix_ctrl := CUR_DEFAULT_ADJACENCY_MATRIX_CTRL;
		--(
		--"11111",
		--"00000",
		--"00000",
		--"00000",
		--"11111"
		--);

		--( 
		--"0001000000",
		--"0001000000",
		--"0100100000",
		--"0100000010",
		--"0000000100",
		--"0000000010",
		--"0000001000",
		--"0000000000",
		--"0010010000"
		--);
		--

		--(			
		--"1010000010",                      
		--"0000000000",
		--"1010010010",
		--"0000000000",
		--"0000010000",
		--"0000000000",
		--"0001000100",
		--"0000000000",
		--"0001000100",												 
		--"0000000000" 
		--);
		--========================================================================================================================

		--========================= OK ===============================================================================================			
		--			ADJACENCY_MATRIX		 :t_adjacency_matrix := --; --:= --(others => (others => '0'));--CUR_DEFAULT_ADJACENCY_MATRIX;
		--
		--( 
		--"0010101000",
		--"0001000000",
		--"0000100000",
		--"1000000010",
		--"0000000100",
		--"0000000010",
		--"1000001000",
		--"0000000000",
		--"0010010000"
		--);
		--
		--			ADJACENCY_MATRIX_CTRL :t_adjacency_matrix_ctrl := --CUR_DEFAULT_ADJACENCY_MATRIX_CTRL;
		--(			
		--"0000000010",                      
		--"0000000000",
		--"0000010010",
		--"0000000000",
		--"0000010000",
		--"0000000000",
		--"0001000100",
		--"0000000000",
		--"0001000100",												 
		--"0100000000" 
		--);	
		--========================================================================================================================
		-------------------------------------------------------------------------------------------------	

		--			--*************************
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
		--ctrl_inputs		  :in	std_logic_vector(
		--WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS -1 downto 0); -- 1 Bit width
		--			------------------------------------------
		--			ctrl_outputs	  :out std_logic_vector(
		--							WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS -1 downto 0); -- 1 Bit width
		------------------------------------------
		------------------------------------------
		config_mem_data               : in  std_logic_vector(WPPE_GENERICS_RECORD.SOURCE_DATA_WIDTH - 1 downto 0);
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
		------------------------------------------
		------------------------------------------
		south_inputs_ctrl             : in  std_logic_vector(SOUTH_INPUT_WIDTH_CTRL * SOUTH_PIN_NUM_CTRL - 1 downto 0);
		south_outputs_ctrl            : out std_logic_vector(NORTH_INPUT_WIDTH_CTRL * NORTH_PIN_NUM_CTRL - 1 downto 0);
		------------------------------------------
		------------------------------------------
		east_inputs_ctrl              : in  std_logic_vector(EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto 0);
		east_outputs_ctrl             : out std_logic_vector(WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto 0);
		------------------------------------------
		------------------------------------------
		west_inputs_ctrl              : in  std_logic_vector(WEST_INPUT_WIDTH_CTRL * WEST_PIN_NUM_CTRL - 1 downto 0);
		west_outputs_ctrl             : out std_logic_vector(EAST_INPUT_WIDTH_CTRL * EAST_PIN_NUM_CTRL - 1 downto 0);

		vliw_config_en               : in std_logic;
		icn_config_en                : in std_logic;
		common_config_reset          : in std_logic;
		--Ericles Sousa on 16 Dec 2014: setting the configuration_done signal. I will be connected to the top file
		configuration_done            : out std_logic;
		mask                          : in std_logic_vector(CUR_DEFAULT_DATA_WIDTH-1 downto 0);
		fu_sel                        : in std_logic_vector(CUR_DEFAULT_NUM_OF_FUS-1 downto 0); 
		pe_sel                        : in std_logic; 
		error_flag                    : out std_logic;
		error_diagnosis               : out std_logic_vector(MAX_NUM_ERROR_DIAGNOSIS-1 downto 0);
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
-- pragma translate_off
-- cadence translate_on
----attribute TEMPLATE of wppe_icn_wrapper: entity is TRUE;
-- pragma translate_on
end wppe_icn_wrapper;

architecture Behavioral of wppe_icn_wrapper is


	signal zero_sig : t_inv_sig;

	component ICP_VHDL_wrapper is
		port(
			input_0         : in  std_logic_vector(19 downto 0);
			input_1         : in  std_logic_vector(19 downto 0);
			input_2         : in  std_logic_vector(19 downto 0);
			input_3         : in  std_logic_vector(19 downto 0);
			input_4         : in  std_logic_vector(19 downto 0);

			output_0        : out std_logic_vector(19 downto 0);
			output_1        : out std_logic_vector(19 downto 0);
			output_2        : out std_logic_vector(19 downto 0);
			output_3        : out std_logic_vector(19 downto 0);
			output_4        : out std_logic_vector(19 downto 0);

			clk, rst        : in  std_logic;

			prog_data_intfc : in  std_logic_vector(29 downto 0);
			prog_addr_intfc : in  std_logic_vector(5 downto 0);
			prog_wr_en      : in  std_logic;
			start           : in  std_logic
		);
	end component;

	--===============================================================================--		
	--             POWER CONTROLLER COMPONENT
	--===============================================================================--	

	COMPONENT PWR_CONTROLLER is
		generic(
			-- cadence translate_off			
			INSTANCE_NAME        : string                 := "?";
			-- cadence translate_on	
			WPPE_GENERICS_RECORD : t_wppe_generics_record := CUR_DEFAULT_WPPE_GENERICS_RECORD
		);

		port(
			clk, reset : std_logic;
			input      : in  std_logic_vector(1 downto 0); -- SEE TYPE_LIB.vhd FOR DEFINITIONS
			output     : out std_logic_vector(5 downto 0)
		);

	END COMPONENT;

	--===============================================================================--		
	--             POWER CONTROLLER COMPONENT
	--===============================================================================--	



	--##############################################################################--
	-- WPPE COMPONENT DECLARATION--
	--##############################################################################--

	component wppe_2 is
		generic(
			--Ericles:
			N                    : integer := 0;
			M                    : integer := 0;
			-- cadence translate_off	
			INSTANCE_NAME        : string;

			-- cadence translate_on	
			--*************************
			-- Weakly Programmable Processing Element's (WPPE) GENERICs
			--*************************

			WPPE_GENERICS_RECORD : t_wppe_generics_record
		-- := CUR_DEFAULT_WPPE_GENERICS_RECORD


		);

		port(
			ff_start_detection            : in  std_logic;
			set_to_config                 : in  std_logic;

			pc_debug_out                  : out std_logic_vector(WPPE_GENERICS_RECORD.ADDR_WIDTH - 1 downto 0);

			input_registers               : in  std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG * WPPE_GENERICS_RECORD.DATA_WIDTH - 1 downto 0);
			output_registers              : out std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG * WPPE_GENERICS_RECORD.DATA_WIDTH - 1 downto 0);

			--			ctrl_inputs		  :in	std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS -1 downto 0); -- 1 Bit width
			--			ctrl_outputs	  :out std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS -1 downto 0); -- 1 Bit width

			ctrl_inputs                   : in  std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS * WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
			ctrl_outputs                  : out std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS * WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

			input_fifos_write_en          : in  std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1 downto 0);

			config_mem_data               : in  std_logic_vector(WPPE_GENERICS_RECORD.SOURCE_DATA_WIDTH - 1 downto 0);

		 	vliw_config_en               : in std_logic;
		 	icn_config_en                : in std_logic;
			common_config_reset          : in std_logic;
			--Ericles Sousa on 16 Dec 2014: setting the configuration_done signal. I will be connected to the top file
			configuration_done            : out std_logic;
			mask                          : in std_logic_vector(CUR_DEFAULT_DATA_WIDTH-1 downto 0);
			fu_sel                        : in std_logic_vector(CUR_DEFAULT_NUM_OF_FUS-1 downto 0); 
			pe_sel                        : in std_logic; 
			error_flag                    : out std_logic;
			error_diagnosis               : out std_logic_vector(MAX_NUM_ERROR_DIAGNOSIS-1 downto 0);
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

	--   port( set_to_config    : in  std_logic;  
	--	      pc_debug_out     : out std_logic_vector(3 downto 0);  
	--         input_registers  : in  std_logic_vector(63 downto 0);  
	--			output_registers : out std_logic_vector(31 downto 0);  
	--			ctrl_inputs      : in  std_logic_vector(0 downto 0);  
	--			ctrl_outputs     : out std_logic_vector(0 downto 0);
	--			input_fifos_write_en : in std_logic_vector(3 downto 0);  
	--         config_mem_data  : in std_logic_vector(31 downto 0);  
	--			config_reg_we    : out std_logic;  
	--         config_reg_data  : out std_logic_vector(5 downto 0);  
	--			config_reg_addr  : out std_logic_vector(2 downto 0);
	--			clk, rst         : in std_logic
	--			);

	end component wppe_2;

	--===============================================================================--
	--===============================================================================--

	--##############################################################################--
	-- CONFIGURATION REGISTER FILE COMPONENT DECLARATION--
	--##############################################################################--

	component mux_sel_config_file is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME               : string;

			-- cadence translate_on

			NORTH_TOTAL_SEL_WIDTH       : integer range 0 to MAX_CONFIG_REG_WIDTH; -- := 2;
			EAST_TOTAL_SEL_WIDTH        : integer range 0 to MAX_CONFIG_REG_WIDTH; -- := 2;
			SOUTH_TOTAL_SEL_WIDTH       : integer range 0 to MAX_CONFIG_REG_WIDTH; -- := 2;
			WEST_TOTAL_SEL_WIDTH        : integer range 0 to MAX_CONFIG_REG_WIDTH; -- := 2;
			WPPE_INPUTS_TOTAL_SEL_WIDTH : integer range 0 to MAX_CONFIG_REG_WIDTH; -- := 2;

			--CONFIG_FILE_ADDR_WIDTH :positive range 1 to 7;
			--CONFIG_FILE_SIZE		  :positive range 2 to 128;
			CONFIG_REG_WIDTH            : integer range MIN_CONFIG_REG_WIDTH to MAX_CONFIG_REG_WIDTH
		-- := CUR_DEFAULT_CONFIG_REG_WIDTH

		);

		port(
			clk, rst                : in  std_logic;
			we                      : in  std_logic;

			new_data_input          : in  std_logic_vector(CONFIG_REG_WIDTH - 1 downto 0);
			addr_input              : in  std_logic_vector(2 downto 0);

			NORTH_OUT_mux_selects   : out std_logic_vector(NORTH_TOTAL_SEL_WIDTH downto 0);
			EAST_OUT_mux_selects    : out std_logic_vector(EAST_TOTAL_SEL_WIDTH downto 0);
			SOUTH_OUT_mux_selects   : out std_logic_vector(SOUTH_TOTAL_SEL_WIDTH downto 0);
			WEST_OUT_mux_selects    : out std_logic_vector(WEST_TOTAL_SEL_WIDTH downto 0);
			WPPE_INPUTS_mux_selects : out std_logic_vector(WPPE_INPUTS_TOTAL_SEL_WIDTH downto 0)
		);

	end component mux_sel_config_file;

	--##############################################################################--
	-- CONNECTION WIRE COMPONENT DECLARATION--
	--##############################################################################--

	component connection is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME     : string;

			-- cadence translate_on	
			INPUT_DATA_WIDTH  : integer range 1 to 32; -- := 16;
			OUTPUT_DATA_WIDTH : integer range 1 to 32 -- := 16


		);

		port(
			input_signal  : in  std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
			output_signal : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
		);

	end component connection;

	--===============================================================================--
	--===============================================================================--

	--##############################################################################--
	-- MULTIPLEXER COMPONENT DECLARATION--
	--##############################################################################--

	component wppe_multiplexer is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME     : string;

			-- cadence translate_on	
			INPUT_DATA_WIDTH  : positive range 1 to 64; -- := 16;
			OUTPUT_DATA_WIDTH : positive range 1 to 64; -- := 32;
			SEL_WIDTH         : positive range 1 to 16; -- := 3;		
			NUM_OF_INPUTS     : positive range 1 to 64 -- := 8	

		);

		port(
			data_inputs : in  std_logic_vector(INPUT_DATA_WIDTH * NUM_OF_INPUTS - 1 downto 0);
			sel         : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			output      : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
		);

	end component;

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
	--CONSTANT TYPE_OF_FEEDBACK_FIFO_RAM :std_logic_vector(NUM_OF_FEEDBACK_FIFOS  downto 0) 
	--										:= WPPE_GENERICS_RECORD.TYPE_OF_FEEDBACK_FIFO_RAM;
	--CONSTANT SIZES_OF_FEEDBACK_FIFOS :t_fifo_sizes(NUM_OF_FEEDBACK_FIFOS  downto 0)  
	--										:= WPPE_GENERICS_RECORD.SIZES_OF_FEEDBACK_FIFOS;
	--CONSTANT FB_FIFOS_ADDR_WIDTH	:t_fifo_sizes(NUM_OF_FEEDBACK_FIFOS  downto 0) 
	--										:= WPPE_GENERICS_RECORD.FB_FIFOS_ADDR_WIDTH;

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

	--===============================================================================--
	--===============================================================================--
	-- Filling the additional information IMplicitly given in the
	-- adjacency matrix into the EXplicit form in the MULTI_SOURCE_MATRIX
	-- variable

	CONSTANT MULTI_SOURCE_MATRIX : t_multi_source_info_matrix := fill_out_the_multisource_matrix(ADJACENCY_MATRIX,
		                                                                                         WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG,
		                                                                                         WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG,
		                                                                                         WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH
	);

	--#################
	--### CTRL_ICN: ###
	CONSTANT MULTI_SOURCE_MATRIX_CTRL : t_multi_source_info_matrix_ctrl := fill_out_the_multisource_matrix_ctrl(ADJACENCY_MATRIX_CTRL,
		                                                                                                        WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS,
		                                                                                                        WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS,
		                                                                                                        WPPE_GENERICS_RECORD.CTRL_REG_WIDTH
	);

	--##################################################################################

	--=================================================================
	--=================================================================
	-- NORTH concatenated vectors lengths

	CONSTANT MULTIPLEXED_NORTH_OUTPUT_DRIVERS_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, 0, SOUTH_PIN_NUM - 1, '1');
	-- '1' ==> data_width

	CONSTANT NORTH_TOTAL_MUX_SEL_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, 0, SOUTH_PIN_NUM - 1, '0');
	-- '0' ==> select_width 

	--=================================================================
	-- EAST concatenated vectors lengths

	CONSTANT MULTIPLEXED_EAST_OUTPUT_DRIVERS_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, SOUTH_PIN_NUM,
		                                                                                     SOUTH_PIN_NUM + WEST_PIN_NUM - 1, '1');
	-- '1' ==> data_width

	CONSTANT EAST_TOTAL_MUX_SEL_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, SOUTH_PIN_NUM,
		                                                                        SOUTH_PIN_NUM + WEST_PIN_NUM - 1, '0');
	-- '0' ==> select width
	--=================================================================
	-- SOUTH concatenated vectors lengths

	CONSTANT MULTIPLEXED_SOUTH_OUTPUT_DRIVERS_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, SOUTH_PIN_NUM + WEST_PIN_NUM,
		                                                                                      SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM - 1, '1');
	-- '1' ==> data_width


	CONSTANT SOUTH_TOTAL_MUX_SEL_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, SOUTH_PIN_NUM + WEST_PIN_NUM,
		                                                                         SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM - 1, '0');
	-- '0' ==> select width

	--=================================================================
	-- WEST concatenated vectors lengths

	CONSTANT MULTIPLEXED_WEST_OUTPUT_DRIVERS_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM,
		                                                                                     SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM - 1, '1');
	-- '1' ==> data_width

	CONSTANT WEST_TOTAL_MUX_SEL_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM,
		                                                                        SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM - 1, '0');
	-- '0' ==> select width				

	--=================================================================
	-- WPPE input registers concatenated vectors lengths

	CONSTANT MULTIPLEXED_WPPE_INPUT_DRIVERS_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM,
		                                                                                    SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1, '1');
	-- '1' ==> data_width

	CONSTANT WPPE_INPUT_TOTAL_MUX_SEL_WIDTH : integer := calculate_total_signal_width(MULTI_SOURCE_MATRIX, SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM,
		                                                                              SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1, '0');
	-- '0' ==> select width

	--=================================================================
	--=================================================================


	--#################
	--### CTRL_ICN: ###
	-- NORTH concatenated vectors lengths

	CONSTANT MULTIPLEXED_NORTH_OUTPUT_DRIVERS_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, 0, SOUTH_PIN_NUM_CTRL - 1, '1');
	-- '1' ==> data_width

	CONSTANT NORTH_TOTAL_MUX_SEL_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, 0, SOUTH_PIN_NUM_CTRL - 1, '0');
	-- '0' ==> select_width 

	--=================================================================
	-- EAST concatenated vectors lengths

	CONSTANT MULTIPLEXED_EAST_OUTPUT_DRIVERS_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, SOUTH_PIN_NUM_CTRL,
		                                                                                               SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1, '1');
	-- '1' ==> data_width

	CONSTANT EAST_TOTAL_MUX_SEL_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, SOUTH_PIN_NUM_CTRL,
		                                                                                  SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1, '0');
	-- '0' ==> select width
	--=================================================================
	-- SOUTH concatenated vectors lengths

	CONSTANT MULTIPLEXED_SOUTH_OUTPUT_DRIVERS_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL,
		                                                                                                SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL - 1, '1');
	-- '1' ==> data_width


	CONSTANT SOUTH_TOTAL_MUX_SEL_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL,
		                                                                                   SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL - 1, '0');
	-- '0' ==> select width

	--=================================================================
	-- WEST concatenated vectors lengths

	CONSTANT MULTIPLEXED_WEST_OUTPUT_DRIVERS_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL,
		                                                                                               SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1, '1');
	-- '1' ==> data_width

	CONSTANT WEST_TOTAL_MUX_SEL_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL,
		                                                                                  SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1, '0');
	-- '0' ==> select width				

	--=================================================================
	-- WPPE input registers concatenated vectors lengths

	CONSTANT MULTIPLEXED_WPPE_INPUT_DRIVERS_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL,
		                                                                                              SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS - 1, '1'); -- '1' ==> data_width

	CONSTANT WPPE_INPUT_TOTAL_MUX_SEL_WIDTH_CTRL : integer := calculate_total_signal_width_ctrl(MULTI_SOURCE_MATRIX_CTRL, SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL,
		                                                                                        SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS - 1, '0'); -- '0' ==> select width
	--###########################################################


	--##############################################################################--
	-- TYPE DECLARATIONS
	--##############################################################################--

	---------------------------------------------------
	-- Additional types declaration for the multiplexer	  
	---------------------------------------------------

	-- Layout:									
	------------------------------------------------------------------------------------
	-- DRIVERS for the north_output_x   | 	  ...   | DRIVERS for the north_output 0
	------------------------------------------------------------------------------------
	-- last_driver & ... & first_driver | &  ... & | last_driver & ... & first_driver
	------------------------------------------------------------------------------------
	--	Z			...					Y		|	...	  | X				...				2	1	 0
	------------------------------------------------------------------------------------

	subtype t_north_output_drivers is std_logic_vector(MULTIPLEXED_NORTH_OUTPUT_DRIVERS_WIDTH downto 0);

	-- Layout:									
	-----------------------------------------------------------------------------------------------
	-- Selects for the north_output_x multiplexer   | 	  ...   | Selects for the north_output 0 mux
	-----------------------------------------------------------------------------------------------
	--	Z			...					             Y		|	...	  | X		...			 	   2	  1   0
	-----------------------------------------------------------------------------------------------
	subtype t_north_mux_selects is std_logic_vector(NORTH_TOTAL_MUX_SEL_WIDTH downto 0);

	--===============================================================================--
	subtype t_east_output_drivers is std_logic_vector(MULTIPLEXED_EAST_OUTPUT_DRIVERS_WIDTH downto 0);

	subtype t_east_mux_selects is std_logic_vector(EAST_TOTAL_MUX_SEL_WIDTH downto 0);

	--===============================================================================--
	subtype t_south_output_drivers is std_logic_vector(MULTIPLEXED_SOUTH_OUTPUT_DRIVERS_WIDTH downto 0);

	subtype t_south_mux_selects is std_logic_vector(SOUTH_TOTAL_MUX_SEL_WIDTH downto 0);

	--===============================================================================--
	subtype t_west_output_drivers is std_logic_vector(MULTIPLEXED_WEST_OUTPUT_DRIVERS_WIDTH downto 0);

	subtype t_west_mux_selects is std_logic_vector(WEST_TOTAL_MUX_SEL_WIDTH downto 0);

	--===============================================================================--

	subtype t_wppe_input_drivers is std_logic_vector(MULTIPLEXED_WPPE_INPUT_DRIVERS_WIDTH downto 0);

	subtype t_wppe_input_mux_selects is std_logic_vector(WPPE_INPUT_TOTAL_MUX_SEL_WIDTH downto 0);

	--===============================================================================--
	--===============================================================================--

	type t_reg_width is array (integer range <>) of std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

	--#################
	--### CTRL_ICN: ###
	subtype t_north_output_drivers_ctrl is std_logic_vector(MULTIPLEXED_NORTH_OUTPUT_DRIVERS_WIDTH_CTRL downto 0);

	subtype t_north_mux_selects_ctrl is std_logic_vector(NORTH_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	-----------------------------------------------------------------------------------------------
	subtype t_east_output_drivers_ctrl is std_logic_vector(MULTIPLEXED_EAST_OUTPUT_DRIVERS_WIDTH_CTRL downto 0);

	subtype t_east_mux_selects_ctrl is std_logic_vector(EAST_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	-----------------------------------------------------------------------------------------------
	subtype t_south_output_drivers_ctrl is std_logic_vector(MULTIPLEXED_SOUTH_OUTPUT_DRIVERS_WIDTH_CTRL downto 0);

	subtype t_south_mux_selects_ctrl is std_logic_vector(SOUTH_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	-----------------------------------------------------------------------------------------------
	subtype t_west_output_drivers_ctrl is std_logic_vector(MULTIPLEXED_WEST_OUTPUT_DRIVERS_WIDTH_CTRL downto 0);

	subtype t_west_mux_selects_ctrl is std_logic_vector(WEST_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	-----------------------------------------------------------------------------------------------
	subtype t_wppe_input_drivers_ctrl is std_logic_vector(MULTIPLEXED_WPPE_INPUT_DRIVERS_WIDTH_CTRL downto 0);

	subtype t_wppe_input_mux_selects_ctrl is std_logic_vector(WPPE_INPUT_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	-----------------------------------------------------------------------------------------------
	type t_reg_width_ctrl is array (integer range <>) of std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
	--####################################################


	--##############################################################################--
	-- SIGNAL DECLARATIONS
	--##############################################################################--

	--#################################################################################
	-- CONFIGURATION START SIGNAL
	--#################################################################################

	signal set_to_config : std_logic;

	--#################################################################################
	-- SIGNALS TO THE CONFIGURATION REGISTER FILE
	-- FROM THE GENERIC_LOADER component instantiated in
	-- the WPPE_2 component
	--#################################################################################

	signal internal_config_reg_we   : std_logic;
	signal internal_config_reg_data : std_logic_vector(
		WPPE_GENERICS_RECORD.CONFIG_REG_WIDTH - 1 downto 0);
	signal internal_config_reg_addr : std_logic_vector(2 downto 0);

	--#################################################################################


	--===============================================================================--		
	--             POWER CONTROLLER SIGNALS
	--===============================================================================--	

	signal pwr_controller_inputs  : std_logic_vector(1 downto 0); -- SEE TYPE_LIB.vhd for DEFINITIONS
	signal pwr_controller_outputs : std_logic_vector(5 downto 0);

	signal pwr_controlled_clk : std_logic;
	signal pwr_controlled_rst : std_logic;

	--===============================================================================--		
	--             POWER CONTROLLER SIGNALS
	--===============================================================================--	


	-- Output-multiplexers input and select signals

	signal north_output_all_mux_ins : t_north_output_drivers;
	signal north_output_mux_selects : t_north_mux_selects;

	signal east_output_all_mux_ins : t_east_output_drivers;
	signal east_output_mux_selects : t_east_mux_selects;

	signal south_output_all_mux_ins : t_south_output_drivers;
	signal south_output_mux_selects : t_south_mux_selects;

	signal west_output_all_mux_ins : t_west_output_drivers;
	signal west_output_mux_selects : t_west_mux_selects;

	signal wppe_input_all_mux_ins : t_wppe_input_drivers;
	signal wppe_input_mux_selects : t_wppe_input_mux_selects;

	-- WPPE register signals

	signal wppe_input_regs  : t_reg_width(0 to WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG); -- internal array'ed signal of input registers	 of WPPE
	signal wppe_output_regs : t_reg_width(0 to WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG); -- internal array'ed signal of output registers of WPPE

	signal wppe_input_regs_vector  : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG * WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);
	signal wppe_output_regs_vector : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG * WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

	--signal north_ms_pins_mux_ins :t_north_ms_mux_ins(0 to NORTH_MULTI_SOURCE_PIN_NUM,
	--														 0 to NORTH_OUTPUT_DRIVER_NUM);

	--#################
	--### CTRL_ICN: ###														  
	-- Output-multiplexers input and select signals

	signal north_output_all_mux_ins_ctrl : t_north_output_drivers_ctrl;
	signal north_output_mux_selects_ctrl : t_north_mux_selects_ctrl;

	signal east_output_all_mux_ins_ctrl : t_east_output_drivers_ctrl;
	signal east_output_mux_selects_ctrl : t_east_mux_selects_ctrl;

	signal south_output_all_mux_ins_ctrl : t_south_output_drivers_ctrl;
	signal south_output_mux_selects_ctrl : t_south_mux_selects_ctrl;

	signal west_output_all_mux_ins_ctrl : t_west_output_drivers_ctrl;
	signal west_output_mux_selects_ctrl : t_west_mux_selects_ctrl;

	signal wppe_input_all_mux_ins_ctrl : t_wppe_input_drivers_ctrl;
	signal wppe_input_mux_selects_ctrl : t_wppe_input_mux_selects_ctrl;

	-- WPPE ctrl register signals

	signal wppe_input_regs_ctrl  : t_reg_width_ctrl(0 to WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS) := (others=>(others=>'0')); -- internal array'ed signal of input registers	 of WPPE
	signal wppe_output_regs_ctrl : t_reg_width_ctrl(0 to WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS) := (others=>(others=>'0')); -- internal array'ed signal of output registers of WPPE

	signal wppe_input_regs_vector_ctrl  : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS * WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) := (others=>'0');
	signal wppe_output_regs_vector_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS * WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) := (others=>'0');

	--############################################################
	--------------------------------------------------------------


	--##############################################################################--
	-- LAYOUT of the several NORTH/SOUTH/EAST/WEST in/output signals 
	--##############################################################################--

	-- NORTH_INPUT_x & NORTH_INPUT_x-1 & NORTH_INPUT_x-2 ... & NORTH_INPUT_3 							& NORTH_INPUT_2   					& 		NORTH_INPUT_1
	--																																		 
	--																	... 						 | 2*NORTH_INPUT_WIDTH-1 ...	NORTH_INPUT_WIDTH  |  NORTH_INPUT_WIDTH -1 ... 0


	--===============================================================================--
	--===============================================================================--

	--#############################################################
	--#### COMMON SELECT SIGNSLS (DATA and CTRL MUX's SELECTS):	###
	signal NORTH_OUT_mux_selects_all  : std_logic_vector(NORTH_TOTAL_MUX_SEL_WIDTH + NORTH_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	signal EAST_OUT_mux_selects_all   : std_logic_vector(EAST_TOTAL_MUX_SEL_WIDTH + EAST_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	signal SOUTH_OUT_mux_selects_all  : std_logic_vector(SOUTH_TOTAL_MUX_SEL_WIDTH + SOUTH_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	signal WEST_OUT_mux_selects_all   : std_logic_vector(WEST_TOTAL_MUX_SEL_WIDTH + WEST_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	signal WPPE_INPUT_mux_selects_all : std_logic_vector(WPPE_INPUT_TOTAL_MUX_SEL_WIDTH + WPPE_INPUT_TOTAL_MUX_SEL_WIDTH_CTRL downto 0);
	
	signal mux_east_out_signal_ctrl    : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal mux_east_select_signal_ctrl : std_logic_vector(MULTI_SOURCE_MATRIX_CTRL(2, 1) - 1 downto 0) := (others=>'0');
	signal N_E_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal N_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal E_E_east_in_signal_ctrl  : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal E_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal S_E_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal S_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal W_E_west_in_signal_ctrl  : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal W_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');
	signal WPPE_E_wppe_in_signal_ctrl  : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) := (others=>'0');
	signal WPPE_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0) := (others=>'0');

--#################################
--###################################
--#####################################
BEGIN                                   --##############################
	--#########################################
	--###########################################
	--#############################################


	zero_sig <= (others => '0');

	-- inv_controller_inst : ICP_VHDL_wrapper port map(
	--
	--  input_0 => zero_sig,
	--  input_1 => inv_interface_north_in,
	--  input_2 => inv_interface_east_in,
	--  input_3 => inv_interface_south_in,
	--  input_4 => inv_interface_west_in,
	--  
	--  output_0 => open,
	--  output_1 => inv_interface_north_out,
	--  output_2 => inv_interface_east_out,
	--  output_3 => inv_interface_south_out,
	--  output_4 => inv_interface_west_out,
	--  
	--  clk => clk,
	--  rst => rst,
	--  
	--  prog_data_intfc => inv_prog_data,
	--  prog_addr_intfc => inv_prog_addr,
	--  prog_wr_en      => inv_prog_wr_en,
	--  start           => inv_start
	--
	--); 


	--***********************************
	-- POWER SHUTOFF AUXILIARY SIGNAL
	--***********************************

	pwr_controller_inputs(power_down_bit) <= (rst OR (not set_to_config) OR ff_start_detection);

	--		set_power_on :process(clk, rst)
	--
	--		begin
	--
	--				if rst = '1' then
	--		
	--					pwr_controller_inputs(power_down_bit) <= '1'; -- default state of PE: POWER_DOWN
	--		
	--				else --if clk'event and clk = '1' then
	--
	--						if ( ff_start_detection = '0'  AND set_to_config = '1' )  then
	--						-- power up PE on first SET_TO_CONFIG signal
	--							pwr_controller_inputs(power_down_bit) <= '0'; 
	--						end if;
	--
	--					--end if;
	--
	--				end if;
	--
	--		end process set_power_on;
	--
	--***********************************


	--##############################################################################
	--    POWER GATING RELATED CLOCK GATING SIGNAL CONNECTION
	--##############################################################################

	PWR_GATING_CLK_GATING : if POWER_GATING generate
		pwr_controlled_clk <= clk and (NOT pwr_controller_outputs(clk_so_bit));

		pwr_controlled_rst <= rst OR pwr_controller_outputs(pwr_up_reset_bit);

	--  	  	PWR_GATING_CLK_GATING_clk: my_CG_MOD   
	--			port map(
	--				ck_in  => clk,
	--				enable => pwr_controller_outputs(clk_so_bit),
	--				test	 => zero_signal,--'0',
	--				ck_out => pwr_controlled_clk
	--			);

	end generate;

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	NO_PWR_GATING : if not POWER_GATING generate
		pwr_controlled_clk <= clk;
		pwr_controlled_rst <= rst;
	end generate;

	--#################################################################################
	-- CONFIGURATION START SIGNAL
	--#################################################################################

	set_to_config <= horizontal_set_to_config AND vertical_set_to_config;

	--#################################################################################
	--#################################################################################


	--#############################################################
	--#### COMMON SELECT SIGNALS (DATA and CTRL MUX's SELECTS):	###

	--###############################
	--###############################
	--### SELECTS <= SELECTS_ALL: ###

	north_output_mux_selects(NORTH_TOTAL_MUX_SEL_WIDTH downto 0)    <= NORTH_OUT_mux_selects_all(NORTH_TOTAL_MUX_SEL_WIDTH downto 0);
	east_output_mux_selects(EAST_TOTAL_MUX_SEL_WIDTH downto 0)      <= EAST_OUT_mux_selects_all(EAST_TOTAL_MUX_SEL_WIDTH downto 0);
	south_output_mux_selects(SOUTH_TOTAL_MUX_SEL_WIDTH downto 0)    <= SOUTH_OUT_mux_selects_all(SOUTH_TOTAL_MUX_SEL_WIDTH downto 0);
	west_output_mux_selects(WEST_TOTAL_MUX_SEL_WIDTH downto 0)      <= WEST_OUT_mux_selects_all(WEST_TOTAL_MUX_SEL_WIDTH downto 0);
	wppe_input_mux_selects(WPPE_INPUT_TOTAL_MUX_SEL_WIDTH downto 0) <= WPPE_INPUT_mux_selects_all(WPPE_INPUT_TOTAL_MUX_SEL_WIDTH downto 0);

	north_output_mux_selects_ctrl(NORTH_TOTAL_MUX_SEL_WIDTH_CTRL downto 0) <= NORTH_OUT_mux_selects_all(NORTH_TOTAL_MUX_SEL_WIDTH_CTRL + NORTH_TOTAL_MUX_SEL_WIDTH downto NORTH_TOTAL_MUX_SEL_WIDTH);

	east_output_mux_selects_ctrl(EAST_TOTAL_MUX_SEL_WIDTH_CTRL downto 0) <= EAST_OUT_mux_selects_all(EAST_TOTAL_MUX_SEL_WIDTH_CTRL + EAST_TOTAL_MUX_SEL_WIDTH downto EAST_TOTAL_MUX_SEL_WIDTH);

	south_output_mux_selects_ctrl(SOUTH_TOTAL_MUX_SEL_WIDTH_CTRL downto 0) <= SOUTH_OUT_mux_selects_all(SOUTH_TOTAL_MUX_SEL_WIDTH_CTRL + SOUTH_TOTAL_MUX_SEL_WIDTH downto SOUTH_TOTAL_MUX_SEL_WIDTH);

	west_output_mux_selects_ctrl(WEST_TOTAL_MUX_SEL_WIDTH_CTRL downto 0) <= WEST_OUT_mux_selects_all(WEST_TOTAL_MUX_SEL_WIDTH_CTRL + WEST_TOTAL_MUX_SEL_WIDTH downto WEST_TOTAL_MUX_SEL_WIDTH);

	wppe_input_mux_selects_ctrl(WPPE_INPUT_TOTAL_MUX_SEL_WIDTH_CTRL downto 0) <= WPPE_INPUT_mux_selects_all(WPPE_INPUT_TOTAL_MUX_SEL_WIDTH_CTRL + WPPE_INPUT_TOTAL_MUX_SEL_WIDTH downto WPPE_INPUT_TOTAL_MUX_SEL_WIDTH);
	--#############################################################


	--===============================================================================--		
	--             POWER CONTROLLER INSTANCE
	--===============================================================================--	

	PWR_CONTROLLER_GENERATION : IF POWER_GATING GENERATE
		power_controller : PWR_CONTROLLER
			generic map(

				-- cadence translate_off			
				INSTANCE_NAME        => INSTANCE_NAME & "/pwr_controller",
				-- cadence translate_on	

				WPPE_GENERICS_RECORD => WPPE_GENERICS_RECORD
			)
			port map(
				clk    => clk,
				reset  => rst,
				input  => pwr_controller_inputs,
				output => pwr_controller_outputs
			);

	END GENERATE;

	NO_PWR_CONTROLLER_GENERATION : IF NOT POWER_GATING GENERATE
		pwr_controller_outputs <= (others => '0');
		pwr_controller_inputs  <= (others => '0');

	END GENERATE;

	--===============================================================================--		
	--             POWER CONTROLLER INSTANCE
	--===============================================================================--	

	--=========================================================================================
	--=========================================================================================


	--=========================================================================================
	--=========================================================================================


	-- CONNECTING THE VECTOR OUTPUT SIGNALS FROM THE WPPE
	-- with the ARRAY'ed signals

	--=================================================================================--

	WPPE_OUT_CONNECT : IF (WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG > 0) GENERATE
		out_reg_connection : FOR i in 0 to WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG - 1 GENERATE
			wppe_output_regs(i) <= wppe_output_regs_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH * (i + 1) - 1 downto WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH * i);
		END GENERATE out_reg_connection;
	END GENERATE;

	--=================================================================================--
	--=================================================================================--

	-- CONNECTING THE ARRAY'ed INPUT SIGNALS TO THE WPPE
	-- vector signals

	--=================================================================================--

	WPPE_IN_CONNECT : IF (WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG > 0) GENERATE
		in_reg_connection : FOR i in 0 to WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1 GENERATE
			wppe_input_regs_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH * (i + 1) - 1 downto WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH * i) <= wppe_input_regs(i);
		END GENERATE in_reg_connection;
	END GENERATE;

	--=================================================================================--
	--=================================================================================--
	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	WPPE_OUT_CONNECT_CTRL : IF (WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS > 0) GENERATE
		out_reg_connection_CTRL : FOR i in 0 to WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS - 1 GENERATE
			wppe_output_regs_ctrl(i) <= wppe_output_regs_vector_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH * (i + 1) - 1 downto WPPE_GENERICS_RECORD.CTRL_REG_WIDTH * i);
		END GENERATE out_reg_connection_CTRL;
	END GENERATE;
	--=================================================================================--
	--=================================================================================--

	-- CONNECTING THE ARRAY'ed INPUT SIGNALS TO THE WPPE
	-- vector signals
	--=================================================================================--
	WPPE_IN_CONNECT_CTRL : IF (WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS > 0) GENERATE
		in_reg_connection_CTRL : FOR i in 0 to WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS - 1 GENERATE
			wppe_input_regs_vector_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH * (i + 1) - 1 downto WPPE_GENERICS_RECORD.CTRL_REG_WIDTH * i) <= wppe_input_regs_ctrl(i);
		END GENERATE in_reg_connection_CTRL;
	END GENERATE;
	--###############################################################################################

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- NORTH OUTPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	NORTH_OUTPUTS_CHECK : FOR output in 0 to SOUTH_PIN_NUM - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		NORTH_OUTPUT_MUX_GEN : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
			signal mux_north_out_signal    : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);
			signal mux_north_select_signal : std_logic_vector(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0);

		begin
			north_outputs(SOUTH_INPUT_WIDTH * (output + 1) - 1 downto SOUTH_INPUT_WIDTH * (output)) <= mux_north_out_signal;

			mux_north_select_signal(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0) <= north_output_mux_selects(MULTI_SOURCE_MATRIX(6, output) downto MULTI_SOURCE_MATRIX(5, output)
				);

			north_mux_output : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/north_mux_output_" & Int_to_string(output),

					-- cadence translate_on																	  
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX(1,
						output),
					OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH, -- NORTH OUTPUT WIDTH = SOUTH INPUT WIDTH	
					SEL_WIDTH         => MULTI_SOURCE_MATRIX(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX(0,
						output)
				)
				port map(
					data_inputs => north_output_all_mux_ins(MULTI_SOURCE_MATRIX(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_north_select_signal,
					output      => mux_north_out_signal
				);



		END GENERATE;                   -- NORTH OUTPUT MUX GEN

	END GENERATE;                       -- NORTH OUTPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- EAST OUTPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	EAST_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		EAST_OUTPUT_MUX_GEN : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
			signal mux_east_out_signal    : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);
			signal mux_east_select_signal : std_logic_vector(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0);

		begin
			east_outputs(WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM + 1) - 1 downto WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM)) <= mux_east_out_signal;

			mux_east_select_signal(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0) <= east_output_mux_selects(MULTI_SOURCE_MATRIX(6, output) downto -- END
					MULTI_SOURCE_MATRIX(5, output) -- BEGIN
				);

			east_mux_output : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/east_mux_output_" & Int_to_string(output),

					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX(1,
						output),
					OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH, -- EAST OUTPUT WIDTH = WEST INPUT WIDTH	
					SEL_WIDTH         => MULTI_SOURCE_MATRIX(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX(0,
						output)
				)
				port map(
					data_inputs => east_output_all_mux_ins(MULTI_SOURCE_MATRIX(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_east_select_signal,
					output      => mux_east_out_signal
				);



		END GENERATE;                   -- EAST OUTPUT MUX GEN

	END GENERATE;                       -- EAST OUTPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- SOUTH OUTPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	SOUTH_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM - 1 GENERATE
		-- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		SOUTH_OUTPUT_MUX_GEN : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
			signal mux_south_out_signal    : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);
			signal mux_south_select_signal : std_logic_vector(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0);

		begin
			south_outputs(NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM) + 1) - 1 downto NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM))
			) <= mux_south_out_signal;

			mux_south_select_signal(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0) <= south_output_mux_selects(MULTI_SOURCE_MATRIX(6, output) downto -- END
					MULTI_SOURCE_MATRIX(5, output) -- BEGIN
				);

			south_mux_output : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/south_mux_output_" & Int_to_string(output),

					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX(1,
						output),
					OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH, -- SOUTH OUTPUT WIDTH = NORTH INPUT WIDTH	
					SEL_WIDTH         => MULTI_SOURCE_MATRIX(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX(0,
						output)
				)
				port map(
					data_inputs => south_output_all_mux_ins(MULTI_SOURCE_MATRIX(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_south_select_signal,
					output      => mux_south_out_signal
				);



		END GENERATE;                   -- SOUTH OUTPUT MUX GEN

	END GENERATE;                       -- SOUTH OUTPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- WEST OUTPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	WEST_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM - 1 GENERATE
		-- = WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		WEST_OUTPUT_MUX_GEN : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
			signal mux_west_out_signal    : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);
			signal mux_west_select_signal : std_logic_vector(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0);

		begin
			west_outputs(EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM))
			) <= mux_west_out_signal;

			mux_west_select_signal(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0) <= west_output_mux_selects(MULTI_SOURCE_MATRIX(6, output) downto -- END
					MULTI_SOURCE_MATRIX(5, output) -- BEGIN
				);

			west_mux_output : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/west_mux_output_" & Int_to_string(output),

					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX(1,
						output),
					OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH, -- WEST  OUTPUT WIDTH = EAST INPUT WIDTH	
					SEL_WIDTH         => MULTI_SOURCE_MATRIX(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX(0,
						output)
				)
				port map(
					data_inputs => west_output_all_mux_ins(MULTI_SOURCE_MATRIX(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_west_select_signal,
					output      => mux_west_out_signal
				);


		END GENERATE;                   -- WEST OUTPUT MUX GEN

	END GENERATE;                       -- WEST OUTPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- WPPE INPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	WPPE_INPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1 GENERATE
		WPPE_INPUT_MUX_GEN : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
			signal mux_wppe_in_signal     : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);
			signal mux_wppe_select_signal : std_logic_vector(MULTI_SOURCE_MATRIX(2, output) - 1 downto 0);

		begin
			wppe_input_regs(output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM)
			) <= mux_wppe_in_signal;

			mux_wppe_select_signal <= wppe_input_mux_selects(MULTI_SOURCE_MATRIX(6, output) downto -- END
					MULTI_SOURCE_MATRIX(5, output) -- BEGIN
				);

			wppe_in_mux_output : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/wppe_in_mux_output_" & Int_to_string(output),

					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX(1,
						output),
					OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH,
					SEL_WIDTH         => MULTI_SOURCE_MATRIX(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX(0,
						output)
				)
				port map(
					data_inputs => wppe_input_all_mux_ins(MULTI_SOURCE_MATRIX(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_wppe_select_signal,
					output      => mux_wppe_in_signal
				);



		END GENERATE;                   -- WPPE INPUT MUX GEN

	END GENERATE;                       -- WPPE INPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											NORTH INPUTS
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 		N_N_...	<==>	NORTH INPUTS <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	N_N_NORTH_OUTPUTS_CHECK : FOR output in 0 to SOUTH_PIN_NUM - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		N_N_NORTH_INPUTS_CHECK : FOR input in NORTH_PIN_NUM - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_N_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_N_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					N_N_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE

						-----------------------------------------------------
						-- Signal declartions
						-----------------------------------------------------			

						signal N_N_north_in_signal  : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);
						signal N_N_north_out_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						N_N_north_in_signal <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * (input));

						north_outputs(SOUTH_INPUT_WIDTH * (output + 1) - 1 downto SOUTH_INPUT_WIDTH * (output)) <= N_N_north_out_signal;

						N_N_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/N_N_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH
							)
							port map(
								input_signal  => N_N_north_in_signal,
								output_signal => N_N_north_out_signal
							);

					END GENERATE;       -- NORTH NORTH CONN_CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_N_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_N_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_N_mux_north_in_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						N_N_mux_north_in_signal(NORTH_INPUT_WIDTH - 1 downto 0) <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * (input));

						north_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= N_N_mux_north_in_signal;


					END GENERATE;       -- N_N_MULTI_SOURCE CONNECTION CHECK

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   -- NORTH INPUTS CHECK

	END GENERATE;                       -- NORTH OUTPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 		N_E_...	<==>		NORTH INPUTS <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--


	N_E_EAST_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM to (SOUTH_PIN_NUM + WEST_PIN_NUM) - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		N_E_NORTH_INPUTS_CHECK : FOR input in NORTH_PIN_NUM - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_E_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_E_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		

					N_E_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_E_north_in_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);
						signal N_E_east_out_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						N_E_north_in_signal <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * (input));

						east_outputs(WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM + 1) - 1 downto WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM)) <= N_E_east_out_signal;

						N_E_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/N_E_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH
							)
							port map(
								input_signal  => N_E_north_in_signal,
								output_signal => N_E_east_out_signal
							);

					END GENERATE;       -- NORTH EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_E_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_E_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_E_mux_north_in_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						N_E_mux_north_in_signal(NORTH_INPUT_WIDTH - 1 downto 0) <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * (input));

						east_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= N_E_mux_north_in_signal;



					END GENERATE;       -- N_E_MULTI SOURCE CONNECTION CHECK	

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   -- EAST OUTPUTS CHECK

	END GENERATE;                       -- NORTH INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 	N_S_...	<==>		NORTH6 INPUTS <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	N_S_SOUTH_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		N_S_NORTH_INPUTS_CHECK : FOR input in NORTH_PIN_NUM - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_S_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_S_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					N_S_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_S_north_in_signal  : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);
						signal N_S_south_out_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0); -- = SOUTH OUTPUT WIDTH = NORTH INPUT WIDTH

					begin
						N_S_north_in_signal <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * input);

						south_outputs(NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM) + 1) - 1 downto NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM))) <= N_S_south_out_signal;

						N_S_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/N_S_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on						  		
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH
							)
							port map(
								input_signal  => N_S_north_in_signal,
								output_signal => N_S_south_out_signal
							);

					END GENERATE;       -- NORTH SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_S_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_S_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_S_mux_north_in_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						N_S_mux_north_in_signal(NORTH_INPUT_WIDTH - 1 downto 0) <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * (input));

						south_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= N_S_mux_north_in_signal;


					END GENERATE;       -- N_S MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   -- SOUTH OUTPUTS CHECK

	END GENERATE;                       -- NORTH INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- N_W_... 		<==>				NORTH INPUTS <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	N_W_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM) - 1 GENERATE -- =  WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		N_W_INPUTS_CHECK : FOR input in NORTH_PIN_NUM - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_W_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_W_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					N_W_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_W_north_in_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);
						signal N_W_west_out_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						N_W_north_in_signal <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * input);

						west_outputs(EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM))) <= N_W_west_out_signal;

						N_W_cnn : connection
							generic map(
								-- cadence translate_off							
								INSTANCE_NAME     => INSTANCE_NAME & "/N_W_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH
							)
							port map(
								input_signal  => N_W_north_in_signal,
								output_signal => N_W_west_out_signal
							);

					END GENERATE;       --  NORTH WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_W_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_W_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_W_mux_north_in_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						N_W_mux_north_in_signal(NORTH_INPUT_WIDTH - 1 downto 0) <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * (input));

						west_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= N_W_mux_north_in_signal;



					END GENERATE;       -- N_W MULTI SOURCE CONNECTION CHECK	

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  NORTH INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- N_PROC_...		<==>		NORTH INPUTS <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--


	N_PROC_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG) - 1 GENERATE
		N_PROC_INPUTS_CHECK : FOR input in NORTH_PIN_NUM - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_PROC_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_PROC_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					N_PROC_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_PROC_north_in_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);
						signal N_PROC_wppe_out_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						N_PROC_north_in_signal <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * input);

						wppe_input_regs(output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM)) <= N_PROC_wppe_out_signal;

						N_PROC_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/N_PROC_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH
							)
							port map(
								input_signal  => N_PROC_north_in_signal,
								output_signal => N_PROC_wppe_out_signal
							);

					END GENERATE;       --  NORTH to INPUT REGISTERS CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_PROC_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_PROC_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal N_PROC_mux_north_in_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						N_PROC_mux_north_in_signal(NORTH_INPUT_WIDTH - 1 downto 0) <= north_inputs(NORTH_INPUT_WIDTH * (input + 1) - 1 downto NORTH_INPUT_WIDTH * (input));

						wppe_input_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output)
						) <= N_PROC_mux_north_in_signal;



					END GENERATE;       -- N_PROC MULTI SOURCE CONNECTION CHECK

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  INPUT REGISTERS CHECK

	END GENERATE;                       --  NORTH INPUTS CHECK


	--**************************************************************************************--
	--**************************************************************************************--

	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											EAST INPUTS
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- E_N_... <==>		EAST INPUTS <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_N_OUTPUTS_CHECK : FOR output in 0 to SOUTH_PIN_NUM - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		E_N_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM - 1 downto NORTH_PIN_NUM GENERATE -- = EAST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_N_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_N_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	


					E_N_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_N_east_in_signal   : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);
						signal E_N_north_out_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						E_N_east_in_signal <= east_inputs(EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM + 1) - 1 downto EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM));

						north_outputs(SOUTH_INPUT_WIDTH * (output + 1) - 1 downto SOUTH_INPUT_WIDTH * output) <= E_N_north_out_signal;

						E_N_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_N_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH
							)
							port map(
								input_signal  => E_N_east_in_signal,
								output_signal => E_N_north_out_signal
							);

					END GENERATE;       --  EAST NORTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_N_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_N_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_N_mux_east_in_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						E_N_mux_east_in_signal(EAST_INPUT_WIDTH - 1 downto 0) <= east_inputs(EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM))
							);

						north_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= E_N_mux_east_in_signal;



					END GENERATE;       -- E_N MULTIC SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  NORTH OUTPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- E_E_... 	<==>		EAST INPUTS <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_E_EAST_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM to (SOUTH_PIN_NUM + WEST_PIN_NUM) - 1 GENERATE -- =  EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER	

		E_E_EAST_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM - 1 downto NORTH_PIN_NUM GENERATE -- =  EAST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_E_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_E_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					E_E_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_E_east_in_signal  : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);
						signal E_E_east_out_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						E_E_east_in_signal <= east_inputs(EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM + 1) - 1 downto EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM));

						east_outputs(WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM + 1) - 1 downto WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM)) <= E_E_east_out_signal;

						E_E_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_E_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH
							)
							port map(
								input_signal  => E_E_east_in_signal,
								output_signal => E_E_east_out_signal
							);

					END GENERATE;       --  EAST EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_E_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_E_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_E_mux_east_in_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						E_E_mux_east_in_signal(EAST_INPUT_WIDTH - 1 downto 0) <= east_inputs(EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM))
							);

						east_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= E_E_mux_east_in_signal;



					END GENERATE;       -- E_E MULTIC SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  EAST OUTPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 	E_S_... <==>				EAST INPUTS <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_S_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		E_S_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM - 1 downto NORTH_PIN_NUM GENERATE -- = EAST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_S_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_S_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					E_S_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_S_east_in_signal   : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);
						signal E_S_south_out_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						E_S_east_in_signal <= east_inputs(EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM + 1) - 1 downto EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM));

						south_outputs(NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM) + 1) - 1 downto NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM))) <= E_S_south_out_signal;

						E_S_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_S_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH
							)
							port map(
								input_signal  => E_S_east_in_signal,
								output_signal => E_S_south_out_signal
							);

					END GENERATE;       --  EAST SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_S_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_S_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_S_mux_east_in_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						E_S_mux_east_in_signal(EAST_INPUT_WIDTH - 1 downto 0) <= east_inputs(EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM))
							);

						south_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= E_S_mux_east_in_signal;



					END GENERATE;       -- E_S MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  SOUTH OUTPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 	E_W_...	<==>		EAST INPUTS <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_W_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM) - 1 GENERATE -- = WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		E_W_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM - 1 downto NORTH_PIN_NUM GENERATE -- = EAST INPUT PIN NUMBER	 \

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_W_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_W_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					E_W_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_W_east_in_signal  : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);
						signal E_W_west_out_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						E_W_east_in_signal <= east_inputs(EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM + 1) - 1 downto EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM));

						west_outputs(EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM))) <= E_W_west_out_signal;

						E_W_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_W_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH
							)
							port map(
								input_signal  => E_W_east_in_signal,
								output_signal => E_W_west_out_signal
							);

					END GENERATE;       --  EAST WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_W_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_W_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_W_mux_east_in_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						E_W_mux_east_in_signal(EAST_INPUT_WIDTH - 1 downto 0) <= east_inputs(EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM))
							);

						west_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= E_W_mux_east_in_signal;



					END GENERATE;       -- E_W MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- E_PROC_... <==>		EAST INPUTS <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_PROC_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG) - 1 GENERATE
		E_PROC_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM - 1 downto NORTH_PIN_NUM GENERATE -- =  EAST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_PROC_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_PROC_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					E_PROC_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_PROC_east_in_signal  : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);
						signal E_PROC_wppe_out_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						E_PROC_east_in_signal <= east_inputs(EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM + 1) - 1 downto EAST_INPUT_WIDTH * (input - NORTH_PIN_NUM));

						wppe_input_regs(output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM)) <= E_PROC_wppe_out_signal;

						E_PROC_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_PROC_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH
							)
							port map(
								input_signal  => E_PROC_east_in_signal,
								output_signal => E_PROC_wppe_out_signal
							);

					END GENERATE;       --  EAST to PROCESSOR CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_PROC_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_PROC_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal E_PROC_mux_east_in_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						E_PROC_mux_east_in_signal(EAST_INPUT_WIDTH - 1 downto 0) <= east_inputs(EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (input - (NORTH_PIN_NUM))
							);

						wppe_input_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output)
						) <= E_PROC_mux_east_in_signal;


					END GENERATE;       -- E_PROC MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  PROCESSOR INPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--**************************************************************************************--
	--**************************************************************************************--


	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											SOUTH INPUTS
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 	S_N_...	<==>		SOUTH INPUTS <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_N_OUTPUTS_CHECK : FOR output in 0 to SOUTH_PIN_NUM - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		S_N_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM - 1 downto (NORTH_PIN_NUM + EAST_PIN_NUM) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_N_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_N_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					S_N_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_N_south_in_signal  : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);
						signal S_N_north_out_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						S_N_south_in_signal <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM)));

						north_outputs(SOUTH_INPUT_WIDTH * (output + 1) - 1 downto SOUTH_INPUT_WIDTH * output) <= S_N_north_out_signal;

						S_N_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_N_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH
							)
							port map(
								input_signal  => S_N_south_in_signal,
								output_signal => S_N_north_out_signal
							);

						north_outputs(SOUTH_INPUT_WIDTH * (output + 1) - 1 downto SOUTH_INPUT_WIDTH * output) <= S_N_north_out_signal;

					END GENERATE;       --  SOUTH NORTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_N_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_N_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_N_mux_south_in_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						S_N_mux_south_in_signal(SOUTH_INPUT_WIDTH - 1 downto 0) <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM))
							);

						north_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= S_N_mux_south_in_signal;



					END GENERATE;       -- SOUTH NORTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  NORTH OUTPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- S_E_... <==>		SOUTH INPUTS <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_E_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM to (SOUTH_PIN_NUM + WEST_PIN_NUM) - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		S_E_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM - 1 downto (NORTH_PIN_NUM + EAST_PIN_NUM) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_E_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_E_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					S_E_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_E_south_in_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);
						signal S_E_east_out_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						S_E_south_in_signal <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM)));

						east_outputs(WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM + 1) - 1 downto WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM)) <= S_E_east_out_signal;

						S_E_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_E_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH
							)
							port map(
								input_signal  => S_E_south_in_signal,
								output_signal => S_E_east_out_signal
							);

					END GENERATE;       --  SOUTH EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_E_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_E_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_E_mux_south_in_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						S_E_mux_south_in_signal(SOUTH_INPUT_WIDTH - 1 downto 0) <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM))
							);

						east_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= S_E_mux_south_in_signal;



					END GENERATE;       -- SOUTH EAST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  EAST OUTPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- S_S_... <==>		SOUTH INPUTS <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_S_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		S_S_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM - 1 downto (NORTH_PIN_NUM + EAST_PIN_NUM) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_S_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_S_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


					S_S_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_S_south_in_signal  : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);
						signal S_S_south_out_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						S_S_south_in_signal <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM)));

						south_outputs(NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM) + 1) - 1 downto NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM))) <= S_S_south_out_signal;

						S_S_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_S_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH
							)
							port map(
								input_signal  => S_S_south_in_signal,
								output_signal => S_S_south_out_signal
							);

					END GENERATE;       --  SOUTH SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_S_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_S_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_S_mux_south_in_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						S_S_mux_south_in_signal(SOUTH_INPUT_WIDTH - 1 downto 0) <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM))
							);

						south_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= S_S_mux_south_in_signal;



					END GENERATE;       -- SOUTH SOUTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  SOUTH OUTPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- S_W_...	<==>			SOUTH INPUTS <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_W_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM) - 1 GENERATE -- = WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		S_W_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM - 1 downto (NORTH_PIN_NUM + EAST_PIN_NUM) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_W_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_W_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					S_W_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_W_south_in_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);
						signal S_W_west_out_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						S_W_south_in_signal <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM)));

						west_outputs(EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM))) <= S_W_west_out_signal;

						S_W_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_W_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH
							)
							port map(
								input_signal  => S_W_south_in_signal,
								output_signal => S_W_west_out_signal
							);

					END GENERATE;       --  SOUTH WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_W_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_W_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_W_mux_south_in_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						S_W_mux_south_in_signal(SOUTH_INPUT_WIDTH - 1 downto 0) <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM))
							);

						west_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= S_W_mux_south_in_signal;



					END GENERATE;       -- SOUTH WEST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- S_PROC	<==>		SOUTH INPUTS <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_PROC_OUTPUTS_CHECK : FOR output in (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM) to (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG) - 1 GENERATE
		S_PROC_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM - 1 downto (NORTH_PIN_NUM + EAST_PIN_NUM) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_PROC_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_PROC_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


					S_PROC_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_PROC_south_in_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);
						signal S_PROC_wppe_out_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						S_PROC_south_in_signal <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM)));

						wppe_input_regs(output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM)) <= S_PROC_wppe_out_signal;

						S_PROC_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_PROC_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH
							)
							port map(
								input_signal  => S_PROC_south_in_signal,
								output_signal => S_PROC_wppe_out_signal
							);

					END GENERATE;       --  SOUTH PROCESSOR CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_PROC_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_PROC_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal S_PROC_mux_south_in_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						S_PROC_mux_south_in_signal(SOUTH_INPUT_WIDTH - 1 downto 0) <= south_inputs(SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM) + 1) - 1 downto SOUTH_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM))
							);

						wppe_input_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output)
						) <= S_PROC_mux_south_in_signal;


					END GENERATE;       -- SOUTH PROCESSOR MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  PROCESSOR INPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--**************************************************************************************--
	--**************************************************************************************--

	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											WEST INPUTS
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_N_... <==> 	WEST INPUTS <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--


	W_N_OUTPUTS_CHECK : FOR output in 0 to SOUTH_PIN_NUM - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		W_N_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_N_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_N_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_N_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_N_west_in_signal   : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);
						signal W_N_north_out_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						W_N_west_in_signal <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM)));

						north_outputs(SOUTH_INPUT_WIDTH * (output + 1) - 1 downto SOUTH_INPUT_WIDTH * output) <= W_N_north_out_signal;

						W_N_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_N_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH
							)
							port map(
								input_signal  => W_N_west_in_signal,
								output_signal => W_N_north_out_signal
							);

					END GENERATE;       --  WEST NORTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_N_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_N_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_N_mux_west_in_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						W_N_mux_west_in_signal(WEST_INPUT_WIDTH - 1 downto 0) <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM))
							);

						north_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= W_N_mux_west_in_signal;



					END GENERATE;       -- WEST NORTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  NORTH OUTPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_E_... <==>		WEST INPUTS <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	W_E_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		W_E_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_E_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_E_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_E_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_E_west_in_signal  : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);
						signal W_E_east_out_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						W_E_west_in_signal <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM)));

						east_outputs(WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM + 1) - 1 downto WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM)) <= W_E_east_out_signal;

						W_E_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_E_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH
							)
							port map(
								input_signal  => W_E_west_in_signal,
								output_signal => W_E_east_out_signal
							);

					END GENERATE;       --  WEST EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_E_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_E_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_E_mux_west_in_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						W_E_mux_west_in_signal(WEST_INPUT_WIDTH - 1 downto 0) <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM))
							);

						east_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= W_E_mux_west_in_signal;


					END GENERATE;       -- WEST EAST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  EAST OUTPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_S_...	<==>				WEST INPUTS <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	W_S_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		W_S_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_S_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_S_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_S_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_S_west_in_signal   : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);
						signal W_S_south_out_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						W_S_west_in_signal <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM)));

						south_outputs(NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM) + 1) - 1 downto NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM))) <= W_S_south_out_signal;

						W_S_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_S_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH
							)
							port map(
								input_signal  => W_S_west_in_signal,
								output_signal => W_S_south_out_signal
							);

					END GENERATE;       --  WEST SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_S_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_S_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_S_mux_west_in_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						W_S_mux_west_in_signal(WEST_INPUT_WIDTH - 1 downto 0) <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM))
							);

						south_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= W_S_mux_west_in_signal;


					END GENERATE;       -- WEST SOUTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  SOUTH OUTPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_W_...		<==>		WEST INPUTS <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	W_W_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM - 1 GENERATE -- = WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		W_W_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_W_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_W_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_W_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_W_west_in_signal  : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);
						signal W_W_west_out_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						W_W_west_in_signal <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM)));

						west_outputs(EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM))) <= W_W_west_out_signal;

						W_W_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_W_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH
							)
							port map(
								input_signal  => W_W_west_in_signal,
								output_signal => W_W_west_out_signal
							);

					END GENERATE;       --  WEST WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_W_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_W_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_W_mux_west_in_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						W_W_mux_west_in_signal(WEST_INPUT_WIDTH - 1 downto 0) <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM))
							);

						west_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= W_W_mux_west_in_signal;



					END GENERATE;       -- WEST WEST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_PROC_...	 <==>		WEST INPUTS <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	W_PROC_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1 GENERATE
		W_PROC_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_PROC_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_PROC_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_PROC_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_PROC_west_in_signal  : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);
						signal W_PROC_wppe_out_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						W_PROC_west_in_signal <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM)));

						wppe_input_regs(output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM)) <= W_PROC_wppe_out_signal;

						W_PROC_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_PROC_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH
							)
							port map(
								input_signal  => W_PROC_west_in_signal,
								output_signal => W_PROC_wppe_out_signal
							);

					END GENERATE;       --  WEST PROCESSOR CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_PROC_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_PROC_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal W_PROC_mux_west_in_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						W_PROC_mux_west_in_signal(WEST_INPUT_WIDTH - 1 downto 0) <= west_inputs(WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM) + 1) - 1 downto WEST_INPUT_WIDTH * (input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM))
							);

						wppe_input_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output)
						) <= W_PROC_mux_west_in_signal;



					END GENERATE;       -- WEST PROCESSOR MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  PROCESSOR INPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--**************************************************************************************--
	--**************************************************************************************--

	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											WPPE OUTPUT REGISTERS 
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_N_...	<==>		WPPE OUTPUT REGISTERS  <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_N_OUTPUTS_CHECK : FOR output in 0 to SOUTH_PIN_NUM - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		WPPE_N_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_N_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_N_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					WPPE_N_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_N_wppe_in_signal   : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);
						signal WPPE_N_north_out_signal : std_logic_vector(SOUTH_INPUT_WIDTH - 1 downto 0);

					begin
						WPPE_N_wppe_in_signal <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM));

						north_outputs(SOUTH_INPUT_WIDTH * (output + 1) - 1 downto SOUTH_INPUT_WIDTH * output) <= WPPE_N_north_out_signal;

						WPPE_N_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_N_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH
							)
							port map(
								input_signal  => WPPE_N_wppe_in_signal,
								output_signal => WPPE_N_north_out_signal
							);

					END GENERATE;       --  WPPE_OUT to  NORTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_N_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_N_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_N_mux_wppe_in_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						WPPE_N_mux_wppe_in_signal(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0) <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM)
							);

						north_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= WPPE_N_mux_wppe_in_signal;


					END GENERATE;       -- WPPE NORTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  NORTH OUTPUTS CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_E_... 	<==>		WPPE OUTPUT REGISTERS  <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_E_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		WPPE_E_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_E_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_E_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					WPPE_E_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_E_wppe_in_signal  : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);
						signal WPPE_E_east_out_signal : std_logic_vector(WEST_INPUT_WIDTH - 1 downto 0);

					begin
						WPPE_E_wppe_in_signal <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM));

						east_outputs(WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM + 1) - 1 downto WEST_INPUT_WIDTH * (output - SOUTH_PIN_NUM)) <= WPPE_E_east_out_signal;

						WPPE_E_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_E_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH,
								OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH
							)
							port map(
								input_signal  => WPPE_E_wppe_in_signal,
								output_signal => WPPE_E_east_out_signal
							);

					END GENERATE;       --  WPPE_OUT to EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_E_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_E_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_E_mux_wppe_in_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						WPPE_E_mux_wppe_in_signal(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0) <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM)
							);

						east_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= WPPE_E_mux_wppe_in_signal;



					END GENERATE;       -- WPPE EAST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  EAST OUTPUTS CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_S_...		<==>		WPPE OUTPUT REGISTERS  <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_S_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		WPPE_S_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_S_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_S_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					WPPE_S_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_S_wppe_in_signal   : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);
						signal WPPE_S_south_out_signal : std_logic_vector(NORTH_INPUT_WIDTH - 1 downto 0);

					begin
						WPPE_S_wppe_in_signal <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM));

						south_outputs(NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM) + 1) - 1 downto NORTH_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM))) <= WPPE_S_south_out_signal;

						WPPE_S_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_S_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH
							)
							port map(
								input_signal  => WPPE_S_wppe_in_signal,
								output_signal => WPPE_S_south_out_signal
							);

					END GENERATE;       --  WPPE_OUT to SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_S_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_S_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_S_mux_wppe_in_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						WPPE_S_mux_wppe_in_signal(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0) <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM)
							);

						south_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                 MULTI_SOURCE_MATRIX,
								                 input,
								                 output)
						) <= WPPE_S_mux_wppe_in_signal;



					END GENERATE;       -- WPPE SOUTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  SOUTH OUTPUTS CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_W_...	<==>		WPPE OUTPUT REGISTERS  <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_W_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM - 1 GENERATE -- WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		WPPE_W_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_W_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_W_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


					WPPE_W_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_W_wppe_in_signal  : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);
						signal WPPE_W_west_out_signal : std_logic_vector(EAST_INPUT_WIDTH - 1 downto 0);

					begin
						WPPE_W_wppe_in_signal <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM));

						west_outputs(EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM) + 1) - 1 downto EAST_INPUT_WIDTH * (output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM))) <= WPPE_W_west_out_signal;

						WPPE_W_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_W_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH
							)
							port map(
								input_signal  => WPPE_W_wppe_in_signal,
								output_signal => WPPE_W_west_out_signal
							);

					END GENERATE;       --  WPPE_OUT to WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_W_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_W_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_W_mux_wppe_in_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						WPPE_W_mux_wppe_in_signal(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0) <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM)
							);

						west_output_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								                MULTI_SOURCE_MATRIX,
								                input,
								                output)
						) <= WPPE_W_mux_wppe_in_signal;



					END GENERATE;       -- WPPE WEST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_PROC_...	<==>	WPPE OUTPUT REGISTERS  <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_PROC_OUTPUTS_CHECK : FOR output in SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM to SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_INPUT_REG - 1 GENERATE
		WPPE_PROC_INPUTS_CHECK : FOR input in NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM + WPPE_GENERICS_RECORD.NUM_OF_OUTPUT_REG - 1 downto NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_PROC_DRIVER_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_PROC_FALSE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


					WPPE_PROC_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_PROC_wppe_in_signal  : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);
						signal WPPE_PROC_wppe_out_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						WPPE_PROC_wppe_in_signal <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM));

						wppe_input_regs(output - (SOUTH_PIN_NUM + WEST_PIN_NUM + NORTH_PIN_NUM + EAST_PIN_NUM)) <= WPPE_PROC_wppe_out_signal;

						WPPE_PROC_cnn : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_PROC_cnn_" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH
							)
							port map(
								input_signal  => WPPE_PROC_wppe_in_signal,
								output_signal => WPPE_PROC_wppe_out_signal
							);

					END GENERATE;       --  WPPE_OUT to WPPE_IN CHECK

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_PROC_TRUE_MS_CHECK : IF MULTI_SOURCE_MATRIX(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_PROC_MS_CONN_CHECK : IF ADJACENCY_MATRIX(input)(output) = '1' GENERATE
						signal WPPE_PROC_mux_wppe_in_signal : std_logic_vector(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0);

					begin
						WPPE_PROC_mux_wppe_in_signal(WPPE_GENERICS_RECORD.GEN_PUR_REG_WIDTH - 1 downto 0) <= wppe_output_regs(input - (NORTH_PIN_NUM + EAST_PIN_NUM + SOUTH_PIN_NUM + WEST_PIN_NUM)
							);

						wppe_input_all_mux_ins(calculate_driver_end(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output) downto calculate_driver_begin(ADJACENCY_MATRIX,
								               MULTI_SOURCE_MATRIX,
								               input,
								               output)
						) <= WPPE_PROC_mux_wppe_in_signal;



					END GENERATE;       -- WPPE PROCESSOR MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WPPE_IN CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--#################################
	--###################################
	--#####################################
	--### BEGIN CTRL_ICN INSTANTIATION: #####
	--#########################################


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- NORTH OUTPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	NORTH_OUTPUTS_CHECK_CTRL : FOR output in 0 to SOUTH_PIN_NUM_CTRL - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		NORTH_OUTPUT_MUX_GEN_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
			signal mux_north_out_signal_ctrl    : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);
			signal mux_north_select_signal_ctrl : std_logic_vector(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0);

		begin
			north_outputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (output + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (output)) <= mux_north_out_signal_ctrl(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

			mux_north_select_signal_ctrl(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0) <= north_output_mux_selects_ctrl(MULTI_SOURCE_MATRIX_CTRL(6, output) downto MULTI_SOURCE_MATRIX_CTRL(5, output)
				);

			north_mux_output_ctrl : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/north_mux_output_ctrl" & Int_to_string(output),

					-- cadence translate_on																	  
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX_CTRL(1,
						output),
					OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH_CTRL, -- NORTH OUTPUT WIDTH = SOUTH INPUT WIDTH	
					SEL_WIDTH         => MULTI_SOURCE_MATRIX_CTRL(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX_CTRL(0,
						output)
				)
				port map(
					data_inputs => north_output_all_mux_ins_ctrl(MULTI_SOURCE_MATRIX_CTRL(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX_CTRL(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_north_select_signal_ctrl,
					output      => mux_north_out_signal_ctrl
				);


		END GENERATE;                   -- NORTH OUTPUT MUX GEN

	END GENERATE;                       -- NORTH OUTPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- EAST OUTPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	EAST_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		EAST_OUTPUT_MUX_GEN_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
			--signal mux_east_out_signal_ctrl    : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);
			--signal mux_east_select_signal_ctrl : std_logic_vector(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0);

		begin
			east_outputs_ctrl(WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL)) <= mux_east_out_signal_ctrl;

			mux_east_select_signal_ctrl(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0) <= east_output_mux_selects_ctrl(MULTI_SOURCE_MATRIX_CTRL(6, output) downto -- END
					MULTI_SOURCE_MATRIX_CTRL(5, output) -- BEGIN
				);

			east_mux_output_ctrl : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/east_mux_output_ctrl" & Int_to_string(output),

					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX_CTRL(1,
						output),
					OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH_CTRL, -- EAST OUTPUT WIDTH = WEST INPUT WIDTH	
					SEL_WIDTH         => MULTI_SOURCE_MATRIX_CTRL(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX_CTRL(0,
						output)
				)
				port map(
					data_inputs => east_output_all_mux_ins_ctrl(MULTI_SOURCE_MATRIX_CTRL(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX_CTRL(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_east_select_signal_ctrl,
					output      => mux_east_out_signal_ctrl
				);


		END GENERATE;                   -- EAST OUTPUT MUX GEN

	END GENERATE;                       -- EAST OUTPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- SOUTH OUTPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	SOUTH_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL - 1 GENERATE
		-- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		SOUTH_OUTPUT_MUX_GEN_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
			signal mux_south_out_signal_ctrl    : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);
			signal mux_south_select_signal_ctrl : std_logic_vector(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0);

		begin
			south_outputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL))
			) <= wppe_output_regs_vector_ctrl(0 downto 0); --mux_south_out_signal_ctrl; 

			mux_south_select_signal_ctrl(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0) <= south_output_mux_selects_ctrl(MULTI_SOURCE_MATRIX_CTRL(6, output) downto -- END
					MULTI_SOURCE_MATRIX_CTRL(5, output) -- BEGIN
				);

			south_mux_output_ctrl : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/south_mux_output_ctrl" & Int_to_string(output),

					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX_CTRL(1,
						output),
					OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH_CTRL, -- SOUTH OUTPUT WIDTH = NORTH INPUT WIDTH	
					SEL_WIDTH         => MULTI_SOURCE_MATRIX_CTRL(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX_CTRL(0,
						output)
				)
				port map(
					data_inputs => south_output_all_mux_ins_ctrl(MULTI_SOURCE_MATRIX_CTRL(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX_CTRL(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_south_select_signal_ctrl,
					output      => mux_south_out_signal_ctrl
				);



		END GENERATE;                   -- SOUTH OUTPUT MUX GEN

	END GENERATE;                       -- SOUTH OUTPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- WEST OUTPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	WEST_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1 GENERATE
		-- = WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		WEST_OUTPUT_MUX_GEN_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
			signal mux_west_out_signal_ctrl    : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);
			signal mux_west_select_signal_ctrl : std_logic_vector(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0);

		begin
			west_outputs_ctrl(EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL))
			) <= mux_west_out_signal_ctrl;

			mux_west_select_signal_ctrl(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0) <= west_output_mux_selects_ctrl(MULTI_SOURCE_MATRIX_CTRL(6, output) downto -- END
					MULTI_SOURCE_MATRIX_CTRL(5, output) -- BEGIN
				);

			west_mux_output_ctrl : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/west_mux_output_ctrl" & Int_to_string(output),

					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX_CTRL(1,
						output),
					OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH_CTRL, -- WEST  OUTPUT WIDTH = EAST INPUT WIDTH	
					SEL_WIDTH         => MULTI_SOURCE_MATRIX_CTRL(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX_CTRL(0,
						output)
				)
				port map(
					data_inputs => west_output_all_mux_ins_ctrl(MULTI_SOURCE_MATRIX_CTRL(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX_CTRL(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_west_select_signal_ctrl,
					output      => mux_west_out_signal_ctrl
				);


		END GENERATE;                   -- WEST OUTPUT MUX GEN

	END GENERATE;                       -- WEST OUTPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- WPPE INPUTS MULTIPLEXER GENERATION
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	WPPE_INPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS - 1 GENERATE
		WPPE_INPUT_MUX_GEN_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
			signal mux_wppe_in_signal_ctrl     : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
			signal mux_wppe_select_signal_ctrl : std_logic_vector(MULTI_SOURCE_MATRIX_CTRL(2, output) - 1 downto 0);

		begin
			wppe_input_regs_ctrl(output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL)
			) <= mux_wppe_in_signal_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) when rst = '0' else (others=>'0');

			mux_wppe_select_signal_ctrl <= wppe_input_mux_selects_ctrl(MULTI_SOURCE_MATRIX_CTRL(6, output) downto -- END
					MULTI_SOURCE_MATRIX_CTRL(5, output) -- BEGIN
				);

			wppe_in_mux_output_ctrl : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/wppe_in_mux_output_ctrl" & Int_to_string(output),

					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MULTI_SOURCE_MATRIX_CTRL(1,
						output),
					OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH,
					SEL_WIDTH         => MULTI_SOURCE_MATRIX_CTRL(2,
						output),
					NUM_OF_INPUTS     => MULTI_SOURCE_MATRIX_CTRL(0,
						output)
				)
				port map(
					data_inputs => wppe_input_all_mux_ins_ctrl(MULTI_SOURCE_MATRIX_CTRL(4,
							output)     --END DATA !!!  
						downto MULTI_SOURCE_MATRIX_CTRL(3,
							output)     -- BEGIN DATA !!!
					),
					sel         => mux_wppe_select_signal_ctrl,
					output      => mux_wppe_in_signal_ctrl
				);



		END GENERATE;                   -- WPPE INPUT MUX GEN

	END GENERATE;                       -- WPPE INPUTS CHECK

	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											NORTH INPUTS
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 		N_N_...	<==>	NORTH INPUTS <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	N_N_NORTH_OUTPUTS_CHECK_CTRL : FOR output in 0 to SOUTH_PIN_NUM_CTRL - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		N_N_NORTH_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_N_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_N_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					N_N_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE

						-----------------------------------------------------
						-- Signal declartions
						-----------------------------------------------------			

						signal N_N_north_in_signal_ctrl  : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);
						signal N_N_north_out_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						--Ericles
						--wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*(input));

						N_N_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (input)) when rst = '0' else (others=>'0');

						north_outputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (output + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (output)) <= N_N_north_out_signal_ctrl(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

						N_N_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/N_N_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => N_N_north_in_signal_ctrl,
								output_signal => N_N_north_out_signal_ctrl
							);

					END GENERATE;       -- NORTH NORTH CONN_CHECK_CTRL ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_N_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_N_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal N_N_mux_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						--Ericles
						--wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*(input));

						N_N_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (input)) when rst = '0' else (others=>'0');

						north_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= N_N_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);



					END GENERATE;       -- N_N_MULTI_SOURCE CONNECTION CHECK

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   -- NORTH INPUTS CHECK

	END GENERATE;                       -- NORTH OUTPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 		N_E_...	<==>		NORTH INPUTS <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--


	N_E_EAST_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		N_E_NORTH_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_E_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_E_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		

					N_E_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						--signal N_E_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);
						--signal N_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						--Ericles
						--wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*(input));

						N_E_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (input)) when rst = '0' else (others=>'0');

						east_outputs_ctrl(WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL)) <= N_E_east_out_signal_ctrl(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

						N_E_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/N_E_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => N_E_north_in_signal_ctrl,
								output_signal => N_E_east_out_signal_ctrl
							);

					END GENERATE;       -- NORTH EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_E_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_E_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal N_E_mux_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						--Ericles
						--wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*(input));
						N_E_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (input)) when rst = '0' else (others=>'0');

						east_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= N_E_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);



					END GENERATE;       -- N_E_MULTI SOURCE CONNECTION CHECK	

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   -- EAST OUTPUTS CHECK

	END GENERATE;                       -- NORTH INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 	N_S_...	<==>		NORTH INPUTS <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	N_S_SOUTH_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		N_S_NORTH_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_S_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_S_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					N_S_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal N_S_north_in_signal_ctrl  : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);
						signal N_S_south_out_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0); -- = SOUTH OUTPUT WIDTH = NORTH INPUT WIDTH

					begin
						--Ericles
						--wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*input);
						N_S_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * input) when rst = '0' else (others=>'0');

						south_outputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL))) <= wppe_output_regs_vector_ctrl(0 downto 0); --N_S_south_out_signal_ctrl(NORTH_INPUT_WIDTH_CTRL -1 downto 0); 

						N_S_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/N_S_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on						  		
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => N_S_north_in_signal_ctrl,
								output_signal => N_S_south_out_signal_ctrl
							);

					END GENERATE;       -- NORTH SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_S_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_S_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal N_S_mux_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						--Ericles
						--wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*(input));
						N_S_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (input)) when rst = '0' else (others=>'0');

						south_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= N_S_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);


					END GENERATE;       -- N_S MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   -- SOUTH OUTPUTS CHECK

	END GENERATE;                       -- NORTH INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- N_W_... 		<==>				NORTH INPUTS <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	N_W_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) - 1 GENERATE -- =  WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		N_W_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_W_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_W_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					N_W_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal N_W_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);
						signal N_W_west_out_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						--Ericles
						--wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*input);
						N_W_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * input) when rst = '0' else (others=>'0');

						west_outputs_ctrl(EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL))) <= N_W_west_out_signal_ctrl(EAST_INPUT_WIDTH_CTRL - 1
								downto 0);

						N_W_cnn_ctrl : connection
							generic map(
								-- cadence translate_off							
								INSTANCE_NAME     => INSTANCE_NAME & "/N_W_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => N_W_north_in_signal_ctrl,
								output_signal => N_W_west_out_signal_ctrl
							);

					END GENERATE;       --  NORTH WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_W_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_W_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal N_W_mux_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						--Ericles
						--	wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*(input));
						N_W_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (input)) when rst = '0' else (others=>'0');

						west_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= N_W_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);



					END GENERATE;       -- N_W MULTI SOURCE CONNECTION CHECK	

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  NORTH INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- N_PROC_...		<==>		NORTH INPUTS <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--


	N_PROC_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS) - 1 GENERATE
		N_PROC_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL - 1 downto 0 GENERATE -- = NORTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			N_PROC_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				N_PROC_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					N_PROC_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal N_PROC_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);
						signal N_PROC_wppe_out_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						N_PROC_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * input) when rst = '0' else (others=>'0');

						wppe_input_regs_ctrl(output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL)) <= N_PROC_wppe_out_signal_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) 
						when rst = '0' else (others=>'0');

						N_PROC_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/N_PROC_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => NORTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH
							)
							port map(
								input_signal  => N_PROC_north_in_signal_ctrl,
								output_signal => N_PROC_wppe_out_signal_ctrl
							);

					END GENERATE;       --  NORTH to INPUT REGISTERS CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				N_PROC_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					N_PROC_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal N_PROC_mux_north_in_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						--Ericles
						--wppe_input_regs_vector_ctrl <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL*(input + 1)-1 downto NORTH_INPUT_WIDTH_CTRL*(input));

						N_PROC_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0) <= north_inputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (input + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (input)) when rst = '0' else (others=>'0');

						wppe_input_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output)
						) <= N_PROC_mux_north_in_signal_ctrl(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);



					END GENERATE;       -- N_PROC MULTI SOURCE CONNECTION CHECK

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  INPUT REGISTERS CHECK

	END GENERATE;                       --  NORTH INPUTS CHECK


	--**************************************************************************************--
	--**************************************************************************************--

	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											EAST INPUTS	 CURRENT UPDATE
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- E_N_... <==>		EAST INPUTS <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_N_OUTPUTS_CHECK_CTRL : FOR output in 0 to SOUTH_PIN_NUM_CTRL - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		E_N_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL GENERATE -- = EAST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_N_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_N_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	


					E_N_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_N_east_in_signal_ctrl   : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);
						signal E_N_north_out_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_N_east_in_signal_ctrl <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL)) when rst = '0' else (others=>'0');

						north_outputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (output + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * output) <= E_N_north_out_signal_ctrl;

						E_N_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_N_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => E_N_east_in_signal_ctrl,
								output_signal => E_N_north_out_signal_ctrl
							);

					END GENERATE;       --  EAST NORTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_N_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_N_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_N_mux_east_in_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_N_mux_east_in_signal_ctrl(EAST_INPUT_WIDTH_CTRL - 1 downto 0) <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						north_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= E_N_mux_east_in_signal_ctrl;


					END GENERATE;       -- E_N MULTIC SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  NORTH OUTPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- E_E_... 	<==>		EAST INPUTS <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_E_EAST_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) - 1 GENERATE -- =  EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER	

		E_E_EAST_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL GENERATE -- =  EAST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_E_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_E_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					E_E_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						--signal E_E_east_in_signal_ctrl  : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);
						--signal E_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_E_east_in_signal_ctrl <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL)) when rst = '0' else (others=>'0');

						east_outputs_ctrl(WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL)) <= E_E_east_out_signal_ctrl;

						E_E_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_E_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => E_E_east_in_signal_ctrl,
								output_signal => E_E_east_out_signal_ctrl
							);

					END GENERATE;       --  EAST EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_E_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_E_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_E_mux_east_in_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_E_mux_east_in_signal_ctrl(EAST_INPUT_WIDTH_CTRL - 1 downto 0) <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						east_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= E_E_mux_east_in_signal_ctrl;



					END GENERATE;       -- E_E MULTIC SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  EAST OUTPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 	E_S_... <==>				EAST INPUTS <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_S_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		E_S_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL GENERATE -- = EAST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_S_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_S_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					E_S_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_S_east_in_signal_ctrl   : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);
						signal E_S_south_out_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_S_east_in_signal_ctrl <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL)) when rst = '0' else (others=>'0');

						south_outputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL))) <= wppe_output_regs_vector_ctrl(0 downto 0); --E_S_south_out_signal_ctrl; 

						E_S_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_S_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => E_S_east_in_signal_ctrl,
								output_signal => E_S_south_out_signal_ctrl
							);

					END GENERATE;       --  EAST SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_S_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_S_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_S_mux_east_in_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_S_mux_east_in_signal_ctrl(EAST_INPUT_WIDTH_CTRL - 1 downto 0) <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						south_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= E_S_mux_east_in_signal_ctrl;



					END GENERATE;       -- E_S MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  SOUTH OUTPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 	E_W_...	<==>		EAST INPUTS <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_W_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) - 1 GENERATE -- = WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		E_W_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL GENERATE -- = EAST INPUT PIN NUMBER	 \

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_W_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_W_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					E_W_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_W_east_in_signal_ctrl  : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);
						signal E_W_west_out_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_W_east_in_signal_ctrl <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL)) when rst = '0' else (others=>'0');

						west_outputs_ctrl(EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL))) <= E_W_west_out_signal_ctrl;

						E_W_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_W_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => E_W_east_in_signal_ctrl,
								output_signal => E_W_west_out_signal_ctrl
							);

					END GENERATE;       --  EAST WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_W_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_W_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_W_mux_east_in_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_W_mux_east_in_signal_ctrl(EAST_INPUT_WIDTH_CTRL - 1 downto 0) <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						west_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= E_W_mux_east_in_signal_ctrl;

						-- DEBUGGING ENTITY TO SHOW THE CALCULATED GENERICS


					END GENERATE;       -- E_W MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- E_PROC_... <==>		EAST INPUTS <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	E_PROC_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS) - 1 GENERATE
		E_PROC_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL GENERATE -- =  EAST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			E_PROC_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				E_PROC_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

					E_PROC_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_PROC_east_in_signal_ctrl  : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);
						signal E_PROC_wppe_out_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						E_PROC_east_in_signal_ctrl <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - NORTH_PIN_NUM_CTRL)) when rst = '0' else (others=>'0');

						wppe_input_regs_ctrl(output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL)) <= E_PROC_wppe_out_signal_ctrl
						when rst = '0' else (others=>'0');

						E_PROC_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/E_PROC_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => EAST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH
							)
							port map(
								input_signal  => E_PROC_east_in_signal_ctrl,
								output_signal => E_PROC_wppe_out_signal_ctrl
							);

					END GENERATE;       --  EAST to PROCESSOR CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				E_PROC_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					E_PROC_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal E_PROC_mux_east_in_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						E_PROC_mux_east_in_signal_ctrl(EAST_INPUT_WIDTH_CTRL - 1 downto 0) <= east_inputs_ctrl(EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						wppe_input_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output)
						) <= E_PROC_mux_east_in_signal_ctrl;

						-- DEBUGGING ENTITY TO SHOW THE CALCULATED GENERICS



					END GENERATE;       -- E_PROC MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  PROCESSOR INPUTS CHECK

	END GENERATE;                       --  EAST INPUTS CHECK


	--**************************************************************************************--
	--**************************************************************************************--


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											SOUTH INPUTS
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--


	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- 	S_N_...	<==>		SOUTH INPUTS <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_N_OUTPUTS_CHECK_CTRL : FOR output in 0 to SOUTH_PIN_NUM_CTRL - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		S_N_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL - 1 downto (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_N_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_N_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					S_N_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_N_south_in_signal_ctrl  : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);
						signal S_N_north_out_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_N_south_in_signal_ctrl <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						north_outputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (output + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * output) <= S_N_north_out_signal_ctrl;

						S_N_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_N_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => S_N_south_in_signal_ctrl,
								output_signal => S_N_north_out_signal_ctrl
							);

						north_outputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (output + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * output) <= S_N_north_out_signal_ctrl;

					END GENERATE;       --  SOUTH NORTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_N_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_N_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_N_mux_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_N_mux_south_in_signal_ctrl(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0) <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						north_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= S_N_mux_south_in_signal_ctrl;


					END GENERATE;       -- SOUTH NORTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  NORTH OUTPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- S_E_... <==>		SOUTH INPUTS <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_E_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		S_E_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL - 1 downto (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_E_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_E_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					S_E_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						--signal S_E_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);
						--signal S_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_E_south_in_signal_ctrl <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						east_outputs_ctrl(WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL)) <= S_E_east_out_signal_ctrl;

						S_E_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_E_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => S_E_south_in_signal_ctrl,
								output_signal => S_E_east_out_signal_ctrl
							);

					END GENERATE;       --  SOUTH EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_E_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_E_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_E_mux_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_E_mux_south_in_signal_ctrl(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0) <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						east_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= S_E_mux_south_in_signal_ctrl;



					END GENERATE;       -- SOUTH EAST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  EAST OUTPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- S_S_... <==>		SOUTH INPUTS <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_S_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		S_S_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL - 1 downto (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_S_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_S_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


					S_S_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_S_south_in_signal_ctrl  : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);
						signal S_S_south_out_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_S_south_in_signal_ctrl <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						south_outputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL))) <= wppe_output_regs_vector_ctrl(0 downto 0); --S_S_south_out_signal_ctrl; 

						S_S_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_S_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => S_S_south_in_signal_ctrl,
								output_signal => S_S_south_out_signal_ctrl
							);

					END GENERATE;       --  SOUTH SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_S_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_S_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_S_mux_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_S_mux_south_in_signal_ctrl(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0) <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						south_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= S_S_mux_south_in_signal_ctrl;

						-- DEBUGGING ENTITY TO SHOW THE CALCULATED GENERICS



					END GENERATE;       -- SOUTH SOUTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  SOUTH OUTPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- S_W_...	<==>			SOUTH INPUTS <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_W_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) - 1 GENERATE -- = WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		S_W_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL - 1 downto (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_W_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_W_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					S_W_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_W_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);
						signal S_W_west_out_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_W_south_in_signal_ctrl <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						west_outputs_ctrl(EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL))) <= S_W_west_out_signal_ctrl;

						S_W_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_W_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => S_W_south_in_signal_ctrl,
								output_signal => S_W_west_out_signal_ctrl
							);

					END GENERATE;       --  SOUTH WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_W_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_W_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_W_mux_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_W_mux_south_in_signal_ctrl(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0) <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						west_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= S_W_mux_south_in_signal_ctrl;



					END GENERATE;       -- SOUTH WEST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- S_PROC	<==>		SOUTH INPUTS <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	S_PROC_OUTPUTS_CHECK_CTRL : FOR output in (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) to (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS) - 1 GENERATE
		S_PROC_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL - 1 downto (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) GENERATE -- = SOUTH INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			S_PROC_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				S_PROC_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


					S_PROC_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_PROC_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);
						signal S_PROC_wppe_out_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						S_PROC_south_in_signal_ctrl <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						wppe_input_regs_ctrl(output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL)) <= S_PROC_wppe_out_signal_ctrl
						when rst = '0' else (others=>'0');

						S_PROC_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/S_PROC_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => SOUTH_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH
							)
							port map(
								input_signal  => S_PROC_south_in_signal_ctrl,
								output_signal => S_PROC_wppe_out_signal_ctrl
							);

					END GENERATE;       --  SOUTH PROCESSOR CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				S_PROC_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					S_PROC_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal S_PROC_mux_south_in_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						S_PROC_mux_south_in_signal_ctrl(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0) <= south_inputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL) + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						wppe_input_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output)
						) <= S_PROC_mux_south_in_signal_ctrl;



					END GENERATE;       -- SOUTH PROCESSOR MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  PROCESSOR INPUTS CHECK

	END GENERATE;                       --  SOUTH INPUTS CHECK


	--**************************************************************************************--
	--**************************************************************************************--


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											WEST INPUTS
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_N_... <==> 	WEST INPUTS <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--


	W_N_OUTPUTS_CHECK_CTRL : FOR output in 0 to SOUTH_PIN_NUM_CTRL - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		W_N_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_N_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_N_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_N_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_N_west_in_signal_ctrl   : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);
						signal W_N_north_out_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_N_west_in_signal_ctrl <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						north_outputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (output + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * output) <= W_N_north_out_signal_ctrl;

						W_N_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_N_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => W_N_west_in_signal_ctrl,
								output_signal => W_N_north_out_signal_ctrl
							);

					END GENERATE;       --  WEST NORTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_N_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_N_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_N_mux_west_in_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_N_mux_west_in_signal_ctrl(WEST_INPUT_WIDTH_CTRL - 1 downto 0) <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL +
										SOUTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						north_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= W_N_mux_west_in_signal_ctrl;



					END GENERATE;       -- WEST NORTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  NORTH OUTPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_E_... <==>		WEST INPUTS <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	W_E_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		W_E_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_E_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_E_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_E_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						--signal W_E_west_in_signal_ctrl  : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);
						--signal W_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_E_west_in_signal_ctrl <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						east_outputs_ctrl(WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL)) <= W_E_east_out_signal_ctrl;

						W_E_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_E_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => W_E_west_in_signal_ctrl,
								output_signal => W_E_east_out_signal_ctrl
							);

					END GENERATE;       --  WEST EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				--W_E_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
				W_E_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_E_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_E_mux_west_in_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_E_mux_west_in_signal_ctrl(WEST_INPUT_WIDTH_CTRL - 1 downto 0) <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL +
										SOUTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						east_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= W_E_mux_west_in_signal_ctrl;



					END GENERATE;       -- WEST EAST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  EAST OUTPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_S_...	<==>				WEST INPUTS <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	W_S_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		W_S_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_S_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_S_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_S_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_S_west_in_signal_ctrl   : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);
						signal W_S_south_out_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_S_west_in_signal_ctrl <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						south_outputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL))) <= wppe_output_regs_vector_ctrl(0 downto 0); --W_S_south_out_signal_ctrl; 

						W_S_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_S_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => W_S_west_in_signal_ctrl,
								output_signal => W_S_south_out_signal_ctrl
							);

					END GENERATE;       --  WEST SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_S_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_S_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_S_mux_west_in_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_S_mux_west_in_signal_ctrl(WEST_INPUT_WIDTH_CTRL - 1 downto 0) <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL +
										SOUTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						south_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= W_S_mux_west_in_signal_ctrl;



					END GENERATE;       -- WEST SOUTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  SOUTH OUTPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_W_...		<==>		WEST INPUTS <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	W_W_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1 GENERATE -- = WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		W_W_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_W_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_W_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_W_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_W_west_in_signal_ctrl  : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);
						signal W_W_west_out_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_W_west_in_signal_ctrl <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						west_outputs_ctrl(EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL))) <= W_W_west_out_signal_ctrl;

						W_W_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_W_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => W_W_west_in_signal_ctrl,
								output_signal => W_W_west_out_signal_ctrl
							);

					END GENERATE;       --  WEST WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_W_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_W_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_W_mux_west_in_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_W_mux_west_in_signal_ctrl(WEST_INPUT_WIDTH_CTRL - 1 downto 0) <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL +
										SOUTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						west_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= W_W_mux_west_in_signal_ctrl;



					END GENERATE;       -- WEST WEST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- W_PROC_...	 <==>		WEST INPUTS <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	W_PROC_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS - 1 GENERATE
		W_PROC_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL GENERATE -- = WEST INPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			W_PROC_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				W_PROC_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					W_PROC_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_PROC_west_in_signal_ctrl  : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);
						signal W_PROC_wppe_out_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						W_PROC_west_in_signal_ctrl <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL))) when rst = '0' else (others=>'0');

						wppe_input_regs_ctrl(output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL)) <= W_PROC_wppe_out_signal_ctrl
						when rst = '0' else (others=>'0');

						W_PROC_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/W_PROC_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WEST_INPUT_WIDTH_CTRL,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH
							)
							port map(
								input_signal  => W_PROC_west_in_signal_ctrl,
								output_signal => W_PROC_wppe_out_signal_ctrl
							);

					END GENERATE;       --  WEST PROCESSOR CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				W_PROC_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					W_PROC_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal W_PROC_mux_west_in_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						W_PROC_mux_west_in_signal_ctrl(WEST_INPUT_WIDTH_CTRL - 1 downto 0) <= west_inputs_ctrl(WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL) + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL +
										SOUTH_PIN_NUM_CTRL))
							) when rst = '0' else (others=>'0');

						wppe_input_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output)
						) <= W_PROC_mux_west_in_signal_ctrl;



					END GENERATE;       -- WEST PROCESSOR MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  PROCESSOR INPUTS CHECK

	END GENERATE;                       --  WEST INPUTS CHECK


	--**************************************************************************************--
	--**************************************************************************************--


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--											WPPE OUTPUT REGISTERS 
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--
	--""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""--

	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_N_...	<==>		WPPE OUTPUT REGISTERS  <==>  NORTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_N_OUTPUTS_CHECK_CTRL : FOR output in 0 to SOUTH_PIN_NUM_CTRL - 1 GENERATE -- = NORTH OUTPUT PIN NUMBER = SOUTH INPUT PIN NUMBER

		WPPE_N_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_N_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_N_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					WPPE_N_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_N_wppe_in_signal_ctrl   : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
						signal WPPE_N_north_out_signal_ctrl : std_logic_vector(SOUTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						WPPE_N_wppe_in_signal_ctrl <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL));

						north_outputs_ctrl(SOUTH_INPUT_WIDTH_CTRL * (output + 1) - 1 downto SOUTH_INPUT_WIDTH_CTRL * output) <= WPPE_N_north_out_signal_ctrl;

						WPPE_N_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_N_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH,
								OUTPUT_DATA_WIDTH => SOUTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => WPPE_N_wppe_in_signal_ctrl,
								output_signal => WPPE_N_north_out_signal_ctrl
							);

					END GENERATE;       --  WPPE_OUT to  NORTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_N_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_N_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_N_mux_wppe_in_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						WPPE_N_mux_wppe_in_signal_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL)
							);

						north_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= WPPE_N_mux_wppe_in_signal_ctrl;



					END GENERATE;       -- WPPE NORTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		END GENERATE;                   --  NORTH OUTPUTS CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_E_... 	<==>		WPPE OUTPUT REGISTERS  <==>  EAST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_E_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL - 1 GENERATE -- = EAST OUTPUT PIN NUMBER = WEST INPUT PIN NUMBER

		WPPE_E_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_E_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_E_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					WPPE_E_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						--signal WPPE_E_wppe_in_signal_ctrl  : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
						--signal WPPE_E_east_out_signal_ctrl : std_logic_vector(WEST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						WPPE_E_wppe_in_signal_ctrl <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL));

						east_outputs_ctrl(WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL + 1) - 1 downto WEST_INPUT_WIDTH_CTRL * (output - SOUTH_PIN_NUM_CTRL)) <= WPPE_E_east_out_signal_ctrl;

						WPPE_E_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_E_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH,
								OUTPUT_DATA_WIDTH => WEST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => WPPE_E_wppe_in_signal_ctrl,
								output_signal => WPPE_E_east_out_signal_ctrl
							);

					END GENERATE;       --  WPPE_OUT to EAST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_E_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_E_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_E_mux_wppe_in_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						WPPE_E_mux_wppe_in_signal_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL)
							);

						east_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= WPPE_E_mux_wppe_in_signal_ctrl;



					END GENERATE;       -- WPPE EAST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  EAST OUTPUTS CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_S_...		<==>		WPPE OUTPUT REGISTERS  <==>  SOUTH OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_S_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL - 1 GENERATE -- = SOUTH OUTPUT PIN NUMBER = NORTH INPUT PIN NUMBER

		WPPE_S_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_S_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_S_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					WPPE_S_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_S_wppe_in_signal_ctrl   : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
						signal WPPE_S_south_out_signal_ctrl : std_logic_vector(NORTH_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						WPPE_S_wppe_in_signal_ctrl <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL));

						south_outputs_ctrl(NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL) + 1) - 1 downto NORTH_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL))) <= wppe_output_regs_vector_ctrl(0 downto 0); --WPPE_S_south_out_signal_ctrl; 

						WPPE_S_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_S_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH,
								OUTPUT_DATA_WIDTH => NORTH_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => WPPE_S_wppe_in_signal_ctrl,
								output_signal => WPPE_S_south_out_signal_ctrl
							);

					END GENERATE;       --  WPPE_OUT to SOUTH CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_S_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_S_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_S_mux_wppe_in_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						WPPE_S_mux_wppe_in_signal_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL)
							);

						south_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                      MULTI_SOURCE_MATRIX_CTRL,
								                      input,
								                      output)
						) <= WPPE_S_mux_wppe_in_signal_ctrl;



					END GENERATE;       -- WPPE SOUTH MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  SOUTH OUTPUTS CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_W_...	<==>		WPPE OUTPUT REGISTERS  <==>  WEST OUTPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_W_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL - 1 GENERATE -- WEST OUTPUT PIN NUMBER = EAST INPUT PIN NUMBER

		WPPE_W_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_W_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_W_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


					WPPE_W_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_W_wppe_in_signal_ctrl  : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
						signal WPPE_W_west_out_signal_ctrl : std_logic_vector(EAST_INPUT_WIDTH_CTRL - 1 downto 0);

					begin
						WPPE_W_wppe_in_signal_ctrl <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL));

						west_outputs_ctrl(EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL) + 1) - 1 downto EAST_INPUT_WIDTH_CTRL * (output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL))) <= WPPE_W_west_out_signal_ctrl;

						WPPE_W_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_W_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH,
								OUTPUT_DATA_WIDTH => EAST_INPUT_WIDTH_CTRL
							)
							port map(
								input_signal  => WPPE_W_wppe_in_signal_ctrl,
								output_signal => WPPE_W_west_out_signal_ctrl
							);

					END GENERATE;       --  WPPE_OUT to WEST CONNECTION CHECK ...

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_W_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_W_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_W_mux_wppe_in_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						WPPE_W_mux_wppe_in_signal_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL)
							);

						west_output_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                     MULTI_SOURCE_MATRIX_CTRL,
								                     input,
								                     output)
						) <= WPPE_W_mux_wppe_in_signal_ctrl;



					END GENERATE;       -- WPPE WEST MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WEST OUTPUTS CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK


	--####################
	--##################
	--### CTRL_ICN: ##
	--##############
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
	-- WPPE_PROC_...	<==>	WPPE OUTPUT REGISTERS  <==>  WPPE/PROCESSOR INPUT-REGISTERS INPUTS
	--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

	WPPE_PROC_OUTPUTS_CHECK_CTRL : FOR output in SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL to SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS - 1 GENERATE
		WPPE_PROC_INPUTS_CHECK_CTRL : FOR input in NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS - 1 downto NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL GENERATE -- = WPPE "INPUT" = OUTPUT PIN NUMBER

			--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			WPPE_PROC_DRIVER_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 0 GENERATE
				-- IF any driver(s) for this output signal is needed GENERATE

				WPPE_PROC_FALSE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) = 1 GENERATE
					-- IF only one single driver for this output signal is needed,
					-- hard-wired connection is generated

					--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


					WPPE_PROC_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_PROC_wppe_in_signal_ctrl  : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);
						signal WPPE_PROC_wppe_out_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						WPPE_PROC_wppe_in_signal_ctrl <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL));

						wppe_input_regs_ctrl(output - (SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL + NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL)) <= WPPE_PROC_wppe_out_signal_ctrl
						when rst = '0' else (others=>'0');

						WPPE_PROC_cnn_ctrl : connection
							generic map(
								-- cadence translate_off	
								INSTANCE_NAME     => INSTANCE_NAME & "/WPPE_PROC_cnn_ctrl" & Int_to_string(output) & "_" & Int_to_string(input),

								-- cadence translate_on	
								INPUT_DATA_WIDTH  => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH,
								OUTPUT_DATA_WIDTH => WPPE_GENERICS_RECORD.CTRL_REG_WIDTH
							)
							port map(
								input_signal  => WPPE_PROC_wppe_in_signal_ctrl,
								output_signal => WPPE_PROC_wppe_out_signal_ctrl
							);

					END GENERATE;       --  WPPE_OUT to WPPE_IN CHECK

				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				END GENERATE;           -- FALSE MULTI SOURCE CHECK ...

				WPPE_PROC_TRUE_MS_CHECK_CTRL : IF MULTI_SOURCE_MATRIX_CTRL(0, output) > 1 GENERATE
					-- IF multiple drivers for this output signal are needed,
					-- multiplexer was already generated and 
					-- it is now connected to the input sources

					WPPE_PROC_MS_CONN_CHECK_CTRL : IF ADJACENCY_MATRIX_CTRL(input)(output) = '1' GENERATE
						signal WPPE_PROC_mux_wppe_in_signal_ctrl : std_logic_vector(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0);

					begin
						WPPE_PROC_mux_wppe_in_signal_ctrl(WPPE_GENERICS_RECORD.CTRL_REG_WIDTH - 1 downto 0) <= wppe_output_regs_ctrl(input - (NORTH_PIN_NUM_CTRL + EAST_PIN_NUM_CTRL + SOUTH_PIN_NUM_CTRL + WEST_PIN_NUM_CTRL)
							);

						wppe_input_all_mux_ins_ctrl(calculate_driver_end_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output) downto calculate_driver_begin_ctrl(ADJACENCY_MATRIX_CTRL,
								                    MULTI_SOURCE_MATRIX_CTRL,
								                    input,
								                    output)
						) <= WPPE_PROC_mux_wppe_in_signal_ctrl;



					END GENERATE;       -- WPPE PROCESSOR MULTI SOURCE CONNECTION CHECK 

				END GENERATE;           -- TRUE MULTI SOURCE CHECK

			END GENERATE;               -- DRIVER CHECK ...

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		END GENERATE;                   --  WPPE_IN CHECK

	END GENERATE;                       --  WPPE "INPUTS" = OUTPUTS CHECK

	--#######################################
	--### END CTRL_ICN INSTANTIATION ######
	--###################################
	--#################################
	--###############################


	--**************************************************************************************--
	--**************************************************************************************--

	--=======================================================================================
	--=======================================================================================
	-- 				WPPE COMPONENT INSTANTIATION
	--=======================================================================================
	--=======================================================================================


	core : wppe_2
		generic map(
			--Ericles:
			N                    => N,
			M                    => M,
			-- cadence translate_off	
			INSTANCE_NAME        => INSTANCE_NAME & "/core",

			-- cadence translate_on				
			WPPE_GENERICS_RECORD => WPPE_GENERICS_RECORD
		)
		port map(
			ff_start_detection            => ff_start_detection,
			set_to_config                 => set_to_config,
			pc_debug_out                  => pc_debug_out,
			input_registers               => wppe_input_regs_vector,
			output_registers              => wppe_output_regs_vector,

			--#################
			--### CTRL_ICN: ###
			--	ctrl_inputs		=> ctrl_inputs,
			--	ctrl_outputs	   => ctrl_outputs,
			ctrl_inputs                   => wppe_input_regs_vector_ctrl(NUM_OF_CONTROL_INPUTS * CTRL_REG_WIDTH - 1 downto 0),
			ctrl_outputs                  => wppe_output_regs_vector_ctrl(NUM_OF_CONTROL_OUTPUTS * CTRL_REG_WIDTH - 1 downto 0),
			config_mem_data               => config_mem_data,
			input_fifos_write_en          => input_fifos_write_en,

			--Ericles Sousa on 16 Dec 2014: setting the configuration_done signal. I will be connected to the top file
			configuration_done            => configuration_done,
			mask                          => mask,
			fu_sel                        => fu_sel, 
			pe_sel                        => pe_sel, 
			error_flag                    => error_flag,
			error_diagnosis               => error_diagnosis,
			vliw_config_en                => vliw_config_en,
			icn_config_en                 => icn_config_en,
			common_config_reset           => common_config_reset,
			ctrl_programmable_input_depth => ctrl_programmable_input_depth,
			en_programmable_fd_depth      => en_programmable_fd_depth,
			programmable_fd_depth         => programmable_fd_depth,
			count_down                    => count_down,
			enable_tcpa                   => enable_tcpa,
			config_reg_we                 => internal_config_reg_we,
			config_reg_data               => internal_config_reg_data,
			config_reg_addr               => internal_config_reg_addr,
			clk_in                        => pwr_controlled_clk, --clk,
			rst                           => pwr_controlled_rst --rst

		--			   set_to_config => set_to_config, pc_debug_out(3) => 
		--                           pc_debug_out(3), pc_debug_out(2) => pc_debug_out(2),
		--                           pc_debug_out(1) => pc_debug_out(1), pc_debug_out(0) 
		--                           => pc_debug_out(0), input_registers(31) => 
		--                           wppe_input_regs_vector(31), input_registers(30) => 
		--                           wppe_input_regs_vector(30), input_registers(29) => 
		--                           wppe_input_regs_vector(29), input_registers(28) => 
		--                           wppe_input_regs_vector(28), input_registers(27) => 
		--                           wppe_input_regs_vector(27), input_registers(26) => 
		--                           wppe_input_regs_vector(26), input_registers(25) => 
		--                           wppe_input_regs_vector(25), input_registers(24) => 
		--                           wppe_input_regs_vector(24), input_registers(23) => 
		--                           wppe_input_regs_vector(23), input_registers(22) => 
		--                           wppe_input_regs_vector(22), input_registers(21) => 
		--                           wppe_input_regs_vector(21), input_registers(20) => 
		--                           wppe_input_regs_vector(20), input_registers(19) => 
		--                           wppe_input_regs_vector(19), input_registers(18) => 
		--                           wppe_input_regs_vector(18), input_registers(17) => 
		--                           wppe_input_regs_vector(17), input_registers(16) => 
		--                           wppe_input_regs_vector(16), input_registers(15) => 
		--                           wppe_input_regs_vector(15), input_registers(14) => 
		--                           wppe_input_regs_vector(14), input_registers(13) => 
		--                           wppe_input_regs_vector(13), input_registers(12) => 
		--                           wppe_input_regs_vector(12), input_registers(11) => 
		--                           wppe_input_regs_vector(11), input_registers(10) => 
		--                           wppe_input_regs_vector(10), input_registers(9) => 
		--                           wppe_input_regs_vector(9), input_registers(8) => 
		--                           wppe_input_regs_vector(8), input_registers(7) => 
		--                           wppe_input_regs_vector(7), input_registers(6) => 
		--                           wppe_input_regs_vector(6), input_registers(5) => 
		--                           wppe_input_regs_vector(5), input_registers(4) => 
		--                           wppe_input_regs_vector(4), input_registers(3) => 
		--                           wppe_input_regs_vector(3), input_registers(2) => 
		--                           wppe_input_regs_vector(2), input_registers(1) => 
		--                           wppe_input_regs_vector(1), input_registers(0) => 
		--                           wppe_input_regs_vector(0), output_registers(15) => 
		--                           wppe_output_regs_vector(15), output_registers(14) => 
		--                           wppe_output_regs_vector(14), output_registers(13) => 
		--                           wppe_output_regs_vector(13), output_registers(12) => 
		--                           wppe_output_regs_vector(12), output_registers(11) => 
		--                           wppe_output_regs_vector(11), output_registers(10) => 
		--                           wppe_output_regs_vector(10), output_registers(9) => 
		--                           wppe_output_regs_vector(9), output_registers(8) => 
		--                           wppe_output_regs_vector(8), output_registers(7) => 
		--                           wppe_output_regs_vector(7), output_registers(6) => 
		--                           wppe_output_regs_vector(6), output_registers(5) => 
		--                           wppe_output_regs_vector(5), output_registers(4) => 
		--                           wppe_output_regs_vector(4), output_registers(3) => 
		--                           wppe_output_regs_vector(3), output_registers(2) => 
		--                           wppe_output_regs_vector(2), output_registers(1) => 
		--                           wppe_output_regs_vector(1), output_registers(0) => 
		--                           wppe_output_regs_vector(0), ctrl_inputs(3) => 
		--                           ctrl_inputs(3), ctrl_inputs(2) => ctrl_inputs(2), 
		--                           ctrl_inputs(1) => ctrl_inputs(1), ctrl_inputs(0) => 
		--                           ctrl_inputs(0), ctrl_outputs(3) => ctrl_outputs(3), 
		--                           ctrl_outputs(2) => ctrl_outputs(2), ctrl_outputs(1) 
		--                           => ctrl_outputs(1), ctrl_outputs(0) => 
		--                           ctrl_outputs(0), input_fifos_write_en(1) => 
		--                           input_fifos_write_en(1), input_fifos_write_en(0) => 
		--                           input_fifos_write_en(0), config_mem_data(31) => 
		--                           config_mem_data(31), config_mem_data(30) => 
		--                           config_mem_data(30), config_mem_data(29) => 
		--                           config_mem_data(29), config_mem_data(28) => 
		--                           config_mem_data(28), config_mem_data(27) => 
		--                           config_mem_data(27), config_mem_data(26) => 
		--                           config_mem_data(26), config_mem_data(25) => 
		--                           config_mem_data(25), config_mem_data(24) => 
		--                           config_mem_data(24), config_mem_data(23) => 
		--                           config_mem_data(23), config_mem_data(22) => 
		--                           config_mem_data(22), config_mem_data(21) => 
		--                           config_mem_data(21), config_mem_data(20) => 
		--                           config_mem_data(20), config_mem_data(19) => 
		--                           config_mem_data(19), config_mem_data(18) => 
		--                           config_mem_data(18), config_mem_data(17) => 
		--                           config_mem_data(17), config_mem_data(16) => 
		--                           config_mem_data(16), config_mem_data(15) => 
		--                           config_mem_data(15), config_mem_data(14) => 
		--                           config_mem_data(14), config_mem_data(13) => 
		--                           config_mem_data(13), config_mem_data(12) => 
		--                           config_mem_data(12), config_mem_data(11) => 
		--                           config_mem_data(11), config_mem_data(10) => 
		--                           config_mem_data(10), config_mem_data(9) => 
		--                           config_mem_data(9), config_mem_data(8) => 
		--                           config_mem_data(8), config_mem_data(7) => 
		--                           config_mem_data(7), config_mem_data(6) => 
		--                           config_mem_data(6), config_mem_data(5) => 
		--                           config_mem_data(5), config_mem_data(4) => 
		--                           config_mem_data(4), config_mem_data(3) => 
		--                           config_mem_data(3), config_mem_data(2) => 
		--                           config_mem_data(2), config_mem_data(1) => 
		--                           config_mem_data(1), config_mem_data(0) => 
		--                           config_mem_data(0), config_reg_we => internal_config_reg_we, 
		--                           config_reg_data(5) => internal_config_reg_data(5), 
		--                           config_reg_data(4) => internal_config_reg_data(4), 
		--                           config_reg_data(3) => internal_config_reg_data(3), 
		--                           config_reg_data(2) => internal_config_reg_data(2), 
		--                           config_reg_data(1) => internal_config_reg_data(1), 
		--                           config_reg_data(0) => internal_config_reg_data(0), 
		--                           config_reg_addr(2) => internal_config_reg_addr(2), 
		--                           config_reg_addr(1) => internal_config_reg_addr(1), 
		--                           config_reg_addr(0) => internal_config_reg_addr(0), clk => clk
		--                           , rst => rst
		);

	--=======================================================================================
	--=======================================================================================
	-- 				CONFIGURATION REGISTER FILE COMPONENT INSTANTIATION
	--=======================================================================================
	--=======================================================================================
	ICN_CONFIG_REGISTERS_GEN : IF (WPPE_GENERICS_RECORD.CONFIG_REG_WIDTH > 0) GENERATE
		CONFIG_REG_FILE : mux_sel_config_file
			generic map(
				-- cadence translate_off	
				INSTANCE_NAME               => INSTANCE_NAME & "/CONFIG_REG_FILE",

				-- cadence translate_on	

				--				NORTH_TOTAL_SEL_WIDTH => NORTH_TOTAL_MUX_SEL_WIDTH,		  
				--				EAST_TOTAL_SEL_WIDTH  => EAST_TOTAL_MUX_SEL_WIDTH,
				--				SOUTH_TOTAL_SEL_WIDTH => SOUTH_TOTAL_MUX_SEL_WIDTH,		  
				--				WEST_TOTAL_SEL_WIDTH	 => WEST_TOTAL_MUX_SEL_WIDTH,		  
				--				WPPE_INPUTS_TOTAL_SEL_WIDTH => WPPE_INPUT_TOTAL_MUX_SEL_WIDTH, 

				NORTH_TOTAL_SEL_WIDTH       => NORTH_TOTAL_MUX_SEL_WIDTH + NORTH_TOTAL_MUX_SEL_WIDTH_CTRL,
				EAST_TOTAL_SEL_WIDTH        => EAST_TOTAL_MUX_SEL_WIDTH + EAST_TOTAL_MUX_SEL_WIDTH_CTRL,
				SOUTH_TOTAL_SEL_WIDTH       => SOUTH_TOTAL_MUX_SEL_WIDTH + SOUTH_TOTAL_MUX_SEL_WIDTH_CTRL,
				WEST_TOTAL_SEL_WIDTH        => WEST_TOTAL_MUX_SEL_WIDTH + WEST_TOTAL_MUX_SEL_WIDTH_CTRL,
				WPPE_INPUTS_TOTAL_SEL_WIDTH => WPPE_INPUT_TOTAL_MUX_SEL_WIDTH + WPPE_INPUT_TOTAL_MUX_SEL_WIDTH_CTRL,
				CONFIG_REG_WIDTH            => WPPE_GENERICS_RECORD.CONFIG_REG_WIDTH
			)
			port map(
				clk                     => clk,
				rst                     => rst,
				we                      => internal_config_reg_we,
				new_data_input          => internal_config_reg_data,
				addr_input              => internal_config_reg_addr,

				--		 NORTH_OUT_mux_selects	 => north_output_mux_selects,
				--		 EAST_OUT_mux_selects    => east_output_mux_selects,
				--		 SOUTH_OUT_mux_selects   => south_output_mux_selects,
				--		 WEST_OUT_mux_selects    => west_output_mux_selects,
				--		 WPPE_INPUTS_mux_selects => wppe_input_mux_selects

				NORTH_OUT_mux_selects   => NORTH_OUT_mux_selects_all,
				EAST_OUT_mux_selects    => EAST_OUT_mux_selects_all,
				SOUTH_OUT_mux_selects   => SOUTH_OUT_mux_selects_all,
				WEST_OUT_mux_selects    => WEST_OUT_mux_selects_all,
				WPPE_INPUTS_mux_selects => WPPE_INPUT_mux_selects_all
			);

	END GENERATE ICN_CONFIG_REGISTERS_GEN;

end Behavioral;
