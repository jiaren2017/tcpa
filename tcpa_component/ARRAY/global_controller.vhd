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
-- Create Date:    11:11:49 02/21/06
-- Design Name:    
-- Module Name:    GLOBAL_CONTROLLER - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


library wppa_instance_v1_01_a;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

entity GLOBAL_CONTROLLER is
	generic(

		-- cadence translate_off	
		INSTANCE_NAME     : string                                                           := "?";

		-- cadence translate_on	
		--###########################################################################
		-- Bus protocol parameters, do not add to or delete
		--###########################################################################
		C_AWIDTH          : integer                                                          := 32;
		C_DWIDTH          : integer                                                          := 32;
		C_NUM_CE          : integer                                                          := 16;
		--###########################################################################


		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

		------------------------------------------                  
		-- VERTICAL number of WPPEs in the array
		N                 : integer range MIN_NUM_WPPE_VERTICAL to MAX_NUM_WPPE_VERTICAL     := CUR_DEFAULT_NUM_WPPE_VERTICAL;
		------------------------------------------
		-- HORIZONTAL number of WPPEs in the array
		M                 : integer range MIN_NUM_WPPE_HORIZONTAL to MAX_NUM_WPPE_HORIZONTAL := CUR_DEFAULT_NUM_WPPE_HORIZONTAL;
		------------------------------------------                  

		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		-- Generic variables of the OCB bus to external processor core

		BUS_ADDR_WIDTH    : integer range MIN_BUS_ADDR_WIDTH to MAX_BUS_ADDR_WIDTH           := CUR_DEFAULT_BUS_ADDR_WIDTH;
		BUS_DATA_WIDTH    : integer range MIN_BUS_DATA_WIDTH to MAX_BUS_DATA_WIDTH           := CUR_DEFAULT_BUS_DATA_WIDTH;

		SOURCE_DATA_WIDTH : positive range 1 to 128                                          := CUR_DEFAULT_SOURCE_DATA_WIDTH;
		SOURCE_ADDR_WIDTH : positive range 1 to MAX_ADDR_WIDTH                               := CUR_DEFAULT_SOURCE_ADDR_WIDTH
	);

	port(

		--###########################################################################
		-- OPB  BUS  INTERFACE SIGNALS
		--###########################################################################
		Bus2IP_Addr                   : in  std_logic_vector(0 to C_AWIDTH - 1);
		Bus2IP_Data                   : in  std_logic_vector(0 to C_DWIDTH - 1);
		Bus2IP_BE                     : in  std_logic_vector(0 to C_DWIDTH / 8 - 1);
		Bus2IP_RdCE                   : in  std_logic_vector(0 to C_NUM_CE - 1);
		Bus2IP_WrCE                   : in  std_logic_vector(0 to C_NUM_CE - 1);
		IP2Bus_Data                   : out std_logic_vector(0 to C_DWIDTH - 1);
		--###########################################################################

		debug_registers               : in  std_logic_vector((C_NUM_CE - 9) * C_DWIDTH - 1 downto 0);

		clk                           : in  std_logic;
		rst                           : in  std_logic;

		--        pso_powergood_global :in std_logic;

		--        -- WISHBONE signals to external processor core
		--        ADDR_I :in std_logic_vector(BUS_ADDR_WIDTH -1 downto 0);
		--        DATA_I :in std_logic_vector(BUS_DATA_WIDTH -1 downto 0);
		--        DATA_O :out std_logic_vector(BUS_DATA_WIDTH -1 downto 0);
		--        WE_I     :in std_logic;
		--
		-- (Re-)Configuration-enable bit vector
		-- vertical
		CONFIGURATION_MASK_VERTICAL   : out std_logic_vector(1 to M); --N);

		-- (Re-)Configuration-enable bit vector
		-- horizontal
		CONFIGURATION_MASK_HORIZONTAL : out std_logic_vector(1 to N); --M);                    

		source_data_in                : in  std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);
		source_data_out               : out std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);
		-- Address signal to external global configuration memory
		source_addr_out               : out std_logic_vector(SOURCE_ADDR_WIDTH - 1 downto 0);

		ALGO_TYPE_out                 : out std_logic;

		common_config_reset           : out std_logic;
		vliw_config_en                : out std_logic;
		icn_config_en                 : out std_logic;
		config_done                   : out std_logic
	);

end GLOBAL_CONTROLLER;

architecture Behavioral of GLOBAL_CONTROLLER is
	CONSTANT NULL_VECTOR : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0) := (others => '0');
	CONSTANT EINS_VECTOR : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0) := (others => '1');

	--###########################################################################
	-- 	O P B   S I G N A L S 
	--###########################################################################

	signal slv_reg11 : std_logic_vector(0 to C_DWIDTH - 1);
	signal slv_reg12 : std_logic_vector(0 to C_DWIDTH - 1);
	signal slv_reg13 : std_logic_vector(0 to C_DWIDTH - 1);
	signal slv_reg14 : std_logic_vector(0 to C_DWIDTH - 1);
	signal slv_reg15 : std_logic_vector(0 to C_DWIDTH - 1);

	signal reversed_slv_reg11 : std_logic_vector(C_DWIDTH - 1 downto 0);
	signal reversed_slv_reg12 : std_logic_vector(C_DWIDTH - 1 downto 0);
	signal reversed_slv_reg13 : std_logic_vector(C_DWIDTH - 1 downto 0);
	signal reversed_slv_reg14 : std_logic_vector(C_DWIDTH - 1 downto 0);
	signal reversed_slv_reg15 : std_logic_vector(C_DWIDTH - 1 downto 0);

	signal slv_reg_write_select : std_logic_vector(0 to 15);
	signal slv_reg_read_select  : std_logic_vector(0 to 15);
	signal sig_current_source_dual_ratio : integer;
	signal sig_current_icn_data_en : integer;
	--###########################################################################
	--###########################################################################
	signal clear_mask_registers : std_logic;

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

	type controller_state_type is (
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
		--
		LOAD_BUFFER_DUAL,               -- 6
		--
		WRITE_BACK,                     -- 7
		WRITE_BACK_DUAL                 -- 8
--                  
);

	signal Bus2IP_Addr_reg                   : std_logic_vector(0 to C_AWIDTH - 1);
	signal Bus2IP_Data_reg                   : std_logic_vector(0 to C_DWIDTH - 1);
	signal Bus2IP_BE_reg                     : std_logic_vector(0 to C_DWIDTH / 8 - 1);
	signal Bus2IP_RdCE_reg                   : std_logic_vector(0 to C_NUM_CE - 1);
	signal Bus2IP_WrCE_reg                   : std_logic_vector(0 to C_NUM_CE - 1);
	signal source_data_in_reg                : std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);
	signal debug_registers_reg               : std_logic_vector((C_NUM_CE - 9) * C_DWIDTH - 1 downto 0);
	signal IP2Bus_Data_reg                   : std_logic_vector(0 to C_DWIDTH - 1);
	signal CONFIGURATION_MASK_VERTICAL_reg   : std_logic_vector(1 to M); --N);
	signal CONFIGURATION_MASK_HORIZONTAL_reg : std_logic_vector(1 to N); --M);                    
	signal source_data_out_reg               : std_logic_vector(SOURCE_DATA_WIDTH - 1 downto 0);
	signal source_addr_out_reg               : std_logic_vector(SOURCE_ADDR_WIDTH - 1 downto 0);
	signal ALGO_TYPE_out_reg                 : std_logic;
	signal common_config_reset_reg           : std_logic;
	signal vliw_config_en_reg                : std_logic;
	signal icn_config_en_reg                 : std_logic;
	signal config_done_reg                   : std_logic;

	signal controller_nextstate : controller_state_type;

	signal internal_source_addr : std_logic_vector(SOURCE_ADDR_WIDTH - 1 downto 0);

	signal everything_configured : std_logic;
	signal vliw_config_done      : std_logic;
	signal icn_config_done       : std_logic;
	signal preload_config_done   : std_logic;

	signal config_type_loaded : std_logic;

	signal vliw_config_end_addr_loaded : std_logic;
	signal icn_config_end_addr_loaded  : std_logic;

	signal buffer_load_pointer      : integer;-- range 0 to 512;
	signal buffer_load_pointer_dual : integer;-- range 0 to 512;

	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	-- (RE-)CONFIGURATION REGISTERS FOR CURRENT
	-- DESTIN_VLIW_MEMORY WIDTH to SOURCE_MEMORY WIDTH
	-- RATIO
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	-- The DESTIN_VLIW_DATA_WIDTH is supposed to be always bigger than SOURCE_DATA_WIDTH,
	-- and the DESTIN_SOURCE_RATIO >= 1
	-- It will be used to configure the VLIW program memory (DESTIN_DATA_WIDTH) from a
	-- source memory, that is much smaller in data width (SOURCE_DATA_WIDTH << DESTIN_DATA_WIDTH);
	-- DESTIN_DATA_WIDTH / SOURCE_DATA_WIDTH;
	signal DESTIN_SOURCE_RATIO_register          : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_DESTIN_SOURCE_RATIO_register : std_logic_vector(0 to BUS_DATA_WIDTH - 1);

	-- The DUAL_DATA_WIDTH is supposed to be always smaller than SOURCE_DATA_WIDTH,
	-- and the SOURCE_DUAL_RATIO >= 1
	-- It will be used to pre-configure/initialize the register file and the
	-- interconnect-wrapper registers (DUAL_DATA_WIDTH) from a
	-- source memory, that is much bigger in data width (SOURCE_DATA_WIDTH > DUAL_DATA_WIDTH);
	signal SOURCE_DUAL_RATIO_register          : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_SOURCE_DUAL_RATIO_register : std_logic_vector(0 to BUS_DATA_WIDTH - 1);

	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	-- (RE-)CONFIGURATION REGISTERS FOR THE ADDRESS OF THE CURRENT
	-- CONFIGURATION DATA IN THE GLOBAL MEMORY, 
	-- and the BOUNDARY ADDRESSES of the VLIW, PRELOAD, 
	-- and INTERCONNECT configuration data
	-- in the current configuration to be loaded
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	signal CURRENT_CONFIG_START_ADDR_register                  : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_CURRENT_CONFIG_START_ADDR_register         : std_logic_vector(0 to BUS_DATA_WIDTH - 1);
	----------------------------------------------------
	signal CURRENT_DESTIN_VLIW_DATA_END_ADDR_register          : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_CURRENT_DESTIN_VLIW_DATA_END_ADDR_register : std_logic_vector(0 to BUS_DATA_WIDTH - 1);

	signal CURRENT_DESTIN_ICN_DATA_END_ADDR_register          : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_CURRENT_DESTIN_ICN_DATA_END_ADDR_register : std_logic_vector(0 to BUS_DATA_WIDTH - 1);

	signal CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register          : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register : std_logic_vector(0 to BUS_DATA_WIDTH - 1);

	signal COUNT_DOWN_register           : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_COUNT_DOWN_register  : std_logic_vector(0 to BUS_DATA_WIDTH - 1);
	----------------------------------------------------
	signal CONFIG_TYPE_register          : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_CONFIG_TYPE_register : std_logic_vector(0 to BUS_DATA_WIDTH - 1);

	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	-- (RE-)CONFIGURATION REGISTERS FOR THE MASK DATA
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	signal VERTICAL_MASK_register            : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_VERTICAL_MASK_register   : std_logic_vector(0 to BUS_DATA_WIDTH - 1);
	---------------------------------------------
	signal HORIZONTAL_MASK_register          : std_logic_vector(BUS_DATA_WIDTH - 1 downto 0);
	signal reversed_HORIZONTAL_MASK_register : std_logic_vector(0 to BUS_DATA_WIDTH - 1);

	---------------------------------------------
	signal ALGO_TYPE_register          : std_logic_vector(C_DWIDTH - 1 downto 0);
	signal reversed_ALGO_TYPE_register : std_logic_vector(0 to C_DWIDTH - 1);
	---------------------------------------------

	signal result_fifo_read_en    : std_logic;
	signal result_fifo_write_en   : std_logic;
	signal fifo_write_data        : std_logic_vector(C_DWIDTH - 1 downto 0);
	signal fifo_read_data         : std_logic_vector(C_DWIDTH - 1 downto 0);
	signal fifo_full, fifo_empty  : std_logic;
	signal internal_slv_reg11     : std_logic_vector(C_DWIDTH - 1 downto 0);
	signal old_internal_slv_reg11 : std_logic_vector(C_DWIDTH - 1 downto 0);
	
	signal internal_config_done : std_logic;
	signal first_clear          : std_logic;
	signal final_clear          : std_logic;
	signal zero_signal          : std_logic;

	signal pwr_up_counter        : std_logic_vector(2 downto 0); -- POWER UP sequence counter, max. 8 cycles;
	signal pwr_up_ready          : std_logic;
	signal pwr_up_sequence_start : std_logic;

	signal count_down_loaded : std_logic;

--### ARCHITECTURE BEGIN ###

--#######
--#######
BEGIN                                   --##
	--#######
	--#######

	--############################################################
	--############################################################

	--pwr_up_ready   <= '1';  

	wait_for_pwr_up_sequence : process(clk, rst)
	begin
		if rst = '1' then

			-- wait for POWER_UP_CYCLE_COUNT number of cycles to power up sleeping PEs			
			pwr_up_counter <= conv_std_logic_vector(POWER_UP_CYCLE_COUNT, 3);

			if POWER_GATING then
				pwr_up_ready <= '0';
			else
				pwr_up_ready <= '1';
			end if;

		else
			if clk'event and clk = '1' then
				if POWER_GATING and pwr_up_sequence_start = '1' then --and pwr_up_ready = '0' then

					if (pwr_up_counter = "000") then
						pwr_up_ready <= '1';

					else
						pwr_up_counter <= pwr_up_counter - 1;
						pwr_up_ready   <= '0';

					end if;

				else
					pwr_up_counter <= conv_std_logic_vector(POWER_UP_CYCLE_COUNT, 3);

					if POWER_GATING then
						pwr_up_ready <= '0';
					else
						pwr_up_ready <= '1';
					end if;

				end if;

			end if;
		end if;

	end process wait_for_pwr_up_sequence;

	--############################################################
	--############################################################


	--config_done_reg <= internal_config_done;

	--set_first_clear :process(clear_mask_registers)
	--begin	 
	--if clear_mask_registers = '1' then
	-- second_clear <= '1';
	--end if;
	--end process;
	--

	set_everything_configured : process(vliw_config_done, icn_config_done, current_configuration_type, preload_config_done)
	begin
		case current_configuration_type is
			when NO_CONFIGURATION =>
				everything_configured <= '1';

			when VLIW_MEMORY_CONFIG =>
				everything_configured <= vliw_config_done;

			when ICN_CONFIG =>
				everything_configured <= icn_config_done;

			when PRELOAD_CONFIG =>
				everything_configured <= preload_config_done;

			when VLIW_AND_ICN =>
				everything_configured <= vliw_config_done AND icn_config_done;

			when VLIW_AND_PRELOAD =>
				everything_configured <= vliw_config_done AND preload_config_done;

			when ICN_AND_PRELOAD =>
				everything_configured <= icn_config_done AND preload_config_done;

			when VLIW_AND_ICN_AND_PRELOAD =>
				everything_configured <= vliw_config_done AND icn_config_done AND preload_config_done;

			when others =>
				everything_configured <= '1';

		end case;

	end process;

	set_config_done : process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				config_done_reg <= '0';
				first_clear <= '0';
				zero_signal <= '0';
			else
				first_clear <= internal_config_done; --clear_mask_registers;
				config_done_reg <= (internal_config_done OR first_clear or zero_signal) AND everything_configured;
			end if;
		end if;
	end process;
	--
	--result_fifo :fifo_common_clock
	--
	--	generic map(
	--		 	
	--			LUT_RAM_TYPE => '1',
	--		 	DATA_WIDTH	 => C_DWIDTH,
	--		 	ADDR_WIDTH   => 10,
	--		 	FIFO_SIZE	 => 4
	--	)
	--
	--	port map(
	--		
	--		 clk => clk,
	--		 rst => rst,
	--		 read_enable_in  => result_fifo_read_en,  
	--		 write_enable_in => result_fifo_write_en, 
	--		 write_data_in   => fifo_write_data,   
	--		 read_data_out   => fifo_read_data,   
	--		 full_out        => fifo_full, 
	--		 empty_out       => fifo_empty
	--
	--	);

	PPC_CHECK_F_GLB_CFG_CONTROLLER : IF not CONFIG_PPC GENERATE
		--===============================================================
		--===============================================================

		CONNECT_VERTICAL_CONF_BITS : FOR i in 0 to M - 1 GENERATE
			CONFIGURATION_MASK_VERTICAL_REG(M - i) <= VERTICAL_MASK_register(i);

		END GENERATE CONNECT_VERTICAL_CONF_BITS;

		--===============================================================
		--===============================================================

		CONNECT_HORIZONTAL_CONF_BITS : FOR i in 0 to N - 1 GENERATE
			CONFIGURATION_MASK_HORIZONTAL_REG(N - i) <= HORIZONTAL_MASK_register(i);

		END GENERATE CONNECT_HORIZONTAL_CONF_BITS;

	--===============================================================
	--===============================================================


	--	--===============================================================
	--	--===============================================================
	--
	--	CONNECT_VERTICAL_CONF_BITS :FOR i in 0 to M-1 GENERATE            
	--
	--		CONFIGURATION_MASK_VERTICAL_REG(M-i) <= HORIZONTAL_MASK_register(i);
	--
	--	END GENERATE CONNECT_VERTICAL_CONF_BITS;
	--
	--	--===============================================================
	--	--===============================================================
	--
	--	CONNECT_HORIZONTAL_CONF_BITS :FOR i in 0 to N-1 GENERATE          
	--
	-- 		CONFIGURATION_MASK_HORIZONTAL_REG(N-i) <= VERTICAL_MASK_register(i);
	--
	--	END GENERATE CONNECT_HORIZONTAL_CONF_BITS;
	--
	--	--===============================================================
	--	--===============================================================
	END GENERATE PPC_CHECK_F_GLB_CFG_CONTROLLER;

	-- INVERT THE BITS IF PROGRAMMED BY PowerPC (little endian)
	PPC_CHECK_GLB_CFG_CONTROLLER : IF CONFIG_PPC GENERATE
		--===============================================================
		--===============================================================

		CONNECT_VERTICAL_CONF_BITS : FOR i in 0 to M - 1 GENERATE
			CONFIGURATION_MASK_VERTICAL_REG(M - i) <= HORIZONTAL_MASK_register(i);

		END GENERATE CONNECT_VERTICAL_CONF_BITS;

		--===============================================================
		--===============================================================

		CONNECT_HORIZONTAL_CONF_BITS : FOR i in 0 to N - 1 GENERATE
			CONFIGURATION_MASK_HORIZONTAL_REG(N - i) <= VERTICAL_MASK_register(i);

		END GENERATE CONNECT_HORIZONTAL_CONF_BITS;

	--===============================================================
	--===============================================================

	--	--===============================================================
	--	--===============================================================
	--
	--	CONNECT_VERTICAL_CONF_BITS :FOR i in 0 to N-1 GENERATE            
	--
	--		CONFIGURATION_MASK_VERTICAL_REG(N-i) <= VERTICAL_MASK_register(i);
	--
	--	END GENERATE CONNECT_VERTICAL_CONF_BITS;
	--
	--	--===============================================================
	--	--===============================================================
	--
	--	CONNECT_HORIZONTAL_CONF_BITS :FOR i in 0 to M-1 GENERATE          
	--
	-- 		CONFIGURATION_MASK_HORIZONTAL_REG(M-i) <= HORIZONTAL_MASK_register(i);
	--
	--	END GENERATE CONNECT_HORIZONTAL_CONF_BITS;
	--
	--	--===============================================================
	--	--===============================================================

	END GENERATE PPC_CHECK_GLB_CFG_CONTROLLER;

	--###########################################################################
	--  O P B   s i g n a l   c o n n e c t i o n s 
	--###########################################################################

	slv_reg_write_select <= Bus2IP_WrCE_reg(0 to 15);
	slv_reg_read_select  <= Bus2IP_RdCE_reg(0 to 15);

	--						slv_reg10 <= debug_registers_reg(3*C_DWIDTH -1 downto 2*C_DWIDTH);	-- NORTH out
	--						slv_reg11 <= debug_registers_reg(4*C_DWIDTH -1 downto 3*C_DWIDTH);					 
	--						slv_reg12 <= debug_registers_reg(5*C_DWIDTH -1 downto 4*C_DWIDTH);
	--						slv_reg13 <= debug_registers_reg(6*C_DWIDTH -1 downto 5*C_DWIDTH);
	--						slv_reg14 <= debug_registers_reg(7*C_DWIDTH -1 downto 6*C_DWIDTH);
	--						slv_reg15 <= debug_registers_reg(8*C_DWIDTH -1 downto 7*C_DWIDTH);
	--

	----------------------------------------------------------------------------
	REVERSE_DATA : FOR i in 1 to C_DWIDTH GENERATE
		----------------------------------------------------------------------------

		DESTIN_SOURCE_RATIO_register(i - 1) -- R E G I S T E R  0
		<= reversed_DESTIN_SOURCE_RATIO_register(C_DWIDTH - i);

		SOURCE_DUAL_RATIO_register(i - 1) -- R E G I S T E R  1
		<= reversed_SOURCE_DUAL_RATIO_register(C_DWIDTH - i);

		CURRENT_CONFIG_START_ADDR_register(i - 1) -- R E G I S T E R  2
		<= reversed_CURRENT_CONFIG_START_ADDR_register(C_DWIDTH - i);

		CURRENT_DESTIN_VLIW_DATA_END_ADDR_register(i - 1) -- R E G I S T E R  3
		<= reversed_CURRENT_DESTIN_VLIW_DATA_END_ADDR_register(C_DWIDTH - i);

		CURRENT_DESTIN_ICN_DATA_END_ADDR_register(i - 1) -- R E G I S T E R  4
		<= reversed_CURRENT_DESTIN_ICN_DATA_END_ADDR_register(C_DWIDTH - i);

		CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register(i - 1) -- R E G I S T E R  5	 
		<= reversed_CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register(C_DWIDTH - i);

		VERTICAL_MASK_register(i - 1)   -- R E G I S T E R  6
		<= reversed_VERTICAL_MASK_register(C_DWIDTH - i);

		HORIZONTAL_MASK_register(i - 1) -- R E G I S T E R  7
		<= reversed_HORIZONTAL_MASK_register(C_DWIDTH - i);

		COUNT_DOWN_register(i - 1)      -- R E G I S T E R  8
		<= reversed_COUNT_DOWN_register(C_DWIDTH - i);

		CONFIG_TYPE_register(i - 1)     -- R E G I S T E R  9
		<= reversed_CONFIG_TYPE_register(C_DWIDTH - i);

		ALGO_TYPE_register(i - 1)       -- R E G I S T E R  10 ALGO_TYPE
		<= reversed_ALGO_TYPE_register(C_DWIDTH - i);

		--################################################################
		--    ONLY READS to reversed_slv_regxx FROM OPB BUS POSSIBLE
		--    Because they are written from the slv_regxx,
		--    which are set by the WPPA logic
		--################################################################

		reversed_slv_reg11(i - 1) <= slv_reg11(C_DWIDTH - i);

		reversed_slv_reg12(i - 1) <= slv_reg12(C_DWIDTH - i);

		reversed_slv_reg13(i - 1) <= slv_reg13(C_DWIDTH - i);

		reversed_slv_reg14(i - 1) <= slv_reg14(C_DWIDTH - i);

		reversed_slv_reg15(i - 1) <= slv_reg15(C_DWIDTH - i);

	END GENERATE;

	--###########################################################################
	--###########################################################################


	--===============================================================
	-- CONNECT THE internal source addr to the 
	-- external one
	--===============================================================

	source_addr_out_reg <= internal_source_addr;

	--===============================================================
	-- ALGO_TYPE connection
	ALGO_TYPE_out_reg      <= ALGO_TYPE_register(0);
	--===============================================================
	--===============================================================
	slv_reg11          <= debug_registers_reg(2 * C_DWIDTH - 1 downto C_DWIDTH); --fifo_read_data;
	internal_slv_reg11 <= debug_registers_reg(2 * C_DWIDTH - 1 downto C_DWIDTH);
	fifo_write_data    <= debug_registers_reg(2 * C_DWIDTH - 1 downto C_DWIDTH);
	--===============================================================
	--===============================================================
	set_other_slv_regs : process(clk, rst)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then

				--			slv_reg11 <= (others => '0');
				slv_reg12 <= (others => '0');
				slv_reg13 <= (others => '0');
				slv_reg14 <= (others => '0');
				slv_reg15 <= (others => '0');

			else
			----		  	slv_reg11 <= debug_registers_reg(2*C_DWIDTH -1 downto C_DWIDTH);	-- NORTH_out
			--		  	slv_reg12 <= debug_registers_reg(3*C_DWIDTH -1 downto 2*C_DWIDTH);
			--		  	slv_reg13 <= debug_registers_reg(4*C_DWIDTH -1 downto 3*C_DWIDTH);
			--		  	slv_reg14 <= debug_registers_reg(5*C_DWIDTH -1 downto 4*C_DWIDTH);
			--		  	slv_reg15 <= debug_registers_reg(6*C_DWIDTH -1 downto 5*C_DWIDTH);

			end if;

		end if;

	end process;

	--#########################################################################--
	--          ADDRESS FROM THE OCB EXTERNAL BUS DECODING PROCESS
	--#########################################################################--

	p_external_address_decode : process(clk, rst, slv_reg_write_select, Bus2IP_Data_reg)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				-- TODO
				current_configuration_type <= NO_CONFIGURATION;

				-- Internal ADDRESS = 0
				reversed_DESTIN_SOURCE_RATIO_register <= (others => '0');
				--<= reversed_conv_std_logic_vector(CUR_DEFAULT_DESTIN_SOURCE_RATIO, BUS_DATA_WIDTH);

				-- Internal ADDRESS = 1
				reversed_SOURCE_DUAL_RATIO_register <= (others => '0');
				--<= reversed_conv_std_logic_vector(CUR_DEFAULT_SOURCE_DUAL_RATIO, BUS_DATA_WIDTH);

				-- Internal ADDRESS = 2
				reversed_CURRENT_CONFIG_START_ADDR_register <= (others => '0');
				--<= reversed_conv_std_logic_vector(CUR_DEFAULT_CONFIG_START_ADDR, BUS_DATA_WIDTH);

				-- Internal ADDRESS = 3
				reversed_CURRENT_DESTIN_VLIW_DATA_END_ADDR_register <= (others => '0');
				--<=  reversed_conv_std_logic_vector(CUR_DEFAULT_VLIW_DATA_END_ADDR, BUS_DATA_WIDTH);

				-- Internal ADDRESS = 4
				reversed_CURRENT_DESTIN_ICN_DATA_END_ADDR_register <= (others => '1');
				--<= reversed_conv_std_logic_vector(CUR_DEFAULT_ICN_DATA_END_ADDR, BUS_DATA_WIDTH);

				-- Internal ADDRESS = 5
				reversed_CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register <= (others => '1');
				--<= reversed_conv_std_logic_vector(CUR_DEFAULT_PRELOAD_DATA_END_ADDR, BUS_DATA_WIDTH);


				reversed_COUNT_DOWN_register <= (others => '0');

				reversed_CONFIG_TYPE_register <= (others => '0');
				-- Internal ADDRESS = 10 ALGO_TYPE
				reversed_ALGO_TYPE_register   <= (others => '0');

			else

				--Ericles Sousa: Connected to Bus2IP_WrCE_reg
				case slv_reg_write_select is
					when "1000000000000000" => -- R E G I S T E R  0

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_DESTIN_SOURCE_RATIO_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when "0100000000000000" => -- R E G I S T E R  1

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_SOURCE_DUAL_RATIO_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when "0010000000000000" => -- R E G I S T E R  2

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_CURRENT_CONFIG_START_ADDR_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when "0001000000000000" => -- R E G I S T E R  3

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_CURRENT_DESTIN_VLIW_DATA_END_ADDR_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when "0000100000000000" => -- R E G I S T E R  4

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_CURRENT_DESTIN_ICN_DATA_END_ADDR_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when "0000010000000000" => -- R E G I S T E R  5

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when "0000000010000000" => -- R E G I S T E R  8

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_COUNT_DOWN_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when "0000000001000000" => -- R E G I S T E R  9

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_CONFIG_TYPE_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

						case conv_integer(Bus2IP_Data_reg) is
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

					when "0000000000100000" => -- R E G I S T E R  10 ALGO_TYPE

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_ALGO_TYPE_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when others =>

						-----------------------------------------------------------------------------                           
						-- Internal ADDRESS = 0
						reversed_DESTIN_SOURCE_RATIO_register                  <= reversed_DESTIN_SOURCE_RATIO_register;
						-----------------------------------------------------------------------------                           
						-- Internal ADDRESS = 1
						reversed_SOURCE_DUAL_RATIO_register                    <= reversed_SOURCE_DUAL_RATIO_register;
						-----------------------------------------------------------------------------                                           
						-- Internal ADDRESS = 2
						reversed_CURRENT_CONFIG_START_ADDR_register            <= reversed_CURRENT_CONFIG_START_ADDR_register;
						-----------------------------------------------------------------------------                                                            
						-- Internal ADDRESS = 3
						reversed_CURRENT_DESTIN_VLIW_DATA_END_ADDR_register    <= reversed_CURRENT_DESTIN_VLIW_DATA_END_ADDR_register;
						-----------------------------------------------------------------------------                                           
						-- Internal ADDRESS = 4
						reversed_CURRENT_DESTIN_ICN_DATA_END_ADDR_register     <= reversed_CURRENT_DESTIN_ICN_DATA_END_ADDR_register;
						-----------------------------------------------------------------------------                                                            
						-- Internal ADDRESS = 5
						reversed_CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register <= reversed_CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register;
						-----------------------------------------------------------------------------
						-- Internal ADDRESS = 8
						reversed_COUNT_DOWN_register                           <= reversed_COUNT_DOWN_register;
						-----------------------------------------------------------------------------
						-- Internal ADDRESS = 9
						reversed_CONFIG_TYPE_register                          <= reversed_CONFIG_TYPE_register;
						-----------------------------------------------------------------------------
						-- Internal ADDRESS = 10 ALGO_TYPE		
						reversed_ALGO_TYPE_register                            <= reversed_ALGO_TYPE_register;

				--current_configuration_type <= NO_CONFIGURATION;
				end case;

			end if;

		end if;

	end process p_external_address_decode;

	--#########################################################################--
	--#########################################################################--

	--#########################################################################--
	-- PROCESS CONFIGURATION MASK SETTING
	--#########################################################################--

	set_config_mask : process(clk, rst, slv_reg_write_select, Bus2IP_Data_reg)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then

				-- <==> DO NOT CONFIGURE ANY PROCESSORS AFTER RESET !!!
				reversed_VERTICAL_MASK_register <= (others => '0');

				-- Internal ADDRESS = 7
				reversed_HORIZONTAL_MASK_register <= (others => '0');

			elsif clear_mask_registers = '1' then
				reversed_VERTICAL_MASK_register   <= (others => '0');
				reversed_HORIZONTAL_MASK_register <= (others => '0');

			else
				case slv_reg_write_select is -- 32 Bit address line of the external bus assumed

					when "0000001000000000" => -- R E G I S T E R  6

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_VERTICAL_MASK_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when "0000000100000000" => -- R E G I S T E R  7

						for byte_index in 0 to (C_DWIDTH / 8) - 1 loop
							if (Bus2IP_BE_reg(byte_index) = '1') then
								reversed_HORIZONTAL_MASK_register(byte_index * 8 to byte_index * 8 + 7) <= Bus2IP_Data_reg(byte_index * 8 to byte_index * 8 + 7);
							end if;
						end loop;

					when others =>

						-----------------------------------------------------------------------------                                       
						-- Internal ADDRESS = 6
						reversed_VERTICAL_MASK_register   <= reversed_VERTICAL_MASK_register;
						-----------------------------------------------------------------------------                           
						-- Internal ADDRESS = 7
						reversed_HORIZONTAL_MASK_register <= reversed_HORIZONTAL_MASK_register;
				-----------------------------------------------------------------------------                                           

				end case;

			end if;

		end if;

	end process set_config_mask;

	--===============================================================
	set_config_reset : process(clk, rst, slv_reg_read_select)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				--old_internal_slv_reg11 <= (others => '0');
				-----------------------------------------------
				--result_fifo_read_en <= '0';
				-----------------------------------------------
				--result_fifo_write_en <= '0';
				-----------------------------------------------

				common_config_reset_reg <= '1';

			else
				--			if slv_reg_read_select = "0000000000010000" then 
				--				result_fifo_read_en <= '1';
				--			else
				--				result_fifo_read_en <= '0';
				--			end if;
				---------------------------------------------------
				if current_configuration_type = NO_CONFIGURATION and clear_mask_registers = '1' then
					--		result_fifo_write_en   <= '1';

					common_config_reset_reg <= '0';

				elsif current_configuration_type /= NO_CONFIGURATION then
					common_config_reset_reg <= '1';

				--elsif	 fifo_full = '1' then
				--		result_fifo_write_en <= '0';

				else
					common_config_reset_reg <= '0'; -- '1'
				end if;
			end if;
		end if;

	end process;

	--===============================================================

	--implement slave model register read mux
	SLAVE_REG_READ_PROC : process(slv_reg_read_select) is
	begin
		case slv_reg_read_select is

			--===============================================================
			--===============================================================
			when "1000000000000000" =>  -- R E G I S T E R  0

				IP2Bus_Data_reg <= reversed_DESTIN_SOURCE_RATIO_register;

			when "0100000000000000" =>  -- R E G I S T E R  1

				IP2Bus_Data_reg <= reversed_SOURCE_DUAL_RATIO_register;

			when "0010000000000000" =>  -- R E G I S T E R  2

				IP2Bus_Data_reg <= reversed_CURRENT_CONFIG_START_ADDR_register;

			when "0001000000000000" =>  -- R E G I S T E R  3

				IP2Bus_Data_reg <= reversed_CURRENT_DESTIN_VLIW_DATA_END_ADDR_register;

			when "0000100000000000" =>  -- R E G I S T E R  4 

				IP2Bus_Data_reg <= reversed_CURRENT_DESTIN_ICN_DATA_END_ADDR_register;

			when "0000010000000000" =>  -- R E G I S T E R  5

				IP2Bus_Data_reg <= reversed_CURRENT_DESTIN_PRELOAD_DATA_END_ADDR_register;

			when "0000001000000000" =>  -- R E G I S T E R  6

				IP2Bus_Data_reg <= reversed_VERTICAL_MASK_register;

			when "0000000100000000" =>  -- R E G I S T E R  7

				IP2Bus_Data_reg <= reversed_HORIZONTAL_MASK_register;
			--===============================================================
			--===============================================================
			when "0000000010000000" =>  -- R E G I S T E R  8

				IP2Bus_Data_reg <= reversed_COUNT_DOWN_register;
			--===============================================================
			--===============================================================
			when "0000000001000000" =>  -- R E G I S T E R  9

				IP2Bus_Data_reg <= reversed_CONFIG_TYPE_register;
			--===============================================================
			--===============================================================
			-- R E G I S T E R  10 ALGO_TYPE
			when "0000000000100000" =>
				IP2Bus_Data_reg <= reversed_ALGO_TYPE_register;

			when "0000000000010000" =>
				IP2Bus_Data_reg <= reversed_slv_reg11;

			when "0000000000001000" =>
				IP2Bus_Data_reg <= reversed_slv_reg12;

			when "0000000000000100" =>
				IP2Bus_Data_reg <= reversed_slv_reg13;

			when "0000000000000010" =>
				IP2Bus_Data_reg <= reversed_slv_reg14;

			when "0000000000000001" =>
				IP2Bus_Data_reg <= reversed_slv_reg15;

			--===============================================================
			--===============================================================
			when others =>
				IP2Bus_Data_reg <= (others => '0');

		end case;

	end process SLAVE_REG_READ_PROC;

	--===============================================================
	--===============================================================

	--############################################################
	--############################################################
	--set_config_type :process(CONFIG_TYPE_register)
	--
	--begin
	--
	--	case conv_integer(CONFIG_TYPE_register) is
	--
	--		when 0 => 
	--
	--			current_configuration_type <= NO_CONFIGURATION;
	--
	--		when 1 =>
	--			
	--			current_configuration_type <= VLIW_MEMORY_CONFIG;
	--		
	--		when 2 =>
	--
	--			current_configuration_type <= ICN_CONFIG;
	--
	--		when 3 =>
	--
	--			current_configuration_type <= PRELOAD_CONFIG;
	--
	--		when 4 =>
	--
	--			current_configuration_type <= VLIW_AND_ICN;
	--
	--		when 5 =>
	--
	--			current_configuration_type <= VLIW_AND_PRELOAD;
	--
	--		when 6 =>
	--
	--			current_configuration_type <= ICN_AND_PRELOAD;
	--
	--		when 7 =>
	--			
	--			current_configuration_type <=  VLIW_AND_ICN_AND_PRELOAD;
	--
	--		when others =>
	--
	--
	--	end case;
	--
	--
	--end process;
	--############################################################
	--############################################################


	p_statechart : process(clk)
		variable internal_destin_addr : std_logic_vector(SOURCE_ADDR_WIDTH - 1 downto 0);

		----------------------------------------------------
		variable CURRENT_DESTIN_SOURCE_RATIO : integer;-- range 0 to 63;
		variable CURRENT_SOURCE_DUAL_RATIO   : integer;-- range 0 to 63;
		----------------------------------------------------
		--Ericles Sousa on 19 Dec 2014: from 1024 to 2^32-1. Now it is possible to load more than 1kB 
		variable CURRENT_VLIW_DATA_END       : integer; -- range 0 to 32*1024;
		variable CURRENT_ICN_DATA_END        : integer; -- range 0 to 1024; -- former 3??? to 1024
		variable CURRENT_PRELOAD_DATA_END    : integer; -- range 0 to 1024; -- former 2??? to 1024
		----------------------------------------------------
		variable CURRENT_COUNT_DOWN_VALUE    : integer;
		variable CURRENT_CONF_TYPE           : integer range 0 to 7;

	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				count_down_loaded     <= '0';
				pwr_up_sequence_start <= '0';

				internal_config_done <= '0';
				final_clear          <= '0';
				source_data_out_reg      <= (others => '0');

				clear_mask_registers <= '0';
				internal_source_addr <= (others => '0');
				internal_destin_addr := (others => '0');

				buffer_load_pointer      <= 0;
				buffer_load_pointer_dual <= 0;

				vliw_config_done    <= '1';
				icn_config_done     <= '1';
				preload_config_done <= '1';

				config_type_loaded <= '0';
				icn_config_en_reg  <= '0';
				vliw_config_en_reg <= '0';
				vliw_config_end_addr_loaded <= '0';
				icn_config_end_addr_loaded  <= '0';
				------------------------------------
				controller_nextstate <= INITIAL;
				------------------------------------
			else
				case controller_nextstate is

					-- ======================================================================================                       

					--!!!!!!!!!!!!!!!!!!!!!!
					when INITIAL =>
						--!!!!!!!!!!!!!!!!!!!!!!

						if POWER_GATING then
							if conv_integer(pwr_up_counter) = 0 then
								pwr_up_sequence_start <= '0';

							elsif clear_mask_registers = '1' then
								pwr_up_sequence_start <= '0';

							else
								pwr_up_sequence_start <= pwr_up_sequence_start;

							end if;

						else            -- NO POWER GATING

							pwr_up_sequence_start <= '0';

						end if;

						internal_config_done <= '0';

						if clear_mask_registers = '1' then
							icn_config_en_reg <= '0';
							config_type_loaded <= '0';
							count_down_loaded  <= '0';

							vliw_config_end_addr_loaded <= '0';
							icn_config_end_addr_loaded  <= '0';

						end if;
						----------------------------------
						if vliw_config_done = '0' then
							----------------------------------

							-- CLEAR THE (here not existent BUFFER) POINTERS, but they exist in the
							-- WPPEs to be configured !!!    THEREFORE, to be synchronous with the local
							-- MEMORY LOADER modules in each WPPE under configuration,
							-- here, in the global CONTROLLER, the equivalent operations must
							-- be done at least at the corresponding pointer signals
							buffer_load_pointer      <= 0;
							buffer_load_pointer_dual <= 0;

							if config_type_loaded = '0' and pwr_up_ready = '1' then
								source_data_out_reg <= CONFIG_TYPE_register(SOURCE_DATA_WIDTH - 1 downto 0);

								------------------------------------
								controller_nextstate <= LOAD_CONFIG_TYPE;
							------------------------------------

							else
								if config_type_loaded = '1' then
									source_data_out_reg      <= source_data_in_reg;

									internal_source_addr <= internal_source_addr + 1;

									------------------------------------
									controller_nextstate <= LOAD_BUFFER;
								------------------------------------                        

								end if;

							end if;

						----------------------------------
						elsif icn_config_done = '0' then
							----------------------------------

							if config_type_loaded = '0' and pwr_up_ready = '1' then
								source_data_out_reg <= CONFIG_TYPE_register(SOURCE_DATA_WIDTH - 1 downto 0);

								------------------------------------
								controller_nextstate <= LOAD_CONFIG_TYPE;
							------------------------------------

							else
								if config_type_loaded = '1' then
									source_data_out_reg <= source_data_in_reg;

									------------------------------------
									controller_nextstate <= LOAD_BUFFER_DUAL;
									------------------------------------       
									buffer_load_pointer_dual <= 0;

								end if;

							end if;

						else            -- if already configured once, then some
							-- group of the WPPE in the
							-- array, eventually have to be RECONFIGURED
							---------------------------------------------------------
							if (VERTICAL_MASK_register = NULL_VECTOR) AND (HORIZONTAL_MASK_register = NULL_VECTOR) then
								vliw_config_done     <= '1';
								icn_config_done      <= '1';
								preload_config_done  <= '1';
								clear_mask_registers <= '0';

							elsif (VERTICAL_MASK_register = NULL_VECTOR) then
								vliw_config_done     <= '1';
								icn_config_done      <= '1';
								preload_config_done  <= '1';
								clear_mask_registers <= '0';

							elsif (HORIZONTAL_MASK_register = NULL_VECTOR) then
								vliw_config_done     <= '1';
								icn_config_done      <= '1';
								preload_config_done  <= '1';
								clear_mask_registers <= '0';

							else
								if CONFIG_TYPE_register = NULL_VECTOR then
									vliw_config_done    <= '1';
									icn_config_done     <= '1';
									preload_config_done <= '1';

									if final_clear = '1' then
										clear_mask_registers <= '1';
										final_clear          <= '0';
									else
										final_clear <= '1';
									end if;

								else
									if POWER_GATING then
										pwr_up_sequence_start <= '1';
									end if;

									vliw_config_done     <= '0';
									icn_config_done      <= '0';
									preload_config_done  <= '0';
									clear_mask_registers <= '0';
									------------------------------------------------------------------
									------------------------------------------------------------------
									-- GET THE CURRENT COUNT_DOWN_VALUE

									CURRENT_COUNT_DOWN_VALUE := conv_integer(COUNT_DOWN_register);

									-- GET THE CURRENT CONFIGURATION START ADDRESS 
									internal_source_addr <= CURRENT_CONFIG_START_ADDR_register(SOURCE_ADDR_WIDTH - 1 downto 0);

									-- GET the CURRENT DESTIN_SOURCE_RATIO
									CURRENT_DESTIN_SOURCE_RATIO := conv_integer(DESTIN_SOURCE_RATIO_register);

									-- GET the CURRENT END of the VLIW configuration data
									CURRENT_VLIW_DATA_END := conv_integer(CURRENT_DESTIN_VLIW_DATA_END_ADDR_register);
									------------------------------------------------------------------
									------------------------------------------------------------------
									-- GET the CURRENT END of the PRELOAD configuration data
									CURRENT_ICN_DATA_END  := conv_integer(CURRENT_DESTIN_ICN_DATA_END_ADDR_register);

									-- INIT_SOURCE_ADDR was NOT cleared during VLIW configurtion.
									--internal_source_addr <= conv_std_logic_vector(INIT_SOURCE_ADDR, SOURCE_ADDR_WIDTH);
									buffer_load_pointer      <= 0;
									buffer_load_pointer_dual <= 0;

									-- GET the CURRENT SOURCE_DUAL_RATIO
									CURRENT_SOURCE_DUAL_RATIO := conv_integer(SOURCE_DUAL_RATIO_register);
								------------------------------------------------------------------
								------------------------------------------------------------------


								end if;

							end if;
							---------------------------------------------------------

							--                    internal_source_addr <= (others => '0');
							buffer_load_pointer      <= 0;
							buffer_load_pointer_dual <= 0;

							--source_data_out_reg <= (others => '0');
							source_data_out_reg <= source_data_in_reg;

							------------------------------------
							controller_nextstate <= INITIAL;
						------------------------------------

						end if;

					-- ======================================================================================                       
					--!!!!!!!!!!!!!!!!!!!!!!
					when LOAD_CONFIG_TYPE =>
						--!!!!!!!!!!!!!!!!!!!!!!

						if config_type_loaded = '0' then
							source_data_out_reg <= CONFIG_TYPE_register(SOURCE_DATA_WIDTH - 1 downto 0);

							config_type_loaded <= '1';

							------------------------------------
							controller_nextstate <= LOAD_CONFIG_TYPE;
						------------------------------------

						else

							----					 source_data_out_reg 
							----			         <= COUNT_DOWN_register(SOURCE_DATA_WIDTH -1 downto 0);

							source_data_out_reg <= conv_std_logic_vector(
									conv_integer(CURRENT_DESTIN_VLIW_DATA_END_ADDR_register) - conv_integer(CURRENT_CONFIG_START_ADDR_register), SOURCE_DATA_WIDTH
								);

							------------------------------------
							--	controller_nextstate   <= LOAD_COUNT_DOWN; 
							controller_nextstate <= LOAD_VLIW_CONFIG_END_ADDR;
							------------------------------------ 

							case current_configuration_type is
								when NO_CONFIGURATION =>
									vliw_config_done    <= '1';
									icn_config_done     <= '1';
									preload_config_done <= '1';

								when VLIW_MEMORY_CONFIG =>
									vliw_config_done    <= '0';
									icn_config_done     <= '1';
									preload_config_done <= '1';

								when ICN_CONFIG =>
									vliw_config_done    <= '1';
									icn_config_done     <= '0';
									preload_config_done <= '1';

								when PRELOAD_CONFIG =>
									vliw_config_done    <= '1';
									icn_config_done     <= '1';
									preload_config_done <= '0';

								when VLIW_AND_ICN =>
									vliw_config_done    <= '0';
									icn_config_done     <= '0';
									preload_config_done <= '1';

								when VLIW_AND_PRELOAD =>
									vliw_config_done    <= '0';
									icn_config_done     <= '1';
									preload_config_done <= '0';

								when ICN_AND_PRELOAD =>
									vliw_config_done    <= '1';
									icn_config_done     <= '0';
									preload_config_done <= '0';

								when VLIW_AND_ICN_AND_PRELOAD =>
									vliw_config_done    <= '0';
									icn_config_done     <= '0';
									preload_config_done <= '0';

								when others =>
									vliw_config_done    <= '1';
									icn_config_done     <= '1';
									preload_config_done <= '1';

							end case;

						end if;

					-- ======================================================================================                         

					--!!!!!!!!!!!!!!!!!!!!!!
					when LOAD_VLIW_CONFIG_END_ADDR =>
						--!!!!!!!!!!!!!!!!!!!!!!

						if vliw_config_end_addr_loaded = '0' then
							source_data_out_reg <= --CURRENT_DESTIN_VLIW_DATA_END_ADDR_register(SOURCE_DATA_WIDTH -1 downto 0);
								conv_std_logic_vector(
									conv_integer(CURRENT_DESTIN_VLIW_DATA_END_ADDR_register) - conv_integer(CURRENT_CONFIG_START_ADDR_register), SOURCE_DATA_WIDTH
								);

							vliw_config_end_addr_loaded <= '1';

							------------------------------------
							controller_nextstate <= LOAD_VLIW_CONFIG_END_ADDR;
						------------------------------------

						else
							source_data_out_reg <= --CURRENT_DESTIN_ICN_DATA_END_ADDR_register(SOURCE_DATA_WIDTH -1 downto 0);
								conv_std_logic_vector(
									conv_integer(CURRENT_DESTIN_ICN_DATA_END_ADDR_register) - conv_integer(CURRENT_CONFIG_START_ADDR_register), SOURCE_DATA_WIDTH
								);

							------------------------------------
							controller_nextstate <= LOAD_ICN_CONFIG_END_ADDR;
						------------------------------------

						end if;

					-- ======================================================================================                       

					--!!!!!!!!!!!!!!!!!!!!!!
					when LOAD_ICN_CONFIG_END_ADDR =>
						--!!!!!!!!!!!!!!!!!!!!!!

						if icn_config_end_addr_loaded = '0' then
							source_data_out_reg <= --CURRENT_DESTIN_ICN_DATA_END_ADDR_register(SOURCE_DATA_WIDTH -1 downto 0);
								conv_std_logic_vector(
									conv_integer(CURRENT_DESTIN_ICN_DATA_END_ADDR_register) - conv_integer(CURRENT_CONFIG_START_ADDR_register), SOURCE_DATA_WIDTH
								);

							icn_config_end_addr_loaded <= '1';

							------------------------------------
							controller_nextstate <= LOAD_ICN_CONFIG_END_ADDR;
						------------------------------------

						else
							source_data_out_reg <= COUNT_DOWN_register(SOURCE_DATA_WIDTH - 1 downto 0);

							------------------------------------
							controller_nextstate <= LOAD_COUNT_DOWN;
						------------------------------------

						end if;

					-- ======================================================================================                       


					--!!!!!!!!!!!!!!!!!!!!!!
					when LOAD_COUNT_DOWN =>
						--!!!!!!!!!!!!!!!!!!!!!!

						if count_down_loaded = '0' then
							source_data_out_reg <= COUNT_DOWN_register(SOURCE_DATA_WIDTH - 1 downto 0);

							count_down_loaded <= '1';

							------------------------------------
							controller_nextstate <= LOAD_COUNT_DOWN;
						------------------------------------

						else
							source_data_out_reg   <= source_data_in_reg;
							count_down_loaded <= '0';

							----------------------------------
							if vliw_config_done = '0' then
								----------------------------------

								internal_source_addr <= internal_source_addr + 1;

								------------------------------------
								controller_nextstate <= LOAD_BUFFER;
							------------------------------------

							----------------------------------
							elsif icn_config_done = '0' then
								----------------------------------


								------------------------------------
								controller_nextstate <= LOAD_BUFFER_DUAL;
								------------------------------------
								buffer_load_pointer_dual <= 0;

							else
								controller_nextstate <= INITIAL;

							end if;

						end if;
					-- ======================================================================================                       

					--!!!!!!!!!!!!!!!!!!!!!!
					when LOAD_BUFFER =>
					--!!!!!!!!!!!!!!!!!!!!!!    

						source_data_out_reg <= source_data_in_reg;

						if buffer_load_pointer = CURRENT_DESTIN_SOURCE_RATIO then
							buffer_load_pointer <= 0;
							vliw_config_done    <= '0';
							vliw_config_en_reg <= '0';

							------------------------------------
							controller_nextstate <= WRITE_BACK;
							------------------------------------

						else
							vliw_config_done <= '0';

							-- one cycle delay for synchronous config memory
							if icn_config_end_addr_loaded = '1' then
								icn_config_end_addr_loaded <= '0';
								vliw_config_en_reg <= '0';

							else
								-- one cycle delay for synchronous config memory
								icn_config_end_addr_loaded <= '1';

								buffer_load_pointer <= buffer_load_pointer + 1;

								if buffer_load_pointer < CURRENT_DESTIN_SOURCE_RATIO - 1 then
									internal_source_addr <= internal_source_addr + 1;
								end if;
								vliw_config_en_reg <= '1';

							end if;

							------------------------------------
							controller_nextstate <= LOAD_BUFFER;
							------------------------------------

						end if;

					-- ======================================================================================                       

					--!!!!!!!!!!!!!!!!!!!!!!
					when WRITE_BACK =>
						--!!!!!!!!!!!!!!!!!!!!!!    

						source_data_out_reg <= source_data_in_reg;

						if (conv_integer(internal_source_addr) = CURRENT_VLIW_DATA_END) then
							if clear_mask_registers = '0' then

								----------------------------
								-- CLEAR MASK REGISTERS !!!
								----------------------------
								clear_mask_registers <= '1';

								------------------------------------
								controller_nextstate <= WRITE_BACK;
							------------------------------------

							else

								-- Do NOT clear this register HERE, because the ICN DATA comes 
								-- AFTER the VLIW data in the current configuration to be loaded

								--internal_source_addr <= (others => '0');
								buffer_load_pointer <= 0;
								vliw_config_done    <= '1';

								internal_config_done <= '1'; -- SIGNAL CONFIG DONE TO THE CONFIG MANAGER
								------------------------------------
								controller_nextstate <= INITIAL;
							------------------------------------

							end if;

						else
							internal_source_addr <= internal_source_addr + 1;

							vliw_config_done     <= '0';
							internal_destin_addr := internal_destin_addr + 1;

							------------------------------------
							controller_nextstate <= LOAD_BUFFER;
						------------------------------------

						end if;

					-- ======================================================================================       

					--!!!!!!!!!!!!!!!!!!!!!!
					when LOAD_BUFFER_DUAL =>
					--!!!!!!!!!!!!!!!!!!!!!!   

						icn_config_done <= '0';
						source_data_out_reg <= source_data_in_reg;
						internal_source_addr <= internal_source_addr + 1;
--						icn_config_en_reg <= '1';
						------------------------------------
						controller_nextstate <= WRITE_BACK_DUAL;
						------------------------------------

					-- ======================================================================================   

					--!!!!!!!!!!!!!!!!!!!!!!    
					when WRITE_BACK_DUAL =>
						--!!!!!!!!!!!!!!!!!!!!!!
						sig_current_source_dual_ratio <= CURRENT_SOURCE_DUAL_RATIO;
						sig_current_icn_data_en <= CURRENT_ICN_DATA_END;

						source_data_out_reg <= source_data_in_reg;

							if (conv_integer(internal_source_addr) = (CURRENT_ICN_DATA_END)) then -- !!! WRONG: ONLY QUICK HACK FOR FFT !!! 
								--icn_config_en_reg <= '0';
								-- !!! CORRECT: CURRENT_ICN_DATA_END) then -- !!!   
								if clear_mask_registers = '0' then
									----------------------------
									-- CLEAR MASK REGISTERS !!!
									----------------------------
									clear_mask_registers     <= '1';

									------------------------------------
									controller_nextstate <= WRITE_BACK_DUAL;
									------------------------------------
								else
									buffer_load_pointer_dual <= 0;
									--    internal_source_addr <= (others => '0');
									icn_config_done          <= '1';

									internal_config_done <= '1'; -- SIGNAL CONFIG DONE TO THE CONFIG MANAGER
									------------------------------------
									controller_nextstate <= INITIAL;
									------------------------------------
								end if;
							else
								icn_config_en_reg <= '1';
								internal_source_addr <= internal_source_addr + 1;
							end if;

					-- ======================================================================================                           

					--!!!!!!!!!!!!!!!!!!!!!!
					when others =>
						--!!!!!!!!!!!!!!!!!!!!!! 

						source_data_out_reg <= (others => '0');

						internal_source_addr <= (others => '0');
						internal_destin_addr := (others => '0');

						vliw_config_done    <= '0';
						buffer_load_pointer <= 0;

						icn_config_done          <= '0';
						buffer_load_pointer_dual <= 0;

				------------------------------------
				--controller_nextstate   <= INITIAL;
				------------------------------------

				-- ======================================================================================                                           

				end case;

			end if;
		end if;

	end process;

	--The folowing process is introduced to solve some timing violtaion issues
	in_out_register : process(clk, rst)--, Bus2IP_Addr, Bus2IP_Data, Bus2IP_BE, Bus2IP_RdCE, Bus2IP_WrCE, source_data_in, debug_registers)
	begin
		if rst = '1' then
			IP2Bus_Data                   <= (others=>'0');
	                CONFIGURATION_MASK_VERTICAL   <= (others=>'0'); 
	                CONFIGURATION_MASK_HORIZONTAL <= (others=>'0'); 
	                source_data_out               <= (others=>'0'); 
	                source_addr_out               <= (others=>'0'); 
	                ALGO_TYPE_out                 <= '0'; 
	                common_config_reset           <= '0'; 
	                vliw_config_en                <= '0'; 
	                icn_config_en                 <= '0'; 
	                config_done                   <= '0'; 
	
	                Bus2IP_Addr_reg     <= (others=>'0');                   
	                Bus2IP_Data_reg     <=  (others=>'0');                   
	                Bus2IP_BE_reg       <=  (others=>'0');                     
	                Bus2IP_RdCE_reg     <=  (others=>'0');                   
	                Bus2IP_WrCE_reg     <=  (others=>'0');                   
	                source_data_in_reg  <=  (others=>'0');                
	                debug_registers_reg <=  (others=>'0');               

		elsif rising_edge(clk) then
			IP2Bus_Data                   <= IP2Bus_Data_reg;                   
	                CONFIGURATION_MASK_VERTICAL   <= CONFIGURATION_MASK_VERTICAL_reg;   
	                CONFIGURATION_MASK_HORIZONTAL <= CONFIGURATION_MASK_HORIZONTAL_reg; 
	                source_data_out               <= source_data_out_reg;               
	                source_addr_out               <= source_addr_out_reg;               
	                ALGO_TYPE_out                 <= ALGO_TYPE_out_reg;                 
	                common_config_reset           <= common_config_reset_reg;           
	                vliw_config_en                <= vliw_config_en_reg;                 
	                icn_config_en                 <= icn_config_en_reg;                 
	                config_done                   <= config_done_reg;                   
	
	                Bus2IP_Addr_reg               <= Bus2IP_Addr;                   
	                Bus2IP_Data_reg               <=  Bus2IP_Data;                   
	                Bus2IP_BE_reg                 <=  Bus2IP_BE;                     
	                Bus2IP_RdCE_reg               <=  Bus2IP_RdCE;                   
	                Bus2IP_WrCE_reg               <=  Bus2IP_WrCE;                   
	                source_data_in_reg            <=  source_data_in;               

	                debug_registers_reg           <=  debug_registers;               
		end if;
                
	end process;
-- ======================================================================================                       
-- ======================================================================================                       


end Behavioral;
