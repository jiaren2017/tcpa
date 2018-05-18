---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  top_hardware_interface - Behavioral
-- Project Name: Configuration Manager 
--
-- Engineer:     Ericles Sousa
-- Create Date:  17:35:45 10/21/2013 
-- Description:  This module provides the hardware interface to configure and program a TCPA
--
--------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;

library gaisler;
use gaisler.misc.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;

library gaisler;
use gaisler.misc.all;

--For TCPA
library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;
use wppa_instance_v1_01_a.default_LIB.ALL;
use wppa_instance_v1_01_a.array_LIB.ALL;
use wppa_instance_v1_01_a.INVASIC_LIB.ALL;

library UNISIM;
use UNISIM.VComponents.all;

use work.data_type_pkg.all;     -- for input and output format between amba_interface and tcpa components

entity top_hardware_interface is
	generic(
		pindex : integer := 12;
		-- paddr  : integer := 12;
		-- pmask  : integer := 16#fff#
        SUM_COMPONENT   : integer
        );
	port(
		rst                          : in  std_ulogic;
		amba_clk                     : in  std_ulogic;
		--		wppa_data_output             : in t_wppa_data_output_interface;

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
end top_hardware_interface;

architecture Behavioral of top_hardware_interface is
	signal sig_address_position        : STD_LOGIC_VECTOR(31 downto 0);
	constant MAX_MEM_SIZE              : integer            := CUR_DEFAULT_SOURCE_MEM_SIZE; --8*1024;
	signal sig_en_addr_gen             : STD_LOGIC_VECTOR(0 downto 0);
	signal sig_ahbsi                   : ahb_slv_in_type;
	signal sig_ahbso                   : ahb_slv_out_vector := (others => ahbs_none);
	signal sig_tcpa_config_done        : std_logic;
	signal sig_tcpa_config_done_vector : std_logic_vector(31 downto 0);
	signal sig_mem_buffer_out_din      : std_logic_vector(31 downto 0);
	signal sig_mem_buffer_out_we       : std_logic_vector(0 downto 0);
	signal sig_mem_buffer_out_addra    : std_logic_vector(18 downto 0);
	signal sig_out_buffer_addr_b       : STD_LOGIC_VECTOR(18 downto 0);
	signal sig_out_buffer_dout         : STD_LOGIC_VECTOR(31 downto 0);
	signal sig_out_buffer_addr_b_temp  : STD_LOGIC_VECTOR(18 downto 0);
	signal sig_out_buffer_dout_temp    : STD_LOGIC_VECTOR(31 downto 0);

	signal sig_in_buffer_din    : std_logic_vector(31 downto 0);
	signal sig_in_buffer_we     : std_logic_vector(0 downto 0);
	signal sig_in_buffer_addr_a : std_logic_vector(18 downto 0);
	signal sig_in_buffer_addr_b : std_logic_vector(18 downto 0);
	signal sig_in_buffer_dout   : std_logic_vector(31 downto 0);

	signal tcpa_data_output   : t_wppa_data_output_interface;
	signal sig_reconfig_tcpa  : STD_LOGIC;
	signal sig_global_address : STD_LOGIC_VECTOR(18 downto 0);
	signal rst_addr           : STD_LOGIC_VECTOR(0 downto 0);

	signal counter         : integer := 0;
	signal load_config_cnt : integer := 0;

	--For Debug
	signal CONFIGURATION_NAME : string(1 to 19); -- := "EMPTY";

	--
	--	signal sig_wppa_data_input                : t_wppa_data_input_interface;
	--	signal sig_wppa_data_output               : t_wppa_data_output_interface;
	--
	signal sig_wppa_ctrl_input  : t_wppa_ctrl_input_interface;
	signal sig_wppa_ctrl_output : t_wppa_ctrl_output_interface;
	--
	signal sig_select_clk       : std_logic;
	signal tcpa_config_rst_i    : std_logic;
	signal tcpa_rst             : std_logic;
	signal tcpa_rst_apb         : std_logic;
	signal tcpa_rst_ahb         : std_logic;

	--For configuration controller
	signal rst_cnt          : integer                       := 0;
	signal read_en          : std_logic;
	signal load_tcpa_config : std_logic_vector(3 downto 0)  := (others => '0');
	signal bus2ip_be_cnt    : integer                       := 0;
	signal bus2ip_wrce_cnt  : integer                       := 0;
	signal current_config   : std_logic_vector(31 downto 0) := (others => '0');

	--For interface
	constant REVISION : integer         := 0;
	-- constant PCONFIG  : apb_config_type := (0 => ahb_device_reg(VENDOR_CONTRIB,
			                                -- CONTRIB_CORE2,
			                                -- 0,
			                                -- 0,
			                                -- 0),
		                                    -- 1 => apb_iobar(paddr,
			                                -- pmask));

	type registers is record
		reg : std_logic_vector(31 downto 0);
	end record;
	signal r, rin   : registers;
	signal pCommand : registers;
	signal pData    : registers;
	signal pLoad    : registers;
	signal pDebug   : registers;

	type legal_states is (IDLE, START, LOAD_CONFIG, INFECT, CONFIG_TCPA, STOP);
	signal state     : legal_states := IDLE;
	signal debugging : std_logic_vector(31 downto 0);

	signal sig_reset_tcpa           : std_logic := '0';
	signal pulse_reset_tcpa_counter : integer := 5; 


	constant PULSE_TCPA_RESET : std_logic_vector(31 downto 0) := x"000000FB";
	constant RESET            : std_logic_vector(31 downto 0) := x"000000FC";
	constant LOAD_PRE_CONFIG  : std_logic_vector(31 downto 0) := x"000000FF";
	constant NEW_CONFIG_START : std_logic_vector(31 downto 0) := x"000000FE";
	constant NEW_CONFIG_END   : std_logic_vector(31 downto 0) := x"000000FD";
	signal config_status      : std_logic_vector(31 downto 0) := x"00000000";

	--------------------------------------------------------------------------------------------------------------------------------  
	-- AHB connection
	--------------------------------------------------------------------------------------------------------------------------------  
	signal tcpa_config_we     : std_logic_vector(0 downto 0);
	signal tcpa_config_addr   : std_logic_vector(31 downto 0);
	signal tcpa_config_din    : std_logic_vector(31 downto 0);
	signal tcpa_config_stream : std_logic_vector(31 downto 0);

	signal sig_in_buffer_addr_b_temp : STD_LOGIC_VECTOR(18 downto 0);
	signal sig_in_buffer_dout_temp   : STD_LOGIC_VECTOR(31 downto 0);

	--------------------------------------------------------------------------------------------------------------------------------  
	signal clk : std_ulogic;

begin

	------------------------------------------------------------------------------------------------------------------------------  
	-- apb : process(rst, r, apbi, amba_clk)
    apb : process(rst, r, IF_COMP_data, amba_clk)
		------------------------------------------------------------------------------------------------------------------------------  	
		variable readdata  : std_logic_vector(31 downto 0);
		variable data_flag : std_logic := '0';
		variable v         : registers;
	begin
		v := r;

		-- read register
		readdata := (others => '0');

		-- system reset
		if rst = '0' then
			pCommand.reg                <= (others => '0');
			pData.reg                   <= (others => '0');
			pLoad.reg                   <= (others => '0');
			pDebug.reg                  <= (others => '0');
			counter                     <= 0;
			readdata                    := (others => '0');
			sig_tcpa_config_done        <= '0';
			sig_tcpa_config_done_vector <= (others => '0');
			data_flag                   := '0';
			tcpa_config_we              <= "0";
			config_status               <= RESET;
			sig_reset_tcpa              <= '0';
			pulse_reset_tcpa_counter    <= 0;

		elsif amba_clk'event and amba_clk = '1' then
			sig_tcpa_config_done        <= tcpa_config_done;
			sig_tcpa_config_done_vector <= tcpa_config_done_vector;

			if pulse_reset_tcpa_counter = 0 then
				sig_reset_tcpa <= '0';
			else
				pulse_reset_tcpa_counter <= pulse_reset_tcpa_counter - 1;
				sig_reset_tcpa <= '1';
			end if;
			--tcpa_data_output <= wppa_data_output;
			
			--------------------------------------------------
			-- Sync write operation
			--------------------------------------------------
			--if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
            if (IF_COMP_data(pindex).hsel and '1' and IF_COMP_data(pindex).hwrite) = '1' then
				case IF_COMP_data(pindex).haddr(4 downto 2) is              --case apbi.paddr(4 downto 2) is
					when "000" =>
						pCommand.reg <= IF_COMP_data(pindex).hwdata;        --apbi.pwdata;
                        
						if IF_COMP_data(pindex).(hwdata) = RESET then       --if apbi.pwdata = RESET then
							--v.reg := (others => '0'); 
							pCommand.reg  <= (others => '0');
							pData.reg     <= (others => '0');
							pLoad.reg     <= (others => '0');
							pDebug.reg    <= (others => '0');
							counter       <= 0;
							config_status <= RESET;

						elsif IF_COMP_data(pindex).(hwdata) = NEW_CONFIG_START then       --elsif apbi.pwdata = NEW_CONFIG_START then
							config_status <= NEW_CONFIG_START;
							counter       <= 0;

						elsif IF_COMP_data(pindex).(hwdata) = NEW_CONFIG_END then         --elsif apbi.pwdata = NEW_CONFIG_END then
							tcpa_config_we <= "0";
							config_status  <= NEW_CONFIG_END;
							counter        <= 0;

						elsif IF_COMP_data(pindex).(hwdata) = PULSE_TCPA_RESET then       --elsif apbi.pwdata = PULSE_TCPA_RESET then
							sig_reset_tcpa <= '1';
							pulse_reset_tcpa_counter <= 5; 

						else
							config_status <= LOAD_PRE_CONFIG;

						end if;

					when "001" =>
						pData.reg <= IF_COMP_data(pindex).hwdata;      --apbi.pwdata;
						if counter = MAX_MEM_SIZE then
							counter <= 0;
						else
							counter <= counter + 1;
						end if;
						pDebug.reg <= conv_std_logic_vector(counter, 32);
						if config_status = NEW_CONFIG_START then
							tcpa_config_we   <= "1";
							tcpa_config_addr <= conv_std_logic_vector(counter, 32);
							tcpa_config_din  <= IF_COMP_data(pindex).hwdata     --apbi.pwdata;
						end if;

					when others => null;
				end case;
			end if;
		end if;

		--------------------------------------------------
		-- Async read operation
		--------------------------------------------------
		case IF_COMP_data(pindex).haddr(4 downto 2) is          --case apbi.paddr(4 downto 2) is
			when "000" => HW_IF_data.hrdata <= pCommand.reg(31 downto 0);     --when "000" => apbo.prdata <= pCommand.reg(31 downto 0);
			when "001" => HW_IF_data.hrdata <= pData.reg(31 downto 0);        --when "001" => apbo.prdata <= pData.reg(31 downto 0);
			when "010" => HW_IF_data.hrdata <= debugging;                     --when "010" => apbo.prdata <= debugging;
			when "011" => HW_IF_data.hrdata <= pDebug.reg(31 downto 0);       --when "011" => apbo.prdata <= pDebug.reg(31 downto 0);
			when "100" =>
				HW_IF_data.hrdata    <= (others => '0');                      --apbo.prdata    <= (others => '0');
				HW_IF_data.hrdata(0) <= sig_tcpa_config_done;                 --apbo.prdata(0) <= sig_tcpa_config_done;

			when "101" => HW_IF_data.hrdata <= (others => '0');               --when "101" => apbo.prdata <= (others => '0');
				HW_IF_data.hrdata(0)        <= read_en;                       --apbo.prdata(0)        <= read_en;
			when "110" => HW_IF_data.hrdata <= tcpa_config_stream;            --when "110" => apbo.prdata <= tcpa_config_stream;
			when "111" => HW_IF_data.hrdata <= sig_tcpa_config_done_vector;   --when "111" => apbo.prdata <= sig_tcpa_config_done_vector;

			--PE(0,0)
			--when "01000"  => apbo.prdata <= wppa_data_output.external_top_north_out(31 downto 0);
			--when "01001"  => apbo.prdata <= wppa_data_output.external_top_north_out(63 downto 32);
			--when "01010"  => apbo.prdata <= wppa_data_output.external_top_north_out(95 downto 64);

			--when "01011"  => apbo.prdata <= wppa_data_output.external_bottom_south_out(31 downto 0);
			--when "01100"  => apbo.prdata <= wppa_data_output.external_bottom_south_out(63 downto 32);
			--when "01101"  => apbo.prdata <= wppa_data_output.external_bottom_south_out(95 downto 64);

			--when "01110"  => apbo.prdata <= wppa_data_output.external_left_west_out(31 downto 0);
			--when "01111"  => apbo.prdata <= wppa_data_output.external_left_west_out(63 downto 32);
			--when "10000"  => apbo.prdata <= wppa_data_output.external_left_west_out(95 downto 64);

			--when "10001"  => apbo.prdata <= wppa_data_output.external_right_east_out(31 downto 0);
			--when "10010"  => apbo.prdata <= wppa_data_output.external_right_east_out(63 downto 32);
			--when "10011"  => apbo.prdata <= wppa_data_output.external_right_east_out(95 downto 64);

			--PE(3,0)
			--when "10100"  => apbo.prdata <= wppa_data_output.external_right_east_out(319 downto 288);
			--when "10101"  => apbo.prdata <= wppa_data_output.external_right_east_out(351 downto 320);
			--when "10111"  => apbo.prdata <= wppa_data_output.external_right_east_out(383 downto 352);

			when others => null;
		end case;
		rin <= v;
	end process;

    
	-- apbo.pirq    <= (others => '0');
	-- apbo.pindex  <= pindex;
	-- apbo.pconfig <= PCONFIG;
    HW_IF_data.hready   <= '1';
    HW_IF_data.pirq     <= '0'
    HW_IF_data.pindex   <= pindex;
    HW_IF_data.hresp    <= (others => '0');   
    HW_IF_data.hsplit   <= (others => '0');

    

	send_config_to_tcpa : process(rst, amba_clk)
	begin
		if rst = '0' then               --active low

			icp_program_interface                <= (others => '0');
			invasion_input                       <= "00000" & "00000" & "00000" & "00000";
			parasitary_invasion_input            <= "00000" & "00000" & "00000" & "00000"; --(0 0 0 0)
			wppa_bus_input_interface.Bus2IP_Addr <= (others => '0');
			wppa_bus_input_interface.Bus2IP_Data <= (others => '0');
			wppa_bus_input_interface.Bus2IP_BE   <= (others => '0');
			wppa_bus_input_interface.Bus2IP_RdCE <= (others => '0');
			wppa_bus_input_interface.Bus2IP_WrCE <= (others => '0');
			current_config                       <= (others => '0');
			rst_cnt                              <= 0;
			bus2ip_be_cnt                        <= 0;
			bus2ip_wrce_cnt                      <= 0;
			tcpa_rst_apb                         <= '1'; --reset tcpa
			debugging                            <= (others => '0');
			state                                <= IDLE;
			load_tcpa_config                     <= x"0";
			read_en                              <= '0';
			enable_tcpa                          <= '0';

		elsif rising_edge(amba_clk) then
			wppa_bus_input_interface.Bus2IP_Data(1) <= '1';

			case state is
				when IDLE =>
					debugging(31 downto 16) <= x"0002";
					if config_status = RESET then
						icp_program_interface                <= (others => '0');
						invasion_input                       <= "00000" & "00000" & "00000" & "00000";
						parasitary_invasion_input            <= "00000" & "00000" & "00000" & "00000"; --(0 0 0 0)
						wppa_bus_input_interface.Bus2IP_Addr <= (others => '0');
						wppa_bus_input_interface.Bus2IP_Data <= (others => '0');
						wppa_bus_input_interface.Bus2IP_BE   <= (others => '0');
						wppa_bus_input_interface.Bus2IP_RdCE <= (others => '0');
						wppa_bus_input_interface.Bus2IP_WrCE <= (others => '0');
						current_config                       <= (others => '0');
						rst_cnt                              <= 0;
						bus2ip_be_cnt                        <= 0;
						bus2ip_wrce_cnt                      <= 0;
						tcpa_rst_apb                         <= '1'; --reset tcpa
						debugging(31 downto 16)              <= x"0000";
						state                                <= IDLE;
						load_tcpa_config                     <= x"0";
						enable_tcpa                          <= '0';
					else
						tcpa_rst_apb <= '0';
						if sig_tcpa_config_done = '0' and config_status <= NEW_CONFIG_END then
							CONFIGURATION_NAME <= "Config : EXTERNAL  ";
							state              <= START;
							rst_cnt            <= 0;
							load_tcpa_config   <= x"4";
							read_en            <= '1';
						else
							load_tcpa_config <= (others => '0');
							read_en          <= '0';
						end if;
					end if;

				when START =>
					enable_tcpa     <= '0';
					load_config_cnt <= 0;
					if rst_cnt = 10 then
						tcpa_rst_apb            <= '0'; --active tcpa
						rst_cnt                 <= 0;
						state                   <= LOAD_CONFIG;
						debugging(31 downto 16) <= x"0011";
					else
						tcpa_rst_apb            <= '1'; --reset tcpa
						rst_cnt                 <= rst_cnt + 1;
						bus2ip_be_cnt           <= 0;
						bus2ip_wrce_cnt         <= 0;
						debugging(31 downto 16) <= x"0010";
					end if;

				when LOAD_CONFIG =>
					icp_program_interface(1) <= '0';
					icp_program_interface(0) <= '1';
					invasion_input           <= "00000" & "00000" & "00000" & "00000";
					state                    <= INFECT;
					bus2ip_be_cnt            <= 0;
					debugging(31 downto 16)  <= x"0012";
				when INFECT =>
					if bus2ip_be_cnt = 10 * 10 then
						bus2ip_wrce_cnt                       <= 0;
						state                                 <= CONFIG_TCPA;
						wppa_bus_input_interface.Bus2IP_BE(0) <= '0';
						debugging(31 downto 16)               <= x"0013";
					else
						bus2ip_be_cnt                         <= bus2ip_be_cnt + 1;
						wppa_bus_input_interface.Bus2IP_BE(0) <= '1';
						debugging(31 downto 16)               <= x"0014";
					end if;

				when CONFIG_TCPA =>
					if bus2ip_wrce_cnt = 200 * 10 then --time to load the configuration into TCPA
						wppa_bus_input_interface.Bus2IP_WrCE(1) <= '0';
						wppa_bus_input_interface.Bus2IP_WrCE(3) <= '1';
						bus2ip_wrce_cnt                         <= bus2ip_wrce_cnt + 1;
						debugging(31 downto 16)                 <= x"0015";
					elsif bus2ip_wrce_cnt = 1023 * 10 then --minimum time to load a program into a PE
						if (sig_tcpa_config_done) = '1' then
							state <= STOP;
						end if;
						debugging(31 downto 16) <= x"0016";
					else
						bus2ip_wrce_cnt                         <= bus2ip_wrce_cnt + 1;
						wppa_bus_input_interface.Bus2IP_WrCE(1) <= '1';
						debugging(31 downto 16)                 <= x"0017";
					end if;

				when STOP =>
					sig_select_clk          <= '1';
					debugging(31 downto 16) <= x"0018";
					enable_tcpa             <= '1';
					
					--reset tcpa
					tcpa_rst_apb            <= '1'; 	
					
					--Check if TCPA is configured
					if (sig_tcpa_config_done) = '1' then
						debugging(31 downto 16) <= x"0019";
						--enable_tcpa  <= '1';
						load_tcpa_config        <= x"0";
						sig_reconfig_tcpa       <= '0';
						--state          <= IDLE;
						tcpa_rst_apb            <= '0';
					end if;
					if config_status = RESET then
						state        <= IDLE;
						--reset tcpa
						tcpa_rst_apb <= '1';	
					end if;

				when others =>
					state                   <= IDLE;
					debugging(31 downto 16) <= x"0020";
			end case;

			--Mux (output the configuration)
			case load_tcpa_config is
				--Choose configuration 1
				when x"1" =>
					--debugging <= (conv_integer(x"01" & "000000" & wppa_memory_output_interface.to_input_mem_addr(9 downto 0)));
					debugging(15 downto 0) <= wppa_memory_output_interface.to_input_mem_addr(15 downto 0);

				--Choose configuration 2						 		
				when x"2" =>
					--debugging <= (conv_integer(x"02" & "000000" & wppa_memory_output_interface.to_input_mem_addr(9 downto 0)));
					debugging(15 downto 0) <= wppa_memory_output_interface.to_input_mem_addr(15 downto 0);

				--Choose configuration 3
				when x"3" =>
					--debugging <= (conv_integer(x"03" & "000000" & wppa_memory_output_interface.to_input_mem_addr(9 downto 0)));
					debugging(15 downto 0) <= wppa_memory_output_interface.to_input_mem_addr(15 downto 0);

				when x"4" =>
					--debugging <= (conv_integer(x"04" & "000000" & wppa_memory_output_interface.to_input_mem_addr(9 downto 0)));
					debugging(15 downto 0) <= wppa_memory_output_interface.to_input_mem_addr(15 downto 0);

				when x"5" =>
					--debugging <= (conv_integer(x"05" & "000000" & wppa_memory_output_interface.to_input_mem_addr(9 downto 0)));
					debugging(15 downto 0) <= wppa_memory_output_interface.to_input_mem_addr(15 downto 0);

				when others =>
					debugging(15 downto 0) <= x"0024";
			--debugging(31 downto 16) <= x"0024";
			end case;
			tcpa_rst        <= tcpa_rst_apb or sig_reset_tcpa;
			tcpa_config_rst_i <= tcpa_rst;
			tcpa_config_rst <= tcpa_config_rst_i;
		end if;
	end process;

	-- pragma translate_off
	-- bootmsg : report_version 
	-- generic map ("(Re)Configuration Manager connection for TCPAs" & tost(hindex) & ": APB connection rev 2, " & tost(kbytes) & " kbytes");
	-- pragma translate_on
	--------------------------------------------------------------------------------------------------------------------------------  

	inst_tcpa_config_mem : entity work.tcpa_config_mem
		--generic map(memory_size => MAX_MEM_SIZE)
		port map(
			rstn  => rst,
			clk   => amba_clk,
			ena   => tcpa_config_we(0),
			enb   => read_en,
			wea   => tcpa_config_we(0),
			addra => tcpa_config_addr(15 downto 0),
			addrb => wppa_memory_output_interface.to_input_mem_addr(15 downto 0),
			dia   => tcpa_config_din,
			--dob    => wppa_memory_input_interface.from_input_mem_data);
			dob   => tcpa_config_stream);
	wppa_memory_input_interface.from_input_mem_data <= tcpa_config_stream;
--------------------------------------------------------------------------------------------------------------------------------    
end Behavioral;




