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
-- Company: FAU
-- Engineer: Ericles Sousa
--
-- Create Date:    
-- Design Name:    
-- Module Name:    reconfig_registers - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
-- This module provides an Hw/Sw interface to configure a set of registers, it means, the depth of IC signals and feedback registers.
-- So far, up to 1024 registers are can be configured. However, it can be extended by adjusting the address range of this module on the AMBA.
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;

library gaisler;
use gaisler.misc.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;
use wppa_instance_v1_01_a.WPPE_LIB.all;
use wppa_instance_v1_01_a.DEFAULT_LIB.all;
use wppa_instance_v1_01_a.ARRAY_LIB.all;
use wppa_instance_v1_01_a.TYPE_LIB.all;
use wppa_instance_v1_01_a.INVASIC_LIB.all;

use work.data_type_pkg.all;     -- for input and output format

entity reconfig_registers is
	generic(
		pindex : integer := 11;
		-- paddr  : integer := 16#100#;
		-- pmask  : integer := 16#ff8#
        SUM_COMPONENT   : integer
        );
	port(
		rst                      : in  std_ulogic;
		gc_reset                 : in  std_ulogic;
		clk                      : in  std_ulogic;
		ctrl_programmable_depth  : out t_ctrl_programmable_depth;
		en_programmable_fd_depth : out t_en_programmable_fd_depth;
		programmable_fd_depth    : out t_programmable_fd_depth;
                gc_current_i             : in std_logic_vector(31 downto 0);
                gc_current_j             : in std_logic_vector(31 downto 0);
                gc_current_k             : in std_logic_vector(31 downto 0);
		ic 		         : in std_logic;
		AG_out_addr_i_NORTH      : in std_logic_vector(31 downto 0);
		AG_out_addr_i_WEST       : in std_logic_vector(31 downto 0);
		AG_out_addr_i_SOUTH      : in std_logic_vector(31 downto 0);
		AG_out_addr_i_EAST       : in std_logic_vector(31 downto 0);
		AG_config_done_NORTH     : in std_logic;
		AG_config_done_WEST      : in std_logic;
		AG_config_done_SOUTH     : in std_logic;
		AG_config_done_EAST      : in std_logic;
		tcpa_config_done         : in std_logic;
		gc_config_done           : in std_logic;
		tcpa_pc_debug_in         : in t_pc_debug_outs;
		tcpa_clk_en              : in std_logic;
		tcpa_start               : in std_logic;
		tcpa_stop                : in std_logic;
		fault_injection          : in t_fault_injection_module;
		-- apbi                     : in  apb_slv_in_type;
		-- apbo                     : out apb_slv_out_type
        IF_COMP_data             : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
        RR_IF_data               : out rec_COMP_IF
        );
end;

architecture rtl of reconfig_registers is

	--NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS = CUR_DEFAULT_NUM_CONTROL_INPUTS-1, because one IC is used forsignaling errors
	constant NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS : integer := CUR_DEFAULT_NUM_CONTROL_INPUTS -1;
	constant NUM_OF_IC_REGISTERS    : integer := (CUR_DEFAULT_NUM_WPPE_VERTICAL * CUR_DEFAULT_NUM_WPPE_HORIZONTAL * NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS); --32
	constant NUM_OF_EN_FD_REGISTERS : integer := (CUR_DEFAULT_NUM_WPPE_VERTICAL * CUR_DEFAULT_NUM_WPPE_HORIZONTAL * (CUR_DEFAULT_NUM_FB_FIFO + 1)); --48
	constant NUM_OF_FD_REGISTERS    : integer := (CUR_DEFAULT_NUM_WPPE_VERTICAL * CUR_DEFAULT_NUM_WPPE_HORIZONTAL * (CUR_DEFAULT_NUM_FB_FIFO + 1)); --48
	constant NUM_OF_REGISTERS       : integer := NUM_OF_IC_REGISTERS + NUM_OF_EN_FD_REGISTERS + NUM_OF_FD_REGISTERS;

	constant REVISION : integer         := 0;
	-- constant PCONFIG  : apb_config_type := (0 => ahb_device_reg(VENDOR_CONTRIB,
			                                -- CONTRIB_CORE2,
			                                -- 0,
			                                -- REVISION,
			                                -- 0),
		                                    -- 1 => apb_iobar(paddr,
			                                -- pmask));
	type registers is array (0 to NUM_OF_REGISTERS - 1) of std_logic_vector(31 downto 0);

	signal r_ic_register, ic_register       : registers;
	signal r_en_fd_register, en_fd_register : registers;
	signal r_fd_register, fd_register       : registers;
	signal ic_counter, global_counter       : std_logic_vector(31 downto 0);
	signal reset_global_counter             : std_logic;

        signal sig_gc_current_i                 : std_logic_vector(31 downto 0);
        signal sig_gc_current_j                 : std_logic_vector(31 downto 0);
        signal sig_gc_current_k                 : std_logic_vector(31 downto 0);
	signal apb_addr                         : integer := 0;
--	signal debug_addr                       : integer;
begin
	-- apb_addr         <= to_integer(unsigned(apbi.paddr(9 downto 2))) when (apbi.psel(pindex) and apbi.penable) = '1' else 0;
    apb_addr         <= to_integer(unsigned(IF_COMP_data(pindex).haddr(9 downto 2))) when (IF_COMP_data(pindex).hsel and '1') = '1' else 0;
    
--	comb : process(rst, r_ic_register, r_en_fd_register, r_fd_register, apbi.psel(pindex), apbi.penable, sig_gc_current_i, sig_gc_current_j, sig_gc_current_k, AG_out_addr_i_NORTH, AG_out_addr_i_WEST, AG_out_addr_i_SOUTH, AG_out_addr_i_EAST, apb_addr)
	--comb : process(rst, clk)
    comb : process(rst, r_ic_register, r_en_fd_register, r_fd_register, IF_COMP_data,  sig_gc_current_i, sig_gc_current_j, sig_gc_current_k, AG_out_addr_i_NORTH, AG_out_addr_i_WEST, AG_out_addr_i_SOUTH, AG_out_addr_i_EAST, apb_addr)
	
		variable readdata         : std_logic_vector(31 downto 0);
		variable v_ic_register    : registers;
		variable v_en_fd_register : registers;
		variable v_fd_register    : registers;
--		variable apb_addr         : integer;
		variable var_reset_global_counter : std_logic;
	begin
		v_ic_register    := r_ic_register;
		v_en_fd_register := r_en_fd_register;
		v_fd_register    := r_fd_register;

		-- read register
		readdata := (others => '0');
        --if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
        if (IF_COMP_data(pindex).hsel and '1' and (not IF_COMP_data(pindex).pwrite)) = '1' then  
        
--			case to_integer(unsigned(apbi.paddr(9 downto 2))) is
			case apb_addr is
				when 0 to NUM_OF_IC_REGISTERS - 1 =>
					readdata := r_ic_register(apb_addr);
				--debug_addr <= (to_integer(unsigned(apbi.paddr(13 downto 2))));
	
				when NUM_OF_IC_REGISTERS to (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS) - 1 =>
					readdata := r_fd_register(apb_addr - NUM_OF_IC_REGISTERS);
				--debug_addr <= (to_integer(unsigned(apbi.paddr(13 downto 2))) - NUM_OF_IC_REGISTERS);
	
				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS) to (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS) - 1 =>
					readdata := r_en_fd_register(apb_addr - (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS));
				--debug_addr <= (to_integer(unsigned(apbi.paddr(13 downto 2))) - (NUM_OF_IC_REGISTERS + NUM_OF_EN_FD_REGISTERS));
				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS) => 
					readdata := ic_counter;
	
				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+1 => 
					readdata := std_logic_vector(to_unsigned(pindex, 32));

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+2 => 
					readdata := IF_COMP_data(pindex).haddr(31 downto 0);    --apbi.paddr(31 downto 0);

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+3 => 
					readdata := sig_gc_current_i;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+4 => 
					readdata := sig_gc_current_j;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+5 => 
					readdata := sig_gc_current_k;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+6 => 
					readdata := AG_out_addr_i_NORTH;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+7 => 
					readdata := AG_out_addr_i_WEST;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+8 => 
					readdata := AG_out_addr_i_SOUTH;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+9 => 
					readdata := AG_out_addr_i_EAST;
				
				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+10 => 
					readdata(5 downto 0) := tcpa_pc_debug_in(1,1)(5 downto 0);
					readdata(8)  := tcpa_clk_en;
					readdata(9)  := tcpa_start;
					readdata(10) := tcpa_stop;
					readdata(16) := AG_config_done_NORTH;
					readdata(17) := AG_config_done_WEST;
					readdata(18) := AG_config_done_SOUTH;
					readdata(19) := AG_config_done_EAST;
					readdata(20) := tcpa_config_done;
					readdata(21) := gc_config_done;
					readdata(31 downto 22) := (others=>'0');
				
				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+11 => 
					readdata := global_counter;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+12 => 
					readdata := fault_injection.mask;
				
				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+13 => 
					readdata(fault_injection.fu_sel'length-1 downto 0) := fault_injection.fu_sel;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+14 => 
					readdata(5 downto 0) := tcpa_pc_debug_in(1,3)(5 downto 0);
					readdata(13 downto 8) := tcpa_pc_debug_in(2,4)(5 downto 0);
					
				when others => null;
		
			end case;
		end if;

		-- write registers
		--if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
        if (IF_COMP_data(pindex).hsel and '1' and IF_COMP_data(pindex).pwrite) = '1' then
			--case to_integer(unsigned(apbi.paddr(9 downto 2))) is
			case apb_addr is

				--Used for programing the depth of individual IC signals of PEs
				when 0 to NUM_OF_IC_REGISTERS - 1 =>
					--debug_addr <= (to_integer(unsigned(apbi.paddr(13 downto 2))));
					v_ic_register(apb_addr) := IF_COMP_data(pindex).hwdata;     --apbi.pwdata;

				when NUM_OF_IC_REGISTERS to (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS) - 1 =>
					--debug_addr <= (to_integer(unsigned(apbi.paddr(13 downto 2)))) - NUM_OF_IC_REGISTERS;
					v_fd_register(apb_addr - NUM_OF_IC_REGISTERS) := IF_COMP_data(pindex).hwdata;       --apbi.pwdata;

				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS) to (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS) - 1 =>
					--debug_addr <= (to_integer(unsigned(apbi.paddr(13 downto 2)))) - (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS);
					v_en_fd_register(apb_addr - (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS)) := IF_COMP_data(pindex).hwdata;        --apbi.pwdata;
				
				when (NUM_OF_IC_REGISTERS + NUM_OF_FD_REGISTERS + NUM_OF_EN_FD_REGISTERS)+11 => 
					var_reset_global_counter := IF_COMP_data(pindex).hwdata(0);    --apbi.pwdata(0);
				when others => null;

			end case;
		end if;

		-- system reset
		if rst = '0' then
			for i in 0 to NUM_OF_REGISTERS - 1 loop
				v_ic_register(i)    := (others => '0');
				v_en_fd_register(i) := (others => '0');
				v_fd_register(i)    := (others => '0');
			end loop;
			var_reset_global_counter := '0';
		end if;
		ic_register    <= v_ic_register;
		en_fd_register <= v_en_fd_register;
		fd_register    <= v_fd_register;
		reset_global_counter <= var_reset_global_counter;

		--apbo.prdata <= readdata;        -- drive apb read bus
        RR_IF_data.hrdata   <= readdata; 

	end process;

	-- apbo.pirq(pindex) <= '0';           -- No IRQ
	-- apbo.pindex       <= pindex;        -- VHDL generic
	-- apbo.pconfig      <= PCONFIG;       -- Config constant
    RR_IF_data.hindex   <= pindex;
    RR_IF_data.pirg     <= '0';
    RR_IF_data.hready   <= '1';                     -- inform bus:  write OK!       
    RR_IF_data.hresp    <= (others => '0');  
    RR_IF_data.hsplit   <= (others => '0');  
    
    
	-- registers
	regs : process(rst, clk)
	begin
		if rst = '0' then
			for i in 1 to CUR_DEFAULT_NUM_WPPE_VERTICAL loop
				for j in 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL loop
					for k in 0 to NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS - 1 loop
						ctrl_programmable_depth(i, j)(k)  <= 0;
						en_programmable_fd_depth(i, j)(k) <= '0';
						programmable_fd_depth(i, j)(k)    <= (others => '0');
					end loop;
				end loop;
			end loop;
			ic_counter <= (others=>'0');
			global_counter <= (others=>'0');

		elsif rising_edge(clk) then
			sig_gc_current_i <= gc_current_i;
			sig_gc_current_j <= gc_current_j;
			sig_gc_current_k <= gc_current_k;

			if ic = '1' then
				ic_counter <= std_logic_vector(unsigned(ic_counter)+1);
			elsif gc_reset = '1' then
				ic_counter <= (others=>'0');
			end if;

			if reset_global_counter = '1' then
				global_counter <= (others=>'0');
			else
				global_counter <= std_logic_vector(unsigned(global_counter)+1);
			end if;

			r_ic_register    <= ic_register;
			r_en_fd_register <= en_fd_register;
			r_fd_register    <= fd_register;

			--Mapping the 32 IC signals
			for i in 1 to CUR_DEFAULT_NUM_WPPE_VERTICAL loop
				for j in 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL loop
					for k in 0 to NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS - 1 loop
						--ctrl_programmable_depth(i,j)(k) <= to_integer(unsigned(ic_register(k+(NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS*(j-1))+(NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS*CUR_DEFAULT_NUM_WPPE_HORIZONTAL*(i-1)))(7 downto 0)));
						ctrl_programmable_depth(i, j)(k) <= to_integer(unsigned(r_ic_register(k + (NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS * (j - 1)) + (NEW_CUR_DEFAULT_NUM_CONTROL_INPUTS * CUR_DEFAULT_NUM_WPPE_HORIZONTAL * (i - 1)))));
					end loop;
				end loop;
			end loop;

			---Mapping the 48 FD registers and their 48 EN signals. If EN is '0', the FD registers will follow the configuration defined on TCPA editor.
			FOR i in 1 to CUR_DEFAULT_NUM_WPPE_VERTICAL loop
				FOR j in 1 to CUR_DEFAULT_NUM_WPPE_HORIZONTAL loop
					for k in 0 to CUR_DEFAULT_NUM_FB_FIFO loop
						if (r_fd_register(k + ((CUR_DEFAULT_NUM_FB_FIFO + 1) * (j - 1)) + ((CUR_DEFAULT_NUM_FB_FIFO + 1) * CUR_DEFAULT_NUM_WPPE_HORIZONTAL * (i - 1)))(15 downto 0) = x"0000") then
							en_programmable_fd_depth(i, j)(k) <= '0';
							programmable_fd_depth(i, j)(k)    <= (others => '0');
						else
							en_programmable_fd_depth(i, j)(k) <= r_en_fd_register(k + ((CUR_DEFAULT_NUM_FB_FIFO + 1) * (j - 1)) + ((CUR_DEFAULT_NUM_FB_FIFO + 1) * CUR_DEFAULT_NUM_WPPE_HORIZONTAL * (i - 1)))(0);
							programmable_fd_depth(i, j)(k)    <= r_fd_register(k + ((CUR_DEFAULT_NUM_FB_FIFO + 1) * (j - 1)) + ((CUR_DEFAULT_NUM_FB_FIFO + 1) * CUR_DEFAULT_NUM_WPPE_HORIZONTAL * (i - 1)))(15 downto 0);
						end if;
					end loop;
				end loop;
			end loop;
		end if;

	end process;

end;


