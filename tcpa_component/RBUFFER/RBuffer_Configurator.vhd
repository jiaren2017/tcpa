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
-- Create Date:    10:05:45 08/11/2014 
-- Design Name: 
-- Module Name:    RBuffer_Configurator - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RBuffer_Configurator is
	generic(
		--###########################################################################
		-- RBuffer_Configurator, do not add to or delete
		--###########################################################################
		ADDR_HEADER_WIDTH       : integer range 0 to 32 := 8;
		SEL_REG_WIDTH            : integer range 0 to 8  := 3; -- = log2(MAX_SEL_ADDR_WIDTH)
		MAX_CHANNEL_CNT          : integer range 0 to 32 := 4;
		CSR_DELAY_SELECTOR_WIDTH : integer range 0 to 32 := 6;
		CONFIG_ADDR_WIDTH        : integer range 0 to 32 := 8;
		CONFIG_DATA_WIDTH        : integer range 0 to 32 := 8
	--###########################################################################		
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
end RBuffer_Configurator;

architecture Behavioral of RBuffer_Configurator is

	---------------------------------- Type ---------------------------------------
--	type config_type is array (1024 - 1 downto 0) of std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
	type config_type is array (2 ** CONFIG_ADDR_WIDTH - 1 downto 0) of std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
	type state_type is (idle, configure_memory,prepare_config,addr_match_A,addr_match_B ,st_config_width_sel_A,st_config_width_sel_B, use_second_A,use_CSR,CSR_delay_selector,channel_dirs,out_selector_A,out_selector_B, set_number_of_concatenated_channels, 
set_irq_channel_depth, set_irq_channel_en, ready);
	---------------------------------- End Type -----------------------------------

	---------------------------------- Signals ------------------------------------
	signal state, next_state : state_type := idle;
	signal config_reg : config_type := (others => (others => '0'));
	attribute RAM_STYLE : string;
	attribute RAM_STYLE of config_reg : signal is "BLOCK";
	
	signal config_re_i           :  std_logic;
	signal config_rd_addr_i      : std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
	signal config_rd_data_i      : std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
	signal config_start_r		: std_logic;
	
	signal rd_counter: unsigned(CONFIG_ADDR_WIDTH-1 downto 0) := (others => '0');

	signal tmp_config_addr_match_a          : std_logic_vector(MAX_CHANNEL_CNT * ADDR_HEADER_WIDTH - 1 downto 0);
	signal tmp_config_addr_match_b          : std_logic_vector(MAX_CHANNEL_CNT * ADDR_HEADER_WIDTH - 1 downto 0);
	signal tmp_config_width_sel_a           : std_logic_vector(SEL_REG_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_width_sel_b           : std_logic_vector(SEL_REG_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_use_second_a          : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_CSR_selector          : std_logic_vector((MAX_CHANNEL_CNT - 1) * CSR_DELAY_SELECTOR_WIDTH - 1 downto 0);
	signal tmp_config_use_CSR               : std_logic_vector(MAX_CHANNEL_CNT - 2 downto 0);
	signal tmp_config_channel_dir           : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_out_selector_a        : std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_out_selector_b        : std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_irq_channel_depth     : std_logic_vector(MAX_CHANNEL_CNT * CONFIG_DATA_WIDTH - 1 downto 0);
	signal tmp_config_irq_channel_en        : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_concatenated_channels_port_b : std_logic_vector(MAX_CHANNEL_CNT * MAX_CHANNEL_CNT - 1 downto 0);
	signal tmp_config_done                  : std_logic := '0';
	
	signal shifft_addr_match_a                      : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_addr_match_a_d                    : std_logic;
	signal shifft_addr_match_b                      : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_addr_match_b_d                    : std_logic;
	signal shifft_st_config_width_sel_a             : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_st_config_width_sel_a_d           : std_logic;
	signal shifft_st_config_width_sel_b             : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_st_config_width_sel_b_d           : std_logic;
	signal shifft_csr_delay_sel                     : std_logic_vector(MAX_CHANNEL_CNT - 2 downto 0);
	signal shifft_csr_delay_sel_d                   : std_logic;
	signal shifft_st_config_out_selector_a          : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_st_config_out_selector_a_d        : std_logic;
	signal shifft_st_config_out_selector_b          : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_st_config_out_selector_b_d        : std_logic;
	signal shifft_st_concatenated_channels_port_b   : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_st_concatenated_channels_port_b_d : std_logic;
	signal shifft_st_config_irq_channel_depth       : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_st_config_irq_channel_depth_d     : std_logic;
	--signal shifft_st_config_irq_channel_en          : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
	signal shifft_st_config_irq_channel_en_d        : std_logic;
	
	attribute syn_state_machine : boolean;
	attribute syn_state_machine of state : signal is true; 
	
---------------------------------- End Signals --------------------------------
begin
	process(config_clk)
	begin
		if (config_clk'event and config_clk = '1') then
			if (config_en = '1') then
				if (config_we = '1') then
					config_reg(conv_integer(config_wr_addr)) <= config_data;
				end if;
			end if;
		end if;
	end process;

	process(config_clk, config_rst)
	begin
		if (config_clk'event and config_clk = '1') then
			if(config_rst = '1')then
				config_rd_data_i <= (others => '0');
			elsif (config_re_i = '1') then
				config_rd_data_i <= config_reg(conv_integer(config_rd_addr_i));
			end if;
		end if;
	end process;
	
	
	--State Machine 
	SYNC_PROC : process(config_clk)
	begin
		if (config_clk'event and config_clk = '1') then
			if (config_rst = '1') then
				state <= idle;
				config_addr_match_a <= (others => '0');
				config_addr_match_b <= (others => '0');
				config_width_sel_a  <= (others => '0');
				config_width_sel_b  <= (others => '0');
				config_use_second_a <= (others => '0');
				config_CSR_selector <= (others => '0');
				config_use_CSR 		<= (others => '0');
				config_channel_dir  <= (others => '0');
				config_out_selector_a  <= (others => '0');
				config_out_selector_b  <= (others => '0');
				config_concatenated_channels_b  <= (others=>'0');
				config_irq_channel_depth <= (others=>'0');
				config_irq_channel_en    <= (others=>'0');
				config_done <= '0';
			else
				state <= next_state;

				config_addr_match_a             <= tmp_config_addr_match_a;
				config_addr_match_b             <= tmp_config_addr_match_b;
				config_width_sel_a              <= tmp_config_width_sel_a;
				config_width_sel_b              <= tmp_config_width_sel_b;
				config_use_second_a             <= tmp_config_use_second_a;
				config_CSR_selector             <= tmp_config_CSR_selector;
				config_use_CSR 		        <= tmp_config_use_CSR;
				config_channel_dir              <= tmp_config_channel_dir;
				config_out_selector_a           <= tmp_config_out_selector_a;
				config_out_selector_b           <= tmp_config_out_selector_b;
				config_concatenated_channels_b  <= tmp_concatenated_channels_port_b;
				config_irq_channel_depth        <= tmp_config_irq_channel_depth;
				config_irq_channel_en           <= tmp_config_irq_channel_en;


				config_done <= tmp_config_done;
			end if;
		end if;
	end process;
	
	NEXT_STATE_DECODE : process(state, config_en, config_we, 
		config_start, config_start_r,shifft_addr_match_a_d, shifft_addr_match_b_d, shifft_st_config_width_sel_a_d, 
		shifft_st_config_width_sel_b_d, shifft_csr_delay_sel_d, shifft_st_config_out_selector_a_d, shifft_st_config_out_selector_b_d, shifft_st_concatenated_channels_port_b_d, shifft_st_config_irq_channel_depth_d, shifft_st_config_irq_channel_en_d
	)
	begin
		next_state <= state;
		case (state) is
			when idle =>
				if config_en = '1' then
					next_state <= configure_memory;
				end if;
			when configure_memory =>
				if config_start = '1' and config_start_r = '0' then
					next_state <= prepare_config;
				end if;
			when prepare_config =>
				next_state <= addr_match_A;
			when addr_match_A =>
				if (shifft_addr_match_a_d = '1') then
					next_state <= addr_match_B;
				end if;
			when addr_match_B =>
				if (shifft_addr_match_b_d = '1') then
					next_state <= st_config_width_sel_A;
				end if;
			when st_config_width_sel_A =>
				if (shifft_st_config_width_sel_a_d = '1') then
					next_state <= st_config_width_sel_B;
				end if;
			when st_config_width_sel_B =>
				if (shifft_st_config_width_sel_b_d = '1') then
					next_state <= use_second_A;
				end if;
			when use_second_A =>
				next_state <= use_CSR;
			when use_CSR =>
				next_state <= CSR_delay_selector;
			when CSR_delay_selector =>
				if (shifft_csr_delay_sel_d = '1') then
					next_state <= channel_dirs;
				end if;
			when channel_dirs =>
				next_state <= out_selector_A;
			when out_selector_A =>
				if (shifft_st_config_out_selector_a_d = '1') then
					next_state <= out_selector_B;
				end if;
			when out_selector_B =>
				if (shifft_st_config_out_selector_b_d = '1') then
					next_state <= set_number_of_concatenated_channels;
				end if;
			when set_number_of_concatenated_channels =>
				if(shifft_st_concatenated_channels_port_b_d = '1') then
					next_state <= set_irq_channel_depth;
				end if;

			when set_irq_channel_depth =>
				if(shifft_st_config_irq_channel_depth_d = '1') then
					next_state <= set_irq_channel_en;
				end if;

			when set_irq_channel_en =>
				--if(shifft_st_config_irq_channel_en_d = '1') then
					next_state <= ready;
				--end if;

			when ready =>
				if ((config_en and config_we) = '1') then
					next_state <= configure_memory;
				end if;				
			--when others => 
			--	next_state <= state;
			
		end case;
	end process;
	
	REGISTER_PROC : process(config_clk, config_rst) is
	begin
		if config_rst = '1' then
			config_start_r    <= '0';
			tmp_config_done <= '0';
		elsif rising_edge(config_clk) then
			config_start_r    <= config_start;
			if(state = configure_memory)then
				tmp_config_done <= '0';
			elsif(state = ready)then
				tmp_config_done <= '1';
			else
				tmp_config_done <= '1'; --If none configuration is required the buffer will contain a default configuration
			end if;
		end if;
	end process REGISTER_PROC;
	
	SHIFFT_REG_PROC:process (config_clk)
	begin
	   if config_clk'event and config_clk='1' then  
	      if next_state = addr_match_A then 
	         shifft_addr_match_a <= shifft_addr_match_a(MAX_CHANNEL_CNT-2 downto 0) & '1';
	      else
	      	shifft_addr_match_a <= shifft_addr_match_a(MAX_CHANNEL_CNT-2 downto 0) & '0';
	      end if; 
	      if next_state = addr_match_B then 
	         shifft_addr_match_b <= shifft_addr_match_b(MAX_CHANNEL_CNT-2 downto 0) & '1';
	      else
	      	shifft_addr_match_b <= shifft_addr_match_b(MAX_CHANNEL_CNT-2 downto 0) & '0';
	      end if;
	      if next_state = st_config_width_sel_A then 
	         shifft_st_config_width_sel_a <= shifft_st_config_width_sel_a(MAX_CHANNEL_CNT-2 downto 0) & '1';
	      else
	      	 shifft_st_config_width_sel_a <= shifft_st_config_width_sel_a(MAX_CHANNEL_CNT-2 downto 0) & '0';
	      end if;
	      if next_state = st_config_width_sel_B then 
	         shifft_st_config_width_sel_b <= shifft_st_config_width_sel_b(MAX_CHANNEL_CNT-2 downto 0) & '1';
	      else
	      	 shifft_st_config_width_sel_b <= shifft_st_config_width_sel_b(MAX_CHANNEL_CNT-2 downto 0) & '0';
	      end if;
	      if next_state = CSR_delay_selector then 
	         shifft_csr_delay_sel <= shifft_csr_delay_sel(MAX_CHANNEL_CNT-3 downto 0) & '1';
	      else
	      	 shifft_csr_delay_sel <= shifft_csr_delay_sel(MAX_CHANNEL_CNT-3 downto 0) & '0';
	      end if;
	      if next_state = out_selector_A then 
	         shifft_st_config_out_selector_a <= shifft_st_config_out_selector_a(MAX_CHANNEL_CNT-2 downto 0) & '1';
	      else
	      	 shifft_st_config_out_selector_a <= shifft_st_config_out_selector_a(MAX_CHANNEL_CNT-2 downto 0) & '0';
	      end if;
	      if next_state = out_selector_B then 
	         shifft_st_config_out_selector_b <= shifft_st_config_out_selector_b(MAX_CHANNEL_CNT-2 downto 0) & '1';
	      else
	      	 shifft_st_config_out_selector_b <= shifft_st_config_out_selector_b(MAX_CHANNEL_CNT-2 downto 0) & '0';
	      end if;
	      if next_state = set_number_of_concatenated_channels then 
	         shifft_st_concatenated_channels_port_b <= shifft_st_concatenated_channels_port_b(MAX_CHANNEL_CNT-2 downto 0) & '1';
	      else
	      	 shifft_st_concatenated_channels_port_b <= shifft_st_concatenated_channels_port_b(MAX_CHANNEL_CNT-2 downto 0) & '0';
	      end if;
	      if next_state = set_irq_channel_depth then 
	         shifft_st_config_irq_channel_depth <= shifft_st_config_irq_channel_depth(MAX_CHANNEL_CNT-2 downto 0) & '1';
	      else
	         shifft_st_config_irq_channel_depth <= shifft_st_config_irq_channel_depth(MAX_CHANNEL_CNT-2 downto 0) & '0';
	      end if;
--	      if next_state = set_irq_channel_en then 
--	         shifft_st_config_irq_channel_en <= shifft_st_config_irq_channel_en(MAX_CHANNEL_CNT-2 downto 0) & '1';
--	      else
--	         shifft_st_config_irq_channel_en <= shifft_st_config_irq_channel_en(MAX_CHANNEL_CNT-2 downto 0) & '0';
--	      end if;
	      
	   end if;
	end process;
	shifft_addr_match_a_d <= shifft_addr_match_a(MAX_CHANNEL_CNT-1);
	shifft_addr_match_b_d <= shifft_addr_match_b(MAX_CHANNEL_CNT-1);
	shifft_st_config_width_sel_a_d <= shifft_st_config_width_sel_a(MAX_CHANNEL_CNT-1);
	shifft_st_config_width_sel_b_d <= shifft_st_config_width_sel_b(MAX_CHANNEL_CNT-1);
	shifft_csr_delay_sel_d <= shifft_csr_delay_sel(MAX_CHANNEL_CNT-2);
	shifft_st_config_out_selector_a_d <= shifft_st_config_out_selector_a(MAX_CHANNEL_CNT-1);
	shifft_st_config_out_selector_b_d <= shifft_st_config_out_selector_b(MAX_CHANNEL_CNT-1);
	shifft_st_concatenated_channels_port_b_d <= shifft_st_concatenated_channels_port_b(MAX_CHANNEL_CNT-1);
	shifft_st_config_irq_channel_depth_d <= shifft_st_config_irq_channel_depth(MAX_CHANNEL_CNT-1);
	--shifft_st_config_irq_channel_en_d    <= shifft_st_config_irq_channel_en(MAX_CHANNEL_CNT-1);
	
	GEN_OUTPUT_MAX_CNT : for i in 0 to MAX_CHANNEL_CNT-1 generate
		NOT_LAST : if i < MAX_CHANNEL_CNT-1 generate
			OUTPUT_REG:process(config_clk, config_rst)
			begin
				if config_rst = '1' then
					tmp_config_addr_match_a((i + 1) * ADDR_HEADER_WIDTH - 1 downto i * ADDR_HEADER_WIDTH) <= (others => '0');
					tmp_config_addr_match_b((i + 1) * ADDR_HEADER_WIDTH - 1 downto i * ADDR_HEADER_WIDTH) <= (others => '0');
					tmp_config_width_sel_a((i + 1) * SEL_REG_WIDTH - 1 downto i * SEL_REG_WIDTH) <= (others => '0');
					tmp_config_width_sel_b((i + 1) * SEL_REG_WIDTH - 1 downto i * SEL_REG_WIDTH) <= (others => '0');
					tmp_config_out_selector_a((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= (others => '0');
					tmp_config_out_selector_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= (others => '0');
					tmp_concatenated_channels_port_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= (others => '0');
					tmp_config_irq_channel_depth((i + 1) * CONFIG_DATA_WIDTH - 1 downto i * CONFIG_DATA_WIDTH) <= (others => '0');

				elsif config_clk = '1' and config_clk'event then
					if (state = addr_match_A and shifft_addr_match_a(i) = '1' and shifft_addr_match_a(i+1) = '0') then
						tmp_config_addr_match_a((i + 1) * ADDR_HEADER_WIDTH - 1 downto i * ADDR_HEADER_WIDTH) <= config_rd_data_i(ADDR_HEADER_WIDTH - 1 downto 0);
					end if;
					if (state = addr_match_B and shifft_addr_match_b(i) = '1' and shifft_addr_match_b(i+1) = '0') then
						tmp_config_addr_match_b((i + 1) * ADDR_HEADER_WIDTH - 1 downto i * ADDR_HEADER_WIDTH) <= config_rd_data_i(ADDR_HEADER_WIDTH - 1 downto 0);
					end if;
					if (state = st_config_width_sel_A and shifft_st_config_width_sel_a(i) = '1' and shifft_st_config_width_sel_a(i+1) = '0') then
						tmp_config_width_sel_a((i + 1) * SEL_REG_WIDTH - 1 downto i * SEL_REG_WIDTH) <= config_rd_data_i(SEL_REG_WIDTH - 1 downto 0);
					end if;
					if (state = st_config_width_sel_B and shifft_st_config_width_sel_b(i) = '1' and shifft_st_config_width_sel_b(i+1) = '0') then
						tmp_config_width_sel_b((i + 1) * SEL_REG_WIDTH - 1 downto i * SEL_REG_WIDTH) <= config_rd_data_i(SEL_REG_WIDTH - 1 downto 0);
					end if;
					if (state = out_selector_A and shifft_st_config_out_selector_a(i) = '1'and shifft_st_config_out_selector_a(i+1) = '0') then
						tmp_config_out_selector_a((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
					end if;
					if (state = out_selector_B and shifft_st_config_out_selector_b(i) = '1'and shifft_st_config_out_selector_b(i+1) = '0') then
						tmp_config_out_selector_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
					end if;				
					if (state = set_number_of_concatenated_channels and shifft_st_concatenated_channels_port_b(i) = '1'and shifft_st_concatenated_channels_port_b(i+1) = '0') then
						tmp_concatenated_channels_port_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
					end if;				
					if(state = set_irq_channel_depth and shifft_st_config_irq_channel_depth(i) = '1' and shifft_st_config_irq_channel_depth(i+1) = '0') then
						tmp_config_irq_channel_depth((i+1) * CONFIG_DATA_WIDTH - 1 downto i*CONFIG_DATA_WIDTH) <= config_rd_data_i(CONFIG_DATA_WIDTH - 1 downto 0);
					end if;

				end if;
			end process OUTPUT_REG;
		end generate NOT_LAST;
		
		generate_label : if i = MAX_CHANNEL_CNT -1 generate
			OUTPUT_REG_2:process(config_clk, config_rst)
			begin
				if config_rst = '1' then
					tmp_config_addr_match_a((i + 1) * ADDR_HEADER_WIDTH - 1 downto i * ADDR_HEADER_WIDTH) <= (others => '0');
					tmp_config_addr_match_b((i + 1) * ADDR_HEADER_WIDTH - 1 downto i * ADDR_HEADER_WIDTH) <= (others => '0');
					tmp_config_width_sel_a((i + 1) * SEL_REG_WIDTH - 1 downto i * SEL_REG_WIDTH) <= (others => '0');
					tmp_config_width_sel_b((i + 1) * SEL_REG_WIDTH - 1 downto i * SEL_REG_WIDTH) <= (others => '0');
					tmp_config_out_selector_a((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= (others => '0');
					tmp_config_out_selector_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= (others => '0');
					tmp_concatenated_channels_port_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= (others => '0');
					tmp_config_irq_channel_depth((i + 1) * CONFIG_DATA_WIDTH - 1 downto i * CONFIG_DATA_WIDTH) <= (others => '0');

				elsif config_clk = '1' and config_clk'event then
					if (state = addr_match_A and shifft_addr_match_a_d = '1') then
						tmp_config_addr_match_a((i + 1) * ADDR_HEADER_WIDTH - 1 downto i * ADDR_HEADER_WIDTH) <= config_rd_data_i(ADDR_HEADER_WIDTH - 1 downto 0);
					end if;
					if (state = addr_match_B and shifft_addr_match_b_d = '1') then
						tmp_config_addr_match_b((i + 1) * ADDR_HEADER_WIDTH - 1 downto i * ADDR_HEADER_WIDTH) <= config_rd_data_i(ADDR_HEADER_WIDTH - 1 downto 0);
					end if;
					if (state = st_config_width_sel_A and shifft_st_config_width_sel_a_d = '1') then
						tmp_config_width_sel_a((i + 1) * SEL_REG_WIDTH - 1 downto i * SEL_REG_WIDTH) <= config_rd_data_i(SEL_REG_WIDTH - 1 downto 0);
					end if;
					if (state = st_config_width_sel_B and shifft_st_config_width_sel_b_d = '1') then
						tmp_config_width_sel_b((i + 1) * SEL_REG_WIDTH - 1 downto i * SEL_REG_WIDTH) <= config_rd_data_i(SEL_REG_WIDTH - 1 downto 0);
					end if;
					if (state = out_selector_A and shifft_st_config_out_selector_a_d = '1') then
						tmp_config_out_selector_a((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
					end if;
					if (state = out_selector_B and shifft_st_config_out_selector_b_d = '1') then
						tmp_config_out_selector_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
					end if;				
					if (state = set_number_of_concatenated_channels and shifft_st_concatenated_channels_port_b_d = '1') then
						tmp_concatenated_channels_port_b((i + 1) * MAX_CHANNEL_CNT - 1 downto i * MAX_CHANNEL_CNT) <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
					end if;				
					if(state = set_irq_channel_depth and shifft_st_config_irq_channel_depth_d = '1') then
						tmp_config_irq_channel_depth((i+1) * CONFIG_DATA_WIDTH - 1 downto i*CONFIG_DATA_WIDTH) <= config_rd_data_i(CONFIG_DATA_WIDTH - 1 downto 0);
					end if;
				end if;
			end process OUTPUT_REG_2;
		end generate generate_label;
		
		
		
		
	end generate GEN_OUTPUT_MAX_CNT;
	
	GEN_OUTPUT_MAX_CNT_1 : for i in 0 to MAX_CHANNEL_CNT-2 generate
		NOT_LAST : if i < MAX_CHANNEL_CNT-2 generate
			OUTPUT_REG_1:process(config_clk, config_rst)
			begin
				if config_rst = '1' then
					tmp_config_CSR_selector((i + 1) * CSR_DELAY_SELECTOR_WIDTH - 1 downto i * CSR_DELAY_SELECTOR_WIDTH) <= (others => '0');				
				elsif config_clk = '1' and config_clk'event then
					if (state =  CSR_delay_selector and shifft_csr_delay_sel(i) = '1' and shifft_csr_delay_sel(i+1) = '0') then
						tmp_config_CSR_selector((i + 1) * CSR_DELAY_SELECTOR_WIDTH - 1 downto i * CSR_DELAY_SELECTOR_WIDTH)<= config_rd_data_i(CSR_DELAY_SELECTOR_WIDTH - 1 downto 0);
					end if;
				end if;
			end process OUTPUT_REG_1;
		end generate NOT_LAST;
	
		LAST_ITEM : if i = MAX_CHANNEL_CNT-2 generate
			OUTPUT_REG_3:process(config_clk, config_rst)
			begin
				if config_rst = '1' then
					tmp_config_CSR_selector((i + 1) * CSR_DELAY_SELECTOR_WIDTH - 1 downto i * CSR_DELAY_SELECTOR_WIDTH) <= (others => '0');				
				elsif config_clk = '1' and config_clk'event then
					if (state =  CSR_delay_selector and shifft_csr_delay_sel_d = '1') then
						tmp_config_CSR_selector((i + 1) * CSR_DELAY_SELECTOR_WIDTH - 1 downto i * CSR_DELAY_SELECTOR_WIDTH)<= config_rd_data_i(CSR_DELAY_SELECTOR_WIDTH - 1 downto 0);
					end if;
				end if;
			end process OUTPUT_REG_3;
		end generate LAST_ITEM;
	end generate GEN_OUTPUT_MAX_CNT_1;
	
	
	SINGLE_OUTPUT : process (config_clk, config_rst) is
	begin
		if config_rst = '1' then
			tmp_config_use_second_a   <= (others => '0');
			tmp_config_use_CSR 	  <= (others => '0');
			tmp_config_channel_dir    <= (others => '0');
			tmp_config_irq_channel_en <= (others => '0');

		elsif rising_edge(config_clk) then
			if(state = use_second_A) then
				tmp_config_use_second_a <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
			end if;
			if(state = use_CSR) then
				tmp_config_use_CSR <= config_rd_data_i(MAX_CHANNEL_CNT - 2 downto 0);
			end if;
			if(state = channel_dirs) then
				tmp_config_channel_dir <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
			end if;
			if(state = set_irq_channel_en) then
				tmp_config_irq_channel_en <= config_rd_data_i(MAX_CHANNEL_CNT - 1 downto 0);
			end if;
		end if;
	end process SINGLE_OUTPUT;
	
	LOAD_OFFSET_COUNTER_PROC : process(config_clk, config_rst)
	begin
		if config_rst = '1' then
			rd_counter <= (others => '0');
			config_re_i <= '0';
		elsif config_clk = '1' and config_clk'event then
			if (next_state = idle or next_state = ready or next_state = configure_memory) then
				rd_counter <= to_unsigned(0, CONFIG_ADDR_WIDTH);
				config_re_i <= '0';
			elsif (next_state = prepare_config) then
				rd_counter <= to_unsigned(0, CONFIG_ADDR_WIDTH);
				config_re_i <= '1';
			else
				rd_counter <= rd_counter + 1;
				config_re_i <= '1';
			end if;
		end if;
	end process LOAD_OFFSET_COUNTER_PROC;
	config_rd_addr_i <= std_logic_vector(rd_counter);
	
end Behavioral;
