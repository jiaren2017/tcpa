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
-- Create Date:    12:17:23 07/18/07
-- Design Name:    
-- Module Name:    configuration_manager - Behavioral
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
-- CONFIGURATION_MANAGER
--
--=========================================================================================================================
--		DOMAIN HEADER FORMAT: 
--		 
--		+-------+---------+--------+----------+----------+---------+----------+---------+--------+---------+--------+--------+
--		|ICN_END|ICN_BEGIN|VLIW_END|VLIW_BEGIN|COUNT_DOWN|ICN_RATIO|VLIW_RATIO|MSK_HORZT|MSK_VERT|NEXT_ADDR|LST_FLAG|DOM_TYPE|
--		+-------+---------+--------+----------+----------+---------+----------+---------+--------+---------+--------+--------+
--		header_width-1                                                                                                       0
--
--		+---------+-----------+----------+------------+------------+-----------+------------+-----------+----------+-----------+----------+----------+
--		| ICN_END | ICN_BEGIN | VLIW_END | VLIW_BEGIN | COUNT_DOWN | ICN_RATIO | VLIW_RATIO | MSK_HORZT | MSK_VERT | NEXT_ADDR | LST_FLAG | DOM_TYPE |
--		+---------+-----------+----------+------------+------------+-----------+------------+-----------+----------+-----------+----------+----------+
--		header_width-1                                                                                                                               0
--
--=========================================================================================================================

--------------------------------------------------------------------------------
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

entity configuration_manager is
	generic(

		-- cadence translate_off	
		INSTANCE_NAME : string  := "?";
		-- cadence translate_on

		HEADER_WIDTH  : integer := 5 * CUR_DEFAULT_SOURCE_ADDR_WIDTH + 1 + CUR_DEFAULT_ICN_RATIO_WIDTH + CUR_DEFAULT_VLIW_RATIO_WIDTH + CUR_DEFAULT_NUM_WPPE_VERTICAL + CUR_DEFAULT_NUM_WPPE_HORIZONTAL + CUR_DEFAULT_COUNT_DOWN_WIDTH + CUR_DEFAULT_DOMAIN_TYPE_WIDTH;
		--###########################################################################
		-- Bus protocol parameters, do not add to or delete
		--###########################################################################
		C_AWIDTH      : integer := 32;
		C_DWIDTH      : integer := 32;
		C_NUM_CE      : integer := 16
	--###########################################################################
	);

	port(
		--***********************************
		-- POWER SHUTOFF AUXILIARY SIGNAL
		--***********************************

		ff_start_detection : out std_logic;

		--#############
		--state_out    : out  std_logic_vector(3 downto 0);
		ready_out          : out std_logic;
		--#############
		count_down         : out t_count_down;

		clk                : in  std_logic;
		rst                : in  std_logic;

		dtab_data_daddr_in : in  std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
		offset_in          : in  std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
		dnumber_in         : in  std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
		conf_type_in       : in  std_logic_vector(CUR_DEFAULT_CONFIG_TYPE_WIDTH - 1 downto 0);
		source_data_in     : in  std_logic_vector(CUR_DEFAULT_SOURCE_DATA_WIDTH - 1 downto 0);
		--source_load_data_in	: in  std_logic_vector(CUR_DEFAULT_SOURCE_DATA_WIDTH-1  downto 0);
		conf_done_in       : in  std_logic;
		conf_en_in         : in  std_logic;

		--source_load_data_out	: out  std_logic_vector(CUR_DEFAULT_SOURCE_DATA_WIDTH-1  downto 0);
		dtab_addr_dnumber  : out std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
		dtab_data_daddr    : out std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
		--source_we					: out  std_logic;
		dtab_we            : out std_logic;
		source_select      : out std_logic_vector(CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH - 1 downto 0);
		source_addr        : out std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
		--###########################################################################
		-- OPB  BUS  INTERFACE SIGNALS
		--###########################################################################
		GlobCtrl_BE        : out std_logic_vector(0 to C_DWIDTH / 8 - 1);
		GlobCtrl_Data      : out std_logic_vector(0 to C_DWIDTH - 1);
		GlobCtrl_WrCE      : out std_logic_vector(0 to C_NUM_CE - 1)
	--###########################################################################
	);
end configuration_manager;

architecture Behavioral of configuration_manager is
	CONSTANT FINAL_ADDR : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0) := (others => '1');

	type t_states is (INITIALIZE, READY, CONFIGURATE, WAITING);
	type t_config_type is (setup_begin, custom, custom_last);
	type t_domain_type is (vliw, icn, vliw_and_icn);

	signal state : t_states;

	signal reversed_GlobCtrl_Data : std_logic_vector(C_DWIDTH - 1 downto 0);
	--signal Bus2IP_BE    : out  std_logic_vector(0 to C_DWIDTH/8-1);

	signal config_type : t_config_type; --:= initial;
	signal dom_type    : t_domain_type;

	signal header_buffer : std_logic_vector(
		(CUR_DEFAULT_SOURCE_DATA_WIDTH * CUR_DEFAULT_DOMAIN_HEADER_RATIO) - 1 downto 0);

	--===== HEADER FIELDS: ========
	signal ICN_END    : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal ICN_BEGIN  : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal VLIW_END   : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal VLIW_BEGIN : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);

	--Ericles Sousa on 07 Jan 2015: IMplementing the count_down signal to controll the starting time of each PE
	-- signal COUNT_DOWN			:	std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH-1  downto 0);


	signal ICN_RATIO       : std_logic_vector(CUR_DEFAULT_ICN_RATIO_WIDTH - 1 downto 0);
	signal VLIW_RATIO      : std_logic_vector(CUR_DEFAULT_VLIW_RATIO_WIDTH - 1 downto 0);
	signal MASK_HORIZONTAL : std_logic_vector(CUR_DEFAULT_NUM_WPPE_VERTICAL - 1 downto 0); -- HORIZONTAL-1  downto 0);
	signal MASK_VERTICAL   : std_logic_vector(CUR_DEFAULT_NUM_WPPE_HORIZONTAL - 1 downto 0); -- VERTICAL-1  downto 0);
	signal NEXT_ADDRESS    : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal LAST_FLAG       : std_logic;
	signal DOMAIN_TYPE     : std_logic_vector(CUR_DEFAULT_DOMAIN_TYPE_WIDTH - 1 downto 0);

	--===== HEADER FIELDS FLAGS: ========
	signal start_address_missing : std_logic;

	signal ICN_END_missing  : std_logic;
	signal VLIW_END_missing : std_logic;

	signal COUNT_DOWN_missing      : std_logic;
	signal ICN_RATIO_missing       : std_logic;
	signal VLIW_RATIO_missing      : std_logic;
	signal MASK_HORIZONTAL_missing : std_logic;
	signal MASK_VERTICAL_missing   : std_logic;
	--	signal NEXT_ADDRESS		:	std_logic;
	--=============================
	signal curr_dnumber            : std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
	signal curr_daddr              : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
	signal next_daddr              : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0); -- := offset_in;

	signal we : std_logic;

	signal first_tact  : std_logic;
	signal second_tact : std_logic;

	signal daddr_missing  : std_logic;
	signal header_missing : std_logic;

	signal conf_type_missing : std_logic;

	signal data_sending : std_logic;

	signal conf_done_in_missing     : std_logic;
	signal start_missing            : std_logic;
	signal no_configuration_missing : std_logic;
	signal vertical_ff_missing      : std_logic;
	signal horizontal_ff_missing    : std_logic;

	signal write_delay_first : std_logic;
	signal write_delay_last  : std_logic;

	signal RATIO_COUNTER : integer range 0 to CUR_DEFAULT_DOMAIN_HEADER_RATIO + 2;

	signal config_en : std_logic;

BEGIN

	--===== HEADER FIELDS BINDING: ========
	ICN_END <= header_buffer(HEADER_WIDTH - 1 downto HEADER_WIDTH - CUR_DEFAULT_SOURCE_ADDR_WIDTH);

	ICN_BEGIN <= header_buffer(HEADER_WIDTH - CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto HEADER_WIDTH - 2 * CUR_DEFAULT_SOURCE_ADDR_WIDTH);

	VLIW_END <= header_buffer(HEADER_WIDTH - 2 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto HEADER_WIDTH - 3 * CUR_DEFAULT_SOURCE_ADDR_WIDTH);

	VLIW_BEGIN <= header_buffer(HEADER_WIDTH - 3 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH);

	--	COUNT_DOWN			<=	header_buffer(HEADER_WIDTH-4*CUR_DEFAULT_SOURCE_ADDR_WIDTH-1
	--									downto 
	--									HEADER_WIDTH-4*CUR_DEFAULT_SOURCE_ADDR_WIDTH-CUR_DEFAULT_COUNT_DOWN_WIDTH);

	-----------------------------------------------------------------------------------------------------
	ICN_RATIO <= header_buffer(HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH - CUR_DEFAULT_ICN_RATIO_WIDTH);

	VLIW_RATIO <= header_buffer(HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH - CUR_DEFAULT_ICN_RATIO_WIDTH - 1 downto HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH - CUR_DEFAULT_ICN_RATIO_WIDTH - CUR_DEFAULT_VLIW_RATIO_WIDTH);
	------------------------------------------------------------------------------------------------------								  

	MASK_HORIZONTAL <= header_buffer(HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH - CUR_DEFAULT_ICN_RATIO_WIDTH - CUR_DEFAULT_VLIW_RATIO_WIDTH - 1 downto HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH - CUR_DEFAULT_ICN_RATIO_WIDTH -
			                         CUR_DEFAULT_VLIW_RATIO_WIDTH - CUR_DEFAULT_NUM_WPPE_VERTICAL); --HORIZONTAL);

	MASK_VERTICAL <= header_buffer(HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH - CUR_DEFAULT_ICN_RATIO_WIDTH - CUR_DEFAULT_VLIW_RATIO_WIDTH - CUR_DEFAULT_NUM_WPPE_VERTICAL - 1 --HORIZONTAL-1 
			                       downto HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH - CUR_DEFAULT_ICN_RATIO_WIDTH - CUR_DEFAULT_VLIW_RATIO_WIDTH - CUR_DEFAULT_NUM_WPPE_VERTICAL - CUR_DEFAULT_NUM_WPPE_HORIZONTAL); --HORIZONTAL-CUR_DEFAULT_NUM_WPPE_VERTICAL);

	NEXT_ADDRESS <= header_buffer(CUR_DEFAULT_DOMAIN_TYPE_WIDTH + CUR_DEFAULT_SOURCE_ADDR_WIDTH downto CUR_DEFAULT_DOMAIN_TYPE_WIDTH + 1);

	LAST_FLAG <= header_buffer(CUR_DEFAULT_DOMAIN_TYPE_WIDTH);

	DOMAIN_TYPE <= header_buffer(CUR_DEFAULT_DOMAIN_TYPE_WIDTH - 1 downto 0);
	--=====================================	

	--============================================================================
	REVERSE_DATA : FOR i in 1 to C_DWIDTH GENERATE
		GlobCtrl_Data(i - 1) <= reversed_GlobCtrl_Data(C_DWIDTH - i);
	--reversed_Bus2IP_Data(C_DWIDTH - i) <= Bus2IP_Data_2GlobCtrl(i - 1);	
	END GENERATE;
	--============================================================================


	count_down_mapping : process(rst, clk)
	begin
		for i in 0 to CUR_DEFAULT_NUM_WPPE_VERTICAL - 1 loop
			for j in 0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL - 1 loop
				if MASK_VERTICAL(j) = '1' AND (MASK_HORIZONTAL(i) = '1') then --Actually the MASK_VERTICAL and MASK_HORIZONTAL are inverted. 
					count_down((CUR_DEFAULT_NUM_WPPE_VERTICAL - 1) - i, (CUR_DEFAULT_NUM_WPPE_HORIZONTAL - 1) - j) <= header_buffer(HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto HEADER_WIDTH - 4 * CUR_DEFAULT_SOURCE_ADDR_WIDTH - CUR_DEFAULT_COUNT_DOWN_WIDTH);
				end if;
			end loop;
		end loop;
	end process;

	statechart : process(clk)
		variable next_daddr_var    : std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0); -- := offset_in;
		--	variable	dom_type_var		:	std_logic_vector(CUR_DEFAULT_DOMAIN_TYPE_WIDTH-1  downto 0);-- := offset_in;
		variable RATIO_COUNTER_VAR : integer range 0 to CUR_DEFAULT_DOMAIN_HEADER_RATIO + 1;

	---###########
	BEGIN                               --###
		---###########

		if clk'event and clk = '1' then
			if rst = '1' then
				ff_start_detection <= '0';

				---=================================================
				--  HARDWARE-AWARE SETTINGS 
				---=================================================

				header_buffer            <= (others => '0');
				MASK_VERTICAL_missing    <= '1';
				MASK_HORIZONTAL_missing  <= '1';
				VLIW_RATIO_missing       <= '1';
				write_delay_last         <= '0';
				write_delay_first        <= '0';
				VLIW_END_missing         <= '1';
				start_address_missing    <= '1';
				no_configuration_missing <= '0';
				ICN_RATIO_missing        <= '1';
				ICN_END_missing          <= '1';
				vertical_ff_missing      <= '1';
				horizontal_ff_missing    <= '1';

				header_missing       <= '1';
				data_sending         <= '0';
				daddr_missing        <= '1';
				COUNT_DOWN_missing   <= '0';
				conf_type_missing    <= '0';
				conf_done_in_missing <= '0';

				RATIO_COUNTER <= 0;
				start_missing <= '0';

				config_type <= setup_begin;
				dom_type    <= vliw;

				dtab_addr_dnumber <= (others => '0');
				dtab_data_daddr   <= (others => '0');

				source_addr <= (others => '0');

				GlobCtrl_BE            <= (others => '0');
				reversed_GlobCtrl_Data <= (others => '0');
				GlobCtrl_WrCE          <= (others => '0');

				---=================================================			    
				ready_out <= '0';

				curr_dnumber <= (others => '0');
				curr_daddr   <= offset_in;
				--next_daddr_var	:= offset_in;
				dtab_we      <= '0';
				we           <= '0';

				first_tact  <= '1';
				second_tact <= '1';

				source_select <= conv_std_logic_vector(2, CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH);
				--------------------
				state         <= INITIALIZE;
			--------------------

			else                        --==: if clk'event and clk = '1'

				case state is

					--!!!!!!!!!!!!!!!!
					when INITIALIZE =>
						--!!!!!!!!!!!!!!!!

						--source_select <= conv_std_logic_vector(2, CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH);
						--source_addr <= curr_daddr;
						ready_out <= '0';

						if first_tact = '1' then
							first_tact <= '0';

							source_addr <= curr_daddr;
							--next_daddr <= next_daddr_var;

							dtab_addr_dnumber <= curr_dnumber;
							dtab_data_daddr   <= offset_in;
							dtab_we           <= '1';

						else            --==: first_tact = '1'

							if second_tact = '1' then
								second_tact <= '0';

								dtab_we <= '0';

								curr_dnumber <= conv_std_logic_vector(
										conv_integer(curr_dnumber) + 1, CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH);

							else        --==: second_tact = '1' 

								next_daddr_var := source_data_in(CUR_DEFAULT_DOMAIN_TYPE_WIDTH + CUR_DEFAULT_SOURCE_ADDR_WIDTH downto CUR_DEFAULT_DOMAIN_TYPE_WIDTH + 1); -- + offset_in; 

								if we = '1' then
									we      <= '0';
									dtab_we <= '0';

								else    --==: we = '1'
									we           <= '1';
									curr_dnumber <= conv_std_logic_vector(
											conv_integer(curr_dnumber) + 1, CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH);

									dtab_addr_dnumber <= curr_dnumber;
									dtab_data_daddr   <= next_daddr_var + offset_in;
									dtab_we           <= '1';

								end if; --==: we = '1'

								if next_daddr_var = FINAL_ADDR then
									dtab_we <= '0';
									we      <= '0';
									---------------
									state   <= READY;
								---------------
								end if;

								--										next_daddr <= next_daddr_var + offset_in;
								source_addr <= next_daddr_var + offset_in;
							end if;     --== : second_tact = '1'
						end if;         --== : if first_tact = '1' 


					--!!!!!!!!!!!
					when READY =>
						--!!!!!!!!!!!

						ready_out <= '1';

						--ff_start_detection <= '0';

						if config_en = '1' then
							ff_start_detection <= '0';
							--config_en <= '0';

							source_select     <= conv_std_logic_vector(2, CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH);
							dtab_addr_dnumber <= dnumber_in;

							RATIO_COUNTER  <= 0;
							daddr_missing  <= '1';
							header_missing <= '1';
							first_tact     <= '1';
							second_tact    <= '1';
							--data_sending 	<= '1';

							--VLIW_RATIO_missing		<= '1';
							--VLIW_END_missing			<= '1';
							--ICN_END_missing			<= '1';
							--ICN_RATIO_missing			<= '1';

							start_address_missing <= '1';
							COUNT_DOWN_missing    <= '1';

							MASK_HORIZONTAL_missing <= '1';
							MASK_VERTICAL_missing   <= '1';
							conf_type_missing       <= '1';
							---------------------
							state                   <= CONFIGURATE;
						---------------------
						else
						---
						end if;

					--!!!!!!!!!!!!!!!!!
					when CONFIGURATE =>
						--!!!!!!!!!!!!!!!!!

						-- TEST TEST TEST TEST TEST   
						GlobCtrl_BE   <= (others => '0');
						GlobCtrl_WrCE <= (others => '0');

						ready_out <= '0';
						--#############################
						-- if 1:1----------------------					   
						if daddr_missing = '1' then
							daddr_missing <= '0';
							state         <= CONFIGURATE; -- !!! NETLIST CORRECTION !!!
						-- if 1:2----------------------
						elsif first_tact = '1' then
							first_tact  <= '0';
							source_addr <= dtab_data_daddr_in;
							curr_daddr  <= dtab_data_daddr_in;
							state       <= CONFIGURATE; -- !!! NETLIST CORRECTION !!!
						-- if 1:3----------------------						
						elsif second_tact = '1' then
							second_tact       <= '0';
							RATIO_COUNTER     <= 1;
							write_delay_first <= '1';
							write_delay_last  <= '0';
							state             <= CONFIGURATE; -- !!! NETLIST CORRECTION !!!
						-- if 1:4----------------------
						elsif header_missing = '1' then
							state <= CONFIGURATE; -- !!! NETLIST CORRECTION !!!
							if write_delay_first = '1' then
								write_delay_first <= '0';
							else
								header_buffer((RATIO_COUNTER - 1) * CUR_DEFAULT_SOURCE_DATA_WIDTH - 1 downto (RATIO_COUNTER - 2) * CUR_DEFAULT_SOURCE_DATA_WIDTH) <= source_data_in;
							end if;

							if write_delay_last = '0' then
								RATIO_COUNTER_VAR := RATIO_COUNTER;
								if RATIO_COUNTER_VAR = CUR_DEFAULT_DOMAIN_HEADER_RATIO then
									write_delay_last <= '1';
									RATIO_COUNTER    <= RATIO_COUNTER + 1;
								else
									RATIO_COUNTER <= RATIO_COUNTER + 1;
									source_addr   <= curr_daddr + RATIO_COUNTER;
								end if;

							else        --==: if write_delay_last = '1'

								write_delay_last <= '0';
								header_missing   <= '0';
								data_sending     <= '1';

								--=========== SETUP CONFIGURATIONS DATA ===============
								case DOMAIN_TYPE is
									when "01" =>
										dom_type <= vliw;

										VLIW_RATIO_missing <= '1';
										VLIW_END_missing   <= '1';
									--ICN_END_missing			<= '1';
									--ICN_RATIO_missing			<= '1';
									when "10" =>
										dom_type <= icn;

										--VLIW_RATIO_missing		<= '1';
										--VLIW_END_missing			<= '1';
										ICN_END_missing   <= '1';
										ICN_RATIO_missing <= '1';
									when "11" =>
										dom_type <= vliw_and_icn; --vliw;--

										VLIW_RATIO_missing <= '1';
										VLIW_END_missing   <= '1';
										ICN_END_missing    <= '1';
										ICN_RATIO_missing  <= '1';
									when others =>
								--
								end case;
								-------------------------------------
								case conf_type_in is
									when "00" =>
										config_type <= setup_begin;
									when "01" =>
										config_type <= custom;
									when "10" =>
										config_type <= custom_last;
									when others =>
								--
								end case;
							-------------------------------------
							end if;     --==: if write_delay_last = '1'

						-- if 1:5----------------------
						elsif data_sending = '1' then
							state <= CONFIGURATE; -- !!! NETLIST CORRECTION !!!
							-- if 1:5:1 ----------------------
							if VLIW_RATIO_missing = '1' then
								VLIW_RATIO_missing <= '0';

								reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(VLIW_RATIO), C_DWIDTH);
								GlobCtrl_WrCE          <= "1000000000000000";
								GlobCtrl_BE            <= (others => '1');
							-- if 1:5:2 ----------------------
							elsif ICN_RATIO_missing = '1' then
								ICN_RATIO_missing <= '0';

								reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(ICN_RATIO), C_DWIDTH);
								GlobCtrl_WrCE          <= "0100000000000000";
								GlobCtrl_BE            <= (others => '1');
							-- if 1:5:3 ----------------------
							elsif COUNT_DOWN_missing = '1' then
								COUNT_DOWN_missing <= '0';
								--Ericles Sousa
								--								 reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(COUNT_DOWN), C_DWIDTH);
								GlobCtrl_WrCE      <= "0000000010000000";
								GlobCtrl_BE        <= (others => '1');
							-- if 1:5:4 ----------------------
							elsif start_address_missing = '1' then
								start_address_missing <= '0';

								case dom_type is
									when vliw =>
										reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(VLIW_BEGIN + offset_in), C_DWIDTH);
									when icn =>
										reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(ICN_BEGIN + offset_in), C_DWIDTH);
									when vliw_and_icn =>
										reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(VLIW_BEGIN + offset_in), C_DWIDTH);
									when others =>
								--
								end case;
								GlobCtrl_WrCE <= "0010000000000000";
								GlobCtrl_BE   <= (others => '1');
							-- if 1:5:5 ----------------------
							elsif VLIW_END_missing = '1' then
								VLIW_END_missing <= '0';

								reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(VLIW_END + offset_in), C_DWIDTH);
								GlobCtrl_WrCE          <= "0001000000000000";
								GlobCtrl_BE            <= (others => '1');
							-- if 1:5:6 ----------------------
							elsif ICN_END_missing = '1' then
								ICN_END_missing <= '0';

								reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(ICN_END + offset_in), C_DWIDTH);
								GlobCtrl_WrCE          <= "0000100000000000";
								GlobCtrl_BE            <= (others => '1');
							-- if 1:5:7 ----------------------
							elsif conf_type_missing = '1' then
								conf_type_missing <= '0';
								--------------------------------------------------------------------------------
								case dom_type is
									when vliw =>
										reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(1), C_DWIDTH);
									when icn =>
										reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(2), C_DWIDTH);
									when vliw_and_icn =>
										reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(4), C_DWIDTH);
									when others =>
								--
								end case;
								---------------------------------------------------------------------------------
								GlobCtrl_WrCE <= "0000000001000000";
								GlobCtrl_BE   <= (others => '1');
							-- if 1:5:8 ----------------------
							elsif MASK_VERTICAL_missing = '1' then
								MASK_VERTICAL_missing <= '0';

								reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(MASK_VERTICAL), C_DWIDTH);
								GlobCtrl_WrCE          <= "0000001000000000";
								GlobCtrl_BE            <= (others => '1');
							-- if 1:5:9 ----------------------
							elsif MASK_HORIZONTAL_missing = '1' then
								MASK_HORIZONTAL_missing <= '0';

								reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(MASK_HORIZONTAL), C_DWIDTH);
								GlobCtrl_WrCE          <= "0000000100000000";
								GlobCtrl_BE            <= (others => '1');

								source_select <= conv_std_logic_vector(1, CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH);

								--==================================================
								-- !!! NETLIST CORRECTION !!!	
								data_sending <= '1';

								ready_out <= '0'; -- !!! FOR SELF CLOCK GATING DISABLE
								-----------------
								state     <= CONFIGURATE; -- !!! NETLIST CORRECTION !!!	
								--==================================================

								--=========  SETUP CONFIGURATION DATA ==============
								if (config_type = setup_begin and LAST_FLAG = '1') or config_type = custom_last then
									conf_done_in_missing     <= '1';
									start_missing            <= '1';
									no_configuration_missing <= '1';
									vertical_ff_missing      <= '1';
									horizontal_ff_missing    <= '1';

								--ff_start_detection <= '1';

								end if;

							-- if 1:5:10 ----------------------
							elsif start_missing = '1' then
								if conf_done_in = '1' then
									conf_done_in_missing <= '0';

									-- TEST !!!
									ff_start_detection <= '1';
									GlobCtrl_BE        <= (others => '0');
									GlobCtrl_WrCE      <= (others => '0');

								end if;

								if conf_done_in_missing = '0' then
									if no_configuration_missing = '1' then
										no_configuration_missing <= '0';

										-- R E G I S T E R  9: set CONFIG_TYPE to 0
										reversed_GlobCtrl_Data <= conv_std_logic_vector(conv_integer(0), C_DWIDTH);
										GlobCtrl_WrCE          <= "0000000001000000";
										GlobCtrl_BE            <= (others => '1');

									elsif vertical_ff_missing = '1' then
										vertical_ff_missing <= '0';

										-- R E G I S T E R  6: set VERTICAL_MASK = FF
										reversed_GlobCtrl_Data <= (others => '1');
										GlobCtrl_WrCE          <= "0000001000000000";
										GlobCtrl_BE            <= (others => '1');

									elsif horizontal_ff_missing = '1' then
										horizontal_ff_missing <= '0';

										-- R E G I S T E R  6: set HORIZONTAL_MASK = FF
										reversed_GlobCtrl_Data <= (others => '1');
										GlobCtrl_WrCE          <= "0000000100000000";
										GlobCtrl_BE            <= (others => '1');

										start_missing <= '0';

										source_select <= conv_std_logic_vector(1, CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH);

									else --==: if no_configuration_missing = '1'


									end if;
								else    --===: if conf_done_in_missing = '1'

									reversed_GlobCtrl_Data <= (others => '0');

								end if; --===: if conf_done_in_missing = '1'

							-- if 1:5:11 ----------------------	
							else        --===: NOTHING MISSING ;-) -- !!! NETLIST CORRECTION !!!

								data_sending <= '0';
								GlobCtrl_BE  <= (others => '0');
								-----------------
								state        <= CONFIGURATE; -- !!! NETLIST CORRECTION !!!
							--state <= READY;
							-----------------
							end if;     --== if 1:5, if	VLIW_RATIO_missing

						-- if 1:6----------------------
						else            --===: --> data_sending = '0'
							if (config_type = setup_begin and LAST_FLAG = '1') or config_type = custom_last then
								---------------
								state <= READY;
							---------------
							else
								-----------------
								state <= WAITING;
							-----------------
							end if;
						end if;         --== main IF

					--!!!!!!!!!!!!
					when WAITING =>
						--!!!!!!!!!!!!

						ready_out <= '0';

						reversed_GlobCtrl_Data <= (others => '0'); -- !!! NETLIST CORRECTION
						GlobCtrl_BE            <= (others => '0');
						GlobCtrl_WrCE          <= (others => '0');

						--------------------
						state <= WAITING; -- !!! NETLIST CORRECTION
						-------------------


						if conf_done_in = '1' then
							if config_type = setup_begin and LAST_FLAG = '0' then
								source_select <= conv_std_logic_vector(2, CUR_DEFAULT_SOURCE_MUX_SELECT_WIDTH);

								RATIO_COUNTER <= 0;
								--daddr_missing  <= '1';

								header_missing <= '1';
								second_tact    <= '1';

								--VLIW_RATIO_missing		<= '1';
								--VLIW_END_missing			<= '1';
								--ICN_END_missing			<= '1';
								--ICN_RATIO_missing			<= '1';

								start_address_missing <= '1';
								COUNT_DOWN_missing    <= '1';

								MASK_HORIZONTAL_missing <= '1';
								MASK_VERTICAL_missing   <= '1';
								conf_type_missing       <= '1';

								source_addr <= NEXT_ADDRESS + offset_in;
								curr_daddr  <= NEXT_ADDRESS + offset_in;
								--------------------
								state       <= CONFIGURATE;
							-------------------
							else
								---------------
								state <= READY;
							---------------
							end if;     --==: if config_type = setup_begin and LAST_FLAG = '0'

						else            --if conf_done_in = '0'

							ready_out <= '0';
							--------------------
							state     <= WAITING; -- !!! NETLIST CORRECTION
						-------------------

						end if;         --==: if conf_done_in = '1'
					--------------------
					--state <= CONFIGURATE;
					--------------------
					--!!!!!!!!!!!!
					when others =>
						--!!!!!!!!!!!!

						ready_out <= '0';

						--------------------
						state <= INITIALIZE;
				--------------------
				end case;
			end if;
		end if;
	end process statechart;

	config_en_switch : process(conf_en_in, clk)
	begin
		if clk'event and clk = '1' then
			if conf_en_in = '1' then
				config_en <= '1';
			elsif config_en = '1' then
				config_en <= '0';
			end if;
		end if;
	end process config_en_switch;

end Behavioral;
