---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  fim_memory 
-- Project Name:  
--
-- Engineer:    Éricles Sousa
-- Create Date: March, 2017
-- Description:  
--
--------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fim_memory is
	generic(
		--###########################################################################
		-- Memory parameters, do not add to or delete
		--###########################################################################
		MEM_SIZE : integer := 256;
		DATA_WIDTH  : integer range 1 to 32 := 32;
		ADDR_WIDTH  : integer range 1 to 16 := 8
	--###########################################################################		
	);
	port(
		-- Write Port
		wr_clk      : in  std_logic;
		en         : in  std_logic;
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
end fim_memory;

architecture Behavioral of fim_memory is
	---------------------------------- Types --------------------------------------
	type data_t is array (MEM_SIZE - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	-------------------------------------------------------------------------------

	---------------------------------- Signals ------------------------------------
	signal reg           : data_t                             :=  (others => (others => '0'));
	signal wr_data_out_i : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal rd_data_i     : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	-------------------------------------------------------------------------------

	attribute RAM_STYLE : string;
	attribute RAM_STYLE of reg : signal is "BLOCK";
	
begin
	WRITE_PROC : process(wr_clk)
	begin
		if wr_clk'event and wr_clk = '1' then
			if en = '1' then
				if we = '1' then
					reg(to_integer(unsigned(wr_addr))) <= wr_data;
					wr_data_out_i                             <= wr_data;
				else
					wr_data_out_i <= reg(to_integer(unsigned(wr_addr)));
				end if;
			end if;
		end if;
	end process WRITE_PROC;

	wr_data_out <= wr_data_out_i;

	READ_PROC : process(rd_clk)
	begin
		if rd_clk'event and rd_clk = '1' then
			if re = '1' then
				rd_data_i <= reg(to_integer(unsigned(rd_addr)));
			end if;
		end if;
	end process READ_PROC;
	rd_data <= rd_data_i;
end Behavioral;




