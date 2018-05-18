---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  fault_injection_module
-- Project Name:  
--
-- Engineer:    Éricles Sousa 
-- Create Date: March, 2017  
-- Description:  
--
--------------------------------------------------------------------------------------------------------------------------------


library ieee; 
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_SIGNED.all;

library grlib; 
use grlib.amba.all; 
use grlib.devices.all;
use grlib.stdlib.all;


library gaisler; 
use gaisler.misc.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.WPPE_LIB.all;
use wppa_instance_v1_01_a.DEFAULT_LIB.all;
use wppa_instance_v1_01_a.ARRAY_LIB.all;
use wppa_instance_v1_01_a.TYPE_LIB.all;
use wppa_instance_v1_01_a.INVASIC_LIB.all;

entity fault_injection_module is
	generic (
		FAULT_TABLE_SIZE : integer := 256;
		DATA_WIDTH       : integer := 32;
		ADDR_WIDTH       : integer := 8
	);
	port (
		rstn 	         : in  std_ulogic;
		clk 	         : in  std_ulogic;
		tcpa_start       : in  std_logic;
		tcpa_stop        : in  std_logic;
		en               : in  std_logic;
		addr             : out std_logic_vector(ADDR_WIDTH-1 downto 0);
		ren              : out std_logic;
		dbg_config_done  : out std_logic;
		dbg_fsm_state    : out std_logic_vector(3 downto 0);
		din              : in  std_logic_vector(DATA_WIDTH-1 downto 0);
	 	global_cnt       : out std_logic_vector(31 downto 0);
	 	dbg_counter      : out std_logic_vector(95 downto 0);
		total_of_entries : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		fault_injection  : out t_fault_injection_module 
	);
end;

architecture rtl of fault_injection_module is
type fault_data_structure is record
	cycle     : std_logic_vector(31 downto 0);
	location  : std_logic_vector(31 downto 0);
	mask      : std_logic_vector(31 downto 0);
end record fault_data_structure;
type t_fault_injection_table is array (0 to FAULT_TABLE_SIZE-1) of fault_data_structure;
type t_state is (IDLE, LOAD_CYCLE, LOAD_LOCATION, LOAD_MASK, STOP);

signal state, next_state     : t_state;
signal fault_injection_table : t_fault_injection_table;

signal global_counter   : std_logic_vector(31 downto 0);
signal relative_counter : std_logic_vector(31 downto 0);
signal dbg_counter_sig      : std_logic_vector(95 downto 0);
signal next_addr_out    : std_logic_vector(ADDR_WIDTH-1 downto 0);

signal debug_pe_column_sel        : integer range 0 to 2**ADDR_WIDTH;
signal debug_pe_row_sel           : integer range 0 to 2**ADDR_WIDTH;
signal write_addr                 : integer range 0 to 2**ADDR_WIDTH;
signal read_addr                  : integer range 0 to 2**ADDR_WIDTH;
signal last_valid_addr            : integer range 0 to 2**ADDR_WIDTH;
signal total_of_entries_int       : integer range 0 to 2**ADDR_WIDTH;
signal inject_faults              : std_logic;
signal valid_fu_selection         : std_logic;
signal valid_pe_selection         : std_logic;
signal config_done                : std_logic;
signal increment_write_addr       : std_logic;
signal fault_injection_done       : std_logic;

begin	
	global_counter_process : process(rstn, clk, tcpa_start, tcpa_stop, config_done)
	begin
		 if(rstn = '0') then
			global_counter   <= (others=>'0');
			inject_faults    <= '0';

		elsif rising_edge(clk) then
			global_cnt <= global_counter;
			if((en and config_done) = '1') then
				--if(tcpa_start = '1' and tcpa_stop = '0') then
				if(tcpa_start = '1') then
					--This counter starts when the TCPA starts a computation
					global_counter <= std_logic_vector(unsigned(global_counter) + 1);
					inject_faults <= '1';
				else
					inject_faults <= '0';
				end if;
			else
				inject_faults <= '0';
				global_counter <= (others=>'0'); 
			end if;
		end if;
	end process;

	config_fault_injection_table : process(rstn, state, en, din, next_addr_out, total_of_entries_int)
	begin
		case state is
			when IDLE =>
				if(en = '1') then
					ren <= '1';
					next_state <= LOAD_CYCLE;
					dbg_fsm_state <= x"2";
				else
					next_state <= IDLE;
					config_done <= '0';
					ren <= '0';
					increment_write_addr <= '0';
					dbg_fsm_state <= x"1";
				end if;
			when LOAD_CYCLE =>
				increment_write_addr <= '0';
				dbg_fsm_state <= x"3";

				if((rstn = '0') or (en = '0')) then
					next_state <= IDLE;
					config_done <= '0';
				elsif(unsigned(next_addr_out) = total_of_entries_int) then
					next_state <= STOP;
					increment_write_addr <= '0';
					dbg_fsm_state <= x"4";
				else
					next_state <= LOAD_LOCATION;
					dbg_fsm_state <= x"5";
				end if;

			when LOAD_LOCATION =>
				dbg_fsm_state <= x"6";

				if((rstn = '0') or (en = '0')) then
					next_state <= IDLE;
					config_done <= '0';
				elsif(unsigned(next_addr_out) = total_of_entries_int) then
					next_state <= STOP;
					increment_write_addr <= '0';
					dbg_fsm_state <= x"7";
				else
					next_state <= LOAD_MASK;
					dbg_fsm_state <= x"8";
				end if;

			when LOAD_MASK =>
				dbg_fsm_state <= x"9";

				if((rstn = '0') or (en = '0')) then
					next_state <= IDLE;
					config_done <= '0';
				elsif(unsigned(next_addr_out) = total_of_entries_int) then
					next_state <= STOP;
					increment_write_addr <= '0';
					dbg_fsm_state <= x"A";
				else
					next_state <= LOAD_CYCLE;
					increment_write_addr <= '1';
					dbg_fsm_state <= x"B";
				end if;
				
			when STOP =>
				if((rstn = '0') or (en = '0')) then
					next_state <= IDLE;
					config_done <= '0';
					dbg_fsm_state <= x"D";
				else
					next_state <= STOP;
					config_done <= '1';
					ren <= '0';
					dbg_fsm_state <= x"C";
					increment_write_addr <= '0';
				end if;
			when others =>
				dbg_fsm_state <= x"E";
				--null;
		end case;
	end process;


	controller : process(rstn, clk)
	begin
		if(rstn = '0') then
			next_addr_out <= (others=>'0');
			state <= IDLE;
			total_of_entries_int <= 0;		
			last_valid_addr <= 0;
			write_addr <= 0;

		elsif rising_edge(clk) then 
			dbg_config_done <= config_done;
			state <= next_state;

			if(state = STOP) then
				if(en = '0') then
					next_addr_out <= (others=>'0');
					state <= IDLE;
					total_of_entries_int <= 0;		
					last_valid_addr <= 0;
					write_addr <= 0;
				end if;
			end if;

			if(unsigned(total_of_entries) > FAULT_TABLE_SIZE) then 
				total_of_entries_int <= FAULT_TABLE_SIZE-1;
			else
				total_of_entries_int <= to_integer(unsigned(total_of_entries));
			end if;
	
			if((en = '1') and (config_done = '0')) then
				next_addr_out <= std_logic_vector(unsigned(next_addr_out)+1);
			else
				next_addr_out <= (others=>'0');
			end if;
			if((config_done = '1') and (en = '1')) then
				last_valid_addr <= write_addr;
			else
				last_valid_addr <= 0;
			end if;
			if(increment_write_addr = '1') then
				if(write_addr = FAULT_TABLE_SIZE-1) then
					write_addr <= 0;
	                        else
	                        	write_addr <= write_addr + 1;
				end if;
			end if;

			--Loading fault_injection_table
			if(state = LOAD_CYCLE) then
				fault_injection_table(write_addr).cycle <= din;
			elsif(state = LOAD_LOCATION) then
				fault_injection_table(write_addr).location <= din;
			elsif(state = LOAD_MASK) then
				fault_injection_table(write_addr).mask <= din;
			end if;

		end if;
	end process;

	addr  <= next_addr_out;
	fault_injector : process(rstn, clk)
	begin
		if(rstn = '0') then
			fault_injection.mask   <= (others=>'0');
			fault_injection.fu_sel <= (others=>'0'); 
			fault_injection.pe_sel <= (others=>(others=>'0'));
			valid_fu_selection     <= '0';
			valid_pe_selection     <= '0';
			read_addr              <= 0;
			debug_pe_row_sel       <= 0;
			debug_pe_column_sel    <= 0; 
			fault_injection_done   <= '0';
			relative_counter       <= (others=>'0');
			dbg_counter_sig        <= (others=>'0');
			
		elsif rising_edge(clk) then 
			dbg_counter <= dbg_counter_sig;
			fault_injection.mask   <= (others=>'0');
			fault_injection.fu_sel <= (others=>'0'); 
			fault_injection.pe_sel <= (others=>(others=>'0'));

	 		if((en ='0') or (config_done = '0')) then
				valid_fu_selection     <= '0';
				valid_pe_selection     <= '0';
				read_addr              <= 0;
				debug_pe_row_sel       <= 0;
				debug_pe_column_sel    <= 0; 
				fault_injection_done   <= '0';
				relative_counter       <= (others=>'0');
				dbg_counter_sig        <= (others=>'0');
			end if;

	
			--if(inject_faults = '1' and tcpa_start = '1' and tcpa_stop = '0' and fault_injection_done = '0') then	
			if(inject_faults = '1' and fault_injection_done = '0') then	

				dbg_counter_sig(31 downto 8) <= std_logic_vector(unsigned(dbg_counter_sig(31 downto 8))+1);	
				if(unsigned(fault_injection_table(read_addr).cycle)-1 = unsigned(relative_counter)) then
					relative_counter <= (others=>'0');


					dbg_counter_sig(7 downto 0) <= std_logic_vector(unsigned(dbg_counter_sig(7 downto 0))+1);	
					fault_injection.mask   <= fault_injection_table(read_addr).mask;

					-- Functional Unit Selection --
					-- Check if the selected FU is in the in valid range from 0 to CUR_DEFAULT_NUM_OF_FUS-1
					if(unsigned(fault_injection_table(read_addr).location(CUR_DEFAULT_NUM_OF_FUS+7 downto 8)) <= CUR_DEFAULT_NUM_OF_FUS-1 ) then
						valid_fu_selection <= '1';
						--srl 8 , because only (31 downto 8) contains the FUs location 
						fault_injection.fu_sel <= fault_injection_table(read_addr).location(CUR_DEFAULT_NUM_OF_FUS+7 downto 8);
						dbg_counter_sig(63 downto 32) <= global_counter;	
					else
						valid_fu_selection <= '0';
						fault_injection.fu_sel <= (others=>'0'); 
						dbg_counter_sig(63 downto 32) <= (others=>'1');	
					end if;	
	
					-- PE Selection --
					-- Check if the selected PE is in the valid range (0 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1, 0 to CUR_DEFAULT_NUM_WPPE_VERTICAL-1)
					if(unsigned(fault_injection_table(read_addr).location(7 downto 4)) <= CUR_DEFAULT_NUM_WPPE_VERTICAL-1) then
						if(unsigned(fault_injection_table(read_addr).location(3 downto 0)) <= CUR_DEFAULT_NUM_WPPE_HORIZONTAL-1 ) then
							fault_injection.pe_sel(to_integer(unsigned(fault_injection_table(read_addr).location(3 downto 0))) , to_integer(unsigned(fault_injection_table(read_addr).location(7 downto 4)))) <= '1';
							debug_pe_column_sel <= to_integer(unsigned(fault_injection_table(read_addr).location(7 downto 4)));
							debug_pe_row_sel <= to_integer(unsigned(fault_injection_table(read_addr).location(3 downto 0)));
							dbg_counter_sig(95 downto 64) <= global_counter;	

							valid_pe_selection <= '1';
						else
							fault_injection.pe_sel <= (others=>(others=>'0'));
							valid_pe_selection <= '0';
							dbg_counter_sig(95 downto 64) <= (others=>'1');	
						end if;
					else
						valid_pe_selection <= '0';
						fault_injection.pe_sel <= (others=>(others=>'0'));
						dbg_counter_sig(95 downto 64) <= (others=>'1');	
					end if;

					if(read_addr = last_valid_addr) then
						fault_injection_done <= '1';
					else
						read_addr <= read_addr + 1;
					end if;
				else
					relative_counter   <= std_logic_vector(unsigned(relative_counter) + 1);
					valid_pe_selection <= '0';
					valid_fu_selection <= '0';
					fault_injection.pe_sel <= (others=>(others=>'0'));
				end if;
			else
				valid_pe_selection <= '0';
				valid_fu_selection <= '0';
			end if;
		end if;
	end process;
end;



