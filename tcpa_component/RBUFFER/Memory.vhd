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
-- Create Date:    13:45:07 08/11/2014 
-- Design Name: 
-- Module Name:    Memory - Behavioral 
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
use std.textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memory is
	generic(
		--###########################################################################
		-- Memory parameters, do not add to or delete
		--###########################################################################
		DATA_WIDTH  : integer range 0 to 64 := 18; -- 2 * DATA_WIDTH;
		CONFIG_SIZE : integer := 1024;
		ADDR_WIDTH  : integer range 0 to 32 := 10
	--###########################################################################		
	);
	port(
		-- Write Port
		config_wr_clk      : in  std_logic;
		config_en          : in  std_logic;
		config_we          : in  std_logic;
		config_wr_data     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		config_wr_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		config_wr_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);

		-- Read Port
		config_rd_clk      : in  std_logic;
		config_re          : in  std_logic;
		config_rd_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		config_rd_data     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end Memory;

architecture Behavioral of Memory is
	---------------------------------- Types --------------------------------------
	--type config_data_t is array (2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type config_data_t is array (CONFIG_SIZE - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	-------------------------------------------------------------------------------

	---------------------------------- Signals ------------------------------------
	signal config_reg           : config_data_t                             :=  (others => (others => '0'));
	signal config_wr_data_out_i : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal config_rd_data_i     : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	-------------------------------------------------------------------------------

	attribute RAM_STYLE : string;
	attribute RAM_STYLE of config_reg : signal is "BLOCK";
	
begin
	CONFIG_WR_PROC : process(config_wr_clk)
	begin
		if config_wr_clk'event and config_wr_clk = '1' then
			if config_en = '1' then
				if config_we = '1' then
					config_reg(to_integer(unsigned(config_wr_addr))) <= config_wr_data;
					config_wr_data_out_i                             <= config_wr_data;
				else
					config_wr_data_out_i <= config_reg(to_integer(unsigned(config_wr_addr)));
				end if;
			end if;
		end if;
	end process CONFIG_WR_PROC;

	config_wr_data_out <= config_wr_data_out_i;

	CONFIG_RD_PROC : process(config_rd_clk)
	begin
		if config_rd_clk'event and config_rd_clk = '1' then
			if config_re = '1' then
				config_rd_data_i <= config_reg(to_integer(unsigned(config_rd_addr)));
			end if;
		end if;
	end process CONFIG_RD_PROC;
	config_rd_data <= config_rd_data_i;
end Behavioral;

