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
-- Create Date:    18:12:09 10/15/2014 
-- Design Name: 
-- Module Name:    AhbOpbWrapper - Behavioral 
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

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.all;
use wppa_instance_v1_01_a.DEFAULT_LIB.all;
use wppa_instance_v1_01_a.ARRAY_LIB.all;
use wppa_instance_v1_01_a.TYPE_LIB.all;
use wppa_instance_v1_01_a.INVASIC_LIB.all;

entity GC_AG_glue is
	generic(
		CHANNEL_COUNT_NORTH      : integer := 4;
		CHANNEL_COUNT_SOUTH      : integer := 4;
		CHANNEL_COUNT_EAST       : integer := 4;
		CHANNEL_COUNT_WEST       : integer := 4;
		NUM_OF_BUFFER_STRUCTURES : integer := 4;
		START_DELAY              : integer := 16
	);
	port(
		rst                     : in  std_logic;
		clk                     : in  std_logic;
		ag_config_done_north    : in  std_logic;
		ag_config_done_south    : in  std_logic;
		ag_config_done_east     : in  std_logic;
		ag_config_done_west     : in  std_logic;

		AG_irq_NORTH            : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
		AG_irq_WEST             : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
		AG_irq_SOUTH            : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
		AG_irq_EAST             : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);

		north_buffers_event     : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
		east_buffers_event      : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0); 
		south_buffers_event     : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
		west_buffers_event      : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES - 1 downto 0);
	
		error_status            : in t_error_status;
		gc_config_done          : in  std_logic;
		gc_irq                  : in  std_logic;
		gc_ready          	: in  std_logic;
		tcpa_config_done        : in  std_logic;

		tcpa_config_done_computed : out std_logic;

		syn_rst		        : out std_logic;

		tcpa_cmd_start          : out std_logic;
		tcpa_cmd_stop           : out std_logic;

		gc_cmd_start            : out std_logic;
		gc_cmd_stop             : out std_logic;

		ag_cmd_start            : out std_logic;
		ag_cmd_stop             : out std_logic
	);
end GC_AG_glue;

architecture Behavioral of GC_AG_glue is
	signal tcpa_config_done_i  : std_logic := '0';
	signal tmp_gc, stop        : std_logic := '0';
	signal shift_ag            : std_logic_vector(START_DELAY - 1 downto 0);
	signal shift_gc            : std_logic_vector(START_DELAY - 1 downto 0);
	signal shift_tcpa          : std_logic_vector(START_DELAY - 1 downto 0);
	signal start_computation_i : std_logic := '0';
	signal shift_start           : std_logic_vector(START_DELAY - 1 downto 0);

	attribute syn_preserve : boolean;
	attribute syn_preserve of shift_ag : signal is true;
	attribute syn_preserve of shift_gc : signal is true;
	attribute syn_preserve of shift_tcpa : signal is true;
	attribute syn_preserve of shift_start : signal is true;

begin
	PROC_TCPA_CONFIG_DONE : process(clk, rst, tcpa_config_done) is
	begin
		if rst = '1' then
			tcpa_config_done_i <= '0';

		elsif rising_edge(clk) then
			tcpa_config_done_i <= tcpa_config_done;
		end if;
	end process PROC_TCPA_CONFIG_DONE;

	tcpa_config_done_computed <= tcpa_config_done_i;

	--------------------------------------------------------------------------------------
	tmp_gc <= gc_ready and gc_config_done;

	SHIFT_REG_PROC_proc : process(clk, rst)
	begin
		if (rst = '1') then
			shift_ag   <= (others => '0');
			shift_gc   <= (others => '0');
			shift_tcpa <= (others => '0');
			shift_start<= (others => '0');
			
		elsif (clk'event and clk = '1') then
			shift_ag   <= shift_ag(START_DELAY - 2 downto 0) & (ag_config_done_north and ag_config_done_east and ag_config_done_south and ag_config_done_west);
			shift_gc   <= shift_gc(START_DELAY - 2 downto 0) & tmp_gc;
			shift_tcpa <= shift_tcpa(START_DELAY - 2 downto 0) & tcpa_config_done_i;
			shift_start<= shift_start(START_DELAY - 2 downto 0) & start_computation_i;
		end if;
	end process;

--	start_computation_i <= '0' when rst = '1' else ((not rst) and shift_ag(START_DELAY - 1) and shift_gc(START_DELAY - 1) and shift_tcpa(START_DELAY - 1)) when rst = '0';

	Start_out : process(clk, rst) is
	begin
		if rst = '1' then
			gc_cmd_start        <= '0';
			ag_cmd_start        <= '0';
			tcpa_cmd_start      <= '0';
			syn_rst	            <= '0';
			start_computation_i <= '0';
			stop                <= '0';
		elsif rising_edge(clk) then
			start_computation_i <= ((not rst) and shift_ag(START_DELAY - 1) and shift_gc(START_DELAY - 1) and shift_tcpa(START_DELAY - 1));
			gc_cmd_start   <= shift_start(10);
			if (stop = '0') then
				ag_cmd_start   <= shift_start(9);
			else
				ag_cmd_start   <= '0';
			end if;
			syn_rst	       <= shift_start(3);--start_computation_i;
			tcpa_cmd_start <= shift_start(4);

			if shift_start(9) = '1' then
				if ((not ((AG_irq_NORTH = (NUM_OF_BUFFER_STRUCTURES - 1 downto 0 => '0')) and 
					(AG_irq_SOUTH = (NUM_OF_BUFFER_STRUCTURES - 1 downto 0 => '0')) and 
					(AG_irq_WEST = (NUM_OF_BUFFER_STRUCTURES - 1 downto 0 => '0')) and 
					(AG_irq_EAST = (NUM_OF_BUFFER_STRUCTURES - 1 downto 0 => '0')))) 
					or
					(not ((north_buffers_event = (NUM_OF_BUFFER_STRUCTURES - 1 downto 0 => '0')) and
                                        (west_buffers_event = (NUM_OF_BUFFER_STRUCTURES - 1 downto 0 => '0')) and
                                        (south_buffers_event = (NUM_OF_BUFFER_STRUCTURES - 1 downto 0 => '0')) and
                                        (east_buffers_event = (NUM_OF_BUFFER_STRUCTURES - 1 downto 0 => '0'))))
					or
					(gc_irq = '1') 
					or
					(error_status.irq = '1')
					) then
					stop <= '1';
					ag_cmd_start   <= '0';
				end if;
			else --it becames zero only when the GC stops a computation
				stop <= '0';
			end if;

		end if;
	end process Start_out;

	name : process(rst, clk)
	begin
		if rst = '1' then
			gc_cmd_stop   <= '0';
			ag_cmd_stop   <= '0';
			tcpa_cmd_stop <= '0';

		elsif (clk'event and clk = '1') then
--			if start_computation_i = '1' then
--				if (not ((AG_irq_NORTH = (CHANNEL_COUNT_NORTH downto 0 => '0')) and (AG_irq_SOUTH = (CHANNEL_COUNT_SOUTH downto 0 => '0')) and (AG_irq_WEST = (CHANNEL_COUNT_WEST downto 0 => '0')) and (AG_irq_EAST = (CHANNEL_COUNT_EAST downto 0 => '0'
--							)))) then
			if (stop = '0') then
					gc_cmd_stop   <= '0';
					ag_cmd_stop   <= '0';
					tcpa_cmd_stop <= '0';
			else
				gc_cmd_stop   <= '1';   --when ((not(buffer_interrupts = (CHANNEL_COUNT downto 0 => '0'))) and start_computation_i = '1') else '1';
				ag_cmd_stop   <= '1';   --when ((not(buffer_interrupts = (CHANNEL_COUNT downto 0 => '0'))) and start_computation_i = '1') else '1';
				tcpa_cmd_stop <= '1';
				
			end if;
		end if;
	end process name;

end Behavioral;
