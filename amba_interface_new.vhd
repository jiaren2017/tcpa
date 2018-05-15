library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.amba.all;
use grlib.devices.all;

library gaisler;
use gaisler.misc.all;


--  library from TCPA_TOP_new  --------------------------
library UNISIM;
use UNISIM.VComponents.all;

library techmap;
use techmap.gencomp.all;

use work.AG_BUFFER_type_lib.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;
sim:/testbench/d3/u0/leon3x0/vhdl/cmem0/ime/im0(0)/itags0/xc2v/x0/a9/x(0)/r/R1/TDP/RAMB36E1_TDP_inst/prcs_clk
use wppa_instance_v1_01_a.WPPE_LIB.all;
use wppa_instance_v1_01_a.DEFAULT_LIB.all;
use wppa_instance_v1_01_a.ARRAY_LIB.all;
use wppa_instance_v1_01_a.TYPE_LIB.all;
use wppa_instance_v1_01_a.INVASIC_LIB.all;

--------------------------------------------------------

entity amba_interface is
	generic(
        hindex : integer := 7;
        haddr  : integer := 16#300#;
        hmask  : integer := 16#FC0#;
        hirq   : integer := 0;

	componentCount : positive := 9,
	masks : array (0 to componentCount - 1) of std_logic_vector(31 downto 0),
        
    
        COMP_NUM_POWER  : integer := 4;         -- 2^4 == 16 components
        COMP_SIZE       : integer := 22;        -- 2^22 == 4 MByte

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

	RBUFFER_HIRQ_AHB_INDEX                : integer;
	RBUFFER_HIRQ_AHB_ADDR                 : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_ADDR;sim:/testbench/d3/u0/leon3x0/vhdl/cmem0/ime/im0(0)/itags0/xc2v/x0/a9/x(0)/r/R1/TDP/RAMB36E1_TDP_inst/prcs_clk
	RBUFFER_HIRQ_AHB_MASK                 : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_MASK;
	RBUFFER_HIRQ_AHB_IRQ                  : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_IRQ;

	INDEX_VECTOR_DIMENSION                : integer range 0 to 32 := 3;
	INDEX_VECTOR_DATA_WIDTH               : integer range 0 to 32 := 17;-- 9;
	MATRIX_PIPELINE_DEPTH                 : integer range 0 to 32 := 2; -- equals log2(INDEX_VECTOR_DIMENSION) + 1

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
        -- Input Signals from Bus-System to AMBA Interface
        ahb_clk         : in  std_ulogic;sim:/testbench/d3/u0/leon3x0/vhdl/cmem0/ime/im0(0)/itags0/xc2v/x0/a9/x(0)/r/R1/TDP/RAMB36E1_TDP_inst/prcs_clk
        ahb_rstn        : in  std_ulogic;
        ahbsi           : in  ahb_slv_in_type;
        -- Output signals from component to amba_bus
        ahbso           : out ahb_slv_out_type

	tcpaBus_in : in array(0 to componentCount - 1) of tcpaBus_in_interface,
	tcpaBus_out : out array(0 to component Count - 1) of tcpaBus_out_interface
        );
end entity amba_interface;

architecture Behavioral of amba_interface is

    
------------------------------------------------------------------------------------------------------------------
----------------------------------  from TCPA_TOP_new  -------------------------------------------
	--attribute syn_noclockbuf of Behavioral : architecture is true;
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

    
    
----------------------------------    Components  Declaration ---------------------------------
------------------------------------------------------------------------------------------------------------------
--  This is a hierarchical interrupt request module for the reconfigurable buffer strcuture
	component RBuffer_hirq is
        generic (
            NUM_OF_BUFFER_STRUCTURES : integer := 4;
            CHANNEL_COUNT_NORTH      : integer := 4;
            CHANNEL_COUNT_WEST       : integer := 4;
            CHANNEL_COUNT_SOUTH      : integer := 4;
            CHANNEL_COUNT_EAST       : integer := 4;
            COMPONENT_ADDRESS        : std_logic_vector(31 downto 0);
            hindex                   : integer := 0;
            -- haddr                    : integer := 0;
            -- hmask                    : integer := 16#FFF#;
            hirq                     : integer := 0
        );
        port (
            rstn                 : in  std_ulogic;
            clk                  : in  std_ulogic;
            irq_clear            : out std_logic_vector(3 downto 0);

            north_buffers_irq    : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_NORTH - 1 downto 0) := (others => '0');
            west_buffers_irq     : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1 downto 0)  := (others => '0');
            south_buffers_irq    : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_SOUTH - 1 downto 0) := (others => '0');
            east_buffers_irq     : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_EAST - 1 downto 0)  := (others => '0');

            -- Input Signals from AMBA Interface    -- ahbsi  : in  ahb_slv_in_type;
            IF_RBuff_hirq_hready : in std_ulogic; 
            IF_RBuff_hirq_hsel   : in std_ulogic;  -- slave select
            IF_RBuff_hirq_haddr  : in std_logic_vector(31 downto 0); -- address bus (byte)
            IF_RBuff_hirq_hwrite : in std_ulogic; -- read/write
            IF_RBuff_hirq_htrans : in std_logic_vector(1 downto 0); -- transfer type
            IF_RBuff_hirq_hwdata : in std_logic_vector(31 downto 0); -- write data bus
            
            -- Output Signals to AMBA Interface		-- ahbso  : out ahb_slv_out_type
            RBuff_hirq_IF_hready : out std_ulogic; -- transfer done
            RBuff_hirq_IF_hresp  : out std_logic_vector(1 downto 0); -- response type
            RBuff_hirq_IF_hrdata : out std_logic_vector(31 downto 0); -- read data bus
            RBuff_hirq_IF_hsplit : out std_logic_vector(15 downto 0); -- split completion
            RBuff_hirq_IF_hirq   : out std_ulogic; -- interrupt bus
            RBuff_hirq_IF_hindex : out integer    -- diagnostic use only
    --        RBuff_hirq_IF_hconfig : out ahb_config_type; -- memory access reg.registers
		);
    end component RBuffer_hirq;
    
    
------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------           AHB_AG_Buffer_Wrapper
	component AHB_AG_Buffer_Wrapper is
		generic(
            DESIGN_TYPE                           : integer range 0 to 7  := 1;
            ENABLE_PIXEL_BUFFER_MODE              : integer range 0 to 31 := 1;

            CONFIG_DATA_WIDTH                     : integer range 0 to 32 := 32;
            CONFIG_ADDR_WIDTH                     : integer range 0 to 32 := 10;

            INDEX_VECTOR_DIMENSION                : integer range 0 to 32 := 3;
            INDEX_VECTOR_DATA_WIDTH               : integer range 0 to 32 := 9;
            MATRIX_PIPELINE_DEPTH                 : integer range 0 to 32 := 2; -- equals log2(INDEX_VECTOR_DIMENSION) + 1

            CHANNEL_DATA_WIDTH                    : integer range 0 to 32 := 32;
            CHANNEL_ADDR_WIDTH                    : integer range 0 to 64 := 18; -- 2 * INDEX_VECTOR_DATA_WIDTH;
            CHANNEL_COUNT                         : integer range 0 to 32 := 4;

            AG_CONFIG_ADDR_WIDTH                  : integer range 0 to 32 := 6; -- must be computed
            AG_CONFIG_DATA_WIDTH                  : integer range 0 to 32 := 9; -- must be equal to the INDEX_VECTOR_DATA_WIDTH
            AG_BUFFER_CONFIG_SIZE                 : integer               := 1024; 

            NUM_OF_BUFFER_STRUCTURES              : positive range 1 to 8 := 4;
            BUFFER_CONFIG_ADDR_WIDTH              : integer range 0 to 32 := 4; -- must be computed
            BUFFER_CONFIG_DATA_WIDTH              : integer range 0 to 32 := 32; -- must be allways set to 32
            BUFFER_ADDR_HEADER_WIDTH              : integer range 0 to 54 := 8; -- = 2 * INDEX_VECTOR_DATA_WIDTH - 10; -- Sice we are using 32x1kbits RAMs
            BUFFER_SEL_REG_WIDTH                  : integer range 0 to 8  := 4; -- = log2(ADDR_HEADER_WIDTH)
            BUFFER_CSR_DELAY_SELECTOR_WIDTH       : integer range 0 to 32 := 6; -- We fixed the delay selector to max 2**6 -1 depth
            BUFFER_SIZE                           : integer               := 4096;
            BUFFER_SIZE_ADDR_WIDTH                : integer               := 12;
            BUFFER_CHANNEL_SIZE                   : integer               := 1024;
            BUFFER_CHANNEL_ADDR_WIDTH             : integer               := 10;
            BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := TRUE;        --tcpa component
        AG_Buffer_Wrapper_EAST      : std_logic_vector(31 downto 0) := x"00000000";
        AG_Buffer_Wrapper_WEST      : std_logic_vector(31 downto 0) := x"00400000";
        AG_Buffer_Wrapper_SOUTH     : std_logic_vector(31 downto 0) := x"00800000";
        AG_Buffer_Wrapper_NORTH     : std_logic_vector(31 downto 0) := x"00C00000";
        RBuffer_hirq_addr           : std_logic_vector(31 downto 0) := x"01000000";
        top_hardware_interface_addr : std_logic_vector(31 downto 0) := x"01400000";
        reconfig_registers_addr     : std_logic_vector(31 downto 0) := x"01800000";
        gc_apb_slave_mem_wrapper_addr : std_logic_vector(31 downto 0) := x"01C00000";
        fault_injection_top_addr    : std_logic_vector(31 downto 0) := x"02000000";
    
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

            EN_ELASTIC_BUFFER                     : boolean               := FALSE;
            
            COMPONENT_ADDRESS                     : std_logic_vector(31 downto 0);
            hindex                                : integer;               
            hirq                                  : integer               := 0
            -- haddr                                 : integer               := 0;
            -- hmask                                 : integer               := 16#fff#;
                    
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

            ----------------------------------------------------------------------------------------------
            ahb_clk                  : in  std_logic;
			ahb_rstn                 : in  std_logic;
            
            -- Input Signals from AMBA Interface to AHB_AG_Buffer_Wrapper        --ahbsi : in  ahb_slv_in_type;
            IF_AG_hsel                  : in std_logic_vector(0 to 3);          -- slave select
            IF_AG_haddr                 : in std_logic_vector(31 downto 0);    -- address bus (byte)
            IF_AG_hwrite                : in std_ulogic;                       -- read/write
            IF_AG_htrans                : in std_logic_vector(1 downto 0);     -- transfer type
            IF_AG_hwdata                : in std_logic_vector(31 downto 0);    -- write data bus
            IF_AG_hready                : in std_ulogic;                       -- transfer doneregisters
            
            -- Output Signals from AHB_AG_Buffer_Wrapper to AMBA Interface       --ahbso : out ahb_slv_out_type
            AG_IF_hready                : out std_ulogic;                        -- transfer done
            AG_IF_hresp                 : out std_logic_vector(1 downto 0);      -- response type
            AG_IF_hrdata                : out std_logic_vector(31 downto 0);     -- read data bus
            AG_IF_hsplit                : out std_logic_vector(15 downto 0);     -- split completion
            AG_IF_hirq                  : out std_ulogic;                        -- interrupt bus
            AG_IF_hindex                : out integer               -- diagnostic use only   
            -- AG_IF_hconfig               : out ahb_config_type;                   -- memory access reg.

		);
	end component AHB_AG_Buffer_Wrapper;
        
     
	-------------------------------------------------------------------------------------
	-- Global controller - Configuration Memory
	-------------------------------------------------------------------------------------
	component gc_apb_slave_mem_wrapper
		generic(
            COMPONENT_ADDRESS  : std_logic_vector(31 downto 0);to 0) := x"000000
			pindex      : integer;
			-- paddr       : integer := 0;
			-- pmask       : integer := 16#ff0#;
            pirq        : integer := 0;
			NO_OF_WORDS : integer := 1024
		);
		port(
			rstn        : in  std_ulogic;
			clk         : in  std_ulogic;
			start       : in  std_logic;
			stop        : in  std_logic;
            
			--          Input Signals from AMBA Interface               --  apbi : in apb_slv_in_type;
            IF_gc_psel                   : in std_ulogic;  -- slave select
            IF_gc_penable                : in std_ulogic;                                       -- enable,  strobe
            IF_gc_paddr                  : in std_logic_vector(31 downto 0);                    -- address bus (byte)
            IF_gc_pwrite                 : in std_ulogic;                                       -- write
            IF_gc_pwdata                 : in std_logic_vector(31 downto 0);                    -- write data bus
            
            --          Output Signals to AMBA Interface                -- apbo : out apb_slv_out_type;
            gc_IF_pirq                   : out std_ulogic;         
            gc_IF_pindex                 : out integer;
            gc_IF_prdata                 : out std_logic_vector(31 downto 0);
            -- gc_IF_PCONFIG                : out apb_config_type 
            
            
			conf_en     : in  std_logic;
			rnready     : in  std_logic;
			config_done : in  std_logic;
			gc_done     : in  std_logic;
			gc_irq      : out std_logic;

			dout        : out std_logic_vector(31 downto 0);
			pdone       : out std_logic;
			gc_reset    : out std_logic
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
   
        88
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
			conf_en       : out std_logic;registers
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
			pindex : integer;
			-- paddr  : integer := 13;
			-- pmask  : integer := 16#fff#;
            COMPONENT_ADDRESS   : std_logic_vector(31 downto 0));
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
            
            -- Input Signals from AMBA Interface            -- apbi  : in  apb_slv_in_type;
            IF_HwInterFace_psel          : in std_ulogic;  -- slave select
            IF_HwInterFace_penable       : in std_ulogic;                                       -- enable,  strobe
            IF_HwInterFace_paddr         : in std_logic_vector(31 downto 0);                    -- address bus (byte)
            IF_HwInterFace_pwrite        : in std_uvlilogic;                                       -- write
            IF_HwInterFace_pwdata        : in std_logic_vector(31 downto 0);                    -- write data bus
            
            -- Output Signals to AMBA Interface             -- apbo  : out apb_slv_out_type
            HwInterFace_IF_pirq          : out std_ulogic;         
            HwInterFace_IF_pindex        : out integer;
            HwInterFace_IF_prdata        : out std_logic_vector(31 downto 0)
            -- HwInterFace_IF_PCONFIG       : out apb_config_type
            );
	end component;   
        
        
------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------                           WPPA_TOP
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
			icp_program_interface        : in  t_prog_intfc
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
	                pirq              : integer := 15;registers
	                -- paddr             : integer := 15;
	                -- pmask             : integer := 16#fff#;
                    COMPONENT_ADDRESS  : std_logic_vector(31 downto 0)
                    );
	        port (
	                rstn            : in std_ulogic;
	                clk             : in std_ulogic;
                    tcpa_start      : in std_logic;
                    tcpa_stop       : in std_logic;
	                fault_injection : out t_fault_injection_module;
                    error_status    : in t_error_status;
                    
                    -- Input Signals from AMBA Interface to fault_injection_top             --apbi : in apb_slv_in_type;
                    IF_faultTOP_psel                   : in std_logic_vector(0 to NUM_APB_SLV-1);         -- select   
                    IF_faultTOP_penable                : in std_ulogic;                                       -- enable,  strobe
                    IF_faultTOP_paddr                  : in std_logic_vector(31 downto 0);                    -- address bus (byte)
                    IF_faultTOP_pwrite                 : in std_ulogic;                                       -- write
                    IF_faultTOP_pwdata                 : in std_logic_vector(31 downto 0);                    -- write data bus
                    
                    -- Output Signals from fault_injection_top to AMBA Interface            --apbo : out apb_slv_out_type
                    faultTOP_IF_pirq                   : out std_ulogic;         
                    faultTOP_IF_pindex                 : out integer;
                    faultTOP_IF_prdata                 : out std_logic_vector(31 downto 0)
                    --faultTOP_IF_PCONFIG                : out apb_config_type
                    );
	end component;
    
------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------                       reconfig_registers   
 
	component reconfig_registers is
		generic(
			pindex : integer;
			-- paddr  : integer := 12;
			-- pmask  : integer := 16#fff#;
            COMPONENT_ADDRESS  : std_logic_vector(31 downto 0)
            );
		port(
			rst                      : in  std_ulogic;
			gc_reset                 : in  std_ulogic;
			clk                      : in  std_ulogic;
			ctrl_programmable_depth  : out t_ctrl_programmable_depth;
			en_programmable_fd_depth : out t_en_programmable_fd_depth;
			programmable_fd_depth    : out t_programmable_fd_depth;
			ic 			             : in std_logic;
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
            
            -- Input Signals from AMBA Interface            -- apbi : in  apb_slv_in_type;
            IF_ReconfReg_psel        : in std_ulogic;  -- slave select
            IF_ReconfReg_penable     : in std_ulogic;                                       -- enable,  strobe
            IF_ReconfReg_paddr       : in std_logic_vector(31 downto 0);                    -- address bus (byte)
            IF_ReconfReg_pwrite      : in std_ulogic;                                       -- write
            IF_ReconfReg_pwdata      : in std_logic_vector(31 downto 0);                    -- write data bus
            
            -- Output Signals to AMBA Interface             -- apbo : out apb_slv_out_type
            ReconfReg_IF_pirq        : out std_ulogic;         
            ReconfReg_IF_pindex      : out integer;                -- diag use only
            ReconfReg_IF_prdata      : out std_logic_vector(31 downto 0)
            -- ReconfReg_IF_PCONFIG     : out apb_config_type
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
    
--------------------------------------------------------------------------------------------
----------------------------------------------- End Components -----------------------------
        
        
	---------------------------------- Attributes -----------------------------
	--attribute syn_black_box : boolean;
	--attribute syn_black_box of chipscope_icon_kc705 : component is TRUE;
	--attribute syn_black_box of chipscope_ila_kc705 : component is TRUE;
	--attribute syn_black_box of chipscope_vio_kc705 : component is TRUE;registers

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
--	signal sig_fault_injection     : t_fault_injection_module; 
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
	signal east_buffers_event_i : std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);registers


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
	-- signal sig_invasion_input                : t_inv_sig                    := (others => '0');
	-- signal sig_invasion_output               : t_inv_sig                    := (others => '0');
	-- signal sig_parasitary_invasion_input     : t_inv_sig                    := (others => '0');
	-- signal sig_parasitary_invasion_output    : t_inv_sig                    := (others => '0');
	-- signal sig_enable_tcpa, sig_enable_tcpa_i: std_logic;
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
    -- amba_interface   
	constant AMBA_IF_CONFIG : ahb_config_type := (
		0      => ahb_device_reg(VENDOR_CONTRIB, CONTRIB_CORE1, 0, 0, 0),
		4      => ahb_membar(haddr, '0', '0', hmask),
		others => zero32);
        
    type component_addr_type is array (0 to 2**COMP_NUM_POWER-1) of std_logic_vector(31 downto 0);   
    signal component_addr_array : component_addr_type := (others => (others => '0'));
    
    signal mask_intern      : std_logic_vector(31 downto 0) := to_stdlogicvector(to_bitvector((x"FFFFFFFF")) srl (32-COMP_NUM_POWER-COMP_SIZE));        -- 0x03FFFFFF
    signal component_size   : integer := 2**COMP_SIZE;

    signal addr_mask        : std_logic_vector(31 downto 0);
    signal addr_srl         : std_logic_vector(31 downto 0);
    signal addr_array_index : integer range 0 to 2**COMP_NUM_POWER-1;
    signal IF_component_addr     : std_logic_vector(31 downto 0);
        
--------------------------------------------------------------------------------------------
------------------------              signal between amba_interface and tcpa components
    
    ---------------------    reconfig_registers    -------------------------
        -- Input Signals from AMBA Interface to reconfig_registers
    signal    IF_ReconfReg_psel        :  std_ulogic;  -- slave select
    signal    IF_ReconfReg_penable     :  std_ulogic;                                       -- enable,  stroberegisters
    signal    IF_ReconfReg_paddr       :  std_logic_vector(31 downto 0);                    -- address bus (byte)
    signal    IF_ReconfReg_pwrite      :  std_ulogic;                                       -- write
    signal    IF_ReconfReg_pwdata      :  std_logic_vector(31 downto 0);                    -- write data bus

        
        -- Output Signals from reconfig_registers to AMBA Interface
    signal    ReconfReg_IF_pirq        :  std_ulogic;                                        -- interrupt bus
    signal    ReconfReg_IF_prdata      :  std_logic_vector(31 downto 0);                     -- read data bus
    signal    ReconfReg_IF_pindex      :  integer range 0 to 2**COMP_NUM_POWER -1;           -- diagnostic use only
    
        ------------------------------------------------------------------------
        ---------------------  top_hardware_interface  ------------------------- 
        -- Input Signals from AMBA Interface to top_hardware_interface
    signal    IF_HwInterFace_psel          :  std_ulogic;  -- slave select
    signal    IF_HwInterFace_penable       :  std_ulogic;                                       -- enable,  strobe
    signal    IF_HwInterFace_paddr         :  std_logic_vector(31 downto 0);                    -- address bus (byte)
    signal    IF_HwInterFace_pwrite        :  std_ulogic;                                       -- write
    signal    IF_HwInterFace_pwdata        :  std_logic_vector(31 downto 0);                    -- write data bus
        
        -- Output Signals from top_hardware_interface to AMBA Interface
    signal    HwInterFace_IF_pirq          :  std_ulogic;         
    signal    HwInterFace_IF_prdata        :  std_logic_vector(31 downto 0);
    signal    HwInterFace_IF_pindex        :  integer range 0 to 2**COMP_NUM_POWER -1;          -- diagnostic use only
    
        --------------------------------------------------------------------------
        ---------------------  gc_apb_slave_mem_wrapper  ------------------------- 
        -- Input Signals from AMBA Interface to gc_apb_slave_mem_wrapper
    signal    IF_gc_psel                   :  std_ulogic;  -- slave select
    signal    IF_gc_penable                :  std_ulogic;                                       -- enable,  strobe
    signal    IF_gc_paddr                  :  std_logic_vector(31 downto 0);                    -- address bus (byte)
    signal    IF_gc_pwrite                 :  std_ulogic;                                       -- write
    signal    IF_gc_pwdata                 :  std_logic_vector(31 downto 0);                    -- write data bus
        
        -- Output Signals from gc_apb_slave_mem_wrapper to AMBA Interface
    signal    gc_IF_pirq                   :  std_ulogic;         
    signal    gc_IF_prdata                 :  std_logic_vector(31 downto 0);
    signal    gc_IF_pindex                 :  integer range 0 to 2**COMP_NUM_POWER -1;  -- diagnostic use only
    
        --------------------------------------------------------------------------
        ---------------------         RBuffer_hirq       -------------------------
        -- Input Signals from AMBA Interface to RBuffer_hirq
    signal    IF_RBuff_hirq_hready        :  std_ulogic; 
    signal    IF_RBuff_hirq_hsel          :  std_ulogic;  -- slave select
    signal    IF_RBuff_hirq_haddr         :  std_logic_vector(31 downto 0); -- address bus (byte)
    signal    IF_RBuff_hirq_hwrite        :  std_ulogic; -- read/write
    signal    IF_RBuff_hirq_htrans        :  std_logic_vector(1 downto 0); -- transfer type
    signal    IF_RBuff_hirq_hwdata        :  std_logic_vector(31 downto 0); -- write data bus

        
        -- Output Signals from RBuffer_hirq to AMBA Interface
    signal    RBuff_hirq_IF_hready        :  std_ulogic; -- transfer done
    signal    RBuff_hirq_IF_hresp         :  std_logic_vector(1 downto 0); -- response type
    signal    RBuff_hirq_IF_hrdata        :  std_logic_vector(31 downto 0); -- read data bus
    signal    RBuff_hirq_IF_hsplit        :  std_logic_vector(15 downto 0); -- split completion
    signal    RBuff_hirq_IF_hirq          :  std_ulogic; -- interrupt bus
    signal    RBuff_hirq_IF_hindex        :  integer range 0 to 2**COMP_NUM_POWER -1;  -- diagnostic use only
    
        --------------------------------------------------------------------------
        ---------------------    AHB_AG_Buffer_Wrapper   -------------------------
        -- Input Signals from AMBA Interface to AHB_AG_Buffer_Wrapper
    signal    IF_AG_hsel                  :  std_logic_vector(0 to 3);         -- slave select
    signal    IF_AG_haddr                 :  std_logic_vector(31 downto 0);    -- address bus (byte)
    signal    IF_AG_hwrite                :  std_ulogic;                       -- read/write
    signal    IF_AG_htrans                :  std_logic_vector(1 downto 0);     -- transfer type
    signal    IF_AG_hwdata                :  std_logic_vector(31 downto 0);    -- write data bus
    signal    IF_AG_hready                :  std_ulogic;                       -- transfer done

      
    -- Output Signals from AHB_AG_Buffer_Wrapper to AMBA Interface
    
    signal    AG_IF_hready                :  std_ulogic;                        -- transfer done
    signal    AG_IF_hresp                 :  std_logic_vector(1 downto 0);      -- response type
    signal    AG_IF_hrdata                :  std_logic_vector(31 downto 0);     -- read data bus
    signal    AG_IF_hsplit                :  std_logic_vector(15 downto 0);     -- split completion
    signal    AG_IF_hirq                  :  std_ulogic;                        -- interrupt bus
    signal    AG_IF_hindex                :  integer range 0 to 3;              -- diagnostic use only      east: "00", west: "01", south: "10", north: "11"  
    
    signal    AG_IF_ahbso_EAST_valid           :  std_ulogic;
    signal    AG_IF_ahbso_WEST_valid           :  std_ulogic;  
    signal    AG_IF_ahbso_SOUTH_valid          :  std_ulogic;
    signal    AG_IF_ahbso_NORTH_valid          :  std_ulogic

    -------------------------------------------------------------------------------
	
        --------------------------------------------------------------------------
        ---------------------    fault_injection_top   -------------------------
        -- Input Signals from AMBA Interface to fault_injection_top
    signal    IF_faultTOP_psel                   :  std_ulogic;                                       -- select   
    signal    IF_faultTOP_penable                :  std_ulogic;                                       -- enable,  strobe
    signal    IF_faultTOP_paddr                  :  std_logic_vector(31 downto 0);                    -- address bus (byte)
    signal    IF_faultTOP_pwrite                 :  std_ulogic;                                       -- write
    signal    IF_faultTOP_pwdata                 :  std_logic_vector(31 downto 0);                    -- write data bus
        
        -- Output Signals from fault_injection_top to AMBA Interface
    signal    faultTOP_IF_pirq                   :  std_ulogic;         
    signal    faultTOP_IF_pindex                 :  integer;
    signal    faultTOP_IF_prdata                 :  std_logic_vector(31 downto 0);
    signal    faultTOP_IF_apbo_valid             :  std_ulogic;

        
begin

	-------------------------------------------------------------------------------  from tcpa_TOP_new
	tcpa_rst         <= tcpa_config_rst or sync_rst or not ahb_rstn;
	gc_rstn          <= not tcpa_config_rst;
	glue_logic_rst   <= tcpa_config_rst;
	tcpa_clk_en      <= '1';

    -------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	rbuffer_hirq_inst : RBuffer_hirq
  	generic map (
		NUM_OF_BUFFER_STRUCTURES => NUM_OF_BUFFER_STRUCTURES, 
		CHANNEL_COUNT_NORTH      => AG_BUFFER_NORTH.CHANNEL_COUNT,registers
		CHANNEL_COUNT_WEST       => AG_BUFFER_WEST.CHANNEL_COUNT,
		CHANNEL_COUNT_SOUTH      => AG_BUFFER_SOUTH.CHANNEL_COUNT,
		CHANNEL_COUNT_EAST       => AG_BUFFER_EAST.CHANNEL_COUNT,
        COMPONENT_ADDRESS        => RBuffer_hirq_addr,
        hindex                   => RBuffer_hirq_ID,
        hirq                     => RBUFFER_HIRQ_AHB_IRQ
        )
	  port map(
		rstn              => ahb_rstn,   --ahb_rstn_in,
		clk               => ahb_clk,  --TCPA_clk,
		irq_clear         => RBuffer_hirq_clear,
		north_buffers_irq => north_buffers_irq_i,
		west_buffers_irq  => west_buffers_irq_i,
		south_buffers_irq => south_buffers_irq_i,
		east_buffers_irq  => east_buffers_irq_i,
        
		--ahbsi             => ahbsi_in,
        IF_RBuff_hirq_hready        => IF_RBuff_hirq_hready,
        IF_RBuff_hirq_hsel          => IF_RBuff_hirq_hsel,
        IF_RBuff_hirq_haddr         => IF_RBuff_hirq_haddr,
        IF_RBuff_hirq_hwrite        => IF_RBuff_hirq_hwrite,
        IF_RBuff_hirq_htrans        => IF_RBuff_hirq_htrans,
        IF_RBuff_hirq_hwdata        => IF_RBuff_hirq_hwdata,
        
        --ahbso             => RBuffer_hirq_out
        RBuff_hirq_IF_hready        => RBuff_hirq_IF_hready,
        RBuff_hirq_IF_hresp         => RBuff_hirq_IF_hresp,
        RBuff_hirq_IF_hrdata        => RBuff_hirq_IF_hrdata,
        RBuff_hirq_IF_hsplit        => RBuff_hirq_IF_hsplit,
        RBuff_hirq_IF_hirq          => RBuff_hirq_IF_hirq,
        RBuff_hirq_IF_hindex        => RBuff_hirq_IF_hindex
        );

    -------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
    
	BUFFER_NORTH : if CFG_BUFFER_NORTH = 1 generate
        AG_IF_ahbso_NORTH_valid <= '1';
		AG_BUFFER__NORTH : AHB_AG_Buffer_Wrapper    --AHB_AG_Buffer_Wrapper
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
                
                COMPONENT_ADDRESS                     => AG_Buffer_Wrapper_NORTH,
                hindex                                => AG_Buffer_NORTH_ID,
                hirq                                  => AG_BUFFER_NORTH.AG_hirqregisters
			)
			port map(
				clk                      => ahb_clk -- TCPA_clk, --gc_clk,
				reset                    => tcpa_rst,
				gc_reset                 => gc_reset,
				start                    => AG_start,

				-- configuration state
				config_done              => AG_config_done_NORTH,
				restart_ext              => restart_ext_north,
				
				-- AG Signals
				AG_buffer_interrupt      => north_ag_irq_i,
				index_vector             => AG_index_vector, -- should be mapped
				AG_out_addr_out          => AG_out_addr_i_NORTH,
				AG_en                    => gc_global_en,
				AG_out_en_out            => AG_out_en_i_NORTH,

				-- TCPA Signals
				cpu_tcpa_buffer          => cpu_tcpa_buffer_reg,
				channel_tcpa_input_data  => channel_tcpa_input_data_NORTH,
				channel_tcpa_output_data => channel_tcpa_output_data_NORTH,
				buffers_irq              => north_buffers_irq_i,
				buffer_event             => north_buffers_event_i,
				irq_clear                => RBuffer_hirq_clear(0),
                
				ahb_clk                  => ahb_clk,     --ahb_clk_in,
				ahb_rstn                 => ahb_rstn,    --ahb_rstn_in,
                
				--ahbsi                    => ahbsi_in,
                IF_AG_hsel               => IF_AG_hsel,
                IF_AG_haddr              => IF_AG_haddr,
                IF_AG_hwrite             => IF_AG_hwrite,
                IF_AG_htrans             => IF_AG_htrans,
                IF_AG_hwdata             => IF_AG_hwdata,
                IF_AG_hready             => IF_AG_hready,
                
				--ahbso                    => ahbso_out_NORTH
                AG_IF_hready             => AG_IF_hready,
                AG_IF_hresp              => AG_IF_hresp,
                AG_IF_hrdata             => AG_IF_hrdata,
                AG_IF_hsplit             => AG_IF_hsplit,
                AG_IF_hirq               => AG_IF_hirq,
                AG_IF_hindex             => AG_IF_hindex    -- diagnostic use only      east: "00", west: "01", south: "10", north: "11"  
			);
	end generate;
	NO_BUFFER_NORTH : if CFG_BUFFER_NORTH = 0 generate
		AG_config_done_NORTH            <= '1';
		north_ag_irq_i                  <= (others => '0');
		north_buffers_irq_i             <= (others => '0');
		north_buffers_event_i           <= (others => '0');
		restart_ext_north               <= '0';
		channel_tcpa_output_data_NORTH  <= (others => '0');
        AG_IF_ahbso_NORTH_valid         <= '0';             		--ahbso_out_NORTH                <= ahbs_none;   
	end generate;
        
        
        
	BUFFER_SOUTH : if CFG_BUFFER_SOUTH = 1 generate
        AG_IF_ahbso_SOUTH_valid         <= '1'; 
		AG_BUFFER__SOUTH : AHB_AG_Buffer_Wrapper
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
                
                COMPONENT_ADDRESS                     => AG_Buffer_Wrapper_SOUTH,
                hindex                                => AG_Buffer_SOUTH_ID,
                hirq                                  => AG_BUFFER_SOUTH.AG_hirq
			)
			port map(
				clk                      => ahb_clk,
				reset                    => tcpa_rst,
				gc_reset                 => gc_reset,
				start                    => AG_start,

				--configuration state
				config_done              => AG_config_done_SOUTH,
				restart_ext              => restart_ext_south,

				--AG Signals
				AG_buffer_interrupt      => south_ag_irq_i,
				index_vector             => AG_index_vector, --should be mapped
				AG_out_addr_out          => AG_out_addr_i_SOUTH,
				AG_en                    => gc_global_en,
				AG_out_en_out            => AG_out_en_i_SOUTH,

				-- TCPA Signals
				cpu_tcpa_buffer          => cpu_tcpa_buffer_reg,
				channel_tcpa_input_data  => channel_tcpa_input_data_SOUTH,
				channel_tcpa_output_data => channel_tcpa_output_data_SOUTH,
				buffers_irq              => south_buffers_irq_i,
				buffer_event             => south_buffers_event_i,
				irq_clear                => RBuffer_hirq_clear(2),
                
				ahb_clk                  => ahb_clk,     --ahb_clk_in,
				ahb_rstn                 => ahb_rstn,    --ahb_rstn_in,
                
				--ahbsi                    => ahbsi_in,
                IF_AG_hsel               => IF_AG_hsel,
                IF_AG_haddr              => IF_AG_haddr,
                IF_AG_hwrite             => IF_AG_hwrite,
                IF_AG_htrans             => IF_AG_htrans,
                IF_AG_hwdata             => IF_AG_hwdata,
                IF_AG_hready             => IF_AG_hready,
                
				--ahbso                    => ahbso_out_NORTH
                AG_IF_hready             => AG_IF_hready,
                AG_IF_hresp              => AG_IF_hresp,
                AG_IF_hrdata             => AG_IF_hrdata,
                AG_IF_hsplit             => AG_IF_hsplit,
                AG_IF_hirq               => AG_IF_hirq,
                AG_IF_hindex             => AG_IF_hindex    -- diagnostic use only      east: "00", west: "01", south: "10", north: "11"  
			);
	end generate;
	NO_BUFFER_SOUTH : if CFG_BUFFER_SOUTH = 0 generate
		AG_config_done_SOUTH            <= '1';
		south_ag_irq_i                  <= (others => '0');
		south_buffers_irq_i             <= (others => '0');
		south_buffers_event_i           <= (others => '0');
		restart_ext_south               <= '0';
		channel_tcpa_output_data_SOUTH  <= (others => '0');
		AG_IF_ahbso_SOUTH_valid         <= '0'; --ahbso_out_SOUTH                <= ahbs_none;
	end generate; 
        
        
	BUFFER_EAST : if CFG_BUFFER_EAST = 1 generate
        AG_IF_ahbso_EAST_valid <= '1';
		AG_BUFFER__EAST : AHB_AG_Buffer_Wrapper
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
                
                COMPONENT_ADDRESS                     => AG_Buffer_Wrapper_EAST,
                hindex                                => AG_Buffer_EAST_ID,  
                hirq                                  => AG_BUFFER_EAST.AG_hirq
			)
			port map(
				clk                      => ahb_clk --TCPA_clk, --gc_clk,
				reset                    => tcpa_rst,
				gc_reset                 => gc_reset,
				start                    => AG_start,

				-- configuration state
				config_done              => AG_config_done_EAST,
				restart_ext              => restart_ext_east,

				-- AG Signals
				AG_buffer_interrupt      => east_ag_irq_i,
				index_vector             => AG_index_vector, -- should be mapped
				AG_out_addr_out          => AG_out_addr_i_EAST,
				AG_en                    => gc_global_en,
				AG_out_en_out            => AG_out_en_i_EAST,

				-- TCPA Signals
				cpu_tcpa_buffer          => cpu_tcpa_buffer_reg,
				channel_tcpa_input_data  => channel_tcpa_input_data_EAST,
				channel_tcpa_output_data => channel_tcpa_output_data_EAST,
				buffers_irq              => east_buffers_irq_i,registers
				buffer_event             => east_buffers_event_i,
				irq_clear                => RBuffer_hirq_clear(3),
                
				ahb_clk                  => ahb_clk,     --ahb_clk_in,
				ahb_rstn                 => ahb_rstn,    --ahb_rstn_in,
                
				--ahbsi                    => ahbsi_in,
                IF_AG_hsel               => IF_AG_hsel,
                IF_AG_haddr              => IF_AG_haddr,
                IF_AG_hwrite             => IF_AG_hwrite,
                IF_AG_htrans             => IF_AG_htrans,
                IF_AG_hwdata             => IF_AG_hwdata,
                IF_AG_hready             => IF_AG_hready,
                
				--ahbso                    => ahbso_out_NORTH
                AG_IF_hready             => AG_IF_hready,
                AG_IF_hresp              => AG_IF_hresp,
                AG_IF_hrdata             => AG_IF_hrdata,
                AG_IF_hsplit             => AG_IF_hsplit,
                AG_IF_hirq               => AG_IF_hirq,
                AG_IF_hindex             => AG_IF_hindex    -- diagnostic use only      east: "00", west: "01", south: "10", north: "11"  
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
		AG_BUFFER__WEST : AHB_AG_Buffer_Wrapper
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
                
                COMPONENT_ADDRESS                     => AG_Buffer_Wrapper_WEST,
                hindex                                => AG_Buffer_WEST_ID,
                hirq                                  => AG_BUFFER_WEST.AG_hirq
			)
			port map(
				clk                      => ahb_clk  --TCPA_clk, --gc_clk,
				reset                    => tcpa_rst,
				start                    => AG_start,
				gc_reset                 => gc_reset, 
                
				-- configuration state
				config_done              => AG_config_done_WEST,
				restart_ext              => restart_ext_west,

				-- AG Signals
				AG_buffer_interrupt      => west_ag_irq_i,
				index_vector             => AG_index_vector,
				AG_out_addr_out          => AG_out_addr_i_WEST,
				AG_en                    => gc_global_en,
				AG_out_en_out            => AG_out_en_i_WEST,

				-- TCPA Signals
				cpu_tcpa_buffer          => cpu_tcpa_buffer_reg,
				channel_tcpa_input_data  => channel_tcpa_input_data_WEST,
				channel_tcpa_output_data => channel_tcpa_output_data_WEST,
				buffers_irq              => west_buffers_irq_i,
				buffer_event             => west_buffers_event_i,
				irq_clear                => RBuffer_hirq_clear(1),
                
				ahb_clk                  => ahb_clk,     --ahb_clk_in,
				ahb_rstn                 => ahb_rstn,    --ahb_rstn_in,
                
				--ahbsi                    => ahbsi_in,
                IF_AG_hsel               => IF_AG_hsel,
                IF_AG_haddr              => IF_AG_haddr,
                IF_AG_hwrite             => IF_AG_hwrite,
                IF_AG_htrans             => IF_AG_htrans,
                IF_AG_hwdata             => IF_AG_hwdata,
                IF_AG_hready             => IF_AG_hready,
                
				--ahbso                    => ahbso_out_NORTH
                AG_IF_hready             => AG_IF_hready,
                AG_IF_hresp              => AG_IF_hresp,
                AG_IF_hrdata             => AG_IF_hrdata,
                AG_IF_hsplit             => AG_IF_hsplit,
                AG_IF_hirq               => AG_IF_hirq,
                AG_IF_hindex             => AG_IF_hindex    -- diagnostic use only      east: "00", west: "01", south: "10", north: "11"  
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

	GLOBAL_CONTROLLER_RESTART_LOGIC : process(ahb_clk, glue_logic_rst, TCPA_ic_in) is
	begin
		if glue_logic_rst = '1' then
			gc_restart_ext <= '0';
			sync_rst       <= '0';
			sync           <= '0';

		elsif rising_edge(ahb_clk) then
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
			clk                     => ahb_clk --TCPA_clk, -- gc_clk,
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
			gc_irq			        => gc_irq,
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
            COMPONENT_ADDRESS  => gc_apb_slave_mem_wrapper_addr,
			pindex  => gc_apb_slave_mem_wrapper_ID,
			-- paddr       : integer := 0;
			-- pmask       : integer := 16#ff0#;
            pirq        => 0
		)
		port map(
			rstn        => gc_rstn,     -- same rstn as ahb rstn
			clk         => ahb_clk,      --ahb_clk_in,  -- same clck as ahb clck
			start       => gc_start_mux_out, 
			stop        => gc_stop, 
            
--          apbi        => apbi_in,
            IF_gc_psel                   => IF_gc_psel,         
            IF_gc_penable                => IF_gc_penable,
            IF_gc_paddr                  => IF_gc_paddr,
            IF_gc_pwrite                 => IF_gc_pwrite,
            IF_gc_pwdata                 => IF_gc_pwdata,
            
--          apbo        => GC_apbo_out,
            gc_IF_pirq                   => gc_IF_pirq,
            gc_IF_prdata                 => gc_IF_prdata,
            gc_IF_pindex                 => gc_IF_pindex,
            
			conf_en     => gc_conf_en,
			rnready     => gc_rnready,
			config_done => gc_config_done,
			gc_done     => gc_done,
			gc_irq      => gc_irq,
			dout        => gc_config_dout,
			pdone       => gc_pdone,
			gc_reset    => gc_reset
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
			conf_clk      => ahb_clk,     --ahb_clk_in,
			conf_bus      => gc_config_dout(ITERATION_VARIABLE_WIDTH - 1 downto 0),
			reset         => gc_reset,
			tcpa_clk      => ahb_clk  --TCPA_clk,
			stop          => gc_stop,
			start         => gc_start_mux_out,
			global_en     => gc_global_en,
			restart_ext   => gc_restart_ext,
			dclk_in       => ahb_clk   --dclk_in,
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
			end generate;  
        end generate;
        
        
        
        sync_process : process(ahb_clk)
        begin
            if rising_edge(ahb_clk) then
                channel_tcpa_input_data_EAST  <= sig_channel_tcpa_input_data_EAST;
                channel_tcpa_input_data_WEST  <= sig_channel_tcpa_input_data_WEST;
                channel_tcpa_input_data_SOUTH <= sig_channel_tcpa_input_data_SOUTH;
                channel_tcpa_input_data_NORTH <= sig_channel_tcpa_input_data_NORTH;
                
                sig_channel_tcpa_output_data_EAST  <= channel_tcpa_output_data_EAST;
                sig_channel_tcpa_output_data_WEST  <= channel_tcpa_output_data_WEST;
                sig_channel_tcpa_output_data_SOUTH <= channel_tcpa_output_data_SOUTH;
                sig_channel_tcpa_output_data_NORTH <= channel_tcpa_output_data_NORTH;
            end if;
        end process;	
	end generate;
	
    
	BUFFERS_LOOPBACK_CONNECTION : if CFG_ENABLE_TCPA = 0 generate
		loopback : process(ahb_clk)
		begin
			if rising_edge(ahb_clk) then
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
    
    -------------------------------------------------------------------------------
	------------------------------------------------------------------------------- 
  
	hw_sw_interface : top_hardware_interface
		generic map(
			pindex  => top_hw_interface_ID,
			-- paddr  : integer := 13;
			-- pmask  : integer := 16#fff#;
            COMPONENT_ADDRESS => top_hardware_interface_addr
            )
		port map(
			rst                          => ahb_rstn,     --ahb_rstn_in,
			amba_clk                     => ahb_clk,      --ahb_clk_in,

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
            IF_HwInterFace_psel          => IF_HwInterFace_psel,           
            IF_HwInterFace_penable       => IF_HwInterFace_penable,
            IF_HwInterFace_paddr         => IF_HwInterFace_paddr,
            IF_HwInterFace_pwrite        => IF_HwInterFace_pwrite,
            IF_HwInterFace_pwdata        => IF_HwInterFace_pwdata,
            
            -- apbo                         => CM_apbo
            HwInterFace_IF_pirq          => HwInterFace_IF_pirq,
            HwInterFace_IF_prdata        => HwInterFace_IF_prdata,
            HwInterFace_IF_pindex        => HwInterFace_IF_pindex
            
		);

    -------------------------------------------------------------------------------
	------------------------------------------------------------------------------- 
  
	reconfig_regs : reconfig_registers
		generic map(
			pindex => reconfig_registers_ID,
			-- paddr  : integer := 12;
			-- pmask  : integer := 16#fff#;
            COMPONENT_ADDRESS  => reconfig_registers_addr
            )
		port map(
			rst                      => ahb_rstn,    --ahb_rstn_in,
			gc_reset                 => gc_reset,
			clk                      => ahb_clk,     --ahb_clk_in,
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
            IF_ReconfReg_psel        => IF_ReconfReg_psel,              
            IF_ReconfReg_penable     => IF_ReconfReg_penable,
            IF_ReconfReg_paddr       => IF_ReconfReg_paddr,
            IF_ReconfReg_pwrite      => IF_ReconfReg_pwrite,
            IF_ReconfReg_pwdata      => IF_ReconfReg_pwdata,

            -- apbo                     => reconfig_regs_apbo
            ReconfReg_IF_pirq        => ReconfReg_IF_pirq,
            ReconfReg_IF_prdata      => ReconfReg_IF_prdata,
            ReconfReg_IF_pindex      => ReconfReg_IF_pindex
		);

    -------------------------------------------------------------------------------
	------------------------------------------------------------------------------- 
    
	en_fault_injection : if FAULT_INJECTION_MODULE_EN = TRUE generate
        faultTOP_IF_apbo_valid <= '1';
		entity_fault_injection_top : fault_injection_top
			generic map(
				MEM_SIZE          => 128,
				DATA_WIDTH        => 32,
				ADDR_WIDTH        => 7,
				NUM_OF_IC_SIGNALS => NUM_OF_IC_SIGNALS,
				pindex            => fault_injection_top_ID,
				pirq              => 0,
				-- paddr             => FI_paddr,
				-- pmask             => FI_pmask
                COMPONENT_ADDRESS  => fault_injection_top_addr
                )
			port map(
				rstn            => ahb_rstn_in, --tcpa_rst, 
				clk             => ahb_clk   --TCPA_clk,
				tcpa_start      => sig_tcpa_start,
				tcpa_stop	    => sig_tcpa_stop,
				fault_injection => sig_fault_injection, 
				error_status    => sig_error_status, 
                
                -- Input Signals from AMBA Interface to fault_injection_top
                IF_faultTOP_psel    => IF_faultTOP_psel,       -- select   
                IF_faultTOP_penable => IF_faultTOP_penable,                                      -- enable,  strobe
                IF_faultTOP_paddr   => IF_faultTOP_paddr,                   -- address bus (byte)
                IF_faultTOP_pwrite  => IF_faultTOP_pwrite,                                      -- write
                IF_faultTOP_pwdata  => IF_faultTOP_pwdata,                   -- write data bus
                    
                -- Output Signals from fault_injection_top to AMBA Interface            --apbo : out apb_slv_out_type
                faultTOP_IF_pirq    => faultTOP_IF_pirq,        
                faultTOP_IF_pindex  => faultTOP_IF_pindex,
                faultTOP_IF_prdata  => faultTOP_IF_prdata
                );
	end generate;
	no_fault_injection_module : if FAULT_INJECTION_MODULE_EN = FALSE generate
        faultTOP_IF_apbo_valid <= '0';      --	FI_apbo <= apb_none;
	end generate; 
        
	debug_tcpa_0 : if CFG_ENABLE_TCPA = 1 generate
		inst_tcpa_top : WPPA_TOP			
        port map(
				clk                          => ahb_clk,    --TCPA_clk,
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
				icp_program_interface        => sig_icp_program_interface
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

    
    
    
    
	-------------------------------------------------------   generate addr_array_index to check which component is of interest
    addr_mask  <= ahbsi.haddr and mask_intern;
    addr_srl   <= to_stdlogicvector(to_bitvector(addr_mask) srl COMP_SIZE);
    addr_array_index <= to_integer(unsigned(addr_srl));  
    
    
-----------------------------------------------------------------  generate address - array
    gen_addr_array : process(ahb_clk, ahb_rstn)
    begin
        if(ahb_clk'event and ahb_clk='1') then
            if ahb_rstn = '0' then 
                for i  in 0 to 2**COMP_NUM_POWER-1 loop
                    component_addr_array(i) <= std_logic_vector(to_unsigned((i*(component_size)),32));
                end loop;
                report "********* Component_Addr_ARRAY is READY *********"; 
            end if;
        end if;
    end process gen_addr_array;
    
    
-----------------------------------------------------------------  find out the component address of interest
    arbitration : process (ahb_clk, ahb_rstn, ahbsi, addr_array_index)
    begin
        if(ahb_clk'event and ahb_clk='1') then
            if ahb_rstn = '0' then 
                IF_component_addr        <= (others => '0');
                report "********* ahb_rstn is ON *********";
            else
                IF_component_addr      <= (others => '0');
                if ahbsi.hsel(hindex) = '1' then            -- check whether the amba_interface is called
                    IF_component_addr  <= component_addr_array(addr_array_index);
                    report "********* addr_array_index is " & integer'image(addr_array_index) & " *********";
                end if;
            end if;
        end if;    
    end process arbitration;
       

       
-----------------------------------------------------------------  configure the output signals to component   
    output_to_component: process (IF_component_addr)      
    begin
        if IF_component_addr = RBuffer_hirq_addr then  ---------------------        Component: RBuffer_hirq       
                IF_RBuff_hirq_hready    <=  ahbsi.hready;
                IF_RBuff_hirq_hsel      <=  '1';
                IF_RBuff_hirq_haddr     <=  ahbsi.haddr;
                IF_RBuff_hirq_hwrite    <=  ahbsi.hwrite;
                IF_RBuff_hirq_htrans    <=  ahbsi.htrans;
                IF_RBuff_hirq_hwdata    <=  ahbsi.hwdata;

        elsif IF_component_addr = AG_Buffer_Wrapper_NORTH then ---------------------   Component: AHB_AG_Buffer_Wrapper_NORTH
                if AG_IF_ahbso_NORTH_valid = '1' then
                    IF_AG_hsel        <=  "0001";
                    IF_AG_haddr       <=  ahbsi.haddr;
                    IF_AG_hwrite      <=  ahbsi.hwrite;
                    IF_AG_htrans      <=  ahbsi.htrans;
                    IF_AG_hwdata      <=  ahbsi.hwdata;
                    IF_AG_hready      <=  ahbsi.hready;
                    
                else
                    IF_AG_hsel        <=  (others=>'0');
                    IF_AG_haddr       <=  (others=>'0');
                    IF_AG_hwrite      <=  '0';
                    IF_AG_htrans      <=  (others=>'0');
                    IF_AG_hwdata      <=  (others=>'0');
                    IF_AG_hready      <=  '0';
                end if;
                
        elsif IF_component_addr = AG_Buffer_Wrapper_SOUTH then ---------------------   Component: AHB_AG_Buffer_Wrapper_SOUTH
                if AG_IF_ahbso_SOUTH_valid = '1' then
                    IF_AG_hsel        <=  "0010";
                    IF_AG_haddr       <=  ahbsi.haddr;
                    IF_AG_hwrite      <=  ahbsi.hwrite;
                    IF_AG_htrans      <=  ahbsi.htrans;
                    IF_AG_hwdata      <=  ahbsi.hwdata;
                    IF_AG_hready      <=  ahbsi.hready;
                    
                else
                    IF_AG_hsel        <=  (others=>'0');
                    IF_AG_haddr       <=  (others=>'0');
                    IF_AG_hwrite      <=  '0';
                    IF_AG_htrans      <=  (others=>'0');
                    IF_AG_hwdata      <=  (others=>'0');
                    IF_AG_hready      <=  '0';
                end if;
                
        elsif IF_component_addr = AG_Buffer_Wrapper_WEST then ---------------------   Component: AHB_AG_Buffer_Wrapper_WEST
                if AG_IF_ahbso_WEST_valid = '1' then
                    IF_AG_hsel        <=  "0100";
                    IF_AG_haddr       <=  ahbsi.haddr;
                    IF_AG_hwrite      <=  ahbsi.hwrite;
                    IF_AG_htrans      <=  ahbsi.htrans;
                    IF_AG_hwdata      <=  ahbsi.hwdata;
                    IF_AG_hready      <=  ahbsi.hready;
                    
                else
                    IF_AG_hsel        <=  (others=>'0');
                    IF_AG_haddr       <=  (others=>'0');
                    IF_AG_hwrite      <=  '0';
                    IF_AG_htrans      <=  (others=>'0');
                    IF_AG_hwdata      <=  (others=>'0');
                    IF_AG_hready      <=  '0';
                end if;
                
        elsif IF_component_addr = AG_Buffer_Wrapper_EAST then ---------------------   Component: AHB_AG_Buffer_Wrapper_EAST
                if AG_IF_ahbso_EAST_valid = '1' then
                    IF_AG_hsel        <=  "1000";
                    IF_AG_haddr       <=  ahbsi.haddr;
                    IF_AG_hwrite      <=  ahbsi.hwrite;
                    IF_AG_htrans      <=  ahbsi.htrans;
                    IF_AG_hwdata      <=  ahbsi.hwdata;
                    IF_AG_hready      <=  ahbsi.hready;
                    
                else
                    IF_AG_hsel        <=  (others=>'0');
                    IF_AG_haddr       <=  (others=>'0');
                    IF_AG_hwrite      <=  '0';
                    IF_AG_htrans      <=  (others=>'0');
                    IF_AG_hwdata      <=  (others=>'0');
                    IF_AG_hready      <=  '0';
                end if;
                 
        elsif IF_component_addr = top_hardware_interface_addr then --------------------- Component: top_hardware_interface       
                IF_HwInterFace_psel       <=  '1';
                IF_HwInterFace_penable    <=  '1';
                IF_HwInterFace_paddr      <=  ahbsi.haddr;
                IF_HwInterFace_pwrite     <=  ahbsi.hwrite;
                IF_HwInterFace_pwdata     <=  ahbsi.hwdata;
                
        elsif IF_component_addr = reconfig_registers_addr then ---------------------     Component: reconfig_registers     
                IF_ReconfReg_psel         <=  '1';
                IF_ReconfReg_penable      <=  '1';
                IF_ReconfReg_paddr        <=  ahbsi.haddr;
                IF_ReconfReg_pwrite       <=  ahbsi.hwrite;
                IF_ReconfReg_pwdata       <=  ahbsi.hwdata;
                
        elsif IF_component_addr = gc_apb_slave_mem_wrapper_addr then ---------------------     Component: gc_apb_slave_mem_wrapper     
                IF_gc_psel                <=  '1';
                IF_gc_penable             <=  '1';
                IF_gc_paddr               <=  ahbsi.haddr;
                IF_gc_pwrite              <=  ahbsi.hwrite;
                IF_gc_pwdata              <=  ahbsi.hwdata;

        elsif IF_component_addr = fault_injection_top_addr then ---------------------     Component: fault_injection_top     
                if faultTOP_IF_apbo_valid = '1' then
                    IF_faultTOP_psel          <=  '1';
                    IF_faultTOP_penable       <=  '1';
                    IF_faultTOP_paddr         <=  ahbsi.haddr;
                    IF_faultTOP_pwrite        <=  ahbsi.hwrite;
                    IF_faultTOP_pwdata        <=  ahbsi.hwdata;
                else 
                    IF_faultTOP_psel          <=  '0';
                    IF_faultTOP_penable       <=  '0';
                    IF_faultTOP_paddr         <=  (others=>'0');
                    IF_faultTOP_pwrite        <=  '0';
                    IF_faultTOP_pwdata        <=  (others=>'0');
                end if;
                
                
        else 
                IF_RBuff_hirq_hready    <=  '0';
                IF_RBuff_hirq_hsel      <=  '0';
                IF_RBuff_hirq_haddr     <=  (others=>'0');
                IF_RBuff_hirq_hwrite    <=  '0';
                IF_RBuff_hirq_htrans    <=  (others=>'0');
                IF_RBuff_hirq_hwdata    <=  (others=>'0');
            
                IF_AG_hsel              <=  (others=>'0');
                IF_AG_haddr             <=  (others=>'0');
                IF_AG_hwrite            <=  '0';
                IF_AG_htrans            <=  (others=>'0');
                IF_AG_hwdata            <=  (others=>'0');
                IF_AG_hready            <=  '0';
                
                IF_HwInterFace_psel       <=  '0';
                IF_HwInterFace_penable    <=  '0';
                IF_HwInterFace_paddr      <=  (others=>'0');
                IF_HwInterFace_pwrite     <=  '0';
                IF_HwInterFace_pwdata     <=  (others=>'0');
                
                IF_ReconfReg_psel         <=  '0';
                IF_ReconfReg_penable      <=  '0';
                IF_ReconfReg_paddr        <=  (others=>'0');
                IF_ReconfReg_pwrite       <=  '0';
                IF_ReconfReg_pwdata       <=  (others=>'0');
                
                IF_gc_psel                <=  '0';
                IF_gc_penable             <=  '0';
                IF_gc_paddr               <=  (others=>'0');
                IF_gc_pwrite              <=  '0';
                IF_gc_pwdata              <=  (others=>'0');
                
                IF_faultTOP_psel          <=  '0';
                IF_faultTOP_penable       <=  '0';
                IF_faultTOP_paddr         <=  (others=>'0');
                IF_faultTOP_pwrite        <=  '0';
                IF_faultTOP_pwdata        <=  (others=>'0');
                
        end if;
    end process;
    
    
    
-----------------------------------------------------------------  configure the output signals to bus       -- abhso configuration
    output_to_bus: process (ahbsi, IF_component_addr, RBuff_hirq_IF_hindex, AG_IF_hindex, AG_IF_ahbso_NORTH_valid, AG_IF_ahbso_SOUTH_valid, AG_IF_ahbso_WEST_valid, AG_IF_ahbso_EAST_valid, faultTOP_IF_apbo_valid,
                            HwInterFace_IF_pindex, ReconfReg_IF_pindex, gc_IF_pindex, RBuff_hirq_IF_hready, AG_IF_hready, faultTOP_IF_pindex)      
    begin
        ----------------------------------------------  default assignment
        ahbso.hrdata         <= (others => '0');
        ahbso.hready         <= '0';
        ahbso.hresp          <= (others => '0');      -- status: okay
        ahbso.hirq           <= (others => '0');
        ahbso.hsplit         <= (others => '0');
        ahbso.hconfig        <= AMBA_IF_CONFIG;
        ahbso.hindex         <= hindex;
    
        if ahbsi.hwrite = '1' then				     -- write data	
            if IF_component_addr = RBuffer_hirq_addr then  ---------------------        Component: RBuffer_hirq     
                if RBuff_hirq_IF_hindex = RBuffer_hirq_ID then      -- check ID
                    ahbso.hrdata         <= (others => '0');
                    ahbso.hready         <= RBuff_hirq_IF_hready;
                    ahbso.hresp          <= RBuff_hirq_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= RBuff_hirq_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = AG_Buffer_Wrapper_NORTH then ---------------------   Component: AHB_AG_Buffer_Wrapper_NORTH
                if AG_IF_hindex = AG_Buffer_NORTH_ID and AG_IF_ahbso_NORTH_valid = '1' then      -- check ID
                    ahbso.hrdata         <= (others => '0');
                    ahbso.hready         <= AG_IF_hready;
                    ahbso.hresp          <= AG_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= AG_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = AG_Buffer_Wrapper_SOUTH then ---------------------   Component: AHB_AG_Buffer_Wrapper_SOUTH
                if AG_IF_hindex = AG_Buffer_SOUTH_ID and AG_IF_ahbso_SOUTH_valid = '1' then      -- check ID
                    ahbso.hrdata         <= (others => '0');
                    ahbso.hready         <= AG_IF_hready;
                    ahbso.hresp          <= AG_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= AG_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = AG_Buffer_Wrapper_WEST then ---------------------   Component: AHB_AG_Buffer_Wrapper_WEST
                if AG_IF_hindex = AG_Buffer_WEST_ID and AG_IF_ahbso_WEST_valid = '1' then      -- check ID
                    ahbso.hrdata         <= (others => '0');
                    ahbso.hready         <= AG_IF_hready;
                    ahbso.hresp          <= AG_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= AG_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = AG_Buffer_Wrapper_EAST then ---------------------   Component: AHB_AG_Buffer_Wrapper_EAST
                if AG_IF_hindex = AG_Buffer_EAST_ID and AG_IF_ahbso_EAST_valid = '1' then      -- check ID
                    ahbso.hrdata         <= (others => '0');
                    ahbso.hready         <= AG_IF_hready;
                    ahbso.hresp          <= AG_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= AG_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = top_hardware_interface_addr then --------------------- Component: top_hardware_interface       
                if HwInterFace_IF_pindex = top_hw_interface_ID then      -- check ID
                    ahbso.hrdata         <= (others => '0');
                    ahbso.hready         <= '1';
                    ahbso.hresp          <= (others => '0');
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= (others => '0');
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = reconfig_registers_addr then ---------------------     Component: reconfig_registers     
                if ReconfReg_IF_pindex = reconfig_registers_ID then      -- check ID
                    ahbso.hrdata         <= (others => '0');
                    ahbso.hready         <= '1';
                    ahbso.hresp          <= (others => '0');
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= (others => '0');
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = gc_apb_slave_mem_wrapper_addr then ---------------------     Component: gc_apb_slave_mem_wrapper
                if gc_IF_pindex = gc_apb_slave_mem_wrapper_ID then      -- check ID
                    ahbso.hrdata         <= (others => '0');
                    ahbso.hready         <= '1';
                    ahbso.hresp          <= (others => '0');
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= (others => '0');
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
          
        else	------------------------------------------- read data
            if IF_component_addr = RBuffer_hirq_addr then  ---------------------        Component: RBuffer_hirq     
                if RBuff_hirq_IF_hindex = RBuffer_hirq_ID then      -- check ID
                    ahbso.hrdata         <= RBuff_hirq_IF_hrdata;
                    ahbso.hready         <= RBuff_hirq_IF_hready;
                    ahbso.hresp          <= RBuff_hirq_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= RBuff_hirq_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = AG_Buffer_Wrapper_NORTH then ---------------------   Component: AHB_AG_Buffer_Wrapper_NORTH
                if AG_IF_hindex = AG_Buffer_NORTH_ID and AG_IF_ahbso_NORTH_valid = '1' then      -- check ID
                    ahbso.hrdata         <= AG_IF_hrdata;
                    ahbso.hready         <= AG_IF_hready;
                    ahbso.hresp          <= AG_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= AG_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = AG_Buffer_Wrapper_SOUTH then ---------------------   Component: AHB_AG_Buffer_Wrapper_SOUTH
                if AG_IF_hindex = AG_Buffer_SOUTH_ID and AG_IF_ahbso_SOUTH_valid = '1' then      -- check ID
                    ahbso.hrdata         <= AG_IF_hrdata;
                    ahbso.hready         <= AG_IF_hready;
                    ahbso.hresp          <= AG_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= AG_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = AG_Buffer_Wrapper_WEST then ---------------------   Component: AHB_AG_Buffer_Wrapper_WEST
                if AG_IF_hindex = AG_Buffer_WEST_ID and AG_IF_ahbso_WEST_valid = '1' then      -- check ID
                    ahbso.hrdata         <= AG_IF_hrdata;
                    ahbso.hready         <= AG_IF_hready;
                    ahbso.hresp          <= AG_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= AG_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = AG_Buffer_Wrapper_EAST then ---------------------   Component: AHB_AG_Buffer_Wrapper_EAST
                if AG_IF_hindex = AG_Buffer_EAST_ID and AG_IF_ahbso_EAST_valid = '1' then      -- check ID
                    ahbso.hrdata         <= AG_IF_hrdata;
                    ahbso.hready         <= AG_IF_hready;
                    ahbso.hresp          <= AG_IF_hresp;       
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= AG_IF_hsplit;
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = top_hardware_interface_addr then --------------------- Component: top_hardware_interface       
                if HwInterFace_IF_pindex = top_hw_interface_ID then      -- check ID
                    ahbso.hrdata         <= HwInterFace_IF_prdata;
                    ahbso.hready         <= '1';
                    ahbso.hresp          <= (others => '0');
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= (others => '0');
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = reconfig_registers_addr then ---------------------     Component: reconfig_registers     
                if ReconfReg_IF_pindex = reconfig_registers_ID then      -- check ID
                    ahbso.hrdata         <= ReconfReg_IF_prdata;
                    ahbso.hready         <= '1';
                    ahbso.hresp          <= (others => '0');
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= (others => '0');
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            elsif IF_component_addr = gc_apb_slave_mem_wrapper_addr then ---------------------     Component: gc_apb_slave_mem_wrapper
                if gc_IF_pindex = gc_apb_slave_mem_wrapper_ID then      -- check ID
                    ahbso.hrdata         <= gc_IF_prdata;
                    ahbso.hready         <= '1';
                    ahbso.hresp          <= (others => '0');
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= (others => '0');
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;

            elsif IF_component_addr = fault_injection_top_addr then ---------------------     Component: fault_injection_top     
                if faultTOP_IF_pindex = fault_injection_top_ID and faultTOP_IF_apbo_valid = '1' then      -- check ID 
                    ahbso.hrdata         <= faultTOP_IF_prdata;
                    ahbso.hready         <= '1';
                    ahbso.hresp          <= (others => '0');
                    ahbso.hirq           <= (others => '0');
                    ahbso.hsplit         <= (others => '0');
                    ahbso.hconfig        <= AMBA_IF_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
            end if;
        end if;
    end process;
        
end Behavioral; 



