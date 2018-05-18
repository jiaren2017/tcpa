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
-- Create Date:    11:06:00 09/13/05
-- Design Name:    
-- Module Name:    BRAM_fifo_memory - Behavioral
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
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BRAM_fifo_memory is
	generic(
		-- cadence translate_off		
		INSTANCE_NAME : string;
		-- cadence translate_on				
		FIFO_SIZE     : positive range MIN_FIFO_SIZE to MAX_FIFO_SIZE             := CUR_DEFAULT_FIFO_SIZE;
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH           := CUR_DEFAULT_DATA_WIDTH;
		ADDR_WIDTH    : positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH
	);

	port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		we         : in  std_logic;
		write_addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		read_addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		d_in       : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		d_out      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);

end BRAM_fifo_memory;

architecture Behavioral of BRAM_fifo_memory is
	type t_ram is array (0 to FIFO_SIZE - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	signal ram : t_ram := (others => (others => '0'));

	signal int_write_addr : integer range 0 to FIFO_SIZE - 1;

begin
	process(clk, d_in, write_addr, we, int_write_addr, ram, read_addr) -- synchronous write and asynchronous read


	begin
		int_write_addr <= conv_integer(write_addr);

		if clk'event and clk = '1' then
			if we = '1' then            -- write enable

				ram(int_write_addr) <= d_in;

			end if;

			-- DUAL PORT !!! BLOCK !!! RAM is used
			-- with only SYNCHRONOUS READ possible

			d_out <= ram(conv_integer(read_addr));

		end if;                         -- clk

	end process;

end Behavioral;
