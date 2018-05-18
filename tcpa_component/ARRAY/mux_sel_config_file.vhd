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
-- Create Date:    10:20:00 02/22/06
-- Design Name:    
-- Module Name:    mux_sel_config_file - Behavioral
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;

entity mux_sel_config_file is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME               : string                                                     := "???";
		-- cadence translate_on

		NORTH_TOTAL_SEL_WIDTH       : integer range 0 to MAX_CONFIG_REG_WIDTH                    := 2;
		EAST_TOTAL_SEL_WIDTH        : integer range 0 to MAX_CONFIG_REG_WIDTH                    := 2;
		SOUTH_TOTAL_SEL_WIDTH       : integer range 0 to MAX_CONFIG_REG_WIDTH                    := 2;
		WEST_TOTAL_SEL_WIDTH        : integer range 0 to MAX_CONFIG_REG_WIDTH                    := 2;
		WPPE_INPUTS_TOTAL_SEL_WIDTH : integer range 0 to MAX_CONFIG_REG_WIDTH                    := 2;

		--CONFIG_FILE_ADDR_WIDTH :positive range 1 to 7;
		--CONFIG_FILE_SIZE		  :positive range 2 to 128;
		CONFIG_REG_WIDTH            : integer range MIN_CONFIG_REG_WIDTH to MAX_CONFIG_REG_WIDTH := CUR_DEFAULT_CONFIG_REG_WIDTH
	);

	port(
		clk, rst                : in  std_logic;
		we                      : in  std_logic;

		new_data_input          : in  std_logic_vector(CONFIG_REG_WIDTH - 1 downto 0);
		addr_input              : in  std_logic_vector(2 downto 0);

		NORTH_OUT_mux_selects   : out std_logic_vector(NORTH_TOTAL_SEL_WIDTH downto 0);
		EAST_OUT_mux_selects    : out std_logic_vector(EAST_TOTAL_SEL_WIDTH downto 0);
		SOUTH_OUT_mux_selects   : out std_logic_vector(SOUTH_TOTAL_SEL_WIDTH downto 0);
		WEST_OUT_mux_selects    : out std_logic_vector(WEST_TOTAL_SEL_WIDTH downto 0);
		WPPE_INPUTS_mux_selects : out std_logic_vector(WPPE_INPUTS_TOTAL_SEL_WIDTH downto 0)
	);
end mux_sel_config_file;

architecture BEH of mux_sel_config_file is
	--type t_config_reg_file is array (0 to 4) of std_logic_vector(CONFIG_REG_WIDTH+3 downto 0);
        type t_config_reg_file is array (0 to 4) of std_logic_vector(MAX_CONFIG_REG_WIDTH-1 downto 0);

	--###############################################
	-- LAYOUT of the configuration registers:
	--###############################################

	-- REG #0 ==> NORTH_OUTPUTS selects
	-- REG #1 ==> EAST_OUTPUTS selects
	-- REG #2 ==> SOUTH_OUTPUTS selects
	-- REG #3 ==> WEST_OUTPUTS selects
	-- REG #4 ==> WPPE_INPUTS_selects

	--###############################################
	--###############################################


	signal config_reg_file : t_config_reg_file := (others => (others => '0'));

begin

	------------------------------------------------------------------------------
	NORTH_OUT_mux_selects               --(CONFIG_REG_WIDTH -1 downto 0) 
	<= config_reg_file(0)(NORTH_TOTAL_SEL_WIDTH downto 0); --(CONFIG_REG_WIDTH -1 downto 0);
	------------------------------------------------------------------------------
	EAST_OUT_mux_selects                --(CONFIG_REG_WIDTH -1 downto 0)  
	<= config_reg_file(1)(EAST_TOTAL_SEL_WIDTH downto 0); --(CONFIG_REG_WIDTH -1 downto 0);
	------------------------------------------------------------------------------
	SOUTH_OUT_mux_selects               --(CONFIG_REG_WIDTH -1 downto 0) 
	<= config_reg_file(2)(SOUTH_TOTAL_SEL_WIDTH downto 0); --(CONFIG_REG_WIDTH -1 downto 0);
	------------------------------------------------------------------------------
	WEST_OUT_mux_selects                --(CONFIG_REG_WIDTH -1 downto 0) 
	<= config_reg_file(3)(WEST_TOTAL_SEL_WIDTH downto 0); --(CONFIG_REG_WIDTH -1 downto 0);
	------------------------------------------------------------------------------
	WPPE_INPUTS_mux_selects             --(CONFIG_REG_WIDTH -1 downto 0) 
	<= config_reg_file(4)(WPPE_INPUTS_TOTAL_SEL_WIDTH downto 0); --(CONFIG_REG_WIDTH -1 downto 0);
	------------------------------------------------------------------------------


	process(clk, addr_input, we, new_data_input, config_reg_file)
	begin
		if clk'event and clk = '1' then
			if we = '1' AND (conv_integer(addr_input) < 5) then -- write enable

				config_reg_file(conv_integer(addr_input))(CONFIG_REG_WIDTH - 1 downto 0) <= new_data_input(CONFIG_REG_WIDTH - 1 downto 0);

			end if;
		end if;

	end process;

end BEH;
