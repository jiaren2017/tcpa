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

entity AG_Buffer_Wrapper is
	generic(
		--###########################################################################
		-- AG_Configurator parameters, do not add to or delete
		--###########################################################################
		CONFIG_DATA_WIDTH               : integer range 0 to 32 := 32;
		CONFIG_ADDR_WIDTH               : integer range 0 to 32 := 10;

		INDEX_VECTOR_DIMENSION          : integer range 0 to 32 := 3;
		INDEX_VECTOR_DATA_WIDTH         : integer range 0 to 32 := 10;
		MATRIX_PIPELINE_DEPTH            : integer range 0 to 32 := 2; -- equals log2(INDEX_VECTOR_DIMENSION) + 1

		CHANNEL_DATA_WIDTH              : integer range 0 to 32 := 32;
		CHANNEL_ADDR_WIDTH              : integer range 0 to 64 := 20; -- 2 * INDEX_VECTOR_DATA_WIDTH;
		CHANNEL_COUNT                   : integer range 0 to 32 := 4;

		AG_CONFIG_ADDR_WIDTH            : integer range 0 to 32 := 6; -- must be computed

		INITIAL_DELAY_SELECTOR_WIDTH : integer range 0 to 15 := 6;

		BUFFER_CONFIG_ADDR_WIDTH        : integer range 0 to 10 := 4; -- must be computed
		BUFFER_CONFIG_DATA_WIDTH        : integer range 0 to 32 := 32; -- must be allways set to 32
		BUFFER_ADDR_HEADER_WIDTH        : integer range 0 to 54 := 10; -- = 2 * INDEX_VECTOR_DATA_WIDTH - 10; -- Sice we are using 32x1kbits RAMs
		BUFFER_SEL_REG_WIDTH            : integer range 0 to 8  := 4; -- = log2(ADDR_HEADER_WIDTH)
		BUFFER_CSR_DELAY_SELECTOR_WIDTH : integer range 0 to 15 := 5 -- We fixed the delay selector to max 2**3 -1 depth			
	--###########################################################################		
	);
	port(
		clk                     : in  std_logic;
		reset                   : in  std_logic;
		start                   : in  std_logic;
		-- Configuration Write port
		config_clk              : in  std_logic;
		config_rst              : in  std_logic;
		config_en               : in  std_logic;
		config_we               : in  std_logic;
		config_data             : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
		config_wr_addr          : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
		config_wr_data_out      : out std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);

		-- configuration state
		config_start            : in  std_logic;
		config_soft_rst         : in  std_logic;
		config_done             : out std_logic;

		-- AG Signals
		buffer_interrupts       : out std_logic_vector(CHANNEL_COUNT - 1 downto 0);
		index_vector            : in  std_logic_vector(INDEX_VECTOR_DIMENSION * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);

		-- Bus Signals
		channel_bus_clk         : in  std_logic;
		channel_bus_rst         : in  std_logic;
		channel_bus_input_en     : in  std_logic_vector(CHANNEL_COUNT - 1 downto 0);
		channel_bus_input_we     : in  std_logic_vector(CHANNEL_COUNT - 1 downto 0);
		channel_bus_input_addr   : in  std_logic_vector(CHANNEL_ADDR_WIDTH * CHANNEL_COUNT - 1 downto 0);
		channel_bus_input_data   : in  std_logic_vector(CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
		channel_bus_output_data  : out std_logic_vector(CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);

		-- TCPA Signals
		channel_tcpa_input_data  : in  std_logic_vector(CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
		channel_tcpa_output_data : out std_logic_vector(CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0)
	);
end AG_Buffer_Wrapper;

architecture Behavioral of AG_Buffer_Wrapper is
	CONSTANT AG_CONFIG_DATA_WIDTH : integer range 0 to 32 := INDEX_VECTOR_DATA_WIDTH;

	---------------------------------- Signals ------------------------------------
	-- AG Internal signals
	signal AG_config_clk_i     : std_logic;
	signal AG_config_rst_i     : std_logic;
	signal AG_config_en_i      : std_logic;
	signal AG_config_we_i      : std_logic;
	signal AG_config_data_i    : std_logic_vector(AG_CONFIG_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal AG_config_wr_addr_i : std_logic_vector(AG_CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');

	-- BUFFER Configurations signals
	signal BUFFER_config_clk_i     : std_logic;
	signal BUFFER_config_rst_i     : std_logic;
	signal BUFFER_config_en_i      : std_logic;
	signal BUFFER_config_we_i      : std_logic;
	signal BUFFER_config_data_i    : std_logic_vector(BUFFER_CONFIG_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal BUFFER_config_wr_addr_i : std_logic_vector(BUFFER_CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal BUFFER_config_done_i    : std_logic;
	signal BUFFER_config_start_i     : std_logic;

	-- AG Signals
	signal channels_en_i   : std_logic_vector(CHANNEL_COUNT - 1 downto 0)                      := (others => '0');
	signal channels_addr_i : std_logic_vector(CHANNEL_COUNT * CHANNEL_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal AG_out_addr_i   : std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0)                 := (others => '0');
	signal AG_out_en_i     : std_logic                                                         := '0';

	-------------------------------------------------------------------------------

	---------------------------------- Components ---------------------------------
	component AG_Configurator is
		generic(
			CONFIG_DATA_WIDTH        : integer range 0 to 32 := CONFIG_DATA_WIDTH;
			CONFIG_ADDR_WIDTH        : integer range 0 to 32 := CONFIG_ADDR_WIDTH;
			AG_CONFIG_ADDR_WIDTH     : integer range 0 to 32 := AG_CONFIG_ADDR_WIDTH;
			AG_CONFIG_DATA_WIDTH     : integer range 0 to 32 := AG_CONFIG_DATA_WIDTH;
			BUFFER_CONFIG_ADDR_WIDTH : integer range 0 to 10 := BUFFER_CONFIG_ADDR_WIDTH;
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
			BUFFER_config_done    : in std_logic;
			BUFFER_config_en      : out std_logic;
			BUFFER_config_we      : out std_logic;
			BUFFER_config_data    : out std_logic_vector(BUFFER_CONFIG_DATA_WIDTH - 1 downto 0);
			BUFFER_config_wr_addr : out std_logic_vector(BUFFER_CONFIG_ADDR_WIDTH - 1 downto 0)
		);
	end component AG_Configurator;

	component AG_MATRIX_Pipelined is
		generic(
			INDEX_VECTOR_DIMENSION  : integer range 0 to 32 := INDEX_VECTOR_DIMENSION;
			INDEX_VECTOR_DATA_WIDTH : integer range 0 to 32 := INDEX_VECTOR_DATA_WIDTH;
			MATRIX_PIPELINE_DEPTH    : integer range 0 to 32 := MATRIX_PIPELINE_DEPTH;

			CHANNEL_ADDR_WIDTH      : integer range 0 to 64 := CHANNEL_ADDR_WIDTH; -- 2 * DATA_WIDTH;
			CHANNEL_COUNT           : integer range 0 to 32 := CHANNEL_COUNT;

			INITIAL_DELAY_SELECTOR_WIDTH : integer range 0 to 15 := 6;

			CONFIG_ADDR_WIDTH       : integer range 0 to 32 := AG_CONFIG_ADDR_WIDTH;
			CONFIG_DATA_WIDTH       : integer range 0 to 32 := AG_CONFIG_DATA_WIDTH
		);
		port(
			clk               : in  std_logic;
			reset             : in  std_logic;
			config_clk        : in  std_logic;
			config_rst        : in  std_logic;
			config_en         : in  std_logic;
			config_we         : in  std_logic;
			config_data       : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
			config_wr_addr    : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
			start             : in  std_logic;
			index_vector      : in  std_logic_vector(INDEX_VECTOR_DIMENSION * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
			channels_en       : out std_logic_vector(CHANNEL_COUNT - 1 downto 0);
			channels_addr     : out std_logic_vector(CHANNEL_COUNT * CHANNEL_ADDR_WIDTH - 1 downto 0);
			AG_out_addr       : out std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0);
			AG_out_en         : out std_logic;
			buffer_interrupts : out std_logic_vector(CHANNEL_COUNT - 1 downto 0)
		);
	end component AG_MATRIX_Pipelined;

	component RBuffer is
		generic(
			-- RAMs Parameters
			ADDR_WIDTH               : integer range 0 to 32 := CHANNEL_ADDR_WIDTH; -- Please do not change
			DATA_WIDTH               : integer range 0 to 32 := CHANNEL_DATA_WIDTH;
			ADDR_HEADER_WIDTH        : integer range 0 to 54 := BUFFER_ADDR_HEADER_WIDTH; -- = ADDR_WIDTH - 10; -- Sice we are using 32x1kbits RAMs
			SEL_REG_WIDTH            : integer range 0 to 8  := BUFFER_SEL_REG_WIDTH; -- = log2(ADDR_HEADER_WIDTH)
			-- Channel Count
			MAX_CHANNEL_CNT          : integer               := CHANNEL_COUNT;
			-- Configurations Parameters
			CONFIG_ADDR_WIDTH        : integer range 0 to 10 := BUFFER_CONFIG_ADDR_WIDTH;
			CONFIG_DATA_WIDTH        : integer range 0 to 32 := BUFFER_CONFIG_DATA_WIDTH;
			-- CSR Delay
			CSR_DELAY_SELECTOR_WIDTH : integer range 0 to 15 := BUFFER_CSR_DELAY_SELECTOR_WIDTH -- We fixed the delay selector to max 2**3 depth
		--###########################################################################		
		);
		port(
			bus_clk                 : in  std_logic;
			AG_clk                  : in  std_logic;
			bus_rst                 : in  std_logic;
			AG_rst                  : in  std_logic;
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

			config_clk              : in  std_logic;
			config_rst              : in  std_logic;
			config_en               : in  std_logic;
			config_we               : in  std_logic;
			config_wr_addr          : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
			config_data             : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
			config_start            : in  std_logic;
			config_done             : out std_logic
		);
	end component RBuffer;

---------------------------------- End Components -----------------------------

begin
	Configurator_Inst : component AG_Configurator
		generic map(
			CONFIG_DATA_WIDTH        => CONFIG_DATA_WIDTH,
			CONFIG_ADDR_WIDTH        => CONFIG_ADDR_WIDTH,
			AG_CONFIG_ADDR_WIDTH     => AG_CONFIG_ADDR_WIDTH,
			AG_CONFIG_DATA_WIDTH     => AG_CONFIG_DATA_WIDTH,
			BUFFER_CONFIG_ADDR_WIDTH => BUFFER_CONFIG_ADDR_WIDTH,
			BUFFER_CONFIG_DATA_WIDTH => BUFFER_CONFIG_DATA_WIDTH
		)
		port map(
			config_clk            => config_clk,
			config_rst            => config_rst,
			config_en             => config_en,
			config_we             => config_we,
			config_data           => config_data,
			config_wr_addr        => config_wr_addr,
			config_wr_data_out    => config_wr_data_out,
			config_start          => config_start,
			config_soft_rst       => config_soft_rst,
			config_done           => config_done,
			AG_config_clk         => AG_config_clk_i,
			AG_config_rst         => AG_config_rst_i,
			AG_config_en          => AG_config_en_i,
			AG_config_we          => AG_config_we_i,
			AG_config_data        => AG_config_data_i,
			AG_config_wr_addr     => AG_config_wr_addr_i,
			BUFFER_config_clk     => BUFFER_config_clk_i,
			BUFFER_config_rst     => BUFFER_config_rst_i,
			BUFFER_config_en      => BUFFER_config_en_i,
			BUFFER_config_we      => BUFFER_config_we_i,
			BUFFER_config_data    => BUFFER_config_data_i,
			BUFFER_config_wr_addr => BUFFER_config_wr_addr_i,
			BUFFER_config_start   => BUFFER_config_start_i,
			BUFFER_config_done    => BUFFER_config_done_i
		);

	AG_Inst : component AG_MATRIX_Pipelined
		generic map(
			INDEX_VECTOR_DIMENSION  => INDEX_VECTOR_DIMENSION,
			INDEX_VECTOR_DATA_WIDTH => INDEX_VECTOR_DATA_WIDTH,
			MATRIX_PIPELINE_DEPTH    => MATRIX_PIPELINE_DEPTH,
			INITIAL_DELAY_SELECTOR_WIDTH => INITIAL_DELAY_SELECTOR_WIDTH,
			CHANNEL_ADDR_WIDTH      => CHANNEL_ADDR_WIDTH,
			CHANNEL_COUNT           => CHANNEL_COUNT,
			CONFIG_ADDR_WIDTH       => AG_CONFIG_ADDR_WIDTH,
			CONFIG_DATA_WIDTH       => AG_CONFIG_DATA_WIDTH
		)
		port map(
			clk               => clk,
			reset             => reset,
			config_rst        => AG_config_rst_i,
			config_clk        => AG_config_clk_i,
			config_en         => AG_config_en_i,
			config_we         => AG_config_we_i,
			config_data       => AG_config_data_i(AG_CONFIG_DATA_WIDTH - 1 downto 0),
			config_wr_addr    => AG_config_wr_addr_i(AG_CONFIG_ADDR_WIDTH - 1 downto 0),
			start             => start,
			index_vector      => index_vector,
			channels_en       => channels_en_i,
			channels_addr     => channels_addr_i,
			AG_out_addr       => AG_out_addr_i,
			AG_out_en         => AG_out_en_i,
			buffer_interrupts => buffer_interrupts
		);

	RBuffer_Inst : component RBuffer
		generic map(
			ADDR_WIDTH               => CHANNEL_ADDR_WIDTH,
			DATA_WIDTH               => CHANNEL_DATA_WIDTH,
			ADDR_HEADER_WIDTH        => BUFFER_ADDR_HEADER_WIDTH,
			SEL_REG_WIDTH            => BUFFER_SEL_REG_WIDTH,
			MAX_CHANNEL_CNT          => CHANNEL_COUNT,
			CONFIG_ADDR_WIDTH        => BUFFER_CONFIG_ADDR_WIDTH,
			CONFIG_DATA_WIDTH        => BUFFER_CONFIG_DATA_WIDTH,
			CSR_DELAY_SELECTOR_WIDTH => BUFFER_CSR_DELAY_SELECTOR_WIDTH
		)
		port map(
			bus_clk                 => channel_bus_clk,
			AG_clk                  => clk,
			bus_rst                 => channel_bus_rst,
			AG_rst                  => reset,
			channel_bus_input_en     => channel_bus_input_en,
			channel_bus_input_we     => channel_bus_input_we,
			channel_bus_input_addr   => channel_bus_input_addr,
			channel_bus_input_data   => channel_bus_input_data,
			channel_bus_output_data  => channel_bus_output_data,
			channel_tcpa_input_data  => channel_tcpa_input_data,
			channel_tcpa_output_data => channel_tcpa_output_data,
			channel_AG_input_en      => channels_en_i,
			channel_AG_input_addr    => channels_addr_i,
			channel_AG_output_en     => AG_out_en_i,
			channel_AG_output_addr   => AG_out_addr_i,
			config_clk              => BUFFER_config_clk_i,
			config_rst              => BUFFER_config_rst_i,
			config_en               => BUFFER_config_en_i,
			config_we               => BUFFER_config_we_i,
			config_wr_addr          => BUFFER_config_wr_addr_i(BUFFER_CONFIG_ADDR_WIDTH - 1 downto 0),
			config_data             => BUFFER_config_data_i(BUFFER_CONFIG_DATA_WIDTH - 1 downto 0),
			config_start            => BUFFER_config_start_i,
			config_done             => BUFFER_config_done_i
		);
end Behavioral;

