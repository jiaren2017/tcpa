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
-- Create Date:    13:45:07 08/11/2014 
-- Design Name: 
-- Module Name:    AG_Configurator - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AG_Configurator is
	generic(
		--###########################################################################
		-- AG_Configurator parameters, do not add to or delete
		--###########################################################################
		CONFIG_DATA_WIDTH        : integer range 0 to 32 := 32;
		CONFIG_ADDR_WIDTH        : integer range 0 to 32 := 10;

		AG_CONFIG_ADDR_WIDTH     : integer range 0 to 32 := 8; -- must be computed
		AG_CONFIG_DATA_WIDTH     : integer range 0 to 32 := 9;
		AG_BUFFER_CONFIG_SIZE    : integer               := 1024;

		BUFFER_CONFIG_ADDR_WIDTH : integer range 0 to 32 := 8;
		BUFFER_CONFIG_DATA_WIDTH : integer range 0 to 32 := 8
	--###########################################################################		
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
end AG_Configurator;

architecture Behavioral of AG_Configurator is
	---------------------------------- Types --------------------------------------
	type offset_t is array (1 downto 0) of std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
	type depth_t is array (1 downto 0) of std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);

	type state_type is (idle, configure_memory, load_offsets, load_depths, configure_BUFFER, configure_AG, ready);
	-------------------------------------------------------------------------------
	---------------------------------- Signals ------------------------------------
	signal offsets           : offset_t := (others => (others => '0'));
	signal depths            : depth_t  := (others => (others => '0'));
	signal state, next_state : state_type;

	-- AG Internal signals
	signal AG_config_en_i      : std_logic;
	signal AG_config_we_i      : std_logic;
	signal AG_config_data_i    : std_logic_vector(AG_CONFIG_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal AG_config_wr_addr_i : std_logic_vector(AG_CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');

	-- BUFFER Configurations signals
	signal BUFFER_config_en_i      : std_logic;
	signal BUFFER_config_we_i      : std_logic;
	signal BUFFER_config_data_i    : std_logic_vector(BUFFER_CONFIG_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal BUFFER_config_wr_addr_i : std_logic_vector(BUFFER_CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');

	signal config_re_i      : std_logic                                        := '0';
	signal config_rd_addr_i : std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal config_rd_addr_r : std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal config_rd_data_i : std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal config_done_i    : std_logic;
	signal config_rst_i     : std_logic;
	signal config_start_r   : std_logic;

	signal load_offset_cnt   : unsigned(CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal load_depth_cnt    : unsigned(CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal load_offset_cnt_r : unsigned(1 - 1 downto 0)                 := (others => '0');
	signal load_depth_cnt_r  : unsigned(1 - 1 downto 0)                 := (others => '0');

	signal count_AG       : unsigned(AG_CONFIG_ADDR_WIDTH - 1 downto 0)     := (others => '0');
	signal count_AG_r     : unsigned(AG_CONFIG_ADDR_WIDTH - 1 downto 0)     := (others => '0');
	signal count_BUFFER   : unsigned(BUFFER_CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal count_BUFFER_r : unsigned(BUFFER_CONFIG_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal offset_AG      : unsigned(CONFIG_ADDR_WIDTH - 1 downto 0)        := (others => '0');
	signal offset_BUFFER  : unsigned(CONFIG_ADDR_WIDTH - 1 downto 0)        := (others => '0');
	signal depth_AG       : unsigned(CONFIG_ADDR_WIDTH - 1 downto 0)        := (others => '0');
	signal depth_BUFFER   : unsigned(CONFIG_ADDR_WIDTH - 1 downto 0)        := (others => '0');

	signal AG_config_clk_i     : std_logic := '0';
	signal AG_config_rst_i     : std_logic := '0';
	signal BUFFER_config_clk_i : std_logic := '0';
	signal BUFFER_config_rst_i : std_logic := '0';
	
	signal BUFFER_config_start_i: std_logic := '0';

--	attribute BUFFER_TYPE : string;
--	attribute BUFFER_TYPE of AG_config_clk_i : signal is "BUFGP";
--	attribute BUFFER_TYPE of BUFFER_config_clk_i : signal is "BUFGP";
	attribute syn_state_machine : boolean;
	attribute syn_state_machine of state : signal is true; 
	-------------------------------------------------------------------------------

	---------------------------------- Components ---------------------------------
	component Memory is
		generic(
			DATA_WIDTH  : integer range 0 to 64 := CONFIG_DATA_WIDTH;
			CONFIG_SIZE : integer              := AG_BUFFER_CONFIG_SIZE;
			ADDR_WIDTH  : integer range 0 to 32 := CONFIG_ADDR_WIDTH
		);
		port(
			-- Write Port
			config_wr_clk      : in  std_logic;
			config_en          : in  std_logic;
			config_we          : in  std_logic;
			config_wr_data     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			config_wr_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			config_wr_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);

			-- Read Port
			config_rd_clk      : in  std_logic;
			config_re          : in  std_logic;
			config_rd_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			config_rd_data     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	end component Memory;

---------------------------------- End Components -----------------------------

begin
	Memory_Inst : component Memory
		generic map(
			DATA_WIDTH  => CONFIG_DATA_WIDTH,
			CONFIG_SIZE => AG_BUFFER_CONFIG_SIZE,
			ADDR_WIDTH  => CONFIG_ADDR_WIDTH
		)
		port map(
			config_wr_clk      => config_clk,
			config_en          => config_en,
			config_we          => config_we,
			config_wr_data     => config_data,
			config_wr_addr     => config_wr_addr,
			config_wr_data_out => config_wr_data_out,
			config_rd_clk      => config_clk,
			config_re          => config_re_i,
			config_rd_addr     => config_rd_addr_i,
			config_rd_data     => config_rd_data_i
		);

	SYNC_PROC : process(config_clk)
	begin
		if (config_clk'event and config_clk = '1') then
			if (config_rst_i = '1') then
				state <= idle;

				AG_config_en      <= '0';
				AG_config_we      <= '0';
				AG_config_data    <= (others => '0');
				AG_config_wr_addr <= (others => '0');

				BUFFER_config_en      <= '0';
				BUFFER_config_we      <= '0';
				BUFFER_config_data    <= (others => '0');
				BUFFER_config_wr_addr <= (others => '0');
				BUFFER_config_start	  <= '0';

				config_done <= '0';
			else
				state <= next_state;

				AG_config_en      <= AG_config_en_i;
				AG_config_we      <= AG_config_we_i;
				AG_config_data    <= AG_config_data_i;
				AG_config_wr_addr <= AG_config_wr_addr_i;

				BUFFER_config_en      <= BUFFER_config_en_i;
				BUFFER_config_we      <= BUFFER_config_we_i;
				BUFFER_config_data    <= BUFFER_config_data_i;
				BUFFER_config_wr_addr <= BUFFER_config_wr_addr_i;
				BUFFER_config_start	  <= BUFFER_config_start_i;

				config_done <= config_done_i and BUFFER_config_done;
			end if;
		end if;
	end process;

	NEXT_STATE_DECODE : process(state, config_en, config_we, config_start, config_start_r, config_rd_addr_r, offset_AG, depth_AG, offset_BUFFER, depth_BUFFER)
	begin
		next_state <= state;
		case (state) is
			when idle =>
				if config_en = '1' then
					next_state <= configure_memory;
				end if;
			when configure_memory =>
				if config_start = '1' and config_start_r = '0' then
					next_state <= load_offsets;
				end if;
			when load_offsets =>
				if (config_rd_addr_r = std_logic_vector(to_unsigned(1, CONFIG_ADDR_WIDTH))) then
					next_state <= load_depths;
				end if;
			when load_depths =>
				if (config_rd_addr_r = std_logic_vector(to_unsigned(3, CONFIG_ADDR_WIDTH))) then
					next_state <= configure_AG;
				end if;
			when configure_AG =>
				if (config_rd_addr_r = std_logic_vector(offset_AG + depth_AG - 1)) then
					next_state <= configure_BUFFER;
				end if;
			when configure_BUFFER =>
				if (config_rd_addr_r = std_logic_vector(offset_BUFFER + depth_BUFFER - 1)) then
					next_state <= ready;
				end if;
			when ready =>
				if ((config_en and config_we) = '1') then
					next_state <= configure_memory;
				end if;
		end case;
	end process;

	OUTPUT_DECODE : process(state, count_AG_r, count_BUFFER_r, config_rd_data_i)
	begin
		if state = idle then
			AG_config_en_i      <= '0';
			AG_config_we_i      <= '0';
			AG_config_data_i    <= (others => '0');
			AG_config_wr_addr_i <= (others => '0');

			BUFFER_config_en_i      <= '0';
			BUFFER_config_we_i      <= '0';
			BUFFER_config_data_i    <= (others => '0');
			BUFFER_config_start_i		<= '0';
			BUFFER_config_wr_addr_i <= (others => '0');

			config_done_i <= '1';
		elsif (state = configure_memory) then
			AG_config_en_i      <= '0';
			AG_config_we_i      <= '0';
			AG_config_data_i    <= (others => '0');
			AG_config_wr_addr_i <= (others => '0');

			BUFFER_config_en_i      <= '0';
			BUFFER_config_we_i      <= '0';
			BUFFER_config_data_i    <= (others => '0');
			BUFFER_config_start_i		<= '0';
			BUFFER_config_wr_addr_i <= (others => '0');

			config_done_i <= '0';
		elsif (state = load_offsets) then
			AG_config_en_i      <= '0';
			AG_config_we_i      <= '0';
			AG_config_data_i    <= (others => '0');
			AG_config_wr_addr_i <= (others => '0');

			BUFFER_config_en_i      <= '0';
			BUFFER_config_we_i      <= '0';
			BUFFER_config_data_i    <= (others => '0');
			BUFFER_config_start_i		<= '0';
			BUFFER_config_wr_addr_i <= (others => '0');

			config_done_i <= '0';
		elsif (state = load_depths) then
			AG_config_en_i      <= '0';
			AG_config_we_i      <= '0';
			AG_config_data_i    <= (others => '0');
			AG_config_wr_addr_i <= (others => '0');

			BUFFER_config_en_i      <= '0';
			BUFFER_config_we_i      <= '0';
			BUFFER_config_data_i    <= (others => '0');
			BUFFER_config_start_i		<= '0';
			BUFFER_config_wr_addr_i <= (others => '0');

			config_done_i <= '0';
		elsif (state = configure_AG) then
			AG_config_en_i      <= '1';
			AG_config_we_i      <= '1';
			AG_config_data_i    <= config_rd_data_i(AG_CONFIG_DATA_WIDTH - 1 downto 0);
			AG_config_wr_addr_i <= std_logic_vector(count_AG_r(AG_CONFIG_ADDR_WIDTH - 1 downto 0));

			BUFFER_config_en_i      <= '0';
			BUFFER_config_we_i      <= '0';
			BUFFER_config_data_i    <= (others => '0');
			BUFFER_config_start_i		<= '0';
			BUFFER_config_wr_addr_i <= (others => '0');

			config_done_i <= '0';
		elsif (state = configure_BUFFER) then
			AG_config_en_i      <= '0';
			AG_config_we_i      <= '0';
			AG_config_data_i    <= (others => '0');
			AG_config_wr_addr_i <= (others => '0');

			BUFFER_config_en_i      <= '1';
			BUFFER_config_we_i      <= '1';
			BUFFER_config_data_i    <= config_rd_data_i(BUFFER_CONFIG_DATA_WIDTH - 1 downto 0);
			BUFFER_config_start_i		<= '0';
			BUFFER_config_wr_addr_i <= std_logic_vector(count_BUFFER_r(BUFFER_CONFIG_ADDR_WIDTH - 1 downto 0));

			config_done_i <= '0';
		elsif (state = ready) then
			AG_config_en_i      <= '0';
			AG_config_we_i      <= '0';
			AG_config_data_i    <= (others => '0');
			AG_config_wr_addr_i <= (others => '0');

			BUFFER_config_en_i      <= '0';
			BUFFER_config_we_i      <= '0';
			BUFFER_config_data_i    <= (others => '0');
			BUFFER_config_start_i		<= '1';
			BUFFER_config_wr_addr_i <= (others => '0');

			config_done_i <= '1';
		else
			AG_config_en_i      <= '0';
			AG_config_we_i      <= '0';
			AG_config_data_i    <= (others => '0');
			AG_config_wr_addr_i <= (others => '0');

			BUFFER_config_en_i      <= '0';
			BUFFER_config_we_i      <= '0';
			BUFFER_config_data_i    <= (others => '0');
			BUFFER_config_start_i		<= '0';
			BUFFER_config_wr_addr_i <= (others => '0');

			--config_done_i <= '0';
		end if;
	end process;

	BEFORE_OUTPUT_DECODE : process(next_state, load_offset_cnt, load_depth_cnt, count_AG, count_BUFFER, offset_AG, offset_BUFFER)
	begin
		if next_state = idle then
			config_re_i      <= '0';
			config_rd_addr_i <= (others => '0');
		elsif (next_state = configure_memory) then
			config_re_i      <= '0';
			config_rd_addr_i <= (others => '0');
		elsif (next_state = load_offsets) then
			config_re_i      <= '1';
			config_rd_addr_i <= std_logic_vector(load_offset_cnt);
		elsif (next_state = load_depths) then
			config_re_i      <= '1';
			config_rd_addr_i <= std_logic_vector(load_depth_cnt);
		elsif (next_state = configure_AG) then
			config_re_i      <= '1';
			config_rd_addr_i <= std_logic_vector(count_AG + offset_AG);
		elsif (next_state = configure_BUFFER) then
			config_re_i      <= '1';
			config_rd_addr_i <= std_logic_vector(count_BUFFER + offset_BUFFER);
		elsif (next_state = ready) then
			config_re_i      <= '0';
			config_rd_addr_i <= (others => '0');
		else
			config_re_i      <= '0';
			config_rd_addr_i <= (others => '0');
		end if;
	end process;

	REGISTER_PROC : process(config_clk, config_rst_i) is
	begin
		if config_rst_i = '1' then
			config_rd_addr_r  <= (others => '0');
			load_offset_cnt_r <= (others => '0');
			load_depth_cnt_r  <= (others => '0');
			count_AG_r        <= (others => '0');
			count_BUFFER_r    <= (others => '0');
			config_start_r    <= '0';
		elsif rising_edge(config_clk) then
			config_rd_addr_r  <= config_rd_addr_i;
			load_offset_cnt_r <= load_offset_cnt(1 - 1 downto 0);
			load_depth_cnt_r  <= load_depth_cnt(1 - 1 downto 0);
			count_AG_r        <= count_AG;
			count_BUFFER_r    <= count_BUFFER;
			config_start_r    <= config_start;
		end if;
	end process REGISTER_PROC;

	-- Load Offset
	LOAD_OFFSET_COUNTER_PROC : process(config_clk, config_rst_i)
	begin
		if config_rst_i = '1' then
			load_offset_cnt <= (others => '0');
		elsif config_clk = '1' and config_clk'event then
			if (not (next_state = load_offsets)) then
				load_offset_cnt <= to_unsigned(0, CONFIG_ADDR_WIDTH);
			else
				load_offset_cnt <= load_offset_cnt + 1;
			end if;
		end if;
	end process LOAD_OFFSET_COUNTER_PROC;

	MAP_OFFESETS : process(config_clk, config_rst_i) is
	begin
		if config_rst_i = '1' then
			offsets <= (others => (others => '0'));
		elsif config_clk = '1' and config_clk'event then
			if (state = load_offsets) then
				offsets(to_integer(load_offset_cnt_r(0 downto 0))) <= config_rd_data_i(CONFIG_ADDR_WIDTH - 1 downto 0);
			end if;
		end if;
	end process MAP_OFFESETS;

	-- Load Depth
	LOAD_DETH_COUNTER_PROC : process(config_clk, config_rst_i)
	begin
		if config_rst_i = '1' then
			load_depth_cnt <= (others => '0');
		elsif config_clk = '1' and config_clk'event then
			if (not (next_state = load_depths)) then
				load_depth_cnt <= to_unsigned(2, CONFIG_ADDR_WIDTH);
			else
				load_depth_cnt <= load_depth_cnt + 1;
			end if;
		end if;
	end process LOAD_DETH_COUNTER_PROC;

	MAP_DEPTHS : process(config_clk, config_rst_i) is
	begin
		if config_rst_i = '1' then
			depths <= (others => (others => '0'));
		elsif config_clk = '1' and config_clk'event then
			if (state = load_depths) then
				depths(to_integer(load_depth_cnt_r(0 downto 0))) <= config_rd_data_i(CONFIG_ADDR_WIDTH - 1 downto 0);
			end if;
		end if;
	end process MAP_DEPTHS;

	offset_AG     <= unsigned(offsets(0));
	depth_AG      <= unsigned(depths(0));
	offset_BUFFER <= unsigned(offsets(1));
	depth_BUFFER  <= unsigned(depths(1));

	-- Configure AG
	CONFIGURE_AG_COUNTER_PROC : process(config_clk, config_rst_i)
	begin
		if config_rst_i = '1' then
			count_AG <= (others => '0');
		elsif config_clk = '1' and config_clk'event then
			if (not (next_state = configure_AG)) then
				count_AG <= to_unsigned(0, AG_CONFIG_ADDR_WIDTH);
			else
				count_AG <= count_AG + 1;
			end if;
		end if;
	end process CONFIGURE_AG_COUNTER_PROC;

	-- Configure BUFFER
	CONFIGURE_BUFFER_COUNTER_PROC : process(config_clk, config_rst_i)
	begin
		if config_rst_i = '1' then
			count_BUFFER <= (others => '0');
		elsif config_clk = '1' and config_clk'event then
			if (not (next_state = configure_BUFFER)) then
				count_BUFFER <= to_unsigned(0, BUFFER_CONFIG_ADDR_WIDTH);
			else
				count_BUFFER <= count_BUFFER + 1;
			end if;
		end if;
	end process CONFIGURE_BUFFER_COUNTER_PROC;

	-- Config Clk and rst
	AG_config_clk_i     <= config_clk;
	AG_config_rst_i     <= config_rst_i;
	BUFFER_config_clk_i <= config_clk;
	BUFFER_config_rst_i <= config_rst_i;

	config_rst_i <= config_rst or config_soft_rst;

	AG_config_clk     <= AG_config_clk_i;
	AG_config_rst     <= AG_config_rst_i;
	BUFFER_config_clk <= BUFFER_config_clk_i;
	BUFFER_config_rst <= BUFFER_config_rst_i;

end Behavioral;
