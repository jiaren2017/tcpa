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
-- Company:        Informatik 12 - Universität erlangen-nürnberg
-- Engineer:       Jupiter BAKAKEU and Ericles Sousa
-- 
-- Create Date:    12:08:45 06/30/2014 
-- Design Name:    Configurable Shifft Register (CSR)
-- Module Name:    ReconfigurableBuffer - Behavioral 
-- Project Name: 	 Masterarbeit Jupiter Bakakeu
-- Target Devices: Virtex 5
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
use IEEE.NUMERIC_STD.ALL;
library work;
use work.AG_BUFFER_type_lib.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RBuffer is
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
		AG_clk                  : in  std_logic;
		bus_rst                 : in  std_logic;
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
		config_done              : out  std_logic
	);
end RBuffer;

architecture Behavioral of RBuffer is
	---------------------------------- Constant    ------------------------------------	
	-- Configurable Shift Register
	constant CSR_DATA_WIDTH : integer range 0 to 32 := ADDR_WIDTH + 1;
	---------------------------------- End Constant    --------------------------------

	---------------------------------- Type    ------------------------------------
	type b_en_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC;
	type b_addr_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
	type b_data_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	type b_second_data_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	type b_config_addr_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC_VECTOR(ADDR_HEADER_WIDTH - 1 DOWNTO 0);
	type b_sel_reg_width_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC_VECTOR(SEL_REG_WIDTH - 1 DOWNTO 0);
	type b_use_second_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC;
	type b_csr_data_width_t is array (MAX_CHANNEL_CNT - 2 downto 0) of STD_LOGIC_VECTOR(CSR_DATA_WIDTH - 1 DOWNTO 0);
	type b_csr_selector_width_t is array (MAX_CHANNEL_CNT - 2 downto 0) of STD_LOGIC_VECTOR(CSR_DELAY_SELECTOR_WIDTH - 1 DOWNTO 0);
	type b_csr_selector_width_ut is array (MAX_CHANNEL_CNT - 2 downto 0) of unsigned(CSR_DELAY_SELECTOR_WIDTH - 1 DOWNTO 0);
	type b_output_selector_array_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC_VECTOR(MAX_CHANNEL_CNT - 1 downto 0);
	type b_irq_channel_depth_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC_VECTOR(CONFIG_DATA_WIDTH - 1 downto 0);
	type b_irq_channel_en_t is array (MAX_CHANNEL_CNT - 1 downto 0) of STD_LOGIC;
	---------------------------------- End Type    --------------------------------

	---------------------------------- Signals ------------------------------------
	signal tmp_second_ena, sig_tmp_second_ena  : b_en_t := (others => '0');
	signal channel_ena    : b_en_t := (others => '0');
	signal channel_wea    : b_en_t := (others => '0');
	signal channel_enb    : b_en_t := (others => '0');

	signal tmp_second_addra, sig_tmp_second_addra : b_addr_t := (others => (others => '0'));
	signal channel_addra    : b_addr_t := (others => (others => '0'));
	signal channel_addrb    : b_addr_t := (others => (others => '0'));

	signal tmp_second_dina : b_second_data_t := (others => (others => '0'));

	signal channel_dina  : b_data_t := (others => (others => '0'));
	signal channel_dinb  : b_data_t := (others => (others => '0'));
	signal channel_douta : b_data_t := (others => (others => '0'));
	signal channel_doutb : b_data_t := (others => (others => '0'));

	signal config_addr_match_a : b_config_addr_t := (others => (others => '0'));
	signal config_addr_match_b : b_config_addr_t := (others => (others => '0'));

	signal config_width_sel_a : b_sel_reg_width_t := (others => (others => '0'));
	signal config_width_sel_b : b_sel_reg_width_t := (others => (others => '0'));

	signal config_use_second_a : b_use_second_t := (others => '0');

	signal CSR_data_input  : b_csr_data_width_t := (others => (others => '0'));
	signal CSR_data_output : b_csr_data_width_t := (others => (others => '0'));

	signal config_CSR_selector          : b_csr_selector_width_t  := (others => (others => '0'));
	signal modified_config_CSR_selector : b_csr_selector_width_ut := (others => (others => '0'));

	signal out_selector_value_a         : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0)              := (others => '0');
	signal out_selector_value_b         : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0)              := (others => '0');
	signal delayed_out_selector_value_a : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0)              := (others => '0');
	signal delayed_out_selector_value_b : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0)              := (others => '0');
	signal out_selector_en_a            : b_output_selector_array_t                                   := (others => (others => '0'));
	signal out_selector_en_b            : b_output_selector_array_t                                   := (others => (others => '0'));
	signal out_selector_input_data_a    : std_logic_vector(MAX_CHANNEL_CNT * DATA_WIDTH - 1 downto 0) := (others => '0');
	signal out_selector_input_data_b    : std_logic_vector(MAX_CHANNEL_CNT * DATA_WIDTH - 1 downto 0) := (others => '0');

	signal tmp_config_addr_match_a   : std_logic_vector(MAX_CHANNEL_CNT * ADDR_HEADER_WIDTH - 1 downto 0);
	signal tmp_config_addr_match_b   : std_logic_vector(MAX_CHANNEL_CNT * ADDR_HEADER_WIDTH - 1 downto 0);
	signal tmp_config_width_sel_a    : std_logic_vector(SEL_REG_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_width_sel_b    : std_logic_vector(SEL_REG_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_use_second_a   : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_CSR_selector   : std_logic_vector((MAX_CHANNEL_CNT - 1) * CSR_DELAY_SELECTOR_WIDTH - 1 downto 0);
	signal tmp_config_use_CSR        : std_logic_vector(MAX_CHANNEL_CNT - 2 downto 0);
	signal tmp_config_channel_dir    : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_out_selector_a : std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_out_selector_b : std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_concatenated_channels_b  : std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_irq_channel_depth : std_logic_vector(MAX_CHANNEL_CNT * CONFIG_DATA_WIDTH - 1 downto 0);
	signal tmp_config_irq_channel_en    : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_channel_irq           : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_channel_ena           : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_channel_wea           : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_channel_enb           : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_channel_web           : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_channel_addra : std_logic_vector(MAX_CHANNEL_CNT * ADDR_WIDTH - 1 downto 0);  
	signal tmp_channel_addrb : std_logic_vector(MAX_CHANNEL_CNT * ADDR_WIDTH - 1 downto 0);  
	---------------------------------- End Signals --------------------------------

	---------------------------------- Components ---------------------------------
	component BRAM_Wrapper is
		generic(
		        BUFFER_SIZE                           : integer               := 4096;
			BUFFER_SIZE_ADDR_WIDTH                : integer               := 12;
			BUFFER_CHANNEL_SIZE                   : integer               := 1024;
			BUFFER_CHANNEL_ADDR_WIDTH             : integer               := 10;
	                BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := TRUE;
	                EN_ELASTIC_BUFFER                     : boolean               := FALSE;
			DATA_WIDTH                            : integer range 0 to 32 := 32;
			ADDR_WIDTH                            : integer range 0 to 32 := 18;
			ADDR_HEADER_WIDTH                     : integer range 0 to 32 := 8;
			SEL_REG_WIDTH                         : integer range 0 to 8  := 3
		);
		port(
			rst                           : IN  STD_LOGIC;
			-- Port A
			clka                          : IN  STD_LOGIC;
			ena                           : in  std_logic;
			wea                           : in  std_logic;
			addra                         : IN  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
			dina                          : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
			douta                         : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
			second_clka                   : IN  STD_LOGIC;
			second_ena                    : in  std_logic;
			second_addra                  : IN  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
			second_dina                   : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
			config_header_addr_to_match_a : in  std_logic_vector(ADDR_HEADER_WIDTH - 1 downto 0);
			config_width_sel_a            : in  std_logic_vector(SEL_REG_WIDTH - 1 downto 0);
			config_use_second_a           : in  std_logic;

			-- Port B
			clkb                          : IN  STD_LOGIC;
			enb                           : in  std_logic;
			addrb                         : IN  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
			dinb                          : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
			doutb                         : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
			config_header_addr_to_match_b : in  std_logic_vector(ADDR_HEADER_WIDTH - 1 downto 0);
			config_width_sel_b            : in  std_logic_vector(SEL_REG_WIDTH - 1 downto 0);

			buffer_addr_lsb               : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			-- Direction
			buffer_direction              : in  std_logic; -- '1' == Data flows from portA to portB and in the inverse direction if set to '0'
			filtered_en_out_a             : out std_logic := '0';
			filtered_en_out_b             : out std_logic := '0'
		);
	end component;

	COMPONENT CSR is
		generic(
			DELAY_SELECTOR_WIDTH : integer range 0 to 32 := CSR_DELAY_SELECTOR_WIDTH;
			DATA_WIDTH           : integer range 0 to 32 := CSR_DATA_WIDTH
		);
		port(
			clk         : in  std_logic;
			rst         : in  std_logic;
			selector    : in  std_logic_vector(DELAY_SELECTOR_WIDTH - 1 downto 0);
			data_input  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			data_output : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	END COMPONENT;

	COMPONENT RBuffer_Configurator is
		generic(
			ADDR_HEADER_WIDTH        : integer range 0 to 54 := ADDR_HEADER_WIDTH;
			SEL_REG_WIDTH            : integer range 0 to 8  := SEL_REG_WIDTH;
			MAX_CHANNEL_CNT          : integer range 0 to 32 := MAX_CHANNEL_CNT;
			CSR_DELAY_SELECTOR_WIDTH : integer range 0 to 32 := CSR_DELAY_SELECTOR_WIDTH;
			CONFIG_ADDR_WIDTH        : integer range 0 to 32 := CONFIG_ADDR_WIDTH;
			CONFIG_DATA_WIDTH        : integer range 0 to 32 := CONFIG_DATA_WIDTH
		);
		port(
			config_clk          : in  std_logic;
			config_rst          : in  std_logic;
			config_en           : in  std_logic;
			config_we           : in  std_logic;
			config_wr_addr      : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
			config_data         : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
			config_start        : in  std_logic;
			
			config_done         : out  std_logic;
			config_addr_match_a : out std_logic_vector(MAX_CHANNEL_CNT * ADDR_HEADER_WIDTH - 1 downto 0);
			config_addr_match_b : out std_logic_vector(MAX_CHANNEL_CNT * ADDR_HEADER_WIDTH - 1 downto 0);
			config_width_sel_a  : out std_logic_vector(SEL_REG_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
			config_width_sel_b  : out std_logic_vector(SEL_REG_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
			config_use_second_a : out std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
			config_CSR_selector : out std_logic_vector((MAX_CHANNEL_CNT - 1) * CSR_DELAY_SELECTOR_WIDTH - 1 downto 0);
			config_use_CSR 		: out std_logic_vector(MAX_CHANNEL_CNT - 2 downto 0);
			config_channel_dir  : out std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
			config_out_selector_a  : out std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0);
			config_out_selector_b  : out std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0);
			config_irq_channel_depth : out std_logic_vector(MAX_CHANNEL_CNT * CONFIG_DATA_WIDTH - 1 downto 0);
			config_irq_channel_en    : out std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
			config_concatenated_channels_b  : out std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0)
		);
	end component RBuffer_Configurator;

	component OutputSelector is
		generic(
			SEL_WIDTH  : integer range 0 to 32 := MAX_CHANNEL_CNT;
			DATA_WIDTH : integer range 0 to 32 := DATA_WIDTH
		);
		port(
			select_en    : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			select_value : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			data_input   : in  std_logic_vector(SEL_WIDTH * DATA_WIDTH - 1 downto 0);
			data_output  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	end component;
	
	component InputSelector is
		generic(
			SEL_WIDTH  : integer range 0 to 32 := MAX_CHANNEL_CNT;
			DATA_WIDTH : integer range 0 to 32 := DATA_WIDTH
		);
		port(
			select_en    : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			data_input   : in  std_logic_vector(SEL_WIDTH * DATA_WIDTH - 1 downto 0);
			data_output  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	end component;

	component interrupt_generator is
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
		ADDR_WIDTH                            : integer range 0 to 32 := 18;
		DATA_WIDTH                            : integer range 0 to 32 := 32;
		CONFIG_DATA_WIDTH                     : integer range 0 to 32 := 32;
		ADDR_HEADER_WIDTH                     : integer range 0 to 54 := 8; 
		SEL_REG_WIDTH                         : integer range 0 to 8  := 4;
		-- Channel Count
		MAX_CHANNEL_CNT                       : integer               := 4
		--###########################################################################		
	);
	port(
		rst               : in std_logic; 
		start             : in  std_logic;
		buffer_direction  : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		irq_channel_depth : in std_logic_vector(MAX_CHANNEL_CNT * CONFIG_DATA_WIDTH -1 downto 0);
		irq_channel_en    : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		irq_clear         : in std_logic;
		buffer_event      : out std_logic;

		-- Port A -- Always connected to Bus side
		clka              : in std_logic;
		ena               : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		wea               : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		addra             : in std_logic_vector(ADDR_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);

		-- Port B -- Always connected to TCPA side
		clkb              : in std_logic;
		enb               : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		web               : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		addrb             : in std_logic_vector(ADDR_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
		irq_out           : out std_logic_vector(MAX_CHANNEL_CNT -1 downto 0)
	);
	end component;

begin
	GENERATE_CONFIG_SIGNALS : FOR i in 0 to MAX_CHANNEL_CNT - 1 GENERATE
		config_addr_match_a(i) <= tmp_config_addr_match_a(ADDR_HEADER_WIDTH * (i + 1) - 1 downto ADDR_HEADER_WIDTH * (i));
		config_addr_match_b(i) <= tmp_config_addr_match_b(ADDR_HEADER_WIDTH * (i + 1) - 1 downto ADDR_HEADER_WIDTH * (i));
		config_width_sel_a(i)  <= tmp_config_width_sel_a(SEL_REG_WIDTH * (i + 1) - 1 downto SEL_REG_WIDTH * (i));
		config_width_sel_b(i)  <= tmp_config_width_sel_b(SEL_REG_WIDTH * (i + 1) - 1 downto SEL_REG_WIDTH * (i));
		config_use_second_a(i) <= tmp_config_use_second_a(i);

		not_last : if (i < MAX_CHANNEL_CNT - 1) generate
			modified_config_CSR_selector(i) <= unsigned(tmp_config_CSR_selector(CSR_DELAY_SELECTOR_WIDTH * (i + 1) - 1 downto CSR_DELAY_SELECTOR_WIDTH * (i)));
			config_CSR_selector(i)          <= std_logic_vector(modified_config_CSR_selector(i) - to_unsigned(1, CSR_DELAY_SELECTOR_WIDTH));
		end generate not_last;
	end GENERATE GENERATE_CONFIG_SIGNALS;

	RBuffer_Configurator_Instance : RBuffer_Configurator
		generic map(
			ADDR_HEADER_WIDTH        => ADDR_HEADER_WIDTH,
			SEL_REG_WIDTH            => SEL_REG_WIDTH,
			MAX_CHANNEL_CNT          => MAX_CHANNEL_CNT,
			CSR_DELAY_SELECTOR_WIDTH => CSR_DELAY_SELECTOR_WIDTH,
			CONFIG_ADDR_WIDTH        => CONFIG_ADDR_WIDTH,
			CONFIG_DATA_WIDTH        => CONFIG_DATA_WIDTH
		)
		port map(
			config_clk            => config_clk,
			config_rst            => config_rst,
			config_en             => config_en,
			config_we             => config_we,
			config_wr_addr        => config_wr_addr,
			config_data           => config_data,
			config_start          => config_start,
			
			config_done              => config_done,
			config_addr_match_a      => tmp_config_addr_match_a,
			config_addr_match_b      => tmp_config_addr_match_b,
			config_width_sel_a       => tmp_config_width_sel_a,
			config_width_sel_b       => tmp_config_width_sel_b,
			config_use_second_a      => tmp_config_use_second_a,
			config_CSR_selector      => tmp_config_CSR_selector,
			config_use_CSR           => tmp_config_use_CSR,
			config_channel_dir       => tmp_config_channel_dir,
			config_out_selector_a    => tmp_config_out_selector_a,
			config_out_selector_b    => tmp_config_out_selector_b,
			config_irq_channel_depth => tmp_config_irq_channel_depth,
			config_irq_channel_en    => tmp_config_irq_channel_en,
			config_concatenated_channels_b  => tmp_config_concatenated_channels_b
		);

	 	irq_channel_gen : interrupt_generator
	 	generic map(
	 		BUFFER_SIZE                           => BUFFER_SIZE,
	 		BUFFER_SIZE_ADDR_WIDTH                => BUFFER_SIZE_ADDR_WIDTH,
	 		BUFFER_CHANNEL_SIZE                   => BUFFER_CHANNEL_SIZE,
	 		BUFFER_CHANNEL_ADDR_WIDTH             => BUFFER_CHANNEL_ADDR_WIDTH,
	 	        BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
	 		EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER,
	 		ENABLE_PIXEL_BUFFER_MODE	      => ENABLE_PIXEL_BUFFER_MODE,
	 		ADDR_WIDTH                            => ADDR_WIDTH,
	 		ADDR_HEADER_WIDTH                     => ADDR_HEADER_WIDTH,
	 		SEL_REG_WIDTH                         => SEL_REG_WIDTH,
	 		MAX_CHANNEL_CNT			      => MAX_CHANNEL_CNT,
	 		CONFIG_DATA_WIDTH                     => CONFIG_DATA_WIDTH,
	 		DATA_WIDTH			      => DATA_WIDTH
	 		)
	 	port map(
	 		rst             	=> bus_rst,				-- 
			start                   => start,
	 		buffer_direction 	=> tmp_config_channel_dir, 		--
	 		irq_channel_depth	=> tmp_config_irq_channel_depth,	--
	 		irq_channel_en   	=> tmp_config_irq_channel_en,		--
			irq_clear               => irq_clear,
			buffer_event            => buffer_event,
			
	 	
	 		-- Port A -- Alwayes connected to Bus
	 		clka             	=> bus_clk, 				--
	 		ena              	=> tmp_channel_ena,			-- ok, filtered_ena
	 		wea              	=> tmp_channel_wea,			-- ok, porta_we
	 		addra            	=> tmp_channel_addra,			-- ok, tmp_addr_a
	 	
	 		-- Port B -- Always connected to TCPA
	 		clkb             	=> AG_clk,				-- ok, clkb_i
	 		enb              	=> tmp_channel_enb,			-- ok, filtered_enb
	 		web              	=> tmp_channel_web,			-- ok, portb_we
	 		addrb            	=> tmp_channel_addrb,			-- ok, tmp_addr_b
	 		irq_out             	=> channels_irq 
	 	);


	-- Multiplexer above BRAM
	GENERATE_REGISTERS : FOR i in 0 to MAX_CHANNEL_CNT - 1 GENERATE
		tmp_channel_addrb((i+1)*ADDR_WIDTH - 1 downto i*ADDR_WIDTH) <= channel_addrb(i); -- ok	

		--tmp_config_channel_dir = buffer_direction.
		--Input Buffers: buffer_direction = 1, i.e., TCPA reads PORT B. 
		--Output Buffers: buffer_direction = 0, i.e., TCPA writes PORT B. 
		tmp_channel_web(i) <= '1' when tmp_config_channel_dir(i) = '0' else '0'; -- 

		tmp_channel_enb(i) <= out_selector_value_b(i);   -- ok
		tmp_channel_addra((i+1)*ADDR_WIDTH - 1 downto i*ADDR_WIDTH) <= 
		std_logic_vector((unsigned(channel_addra(i)(ADDR_WIDTH-1 downto 0))) - (unsigned(buffer_addr_lsb(ADDR_WIDTH-1 downto 0))))
		when config_use_second_a(i) = '0' else tmp_second_addra(i)(ADDR_WIDTH - 1 downto 0); -- ok
		tmp_channel_wea(i) <=  channel_wea(i) when config_use_second_a(i) = '0' else tmp_second_ena(i); --ok
		tmp_channel_ena(i) <= out_selector_value_a(i); -- ok



		channel_ena(i)   <= channel_bus_input_en(i) when bus_rst = '0' else '0';
		channel_wea(i)   <= channel_bus_input_we(i) when bus_rst = '0' else '0';
		--channel_addra(i) <= channel_bus_input_addr(ADDR_WIDTH * (i + 1) - 1 downto ADDR_WIDTH * i) when ((not bus_rst) and channel_ena(i)) = '1'  else (others => '0');
		--channel_dina(i)  <= channel_bus_input_data(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i) when ((not bus_rst) and channel_ena(i)) = '1'  else (others => '0');
		channel_addra(i) <= channel_bus_input_addr(ADDR_WIDTH * (i + 1) - 1 downto ADDR_WIDTH * i) when bus_rst = '0'  else (others => '0');
		channel_dina(i)  <= channel_bus_input_data(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i) when bus_rst = '0' else (others => '0');
		--channel_dinb(i)  <= channel_tcpa_input_data(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i);

		-- Removed because of the pixel buffer mode --> Jupiter		
		NO_PIXEL_BUFFER_MODE:if ENABLE_PIXEL_BUFFER_MODE = 0 generate
			tmp_second_ena(i)   <= channel_AG_input_en(i);
			tmp_second_addra(i) <= channel_AG_input_addr(ADDR_WIDTH * (i + 1) - 1 downto ADDR_WIDTH * i);
		end generate NO_PIXEL_BUFFER_MODE;


		--channel_bus_output_data(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i)  <= channel_douta(i);
		--channel_tcpa_output_data(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i) <= channel_doutb(i);

		out_selector_input_data_a(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i) <= channel_douta(i);
		out_selector_input_data_b(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i) <= channel_doutb(i);
		out_selector_en_a(i)                                                      <= tmp_config_out_selector_a((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT);
		--out_selector_en_b(i)                                                      <= tmp_config_out_selector_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) when (unsigned(tmp_config_concatenated_channels_b) <= MAX_CHANNEL_CNT);
		
		--Added to allow concatenation of buffer channels. This solution allows only to concatenate all buffer channels into one single output channel (PortB)
		out_selector_en_b(i)                                                      <= tmp_config_out_selector_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) when (unsigned(tmp_config_concatenated_channels_b) <= MAX_CHANNEL_CNT) else
											    --std_logic_vector(unsigned(log2_32bits(to_integer(unsigned(delayed_out_selector_value_b)))));
											    std_logic_vector(to_unsigned( log2_32bits(to_integer(unsigned(delayed_out_selector_value_b))) , MAX_CHANNEL_CNT));

		-- Delayed Output selected because reading take 1 clk cycle
		Delayed_out_selector_en_a : process(bus_clk, bus_rst) is
		begin
			if bus_rst = '1' then
				delayed_out_selector_value_a(i) <= '0';
			elsif rising_edge(bus_clk) then
				delayed_out_selector_value_a(i) <= out_selector_value_a(i);
			end if;
		end process Delayed_out_selector_en_a;

		Delayed_out_selector_en_b : process(AG_clk, AG_rst) is
		begin
			if AG_rst = '1' then
				delayed_out_selector_value_b(i) <= '0';
			elsif rising_edge(AG_clk) then
				delayed_out_selector_value_b(i) <= out_selector_value_b(i);
			end if;
		end process Delayed_out_selector_en_b;

		-- Initialize Port A Channel Selector
		PORTA_OutputSelector_Inst : OutputSelector
			generic map(
				SEL_WIDTH  => MAX_CHANNEL_CNT,
				DATA_WIDTH => DATA_WIDTH
			)
			port map(
				select_en    => out_selector_en_a(i),
				select_value => delayed_out_selector_value_a,
				data_input   => out_selector_input_data_a,
				data_output  => channel_bus_output_data(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i)
			);

		-- Initialize Port B Channel Selector
		PORTB_OutputSelector_Inst : OutputSelector
			generic map(
				SEL_WIDTH  => MAX_CHANNEL_CNT,
				DATA_WIDTH => DATA_WIDTH
			)
			port map(
				select_en    => out_selector_en_b(i),
				select_value => delayed_out_selector_value_b,
				data_input   => out_selector_input_data_b,
				data_output  => channel_tcpa_output_data(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * i)
			);
			
		-- Initialize Port B Channel Selector
		PORTB_InputSelector_Inst : InputSelector
			generic map(
				SEL_WIDTH  => MAX_CHANNEL_CNT,
				DATA_WIDTH => DATA_WIDTH
			)
			port map(
				select_en    => out_selector_en_b(i),
				data_input   => channel_tcpa_input_data,
				data_output  => channel_dinb(i)
			);

		first_ram : if (i = 0) generate
			-- BRAM Wrapper --------------------------------------------------------------
			-- Mapping  input ports
			channel_enb(i)     <= channel_AG_output_en;
			channel_addrb(i)   <= channel_AG_output_addr;
					
			tmp_second_dina(i) <= (others => '0');

			PIXEL_BUFFER_MODE:if not (ENABLE_PIXEL_BUFFER_MODE = 0) generate
				second_address_proc: process(AG_clk) is
				begin
					if rising_edge(AG_clk) then
						tmp_second_ena(i)   <= '0';
						tmp_second_addra(i) <= (others => '0');
      			 		end if;
				end process;
			end generate PIXEL_BUFFER_MODE;

			BRAM_Wapper_instance : BRAM_Wrapper
				generic map(
		                        BUFFER_SIZE                           => BUFFER_SIZE,
					BUFFER_SIZE_ADDR_WIDTH                => BUFFER_SIZE_ADDR_WIDTH,
					BUFFER_CHANNEL_SIZE                   => BUFFER_CHANNEL_SIZE,
					BUFFER_CHANNEL_ADDR_WIDTH             => BUFFER_CHANNEL_ADDR_WIDTH,
	                		BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
			                EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER,
					ADDR_WIDTH                            => ADDR_WIDTH,
					ADDR_HEADER_WIDTH                     => ADDR_HEADER_WIDTH,
					SEL_REG_WIDTH                         => SEL_REG_WIDTH
				)
				port map(
					rst                           => AG_rst, 
					-- Port A
					clka                          => bus_clk,
					ena                           => channel_ena(i),
					wea                           => channel_wea(i),
					addra                         => channel_addra(i),
					dina                          => channel_dina(i),
					douta                         => channel_douta(i),
					second_clka                   => AG_clk,
					second_ena                    => tmp_second_ena(i),
					second_addra                  => tmp_second_addra(i),
					second_dina                   => tmp_second_dina(i),
					config_header_addr_to_match_a => config_addr_match_a(i),
					config_width_sel_a            => config_width_sel_a(i),
					config_use_second_a           => config_use_second_a(i),

					-- Port B
					clkb                          => AG_clk,
					enb                           => channel_enb(i),
					addrb                         => channel_addrb(i),
					dinb                          => channel_dinb(i),
					doutb                         => channel_doutb(i),
					config_header_addr_to_match_b => config_addr_match_b(i),
					config_width_sel_b            => config_width_sel_b(i),
					
					buffer_addr_lsb               => buffer_addr_lsb,
					-- Direction
					buffer_direction              => tmp_config_channel_dir(i),
					filtered_en_out_a             => out_selector_value_a(i),
					filtered_en_out_b             => out_selector_value_b(i)
				);

			-- Configuarable Shifft register --------------------------------------------------
			-- Mapping  output ports
			CSR_data_input(i) <= channel_addrb(i) & channel_enb(i);
			CSR_internal : CSR
				generic map(
					DELAY_SELECTOR_WIDTH => CSR_DELAY_SELECTOR_WIDTH,
					DATA_WIDTH           => CSR_DATA_WIDTH
				--###########################################################################		
				)
				port map(
					clk         => AG_clk,
					rst         => AG_rst,
					selector    => config_CSR_selector(i),
					data_input  => CSR_data_input(i),
					data_output => CSR_data_output(i)
				);
		end generate first_ram;

		intermadiate_ram : if (i > 0 and i < MAX_CHANNEL_CNT - 1) generate

			-- BRAM Wrapper --------------------------------------------------------------
			-- Mapping  input ports
--			process(AG_clk, AG_rst) is
--			begin
--				if AG_rst = '1' then
--					channel_enb(i)   <= '0';
--					channel_addrb(i) <= (others => '0');
--				elsif rising_edge(AG_clk) then
--					if (tmp_config_use_CSR(i - 1) = '1') then
--						channel_enb(i)   <= CSR_data_output(i - 1)(0);
--						channel_addrb(i) <= CSR_data_output(i - 1)(CSR_DATA_WIDTH - 1 downto 1);
--					else
--						channel_enb(i)   <= channel_AG_output_en;
--						channel_addrb(i) <= channel_AG_output_addr;
--						--channel_enb(i)   <= CSR_data_input(i - 1)(0);
--						--channel_addrb(i) <= CSR_data_input(i - 1)(CSR_DATA_WIDTH - 1 downto 1);
--					end if;
--				end if;
--			end process;

			channel_enb(i)   <= channel_AG_output_en when tmp_config_use_CSR(i - 1) = '0' else CSR_data_output(i - 1)(0);
			channel_addrb(i) <= channel_AG_output_addr when tmp_config_use_CSR(i - 1) = '0' else CSR_data_output(i - 1)(CSR_DATA_WIDTH - 1 downto 1);

			PIXEL_BUFFER_MODE:if not (ENABLE_PIXEL_BUFFER_MODE = 0) generate
				second_address_proc: process(AG_clk) is
				begin
					if rising_edge(AG_clk) then
						sig_tmp_second_ena(i)   <= channel_enb(i-1);
						sig_tmp_second_addra(i)  <= channel_addrb(i-1);
						tmp_second_ena(i)   <= sig_tmp_second_ena(i);
						tmp_second_addra(i) <= sig_tmp_second_addra(i);
      			 		end if;
				end process;
			end generate PIXEL_BUFFER_MODE;
			tmp_second_dina(i) <= channel_doutb(i - 1);



			BRAM_Wapper_instance : BRAM_Wrapper
				generic map(
                                        BUFFER_SIZE                           => BUFFER_SIZE,
                                        BUFFER_SIZE_ADDR_WIDTH                => BUFFER_SIZE_ADDR_WIDTH,
                                        BUFFER_CHANNEL_SIZE                   => BUFFER_CHANNEL_SIZE,
                                        BUFFER_CHANNEL_ADDR_WIDTH             => BUFFER_CHANNEL_ADDR_WIDTH,
                                        BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
                                        EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER,
                                        ADDR_WIDTH                            => ADDR_WIDTH,
                                        ADDR_HEADER_WIDTH                     => ADDR_HEADER_WIDTH,
                                        SEL_REG_WIDTH                         => SEL_REG_WIDTH
				)
				port map(
					rst                           => AG_rst, 
					-- Port A
					clka                          => bus_clk,
					ena                           => channel_ena(i),
					wea                           => channel_wea(i),
					addra                         => channel_addra(i),
					dina                          => channel_dina(i),
					douta                         => channel_douta(i),
					second_clka                   => AG_clk,
					second_ena                    => tmp_second_ena(i),
					second_addra                  => tmp_second_addra(i),
					second_dina                   => tmp_second_dina(i),
					config_header_addr_to_match_a => config_addr_match_a(i),
					config_width_sel_a            => config_width_sel_a(i),
					config_use_second_a           => config_use_second_a(i),

					-- Port B
					clkb                          => AG_clk,
					enb                           => channel_enb(i),
					addrb                         => channel_addrb(i),
					dinb                          => channel_dinb(i),
					doutb                         => channel_doutb(i),
					config_header_addr_to_match_b => config_addr_match_b(i),
					config_width_sel_b            => config_width_sel_b(i),
					
					buffer_addr_lsb               => buffer_addr_lsb,

					-- Direction
					buffer_direction              => tmp_config_channel_dir(i),
					filtered_en_out_a             => out_selector_value_a(i),
					filtered_en_out_b             => out_selector_value_b(i)
				);

			-- Configuarable Shifft register --------------------------------------------------
			-- Mapping  output ports
			CSR_data_input(i) <= channel_addrb(i) & channel_enb(i);
			CSR_internal : CSR
				generic map(
					DELAY_SELECTOR_WIDTH => CSR_DELAY_SELECTOR_WIDTH,
					DATA_WIDTH           => CSR_DATA_WIDTH
				--###########################################################################		
				)
				port map(
					clk         => AG_clk,
					rst         => AG_rst,
					selector    => config_CSR_selector(i),
					data_input  => CSR_data_input(i),
					data_output => CSR_data_output(i)
				);

		end generate intermadiate_ram;

		last_ram : if (i = MAX_CHANNEL_CNT - 1) generate
			-- BRAM Wrapper --------------------------------------------------------------
			-- Mapping  input ports
--			process(AG_clk, AG_rst) is
--			begin
--				if AG_rst = '1' then
--					channel_enb(i)   <= '0';
--					channel_addrb(i) <= (others => '0');
--				elsif rising_edge(AG_clk) then
--					if (tmp_config_use_CSR(i - 1) = '1') then
--						channel_enb(i)   <= CSR_data_output(i - 1)(0);
--						channel_addrb(i) <= CSR_data_output(i - 1)(CSR_DATA_WIDTH - 1 downto 1);
--					else
--						channel_enb(i)   <= channel_AG_output_en;
--						channel_addrb(i) <= channel_AG_output_addr;
--						--channel_enb(i)   <= CSR_data_input(i - 1)(0);
--						--channel_addrb(i) <= CSR_data_input(i - 1)(CSR_DATA_WIDTH - 1 downto 1);
--					end if;
--				end if;
--			end process;

			channel_enb(i)   <= channel_AG_output_en when tmp_config_use_CSR(i - 1) = '0' else CSR_data_output(i - 1)(0);
			channel_addrb(i) <= channel_AG_output_addr when tmp_config_use_CSR(i - 1) = '0' else CSR_data_output(i - 1)(CSR_DATA_WIDTH - 1 downto 1);

			PIXEL_BUFFER_MODE:if not (ENABLE_PIXEL_BUFFER_MODE = 0) generate
				second_address_proc: process(AG_clk) is
				begin
					if rising_edge(AG_clk) then
						tmp_second_ena(i)   <= channel_enb(i-1);
						tmp_second_addra(i) <= channel_addrb(i-1);
      			 		end if;
				end process;
			end generate PIXEL_BUFFER_MODE;
			tmp_second_dina(i) <= channel_doutb(i - 1);

			BRAM_Wapper_instance : BRAM_Wrapper
				generic map(
                                        BUFFER_SIZE                           => BUFFER_SIZE,
                                        BUFFER_SIZE_ADDR_WIDTH                => BUFFER_SIZE_ADDR_WIDTH,
                                        BUFFER_CHANNEL_SIZE                   => BUFFER_CHANNEL_SIZE,
                                        BUFFER_CHANNEL_ADDR_WIDTH             => BUFFER_CHANNEL_ADDR_WIDTH,
                                        BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
                                        EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER,
                                        ADDR_WIDTH                            => ADDR_WIDTH,
                                        ADDR_HEADER_WIDTH                     => ADDR_HEADER_WIDTH,
                                        SEL_REG_WIDTH                         => SEL_REG_WIDTH
				)
				port map(
					rst                           => AG_rst, 
					-- Port A
					clka                          => bus_clk,
					ena                           => channel_ena(i),
					wea                           => channel_wea(i),
					addra                         => channel_addra(i),
					dina                          => channel_dina(i),
					douta                         => channel_douta(i),
					second_clka                   => AG_clk,
					second_ena                    => tmp_second_ena(i),
					second_addra                  => tmp_second_addra(i),
					second_dina                   => tmp_second_dina(i),
					config_header_addr_to_match_a => config_addr_match_a(i),
					config_width_sel_a            => config_width_sel_a(i),
					config_use_second_a           => config_use_second_a(i),

					-- Port B
					clkb                          => AG_clk,
					enb                           => channel_enb(i),
					addrb                         => channel_addrb(i),
					dinb                          => channel_dinb(i),
					doutb                         => channel_doutb(i),
					config_header_addr_to_match_b => config_addr_match_b(i),
					config_width_sel_b            => config_width_sel_b(i),
					
					buffer_addr_lsb               => buffer_addr_lsb,

					-- Direction
					buffer_direction              => tmp_config_channel_dir(i),
					filtered_en_out_a             => out_selector_value_a(i),
					filtered_en_out_b             => out_selector_value_b(i)
				);
		-- Mapping of teh ports
		end generate last_ram;

	END GENERATE;

end Behavioral;

