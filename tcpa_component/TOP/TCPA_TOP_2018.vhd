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

----------------------------------------------------------------------------------
-- Company:        Hardware/Software Co-design (LS12) at FAU Erlangen-Nuernberg
-- Engineer:       Ericles Sousa
-- 
-- Create Date:    17:56:04 08/27/2014 
-- Design Name: 
-- Module Name:    TCPA_TOP - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:    Top file for integrating all components of a TCPA architecture
-- 
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- This file also contains the contribution of the following Engineers:
-- Srinivas Boppu and Jupiter Bakakeu
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--library IEEE, synplify;
use IEEE.std_logic_1164.all;
--use synplify.attributes.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library techmap;
use techmap.gencomp.all;

use work.AG_BUFFER_type_lib.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.all;
use wppa_instance_v1_01_a.DEFAULT_LIB.all;
use wppa_instance_v1_01_a.ARRAY_LIB.all;
use wppa_instance_v1_01_a.TYPE_LIB.all;
use wppa_instance_v1_01_a.INVASIC_LIB.all;

use work.data_type_pkg.all;     -- for input and output format between amba_interface and tcpa components

entity TCPA_TOP_2018 is
	generic(
		--###########################################################################
		-- registration TCPA_TOP for amba bus
		--###########################################################################
        hindex : integer := 7;                  -- component index for amba-bus
        haddr  : integer := 16#300#;            -- amba-bus-component address
        hmask  : integer := 16#FC0#;            -- compnent size for amba-bus
        hirq   : integer := 0;


		--###########################################################################
		-- TCPA_TOP parameters, do not add to or delete
		--###########################################################################
		NUM_OF_BUFFER_STRUCTURES              : positive range 1 to 4 := CUR_DEFAULT_NUM_OF_BUFFER_STRUCTURES;
		BUFFER_SIZE                           : integer               := CUR_DEFAULT_MAX_BUFFER_SIZE;
		BUFFER_SIZE_ADDR_WIDTH                : integer               := CUR_DEFAULT_BUFFER_ADDR_WIDTH;
		BUFFER_CHANNEL_SIZE                   : integer               := CUR_DEFAULT_BUFFER_CHANNEL_SIZE;
		BUFFER_CHANNEL_ADDR_WIDTH             : integer               := CUR_DEFAULT_BUFFER_CHANNEL_ADDR_WIDTH;
	        BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := CUR_DEFAULT_CHANNEL_SIZES_ARE_POWER_OF_TWO;
	        EN_ELASTIC_BUFFER                     : boolean               := CUR_DEFAULT_EN_ELASTIC_BUFFER;
		AG_BUFFER_CONFIG_SIZE                 : integer               := CUR_DEFAULT_AG_BUFFER_CONFIG_SIZE;
		AG_BUFFER_NORTH                       : t_ag_buffer_generics  := CUR_DEFAULT_AG_BUFFER_NORTH;
		AG_BUFFER_WEST                        : t_ag_buffer_generics  := CUR_DEFAULT_AG_BUFFER_WEST;
		AG_BUFFER_SOUTH                       : t_ag_buffer_generics  := CUR_DEFAULT_AG_BUFFER_SOUTH;
		AG_BUFFER_EAST                        : t_ag_buffer_generics  := CUR_DEFAULT_AG_BUFFER_EAST;

--        RBUFFER_HIRQ_AHB_INDEX                : integer;
        RBUFFER_HIRQ_AHB_ADDR                 : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_ADDR;
        RBUFFER_HIRQ_AHB_MASK                 : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_MASK;
        RBUFFER_HIRQ_AHB_IRQ                  : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_IRQ;

        INDEX_VECTOR_DIMENSION                : integer range 0 to 32 := 3;
        INDEX_VECTOR_DATA_WIDTH               : integer range 0 to 32 := 17;-- 9;
        MATRIX_PIPELINE_DEPTH                 : integer range 0 to 32 := 2; -- equals log2(INDEX_VECTOR_DIMENSION) + 1
    
        --###########################################################################
        -- Listing of components inside TCPA_TOP
        --###########################################################################
        COMP_NUM_POWER  : integer := 4;         -- 2^4 == 16 components at all 
        COMP_SIZE       : integer := 22;        -- 2^22 == 4 MByte for each component
      
        --tcpa component index
        AG_Buffer_EAST_ID           : integer := 0;
        AG_Buffer_WEST_ID           : integer := 1;
        AG_Buffer_SOUTH_ID          : integer := 2;
        AG_Buffer_NORTH_ID          : integer := 3;
        RBuffer_hirq_ID             : integer := 4;
        top_hw_interface_ID         : integer := 5;
        reconfig_registers_ID       : integer := 6;
        gc_apb_slave_mem_wrapper_ID : integer := 7;
        fault_injection_top_ID      : integer := 8;
    

    --#######################################################################		
    ITERATION_VARIABLE_WIDTH              : integer               := 16;--default value. This constant value is defined in the file GLOBAL_CONTROLLER/minmax_comparator_matrix.v 
    DIMENSION                             : integer               := 3; --default value
    SELECT_WIDTH                          : integer               := 3; --default value
    NO_REG_TO_PROGRAM                     : integer               := 4; --default value
    MATRIX_ELEMENT_WIDTH                  : integer               := 8; --default value
    DATA_WIDTH                            : integer               := 8; --default value
    MAX_NO_OF_PROGRAM_BLOCKS              : integer               := 35;--default value
    NUM_OF_IC_SIGNALS                     : integer               := 3  --default value		
	);
  port(
    -- dclk_in            : in  std_logic;

    -- -- TCPA Signals
    -- TCPA_clk           : in  std_logic;

    ahb_clk_in         : in  std_logic;
    ahb_rstn_in        : in  std_logic;

    -- AG AHB
    ahbsi_in           : in  ahb_slv_in_type;
    ahbso_out          : out apb_slv_out_type
    -- ahbso_out_NORTH    : out ahb_slv_out_type;
    -- ahbso_out_SOUTH    : out ahb_slv_out_type;
    -- ahbso_out_EAST     : out ahb_slv_out_type;
    -- ahbso_out_WEST     : out ahb_slv_out_type;
    -- RBuffer_hirq_out   : out ahb_slv_out_type;
    
    -- reconfig_regs_apbo : out apb_slv_out_type;
    -- CM_apbo            : out apb_slv_out_type;
    -- FI_apbo            : out apb_slv_out_type;
    -- GC Conf Memory APB
    -- apbi_in            : in  apb_slv_in_type;
    -- GC_apbo_out        : out apb_slv_out_type
  );
end TCPA_TOP_2018;

architecture behavior of TCPA_TOP_2018 is
	--attribute syn_noclockbuf of behavior : architecture is true;
	--attribute syn_noclockbuf of TCPA_TOP	: architecture is true;

	--Ericles
	constant CFG_GC_NORTH : integer := 1; --Enable Global Controller on the NORTH side of TCPA
	constant CFG_GC_SOUTH : integer := 0; --Enable Global Controller on the SOUTH side of TCPA
	constant CFG_GC_EAST  : integer := 0; --Enable Global Controller on the EAST  side of TCPA
	constant CFG_GC_WEST  : integer := 0; --Enable Global Controller on the WEST  side of TCPA

	constant CFG_BUFFER_NORTH : integer := 1; --Enable AG and BUFFER NORTH
	constant CFG_BUFFER_SOUTH : integer := 1; --Enable AG and BUFFER SOUTH
	constant CFG_BUFFER_EAST  : integer := 1; --Enable AG and BUFFER EAST 
	constant CFG_BUFFER_WEST  : integer := 1; --Enable AG and BUFFER WEST 

	constant CFG_ENABLE_TCPA            : integer := 1; --Enable TCPA, by providing the interconnection with existing buffers
	constant ENABLE_CHIPSCOPE           : integer := 0; --Used for debug purpose. Note: The chipscope modules may have to be generated for the target FPGA device

	---------------------------------- Components ---------------------------------

    ----------------------------------------  amba_interface
    component amba_interface is
        generic( 
            hindex : integer := 7;                  -- component index for amba-bus
            haddr  : integer := 16#300#;            -- amba-bus-component address
            hmask  : integer := 16#FC0#;            -- compnent size for amba-bus
            hirq   : integer := 0;
            SUM_COMPONENT   : integer;
            COMP_NUM_POWER  : integer := 4;         -- 2^4 == 16 components
            COMP_SIZE       : integer := 22        -- 2^22 == 4 MByte
            );
        port(
            -- data between top and amba_interface
            ahbsi           : in  ahb_slv_in_type;
            ahbso           : out ahb_slv_out_type;
            
            -- data between amba_interface and component
            IF_COMP_data    : out arr_IF_COMP(0 to SUM_COMPONENT-1);    -- array of records
            COMP_IF_data    : in  arr_COMP_IF(0 to SUM_COMPONENT-1)     -- 
          
            -- RB_IF_data      : in rec_COMP_IF;    -- RBuffer_hirq
            -- GC_IF_data      : in rec_COMP_IF;   --gc_apb_slave_mem_wrapper_addr
            -- FI_IF_data      : in rec_COMP_IF;   -- faule invasion
            -- RR_IF_data      : in rec_COMP_IF;   -- reconfig_registers
            -- HW_IF_data      : in rec_COMP_IF;   -- top_hardware_interface
            -- AG_EAST_IF_data : in rec_COMP_IF;   -- AG_Buffer_Wrapper_EAST
            -- AG_WEST_IF_data : in rec_COMP_IF;   -- AG_Buffer_Wrapper_WEST
            -- AG_SOUTH_IF_data : in rec_COMP_IF;  -- AG_Buffer_Wrapper_SOUTH
            -- AG_NORTH_IF_data : in rec_COMP_IF;  -- AG_Buffer_Wrapper_NORTH
            
            -- AG_IF_ahbso_EAST_valid           :  in std_ulogic;
            -- AG_IF_ahbso_WEST_valid           :  in std_ulogic;  
            -- AG_IF_ahbso_SOUTH_valid          :  in std_ulogic;
            -- AG_IF_ahbso_NORTH_valid          :  in std_ulogic;
            -- faultTOP_IF_apbo_valid           :  in std_ulogic
            
            );	
    end component amba_interface;
    
    

    
    
    ----------------------------------------  RBuffer_hirq
	component RBuffer_hirq is
  	generic (
		NUM_OF_BUFFER_STRUCTURES : integer := 4;
		CHANNEL_COUNT_NORTH      : integer := 4;
		CHANNEL_COUNT_WEST       : integer := 4;
		CHANNEL_COUNT_SOUTH      : integer := 4;
		CHANNEL_COUNT_EAST       : integer := 4;
		hindex                   : integer := 0;
		-- haddr                    : integer := 0;
		-- hmask                    : integer := 16#FFF#;
		hirq                     : integer := 0;
        SUM_COMPONENT            : integer
        );
	  port (
		rstn                 : in  std_ulogic;
		clk                  : in  std_ulogic;
		irq_clear            : out std_logic_vector(3 downto 0);
		north_buffers_irq    : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_NORTH - 1 downto 0) := (others => '0');
		west_buffers_irq     : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1 downto 0)  := (others => '0');
		south_buffers_irq    : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_SOUTH - 1 downto 0) := (others => '0');
		east_buffers_irq     : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_EAST - 1 downto 0)  := (others => '0');
		-- ahbsi                : in  ahb_slv_in_type;
		-- ahbso                : out ahb_slv_out_type
        IF_COMP_data         : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
        RB_IF_data           : out rec_COMP_IF    -- RBuffer_hirq
        );
	end component RBuffer_hirq;

    
    ----------------------------------------  AHB_AG_Buffer_Wrapper
	component AHB_AG_Buffer_Wrapper is
		generic(
	                DESIGN_TYPE                           : integer range 0 to 7  := 1;
	                ENABLE_PIXEL_BUFFER_MODE              : integer range 0 to 31 := 1;
	
	                CONFIG_DATA_WIDTH                     : integer range 0 to 32 := 32;
	                CONFIG_ADDR_WIDTH                     : integer range 0 to 32 := 10;
	
	                INDEX_VECTOR_DIMENSION                : integer range 0 to 32 := 3;
	                INDEX_VECTOR_DATA_WIDTH               : integer range 0 to 32 := 9;
	                MATRIX_PIPELINE_DEPTH                 : integer range 0 to 32 := 2; 
	
	                CHANNEL_DATA_WIDTH                    : integer range 0 to 32 := 32;
	                CHANNEL_ADDR_WIDTH                    : integer range 0 to 64 := 18;
	                CHANNEL_COUNT                         : integer range 0 to 32 := 4;
	
	                AG_CONFIG_ADDR_WIDTH                  : integer range 0 to 32 := 6; 
	                AG_CONFIG_DATA_WIDTH                  : integer range 0 to 32 := 9; 
	                AG_BUFFER_CONFIG_SIZE                 : integer := 1024; 
	
                    NUM_OF_BUFFER_STRUCTURES              : positive range 1 to 8 := 4;
	                BUFFER_CONFIG_ADDR_WIDTH              : integer range 0 to 32 := 4; 
	                BUFFER_CONFIG_DATA_WIDTH              : integer range 0 to 32 := 32;
	                BUFFER_ADDR_HEADER_WIDTH              : integer range 0 to 54 := 8; 
	                BUFFER_SEL_REG_WIDTH                  : integer range 0 to 8  := 4; 
	                BUFFER_CSR_DELAY_SELECTOR_WIDTH       : integer range 0 to 32 := 6; 
	                BUFFER_SIZE                           : integer               := 4096;
	                BUFFER_SIZE_ADDR_WIDTH                : integer               := 12;
	                BUFFER_CHANNEL_SIZE                   : integer               := 1024;
	                BUFFER_CHANNEL_ADDR_WIDTH             : integer               := 10;
	                BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := TRUE;
	                EN_ELASTIC_BUFFER                     : boolean               := FALSE;
	
	                hindex                                : integer               := 0;
	                hirq                                  : integer               := 0;
	                -- haddr                                 : integer               := 0;
	                -- hmask                                 : integer               := 16#fff#
                    SUM_COMPONENT                         : integer
		);
		port(
			clk                      : in  std_logic;
			reset                    : in  std_logic;
			gc_reset                 : in  std_logic;

			start                    : in  std_logic;

			-- configuration state
			config_done              : out std_logic;
			restart_ext              : out std_logic;

			-- AG Signals
			AG_buffer_interrupt      : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
			index_vector             : in  std_logic_vector(INDEX_VECTOR_DIMENSION * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);

			-- TCPA Signals
			--dvi_input                : in  std_logic_vector(CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
			--dvi_input                : in  std_logic_vector(CHANNEL_DATA_WIDTH-1 downto 0);
			--dvi_in_en                : out std_logic;
			cpu_tcpa_buffer          : in cpu_tcpa_buffer_type;

			channel_tcpa_input_data  : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
			channel_tcpa_output_data : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);

			-- AG Addrs
			AG_out_addr_out          : out std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0);
			AG_en                    : in  std_logic;
			AG_out_en_out            : out std_logic;
	
			-- Buffer IRQs
			buffers_irq              : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT - 1 downto 0);
			irq_clear                : in std_logic;
			buffer_event             : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);

			ahb_clk                  : in  std_logic;
			ahb_rstn                 : in  std_logic;
			-- ahbsi                    : in  ahb_slv_in_type;
			-- ahbso                    : out ahb_slv_out_type
            IF_COMP_data             : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
            AG_IF_data               : out rec_COMP_IF   
            
            
		);
	end component AHB_AG_Buffer_Wrapper;

	-------------------------------------------------------------------------------------
	-- Global controller - Configuration Memory
	-------------------------------------------------------------------------------------
	component gc_apb_slave_mem_wrapper
		generic(
			pindex      : integer := 0;
			-- paddr       : integer := 0;
			-- pmask       : integer := 16#ff0#;
            pirq        : integer := 0;
			NO_OF_WORDS : integer := 1024;
            SUM_COMPONENT   : integer
		);
		port(
			rstn        : in  std_ulogic;
			clk         : in  std_ulogic;
			start       : in  std_logic;
			stop        : in  std_logic;
			--apbi        : in  apb_slv_in_type;
			conf_en     : in  std_logic;
			rnready     : in  std_logic;
			config_done : in  std_logic;
			gc_done     : in  std_logic;
			gc_irq      : out std_logic;
			--apbo        : out apb_slv_out_type;
			dout        : out std_logic_vector(31 downto 0);
			pdone       : out std_logic;
			gc_reset    : out std_logic;
            
            IF_COMP_data    : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
            GC_IF_data      : out rec_COMP_IF   --gc_apb_slave_mem_wrapper
		);
	end component;

	component GC_AG_glue
		generic(
			CHANNEL_COUNT_NORTH      : integer := 4;
			CHANNEL_COUNT_SOUTH      : integer := 4;
			CHANNEL_COUNT_EAST       : integer := 4;
			CHANNEL_COUNT_WEST       : integer := 4;
			NUM_OF_BUFFER_STRUCTURES : integer := 4;
			START_DELAY              : integer := 16
		);
		port(
			rst                       : in  std_logic;
			clk                       : in  std_logic;
			ag_config_done_north      : in  std_logic;
			ag_config_done_south      : in  std_logic;
			ag_config_done_east       : in  std_logic;
			ag_config_done_west       : in  std_logic;

			AG_irq_NORTH              : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
			AG_irq_WEST               : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
			AG_irq_SOUTH              : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
			AG_irq_EAST               : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);

			north_buffers_event       : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
			west_buffers_event        : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
			south_buffers_event       : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
			east_buffers_event        : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
	
			error_status    	  : in t_error_status;
			
			gc_irq                    : in  std_logic;
			gc_config_done            : in  std_logic;
			gc_ready                  : in  std_logic;
			tcpa_config_done          : in  std_logic;

			syn_rst                   : out std_logic;
			tcpa_config_done_computed : out std_logic;

			tcpa_cmd_start            : out std_logic;
			tcpa_cmd_stop             : out std_logic;

			gc_cmd_start              : out std_logic;
			gc_cmd_stop               : out std_logic;

			ag_cmd_start              : out std_logic;
			ag_cmd_stop               : out std_logic
		);
	end component GC_AG_glue;

    
------------------------------------------------------------------------------------------------------------------
-----This is the top level design for rectangular global controller design.
	component gc_rectangular_top
		generic(
			ITERATION_VARIABLE_WIDTH : integer := ITERATION_VARIABLE_WIDTH; --default value
			DIMENSION                : integer := DIMENSION; --default value
			SELECT_WIDTH             : integer := SELECT_WIDTH; --default value
			NO_REG_TO_PROGRAM        : integer := NO_REG_TO_PROGRAM; --default value
			MATRIX_ELEMENT_WIDTH     : integer := MATRIX_ELEMENT_WIDTH; --default value
			DATA_WIDTH               : integer := DATA_WIDTH; --default value
			MAX_NO_OF_PROGRAM_BLOCKS : integer := MAX_NO_OF_PROGRAM_BLOCKS; --default value
			NUM_OF_IC_SIGNALS        : integer := NUM_OF_IC_SIGNALS --default value
		);
		port(
			conf_clk      : in  std_logic; -- conf clock should be connected to the apb clck
			conf_bus      : in  std_logic_vector(ITERATION_VARIABLE_WIDTH - 1 downto 0); -- configuration bus, later connected to APB slave interface	--or the memory in the APB slave interface
			reset         : in  std_logic;
			tcpa_clk      : in  std_logic;
			dclk_in       : in  std_logic; -- clock for the dynamic reconfiguration port, please refer to "ug191.pdf" from xilinx for more details
			stop          : in  std_logic;
			start         : in  std_logic;
			global_en     : out std_logic;
			restart_ext   : in  std_logic;
			pdone         : in  std_logic;
			ic            : out std_logic_vector(0 to NUM_OF_IC_SIGNALS - 1);
			config_done   : out std_logic;
			config_busy   : out std_logic;
			conf_en       : out std_logic;
			cready        : out std_logic;
			current_i     : out std_logic_vector(31 downto 0);
			current_j     : out std_logic_vector(31 downto 0);
			current_k     : out std_logic_vector(31 downto 0);
			x_bus         : out std_logic_vector(0 to DIMENSION * ITERATION_VARIABLE_WIDTH - 1);
			ivar_next_bus : out std_logic_vector(0 to DIMENSION * ITERATION_VARIABLE_WIDTH - 1);
			reinitialize  : out std_logic;
			gc_done       : out std_logic;
			dcm_lock      : out std_logic;
			gc_clk        : out std_logic
		);
	end component;
    
    
------------------------------------------------------------------------------------------------------------------
-----    This module provides the hardware interface to configure and program a TCPA
	component top_hardware_interface is
		generic(
			pindex : integer := 13;
			-- paddr  : integer := 13;
			-- pmask  : integer := 16#fff#
            SUM_COMPONENT   : integer
            );
		port(
			rst                          : in  std_ulogic;
			amba_clk                     : in  std_ulogic;
			--wppa_data_output             : t_wppa_data_output_interface;

			wppa_bus_input_interface     : out t_wppa_bus_input_interface;
			wppa_bus_output_interface    : in  t_wppa_bus_output_interface;
			wppa_memory_input_interface  : out t_wppa_memory_input_interface;
			wppa_memory_output_interface : in  t_wppa_memory_output_interface;
			--
			tcpa_config_done             : in  std_logic;
			tcpa_config_done_vector      : in  std_logic_vector(31 downto 0);
			enable_tcpa                  : out std_logic;
			--
			icp_program_interface        : out t_prog_intfc;
			invasion_input               : out t_inv_sig;
			invasion_output              : in  t_inv_sig;
			parasitary_invasion_input    : out t_inv_sig;
			parasitary_invasion_output   : in  t_inv_sig;
			tcpa_config_rst              : out std_logic;
			-- apbi                         : in  apb_slv_in_type;
			-- apbo                         : out apb_slv_out_type
            IF_COMP_data                 : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
            HW_IF_data                   : out rec_COMP_IF 
            );
	end component;

	component WPPA_TOP IS
		GENERIC(
			-- cadence translate_off 
			INSTANCE_NAME : string          := "WPPA_TOP_LEVEL_MODULE";
			-- cadence translate_on 
			wppa_generics : t_wppa_generics := DEFAULT_WPPA_GENERICS
		);
		PORT(
			clk, rst                     : in  std_logic;

			-- Bus 
			wppa_bus_input_interface     : in  t_wppa_bus_input_interface;
			wppa_bus_output_interface    : out t_wppa_bus_output_interface;
			-- Data 
			wppa_data_input              : in  t_wppa_data_input_interface;
			wppa_data_output             : out t_wppa_data_output_interface;
			-- Control 
			wppa_ctrl_input              : in  t_wppa_ctrl_input_interface;
			wppa_ctrl_output             : out t_wppa_ctrl_output_interface;
			wppa_memory_input_interface  : in  t_wppa_memory_input_interface;
			wppa_memory_output_interface : out t_wppa_memory_output_interface;
			fault_injection              : in t_fault_injection_module;
			error_status                 : out t_error_status;
			tcpa_config_done             : out std_logic;
			tcpa_config_done_vector      : out std_logic_vector(31 downto 0);
			ctrl_programmable_depth      : in  t_ctrl_programmable_depth;
			en_programmable_fd_depth     : in  t_en_programmable_fd_depth;
			programmable_fd_depth        : in  t_programmable_fd_depth;
			pc_debug_out                 : out t_pc_debug_outs;
			enable_tcpa                  : in  std_logic;
			icp_program_interface        : in  t_prog_intfc;
			invasion_input               : in  t_inv_sig;
			invasion_output              : out t_inv_sig;
			parasitary_invasion_input    : in  t_inv_sig;
			parasitary_invasion_output   : out t_inv_sig
		);

	end component;
	--Importing WPPA_TOP as a black box
	--attribute syn_black_box : boolean; 
	--attribute syn_black_box of  WPPA_TOP: component is true; 
    
------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------                       fault_injection_top  
	component fault_injection_top is
	        generic (
	                MEM_SIZE          : integer := 256;
	                DATA_WIDTH        : integer := 32;
	                ADDR_WIDTH        : integer := 8;
                    NUM_OF_IC_SIGNALS : integer := 1;
	                pindex            : integer := 15;
	                pirq              : integer := 15;
	                -- paddr             : integer := 15;
	                -- pmask             : integer := 16#fff#
                    SUM_COMPONENT   : integer
                    );
	        port (
	                rstn            : in std_ulogic;
	                clk             : in std_ulogic;
                    tcpa_start      : in std_logic;
                    tcpa_stop       : in std_logic;
	                fault_injection : out t_fault_injection_module;
                    error_status    : in t_error_status;
	                -- apbi            : in apb_slv_in_type;
	                -- apbo            : out apb_slv_out_type
                    IF_COMP_data             : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
                    FI_IF_data               : out rec_COMP_IF
                    );
	end component;

    
------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------                       reconfig_registers 
	component reconfig_registers is
		generic(
			pindex : integer := 12;
			-- paddr  : integer := 12;
			-- pmask  : integer := 16#fff#
            SUM_COMPONENT   : integer
            );
		port(
			rst                      : in  std_ulogic;
			gc_reset                 : in  std_ulogic;
			clk                      : in  std_ulogic;
			ctrl_programmable_depth  : out t_ctrl_programmable_depth;
			en_programmable_fd_depth : out t_en_programmable_fd_depth;
			programmable_fd_depth    : out t_programmable_fd_depth;
			ic 			 : in std_logic;
			gc_current_i             : in std_logic_vector(31 downto 0);
			gc_current_j             : in std_logic_vector(31 downto 0);
			gc_current_k             : in std_logic_vector(31 downto 0);
			AG_out_addr_i_NORTH      : in std_logic_vector(31 downto 0);
			AG_out_addr_i_WEST       : in std_logic_vector(31 downto 0);
			AG_out_addr_i_SOUTH      : in std_logic_vector(31 downto 0);
			AG_out_addr_i_EAST       : in std_logic_vector(31 downto 0);
                        AG_config_done_NORTH     : in std_logic;
                        AG_config_done_WEST      : in std_logic;
                        AG_config_done_SOUTH     : in std_logic;
                        AG_config_done_EAST      : in std_logic;
                        gc_config_done           : in std_logic;
                        tcpa_config_done         : in std_logic;
			tcpa_pc_debug_in         : in t_pc_debug_outs;
			tcpa_clk_en              : in std_logic;
			tcpa_start               : in std_logic;
			tcpa_stop                : in std_logic;
			fault_injection          : in t_fault_injection_module; 
			-- apbi                     : in  apb_slv_in_type;
			-- apbo                     : out apb_slv_out_type
            IF_COMP_data             : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
            RR_IF_data               : out rec_COMP_IF
            );
	end component;

	component chipscope_icon_kc705
		PORT(
			CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
			CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
	end component;

	component chipscope_ila_kc705
		PORT(
			CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
			CLK     : IN    STD_LOGIC;
			DATA    : IN    STD_LOGIC_VECTOR(1023 DOWNTO 0);
			TRIG0   : IN    STD_LOGIC_VECTOR(63 DOWNTO 0));

	end component;

	component chipscope_vio_kc705_v2
		PORT(
			CONTROL  : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
			CLK      : IN    STD_LOGIC;
			--ASYNC_IN  : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
			--ASYNC_OUT : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
			--SYNC_IN   : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
			SYNC_OUT : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0));
	end component;
	---------------------------------- End Components -----------------------------

	---------------------------------- Attributes -----------------------------
	--attribute syn_black_box : boolean;
	--attribute syn_black_box of chipscope_icon_kc705 : component is TRUE;
	--attribute syn_black_box of chipscope_ila_kc705 : component is TRUE;
	--attribute syn_black_box of chipscope_vio_kc705 : component is TRUE;

	--attribute syn_noprune : boolean;
	--attribute syn_noprune OF chipscope_icon_inst : LABEL IS true;
	--attribute syn_noprune OF chipscope_ila_inst : LABEL IS true;
	--attribute syn_noprune OF chipscope_vio_inst : LABEL IS true;

	--attribute syn_keep : boolean;
	--attribute syn_keep of AHB_AG_Buffer_Wrapper_NORTH, AHB_AG_Buffer_Wrapper_WEST, AHB_AG_Buffer_Wrapper_EAST, AG_GC_glue_Inst : label is true;
	--attribute syn_preserve : boolean;
	--attribute syn_preserve of AHB_AG_Buffer_Wrapper_NORTH, AHB_AG_Buffer_Wrapper_WEST, AHB_AG_Buffer_Wrapper_EAST, AG_GC_glue_Inst : label is true;
	---------------------------------- End of Attributes -----------------------------


	---------------------------------- Signals ------------------------------------
	-- Internal signals
	signal tcpa_rst        : std_logic;
	signal tcpa_config_rst : std_logic;
	signal tcpa_start, sig_tcpa_start   : std_logic;
	signal tcpa_stop, sig_tcpa_stop     : std_logic;
	signal tcpa_clk_en, sig_tcpa_clk_en : std_logic;
	signal tcpa_clk_s      : std_logic;
	signal glue_syn_rst    : std_logic;
	signal gc_irq, gc_done : std_logic;
	signal cpu_tcpa_buffer_reg : cpu_tcpa_buffer_type;

	-- AG signals
	signal AG_start, AG_stop       : std_logic;
	signal AG_config_done_NORTH    : std_logic;
	signal AG_config_done_SOUTH    : std_logic;
	signal AG_config_done_EAST     : std_logic;
	signal AG_config_done_WEST     : std_logic;
	signal AG_out_addr_i_NORTH     : std_logic_vector(AG_BUFFER_NORTH.CHANNEL_ADDR_WIDTH - 1 downto 0);
	signal sig_AG_out_addr_i_NORTH : std_logic_vector(31 downto 0);
	signal AG_out_en_i_NORTH       : std_logic;
	signal AG_out_addr_i_WEST      : std_logic_vector(AG_BUFFER_WEST.CHANNEL_ADDR_WIDTH - 1 downto 0);
	signal sig_AG_out_addr_i_WEST  : std_logic_vector(31 downto 0);
	signal AG_out_en_i_WEST        : std_logic;
	signal AG_out_addr_i_SOUTH     : std_logic_vector(AG_BUFFER_SOUTH.CHANNEL_ADDR_WIDTH - 1 downto 0);
	signal sig_AG_out_addr_i_SOUTH : std_logic_vector(31 downto 0);
	signal AG_out_en_i_SOUTH       : std_logic;
	signal AG_out_addr_i_EAST      : std_logic_vector(AG_BUFFER_EAST.CHANNEL_ADDR_WIDTH - 1 downto 0);
	signal sig_AG_out_addr_i_EAST  : std_logic_vector(31 downto 0);
	signal AG_out_en_i_EAST        : std_logic;
	signal sig_fault_injection     : t_fault_injection_module; 
	signal sig_error_status        : t_error_status; 

	signal AG_index_vector : std_logic_vector(INDEX_VECTOR_DIMENSION * INDEX_VECTOR_DATA_WIDTH - 1 downto 0) := (others => '0');

	-- WPPA Signals
	signal channel_tcpa_input_data_NORTH  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_NORTH.CHANNEL_DATA_WIDTH * AG_BUFFER_NORTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal channel_tcpa_output_data_NORTH : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_NORTH.CHANNEL_DATA_WIDTH * AG_BUFFER_NORTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal channel_tcpa_input_data_SOUTH  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_SOUTH.CHANNEL_DATA_WIDTH * AG_BUFFER_SOUTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal channel_tcpa_output_data_SOUTH : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_SOUTH.CHANNEL_DATA_WIDTH * AG_BUFFER_SOUTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal channel_tcpa_input_data_EAST   : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_EAST.CHANNEL_DATA_WIDTH * AG_BUFFER_EAST.CHANNEL_COUNT - 1 downto 0)   := (others => '0');
	signal channel_tcpa_output_data_EAST  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_EAST.CHANNEL_DATA_WIDTH * AG_BUFFER_EAST.CHANNEL_COUNT - 1 downto 0)   := (others => '0');
	signal channel_tcpa_input_data_WEST   : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_WEST.CHANNEL_DATA_WIDTH * AG_BUFFER_WEST.CHANNEL_COUNT - 1 downto 0)   := (others => '0');
	signal channel_tcpa_output_data_WEST  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_WEST.CHANNEL_DATA_WIDTH * AG_BUFFER_WEST.CHANNEL_COUNT - 1 downto 0)   := (others => '0');
	
	signal sig_channel_tcpa_input_data_NORTH  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_NORTH.CHANNEL_DATA_WIDTH * AG_BUFFER_NORTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal sig_channel_tcpa_output_data_NORTH : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_NORTH.CHANNEL_DATA_WIDTH * AG_BUFFER_NORTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal sig_channel_tcpa_input_data_SOUTH  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_SOUTH.CHANNEL_DATA_WIDTH * AG_BUFFER_SOUTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal sig_channel_tcpa_output_data_SOUTH : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_SOUTH.CHANNEL_DATA_WIDTH * AG_BUFFER_SOUTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal sig_channel_tcpa_input_data_EAST   : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_EAST.CHANNEL_DATA_WIDTH * AG_BUFFER_EAST.CHANNEL_COUNT - 1 downto 0)   := (others => '0');
	signal sig_channel_tcpa_output_data_EAST  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_EAST.CHANNEL_DATA_WIDTH * AG_BUFFER_EAST.CHANNEL_COUNT - 1 downto 0)   := (others => '0');
	signal sig_channel_tcpa_input_data_WEST   : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_WEST.CHANNEL_DATA_WIDTH * AG_BUFFER_WEST.CHANNEL_COUNT - 1 downto 0)   := (others => '0');
	signal sig_channel_tcpa_output_data_WEST  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_WEST.CHANNEL_DATA_WIDTH * AG_BUFFER_WEST.CHANNEL_COUNT - 1 downto 0)   := (others => '0');
	signal RBuffer_hirq_i                     : ahb_slv_out_type;

	signal restart_ext_north : std_logic;
	signal restart_ext_south : std_logic;
	signal restart_ext_west  : std_logic;
	signal restart_ext_east  : std_logic;

	signal gc_config_dout              : std_logic_vector(31 downto 0);
	signal gc_current_i                : std_logic_vector(31 downto 0);
	signal gc_current_j                : std_logic_vector(31 downto 0);
	signal gc_current_k                : std_logic_vector(31 downto 0);
	signal gc_reset                    : std_logic;
	signal gc_clk                      : std_logic;
	signal gc_stop                     : std_logic;
	signal gc_start                    : std_logic;
	signal gc_pdone                    : std_logic;
	--
	signal gc_config_done              : std_logic;
	signal gc_rnready                  : std_logic;
	signal gc_conf_en, gc_global_en    : std_logic;
	signal gc_cready                   : std_logic;
	signal gc_iteration_vector_current : std_logic_vector(0 to DIMENSION * ITERATION_VARIABLE_WIDTH - 1) := (others => '0');
	signal gc_iteration_vector_next    : std_logic_vector(0 to DIMENSION * ITERATION_VARIABLE_WIDTH - 1) := (others => '0');
	signal gc_last_iteration           : std_logic;
	signal tcpa_config_done_computed_i : std_logic;
	--

	signal dcm_lock       : std_logic;
	signal gc_restart_ext : std_logic;

	--AG IRQ is generated when an AG reaches a programmed address position, which is defined during the AG configuration
	signal north_ag_irq_i       : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0) := (others => '0');
	signal east_ag_irq_i        : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0) := (others => '0');
	signal south_ag_irq_i       : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0) := (others => '0');
	signal west_ag_irq_i        : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0)  := (others => '0');

	--A buffer IRQ is generated if a channel reaches a programmed address position, which is defined during the buffer configuration
	signal north_buffers_irq_i  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_NORTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal east_buffers_irq_i   : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_EAST.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal south_buffers_irq_i  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_SOUTH.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal west_buffers_irq_i   : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * AG_BUFFER_WEST.CHANNEL_COUNT - 1 downto 0) := (others => '0');
	signal RBuffer_hirq_clear   : std_logic_vector(3 downto 0); -- 4 bit values, because of the 4 sides of TCPA, north, west, south, and east

	--Bufer Events are generated if a buffer is empty or full
	signal north_buffers_event_i : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
	signal west_buffers_event_i  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
	signal south_buffers_event_i : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
	signal east_buffers_event_i : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);


	signal TCPA_ic_in, TCPA_ic_out : std_logic_vector(0 to NUM_OF_IC_SIGNALS - 1) := (others => '0');
--	To include when more than one GC is introduced
--	type t_tcpa_ic is array (0 to CUR_DEFAULT_NUM_WPPE_VERTICAL-1, 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1) of std_logic_vector(0 to NUM_OF_IC_SIGNALS - 1);
--	signal TCPA_ic_in, TCPA_ic_out : t_tcpa_ic;

	signal sig_gc_ic                         : std_logic;
	signal sig_AG_addr                       : std_logic_vector(19 downto 0);
--	signal sig_dvi_to_tcpa                   : std_logic_vector(31 downto 0);
--	signal sig_dvi_tcpa_ic                   : std_logic;
--	signal sig_dvi_in_en_north               : std_logic;
--	signal sig_dvi_in_en_south               : std_logic;
--	signal sig_dvi_in_en_east                : std_logic;
--	signal sig_dvi_in_en_west                : std_logic;

	signal sig_wppa_data_input               : t_wppa_data_input_interface  := (others => (others => '0'));
	signal sig_wppa_data_output              : t_wppa_data_output_interface := (others => (others => '0'));
	signal sig_wppa_bus_input_interface      : t_wppa_bus_input_interface;
	signal sig_wppa_bus_output_interface     : t_wppa_bus_output_interface;
	signal sig_wppa_memory_input_interface   : t_wppa_memory_input_interface;
	signal sig_wppa_memory_output_interface  : t_wppa_memory_output_interface;
	--
	signal sig_wppa_ctrl_input               : t_wppa_ctrl_input_interface  := (others => (others => '0'));
	signal sig_wppa_ctrl_output              : t_wppa_ctrl_output_interface := (others => (others => '0'));
	--
	signal sig_configuration_done            : std_logic;
	signal sig_configuration_done_vector     : std_logic_vector(31 downto 0);
	signal sig_ctrl_programmable_depth       : t_ctrl_programmable_depth;
	signal sig_en_programmable_fd_depth      : t_en_programmable_fd_depth;
	signal temp_sig_programmable_fd_depth    : t_programmable_fd_depth;
	signal temp_sig_en_programmable_fd_depth : t_en_programmable_fd_depth;
	signal sig_programmable_fd_depth         : t_programmable_fd_depth;
	signal reg_en_programmable_fd_depth      : t_en_programmable_fd_depth;
	signal reg_programmable_fd_depth         : t_programmable_fd_depth;
	--
	signal sig_icp_program_interface         : t_prog_intfc;
	signal sig_invasion_input                : t_inv_sig                    := (others => '0');
	signal sig_invasion_output               : t_inv_sig                    := (others => '0');
	signal sig_parasitary_invasion_input     : t_inv_sig                    := (others => '0');
	signal sig_parasitary_invasion_output    : t_inv_sig                    := (others => '0');
	signal sig_enable_tcpa, sig_enable_tcpa_i: std_logic;
	signal sync_rst                          : std_logic;
	signal sync                              : std_logic;

	signal sig_pc_debug_out, sig_pc_debug_in : t_pc_debug_outs;
	--Chipscope Signals and components
	signal chipscope_trigers : std_logic_vector(63 downto 0)   := (others => '0');
	signal chipscope_data    : std_logic_vector(1023 downto 0) := (others => '0');
	signal icon_control0     : STD_LOGIC_VECTOR(35 DOWNTO 0);
	signal vio_control1      : STD_LOGIC_VECTOR(35 DOWNTO 0);

	signal vio_async_in  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal vio_async_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal vio_sync_in   : STD_LOGIC_VECTOR(63 DOWNTO 0);
	signal vio_sync_out  : STD_LOGIC_VECTOR(63 DOWNTO 0);

	signal gc_start_mux_select : std_logic;
	signal gc_start_input      : std_logic;
	signal gc_start_mux_out    : std_logic;
	signal gc_rstn             : std_logic; --active low
	signal glue_logic_rst      : std_logic;

	-------------------------------------------------------------------------------
	function reverse_any_vector(a : in std_logic_vector) return std_logic_vector is
		variable result : std_logic_vector(a'RANGE);
		alias aa        : std_logic_vector(a'REVERSE_RANGE) is a;
	begin
		for i in aa'RANGE loop
			result(i) := aa(i);
		end loop;
		return result;
	end;
    
    
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	constant TCPA_TOP_CONFIG : ahb_config_type := (
		0      => ahb_device_reg(VENDOR_CONTRIB, CONTRIB_CORE1, 0, 0, 0),
		4      => ahb_membar(haddr, '0', '0', hmask),
		others => zero32);
    
    signal SUM_COMPONENT  : integer := 2**COMP_NUM_POWER;
    
    
    signal IF_COMP_data    :  arr_IF_COMP(0 to SUM_COMPONENT-1);
    signal COMP_IF_data    :  arr_COMP_IF(0 to SUM_COMPONENT-1);
    signal COMP_IF_data_copy :  arr_COMP_IF(0 to SUM_COMPONENT-1);
    
    -- signal RB_IF_data       :  rec_COMP_IF    -- RBuffer_hirq
    -- signal GC_IF_data       :  rec_COMP_IF;   -- gc_apb_slave_mem_wrapper_addr
    -- signal FI_IF_data       :  rec_COMP_IF;   -- faule invasion
    -- signal RR_IF_data       :  rec_COMP_IF;   -- reconfig_registers
    -- signal HW_IF_data       :  rec_COMP_IF;   -- top_hardware_interface
    -- signal AG_EAST_IF_data  :  rec_COMP_IF;   -- AG_Buffer_Wrapper_EAST
    -- signal AG_WEST_IF_data  :  rec_COMP_IF;   -- AG_Buffer_Wrapper_WEST
    -- signal AG_SOUTH_IF_data :  rec_COMP_IF;   -- AG_Buffer_Wrapper_SOUTH
    -- signal AG_NORTH_IF_data :  rec_COMP_IF;   -- AG_Buffer_Wrapper_NORTH
    
    signal    AG_IF_ahbso_EAST_valid           :  std_ulogic;
    signal    AG_IF_ahbso_WEST_valid           :  std_ulogic;  
    signal    AG_IF_ahbso_SOUTH_valid          :  std_ulogic;
    signal    AG_IF_ahbso_NORTH_valid          :  std_ulogic;
    signal    faultTOP_IF_apbo_valid           :  std_ulogic;
    

begin
	tcpa_rst         <= tcpa_config_rst or sync_rst or not ahb_rstn_in;
	--gc_rstn        <= sig_configuration_done;
	gc_rstn          <= not tcpa_config_rst;
	--glue_logic_rst <= not sig_configuration_done;
	glue_logic_rst   <= tcpa_config_rst;
	--tcpa_clk_en      <= '1' when tcpa_stop = '0' else '0';
	--tcpa_clk_en      <= (not gc_reset) and (not tcpa_stop);
	tcpa_clk_en      <= '1';
	
--	TCPA_BUFGCE  : BUFGCE port map(I => TCPA_clk, CE => tcpa_clk_en, O => TCPA_clk_s);

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------- output signal updating
    COMP_IF_data <= COMP_IF_data_copy;
------------------------------------------------------------------------------


	amba_interface_i : amba_interface
    generic map( 
            hindex => hindex,    -- component index for amba-bus
            haddr  => haddr,    -- amba-bus-component address
            hmask  => hmask, 
            hirq   => hirq,
            SUM_COMPONENT   => SUM_COMPONENT,
            COMP_NUM_POWER  => COMP_NUM_POWER,
            COMP_SIZE       => COMP_SIZE
            )
    port map(
            -- data between top and amba_interface
            ahbsi           => ahbsi,
            ahbso           => ahbso,
            
            -- data between amba_interface and component
            IF_COMP_data    => IF_COMP_data,
            COMP_IF_data    => COMP_IF_data
            );	


	rbuffer_hirq_inst : RBuffer_hirq
  	generic map (
		NUM_OF_BUFFER_STRUCTURES => NUM_OF_BUFFER_STRUCTURES, 
		CHANNEL_COUNT_NORTH      => AG_BUFFER_NORTH.CHANNEL_COUNT,
		CHANNEL_COUNT_WEST       => AG_BUFFER_WEST.CHANNEL_COUNT,
		CHANNEL_COUNT_SOUTH      => AG_BUFFER_SOUTH.CHANNEL_COUNT,
		CHANNEL_COUNT_EAST       => AG_BUFFER_EAST.CHANNEL_COUNT,
		hindex                   => RBuffer_hirq_ID,    --RBUFFER_HIRQ_AHB_INDEX, 
		-- haddr                    => RBUFFER_HIRQ_AHB_ADDR,
		-- hmask                    => RBUFFER_HIRQ_AHB_MASK,
		hirq                     => RBUFFER_HIRQ_AHB_IRQ,
        SUM_COMPONENT            => SUM_COMPONENT)
        
	  port map(
		rstn              => ahb_rstn_in,
		clk               => ahb_clk_in         --TCPA_clk,
		irq_clear         => RBuffer_hirq_clear,
		north_buffers_irq => north_buffers_irq_i,
		west_buffers_irq  => west_buffers_irq_i,
		south_buffers_irq => south_buffers_irq_i,
		east_buffers_irq  => east_buffers_irq_i,
		-- ahbsi             => ahbsi_in,
		-- ahbso             => RBuffer_hirq_out
        IF_COMP_data      => arr_IF_COMP(0 to SUM_COMPONENT-1),
        RB_IF_data        => COMP_IF_data_copy(RBuffer_hirq_ID)
        );


	BUFFER_NORTH : if CFG_BUFFER_NORTH = 1 generate
        AG_IF_ahbso_NORTH_valid <= '1';
		AHB_AG_Buffer_Wrapper_NORTH : AHB_AG_Buffer_Wrapper
			generic map(
				DESIGN_TYPE                           => AG_BUFFER_NORTH.DESIGN_TYPE,
				ENABLE_PIXEL_BUFFER_MODE              => AG_BUFFER_NORTH.ENABLE_PIXEL_BUFFER_MODE,
				CONFIG_DATA_WIDTH                     => AG_BUFFER_NORTH.CONFIG_DATA_WIDTH,
				CONFIG_ADDR_WIDTH                     => AG_BUFFER_NORTH.CONFIG_ADDR_WIDTH,
				INDEX_VECTOR_DIMENSION                => INDEX_VECTOR_DIMENSION,
				INDEX_VECTOR_DATA_WIDTH               => INDEX_VECTOR_DATA_WIDTH,
				MATRIX_PIPELINE_DEPTH                 => MATRIX_PIPELINE_DEPTH,
				CHANNEL_DATA_WIDTH                    => AG_BUFFER_NORTH.CHANNEL_DATA_WIDTH,
				CHANNEL_ADDR_WIDTH                    => AG_BUFFER_NORTH.CHANNEL_ADDR_WIDTH,
				CHANNEL_COUNT                         => AG_BUFFER_NORTH.CHANNEL_COUNT,
				AG_CONFIG_ADDR_WIDTH                  => AG_BUFFER_NORTH.AG_CONFIG_ADDR_WIDTH,
				AG_CONFIG_DATA_WIDTH                  => INDEX_VECTOR_DATA_WIDTH,
				AG_BUFFER_CONFIG_SIZE                 => CUR_DEFAULT_AG_BUFFER_CONFIG_SIZE,
				BUFFER_CONFIG_ADDR_WIDTH              => AG_BUFFER_NORTH.BUFFER_CONFIG_ADDR_WIDTH,
				BUFFER_CONFIG_DATA_WIDTH              => AG_BUFFER_NORTH.BUFFER_CONFIG_DATA_WIDTH,
				BUFFER_ADDR_HEADER_WIDTH              => AG_BUFFER_NORTH.BUFFER_ADDR_HEADER_WIDTH,
				BUFFER_SEL_REG_WIDTH                  => AG_BUFFER_NORTH.BUFFER_SEL_REG_WIDTH,
				BUFFER_CSR_DELAY_SELECTOR_WIDTH       => AG_BUFFER_NORTH.BUFFER_CSR_DELAY_SELECTOR_WIDTH,
				BUFFER_SIZE                           => CUR_DEFAULT_MAX_BUFFER_SIZE,
				BUFFER_SIZE_ADDR_WIDTH                => CUR_DEFAULT_BUFFER_ADDR_WIDTH,
				BUFFER_CHANNEL_SIZE                   => CUR_DEFAULT_BUFFER_CHANNEL_SIZE,
			        BUFFER_CHANNEL_ADDR_WIDTH             => CUR_DEFAULT_BUFFER_CHANNEL_ADDR_WIDTH,
	                	BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
		                EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER, 
				hindex                                => AG_Buffer_NORTH_ID, --AG_BUFFER_NORTH.AG_hindex,
                hirq                                  => AG_BUFFER_NORTH.AG_hirq,
				-- haddr                                 => AG_BUFFER_NORTH.AG_haddr,
				-- hmask                                 => AG_BUFFER_NORTH.AG_hmask
                SUM_COMPONENT                         => SUM_COMPONENT
            
            )
			port map(
				clk                      => ahb_clk_in -- TCPA_clk, --gc_clk,
				reset                    => tcpa_rst,
				gc_reset                 => gc_reset,
				start                    => AG_start,

				-- configuration state
				config_done              => AG_config_done_NORTH,
				restart_ext              => restart_ext_north,
				
				-- AG Signals
				AG_buffer_interrupt      => north_ag_irq_i,
				--buffer_interrupts        => north_ag_irq_i,
				index_vector             => AG_index_vector, -- should be mapped

				-- AG addr out - en
				AG_out_addr_out          => AG_out_addr_i_NORTH,
				AG_en                    => gc_global_en,
				AG_out_en_out            => AG_out_en_i_NORTH,

				-- TCPA Signals
				--dvi_input                => sig_dvi_to_tcpa,
				--dvi_in_en                => sig_dvi_in_en_north,
				cpu_tcpa_buffer          => cpu_tcpa_buffer_reg,
				channel_tcpa_input_data  => channel_tcpa_input_data_NORTH,
				channel_tcpa_output_data => channel_tcpa_output_data_NORTH,
				buffers_irq              => north_buffers_irq_i,
				buffer_event             => north_buffers_event_i,
				irq_clear                => RBuffer_hirq_clear(0),
				ahb_clk                  => ahb_clk_in,
				ahb_rstn                 => ahb_rstn_in,
				-- ahbsi                    => ahbsi_in,
				-- ahbso                    => ahbso_out_NORTH
                IF_COMP_data             => IF_COMP_data,
                AG_IF_data               => COMP_IF_data_copy(AG_Buffer_NORTH_ID)
                
			);
	end generate;
	NO_BUFFER_NORTH : if CFG_BUFFER_NORTH = 0 generate
		AG_config_done_NORTH           <= '1';
		north_ag_irq_i                 <= (others => '0');
		north_buffers_irq_i            <= (others => '0');
		north_buffers_event_i           <= (others => '0');
		restart_ext_north              <= '0';
		channel_tcpa_output_data_NORTH <= (others => '0');
        AG_IF_ahbso_NORTH_valid         <= '0';             		--ahbso_out_NORTH                <= ahbs_none;   
	end generate;

    
    
	BUFFER_SOUTH : if CFG_BUFFER_SOUTH = 1 generate
        AG_IF_ahbso_SOUTH_valid         <= '1'; 
		AHB_AG_Buffer_Wrapper_SOUTH : AHB_AG_Buffer_Wrapper
			generic map(
				DESIGN_TYPE                           => AG_BUFFER_SOUTH.DESIGN_TYPE,
				ENABLE_PIXEL_BUFFER_MODE              => AG_BUFFER_SOUTH.ENABLE_PIXEL_BUFFER_MODE,
				CONFIG_DATA_WIDTH                     => AG_BUFFER_SOUTH.CONFIG_DATA_WIDTH,
				CONFIG_ADDR_WIDTH                     => AG_BUFFER_SOUTH.CONFIG_ADDR_WIDTH,
				INDEX_VECTOR_DIMENSION                => INDEX_VECTOR_DIMENSION,
				INDEX_VECTOR_DATA_WIDTH               => INDEX_VECTOR_DATA_WIDTH,
				MATRIX_PIPELINE_DEPTH                 => MATRIX_PIPELINE_DEPTH,
				CHANNEL_DATA_WIDTH                    => AG_BUFFER_SOUTH.CHANNEL_DATA_WIDTH,
				CHANNEL_ADDR_WIDTH                    => AG_BUFFER_SOUTH.CHANNEL_ADDR_WIDTH,
				CHANNEL_COUNT                         => AG_BUFFER_SOUTH.CHANNEL_COUNT,
				AG_CONFIG_ADDR_WIDTH                  => AG_BUFFER_SOUTH.AG_CONFIG_ADDR_WIDTH,
				AG_CONFIG_DATA_WIDTH                  => INDEX_VECTOR_DATA_WIDTH,
				AG_BUFFER_CONFIG_SIZE                 => CUR_DEFAULT_AG_BUFFER_CONFIG_SIZE,
				BUFFER_CONFIG_ADDR_WIDTH              => AG_BUFFER_SOUTH.BUFFER_CONFIG_ADDR_WIDTH,
				BUFFER_CONFIG_DATA_WIDTH              => AG_BUFFER_SOUTH.BUFFER_CONFIG_DATA_WIDTH,
				BUFFER_ADDR_HEADER_WIDTH              => AG_BUFFER_SOUTH.BUFFER_ADDR_HEADER_WIDTH,
				BUFFER_SEL_REG_WIDTH                  => AG_BUFFER_SOUTH.BUFFER_SEL_REG_WIDTH,
				BUFFER_CSR_DELAY_SELECTOR_WIDTH       => AG_BUFFER_SOUTH.BUFFER_CSR_DELAY_SELECTOR_WIDTH,
				BUFFER_SIZE                           => CUR_DEFAULT_MAX_BUFFER_SIZE,
				BUFFER_SIZE_ADDR_WIDTH                => CUR_DEFAULT_BUFFER_ADDR_WIDTH,
				BUFFER_CHANNEL_SIZE                   => CUR_DEFAULT_BUFFER_CHANNEL_SIZE,
			        BUFFER_CHANNEL_ADDR_WIDTH             => CUR_DEFAULT_BUFFER_CHANNEL_ADDR_WIDTH,
	                	BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
		                EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER, 
				hindex                                => AG_Buffer_SOUTH_ID,     --AG_BUFFER_SOUTH.AG_hindex,
				hirq                                  => AG_BUFFER_SOUTH.AG_hirq,
				-- haddr                                 => AG_BUFFER_SOUTH.AG_haddr,
				-- hmask                                 => AG_BUFFER_SOUTH.AG_hmask
                SUM_COMPONENT                         => SUM_COMPONENT
            )
			port map(
				clk                      => ahb_clk_in  --TCPA_clk,
				reset                    => tcpa_rst,
				gc_reset                 => gc_reset,
				start                    => AG_start,

				--configuration state
				config_done              => AG_config_done_SOUTH,
				restart_ext              => restart_ext_south,

				--AG Signals
				AG_buffer_interrupt      => south_ag_irq_i,
				--buffer_interrupts        => south_ag_irq_i,
				index_vector             => AG_index_vector, --should be mapped

				-- AG addr out - en
				AG_out_addr_out          => AG_out_addr_i_SOUTH,
				AG_en                    => gc_global_en,
				AG_out_en_out            => AG_out_en_i_SOUTH,

				-- TCPA Signals
				--dvi_input                => sig_dvi_to_tcpa,
				--dvi_in_en                => sig_dvi_in_en_south,
				cpu_tcpa_buffer          => cpu_tcpa_buffer_reg,
				channel_tcpa_input_data  => channel_tcpa_input_data_SOUTH,
				channel_tcpa_output_data => channel_tcpa_output_data_SOUTH,
				buffers_irq              => south_buffers_irq_i,
				buffer_event             => south_buffers_event_i,
				irq_clear                => RBuffer_hirq_clear(2),
				ahb_clk                  => ahb_clk_in,
				ahb_rstn                 => ahb_rstn_in,
				-- ahbsi                    => ahbsi_in,
				-- ahbso                    => ahbso_out_SOUTH
                IF_COMP_data             => IF_COMP_data,
                AG_IF_data               => COMP_IF_data_copy(AG_Buffer_SOUTH_ID)
                
			);
	end generate;
	NO_BUFFER_SOUTH : if CFG_BUFFER_SOUTH = 0 generate
		AG_config_done_SOUTH           <= '1';
		south_ag_irq_i                 <= (others => '0');
		south_buffers_irq_i            <= (others => '0');
		south_buffers_event_i           <= (others => '0');
		restart_ext_south              <= '0';
		channel_tcpa_output_data_SOUTH <= (others => '0');
		AG_IF_ahbso_SOUTH_valid         <= '0'; --ahbso_out_SOUTH                <= ahbs_none;
	end generate;

	BUFFER_EAST : if CFG_BUFFER_EAST = 1 generate
        AG_IF_ahbso_EAST_valid <= '1';
		AHB_AG_Buffer_Wrapper_EAST : AHB_AG_Buffer_Wrapper
			generic map(
				DESIGN_TYPE                           => AG_BUFFER_EAST.DESIGN_TYPE,
				ENABLE_PIXEL_BUFFER_MODE              => AG_BUFFER_EAST.ENABLE_PIXEL_BUFFER_MODE,
				CONFIG_DATA_WIDTH                     => AG_BUFFER_EAST.CONFIG_DATA_WIDTH,
				CONFIG_ADDR_WIDTH                     => AG_BUFFER_EAST.CONFIG_ADDR_WIDTH,
				INDEX_VECTOR_DIMENSION                => INDEX_VECTOR_DIMENSION,
				INDEX_VECTOR_DATA_WIDTH               => INDEX_VECTOR_DATA_WIDTH,
				MATRIX_PIPELINE_DEPTH                 => MATRIX_PIPELINE_DEPTH,
				CHANNEL_DATA_WIDTH                    => AG_BUFFER_EAST.CHANNEL_DATA_WIDTH,
				CHANNEL_ADDR_WIDTH                    => AG_BUFFER_EAST.CHANNEL_ADDR_WIDTH,
				CHANNEL_COUNT                         => AG_BUFFER_EAST.CHANNEL_COUNT,
				AG_CONFIG_ADDR_WIDTH                  => AG_BUFFER_EAST.AG_CONFIG_ADDR_WIDTH,
				AG_CONFIG_DATA_WIDTH                  => INDEX_VECTOR_DATA_WIDTH,
				AG_BUFFER_CONFIG_SIZE                 => CUR_DEFAULT_AG_BUFFER_CONFIG_SIZE,
				BUFFER_CONFIG_ADDR_WIDTH              => AG_BUFFER_EAST.BUFFER_CONFIG_ADDR_WIDTH,
				BUFFER_CONFIG_DATA_WIDTH              => AG_BUFFER_EAST.BUFFER_CONFIG_DATA_WIDTH,
				BUFFER_ADDR_HEADER_WIDTH              => AG_BUFFER_EAST.BUFFER_ADDR_HEADER_WIDTH,
				BUFFER_SEL_REG_WIDTH                  => AG_BUFFER_EAST.BUFFER_SEL_REG_WIDTH,
				BUFFER_CSR_DELAY_SELECTOR_WIDTH       => AG_BUFFER_EAST.BUFFER_CSR_DELAY_SELECTOR_WIDTH,
				BUFFER_SIZE                           => CUR_DEFAULT_MAX_BUFFER_SIZE,
				BUFFER_SIZE_ADDR_WIDTH                => CUR_DEFAULT_BUFFER_ADDR_WIDTH,
				BUFFER_CHANNEL_SIZE                   => CUR_DEFAULT_BUFFER_CHANNEL_SIZE,
			        BUFFER_CHANNEL_ADDR_WIDTH             => CUR_DEFAULT_BUFFER_CHANNEL_ADDR_WIDTH,
	                	BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
		                EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER, 
				hindex                                => AG_Buffer_EAST_ID,      --AG_BUFFER_EAST.AG_hindex,
				hirq                                  => AG_BUFFER_EAST.AG_hirq,
				-- haddr                                 => AG_BUFFER_EAST.AG_haddr,
				-- hmask                                 => AG_BUFFER_EAST.AG_hmask
                SUM_COMPONENT                         => SUM_COMPONENT
            )
			port map(
				clk                      => ahb_clk_in  --TCPA_clk, --gc_clk,
				reset                    => tcpa_rst,
				gc_reset                 => gc_reset,
				start                    => AG_start,

				-- configuration state
				config_done              => AG_config_done_EAST,
				restart_ext              => restart_ext_east,

				-- AG Signals
				AG_buffer_interrupt      => east_ag_irq_i,
				--buffer_interrupts        => east_ag_irq_i,
				index_vector             => AG_index_vector, -- should be mapped

				-- AG addr out - en
				AG_out_addr_out          => AG_out_addr_i_EAST,
				AG_en                    => gc_global_en,
				AG_out_en_out            => AG_out_en_i_EAST,

				-- TCPA Signals
				--dvi_input                => sig_dvi_to_tcpa,
				--dvi_in_en                => sig_dvi_in_en_east,
				cpu_tcpa_buffer          => cpu_tcpa_buffer_reg,
				channel_tcpa_input_data  => channel_tcpa_input_data_EAST,
				channel_tcpa_output_data => channel_tcpa_output_data_EAST,
				buffers_irq              => east_buffers_irq_i,
				buffer_event             => east_buffers_event_i,
				irq_clear                => RBuffer_hirq_clear(3),
				ahb_clk                  => ahb_clk_in,
				ahb_rstn                 => ahb_rstn_in,
				-- ahbsi                    => ahbsi_in,
				-- ahbso                    => ahbso_out_EAST
                IF_COMP_data             => IF_COMP_data,
                AG_IF_data               => COMP_IF_data_copy(AG_Buffer_EAST_ID)
                
			);
	end generate;
	NO_BUFFER_EAST : if CFG_BUFFER_EAST = 0 generate
		AG_config_done_EAST           <= '1';
		east_ag_irq_i                 <= (others => '0');
		east_buffers_irq_i            <= (others => '0');
		east_buffers_event_i          <= (others => '0');
		restart_ext_east              <= '0';
		channel_tcpa_output_data_EAST <= (others => '0');
		AG_IF_ahbso_EAST_valid        <= '0';  --ahbso_out_EAST                <= ahbs_none;
	end generate;

    
    
	BUFFER_WEST : if CFG_BUFFER_WEST = 1 generate
        AG_IF_ahbso_WEST_valid <= '1';
		AHB_AG_Buffer_Wrapper_WEST : AHB_AG_Buffer_Wrapper
			generic map(
				DESIGN_TYPE                           => AG_BUFFER_WEST.DESIGN_TYPE,
				ENABLE_PIXEL_BUFFER_MODE              => AG_BUFFER_WEST.ENABLE_PIXEL_BUFFER_MODE,
				CONFIG_DATA_WIDTH                     => AG_BUFFER_WEST.CONFIG_DATA_WIDTH,
				CONFIG_ADDR_WIDTH                     => AG_BUFFER_WEST.CONFIG_ADDR_WIDTH,
				INDEX_VECTOR_DIMENSION                => INDEX_VECTOR_DIMENSION,
				INDEX_VECTOR_DATA_WIDTH               => INDEX_VECTOR_DATA_WIDTH,
				MATRIX_PIPELINE_DEPTH                 => MATRIX_PIPELINE_DEPTH,
				CHANNEL_DATA_WIDTH                    => AG_BUFFER_WEST.CHANNEL_DATA_WIDTH,
				CHANNEL_ADDR_WIDTH                    => AG_BUFFER_WEST.CHANNEL_ADDR_WIDTH,
				CHANNEL_COUNT                         => AG_BUFFER_WEST.CHANNEL_COUNT,
				AG_CONFIG_ADDR_WIDTH                  => AG_BUFFER_WEST.AG_CONFIG_ADDR_WIDTH,
				AG_CONFIG_DATA_WIDTH                  => INDEX_VECTOR_DATA_WIDTH,
				AG_BUFFER_CONFIG_SIZE                 => CUR_DEFAULT_AG_BUFFER_CONFIG_SIZE,
				BUFFER_CONFIG_ADDR_WIDTH              => AG_BUFFER_WEST.BUFFER_CONFIG_ADDR_WIDTH,
				BUFFER_CONFIG_DATA_WIDTH              => AG_BUFFER_WEST.BUFFER_CONFIG_DATA_WIDTH,
				BUFFER_ADDR_HEADER_WIDTH              => AG_BUFFER_WEST.BUFFER_ADDR_HEADER_WIDTH,
				BUFFER_SEL_REG_WIDTH                  => AG_BUFFER_WEST.BUFFER_SEL_REG_WIDTH,
				BUFFER_CSR_DELAY_SELECTOR_WIDTH       => AG_BUFFER_WEST.BUFFER_CSR_DELAY_SELECTOR_WIDTH,
				BUFFER_SIZE                           => CUR_DEFAULT_MAX_BUFFER_SIZE,
				BUFFER_SIZE_ADDR_WIDTH                => CUR_DEFAULT_BUFFER_ADDR_WIDTH,
				BUFFER_CHANNEL_SIZE                   => CUR_DEFAULT_BUFFER_CHANNEL_SIZE,
			        BUFFER_CHANNEL_ADDR_WIDTH             => CUR_DEFAULT_BUFFER_CHANNEL_ADDR_WIDTH,
	                	BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
		                EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER, 
				hindex                                => AG_Buffer_WEST_ID,       --AG_BUFFER_WEST.AG_hindex,
				hirq                                  => AG_BUFFER_WEST.AG_hirq,
				-- haddr                                 => AG_BUFFER_WEST.AG_haddr,
				-- hmask                                 => AG_BUFFER_WEST.AG_hmask
                SUM_COMPONENT                         => SUM_COMPONENT
            )
			port map(
				clk                      => ahb_clk_in  --TCPA_clk, --gc_clk,
				reset                    => tcpa_rst,
				start                    => AG_start,
				gc_reset                 => gc_reset, 
				-- configuration state
				config_done              => AG_config_done_WEST,
				restart_ext              => restart_ext_west,

				-- AG Signals
				AG_buffer_interrupt      => west_ag_irq_i,
				--buffer_interrupts        => west_ag_irq_i,
				index_vector             => AG_index_vector,

				-- AG addr out - en
				AG_out_addr_out          => AG_out_addr_i_WEST,
				AG_en                    => gc_global_en,
				AG_out_en_out            => AG_out_en_i_WEST,

				-- TCPA Signals
				--dvi_input                => sig_dvi_to_tcpa,
				--dvi_in_en                => sig_dvi_in_en_west,
				cpu_tcpa_buffer          => cpu_tcpa_buffer_reg,
				channel_tcpa_input_data  => channel_tcpa_input_data_WEST,
				channel_tcpa_output_data => channel_tcpa_output_data_WEST,
				buffers_irq              => west_buffers_irq_i,
				buffer_event             => west_buffers_event_i,
				irq_clear                => RBuffer_hirq_clear(1),
				ahb_clk                  => ahb_clk_in,
				ahb_rstn                 => ahb_rstn_in,
				-- ahbsi                    => ahbsi_in,
				-- ahbso                    => ahbso_out_WEST
                IF_COMP_data             => IF_COMP_data,
                AG_IF_data               => COMP_IF_data_copy(AG_Buffer_WEST_ID)
			);
	end generate;
	NO_BUFFER_WEST : if CFG_BUFFER_WEST = 0 generate
		AG_config_done_WEST           <= '1';
		west_ag_irq_i                 <= (others => '0');
		west_buffers_irq_i            <= (others => '0');
		west_buffers_event_i          <= (others => '0');
		restart_ext_west              <= '0';
		channel_tcpa_output_data_WEST <= (others => '0');
		AG_IF_ahbso_WEST_valid        <= '0';  --ahbso_out_WEST                <= ahbs_none;
	end generate;

    -------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
    
	GLOBAL_CONTROLLER_RESTART_LOGIC : process(TCPA_clk, glue_logic_rst, TCPA_ic_in) is
	begin
		if glue_logic_rst = '1' then
			gc_restart_ext <= '0';
			sync_rst       <= '0';
			sync           <= '0';

		elsif rising_edge(TCPA_clk) then
			--Ericles: To be implemented in the future
			--      if CFG_GC_NORTH = 1 generate...
			--	sig_wppa_ctrl_input.external_top_north_in_ctrl(0) <= gc_north_ic(0);

			--      if CFG_GC_SOUTH = 1 generate...
			--	sig_wppa_ctrl_input.external_bottom_south_in_ctrl(0) <= gc_south_ic(0);

			--      if CFG_GC_EAST = 1 generate...
			--	sig_wppa_ctrl_input.external_right_east_in_ctrl(0) <= gc_east_ic(0);

			--      if CFG_GC_WEST = 1 generate...
			--	sig_wppa_ctrl_input.external_left_west_in_ctrl(0) <= gc_west_ic(0);

			for i in 0 to CUR_DEFAULT_NUM_WPPE_VERTICAL -1 loop 
					sig_wppa_ctrl_input.external_right_east_in_ctrl(i) <= TCPA_ic_in(0);
					sig_wppa_ctrl_input.external_left_west_in_ctrl(i) <= TCPA_ic_in(0);
			end loop;

			for i in 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL -1 loop 
					sig_wppa_ctrl_input.external_top_north_in_ctrl(i) <= TCPA_ic_in(0);
					sig_wppa_ctrl_input.external_bottom_south_in_ctrl(i) <= TCPA_ic_in(0);
			end loop;
			
			--gc_restart_ext  <= restart_ext_north or restart_ext_east or restart_ext_south or restart_ext_west or tcpa_start;
			gc_restart_ext <= '0';
			--gc_start_mux_out <= gc_start_input when gc_start_mux_select = '1' else gc_start;
			if gc_start_mux_select = '1' then
				gc_start_mux_out <= gc_start_input;
			else
				gc_start_mux_out <= gc_start;
			end if;
			if sync = '0' then
				if (glue_syn_rst = '1') then
					sync     <= '1';
					sync_rst <= '1';
				end if;
			else
				sync_rst <= '0';
			end if;

			sig_AG_out_addr_i_NORTH(AG_BUFFER_NORTH.CHANNEL_ADDR_WIDTH - 1 downto 0) <= AG_out_addr_i_NORTH;
			sig_AG_out_addr_i_WEST(AG_BUFFER_NORTH.CHANNEL_ADDR_WIDTH - 1 downto 0)  <= AG_out_addr_i_WEST;
			sig_AG_out_addr_i_SOUTH(AG_BUFFER_NORTH.CHANNEL_ADDR_WIDTH - 1 downto 0) <= AG_out_addr_i_SOUTH;
			sig_AG_out_addr_i_EAST(AG_BUFFER_NORTH.CHANNEL_ADDR_WIDTH - 1 downto 0)  <= AG_out_addr_i_EAST;

			sig_pc_debug_in <= sig_pc_debug_out;
			sig_tcpa_clk_en <= tcpa_clk_en;
			sig_tcpa_stop   <= tcpa_stop;
			sig_tcpa_start  <= tcpa_start;

		end if;
	end process;

    -------------------------------------------------------------------------------
	-------------------------------------------------------------------------------  
    
	AG_GC_glue_Inst : GC_AG_glue
		generic map(
			CHANNEL_COUNT_NORTH      => AG_BUFFER_NORTH.CHANNEL_COUNT,
			CHANNEL_COUNT_SOUTH      => AG_BUFFER_SOUTH.CHANNEL_COUNT,
			CHANNEL_COUNT_EAST       => AG_BUFFER_EAST.CHANNEL_COUNT,
			CHANNEL_COUNT_WEST       => AG_BUFFER_WEST.CHANNEL_COUNT,
			NUM_OF_BUFFER_STRUCTURES => NUM_OF_BUFFER_STRUCTURES
		)
		port map(
			rst                     => glue_logic_rst,
			clk                     => ahb_clk_in   --TCPA_clk, -- gc_clk,
			AG_config_done_NORTH    => AG_config_done_NORTH,
			AG_config_done_SOUTH    => AG_config_done_SOUTH,
			AG_config_done_EAST     => AG_config_done_EAST,
			AG_config_done_WEST     => AG_config_done_WEST,

			AG_irq_NORTH            => north_ag_irq_i,
			AG_irq_WEST             => west_ag_irq_i,
			AG_irq_SOUTH            => south_ag_irq_i,
			AG_irq_EAST             => east_ag_irq_i,
	
			north_buffers_event     => north_buffers_event_i,
			west_buffers_event      => west_buffers_event_i,
			south_buffers_event     => south_buffers_event_i,
			east_buffers_event      => east_buffers_event_i,

			error_status            => sig_error_status,
			gc_irq			=> gc_irq,
			gc_config_done          => gc_config_done,
			gc_ready                => gc_cready,
			tcpa_config_done        => sig_configuration_done,
			syn_rst                 => glue_syn_rst,
			tcpa_cmd_start          => tcpa_start,
			tcpa_cmd_stop           => tcpa_stop,
			gc_cmd_start            => gc_start,
			gc_cmd_stop             => gc_stop,
			ag_cmd_start            => AG_start,
			ag_cmd_stop             => AG_stop
		);
		sig_enable_tcpa_i <= '0' when (gc_stop or AG_stop or tcpa_stop) = '1' else sig_enable_tcpa;

	-- Global Controller - Configuaration Memory
	--Srinivas
	--GC_apbo_out <= apb_none;
    
    -------------------------------------------------------------------------------
	-------------------------------------------------------------------------------    

	test_gc_apb_slave_mem_wrapper : gc_apb_slave_mem_wrapper
		generic map(
			pindex => gc_apb_slave_mem_wrapper_ID,
			-- paddr  => GC_paddr,
			-- pmask  => GC_pmask,
			pirq  => 0,
            SUM_COMPONENT   => SUM_COMPONENT
		)
		port map(
			rstn        => gc_rstn,     -- same rstn as ahb rstn
			clk         => ahb_clk_in,  -- same clck as ahb clck
			start       => gc_start_mux_out, 
			stop        => gc_stop, 
			--apbi        => apbi_in,
			conf_en     => gc_conf_en,
			rnready     => gc_rnready,
			config_done => gc_config_done,
			gc_done     => gc_done,
			gc_irq      => gc_irq,
			--apbo        => GC_apbo_out,
			dout        => gc_config_dout,
			pdone       => gc_pdone,
			gc_reset    => gc_reset,
            IF_COMP_data => IF_COMP_data,
            GC_IF_data   => COMP_IF_data_copy(gc_apb_slave_mem_wrapper_ID)
		);

    -------------------------------------------------------------------------------
	-------------------------------------------------------------------------------   

	gc_rectangular_top_inst : gc_rectangular_top
		generic map(
			ITERATION_VARIABLE_WIDTH => ITERATION_VARIABLE_WIDTH,
			DIMENSION                => DIMENSION,
			SELECT_WIDTH             => SELECT_WIDTH,
			NO_REG_TO_PROGRAM        => NO_REG_TO_PROGRAM,
			MATRIX_ELEMENT_WIDTH     => MATRIX_ELEMENT_WIDTH,
			DATA_WIDTH               => DATA_WIDTH,
			MAX_NO_OF_PROGRAM_BLOCKS => MAX_NO_OF_PROGRAM_BLOCKS,
			NUM_OF_IC_SIGNALS        => NUM_OF_IC_SIGNALS
		)
		port map(
			-- Inputs
			conf_clk      => ahb_clk_in,
			conf_bus      => gc_config_dout(ITERATION_VARIABLE_WIDTH - 1 downto 0),
			reset         => gc_reset,
			tcpa_clk      => ahb_clk_in     --TCPA_clk,
			stop          => gc_stop,
			start         => gc_start_mux_out,
			global_en     => gc_global_en,
			restart_ext   => gc_restart_ext,
			dclk_in       => ahb_clk_in     --dclk_in,
			pdone         => gc_pdone,
			-- Outputs
			ic            => TCPA_ic_in,
			config_done   => gc_config_done,
			config_busy   => gc_rnready,
			conf_en       => gc_conf_en,
			cready        => gc_cready,
			current_i     => gc_current_i,
			current_j     => gc_current_j,
			current_k     => gc_current_k,
			x_bus         => gc_iteration_vector_current,
			ivar_next_bus => gc_iteration_vector_next,
			reinitialize  => gc_last_iteration,
			gc_done       => gc_done,
			dcm_lock      => dcm_lock,
			gc_clk        => gc_clk
		);

    -------------------------------------------------------------------------------
	------------------------------------------------------------------------------- 
        
	BUFFERS_AND_TCPA_CONNECTION : if CFG_ENABLE_TCPA = 1 generate
			----------
			--Inputs--
			----------              
		BIDING_TCPA_AND_BUFFER_STRUCTURES : for buffer_id in 0 to NUM_OF_BUFFER_STRUCTURES - 1 generate
			
--			CONNECTING_ONE_BUFFER_TO_MULTIPLE_PES : if BUFFERS_TO_MULTIPLE_PES = TRUE generate 
			HORIZONTAL : for i in 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL - 1 generate
					--NUM_OF_BUFFER_STRUCTURES_GREATER_THAN_NORTH_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES > NORTH_PIN_NUM) generate
					--end generate

					--NUM_OF_BUFFER_STRUCTURES_EQUAL_TO_NORTH_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES = NORTH_PIN_NUM) generate
					--end generate

				NUM_OF_BUFFER_STRUCTURES_LESS_THAN_NORTH_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES < NORTH_PIN_NUM) generate
					-- For example: sig_channel_tcpa_output_data_NORTH(511 downto 0) 4 input ports * 32 bits * 4 Buffers and sig_wppa_data_input.EXTERNAL_TOP_north_in(639 downto 0) 5 input ports * 32 bits * 4 PEs
					--From Buffer to TCPA
					sig_wppa_data_input.EXTERNAL_TOP_north_in((((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((NORTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * NORTH_INPUT_WIDTH) -1
									downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((NORTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * NORTH_INPUT_WIDTH))

					<= sig_channel_tcpa_output_data_NORTH( (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id + 1) * AG_BUFFER_NORTH.CONFIG_DATA_WIDTH) -1
                                                                        downto (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id) * AG_BUFFER_NORTH.CONFIG_DATA_WIDTH));
					
					--From TCPA to Buffer
					sig_channel_tcpa_input_data_NORTH( (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id + 1) * AG_BUFFER_NORTH.CONFIG_DATA_WIDTH) -1
                                                                        downto (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id) * AG_BUFFER_NORTH.CONFIG_DATA_WIDTH))
 
					<=sig_wppa_data_output.EXTERNAL_TOP_north_out( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((NORTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * NORTH_INPUT_WIDTH) -1
                                                                        downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((NORTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * NORTH_INPUT_WIDTH));
				end generate;

				NUM_OF_BUFFER_STRUCTURES_LESS_THAN_SOUTH_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES < SOUTH_PIN_NUM) generate
					--From Buffer to TCPA
					sig_wppa_data_input.EXTERNAL_BOTTOM_south_in((((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((SOUTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * SOUTH_INPUT_WIDTH) -1
									downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((SOUTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * SOUTH_INPUT_WIDTH))

					<= sig_channel_tcpa_output_data_SOUTH( (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id + 1) * AG_BUFFER_SOUTH.CONFIG_DATA_WIDTH) -1
                                                                        downto (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id) * AG_BUFFER_SOUTH.CONFIG_DATA_WIDTH));

					--From TCPA to Buffer
					sig_channel_tcpa_input_data_SOUTH( (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id + 1) * AG_BUFFER_SOUTH.CONFIG_DATA_WIDTH) -1
                                                                        downto (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id) * AG_BUFFER_SOUTH.CONFIG_DATA_WIDTH))

					<=sig_wppa_data_output.EXTERNAL_BOTTOM_south_out( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((SOUTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * SOUTH_INPUT_WIDTH) -1
                                                                        downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((SOUTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * SOUTH_INPUT_WIDTH));
				end generate;

			end generate;
		
			VERTICAL_INPUTS : for i in 0 to CUR_DEFAULT_NUM_WPPE_VERTICAL - 1 generate
				NUM_OF_BUFFER_STRUCTURES_LESS_THAN_WEST_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES < WEST_PIN_NUM) generate
					--From Buffer to TCPA
					sig_wppa_data_input.EXTERNAL_LEFT_west_in((((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((WEST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * WEST_INPUT_WIDTH) -1
									downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((WEST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * WEST_INPUT_WIDTH))

					<= sig_channel_tcpa_output_data_WEST( (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id + 1) * AG_BUFFER_WEST.CONFIG_DATA_WIDTH) -1
                                                                        downto (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id) * AG_BUFFER_WEST.CONFIG_DATA_WIDTH));
				
					--From TCPA to Buffer
					sig_channel_tcpa_input_data_WEST( (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id + 1) * AG_BUFFER_WEST.CONFIG_DATA_WIDTH) -1
                                                                        downto (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id) * AG_BUFFER_WEST.CONFIG_DATA_WIDTH))

					<=sig_wppa_data_output.EXTERNAL_LEFT_west_out( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((WEST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * WEST_INPUT_WIDTH) -1
                                                                        downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((WEST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * WEST_INPUT_WIDTH));
				end generate;
				NUM_OF_BUFFER_STRUCTURES_LESS_THAN_EAST_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES < EAST_PIN_NUM) generate
					--From Buffer to TCPA
					sig_wppa_data_input.EXTERNAL_RIGHT_east_in((((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((EAST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * EAST_INPUT_WIDTH) -1
									downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((EAST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * EAST_INPUT_WIDTH))

					<= sig_channel_tcpa_output_data_EAST( (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id + 1) * AG_BUFFER_EAST.CONFIG_DATA_WIDTH) -1
                                                                        downto (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id) * AG_BUFFER_EAST.CONFIG_DATA_WIDTH));
				
					--From TCPA to Buffer
					sig_channel_tcpa_input_data_EAST( (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id + 1) * AG_BUFFER_EAST.CONFIG_DATA_WIDTH) -1
                                                                        downto (((i * NUM_OF_BUFFER_STRUCTURES) + buffer_id) * AG_BUFFER_EAST.CONFIG_DATA_WIDTH))

					<=sig_wppa_data_output.EXTERNAL_RIGHT_east_out( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((EAST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * EAST_INPUT_WIDTH) -1
                                                                        downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((EAST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * EAST_INPUT_WIDTH));
				end generate;
--			end generate;
			end generate;

--			ONE_BUFFER_CONNECTED_TO_INDIVIDUAL_PES
--			HORIZONTAL : for i in 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL - 1 generate
--				--NUM_OF_BUFFER_STRUCTURES_GREATER_THAN_NORTH_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES > NORTH_PIN_NUM) generate
--				--end generate
--
--				--NUM_OF_BUFFER_STRUCTURES_EQUAL_TO_NORTH_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES = NORTH_PIN_NUM) generate
--				--end generate
--
--				NUM_OF_BUFFER_STRUCTURES_LESS_THAN_NORTH_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES < NORTH_PIN_NUM) generate
--					-- For example: sig_channel_tcpa_output_data_NORTH(511 downto 0) 4 input ports * 32 bits * 4 Buffers and sig_wppa_data_input.EXTERNAL_TOP_north_in(639 downto 0) 5 input ports * 32 bits * 4 PEs
--					--From Buffer to TCPA
--					sig_wppa_data_input.EXTERNAL_TOP_north_in((((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((NORTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * NORTH_INPUT_WIDTH) -1
--									downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((NORTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * NORTH_INPUT_WIDTH))
--
--					<= sig_channel_tcpa_output_data_NORTH((((buffer_id * NUM_OF_BUFFER_STRUCTURES + 1) + i) * AG_BUFFER_NORTH.CONFIG_DATA_WIDTH) -1
--                                                                        downto (((buffer_id * NUM_OF_BUFFER_STRUCTURES) + i) * NORTH_INPUT_WIDTH));
--					
--					--From TCPA to Buffer
--					sig_channel_tcpa_input_data_NORTH( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + 1) + i) * AG_BUFFER_NORTH.CONFIG_DATA_WIDTH) -1
--									downto  (((buffer_id * NUM_OF_BUFFER_STRUCTURES) + i) * NORTH_INPUT_WIDTH))
--					<=sig_wppa_data_output.EXTERNAL_TOP_north_out( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((NORTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * NORTH_INPUT_WIDTH) -1
--                                                                        downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((NORTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * NORTH_INPUT_WIDTH));
--				end generate;
--
--				NUM_OF_BUFFER_STRUCTURES_LESS_THAN_SOUTH_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES < SOUTH_PIN_NUM) generate
--					--From Buffer to TCPA
--					sig_wppa_data_input.EXTERNAL_BOTTOM_south_in((((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((SOUTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * SOUTH_INPUT_WIDTH) -1
--									downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((SOUTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * SOUTH_INPUT_WIDTH))
--
--					<= sig_channel_tcpa_output_data_SOUTH((((buffer_id * NUM_OF_BUFFER_STRUCTURES + 1) + i) * AG_BUFFER_SOUTH.CONFIG_DATA_WIDTH) -1
--                                                                        downto (((buffer_id * NUM_OF_BUFFER_STRUCTURES) + i) * SOUTH_INPUT_WIDTH));
--
--					--From TCPA to Buffer
--					sig_channel_tcpa_input_data_SOUTH( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + 1) + i) * AG_BUFFER_SOUTH.CONFIG_DATA_WIDTH) -1
--									downto  (((buffer_id * NUM_OF_BUFFER_STRUCTURES) + i) * SOUTH_INPUT_WIDTH))
--					<=sig_wppa_data_output.EXTERNAL_BOTTOM_south_out( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((SOUTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * SOUTH_INPUT_WIDTH) -1
--                                                                        downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((SOUTH_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * SOUTH_INPUT_WIDTH));
--				end generate;
--
--			end generate;
--		
--			VERTICAL_INPUTS : for i in 0 to CUR_DEFAULT_NUM_WPPE_VERTICAL - 1 generate
--				NUM_OF_BUFFER_STRUCTURES_LESS_THAN_WEST_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES < WEST_PIN_NUM) generate
--					--From Buffer to TCPA
--					sig_wppa_data_input.EXTERNAL_LEFT_west_in((((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((WEST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * WEST_INPUT_WIDTH) -1
--									downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((WEST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * WEST_INPUT_WIDTH))
--
--					<= sig_channel_tcpa_output_data_WEST((((buffer_id * NUM_OF_BUFFER_STRUCTURES + 1) + i) * AG_BUFFER_WEST.CONFIG_DATA_WIDTH) -1
--                                                                        downto (((buffer_id * NUM_OF_BUFFER_STRUCTURES) + i) * WEST_INPUT_WIDTH));
--				
--					--From TCPA to Buffer
--					sig_channel_tcpa_input_data_WEST( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + 1) + i) * AG_BUFFER_WEST.CONFIG_DATA_WIDTH) -1
--									downto  (((buffer_id * NUM_OF_BUFFER_STRUCTURES) + i) * WEST_INPUT_WIDTH))
--					<=sig_wppa_data_output.EXTERNAL_LEFT_west_out( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((WEST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * WEST_INPUT_WIDTH) -1
--                                                                        downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((WEST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * WEST_INPUT_WIDTH));
--				end generate;
--				NUM_OF_BUFFER_STRUCTURES_LESS_THAN_EAST_PIN_NUM : if(NUM_OF_BUFFER_STRUCTURES < EAST_PIN_NUM) generate
--					--From Buffer to TCPA
--					sig_wppa_data_input.EXTERNAL_RIGHT_east_in((((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((EAST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * EAST_INPUT_WIDTH) -1
--									downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((EAST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * EAST_INPUT_WIDTH))
--
--					<= sig_channel_tcpa_output_data_EAST((((buffer_id * NUM_OF_BUFFER_STRUCTURES + 1) + i) * AG_BUFFER_EAST.CONFIG_DATA_WIDTH) -1
--                                                                        downto (((buffer_id * NUM_OF_BUFFER_STRUCTURES) + i) * EAST_INPUT_WIDTH));
--				
--					--From TCPA to Buffer
--					sig_channel_tcpa_input_data_EAST( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + 1) + i) * AG_BUFFER_EAST.CONFIG_DATA_WIDTH) -1
--									downto  (((buffer_id * NUM_OF_BUFFER_STRUCTURES) + i) * EAST_INPUT_WIDTH))
--					<=sig_wppa_data_output.EXTERNAL_RIGHT_east_out( (((buffer_id * NUM_OF_BUFFER_STRUCTURES + ((EAST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id + 1) + i) * EAST_INPUT_WIDTH) -1
--                                                                        downto (((buffer_id *  NUM_OF_BUFFER_STRUCTURES + ((EAST_PIN_NUM - NUM_OF_BUFFER_STRUCTURES)) * buffer_id) + i) * EAST_INPUT_WIDTH));
--				end generate;
--			end generate;
		end generate;

	sync_process : process(ahb_clk_in)
	begin
		if rising_edge(ahb_clk_in) then
			channel_tcpa_input_data_EAST  <= sig_channel_tcpa_input_data_EAST;
			channel_tcpa_input_data_WEST  <= sig_channel_tcpa_input_data_WEST;
			channel_tcpa_input_data_SOUTH <= sig_channel_tcpa_input_data_SOUTH;
			channel_tcpa_input_data_NORTH <= sig_channel_tcpa_input_data_NORTH;
			
			sig_channel_tcpa_output_data_EAST  <= channel_tcpa_output_data_EAST;
			sig_channel_tcpa_output_data_WEST  <= channel_tcpa_output_data_WEST;
			sig_channel_tcpa_output_data_SOUTH <= channel_tcpa_output_data_SOUTH;
			sig_channel_tcpa_output_data_NORTH <= channel_tcpa_output_data_NORTH;
--			cpu_tcpa_buffer_reg <= cpu_tcpa_buffer;

		end if;
	end process;	

	end generate;
	
	BUFFERS_LOOPBACK_CONNECTION : if CFG_ENABLE_TCPA = 0 generate
		loopback : process(ahb_clk_in)
		begin
			if rising_edge(ahb_clk_in) then
				channel_tcpa_input_data_EAST  <= channel_tcpa_output_data_EAST;
				channel_tcpa_input_data_WEST  <= channel_tcpa_output_data_WEST;
				channel_tcpa_input_data_SOUTH <= channel_tcpa_output_data_SOUTH;
				channel_tcpa_input_data_NORTH <= channel_tcpa_output_data_NORTH;

				sig_wppa_bus_output_interface  <= (others => (others => '0'));
				sig_wppa_data_output           <= (others => (others => '0'));
				sig_wppa_ctrl_output           <= (others => (others => '0'));
				sig_configuration_done         <= '1';
				sig_invasion_output            <= (others => '0');
				sig_parasitary_invasion_output <= (others => '0');
			end if;
		end process loopback;
	end generate;

	hw_sw_interface : top_hardware_interface
		generic map(
			pindex => top_hw_interface_ID,        --CM_pindex, --13,
			-- paddr  => CM_paddr,  --16#200#,
			-- pmask  => CM_pmask)  --16#ff0#
            SUM_COMPONENT   => SUM_COMPONENT
            )
		port map(
			rst                          => ahb_rstn_in,
			amba_clk                     => ahb_clk_in,
			--wppa_data_output             => sig_wppa_data_output,
			wppa_memory_input_interface  => sig_wppa_memory_input_interface,
			wppa_memory_output_interface => sig_wppa_memory_output_interface,
			wppa_bus_input_interface     => sig_wppa_bus_input_interface,
			wppa_bus_output_interface    => sig_wppa_bus_output_interface,
			tcpa_config_done             => sig_configuration_done,
			tcpa_config_done_vector      => sig_configuration_done_vector,
			enable_tcpa                  => sig_enable_tcpa,
			icp_program_interface        => sig_icp_program_interface,
			invasion_input               => sig_invasion_input,
			invasion_output              => sig_invasion_output,
			parasitary_invasion_input    => sig_parasitary_invasion_input,
			parasitary_invasion_output   => sig_parasitary_invasion_output,
			tcpa_config_rst              => tcpa_config_rst,
			-- apbi                         => apbi_in,
			-- apbo                         => CM_apbo
            IF_COMP_data                 => IF_COMP_data,
            HW_IF_data                   => COMP_IF_data_copy(top_hw_interface_ID)
            
		);

	reconfig_regs : reconfig_registers
		generic map(
			pindex => reconfig_registers_ID,     --RR_pindex, --12
			-- paddr  => RR_paddr,  --16#100#,
			-- pmask  => RR_pmask)  --16#ff0#
            SUM_COMPONENT   => SUM_COMPONENT
            )
		port map(
			rst                      => ahb_rstn_in,
			gc_reset                 => gc_reset,
			clk                      => ahb_clk_in,
			ctrl_programmable_depth  => sig_ctrl_programmable_depth,
			en_programmable_fd_depth => sig_en_programmable_fd_depth,
			programmable_fd_depth    => sig_programmable_fd_depth,
			ic                       => sig_wppa_ctrl_input.external_top_north_in_ctrl(0),
			gc_current_i             => gc_current_i, 
			gc_current_j             => gc_current_j,
			gc_current_k             => gc_current_k,
			AG_out_addr_i_NORTH      => sig_AG_out_addr_i_NORTH,
			AG_out_addr_i_WEST       => sig_AG_out_addr_i_WEST,
			AG_out_addr_i_SOUTH      => sig_AG_out_addr_i_SOUTH,
			AG_out_addr_i_EAST       => sig_AG_out_addr_i_EAST,
                        AG_config_done_NORTH     => AG_config_done_NORTH,
                        AG_config_done_WEST      => AG_config_done_WEST,
                        AG_config_done_SOUTH     => AG_config_done_SOUTH,
                        AG_config_done_EAST      => AG_config_done_EAST,
                        gc_config_done           => gc_config_done,
                        tcpa_config_done         => sig_configuration_done,
			tcpa_pc_debug_in	 => sig_pc_debug_in,	
			tcpa_clk_en              => sig_tcpa_clk_en,
			tcpa_start               => sig_tcpa_start,
			tcpa_stop                => sig_tcpa_stop,
			fault_injection          => sig_fault_injection, 
			-- apbi                     => apbi_in,
			-- apbo                     => reconfig_regs_apbo
            IF_COMP_data                 => IF_COMP_data,
            RR_IF_data                   => COMP_IF_data_copy(reconfig_registers_ID)
            
		);


	en_fault_injection : if FAULT_INJECTION_MODULE_EN = TRUE generate
        faultTOP_IF_apbo_valid <= '1';
		entity_fault_injection_top : fault_injection_top
			generic map(
				MEM_SIZE          => 128,
				DATA_WIDTH        => 32,
				ADDR_WIDTH        => 7,
				NUM_OF_IC_SIGNALS => NUM_OF_IC_SIGNALS,
				pindex            => fault_injection_top_ID, --FI_pindex,
				pirq              => FI_pirq,
				-- paddr             => FI_paddr,
				-- pmask             => FI_pmask
                SUM_COMPONENT     => SUM_COMPONENT
                )
			port map(
				rstn            => ahb_rstn_in, --tcpa_rst, 
				clk             => ahb_clk_in       --TCPA_clk,
				tcpa_start      => sig_tcpa_start,
				tcpa_stop	    => sig_tcpa_stop,
				fault_injection => sig_fault_injection, 
				error_status    => sig_error_status, 
				-- apbi            => apbi_in, 
				-- apbo            => FI_apbo
                IF_COMP_data    => IF_COMP_data,
                FI_IF_data      => COMP_IF_data_copy(fault_injection_top_ID)
                
                );
	end generate;
	no_fault_injection_module : if FAULT_INJECTION_MODULE_EN = FALSE generate
        faultTOP_IF_apbo_valid <= '0';      --	FI_apbo <= apb_none;
	end generate;

	debug_tcpa_0 : if CFG_ENABLE_TCPA = 1 generate
		inst_tcpa_top : WPPA_TOP
			port map(
				clk                          => ahb_clk_in      --TCPA_clk,
				rst                          => tcpa_rst,
				wppa_bus_input_interface     => sig_wppa_bus_input_interface,
				wppa_bus_output_interface    => sig_wppa_bus_output_interface,
				wppa_data_input              => sig_wppa_data_input,
				wppa_data_output             => sig_wppa_data_output,
				wppa_ctrl_input              => sig_wppa_ctrl_input,
				wppa_ctrl_output             => sig_wppa_ctrl_output,
				wppa_memory_input_interface  => sig_wppa_memory_input_interface,
				wppa_memory_output_interface => sig_wppa_memory_output_interface,
				fault_injection              => sig_fault_injection,
				error_status                 => sig_error_status,
				tcpa_config_done             => sig_configuration_done,
				tcpa_config_done_vector      => sig_configuration_done_vector,
				ctrl_programmable_depth      => sig_ctrl_programmable_depth,
				en_programmable_fd_depth     => sig_en_programmable_fd_depth,
				programmable_fd_depth        => sig_programmable_fd_depth,
				enable_tcpa                  => sig_enable_tcpa_i,
				pc_debug_out                 => sig_pc_debug_out,
				icp_program_interface        => sig_icp_program_interface,
				invasion_input               => sig_invasion_input,
				invasion_output              => sig_invasion_output,
				parasitary_invasion_input    => sig_parasitary_invasion_input,
				parasitary_invasion_output   => sig_parasitary_invasion_output
			);
	end generate;

	REVERSE_INDEX_VECTOR : for i in 0 to DIMENSION - 1 generate
		AG_index_vector(ITERATION_VARIABLE_WIDTH + (i * INDEX_VECTOR_DATA_WIDTH) - 1 downto i * INDEX_VECTOR_DATA_WIDTH) <= gc_iteration_vector_current(i * ITERATION_VARIABLE_WIDTH to (i + 1) * ITERATION_VARIABLE_WIDTH - 1);
		AG_index_vector((i + 1) * INDEX_VECTOR_DATA_WIDTH - 1)                                                           <= '0';
	end generate REVERSE_INDEX_VECTOR;

	--	chipscope_debug_0 : if ENABLE_CHIPSCOPE = 1 generate
	--		--Chipscope trigers
	--		--chipscope_trigers(0)            <= buffer_rst;
	--		chipscope_trigers(1)            <= tcpa_rst;
	--		chipscope_trigers(2)            <= AG_config_done_NORTH;
	--		chipscope_trigers(3)            <= AG_config_done_SOUTH;
	--		chipscope_trigers(4)            <= AG_config_done_EAST;
	--		chipscope_trigers(5)            <= AG_config_done_WEST;
	--		chipscope_trigers(6)            <= tcpa_config_done_computed_i;
	--		chipscope_trigers(7)            <= gc_config_done;
	--		chipscope_trigers(8)            <= gc_cready;
	--		chipscope_trigers(13 downto 9)  <= north_ag_irq_i;
	--		chipscope_trigers(18 downto 14) <= west_ag_irq_i;
	--		chipscope_trigers(23 downto 19) <= south_ag_irq_i;
	--		chipscope_trigers(28 downto 24) <= east_ag_irq_i;
	--		chipscope_trigers(29)           <= tcpa_start;
	--		chipscope_trigers(30)           <= tcpa_stop;
	--		chipscope_trigers(31)           <= gc_start;
	--		chipscope_trigers(32)           <= gc_stop;
	--		chipscope_trigers(33)           <= AG_start;
	--
	--		chipscope_data(26 downto 0)   <= AG_index_vector;
	--		chipscope_data(44 downto 27)  <= AG_out_addr_i_NORTH;
	--		chipscope_data(45)            <= AG_out_en_i_NORTH;
	--		chipscope_data(63 downto 46)  <= AG_out_addr_i_WEST;
	--		chipscope_data(64)            <= AG_out_en_i_WEST;
	--		chipscope_data(82 downto 65)  <= AG_out_addr_i_SOUTH;
	--		chipscope_data(83)            <= AG_out_en_i_SOUTH;
	--		chipscope_data(101 downto 84) <= AG_out_addr_i_EAST;
	--		chipscope_data(102)           <= AG_out_en_i_EAST;
	--
	--		chipscope_data(230 downto 103) <= channel_tcpa_output_data_NORTH;
	--		chipscope_data(358 downto 231) <= channel_tcpa_output_data_WEST;
	--		chipscope_data(486 downto 359) <= channel_tcpa_output_data_SOUTH;
	--		chipscope_data(614 downto 487) <= channel_tcpa_output_data_EAST;
	--
	--		--chipscope_data(615)            <= buffer_rst;
	--		chipscope_data(616)            <= tcpa_rst;
	--		chipscope_data(617)            <= AG_config_done_NORTH;
	--		chipscope_data(618)            <= AG_config_done_SOUTH;
	--		chipscope_data(619)            <= AG_config_done_EAST;
	--		chipscope_data(620)            <= AG_config_done_WEST;
	--		chipscope_data(621)            <= tcpa_config_done_computed_i;
	--		chipscope_data(623)            <= gc_config_done;
	--		chipscope_data(624)            <= gc_cready;
	--		chipscope_data(629 downto 625) <= north_ag_irq_i;
	--		chipscope_data(634 downto 630) <= west_ag_irq_i;
	--		chipscope_data(639 downto 635) <= south_ag_irq_i;
	--		chipscope_data(644 downto 640) <= east_ag_irq_i;
	--		chipscope_data(645)            <= tcpa_start;
	--		chipscope_data(646)            <= tcpa_stop;
	--		chipscope_data(647)            <= gc_start;
	--		chipscope_data(648)            <= gc_stop;
	--		chipscope_data(649)            <= AG_start;
	--		chipscope_data(657 downto 650) <= gc_iteration_vector_current(0 to 7);
	--		chipscope_data(665 downto 658) <= gc_iteration_vector_current(8 to 15);
	--		chipscope_data(673 downto 666) <= gc_iteration_vector_current(16 to 23);
	--		chipscope_data(674)            <= TCPA_ic(0);
	--
	--		debug_tcpa_1 : if CFG_ENABLE_TCPA = 1 generate
	--			-- Monitoring the 16 PCs
	--			chipscope_data(681 downto 675) <= sig_pc_debug_out(1, 1); --PE(0,0);
	--			chipscope_data(688 downto 682) <= sig_pc_debug_out(1, 2); --PE(0,1);
	--			chipscope_data(695 downto 689) <= sig_pc_debug_out(1, 3); --PE(0,2);
	--			--chipscope_data(700 downto 694) <= sig_pc_debug_out(1, 4); --PE(0,3);
	--	
	--			chipscope_data(705 downto 700) <= sig_pc_debug_out(2, 1); --PE(1,0);
	--			chipscope_data(711 downto 706) <= sig_pc_debug_out(2, 2); --PE(1,1);
	--			chipscope_data(717 downto 712) <= sig_pc_debug_out(2, 3); --PE(1,2);
	--			chipscope_data(723 downto 718) <= sig_pc_debug_out(2, 4); --PE(1,3);
	--	
	--			chipscope_data(729 downto 724) <= sig_pc_debug_out(3, 1); --PE(2,0);
	--			chipscope_data(735 downto 730) <= sig_pc_debug_out(3, 2); --PE(2,1);
	--			chipscope_data(740 downto 735) <= sig_pc_debug_out(3, 3); --PE(2,2);
	--			chipscope_data(746 downto 741) <= sig_pc_debug_out(3, 4); --PE(2,3);
	--	
	--			chipscope_data(752 downto 747) <= sig_pc_debug_out(4, 1); --PE(3,0);
	--			chipscope_data(758 downto 753) <= sig_pc_debug_out(4, 2); --PE(3,1);
	--			chipscope_data(764 downto 759) <= sig_pc_debug_out(4, 3); --PE(3,2);
	--			chipscope_data(770 downto 765) <= sig_pc_debug_out(4, 4); --PE(3,3);
	--	
	--			chipscope_data(785)            <= sig_configuration_done;
	--			chipscope_data(787)            <= sig_en_programmable_fd_depth(1, 1)(0);
	--			chipscope_data(788)            <= sig_en_programmable_fd_depth(1, 1)(1);
	--			chipscope_data(789)            <= sig_en_programmable_fd_depth(1, 1)(2);
	--			chipscope_data(805 downto 790) <= sig_programmable_fd_depth(1, 1)(0);
	--			chipscope_data(821 downto 806) <= sig_programmable_fd_depth(1, 1)(1);
	--			chipscope_data(837 downto 822) <= sig_programmable_fd_depth(1, 1)(2);
	--		end generate;
	--		--sync_out_signals 
	--		--gc_start_mux_select <= vio_sync_out(0);
	--		--gc_start_input      <= vio_sync_out(1);
	--     		 vio_control1 <= (others=>'0');
	--
	--
	--		chipscope_icon_inst : chipscope_icon_kc705 
	--			port map(CONTROL0 => icon_control0, CONTROL1 => vio_control1);
	--
	--		chipscope_ila_inst : chipscope_ila_kc705
	--			port map(
	--				CONTROL => icon_control0,
	--				CLK     => ahb_clk_in,
	--				DATA    => chipscope_data,
	--				TRIG0   => chipscope_trigers
	--			);
	--
	--		chipscope_vio_inst : chipscope_vio_kc705_v2
	--			port map(
	--				CONTROL   => vio_control1,
	--				CLK       => ahb_clk_in,
	--				--ASYNC_IN  => vio_async_in,
	--				--ASYNC_OUT => vio_async_out,
	--				--SYNC_IN   => vio_sync_in
	--				SYNC_OUT  => vio_sync_out
	--			);
	--	end generate;

end behavior;




