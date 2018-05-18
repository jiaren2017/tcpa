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
-- Create Date:    14:05:00 12/10/2014
-- Design Name:    
-- Module Name:    LUT_feedback_register - Behavioral
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
-- This file was modified by Ericles Sousa on 10th Dec 2014. In this version,
-- the depth can be programmable at runtime if via software, for that the 
-- "en_programmable_fd_depth" signal has to be equal to 1. 
-- In the TCPA editor the user has to define the maximum depth for the FD Regs
-- and at runtime, it is possible to program each register individually.
-- So far, in our tests we are using the AMBA for interconnecting the TCPA 
-- to a RISC processor (LEON Core).
-- 
--------------------------------------------------------------------------------
library IEEE;
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LUT_feedback_register is
	generic(
		-- cadence translate_off				
		INSTANCE_NAME : string;
		-- cadence translate_on				
		FIFO_SIZE     : positive range MIN_FIFO_SIZE to MAX_FIFO_SIZE             := CUR_DEFAULT_FIFO_SIZE;
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH           := CUR_DEFAULT_DATA_WIDTH;
		ADDR_WIDTH    : positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH
	);

	port(
		clk                   : in  std_logic;
		rst                   : in  std_logic;
		en_programmable_depth : in  std_logic;
		programmable_depth    : in  std_logic_vector(15 downto 0);
		we                    : in  std_logic;
		d_in                  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		d_out                 : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);

end LUT_feedback_register;

architecture Behavioral of LUT_feedback_register is
	type t_ram is array (0 to FIFO_SIZE - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal ram         : t_ram                        := (others => (others => '0'));
	signal depth       : integer range 0 to FIFO_SIZE := 0;
	signal sig_en_programmable_depth : std_logic;

begin
	process(clk, rst, d_in, ram, we)    -- synchronous write and asynchronous read
	begin
		if rst = '1' then
			ram(0) <= (OTHERS => '0');

		elsif clk'event and clk = '1' then
			if (we = '1') then
				if FIFO_SIZE > 1 then
					FOR i in 0 to FIFO_SIZE - 2 LOOP
						ram(i + 1) <= ram(i);
					END LOOP;
				end if;
				ram(0) <= d_in;
			end if;
		end if;

		--Multiplexer for ouput data
		case (sig_en_programmable_depth) is
			when '1' =>
				d_out <= ram(depth - 1);
			when '0' =>
				d_out <= ram(FIFO_SIZE - 1);
			when others =>
				null;
		end case;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			depth <= to_integer(unsigned(programmable_depth));
			sig_en_programmable_depth <= en_programmable_depth;
		end if;
	end process;

end Behavioral;

