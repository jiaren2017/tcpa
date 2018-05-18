----------------------------------------------------------------------------------
-- Company:        Informatik 12 - Universität erlangen-nürnberg
-- Engineer:       Jupiter BAKAKEU
-- 
-- Create Date:    12:08:45 06/30/2014 
-- Design Name:    Configurable Shifft Register (CSR)
-- Module Name:    ReconfigurableBuffer - Behavioral 
-- Project Name: 	 Masterarbeit Jupiter Bakakeu
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: Extended to 128 by Ericles Sousa
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CSR is
	generic(
		--###########################################################################
		-- CSR parameters, do not add to or delete
		--###########################################################################
		DELAY_SELECTOR_WIDTH : integer range 0 to 32 := 6;
		DATA_WIDTH           : integer range 0 to 32 := 32
	--###########################################################################		
	);
	port(
		clk         : in  std_logic;
		rst         : in  std_logic;
		selector    : in  std_logic_vector(DELAY_SELECTOR_WIDTH - 1 downto 0);
		data_input  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_output : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);

end CSR;

architecture Behavioral of CSR is

	
	type data_array_0 is array (0 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type data_array_1 is array (1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type data_array_2 is array (3 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type data_array_3 is array (7 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type data_array_4 is array (15 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type data_array_5 is array (31 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type data_array_6 is array (63 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type data_array_7 is array (127 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type data_array_8 is array (255 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	
	signal delay_0 : data_array_0 := (others => (others => '0'));
	signal delay_1 : data_array_1 := (others => (others => '0'));
	signal delay_2 : data_array_2 := (others => (others => '0'));
	signal delay_3 : data_array_3 := (others => (others => '0'));
	signal delay_4 : data_array_4 := (others => (others => '0'));
	signal delay_5 : data_array_5 := (others => (others => '0'));
	signal delay_6 : data_array_6 := (others => (others => '0'));
	signal delay_7 : data_array_7 := (others => (others => '0'));
	signal delay_8 : data_array_8 := (others => (others => '0'));
	
	signal inter_0 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	signal inter_1 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	signal inter_2 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	signal inter_3 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	signal inter_4 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	signal inter_5 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	signal inter_6 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	signal inter_7 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	signal inter_8 : std_logic_vector(DATA_WIDTH - 1 downto 0):= (others => '0');
	
	attribute syn_preserve : boolean;
	attribute syn_preserve of delay_0 : signal is true;
	attribute syn_preserve of delay_1 : signal is true;
	attribute syn_preserve of delay_2 : signal is true;
	attribute syn_preserve of delay_3 : signal is true;
	attribute syn_preserve of delay_4 : signal is true;
	attribute syn_preserve of delay_5 : signal is true;
	attribute syn_preserve of delay_6 : signal is true;
	attribute syn_preserve of delay_7 : signal is true;
	attribute syn_preserve of delay_8 : signal is true;
	
begin

	proc_0:process(clk,rst)
	begin
		if clk'event and clk = '1' then
			if selector(0) = '1' then
				delay_0(0) <= data_input;
			end if;
		end if;
	end process;
	
	inter_0 <= delay_0(0) when selector(0) = '1' else data_input;
	
	proc_1:process(clk,rst)
	begin
		if clk'event and clk = '1' then
			if selector(1) = '1' then
				delay_1(1) <= delay_1(0);
				delay_1(0) <= inter_0;
			end if;
		end if;
	end process;
	
	inter_1 <= delay_1(1) when selector(1) = '1' else inter_0;
	
	proc_2:process(clk,rst)
	begin
		if clk'event and clk = '1' then
			if selector(2) = '1' then
				for j in 0 to 2 loop
						delay_2(j + 1) <= delay_2(j);
				end loop;
				delay_2(0) <= inter_1;
			end if;
		end if;
	end process;
	
	inter_2 <= delay_2(3) when selector(2) = '1' else inter_1;
	
	proc_3:process(clk,rst)
	begin
		if clk'event and clk = '1' then
			if selector(3) = '1' then
				for j in 0 to 6 loop
						delay_3(j + 1) <= delay_3(j);
				end loop;
				delay_3(0) <= inter_2;
			end if;
		end if;
	end process;
	
	inter_3 <= delay_3(7) when selector(3) = '1' else inter_2;
	
	proc_4:process(clk,rst)
	begin
		if clk'event and clk = '1' then
			if selector(4) = '1' then
				for j in 0 to 14 loop
						delay_4(j + 1) <= delay_4(j);
				end loop;
				delay_4(0) <= inter_3;
			end if;
		end if;
	end process;	
	inter_4 <= delay_4(15) when selector(4) = '1' else inter_3;	

	proc_5:process(clk,rst)
	begin
		if clk'event and clk = '1' then
			if selector(5) = '1' then
				for j in 0 to 30 loop
					delay_5(j + 1) <= delay_5(j);
				end loop;
				delay_5(0) <= inter_4;
			end if;
		end if;
	end process;
	inter_5 <= delay_5(31) when selector(5) = '1' else inter_4;	
--	data_output <= inter_5 when rst = '0' else (others => '0');	

 	proc_6:process(clk,rst)
 	begin
 		if clk'event and clk = '1' then
 			if selector(6) = '1' then
 				for j in 0 to 62 loop
 					delay_6(j + 1) <= delay_6(j);
 				end loop;
 				delay_6(0) <= inter_5;
 			end if;
 		end if;
 	end process;
 	inter_6 <= delay_6(63) when selector(6) = '1' else inter_5;	
-- 	data_output <= inter_6 when rst = '0' else (others => '0');	

 	proc_7:process(clk,rst)
 	begin
 		if clk'event and clk = '1' then
 			if selector(7) = '1' then
 				for j in 0 to 126 loop
 					delay_7(j + 1) <= delay_7(j);
 				end loop;
 				delay_7(0) <= inter_6;
 			end if;
 		end if;
 	end process;
 	inter_7 <= delay_7(127) when selector(7) = '1' else inter_6;	
-- 	data_output <= inter_7 when rst = '0' else (others => '0');	

 	proc_8:process(clk,rst)
 	begin
 		if clk'event and clk = '1' then
 			if selector(8) = '1' then
 				for j in 0 to 254 loop
 					delay_8(j + 1) <= delay_8(j);
 				end loop;
 				delay_8(0) <= inter_7;
 			end if;
 		end if;
 	end process;
 	inter_8 <= delay_8(255) when selector(8) = '1' else inter_7;	
 	data_output <= inter_8 when rst = '0' else (others => '0');	

end Behavioral;



