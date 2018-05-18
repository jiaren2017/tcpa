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
-- Create Date:    15:580 08/01/2015
-- Design Name:    
-- Module Name:    start_manager - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- pragma translate_off
-- cadence translate_on

----library CADENCE;
----use cadence.attributes.all;
-- pragma translate_on

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;

use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

entity start_manager is
	generic(
		--Ericles:
		N             : integer := 0;
		M             : integer := 0;
		INSTANCE_NAME : string  := "/Start_manager"
	);
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		en         : in  std_logic;
		count_down : in  std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto 0);
		start      : out std_logic
	);
end start_manager;

architecture Behavioral of start_manager is
	signal counter : std_logic_vector(CUR_DEFAULT_COUNT_DOWN_WIDTH - 1 downto 0);
begin
	process(clk, rst)
	begin
		if rst = '1' then
			counter <= count_down;
			--start   <= '1';             -- start is active low

		elsif rising_edge(clk) then
			if en = '0' then
				counter <= count_down;
				--start <= '1';           -- start is active low
			--else
			--	if counter = 0 then
			--		start <= '0';       -- start is active low
			--	else
			--		counter <= std_logic_vector(unsigned(counter) - 1);
			--	end if;
			end if;
		end if;
		start <= '0';       -- start is active low, this signal will not be used anymore. Now, the Global controller will send the start time.
	end process;
end;

