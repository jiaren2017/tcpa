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

library IEEE;
use IEEE.std_logic_1164.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

package invasic_lib is

	--	constant INV_BUS_WIDTH		: integer := 16;
	constant INV_BUS_WIDTH   : integer := 20;
	constant PROG_DATA_WIDTH : integer := 30;
	constant PROG_ADDR_WIDTH : integer := 6;

	subtype t_inv_sig is std_logic_vector(INV_BUS_WIDTH - 1 downto 0);

	subtype t_prog_data is std_logic_vector(PROG_DATA_WIDTH - 1 downto 0);
	subtype t_prog_addr is std_logic_vector(PROG_ADDR_WIDTH - 1 downto 0);

	--  type t_prog_intfc is record
	--    inv_prog_data: t_prog_data;
	--    inv_prog_addr: t_prog_addr;
	--    inv_prog_wr_en : std_logic;
	--   inv_start : std_logic;
	--  end record;

	subtype t_prog_intfc is std_logic_vector(PROG_ADDR_WIDTH + PROG_DATA_WIDTH + 1 downto 0);

end package invasic_lib;

package body invasic_lib is
end package body invasic_lib;
