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
-- Create Date:    12:56:13 08/09/2014 
-- Design Name: 
-- Module Name:    Enable_Logic - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Enable_Logic is
	generic(
		--###########################################################################
		-- Enable_Logic parameters, do not add to or delete
		--###########################################################################
		SEL_WIDTH                             : integer range 0 to 8  := 2;
		ADDR_WIDTH                            : integer range 0 to 32 := 4;
	        BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean := TRUE;
	        EN_ELASTIC_BUFFER                     : boolean := FALSE
	--###########################################################################		
	);
	port(
		header_addr_to_match     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		config_width_sel  : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
		config_use_second : in  std_logic;
		input_1_header_addr      : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		input_2_header_addr      : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		input_1_en        : in  std_logic;
		input_2_en        : in  std_logic;
		en_output         : out std_logic
	);
end Enable_Logic;

architecture Behavioral of Enable_Logic is
	---------------------------------- Signals ------------------------------------
	signal tmp_en_input    : std_logic := '0';
	signal tmp_addr_select : std_logic := '0';
	signal addr_to_compare : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	---------------------------------- End Signals --------------------------------

	---------------------------------- Components ---------------------------------
	component Extended_AND is
		generic(
	                SEL_WIDTH                             : integer range 0 to 8  := 3;
	                DATA_WIDTH                            : integer range 0 to 32 := 8;
	                BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := TRUE;
	                EN_ELASTIC_BUFFER                     : boolean               := FALSE
		);
		port(
			data_input_left  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			data_input_right : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			width_sel        : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			data_output      : out std_logic
		);
	end component;
---------------------------------- End Components -----------------------------
begin
	-- select between AG enable signal or channel enable signal
	tmp_en_input    <= input_2_en WHEN config_use_second = '1' ELSE input_1_en;
	addr_to_compare <= input_2_header_addr when config_use_second = '1' else input_1_header_addr;

	channel_extended_and : Extended_AND
		generic map(
			SEL_WIDTH                             => SEL_WIDTH,
			DATA_WIDTH                            => ADDR_WIDTH,
	        	BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
		        EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER
		)
		port map(
			data_input_left  => header_addr_to_match,
			data_input_right => addr_to_compare,
			width_sel        => config_width_sel,
			data_output      => tmp_addr_select
		);

	-- select between AG enable signal or channel enable signal
	en_output <= tmp_en_input AND tmp_addr_select;

end Behavioral;

