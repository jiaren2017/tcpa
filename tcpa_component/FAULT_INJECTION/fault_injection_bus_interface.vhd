---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name: fault_injection_bus_interface 
-- Project Name:  
--
-- Engineer:     Éricles Sousa
-- Create Date:  March, 2017
-- Description:  
--
--------------------------------------------------------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_SIGNED.all;

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
use work.data_type_pkg.all;     -- for input and output format between amba_interface and tcpa components

entity fault_injection_bus_interface is
	generic (
		MEM_SIZE  : integer := 128;
		DATA_WIDTH        : integer := 32;
		ADDR_WIDTH        : integer := 7;
		NUM_OF_IC_SIGNALS : integer := 1;
		pindex            : integer := 0;
		pirq              : integer := 0;
		-- paddr             : integer := 0;
		-- pmask             : integer := 16#fff#
        SUM_COMPONENT     : integer
        );
	port (
		rstn	         : in std_ulogic;
		clk 	         : in std_ulogic;
		tcpa_start       : in std_logic;
		tcpa_stop        : in std_logic;
		ready            : out std_logic; -- FIM		
		fim_rstn         : out std_logic; -- FIM		
		ren              : in std_ulogic; -- FIM
		addr             : in std_logic_vector(ADDR_WIDTH-1 downto 0); --FIM
		dout             : out std_logic_vector(31 downto 0); --FIM
		total_of_entries : out std_logic_vector(ADDR_WIDTH-1 downto 0);
		error_status     : in t_error_status;
	 	global_counter   : in std_logic_vector(31 downto 0);
	 	dbg_counter      : in std_logic_vector(95 downto 0);
		dbg_fault_injection: in t_fault_injection_module;
		dbg_config_done    : in std_logic;
		dbg_fsm_state      : in std_logic_vector(3 downto 0);
	                -- apbi            : in apb_slv_in_type;
	                -- apbo            : out apb_slv_out_type
        IF_COMP_data        : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
        FI_BUS_IF_data      : out rec_COMP_IF
        );
end;

architecture rtl of fault_injection_bus_interface is

component fim_memory is
	generic(
		--###########################################################################
		-- Memory parameters, do not add to or delete
		--###########################################################################
		MEM_SIZE    : integer := 128;
		DATA_WIDTH  : integer range 1 to 32 := 32;
		ADDR_WIDTH  : integer range 1 to 16  := 7
		--###########################################################################		
	);
	port(
		-- Write Port
		wr_clk      : in  std_logic;
		en          : in  std_logic;
		we          : in  std_logic;
		wr_data     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		wr_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		wr_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);

		-- Read Port
		rd_clk      : in  std_logic;
		re          : in  std_logic;
		rd_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		rd_data     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end component fim_memory;


constant REVISION : integer := 0;
constant PCONFIG : apb_config_type := (0 => ahb_device_reg (VENDOR_CONTRIB, CONTRIB_CORE1, 0, 1, pirq),
				       1 => apb_iobar(paddr, pmask));

constant FAULT_INJECTION_EN_ADDR : integer := 4;
constant NUM_OF_FAULTS           : integer := 5;
constant NUM_OF_STATUS_REGISTERS : integer := 6; --1 to set/reset configuration memory and 5 to report error status 
constant MEM_ADDR_WIDTH          : integer := log2(MEM_SIZE);
constant TOTAL_OF_ADDRESSES      : integer := MEM_SIZE + NUM_OF_STATUS_REGISTERS;

type registers is record
	en   : std_logic;
	wen  : std_logic;
	ren  : std_logic;
	data : std_logic_vector(DATA_WIDTH-1 downto 0);
	addr_in : integer range 0 to 2**(MEM_ADDR_WIDTH+1);
	addr : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
end record;

signal pe_rows_and_columns : t_pe_rows_and_columns;
signal pe_row              : std_logic_vector(31 downto 0);
signal pe_column           : std_logic_vector(31 downto 0);
signal pe_index            : std_logic_vector(31 downto 0);
signal error_diagnosis     : std_logic_vector(31 downto 0);
signal apb_dout            : std_logic_vector(31 downto 0);
signal apb_addr            : integer range 0 to 2**MEM_ADDR_WIDTH;

signal r            : registers;
signal rin          : registers;
signal mem_dout     : std_logic_vector(DATA_WIDTH-1 downto 0);
signal temp         : std_logic_vector(DATA_WIDTH-1 downto 0);
signal mem_waddr    : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
signal mem_raddr    : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
signal mem_din      : std_logic_vector(DATA_WIDTH-1 downto 0);
signal mem_en       : std_logic;
signal mem_ren      : std_logic;
signal mem_wen      : std_logic;
signal load_config_done  : std_logic;
signal clear_pending_irq, pending_irq, irq, irq_reg: std_logic;
signal total_of_entries_out   :std_logic_vector(ADDR_WIDTH-1 downto 0);
signal dbg_fault_injection_sig: t_fault_injection_module;
signal dbg_config_done_sig    : std_logic;
signal dbg_fsm_state_sig      : std_logic_vector(3 downto 0);
signal dbg_counter_sig        : std_logic_vector(95 downto 0);
signal global_counter_reg     : std_logic_vector(31 downto 0);
signal rstn_all, user_rst     : std_logic;

signal din     : std_logic_vector(31 downto 0);

	begin

		--apb_addr <= to_integer(unsigned(apbi.paddr(MEM_ADDR_WIDTH+1 downto 2))) when (apbi.psel(pindex) and apbi.penable) = '1' else 0; 
        apb_addr <= to_integer(unsigned(IF_COMP_data(pindex).haddr(MEM_ADDR_WIDTH+1 downto 2))) when (IF_COMP_data(pindex).hsel and '1') = '1' else 0; 
		
        comb : process(rstn_all, r, IF_COMP_data, mem_dout)     --comb : process(rstn_all, r, apbi, mem_dout)
		variable readdata      : std_logic_vector(DATA_WIDTH-1 downto 0);
		variable v             : registers;
		begin

		v        := r;
		v.en     := IF_COMP_data(pindex).hsel; -- and apbi.penable);
		v.wen    := (IF_COMP_data(pindex).hsel and '1' and IF_COMP_data(pindex).hwrite);   --(apbi.psel(pindex) and apbi.penable and apbi.pwrite);
		v.ren    := (IF_COMP_data(pindex).hsel and '1');       --(apbi.psel(pindex) and apbi.penable);
		v.addr   := IF_COMP_data(pindex).haddr(MEM_ADDR_WIDTH+1 downto 2);      --apbi.paddr(MEM_ADDR_WIDTH+1 downto 2);
		v.addr_in:= to_integer(unsigned(IF_COMP_data(pindex).haddr(MEM_ADDR_WIDTH+1 downto 2)));        --to_integer(unsigned(apbi.paddr(MEM_ADDR_WIDTH+1 downto 2)));

		if rstn_all = '0' then
			din <= (others=>'0');
		end if;
		v.data := (others=>'0');

		if(v.wen = '1') then
			case (v.addr_in) is	

				--Config registers...
				--Configuration memory
				when FAULT_INJECTION_EN_ADDR => --4
						--Set to enable fault injection
						v.data := (others=>'0');
					 	v.data := IF_COMP_data(pindex).hwdata;      --apbi.pwdata;

			        --Number of faults	
				when NUM_OF_FAULTS =>
					 v.data := IF_COMP_data(pindex).hwdata;     --apbi.pwdata;

				--Load configuration values into Memory	
				when others =>
					if(v.addr_in >= NUM_OF_STATUS_REGISTERS and v.addr_in < TOTAL_OF_ADDRESSES) then
						din <= IF_COMP_data(pindex).hwdata;     --apbi.pwdata;
					else
						din <= (others=>'0');
					end if;
			end case;

		elsif(v.ren = '1') then
			case (v.addr_in) is
				--Addr 0, status register that signals as '1' the faulty PE in a Row. Bit position n corresponds to a row number n.
				when 0 => 
					apb_dout <= (others=>'0');
					apb_dout(pe_row'length-1 downto 0) <= pe_row;
				
				--Addr 1, status register that signals as '1' the faulty PE in a column. Bit position n corresponds to a column number n.
				when 1 =>
					apb_dout <= (others=>'0');
					apb_dout(pe_column'length-1 downto 0) <= pe_column;
	
				--Addr 2, status register
				when 2 =>
			--		apb_dout <= error_diagnosis;
					apb_dout <= (others=>'0');
					apb_dout(0) <= dbg_config_done_sig;
					apb_dout(1) <= pending_irq;
					apb_dout(1) <= load_config_done;
					--IRQ value that is used to raise error interrupts
					apb_dout(7 downto 4) <= std_logic_vector(to_unsigned(pirq, 4));
					--Debug: Time stamp of the last injected fault
					apb_dout(31 downto 8) <= dbg_counter_sig(87 downto 64);

				--Addr 3, additional debug information
				when 3 =>
					apb_dout <= (others=>'0');
					--apb_dout(31 downto 16) <= pe_index(15 downto 0);
					--Debug: Shows how long the fault injection moudle was active during the TCPA computation
					apb_dout(23 downto 0) <= dbg_counter_sig(31 downto 8);

				
				--Addr 4, additional debug information
				when 4 => 
					--Debug: Global counter. It increments only if TCPA_start signal is high
					apb_dout <= global_counter_reg;

				--Addr 5, status register
				when 5 => 
					apb_dout <= (others=>'0');
					--Debug: It shows how many times the programmed cycles of fault injection table matches the global counter value
					apb_dout(31 downto 24) <= dbg_counter_sig(7 downto 0);
					apb_dout(total_of_entries_out'length-1 downto 0) <= total_of_entries_out;

				-- First memory address of fault injection table
				when others =>
					if(v.addr_in < TOTAL_OF_ADDRESSES) then
						apb_dout <= mem_dout; 
					else
						apb_dout <= (others=>'0'); 
					end if;
			end case;

		end if;

		rin <= v;
		end process;
	
		FI_BUS_IF_data.hrdata <= apb_dout;       --apbo.prdata <= apb_dout; 
		dout <= mem_dout when ren = '1' else (others=>'0');

		--mem_raddr <= std_logic_vector(unsigned(apbi.paddr(MEM_ADDR_WIDTH+1 downto 2))-NUM_OF_STATUS_REGISTERS)
        mem_raddr <= std_logic_vector(unsigned(IF_COMP_data(pindex).haddr(MEM_ADDR_WIDTH+1 downto 2))-NUM_OF_STATUS_REGISTERS)         
			when (IF_COMP_data(pindex).hsel = '1' and ren = '0')        --when (apbi.psel(pindex) = '1' and ren = '0')
			else addr when ren = '1'
			else (others=>'0') when rstn_all = '0';

		mem_ren <= '0' when rstn_all = '0' 
			else '1' when (IF_COMP_data(pindex).hsel = '1')     --(apbi.psel(pindex) = '1') 
			else ren when (IF_COMP_data(pindex).hsel = '0')     --(apbi.psel(pindex) = '0') 
			else '0';

		regs : process(rstn_all, clk)
		begin
		if rstn_all = '0' then
			user_rst    <= '0';
			mem_en      <= '0';
			ready       <= '0';
			pe_row      <= (others=>'0');
			pe_column   <= (others=>'0');
			pe_index    <= (others=>'0');
			irq_reg     <= '0';
			pending_irq <= '0';
			load_config_done <= '0';
			clear_pending_irq <= '0';
			total_of_entries     <= (others=>'0');
			total_of_entries_out <= (others=>'0');

		elsif rising_edge(clk) then 

			user_rst <= '0';
			irq_reg <= '0';
			global_counter_reg <= global_counter;

			if(clear_pending_irq = '1') then
				pending_irq <= '0';
			elsif((pending_irq = '0') and (error_status.irq = '1') and load_config_done = '1' and tcpa_start = '1') then
				pending_irq <= '1';
				irq_reg <= '1';
			end if;

			dbg_fault_injection_sig <= dbg_fault_injection;
			dbg_config_done_sig     <= dbg_config_done;
			dbg_fsm_state_sig       <= dbg_fsm_state;
			dbg_counter_sig         <= dbg_counter;
			if(rin.addr_in = NUM_OF_FAULTS) then
				if(rin.wen = '1') then
					if(unsigned(rin.data) <= MEM_SIZE-1) then
						total_of_entries     <= rin.data(total_of_entries'length-1 downto 0);
						total_of_entries_out <= rin.data(total_of_entries_out'length-1 downto 0);
					else
						total_of_entries     <= std_logic_vector(to_unsigned(MEM_SIZE-1, total_of_entries'length));
						total_of_entries_out <= std_logic_vector(to_unsigned(MEM_SIZE-1, total_of_entries_out'length));
					end if;
				end if;
			end if;

			mem_en <= '1';	
			if(rin.addr_in >= NUM_OF_STATUS_REGISTERS and rin.addr_in < TOTAL_OF_ADDRESSES) then
				if(rin.wen = '1') then
					mem_wen   <= '1';
					mem_din   <= din;
					mem_waddr <= std_logic_vector(unsigned(rin.addr)-NUM_OF_STATUS_REGISTERS);
				else
					mem_wen   <= '0';
					mem_din   <= (others=>'0');
					mem_waddr <= (others=>'0');
				end if;
			end if;

			if(rin.addr_in = 4) then
				if(rin.wen = '1') then
					if(unsigned(rin.data) = 1) then
						clear_pending_irq <= '0';
						pending_irq <= '0';
						load_config_done <= '1';
					elsif(unsigned(rin.data) = 2) then
						user_rst <= '1';
						pending_irq <= '0';
						clear_pending_irq <= '0';
						irq_reg <= '0';
						load_config_done <= '0';
					elsif(unsigned(rin.data) = 3)  then
						clear_pending_irq <= '1';
						pending_irq <= '0';
						irq_reg <= '0';
					--used for forcing and testing IRQ
					elsif(unsigned(rin.data) = 4)  then
						pending_irq <= '1';
						irq_reg <= '1';
					else
						pending_irq <= '0';
						irq_reg <= '0';
						load_config_done <= '0';
					end if;
				end if;
			end if;

			ready     <= load_config_done;
			pe_index  <= error_status.index;
			pe_row    <= error_status.row;
			pe_column <= error_status.column;
			--pe_rows_and_columns <= error_status.pe_rows_and_columns;
			r         <= rin;
		end if;
	end process;
	rstn_all <= '0' when ((rstn = '0') or (user_rst = '1')) else '1';
	fim_rstn <= rstn_all;

	irq <= '0' when rstn_all = '0' else  irq_reg when ((tcpa_start = '1') and (load_config_done = '1')) else '0';
	-- apbo.pirq(pirq) <= '0' when rstn_all = '0' else irq;
    FI_BUS_IF_data.hirq <= '0' when rstn_all = '0' else irq;
    FI_BUS_IF_data.hindex <= pindex;    -- apbo.pindex <= pindex;
	-- apbo.pconfig <= PCONFIG;

	mem : fim_memory 
 	generic map(
 		MEM_SIZE   => MEM_SIZE,
 		DATA_WIDTH => DATA_WIDTH,
 		ADDR_WIDTH => ADDR_WIDTH
 	)
 	port map(
 		en          => mem_en,
 		-- Write Port
 		wr_clk      => clk, 
 		we          => mem_wen,
 		wr_data     => mem_din,
 		wr_addr     => mem_waddr,
 		wr_data_out => temp,
 
 		-- Read Port
 		rd_clk     => clk, 
 		re         => mem_ren,
 		rd_addr    => mem_raddr,
 		rd_data    => mem_dout
 	);

end;


