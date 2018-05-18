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
-- Create Date:    15:33:07 08/18/2014 
-- Design Name: 
-- Module Name:    BRAM_Infered - Behavioral 
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
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BRAM_infered is
	generic(
		BUFFER_SIZE               : integer               := 4096;
		BUFFER_CHANNEL_SIZE       : integer               := 1024;
		BUFFER_CHANNEL_ADDR_WIDTH : integer       := 10;
		DATA_WIDTH        : integer range 0 to 32 := 32
	);
	port(
		-- Port A
		clka  : IN  STD_LOGIC;
		ena   : IN  STD_LOGIC;
		wea   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		addra : IN  STD_LOGIC_VECTOR(BUFFER_CHANNEL_ADDR_WIDTH - 1 DOWNTO 0);
		dina  : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

		-- Port B
		clkb  : IN  STD_LOGIC;
		enb   : IN  STD_LOGIC;
		web   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		addrb : IN  STD_LOGIC_VECTOR(BUFFER_CHANNEL_ADDR_WIDTH - 1 DOWNTO 0);
		dinb  : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		doutb : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
	);
end BRAM_infered;

architecture Behavioral of BRAM_Infered is
	---------------------------------- Type ---------------------------------------
	--type reg_t is array (2 ** 10 - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type reg_t is array (BUFFER_CHANNEL_SIZE - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	---------------------------------- End Type -----------------------------------

	---------------------------------- Signals ------------------------------------
	shared variable bram_reg : reg_t := (others => (others => '0'));
---------------------------------- End Signals --------------------------------

---------------------------------- Attribute ----------------------------------
--	attribute CLOCK_SIGNAL: string; 
--	attribute CLOCK_SIGNAL of clka: signal is "yes";
--	attribute CLOCK_SIGNAL of clkb: signal is "yes";
---------------------------------- End Attribute ------------------------------
begin

	-- Port A write process
	PORTA_Proc : process(clka) is
	begin
		if rising_edge(clka) then
			if ena = '1' then
				if wea = "1111" then
					bram_reg(conv_integer(addra)) := dina;
					douta                         <= dina;
				else
					douta <= bram_reg(conv_integer(addra));
				end if;
			end if;
		end if;
	end process PORTA_Proc;

	-- Port B write process
	PORTB_Proc : process(clkb) is
	begin
		if rising_edge(clkb) then
			if enb = '1' then
				if web = "1111" then
					bram_reg(conv_integer(addrb)) := dinb;
					doutb                         <= dinb;
				else
					doutb <= bram_reg(conv_integer(addrb));
				end if;
			end if;
		end if;
	end process PORTB_Proc;
end Behavioral;

