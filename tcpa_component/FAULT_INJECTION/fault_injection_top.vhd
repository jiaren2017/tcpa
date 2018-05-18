---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  fault_injection_top 
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

library gaisler; 
use gaisler.misc.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.WPPE_LIB.all;
use wppa_instance_v1_01_a.DEFAULT_LIB.all;
use wppa_instance_v1_01_a.ARRAY_LIB.all;
use wppa_instance_v1_01_a.TYPE_LIB.all;
use wppa_instance_v1_01_a.INVASIC_LIB.all;
use work.data_type_pkg.all;     -- for input and output format between amba_interface and tcpa components


entity fault_injection_top is
	generic (
		MEM_SIZE          : integer := 256;
		DATA_WIDTH        : integer := 32;
		ADDR_WIDTH        : integer := 8;
		NUM_OF_IC_SIGNALS : integer := 1;
		pindex            : integer := 0;
		pirq              : integer := 0;
	                -- paddr             : integer := 15;
	                -- pmask             : integer := 16#fff#
        SUM_COMPONENT   : integer
        );
	port (
		rstn 	        : in std_ulogic;
		clk 	        : in std_ulogic;
		tcpa_start      : in std_logic;
		tcpa_stop       : in std_logic;
		fault_injection : out t_fault_injection_module; 
		error_status    : in t_error_status;
	                -- apbi            : in apb_slv_in_type;
	                -- apbo            : out apb_slv_out_type
        IF_COMP_data             : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
        FI_IF_data               : out rec_COMP_IF
        );
end;

architecture rtl of fault_injection_top is

component fault_injection_module is
	generic (
		FAULT_TABLE_SIZE : integer := 256;
		DATA_WIDTH       : integer := 32;
		ADDR_WIDTH       : integer := 8
	);
	port(
		rstn 	           : in std_ulogic;
		clk 	           : in std_ulogic;
		tcpa_start         : in std_logic;
		tcpa_stop          : in std_logic;
		en                 : in std_logic;
		addr               : out std_logic_vector(ADDR_WIDTH-1 downto 0);
		ren                : out std_logic;
		dbg_config_done    : out std_logic;
		dbg_fsm_state      : out std_logic_vector(3 downto 0);
		din                : in std_logic_vector(DATA_WIDTH-1 downto 0);
	 	global_cnt         : out std_logic_vector(31 downto 0);
	 	dbg_counter        : out std_logic_vector(95 downto 0);
		total_of_entries   : in std_logic_vector(ADDR_WIDTH-1 downto 0);
		fault_injection    : out t_fault_injection_module 
	);
end component;


component fault_injection_bus_interface is
	generic (
		MEM_SIZE          : integer := 256;
		DATA_WIDTH        : integer := 32;
		ADDR_WIDTH        : integer := 8;
		NUM_OF_IC_SIGNALS : integer := 1;
		pindex            : integer := 0;
		pirq              : integer := 0;
		-- paddr             : integer := 0;
		-- pmask             : integer := 16#fff#
        SUM_COMPONENT     : integer
        );
	port (
		rstn	           : in std_ulogic;
		clk 	           : in std_ulogic;
		tcpa_start         : in std_logic;
		tcpa_stop          : in std_logic;
		ready              : out std_logic;		
		fim_rstn           : out std_logic; -- FIM		
		ren                : in std_ulogic;
		addr               : in std_logic_vector(ADDR_WIDTH-1 downto 0);
		dout               : out std_logic_vector(31 downto 0);
		total_of_entries   : out std_logic_vector(ADDR_WIDTH-1 downto 0);
		error_status       : in t_error_status;
	 	global_counter     : in std_logic_vector(31 downto 0);
	 	dbg_counter        : in std_logic_vector(95 downto 0);
		dbg_fault_injection: in t_fault_injection_module;
		dbg_config_done    : in std_logic;
		dbg_fsm_state      : in std_logic_vector(3 downto 0);
	                -- apbi            : in apb_slv_in_type;
	                -- apbo            : out apb_slv_out_type
        IF_COMP_data        : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
        FI_BUS_IF_data      : out rec_COMP_IF
        );
end component;


signal ready_i                : std_logic;
signal fault_injection_en_i   : std_logic;		
signal total_of_entries_i     : std_logic_vector(ADDR_WIDTH - 1 downto 0);		
signal addr_i                 : std_logic_vector(ADDR_WIDTH - 1 downto 0);		
signal din_i                  : std_logic_vector(DATA_WIDTH - 1 downto 0);		
signal ren_i                  : std_logic;		
signal fault_injection_rstn_i : std_logic;		
signal fault_injection_i      : t_fault_injection_module;
signal config_done_i          : std_logic;
signal fim_rstn_i             : std_logic;
signal dbg_fsm_state_i        : std_logic_vector(3 downto 0);
signal global_counter_i       : std_logic_vector(31 downto 0);
signal dbg_counter_i          : std_logic_vector(95 downto 0);

begin
	bus_interface : fault_injection_bus_interface 
	generic map(MEM_SIZE         => MEM_SIZE,
		DATA_WIDTH           => DATA_WIDTH,
		ADDR_WIDTH           => ADDR_WIDTH,
		NUM_OF_IC_SIGNALS    => NUM_OF_IC_SIGNALS,
		pindex               => pindex, 
		pirq                 => pirq, 
		-- paddr                => paddr, 
		-- pmask                => pmask
        SUM_COMPONENT        => SUM_COMPONENT
        )
	port map(rstn               => rstn,
		clk                 => clk,
		tcpa_start          => tcpa_start,
		tcpa_stop           => tcpa_stop,
		fim_rstn            => fim_rstn_i,		
		ready               => ready_i,
		ren                 => ren_i,
		addr                => addr_i,
		dout                => din_i,
		total_of_entries    => total_of_entries_i,
		error_status        => error_status,
		global_counter      => global_counter_i,
		dbg_counter         => dbg_counter_i,
		dbg_fault_injection => fault_injection_i,
		dbg_config_done     => config_done_i,
		dbg_fsm_state       => dbg_fsm_state_i,
		-- apbi                => apbi,
		-- apbo                => apbo
        IF_COMP_data        => IF_COMP_data,
        FI_BUS_IF_data      => FI_IF_data
        );

	sync_rstn : process(rstn, fim_rstn_i, clk)
	begin
		if((rstn = '0') or (fim_rstn_i = '0')) then
			fault_injection_rstn_i <= '0'; 
		elsif(clk'event and clk = '1') then
			fault_injection_rstn_i <= '1';
		end if;
	end process;

	--fault_injection_rstn_i <= ready_i and rstn;
	fault_injection_en_i   <= ready_i;
	fault_injection        <= fault_injection_i;

	fault_injector : fault_injection_module
	generic map(
		FAULT_TABLE_SIZE => MEM_SIZE, 
		DATA_WIDTH       => DATA_WIDTH,
		ADDR_WIDTH       => ADDR_WIDTH
	)
	port map(
		rstn 	           => fault_injection_rstn_i, 
		clk 	           => clk,
		tcpa_start         => tcpa_start,
		tcpa_stop          => tcpa_stop,
		en                 => fault_injection_en_i,
		dbg_config_done    => config_done_i,
		addr               => addr_i,
		ren                => ren_i,
		dbg_fsm_state      => dbg_fsm_state_i,
		din                => din_i,
		global_cnt         => global_counter_i,
		dbg_counter        => dbg_counter_i,
		total_of_entries   => total_of_entries_i,
		fault_injection    => fault_injection_i 
	);
end;


