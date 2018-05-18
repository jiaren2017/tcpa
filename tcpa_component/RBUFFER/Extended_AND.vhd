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
-- Engineer: Ericles Sousa 
-- 
-- Create Date:    12:02:22 08/09/2014 
-- Design Name: 
-- Module Name:    Extended_AND - Behavioral 
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

entity Extended_AND is
	generic(
		--###########################################################################
		-- Extended_AND parameters, do not add to or delete
		--###########################################################################
		SEL_WIDTH                             : integer range 0 to 8 := 3;
		DATA_WIDTH                            : integer range 0 to 32 := 8;
		BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean := TRUE;
		EN_ELASTIC_BUFFER                     : boolean := FALSE
		--###########################################################################		
	);
	port(
		data_input_left  	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		data_input_right	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		width_sel         	: in std_logic_vector(SEL_WIDTH-1 downto 0);
		data_output  		: out std_logic
	);
end Extended_AND;

architecture Behavioral of Extended_AND is
signal sig_msb_to_compare    : std_logic_vector(DATA_WIDTH-1 downto 0);
signal sig_index_left_input  : integer range 0 to DATA_WIDTH :=0;
signal sig_index_right_input : integer range 0 to DATA_WIDTH :=0;
begin
	CHANNELS_ARE_POWER_OF_TWO_OR_ELASTIC_BUFFER_IS_FALSE : if BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO  = TRUE and EN_ELASTIC_BUFFER = FALSE generate
		process (data_input_left,data_input_right,width_sel)
			variable tmp                : std_logic := '0';
			variable tmp_i              : std_logic_vector(SEL_WIDTH -1 downto 0);
			variable reconfig_width_sel : integer range 0 to DATA_WIDTH :=0;
			variable msb_to_compare     : integer range 0 to DATA_WIDTH :=0; --std_logic_vector(SEL_WIDTH -1 downto 0);
			variable index_left_input   : integer range 0 to DATA_WIDTH :=0;
			variable index_right_input  : integer range 0 to DATA_WIDTH :=0;
		begin
			tmp:= '1';
			tmp_i := std_logic_vector(to_unsigned(DATA_WIDTH-1,SEL_WIDTH));
			reconfig_width_sel := to_integer(unsigned(width_sel));
	
			--if Buffer and Channel Sizes are power of two, then we only need to evaluate the MSB of different address to enable a particular channel. i
			--If not, we have to compare the entire address to ensure that a particular channel will be correctly enable during a reading por writing operation.
			for i in 0 to DATA_WIDTH-1 loop
				sig_msb_to_compare(i) <= '0'; 
				if  (reconfig_width_sel = 0) then
					tmp := '0';
			        elsif (reconfig_width_sel > DATA_WIDTH-1) then
				        tmp := '0';
				else
					if (i < reconfig_width_sel) then
						sig_msb_to_compare(reconfig_width_sel-1-i) <= data_input_right((DATA_WIDTH-1)-i); 
						--Input left is defined at sotware level, while input right comes from ADDR Genarator or Bus
						--Here, we compare the LSBs of data_input_left with the MSBs of data_input_right
						if (data_input_left(reconfig_width_sel-1-i) = data_input_right((DATA_WIDTH-1)-i)) then
							tmp := tmp and '1';
						else 
							tmp := tmp and '0';
						end if;
					end if;
				end if;
			end loop;

	
			data_output <= tmp;
			sig_index_left_input <= index_left_input;
			sig_index_right_input <= index_right_input;
		end process;
	end generate;

        CHANNELS_ARE_NOT_POWER_OF_TWO_OR_ELASTIC_BUFFER_IS_TRUE : if BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO = FALSE or EN_ELASTIC_BUFFER = TRUE generate
		process (data_input_left,data_input_right,width_sel)
			variable tmp                : std_logic := '0';
			variable tmp_i              : std_logic_vector(SEL_WIDTH -1 downto 0);
			variable reconfig_width_sel : integer range 0 to DATA_WIDTH :=0;
			variable index_left_input   : integer range 0 to DATA_WIDTH :=0;
			variable index_right_input  : integer range 0 to DATA_WIDTH :=0;
		begin
			tmp:= '1';
			tmp_i := std_logic_vector(to_unsigned(DATA_WIDTH-1,SEL_WIDTH));
			reconfig_width_sel := to_integer(unsigned(width_sel));
	
			for i in 0 to DATA_WIDTH-1 loop
				sig_msb_to_compare(i) <= '0'; 
				if  (reconfig_width_sel = 0) then
					tmp := '0';
			        elsif (reconfig_width_sel > DATA_WIDTH-1) then
				        tmp := '0';
				else
					if (i < reconfig_width_sel) then
						sig_msb_to_compare(i) <= data_input_right(i); 
						--Input left is defined at sotware level, while input right comes from ADDR Genarator or Bus
						if (data_input_left(i) <= data_input_right(i)) then
							tmp := tmp and '1';
						else 
							tmp := tmp and '0';
						end if;
					end if;
				end if;
			end loop;

			data_output <= tmp;
			sig_index_left_input <= index_left_input;
			sig_index_right_input <= index_right_input;
		end process;
	end generate;
end Behavioral;


