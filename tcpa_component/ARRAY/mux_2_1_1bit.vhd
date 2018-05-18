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
-- Module Name:    mux_2_1_1bit - Behavioral
--------------------------------------------------------------------------------
library IEEE;
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

entity mux_2_1_1bit is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME : string := "???"
	-- cadence translate_on		
	);
	port(
		input0 : in  std_logic;
		input1 : in  std_logic;
		sel    : in  std_logic;
		output : out std_logic
	);
end mux_2_1_1bit;

architecture Behavioral of mux_2_1_1bit is
begin
	output <= input0 when sel = '0' else input1 when sel = '1';
--   switching : process(sel, input0, input1)
--   begin
--      if sel = '0' then
--         output <= input0;    
--      else
--         output <= input1;    
--      end if;    
--   end process switching;

end Behavioral;














