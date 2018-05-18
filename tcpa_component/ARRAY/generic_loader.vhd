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
-- Create Date:    12:36:57 12/29/05
-- Design Name:    
-- Module Name:    generic_loader - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library wppa_instance_v1_01_a;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generic_loader is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME               : string;
		-- cadence translate_on			
		SOURCE_ADDR_WIDTH           : positive range 1 to MAX_ADDR_WIDTH := CUR_DEFAULT_SOURCE_ADDR_WIDTH;
		DESTIN_ADDR_WIDTH           : positive range 1 to MAX_ADDR_WIDTH := 27; --CUR_DEFAULT_ADDR_WIDTH;
		SOURCE_DATA_WIDTH           : positive range 1 to 128            := CUR_DEFAULT_SOURCE_DATA_WIDTH;
		-- Because the VLIW instruction width is not always a multiple of 
		-- config mem size, the data of VLIW instruction is padded to
		-- be multiple of config mem size. Therefore a
		-- value for the padded ratio must be given => DESTIN_SOURCE_RATIO_CEILING
		DESTIN_SOURCE_RATIO_CEILING : positive range 1 to 32; -- := 4;

		-- shravan : 20120316 : increased range of DESTIN_DATA_WIDTH from (1 to 128) to (1 to 1024),  DEST_IN_DATA_WIDTH is the width of one full VLIW instruction, as the number of FUs increases VLIW instruction size can increase beyond 128     
		-- DESTIN_DATA_WIDTH :positive range 1 to 128 := 117;
		DESTIN_DATA_WIDTH           : positive range 1 to 1024           := 117;

		DUAL_DATA_WIDTH             : positive range 1 to 128            := 8;
		INIT_SOURCE_ADDR            : integer range 0 to MAX_ADDR_WIDTH  := 0;
		--END_DESTIN_ADDR  :positive range 1 to MAX_ADDR_WIDTH := CUR_DEFAULT_MEM_SIZE -1
		END_DESTIN_ADDR             : positive range 1 to 16*1024             := CUR_DEFAULT_MEM_SIZE - 1
	);

	port(
		clk             : in  std_logic;
		rst             : in  std_logic;

		-- If set_to_config = '1', then this WPPE must be (RE-)configured
		set_to_config   : in  std_logic;
		enable_tcpa	: in std_logic;
		-- Signal showing the current state of configuring the memory and registers
		-- gives the reset signal for the WPPE-logic
		config_rst      : out std_logic;
		vliw_config_en   : in std_logic;
		icn_config_en   : in std_logic;
		mem_config_done : out std_logic := '1'; --Ericles
		common_config_reset : in std_logic;

		source_data_in  : in  std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);

		idle            : out std_logic; -- '1' if in INITIAL or WAITING state
		destin_we       : out std_logic;
		dual_we         : out std_logic;
		destin_addr_out : out std_logic_vector(DESTIN_ADDR_WIDTH - 1 downto 0);
		dual_destin_out : out std_logic_vector(DUAL_DATA_WIDTH - 1 downto 0);
		destin_data_out : out std_logic_vector(DESTIN_DATA_WIDTH - 1 downto 0)
	);

end generic_loader;

architecture Behavioral of generic_loader is
	CONSTANT END_CONFIG_DATA : integer range 1 to 128 := 4;

	-- The DESTIN_DATA_WIDTH is supposed to be always bigger than SOURCE_DATA_WIDTH,
	-- and the DESTIN_SOURCE_RATIO >= 1
	-- It will be used to configure the VLIW program memory (DESTIN_DATA_WIDTH) from a
	-- source memory, that is much smaller in data width (SOURCE_DATA_WIDTH << DESTIN_DATA_WIDTH);
	CONSTANT DESTIN_SOURCE_RATIO : integer := DESTIN_SOURCE_RATIO_CEILING; -- DESTIN_DATA_WIDTH / SOURCE_DATA_WIDTH;

	-- The DUAL_DATA_WIDTH is supposed to be always smaller than SOURCE_DATA_WIDTH,
	-- and the SOURCE_DUAL_RATIO >= 1
	-- It will be used to pre-configure/initialize the register file and the
	-- interconnect-wrapper registers (DUAL_DATA_WIDTH) from a
	-- source memory, that is much bigger in data width (SOURCE_DATA_WIDTH > DUAL_DATA_WIDTH);
	--CONSTANT SOURCE_DUAL_RATIO : integer := SOURCE_DATA_WIDTH / DUAL_DATA_WIDTH;
	CONSTANT SOURCE_DUAL_RATIO : integer := 5;

	type config_type is (
		--
		NO_CONFIGURATION,
		--
		VLIW_MEMORY_CONFIG,
		--
		ICN_CONFIG,
		--
		PRELOAD_CONFIG,
		--
		VLIW_AND_ICN,
		--
		VLIW_AND_PRELOAD,
		--
		ICN_AND_PRELOAD,
		--
		VLIW_AND_ICN_AND_PRELOAD);

	signal current_configuration_type : config_type;

	type loader_state_type is (
		--
		INITIAL,                        -- 0
		--
		LOAD_CONFIG_TYPE,               -- 1
		--
		LOAD_VLIW_CONFIG_END_ADDR,      -- 2
		--
		LOAD_ICN_CONFIG_END_ADDR,       -- 3
		--
		LOAD_COUNT_DOWN,                -- 4
		--
		LOAD_BUFFER,                    -- 5 
		LOAD_BUFFER_DUAL,               -- 6
		--
		WRITE_BACK,                     -- 7
		WRITE_BACK_DUAL,                -- 8
		--
		WAIT_STATE,                     -- 9
		--
		COUNT_DOWN_STATE                -- 10
);

	signal loader_nextstate : loader_state_type;

	signal internal_reset    : std_logic := '0';
	signal memory_configured : std_logic := '0';
	signal destin_we_reg     : std_logic; 
	signal dual_we_reg       : std_logic; 

	signal vliw_config_done    : std_logic;
	signal icn_config_done     : std_logic;
	signal preload_config_done : std_logic;

	-- Buffer for the bigger VLIW memory word (compared to the 
	-- smaller source memory), which is
	-- filled up with smaller source memory words
	--signal internal_buffer :std_logic_vector(DESTIN_SOURCE_RATIO_CEILING*SOURCE_DATA_WIDTH -1 downto 0);

	-- To adapt to the 128 Bit VLIW SY0A... memory !!!
	signal internal_buffer : std_logic_vector(DESTIN_SOURCE_RATIO_CEILING * SOURCE_DATA_WIDTH - 1 downto 0);
	--DESTIN_DATA_WIDTH -1 downto 0);

	-- Buffer for the bigger source memory word (compared to the
	-- smaller regiter width), which is
	-- filled in one read cycle and 
	-- read out sequentially with smaller register words
	signal internal_buffer_dual : std_logic_vector((DUAL_DATA_WIDTH*SOURCE_DUAL_RATIO)- 1 downto 0);
	signal internal_data_dual   : std_logic_vector(DUAL_DATA_WIDTH - 1 downto 0);

	signal buffer_load_pointer      : integer range 0 to DESTIN_SOURCE_RATIO + 1;
	signal buffer_load_pointer_dual : integer range 0 to SOURCE_DUAL_RATIO + 1;

	signal internal_destin_addr : std_logic_vector(DESTIN_ADDR_WIDTH - 1 downto 0);
	--signal internal_source_addr :std_logic_vector(SOURCE_ADDR_WIDTH -1 downto 0);

	signal clear_mask_registers : std_logic;
	signal count_down_ready     : std_logic;
	signal count_down_loaded    : std_logic;
	signal config_type_loaded   : std_logic;
	signal sig_set_to_config    : std_logic;
	signal tcpa_config_done     : std_logic; 
	signal set_to_config_reg    : std_logic;

	signal source_data_in_reg   : std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);
	signal vliw_config_end_addr_loaded : std_logic;
	signal sync_flag                   : std_logic;
	signal sig_vliw_config_en           : std_logic;
	signal sig_icn_config_en           : std_logic;
	signal icn_config_end_addr_loaded  : std_logic;

	signal get_new_config_type : std_logic;
	signal dual_write_delay    : std_logic;

	signal COUNT_DOWN_register  : std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);
	----------------------------------------------------
	signal CONFIG_TYPE_register : std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);

	signal VLIW_DATA_END_ADDR_register : std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);
	signal ICN_DATA_END_ADDR_register  : std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);

begin
	--############################################################
	--############################################################
	--set_config_type :process(--clk, rst, 
	--										CONFIG_TYPE_register)
	--
	--begin
	--
	----if clk'event and clk = '1' then
	--	
	--	if rst = '1' then
	--		
	--		current_configuration_type <= NO_CONFIGURATION;
	--
	--	else
	--
	--				case conv_integer(CONFIG_TYPE_register) is
	--
	--					when 0 => 
	--
	--						current_configuration_type <= NO_CONFIGURATION;
	--
	--					when 1 =>
	--			
	--						current_configuration_type <= VLIW_MEMORY_CONFIG;
	--		
	--					when 2 =>
	--
	--						current_configuration_type <= ICN_CONFIG;
	--
	--					when 3 =>
	--
	--						current_configuration_type <= PRELOAD_CONFIG;
	--
	--					when 4 =>
	--
	--						current_configuration_type <= VLIW_AND_ICN;
	--
	--					when 5 =>
	--
	--						current_configuration_type <= VLIW_AND_PRELOAD;
	--
	--					when 6 =>
	--
	--						current_configuration_type <= ICN_AND_PRELOAD;
	--
	--					when 7 =>
	--			
	--						current_configuration_type <=  VLIW_AND_ICN_AND_PRELOAD;
	--
	--					when others =>
	--
	--
	--				end case;
	--
	--		end if;
	--
	----end if;
	--
	--
	--end process;
	--############################################################
	--############################################################

	set_config_rst_register : process(clk, rst)
	begin

		-- Ericles Sousa on 16 Dec 2014: This signals are used to select the MUX which control the instruction memory addresses.
		-- When loading a new configuration into PEs, mem_config_done and config_rst are 0 and 1, respectively. Once the configuration 
		-- of the TCPA is done, mem_config_done is 1 and config_rst is 0.
		if clk'event and clk = '1' then
		--	if rst = '1' then
		--		config_rst <= '1';
				--mem_config_done <= '0';
		--	else
				-- Ericles Sousa on 09 Jan 2015
				-- config_rst <= internal_reset OR NOT count_down_ready;
				config_rst      <= internal_reset;
				mem_config_done <= memory_configured;
				sig_set_to_config <= set_to_config;
		--	end if;
		end if;
	end process;
	source_data_in_reg <= source_data_in;


	-- ======================================================================================						
	-- ======================================================================================						

	p_statechart : process(clk, rst, enable_tcpa)
	begin
		if rst = '1' then
			vliw_config_done    <= '1';
			icn_config_done     <= '1';
			if enable_tcpa = '0' then
				vliw_config_done    <= '0';
				icn_config_done     <= '0';
				internal_reset <= '1';
				memory_configured <= '0';
			end if;
			---------------------------
			idle                 <= '0';
			---------------------------
			--		internal_source_addr <= (others => '0');
			internal_destin_addr <= (others => '0');

			internal_buffer      <= (others => '0');
			internal_buffer_dual <= (others => '0');
			internal_data_dual   <= (others => '0');
			dual_write_delay     <= '1';

			buffer_load_pointer      <= 0;
			buffer_load_pointer_dual <= 0;
			destin_we                <= '0';
			destin_we_reg            <= '0';
			dual_we                  <= '0';
			dual_we_reg              <= '0';
			tcpa_config_done         <= '0';

			sync_flag           <= '0';
			preload_config_done <= '1';

			count_down_ready <= '1';

			clear_mask_registers <= '0';

			COUNT_DOWN_register  <= (others => '0');
			CONFIG_TYPE_register <= (others => '0');

			config_type_loaded  <= '0';
			get_new_config_type <= '0';
			count_down_loaded   <= '0';

			vliw_config_end_addr_loaded <= '0';
			icn_config_end_addr_loaded  <= '0';
			sig_vliw_config_en           <= '0';
			sig_icn_config_en           <= '0';

			------------------------------------
			loader_nextstate <= INITIAL;
			------------------------------------

		else
			if clk'event and clk = '1' then
				sig_vliw_config_en <= vliw_config_en;
				sig_icn_config_en <= icn_config_en;
				set_to_config_reg <= sig_set_to_config;
		 		destin_addr_out <= internal_destin_addr;
				destin_data_out <= internal_buffer(DESTIN_DATA_WIDTH - 1 downto 0);
				dual_destin_out <= internal_data_dual;
				dual_we   <= dual_we_reg;
				destin_we <= destin_we_reg;

				--When tcpa_config_done is '0' means that the entire TCPA is already configured. During the configuration step common_config_reset is '1'
				tcpa_config_done <= not common_config_reset;

				case loader_nextstate is
					-- ======================================================================================						
					when INITIAL =>
						idle <= '0';
						dual_we_reg <= '0';

						internal_destin_addr <= (others => '0');
						internal_buffer      <= (others => '0');
						internal_buffer_dual <= (others => '0');
						internal_data_dual   <= (others => '0');
						clear_mask_registers <= '0';

						--The value '0' means that all PEs are already configured or there is nothing to reconfigure
						if (common_config_reset = '0') then
							memory_configured    <= vliw_config_done and icn_config_done; 
						end if;

						--if vliw_config_done = '0' and set_to_config_reg = '1' then
						if internal_reset = '1' and set_to_config_reg = '1' then

							--					internal_source_addr <= conv_std_logic_vector(INIT_SOURCE_ADDR, SOURCE_ADDR_WIDTH);
							buffer_load_pointer      <= 0;
							buffer_load_pointer_dual <= 0;
							destin_we_reg                <= '0';
							dual_we_reg              <= '0';

							if config_type_loaded = '0' then
							------------------------------------
								loader_nextstate <= LOAD_CONFIG_TYPE;
							------------------------------------
							else
								------------------------------------
								loader_nextstate <= LOAD_BUFFER;
								------------------------------------
							end if;

						elsif icn_config_done = '0' and set_to_config_reg = '1' then
							--					internal_source_addr <= conv_std_logic_vector(INIT_SOURCE_ADDR, SOURCE_ADDR_WIDTH);
							buffer_load_pointer      <= 0;
							buffer_load_pointer_dual <= 0;
							destin_we_reg                <= '0';
							dual_we_reg              <= '0';

							if config_type_loaded = '0' then

								------------------------------------
								loader_nextstate <= LOAD_CONFIG_TYPE;
								------------------------------------
							else
								------------------------------------
								loader_nextstate <= LOAD_BUFFER_DUAL;
							------------------------------------
							end if;

						elsif count_down_ready = '0' and set_to_config_reg = '1' then
							config_type_loaded          <= '0';
							vliw_config_end_addr_loaded <= '0';
							icn_config_end_addr_loaded  <= '0';

							------------------------------------
							loader_nextstate <= WAIT_STATE; --COUNT_DOWN_STATE;
							------------------------------------


						----------------------------------------------------------	

						elsif set_to_config_reg = '1' then
							----------------------------------------------------------					
							--vliw_config_done   <= '0'; --NOT set_to_config; 
							--icn_config_done    <= '0'; --NOT set_to_config;
							count_down_ready   <= '0'; --NOT set_to_config;
							config_type_loaded <= '0'; --NOT set_to_config;

							vliw_config_end_addr_loaded <= '0';
							icn_config_end_addr_loaded  <= '0';

							---------------------------
							internal_reset    <= '1'; --set_to_config;
							memory_configured <= '0';
							---------------------------

							------------------------------------
							loader_nextstate <= INITIAL;
							------------------------------------						
						else

							--					internal_source_addr <= (others => '0');
							buffer_load_pointer      <= 0;
							buffer_load_pointer_dual <= 0;
							destin_we_reg                <= '0';
							dual_we_reg              <= '0';

							------------------------------------
							loader_nextstate <= INITIAL;
							idle             <= '1';
						------------------------------------

						end if;
					-- ======================================================================================						
					when LOAD_CONFIG_TYPE =>
						if config_type_loaded = '0' then
							CONFIG_TYPE_register <= source_data_in_reg;

							case conv_integer(source_data_in_reg) is
								when 0 =>
									current_configuration_type <= NO_CONFIGURATION;

								when 1 =>
									current_configuration_type <= VLIW_MEMORY_CONFIG;

								when 2 =>
									current_configuration_type <= ICN_CONFIG;

								when 3 =>
									current_configuration_type <= PRELOAD_CONFIG;

								when 4 =>
									current_configuration_type <= VLIW_AND_ICN;

								when 5 =>
									current_configuration_type <= VLIW_AND_PRELOAD;

								when 6 =>
									current_configuration_type <= ICN_AND_PRELOAD;

								when 7 =>
									current_configuration_type <= VLIW_AND_ICN_AND_PRELOAD;

								when others =>
									current_configuration_type <= NO_CONFIGURATION;

							end case;

							config_type_loaded <= '1';

							------------------------------------
							loader_nextstate <= LOAD_CONFIG_TYPE;
						------------------------------------

						else
							case current_configuration_type is
								when NO_CONFIGURATION =>

									------------------------------------
									loader_nextstate <= COUNT_DOWN_STATE;
									------------------------------------ 
--									if vliw_config_done = '1' then
--										icn_config_done     <= '1';
--									end if;
								--	vliw_config_done    <= '1';
								--	icn_config_done     <= '1';
									preload_config_done <= '1';

								when VLIW_MEMORY_CONFIG =>

									------------------------------------
									loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR; --LOAD_COUNT_DOWN; 
									------------------------------------ 

									vliw_config_done    <= '0';
									icn_config_done     <= '1';
									preload_config_done <= '1';

								when ICN_CONFIG =>
									------------------------------------
									loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR; --LOAD_COUNT_DOWN; 
									------------------------------------ 

									vliw_config_done    <= '1';
									icn_config_done     <= '0';
									preload_config_done <= '1';

								when PRELOAD_CONFIG =>
									------------------------------------
									loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR; --LOAD_COUNT_DOWN; 
									------------------------------------ 

									vliw_config_done    <= '1';
									icn_config_done     <= '1';
									preload_config_done <= '0';

								when VLIW_AND_ICN =>
									------------------------------------
									loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR; --LOAD_COUNT_DOWN; 
									------------------------------------ 

									vliw_config_done    <= '0';
									icn_config_done     <= '0';
									preload_config_done <= '1';

								when VLIW_AND_PRELOAD =>
									------------------------------------
									loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR; --LOAD_COUNT_DOWN; 
									------------------------------------ 

									vliw_config_done    <= '0';
									icn_config_done     <= '1';
									preload_config_done <= '0';

								when ICN_AND_PRELOAD =>
									------------------------------------
									loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR; --LOAD_COUNT_DOWN; 
									------------------------------------ 

									vliw_config_done    <= '1';
									icn_config_done     <= '0';
									preload_config_done <= '0';

								when VLIW_AND_ICN_AND_PRELOAD =>
									------------------------------------
									loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR; --LOAD_COUNT_DOWN; 
									------------------------------------ 

									vliw_config_done    <= '0';
									icn_config_done     <= '0';
									preload_config_done <= '0';

								when others =>
									------------------------------------
									loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR; --LOAD_COUNT_DOWN; 
									------------------------------------ 

									vliw_config_done    <= '1';
									icn_config_done     <= '1';
									preload_config_done <= '1';

							end case;

						end if;

					-- ======================================================================================						
					when LOAD_VLIW_CONFIG_END_ADDR =>
						if vliw_config_end_addr_loaded = '0' then
							VLIW_DATA_END_ADDR_register <= source_data_in_reg;
							vliw_config_end_addr_loaded <= '1';

							------------------------------------
							loader_nextstate <= LOAD_VLIW_CONFIG_END_ADDR;
						------------------------------------

						else
							VLIW_DATA_END_ADDR_register <= VLIW_DATA_END_ADDR_register;

							------------------------------------
							loader_nextstate <= LOAD_ICN_CONFIG_END_ADDR;
						------------------------------------


						end if;

					-- ======================================================================================						
					when LOAD_ICN_CONFIG_END_ADDR =>

						-- BUG FIXING 28.9.2009
						count_down_loaded <= '0';

						if icn_config_end_addr_loaded = '0' then
							ICN_DATA_END_ADDR_register <= source_data_in_reg;
							ICN_config_end_addr_loaded <= '1';

							------------------------------------
							loader_nextstate <= LOAD_ICN_CONFIG_END_ADDR;
						------------------------------------

						else
							ICN_DATA_END_ADDR_register <= ICN_DATA_END_ADDR_register;

							------------------------------------
							loader_nextstate <= LOAD_COUNT_DOWN;
						------------------------------------


						end if;

					-- ======================================================================================						
					when LOAD_COUNT_DOWN =>
						if count_down_loaded = '0' then

							-- BUG FIXING 28.9.2009
							COUNT_DOWN_register <= source_data_in_reg;

							count_down_loaded <= '1';
						--					
						--					------------------------------------
						--					loader_nextstate   <= LOAD_COUNT_DOWN; 
						--					-----------------------------------
						--				
						else
							COUNT_DOWN_register <= COUNT_DOWN_register;

						end if;

						if vliw_config_done = '0' then

							------------------------------------
							loader_nextstate <= LOAD_BUFFER;
							------------------------------------

						elsif icn_config_done = '0' then
							if count_down_loaded = '0' then

								-- BUG FIXING 28.9.2009
								COUNT_DOWN_register <= source_data_in_reg;
								count_down_loaded <= '1';

							else
								COUNT_DOWN_register <= COUNT_DOWN_register;
								------------------------------------
								loader_nextstate <= LOAD_BUFFER_DUAL;
								------------------------------------
							end if;

						else

							------------------------------------
							loader_nextstate <= INITIAL;
						------------------------------------

						end if;

					-- ======================================================================================						
					when WAIT_STATE =>
						if set_to_config_reg = '0' then

							------------------------------------
							loader_nextstate <= WAIT_STATE;
							idle             <= '1';
						------------------------------------
						else
							idle <= '0';

							if get_new_config_type = '0' then

								-- DELAY 1 CYCLE
								get_new_config_type <= '1';

								------------------------------------
								loader_nextstate <= WAIT_STATE;
							------------------------------------

							else
								get_new_config_type <= '0';

								------------------------------------
								loader_nextstate <= LOAD_CONFIG_TYPE;
							------------------------------------

							end if;

						end if;
					-- ======================================================================================						
					when COUNT_DOWN_STATE =>
						if COUNT_DOWN_register > 0 then
							count_down_ready <= '0';

							COUNT_DOWN_register <= COUNT_DOWN_register - 1;

							------------------------------------
							loader_nextstate <= COUNT_DOWN_STATE;
						------------------------------------

						else
							count_down_ready  <= '1';
							count_down_loaded <= '0';

							------------------------------------
							loader_nextstate <= INITIAL;
						------------------------------------

						end if;

					-- ======================================================================================						

					when LOAD_BUFFER =>

						--				-- Resetting the ..._dual signals
						--				icn_config_done <= '0';	
						--				buffer_load_pointer_dual <= 0;
						--				internal_buffer_dual <= (others => '0');
						--				internal_data_dual <= (others => '0');
						--				dual_we_reg <= '0';
						--				

						if buffer_load_pointer = DESTIN_SOURCE_RATIO then
							buffer_load_pointer <= 0;
							destin_we_reg           <= '1';
							vliw_config_done    <= '0';

							------------------------------------
							loader_nextstate <= WRITE_BACK;
							------------------------------------

						else
							vliw_config_done <= '0';
							destin_we_reg        <= '0';
							if vliw_config_en = '1' then
									internal_buffer(SOURCE_DATA_WIDTH * (buffer_load_pointer + 1) - 1 downto SOURCE_DATA_WIDTH * buffer_load_pointer) <= source_data_in_reg(SOURCE_DATA_WIDTH - 1 downto 0);
									buffer_load_pointer <= buffer_load_pointer + 1;
							end if;
							loader_nextstate <= LOAD_BUFFER;
						end if;

					-- ======================================================================================						

					when WRITE_BACK =>

						--				-- Resetting the ..._dual signals
						--				icn_config_done <= '0';	
						--				buffer_load_pointer_dual <= 0;
						--				internal_buffer_dual <= (others => '0');
						--				internal_data_dual <= (others => '0');
						--				dual_we_reg <= '0';
						--
						destin_we_reg <= '0';

						if ((conv_integer(internal_destin_addr) + 1) * DESTIN_SOURCE_RATIO = conv_integer(VLIW_DATA_END_ADDR_register)) then
							if clear_mask_registers = '0' then

								----------------------------
								-- CLEAR MASK REGISTERS !!!
								----------------------------
								clear_mask_registers <= '1';

								------------------------------------
								loader_nextstate <= WRITE_BACK;
							------------------------------------

							else
								internal_destin_addr <= (others => '0');
								-- DO NOT CLEAR THE SOURCE ADDR REGISTER,
								-- BECAUSE CONFIGURATION DATA FOLLOWS !!!
								--					--	internal_source_addr <= (others => '0');
								buffer_load_pointer  <= 0;
								vliw_config_done     <= '1';

								--memory_configured <= '1';

								---------------------------
								internal_reset <= '0';
								---------------------------

								------------------------------------
								loader_nextstate <= INITIAL;
							------------------------------------

							end if;

						else
							vliw_config_done     <= '0';
							internal_destin_addr <= internal_destin_addr + 1;

							------------------------------------
							loader_nextstate <= LOAD_BUFFER;
							------------------------------------
	
						end if;

					-- ======================================================================================		

					when LOAD_BUFFER_DUAL =>
						internal_reset    <= '1';
						icn_config_done <= '0';
						buffer_load_pointer_dual <= 0;
						if sig_icn_config_en = '1' then
							------------------------------------
							loader_nextstate <= WRITE_BACK_DUAL;
							------------------------------------
						end if;
					-- ======================================================================================	
					when WRITE_BACK_DUAL =>
						if sig_icn_config_en = '0' then
							buffer_load_pointer_dual <= 0;
							internal_reset  <= '0';
							icn_config_done <= '1';
							------------------------------------
							loader_nextstate <= INITIAL;
							------------------------------------
						else
							dual_we_reg <= '1';
							buffer_load_pointer_dual <= buffer_load_pointer_dual + 1;
						end if;
						internal_data_dual(DUAL_DATA_WIDTH - 1 downto 0) <= source_data_in_reg(DUAL_DATA_WIDTH - 1 downto 0);
                                                internal_destin_addr <= conv_std_logic_vector(buffer_load_pointer_dual, internal_destin_addr'length);
					-- ======================================================================================							
					when others =>

						--internal_source_addr <= (others => '0');
						internal_destin_addr <= (others => '0');

						destin_we_reg <= '0';
						dual_we_reg   <= '0';

						vliw_config_done    <= '0';
						internal_buffer     <= (others => '0');
						buffer_load_pointer <= 0;

						icn_config_done          <= '0';
						internal_buffer_dual     <= (others => '0');
						internal_data_dual       <= (others => '0');
						buffer_load_pointer_dual <= 0;

						------------------------------------
						loader_nextstate <= INITIAL;
						------------------------------------

				-- ======================================================================================											

				end case;

			end if;
		end if;

	end process;

-- ======================================================================================						
-- ======================================================================================						


end Behavioral;
