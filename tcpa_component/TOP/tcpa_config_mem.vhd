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

---------------------------------------------------------------------------------------------------------------------------------
-- Copyright (C) 2013 by University of Erlangen-Nuremberg,
-- Department of Computer Science, Hardware/Software Co-Design, Germany.
-- All rights reserved.
-- This IP is intended to be used only in the Transregional Collabarative Research Centre "Invasive Computing" (SFB/TR 89)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ericles Sousa
-- 
-- Create Date:     
-- Design Name: 
-- Module Name:    tcpa_config_mem - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Simple Dual-Port Block RAM with One Clock
-- Correct Modelization with a Shared Variable
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

--For TCPA
library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;
use wppa_instance_v1_01_a.default_LIB.ALL;


entity tcpa_config_mem is
	port(
		rstn  : in  std_logic;
		clk   : in  std_logic;
		ena   : in  std_logic;
		enb   : in  std_logic;
		wea   : in  std_logic;
		addra : in  std_logic_vector(15 downto 0);
		addrb : in  std_logic_vector(15 downto 0);
		dia   : in  std_logic_vector(31 downto 0);
		dob   : out std_logic_vector(31 downto 0)
	);
end tcpa_config_mem;

architecture syn of tcpa_config_mem is
	type ram_type is array (CUR_DEFAULT_SOURCE_MEM_SIZE-1 downto 0) of std_logic_vector(31 downto 0);
	shared variable RAM : ram_type;
begin
	process(clk)
	begin
		if clk'event and clk = '1' then
			if ena = '1' then
				if wea = '1' then
					RAM(conv_integer(addra)) := dia;
				end if;
			end if;
		end if;
	end process;

	process(rstn, clk)
	begin
		if rstn = '0' then
			dob <= (others=>'0');
		
		elsif clk'event and clk = '1' then
			if enb = '1' then
				dob <= RAM(conv_integer(addrb));
			end if;
		end if;
	end process;

end syn;


