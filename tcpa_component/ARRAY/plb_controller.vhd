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
-- Create Date:    11:40:54 05/11/2010 
-- Design Name: 
-- Module Name:    plb_controller - Behavioral 
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
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;

use wppa_instance_v1_01_a.ALL;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;

entity plb_controller is
	generic(
		INSTANCE_NAME     : string                                  := "?";
		HEADER_WIDTH      : integer                                 := 5 * CUR_DEFAULT_SOURCE_ADDR_WIDTH + 1 + CUR_DEFAULT_ICN_RATIO_WIDTH + CUR_DEFAULT_VLIW_RATIO_WIDTH + CUR_DEFAULT_NUM_WPPE_VERTICAL + CUR_DEFAULT_NUM_WPPE_HORIZONTAL + CUR_DEFAULT_COUNT_DOWN_WIDTH + CUR_DEFAULT_DOMAIN_TYPE_WIDTH;
		--###########################################################################
		-- Bus protocol parameters, do not add to or delete
		--###########################################################################
		C_AWIDTH          : integer                                 := 32;
		C_DWIDTH          : integer                                 := 32;
		C_NUM_CE          : integer                                 := 16;
		--###########################################################################

		------------------------------------------
		SOURCE_MEM_SIZE   : positive range 2 to MAX_SOURCE_MEM_SIZE := CUR_DEFAULT_SOURCE_MEM_SIZE;
		------------------------------------------
		SOURCE_ADDR_WIDTH : positive range 1 to MAX_ADDR_WIDTH      := CUR_DEFAULT_SOURCE_ADDR_WIDTH;
		------------------------------------------
		SOURCE_DATA_WIDTH : positive range 1 to 128                 := CUR_DEFAULT_SOURCE_DATA_WIDTH
	------------------------------------------

	);
	port(
		--###########################################################################
		-- OPB  BUS  INTERFACE SIGNALS
		--###########################################################################
		clk           : in  std_logic;
		rst           : in  std_logic;

		Bus2IP_Addr   : in  std_logic_vector(0 to C_AWIDTH - 1);
		Bus2IP_Data   : in  std_logic_vector(0 to C_DWIDTH - 1);
		Bus2IP_BE     : in  std_logic_vector(0 to C_DWIDTH / 8 - 1);
		Bus2IP_RdCE   : in  std_logic_vector(0 to C_NUM_CE - 1);
		Bus2IP_WrCE   : in  std_logic_vector(0 to C_NUM_CE - 1);
		--			    	IP2Bus_Data                    : out std_logic_vector(0 to C_DWIDTH-1);
		--###########################################################################

		conf_en_out   : out std_logic;
		offset_out    : out std_logic_vector(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);
		dnumber_out   : out std_logic_vector(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);
		conf_type_out : out std_logic_vector(CUR_DEFAULT_CONFIG_TYPE_WIDTH - 1 downto 0)
	);
end plb_controller;

architecture Behavioral of plb_controller is
	signal slv_reg_write_select : std_logic_vector(0 to 15);
	signal slv_reg_read_select  : std_logic_vector(0 to 15);
begin
	slv_reg_write_select <= Bus2IP_WrCE(0 to 15);
	slv_reg_read_select  <= Bus2IP_RdCE(0 to 15);
	plb_decode : process(clk, rst, slv_reg_write_select, Bus2IP_Data)
		variable data_in_tmp : std_logic_vector(31 downto 0);
	begin
		if clk'event and clk = '1' then
			conf_en_out <= '0';
			if rst = '1' then
				offset_out    <= (others => '0');
				dnumber_out   <= (others => '0');
				conf_type_out <= (others => '0');
			else
				case slv_reg_write_select is
					when "1000000000000000" => -- R E G I S T E R  0

						data_in_tmp := Bus2IP_Data;
						offset_out  <= data_in_tmp(CUR_DEFAULT_SOURCE_ADDR_WIDTH - 1 downto 0);

					when "0100000000000000" => -- R E G I S T E R  1

						data_in_tmp := Bus2IP_Data;
						dnumber_out <= data_in_tmp(CUR_DEFAULT_DOMAIN_MEMORY_ADDR_WIDTH - 1 downto 0);

					when "0010000000000000" => -- R E G I S T E R  2
						data_in_tmp   := Bus2IP_Data;
						conf_type_out <= data_in_tmp(CUR_DEFAULT_CONFIG_TYPE_WIDTH - 1 downto 0);

					when "0001000000000000" => -- R E G I S T E R  3
						conf_en_out <= '1';

					when others =>
				end case;
			end if;

		end if;

	end process plb_decode;
end Behavioral;


