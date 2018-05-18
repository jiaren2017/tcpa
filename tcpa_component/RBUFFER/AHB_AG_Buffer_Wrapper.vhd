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
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:56:04 08/27/2014 
-- Design Name: 
-- Module Name:    AG_Buffer_Wrapper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;

use work.data_type_pkg.all;     -- for input and output format between amba_interface and tcpa components


entity AHB_AG_Buffer_Wrapper is
	generic(
		DESIGN_TYPE                           : integer range 0 to 7  := 1;
		ENABLE_PIXEL_BUFFER_MODE              : integer range 0 to 31 := 1;

		CONFIG_DATA_WIDTH                     : integer range 0 to 32 := 32;
		CONFIG_ADDR_WIDTH                     : integer range 0 to 32 := 10;

		INDEX_VECTOR_DIMENSION                : integer range 0 to 32 := 3;
		INDEX_VECTOR_DATA_WIDTH               : integer range 0 to 32 := 9;
		MATRIX_PIPELINE_DEPTH                  : integer range 0 to 32 := 2; -- equals log2(INDEX_VECTOR_DIMENSION) + 1

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
                BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := TRUE;
                EN_ELASTIC_BUFFER                     : boolean               := FALSE;                                         

		hindex                                : integer               := 0;
		hirq                                  : integer               := 0;
        -- haddr                                 : integer               := 0;
        -- hmask                                 : integer               := 16#fff#
        SUM_COMPONENT                         : integer                              : integer               := 16#fff#
	);
	port(
		clk                     : in  std_logic;
		reset                   : in  std_logic;
		gc_reset                : in  std_logic;

		start                   : in  std_logic;

		-- AG Signals
		AG_buffer_interrupt     : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
		index_vector            : in  std_logic_vector(INDEX_VECTOR_DIMENSION * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);

		-- configuration state
		config_done             : out std_logic;
		restart_ext             : out std_logic;

		-- TCPA Signals
		cpu_tcpa_buffer          : in cpu_tcpa_buffer_type;
		channel_tcpa_input_data  : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
		channel_tcpa_output_data : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
		
		-- AG Addrs
		AG_out_addr_out         : out std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0);
		AG_en                   : in  std_logic;
		AG_out_en_out           : out std_logic;

		-- Buffer IRQs
		buffers_irq             : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT - 1 downto 0);
		irq_clear               : in std_logic;
		buffer_event            : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);

		ahb_clk                 : in  std_logic;
		ahb_rstn                : in  std_logic;
        -- ahbsi                    : in  ahb_slv_in_type;
        -- ahbso                    : out ahb_slv_out_type
        IF_COMP_data             : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
        AG_IF_data               : out rec_COMP_IF  
	);
end AHB_AG_Buffer_Wrapper;

architecture Behavioral of AHB_AG_Buffer_Wrapper is


	type array_std_logic is array(NUM_OF_BUFFER_STRUCTURES - 1 downto 0) of std_logic;
	---------------------------------- Signals ------------------------------------
	-- AG Internal signals
	signal AG_config_clk     : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0);
	signal AG_config_rst     : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
--	signal AG_config_en_i      : std_logic;
--	signal AG_config_we_i      : std_logic;
	signal AG_config_en        : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal AG_config_we        : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');

	signal AG_config_data_i    : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*AG_CONFIG_DATA_WIDTH) - 1 downto 0) := (others => '0');
	signal AG_config_wr_addr_i : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*AG_CONFIG_ADDR_WIDTH) - 1 downto 0) := (others => '0');

	-- BUFFER Configurations signals
	signal BUFFER_config_clk     : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0);
	signal BUFFER_config_rst     : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0);
--	signal BUFFER_config_en_i      : std_logic;
--	signal BUFFER_config_we_i      : std_logic;
--	signal BUFFER_config_done_i    : std_logic                                               := '0';
--	signal BUFFER_config_start_i   : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0)   := (others => '0');
	signal BUFFER_config_data_i    : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*BUFFER_CONFIG_DATA_WIDTH) - 1 downto 0) := (others => '0');
	signal BUFFER_config_wr_addr_i : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*BUFFER_CONFIG_ADDR_WIDTH) - 1 downto 0) := (others => '0');

	signal BUFFER_config_done      : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal BUFFER_config_start     : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal BUFFER_config_en        : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal BUFFER_config_we        : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');

	-- AG Signals
	signal channels_en_i   : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CHANNEL_COUNT) - 1 downto 0)                    := (others => '0');
	signal channels_addr_i : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH) - 1 downto 0) := (others => '0');
	signal AG_out_addr_i   : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_ADDR_WIDTH - 1 downto 0)                 := (others => '0');
	signal AG_out_en_i     : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0) := (others=>'0');

	-- Configuration Write port
	signal config_clk_i         : std_logic;
	signal config_rst_i         : std_logic;
--	signal config_en_i          : std_logic;
--	signal config_we_i          : std_logic;
	signal config_en            : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal config_we            : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal config_data_i        : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_DATA_WIDTH) - 1 downto 0);
	signal config_wr_addr_i     : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_ADDR_WIDTH) - 1 downto 0);
	signal config_wr_data_out_i : std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_DATA_WIDTH) - 1 downto 0);
	
--	signal config_start_i      : std_logic;
--	signal config_soft_rst_i   : std_logic;
--	signal config_done_i       : std_logic;

	signal restart_ext_vector  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal config_start        : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal config_soft_rst     : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
	signal config_done_vector  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES -1 downto 0) := (others => '0');
--	signal buffer_interrupts_temp : std_logic_vector(CHANNEL_COUNT downto 0);
--	signal buffer_interrupts_i : std_logic_vector(NUM_OF_BUFFER_STRUCTURES*CHANNEL_COUNT downto 0);
	signal AG_buffer_interrupt_i : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);

	-- Buffer Channel Interface
	signal channel_bus_clk_i         : std_logic;
	signal channel_bus_rst_i         : std_logic;
	signal channel_bus_input_en_i    : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT - 1 downto 0);
	signal channel_bus_input_we_i    : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT - 1 downto 0);
	signal channel_bus_input_addr_i  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_ADDR_WIDTH * CHANNEL_COUNT - 1 downto 0);
	signal channel_bus_input_data_i  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
	signal channel_bus_output_data_i : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
	signal buffer_addr_lsb_i         : std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0);
	constant MAX_DATA_WIDTH          : integer range 0 to 32 := 32; -- max(CONFIG_DATA_WIDTH,CHANNEL_DATA_WIDTH

	-------------------------------------------------------------------------------

	---------------------------------- Components ---------------------------------
	component AG_Configurator is
		generic(
			CONFIG_DATA_WIDTH        : integer range 0 to 32 := CONFIG_DATA_WIDTH;
			CONFIG_ADDR_WIDTH        : integer range 0 to 32 := CONFIG_ADDR_WIDTH;
			AG_CONFIG_ADDR_WIDTH     : integer range 0 to 32 := AG_CONFIG_ADDR_WIDTH;
			AG_CONFIG_DATA_WIDTH     : integer range 0 to 32 := AG_CONFIG_DATA_WIDTH;
			AG_BUFFER_CONFIG_SIZE    : integer               := AG_BUFFER_CONFIG_SIZE;
			BUFFER_CONFIG_ADDR_WIDTH : integer range 0 to 32 := BUFFER_CONFIG_ADDR_WIDTH;
			BUFFER_CONFIG_DATA_WIDTH : integer range 0 to 32 := BUFFER_CONFIG_DATA_WIDTH
		);
		port(
			-- Write port
			config_clk            : in  std_logic;
			config_rst            : in  std_logic;
			config_en             : in  std_logic;
			config_we             : in  std_logic;
			config_data           : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
			config_wr_addr        : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
			config_wr_data_out    : out std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);

			-- configuration state
			config_start          : in  std_logic;
			config_soft_rst       : in  std_logic;
			config_done           : out std_logic;

			-- AG Configurations signals
			AG_config_clk         : out std_logic;
			AG_config_rst         : out std_logic;
			AG_config_en          : out std_logic;
			AG_config_we          : out std_logic;
			AG_config_data        : out std_logic_vector(AG_CONFIG_DATA_WIDTH - 1 downto 0);
			AG_config_wr_addr     : out std_logic_vector(AG_CONFIG_ADDR_WIDTH - 1 downto 0);

			-- BUFFER Configurations signals
			BUFFER_config_clk     : out std_logic;
			BUFFER_config_rst     : out std_logic;
			BUFFER_config_start   : out std_logic;
			BUFFER_config_done    : in  std_logic;
			BUFFER_config_en      : out std_logic;
			BUFFER_config_we      : out std_logic;
			BUFFER_config_data    : out std_logic_vector(BUFFER_CONFIG_DATA_WIDTH - 1 downto 0);
			BUFFER_config_wr_addr : out std_logic_vector(BUFFER_CONFIG_ADDR_WIDTH - 1 downto 0)
		);
	end component AG_Configurator;

	component AG_MATRIX_Pipelined is
		generic(
			DESIGN_TYPE             : integer range 0 to 7  := 1;
			INDEX_VECTOR_DIMENSION  : integer range 0 to 32 := INDEX_VECTOR_DIMENSION;
			INDEX_VECTOR_DATA_WIDTH : integer range 0 to 32 := INDEX_VECTOR_DATA_WIDTH;
			MATRIX_PIPELINE_DEPTH   : integer range 0 to 32 := MATRIX_PIPELINE_DEPTH;
			CONFIG_SIZE             : integer               := AG_BUFFER_CONFIG_SIZE; 

			CHANNEL_ADDR_WIDTH      : integer range 0 to 64 := CHANNEL_ADDR_WIDTH; -- 2 * DATA_WIDTH;
			CHANNEL_COUNT           : integer range 0 to 32 := CHANNEL_COUNT;

			ENABLE_PIXEL_BUFFER_MODE	: integer range 0 to 31 := ENABLE_PIXEL_BUFFER_MODE;

			INITIAL_DELAY_SELECTOR_WIDTH : integer range 0 to 32 := BUFFER_CSR_DELAY_SELECTOR_WIDTH;

			CONFIG_ADDR_WIDTH       : integer range 0 to 32 := AG_CONFIG_ADDR_WIDTH;
			CONFIG_DATA_WIDTH       : integer range 0 to 32 := AG_CONFIG_DATA_WIDTH
		);
		port(
			clk                 : in  std_logic;
			reset               : in  std_logic;
			gc_reset            : in  std_logic;
			config_clk          : in  std_logic;
			config_rst          : in  std_logic;
			config_en           : in  std_logic;
			config_we           : in  std_logic;
			config_data         : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
			config_wr_addr      : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
			start               : in  std_logic;
			index_vector        : in  std_logic_vector(INDEX_VECTOR_DIMENSION * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
			channels_en         : out std_logic_vector(CHANNEL_COUNT - 1 downto 0);
			channels_addr       : out std_logic_vector(CHANNEL_COUNT * CHANNEL_ADDR_WIDTH - 1 downto 0);
			AG_out_addr         : out std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0);
			AG_en               : in  std_logic;
			AG_out_en           : out std_logic;
			AG_buffer_interrupt : out std_logic
		);
	end component AG_MATRIX_Pipelined;

	component RBuffer is
		generic(
			--###########################################################################
			-- Reconfigurable Buffer parameters
			--###########################################################################
			BUFFER_SIZE                           : integer               := 4096;
			BUFFER_SIZE_ADDR_WIDTH                : integer               := 12;
			BUFFER_CHANNEL_SIZE                   : integer               := 1024;
			BUFFER_CHANNEL_ADDR_WIDTH             : integer               := 10;
		        BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := TRUE;
		        EN_ELASTIC_BUFFER                     : boolean               := FALSE;
	
			-- Pixel Buffer Mode Architecture
			ENABLE_PIXEL_BUFFER_MODE	      : integer range 0 to 31 := 1;
	
			-- RAMs Parameters
			ADDR_WIDTH                            : integer range 0 to 32 := 18; -- Please do not change
			DATA_WIDTH                            : integer range 0 to 32 := 32;
			ADDR_HEADER_WIDTH                     : integer range 0 to 54 := 8; -- = ADDR_WIDTH - 10; -- Sice we are using 32x1kbits RAMs
			SEL_REG_WIDTH                         : integer range 0 to 8  := 4; -- = log2(ADDR_HEADER_WIDTH)
			-- Channel Count
			MAX_CHANNEL_CNT                       : integer               := 4;
			-- Configurations Parameters
			CONFIG_ADDR_WIDTH                     : integer range 0 to 32 := 8;
			CONFIG_DATA_WIDTH                     : integer range 0 to 32 := 8;
			
			-- CSR Delay
			CSR_DELAY_SELECTOR_WIDTH              : integer range 0 to 32 := 6 -- We fixed the delay selector to max 2**5 depth
			--###########################################################################		
		);
		port(
			bus_clk                 : in  std_logic;
			bus_rst                 : in  std_logic;
			AG_clk                  : in  std_logic;
			AG_rst                  : in  std_logic;

			start                   : in  std_logic;

			channel_bus_input_en     : in  std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
			channel_bus_input_we     : in  std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
			channel_bus_input_addr   : in  std_logic_vector(ADDR_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
			channel_bus_input_data   : in  std_logic_vector(DATA_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
			channel_bus_output_data  : out std_logic_vector(DATA_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);

			channel_tcpa_input_data  : in  std_logic_vector(DATA_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
			channel_tcpa_output_data : out std_logic_vector(DATA_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);

			channel_AG_input_en      : in  std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
			channel_AG_input_addr    : in  std_logic_vector(ADDR_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
			channel_AG_output_en     : in  std_logic;
			channel_AG_output_addr   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			
			buffer_addr_lsb          : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			channels_irq             : out std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
			irq_clear                : in std_logic;
			buffer_event             : out std_logic;

			config_clk               : in  std_logic;
			config_rst               : in  std_logic;
			config_en                : in  std_logic;
			config_we                : in  std_logic;
			config_wr_addr           : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
			config_data              : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
			config_start             : in  std_logic;
			config_done              : out std_logic
		);
	end component RBuffer;

	component ahb_slave_rbuffer is
		generic(
			BUFFER_SIZE              : integer               := BUFFER_SIZE;
			BUFFER_CHANNEL_SIZE      : integer               := BUFFER_CHANNEL_SIZE;
	        	CONFIG_SIZE              : integer               := AG_BUFFER_CONFIG_SIZE; 
			CONFIG_DATA_WIDTH        : integer range 0 to 32 := CONFIG_DATA_WIDTH;
			CONFIG_ADDR_WIDTH        : integer range 0 to 32 := CONFIG_ADDR_WIDTH;

			CHANNEL_COUNT            : integer range 0 to 32 := CHANNEL_COUNT;
			CHANNEL_DATA_WIDTH       : integer range 0 to 32 := CHANNEL_DATA_WIDTH;
			CHANNEL_ADDR_WIDTH       : integer range 0 to 64 := CHANNEL_ADDR_WIDTH; -- 2 * INDEX_VECTOR_DATA_WIDTH;

			NUM_OF_BUFFER_STRUCTURES : positive range 1 to 8 := NUM_OF_BUFFER_STRUCTURES;
			MAX_DATA_WIDTH           : integer range 0 to 32 := MAX_DATA_WIDTH; -- max(CONFIG_DATA_WIDTH,CHANNEL_DATA_WIDTH

			hindex                   : integer               := hindex;
			hirq                     : integer               := hirq;
			-- haddr                    : integer               := haddr;
			-- hmask                    : integer               := hmask
            SUM_COMPONENT            : integer
		);
		port(
			-- AHB Bus Interface
			ahb_clk                : in  std_ulogic;
			ahb_rstn               : in  std_ulogic;
			-- ahbsi                    : in  ahb_slv_in_type;
			-- ahbso                    : out ahb_slv_out_type
            IF_COMP_data             : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
            rbuffer_IF_data          : out rec_COMP_IF;   

			-- Configuration Write port
			config_clk             : out std_logic;
			config_rst             : out std_logic;
			config_en              : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
			config_we              : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
			config_data            : out std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_DATA_WIDTH) - 1 downto 0);
			config_wr_addr         : out std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_ADDR_WIDTH) - 1 downto 0);
			config_wr_data_out     : in  std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_DATA_WIDTH) - 1 downto 0);

			-- Configuration state
			config_start           : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
			config_soft_rst        : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
			config_done            : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
			AG_buffer_interrupt    : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
			buffer_addr_lsb        : out std_logic_vector(CHANNEL_ADDR_WIDTH-1 downto 0);
			restart_ext            : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);

			-- Glocal Controller
			gc_reset               : in  std_logic;

			-- Buffer Channel Interface
			cpu_tcpa_buffer         : in cpu_tcpa_buffer_type;
			channel_bus_clk         : out std_logic;
			channel_bus_rst         : out std_logic;
			channel_bus_input_en    : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT - 1 downto 0);
			channel_bus_input_we    : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT - 1 downto 0);
			channel_bus_input_addr  : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_ADDR_WIDTH * CHANNEL_COUNT - 1 downto 0);
			channel_bus_input_data  : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
			channel_bus_output_data : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0)
		);
	end component;

---------------------------------- End Components -----------------------------

signal config_done_tmp : std_logic;
begin
--	--config_done <= config_done_i;
--	process (ahb_clk, ahb_rstn, config_done_vector, restart_ext_vector)
--		variable restart_ext_tmp : std_logic;
--	begin
--		if(ahb_rstn = '0') then
--			config_done_tmp <= '1';
--			restart_ext_tmp := '0';
--		elsif (ahb_clk'event and ahb_clk = '1') then
--			for i in 0 to NUM_OF_BUFFER_STRUCTURES-1 loop
--				config_done_tmp <= config_done_tmp and config_done_vector(i);
--				restart_ext_tmp := restart_ext_tmp or restart_ext_vector(i);
--			end loop;
--		end if;
--		config_done <= config_done_tmp;
--		restart_ext <= restart_ext_tmp;
--	end process;

	config_done <= '1' when (not(config_done_vector = (NUM_OF_BUFFER_STRUCTURES -1 downto 0 => '0'))) else '0';
	restart_ext <= restart_ext_vector(0) and restart_ext_vector(1) and restart_ext_vector(2) and restart_ext_vector(3);

	AHB_Slave_Inst : ahb_slave_rbuffer
		generic map(
			BUFFER_SIZE              => BUFFER_SIZE,
			BUFFER_CHANNEL_SIZE      => BUFFER_CHANNEL_SIZE,
	        	CONFIG_SIZE              => AG_BUFFER_CONFIG_SIZE,
			CONFIG_DATA_WIDTH        => CONFIG_DATA_WIDTH,
			CONFIG_ADDR_WIDTH        => CONFIG_ADDR_WIDTH,
			CHANNEL_COUNT            => CHANNEL_COUNT,
			CHANNEL_DATA_WIDTH       => CHANNEL_DATA_WIDTH,
			CHANNEL_ADDR_WIDTH       => CHANNEL_ADDR_WIDTH,
			NUM_OF_BUFFER_STRUCTURES => NUM_OF_BUFFER_STRUCTURES,
			MAX_DATA_WIDTH           => MAX_DATA_WIDTH, -- max(CONFIG_DATA_WIDTH,CHANNEL_DATA_WIDTH

			hindex                   => hindex,
			hirq                     => hirq,
			-- haddr                    => haddr,
			-- hmask                    => hmask
            SUM_COMPONENT            => SUM_COMPONENT
		)
		port map(
			-- AHB Bus Interface
			ahb_clk                => ahb_clk,
			ahb_rstn               => ahb_rstn,
			-- ahbsi                  => ahbsi,
			-- ahbso                  => ahbso,
            IF_COMP_data           => IF_COMP_data,
            rbuffer_IF_data        => AG_IF_data,                        
            
            
            
			-- Configuration Write port
			config_clk             => config_clk_i,
			config_rst             => config_rst_i,
			config_en              => config_en,         --config_en_i,
			config_we              => config_we,
			config_data            => config_data_i,
			config_wr_addr         => config_wr_addr_i,
			config_wr_data_out     => config_wr_data_out_i,
			config_start           => config_start,  
			config_soft_rst        => config_soft_rst,
			config_done            => config_done_vector,
			buffer_addr_lsb        => buffer_addr_lsb_i,
			AG_buffer_interrupt    => AG_buffer_interrupt_i,
			
			restart_ext            => restart_ext_vector,
			gc_reset               => gc_reset,

			-- Buffer Channel Interface
			cpu_tcpa_buffer        => cpu_tcpa_buffer,
			channel_bus_clk        => channel_bus_clk_i,
			channel_bus_rst        => channel_bus_rst_i,
			channel_bus_input_en    => channel_bus_input_en_i,
			channel_bus_input_we    => channel_bus_input_we_i,
			channel_bus_input_addr  => channel_bus_input_addr_i,
			channel_bus_input_data  => channel_bus_input_data_i,
			channel_bus_output_data => channel_bus_output_data_i
		);

	BUFFER_STRUCTURE_GEN :  for i in 0 to NUM_OF_BUFFER_STRUCTURES - 1 generate	
		Configurator_Inst : component AG_Configurator
			generic map(
				CONFIG_DATA_WIDTH        => CONFIG_DATA_WIDTH,
				CONFIG_ADDR_WIDTH        => CONFIG_ADDR_WIDTH,
				AG_CONFIG_ADDR_WIDTH     => AG_CONFIG_ADDR_WIDTH,
				AG_CONFIG_DATA_WIDTH     => AG_CONFIG_DATA_WIDTH,
				AG_BUFFER_CONFIG_SIZE    => AG_BUFFER_CONFIG_SIZE,
				BUFFER_CONFIG_ADDR_WIDTH => BUFFER_CONFIG_ADDR_WIDTH,
				BUFFER_CONFIG_DATA_WIDTH => BUFFER_CONFIG_DATA_WIDTH
			)
			port map(
				config_clk            => config_clk_i,
				config_rst            => config_rst_i,
				config_en             => config_en(i),
				config_we             => config_we(i),       --(i),
				config_data           => config_data_i(((i+1)*CONFIG_DATA_WIDTH)-1 downto i*CONFIG_DATA_WIDTH),
				config_wr_addr        => config_wr_addr_i(((i+1)*CONFIG_ADDR_WIDTH)-1 downto i*CONFIG_ADDR_WIDTH),
				config_wr_data_out    => config_wr_data_out_i(((i+1)*CONFIG_DATA_WIDTH)-1 downto i*CONFIG_DATA_WIDTH),
				config_start          => config_start(i),     --(i),
				config_soft_rst       => config_soft_rst(i), --(i),
				config_done           => config_done_vector(i),
				AG_config_clk         => AG_config_clk(i),
				AG_config_rst         => AG_config_rst(i),
				AG_config_en          => AG_config_en(i),
				AG_config_we          => AG_config_we(i),
				AG_config_data        => AG_config_data_i(((i+1)*AG_CONFIG_DATA_WIDTH)-1 downto i*AG_CONFIG_DATA_WIDTH),
				AG_config_wr_addr     => AG_config_wr_addr_i(((i+1)*AG_CONFIG_ADDR_WIDTH)-1 downto i*AG_CONFIG_ADDR_WIDTH),
				BUFFER_config_clk     => BUFFER_config_clk(i),
				BUFFER_config_rst     => BUFFER_config_rst(i),
				BUFFER_config_start   => BUFFER_config_start(i),
				BUFFER_config_done    => BUFFER_config_done(i),
				BUFFER_config_en      => BUFFER_config_en(i),
				BUFFER_config_we      => BUFFER_config_we(i),
				BUFFER_config_data    => BUFFER_config_data_i(((i+1)*BUFFER_CONFIG_DATA_WIDTH)-1 downto i*BUFFER_CONFIG_DATA_WIDTH),
				BUFFER_config_wr_addr => BUFFER_config_wr_addr_i(((i+1)*BUFFER_CONFIG_ADDR_WIDTH)-1 downto i*BUFFER_CONFIG_ADDR_WIDTH)
			);
	
		AG_Inst : component AG_MATRIX_Pipelined
			generic map(
				DESIGN_TYPE             => DESIGN_TYPE,
				ENABLE_PIXEL_BUFFER_MODE=> ENABLE_PIXEL_BUFFER_MODE,
				CONFIG_SIZE             => AG_BUFFER_CONFIG_SIZE,
				INDEX_VECTOR_DIMENSION  => INDEX_VECTOR_DIMENSION,
				INDEX_VECTOR_DATA_WIDTH => INDEX_VECTOR_DATA_WIDTH,
				MATRIX_PIPELINE_DEPTH    => MATRIX_PIPELINE_DEPTH,
				CHANNEL_ADDR_WIDTH      => CHANNEL_ADDR_WIDTH,
				CHANNEL_COUNT           => CHANNEL_COUNT,
				CONFIG_ADDR_WIDTH       => AG_CONFIG_ADDR_WIDTH,
				CONFIG_DATA_WIDTH       => AG_CONFIG_DATA_WIDTH
			)
			port map(
				clk                 => clk,
				reset               => reset,
				gc_reset            => gc_reset,
				config_rst          => AG_config_rst(i),
				config_clk          => AG_config_clk(i),
				config_en           => AG_config_en(i),
				config_we           => AG_config_we(i),
				config_data         => AG_config_data_i(((i+1)*AG_CONFIG_DATA_WIDTH) - 1 downto i*AG_CONFIG_DATA_WIDTH),
				config_wr_addr      => AG_config_wr_addr_i(((i+1)*AG_CONFIG_ADDR_WIDTH)-1 downto i*AG_CONFIG_ADDR_WIDTH),
				start               => start,
				index_vector        => index_vector,
				channels_en         => channels_en_i(((i+1)*CHANNEL_COUNT)-1 downto i*CHANNEL_COUNT),
				channels_addr       => channels_addr_i(((i+1)*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH)-1 downto i*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH),

				AG_out_addr         => AG_out_addr_i(((i+1)*CHANNEL_ADDR_WIDTH)-1 downto i*CHANNEL_ADDR_WIDTH),
				AG_en               => AG_en,
				AG_out_en           => AG_out_en_i(i),
				AG_buffer_interrupt => AG_buffer_interrupt_i(i)
			);
	
		RBuffer_Inst : component RBuffer
			generic map(
			        BUFFER_SIZE                           => BUFFER_SIZE,
				BUFFER_SIZE_ADDR_WIDTH                => BUFFER_SIZE_ADDR_WIDTH,
				BUFFER_CHANNEL_SIZE                   => BUFFER_CHANNEL_SIZE,
				BUFFER_CHANNEL_ADDR_WIDTH             => BUFFER_CHANNEL_ADDR_WIDTH,
				BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
				EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER,
				ENABLE_PIXEL_BUFFER_MODE              => ENABLE_PIXEL_BUFFER_MODE,
				ADDR_WIDTH                            => CHANNEL_ADDR_WIDTH,
				DATA_WIDTH                            => CHANNEL_DATA_WIDTH,
				ADDR_HEADER_WIDTH                     => BUFFER_ADDR_HEADER_WIDTH,
				SEL_REG_WIDTH                         => BUFFER_SEL_REG_WIDTH,
				MAX_CHANNEL_CNT                       => CHANNEL_COUNT,
				CONFIG_ADDR_WIDTH                     => BUFFER_CONFIG_ADDR_WIDTH,
				CONFIG_DATA_WIDTH                     => BUFFER_CONFIG_DATA_WIDTH,
				CSR_DELAY_SELECTOR_WIDTH              => BUFFER_CSR_DELAY_SELECTOR_WIDTH
			)
			port map(
				bus_clk                  => channel_bus_clk_i,
				AG_clk                   => clk,
				bus_rst                  => channel_bus_rst_i,
				AG_rst                   => reset,
				start                    => start,
				channel_bus_input_en     => channel_bus_input_en_i((i+1)*CHANNEL_COUNT-1 downto i*CHANNEL_COUNT),
				channel_bus_input_we     => channel_bus_input_we_i((i+1)*CHANNEL_COUNT-1 downto i*CHANNEL_COUNT),
				channel_bus_input_addr   => channel_bus_input_addr_i(((i+1)*CHANNEL_ADDR_WIDTH*CHANNEL_COUNT)-1 downto i*CHANNEL_ADDR_WIDTH*CHANNEL_COUNT),
				channel_bus_input_data   => channel_bus_input_data_i(((i+1)*CHANNEL_DATA_WIDTH*CHANNEL_COUNT)-1 downto i*CHANNEL_DATA_WIDTH*CHANNEL_COUNT),
				channel_bus_output_data  => channel_bus_output_data_i(((i+1)*CHANNEL_DATA_WIDTH*CHANNEL_COUNT)-1 downto i*CHANNEL_DATA_WIDTH*CHANNEL_COUNT),
				channel_tcpa_input_data  => channel_tcpa_input_data((((i+1)*(CHANNEL_DATA_WIDTH*CHANNEL_COUNT))-1) downto (i*CHANNEL_DATA_WIDTH*CHANNEL_COUNT)),
				channel_tcpa_output_data => channel_tcpa_output_data((((i+1)*(CHANNEL_DATA_WIDTH * CHANNEL_COUNT))-1) downto (i*CHANNEL_DATA_WIDTH*CHANNEL_COUNT)),
				channel_AG_input_en      => channels_en_i(((i+1)*CHANNEL_COUNT)-1 downto i*CHANNEL_COUNT),
				channel_AG_input_addr    => channels_addr_i(((i+1)*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH)-1 downto i*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH),
				channel_AG_output_en     => AG_out_en_i(i),
				channel_AG_output_addr   => AG_out_addr_i(((i+1)*CHANNEL_ADDR_WIDTH)-1 downto i*CHANNEL_ADDR_WIDTH),
				buffer_addr_lsb          => buffer_addr_lsb_i,
				channels_irq             => buffers_irq((i+1)* CHANNEL_COUNT -1 downto i*CHANNEL_COUNT),
				irq_clear                => irq_clear, 
				buffer_event             => buffer_event(i),
				config_clk               => BUFFER_config_clk(i),
				config_rst               => BUFFER_config_rst(i),
				config_en                => BUFFER_config_en(i),
				config_we                => BUFFER_config_we(i),
				config_wr_addr           => BUFFER_config_wr_addr_i(((i+1)*BUFFER_CONFIG_ADDR_WIDTH-1) downto i*BUFFER_CONFIG_ADDR_WIDTH),
				config_data              => BUFFER_config_data_i(((i+1)*BUFFER_CONFIG_DATA_WIDTH)-1 downto i*BUFFER_CONFIG_DATA_WIDTH),
				config_start             => BUFFER_config_start(i),
				config_done              => BUFFER_config_done(i)
			);
			
	end generate BUFFER_STRUCTURE_GEN;	
	--buffer_interrupts <= (others=>'0'); --buffer_interrupts_i;
	AG_out_addr_out   <= (others=>'0'); --AG_out_addr_i;
	AG_out_en_out     <= AG_out_en_i(0);

	AG_buffer_interrupt <= AG_buffer_interrupt_i;

end Behavioral;

