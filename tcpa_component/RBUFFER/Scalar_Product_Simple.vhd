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
-- Create Date:    09:08:24 08/14/2014 
-- Design Name: 
-- Module Name:    Scalar_Product_Simple - Behavioral 
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

entity Scalar_Product_Simple is
	generic(
		--###########################################################################
		-- Scalar_Product_Simple, do not add to or delete
		--###########################################################################
		DATA_WIDTH    : integer range 0 to 32 := 8;
		DIMENSION     : integer range 0 to 64 := 6;
		PIPELINE_DEPTH : integer range 0 to 32 := 3 -- equals log2(DIMENSION) + 1
	--###########################################################################		
	);
	port(
		clk   : in  std_logic;
		reset : in  std_logic;
		en    : in  std_logic;
		u     : in  std_logic_vector(DIMENSION * DATA_WIDTH - 1 downto 0);
		v     : in  std_logic_vector(DIMENSION * DATA_WIDTH - 1 downto 0);
		res   : out std_logic_vector(2 * DATA_WIDTH - 1 downto 0);
		valid : out std_logic
	);
end Scalar_Product_Simple;

architecture Behavioral of Scalar_Product_Simple is
	
	type t1 is array(DIMENSION -1 downto 0) of signed(DATA_WIDTH - 1 downto 0);
	subtype t2 is signed(2 * DATA_WIDTH - 1 downto 0);
	signal res_i : t2 := (others => '0');
	
	signal tmp_a : t1     := (others =>(others => '0'));
	signal tmp_b : t1     := (others =>(others => '0'));
	
	function scalarmul(a : t1; b : t1) return t2 is
		variable i:integer:= 0;
		variable prod    : t2      := (others => '0');
	begin

		for i in 0 to DIMENSION - 1 loop
			prod := prod + (a(i) * b(i));
		end loop;
		return prod;
	end scalarmul;
	
	attribute syn_preserve : boolean;
	attribute syn_preserve of stage_0_en : label is true;
	attribute syn_preserve of Stage_0 : label is true;
	
begin

	CAST_GEN : for i in 0 to DIMENSION -1 generate		
		tmp_a(i) <= signed(u((i + 1) * DATA_WIDTH - 1 downto i * DATA_WIDTH));
		tmp_b(i) <= signed(v((i + 1) * DATA_WIDTH - 1 downto i * DATA_WIDTH));
	end generate CAST_GEN;
	
	res_i <= scalarmul(tmp_a,tmp_b);
	
	Stage_0 : process(clk, reset)
	begin
		if reset = '1' then
			res <= (others => '0');
		elsif clk = '1' and clk'event then
			if (en = '1') then
				res <= std_logic_vector(res_i);
			end if;
		end if;
	end process Stage_0;
	
	stage_0_en : process (clk) is
	begin
		if rising_edge(clk) then
			valid <= en;
		end if;
	end process stage_0_en;
	
	
end Behavioral;
