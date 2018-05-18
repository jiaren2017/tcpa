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
-- Create Date:    11:05:33 09/13/05
-- Design Name:    
-- Module Name:    control_regfile - Behavioral
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
--use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_regfile is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME : string                     := "???";
		-- cadence translate_on			  
		generics      : t_control_regfile_generics := CUR_DEFAULT_CONTROL_REGFILE_GENERICS
	);

	port(
		ctrl_read_addresses_vector    : in  std_logic_vector(generics.CTRL_REGFILE_ADDR_WIDTH * generics.NUM_OF_CTRL_READ_PORTS - 1 downto 0);
		ctrl_read_data_vector         : out std_logic_vector(generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_READ_PORTS - 1 downto 0);

		ctrl_write_addresses_vector   : in  std_logic_vector(generics.CTRL_REGFILE_ADDR_WIDTH * generics.NUM_OF_CTRL_WRITE_PORTS - 1 downto 0);
		ctrl_write_data_vector        : in  std_logic_vector(generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_WRITE_PORTS - 1 downto 0);

		ctrl_wes                      : in  std_logic_vector(generics.NUM_OF_CTRL_WRITE_PORTS downto 1);

		ctrl_input_registers          : in  std_logic_vector(generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_INPUTS - 1 downto 0);
		ctrl_output_registers         : out std_logic_vector(generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_OUTPUTS - 1 downto 0);

		branch_mux_ctrl_registers_out : out std_logic_vector(generics.CTRL_REG_WIDTH * (generics.NUM_OF_CTRL_INPUTS + generics.NUM_OF_CTRL_OUTPUTS + generics.CTRL_REG_NUM) downto 0) := (others => '0');

		ctrl_programmable_input_depth : in  t_ctrl_programmable_input_depth;

		clk                           : in  std_logic;
		rst                           : in  std_logic
	);

end control_regfile;

architecture Behavioral of control_regfile is

	--Ericles on Dec 05, 2014: Used to afford the flexibility to select the IC depth
	CONSTANT IC_MAX_DEPTH : integer := 64;
	--This signal is connected to top level
	type t_programmable_output_depth is array (generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_INPUTS + 3 - 1 downto 0) of integer range 0 to IC_MAX_DEPTH;
	signal programmable_output_depth : t_programmable_output_depth;

	CONSTANT NUM_OF_CTRL_READ_PORTS  : positive range 1 to MAX_NUM_CTRL_READ_PORTS  := generics.NUM_OF_CTRL_READ_PORTS;
	CONSTANT NUM_OF_CTRL_WRITE_PORTS : positive range 1 to MAX_NUM_CTRL_WRITE_PORTS := generics.NUM_OF_CTRL_WRITE_PORTS;

	CONSTANT CTRL_REG_NUM : integer range 0 to MAX_NUM_CONTROL_REGS := generics.CTRL_REG_NUM;

	CONSTANT NUM_OF_CTRL_OUTPUTS : integer range 0 to MAX_NUM_CONTROL_OUTPUTS := generics.NUM_OF_CTRL_OUTPUTS;
	CONSTANT NUM_OF_CTRL_INPUTS  : integer range 0 to MAX_NUM_CONTROL_INPUTS  := generics.NUM_OF_CTRL_INPUTS;

	CONSTANT BEGIN_CTRL_OUTPUTS      : integer range -MAX_NUM_CONTROL_REGS to MAX_NUM_CONTROL_REGS := generics.BEGIN_CTRL_OUTPUTS;
	CONSTANT END_CTRL_OUTPUTS        : integer range -MAX_NUM_CONTROL_REGS to MAX_NUM_CONTROL_REGS := generics.END_CTRL_OUTPUTS;
	CONSTANT CTRL_REG_WIDTH          : positive range 1 to MAX_CTRL_REG_WIDTH                      := generics.CTRL_REG_WIDTH;
	CONSTANT CTRL_REGFILE_ADDR_WIDTH : positive range 1 to MAX_CTRL_REGFILE_ADDR_WIDTH             := generics.CTRL_REGFILE_ADDR_WIDTH;

	type ctrl_file_type is array (integer range 0 to CTRL_REG_NUM + NUM_OF_CTRL_INPUTS + NUM_OF_CTRL_OUTPUTS - 1) of std_logic_vector(CTRL_REG_WIDTH - 1 downto 0);
	type t_addr_array is array (integer range <>) of std_logic_vector(CTRL_REGFILE_ADDR_WIDTH - 1 downto 0);
	type t_data_array is array (integer range <>) of std_logic_vector(CTRL_REG_WIDTH - 1 downto 0);

	signal ctrl_registers : ctrl_file_type;

	--Ericles on Dec 05, 2014: Used to afford the flexibility to select the IC depth.
	type ctrl_file_type_vector is array (integer range 0 to CTRL_REG_NUM + NUM_OF_CTRL_INPUTS + NUM_OF_CTRL_OUTPUTS - 1, 0 to IC_MAX_DEPTH - 1) of std_logic_vector(CTRL_REG_WIDTH - 1 downto 0);
	signal sig_ctrl_registers : ctrl_file_type_vector;

	--CONSTANT CTRL_INPUT_OFFSET : integer := CTRL_REG_NUM + NUM_OF_CTRL_OUTPUTS;
	CONSTANT CTRL_INPUT_OFFSET : integer := CTRL_REG_NUM + NUM_OF_CTRL_INPUTS;

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	-- Conversion of the entity in/out (wide) std_logic_vector(CTRL_REG_WIDTH/CTRL_REGFILE_ADDR_WIDTH * NUM_OF ... downto 0) signals 
	-- to array of std_logic_vectors(CTRL_REG_WIDTH/CTRL_REGFILE_ADDR_WIDTH -1 downto 0) indexed with 1 to NUM_OF ...
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	-- Internal array of read addresses und read data grouped to an array for CONVIENIENCE

	signal ctrl_read_addresses : t_addr_array(1 to NUM_OF_CTRL_READ_PORTS);
	signal ctrl_read_data      : t_data_array(1 to NUM_OF_CTRL_READ_PORTS);

	-- Internal array of write addresses und write data grouped to an array for CONVIENIENCE

	signal ctrl_write_addresses : t_addr_array(1 to NUM_OF_CTRL_WRITE_PORTS);
	signal ctrl_write_data      : t_data_array(1 to NUM_OF_CTRL_WRITE_PORTS);
	type t_write_addr is array (1 to NUM_OF_CTRL_WRITE_PORTS+1) of integer range 0 to CTRL_INPUT_OFFSET;
	signal write_addr_sig : t_write_addr;

begin

	--===============================================================================--
	--===============================================================================--
	-- Connect the CONTROL REGISTERS and THE CONTROL INPUTS to the output signal
	-- branch_mux_registers_out which leads to the BRANCH_FLAGS multiplexer

	COND_CTRL_INPUT_AND_REGS_NOT_NULL_AND_OUTPUT : IF (NUM_OF_CTRL_OUTPUTS + NUM_OF_CTRL_INPUTS + CTRL_REG_NUM) > 0 GENERATE
		COND_CTRL_INPUT_NOT_NULL : IF NUM_OF_CTRL_INPUTS > 0 GENERATE
			CTRL_INPUTS_CONNECT : FOR i in CTRL_INPUT_OFFSET to CTRL_INPUT_OFFSET + NUM_OF_CTRL_INPUTS - 1 GENERATE
				branch_mux_ctrl_registers_out(i) <= ctrl_registers(i - CTRL_INPUT_OFFSET)(0);
			END GENERATE;

		END GENERATE;

		COND_CTRL_OUTPUT_NOT_NULL : IF NUM_OF_CTRL_OUTPUTS > 0 GENERATE
			--CTRL_OUTPUTS_CONNECT : FOR i in CTRL_REG_NUM to CTRL_REG_NUM + NUM_OF_CTRL_OUTPUTS - 1 GENERATE
			CTRL_OUTPUTS_CONNECT : FOR i in (NUM_OF_CTRL_INPUTS) to (CTRL_INPUT_OFFSET + NUM_OF_CTRL_OUTPUTS - 1) GENERATE
			--branch_mux_ctrl_registers_out(i) <= ctrl_registers(i)(0);
			--branch_mux_ctrl_registers_out(i) <= ctrl_registers(i)(0);
			END GENERATE;

		END GENERATE;
		--===============================================================================--
		--===============================================================================--

		COND_CTRL_REGS_NOT_NULL : IF CTRL_REG_NUM > 0 GENERATE
			CTRL_REGS_CONNECT : FOR i in 0 to CTRL_REG_NUM - 1 GENERATE

			--branch_mux_ctrl_registers_out(i + NUM_OF_CTRL_INPUTS) <= ctrl_registers(i)(0);
			--branch_mux_ctrl_registers_out(i) <= ctrl_registers(i)(0);
			END GENERATE;

		END GENERATE;

	END GENERATE COND_CTRL_INPUT_AND_REGS_NOT_NULL_AND_OUTPUT;

	--===============================================================================--
	--===============================================================================--
	-- Assign the read addresses from input vector to the INTERNAL read addresses array 

	ctrl_rd_addr : FOR i in 1 to NUM_OF_CTRL_READ_PORTS GENERATE
		ctrl_read_addresses(i) <= ctrl_read_addresses_vector(CTRL_REGFILE_ADDR_WIDTH * i - 1 downto CTRL_REGFILE_ADDR_WIDTH * (i - 1));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- !!!! Assign the read data from internal read data array to the EXternal read data vector !!!

	ctrl_rd_data : FOR i in 1 to NUM_OF_CTRL_READ_PORTS GENERATE
		ctrl_read_data_vector(CTRL_REG_WIDTH * i - 1 downto CTRL_REG_WIDTH * (i - 1)) <= ctrl_read_data(i);

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- Assign the write addresses from input vector to the INTERNAL write addresses array 

	ctrl_wr_addr : FOR i in 1 to NUM_OF_CTRL_WRITE_PORTS GENERATE
		ctrl_write_addresses(i) <= ctrl_write_addresses_vector(CTRL_REGFILE_ADDR_WIDTH * i - 1 downto CTRL_REGFILE_ADDR_WIDTH * (i - 1));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- Assign the write data from input vector to the INTERNAL write data array 

	ctrl_wr_data : FOR i in 1 to NUM_OF_CTRL_WRITE_PORTS GENERATE
		ctrl_write_data(i) <= ctrl_write_data_vector(CTRL_REG_WIDTH * i - 1 downto CTRL_REG_WIDTH * (i - 1));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--

	-- Witing the input values the INPUT ctrl_registers 

	--CTRL_INT_WRITE: FOR i IN CTRL_INPUT_OFFSET
	--			to (CTRL_INPUT_OFFSET + NUM_OF_CTRL_INPUTS -1) GENERATE
	--
	--	ctrl_registers(i) <=	
	--		ctrl_input_registers(CTRL_REG_WIDTH*(i - CTRL_INPUT_OFFSET +1)- 1 
	--					downto CTRL_REG_WIDTH*(i- CTRL_INPUT_OFFSET));		
	--
	--END GENERATE;


	--Ericles on Dec 05, 2014: This code was replaced by the newest version that includes a programmble depth. 
	--	ctrl_writing : process(clk)
	--		variable write_addr : integer range 0 to CTRL_INPUT_OFFSET - 1;
	--
	--	begin
	--		if clk'event and clk = '1' then
	--			if rst = '1' then
	--				ctrl_registers <= (others => (others => '0'));
	--
	--			else
	--
	--				-- Writing to GENERAL_PURPOSE AND OUTPUT_REGISTERS registers (also to INPUT!!!)
	--
	--				FOR i IN 1 to NUM_OF_CTRL_WRITE_PORTS LOOP
	--					write_addr := conv_integer(ctrl_write_addresses(i));
	--
	--					if ctrl_wes(i) = '1' then
	--						if write_addr < CTRL_INPUT_OFFSET then
	--							ctrl_registers(write_addr) <= ctrl_write_data(i)(CTRL_REG_WIDTH - 1 downto 0);
	--
	--						end if;
	--
	--					end if;
	--
	--					FOR i IN CTRL_INPUT_OFFSET to (CTRL_INPUT_OFFSET + NUM_OF_CTRL_INPUTS - 1) LOOP
	--						ctrl_registers(i) <= ctrl_input_registers(CTRL_REG_WIDTH * (i - CTRL_INPUT_OFFSET + 1) - 1 downto CTRL_REG_WIDTH * (i - CTRL_INPUT_OFFSET));
	--
	--					END LOOP;
	--
	--				END LOOP;
	--
	--			end if;
	--		end if;
	--
	--	end process ctrl_writing;

	--Ericles on Dec 05, 2014: Newest version inluding a programmable depth for Control signals (ICs)
	ctrl_writing : process(clk)
		--variable write_addr : integer range 0 to CTRL_INPUT_OFFSET - 1;
		variable write_addr : t_write_addr;
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				ctrl_registers     <= (others => (others => '0'));
				sig_ctrl_registers <= (others => (others => (others => '0')));

			else
				-- Writing to GENERAL_PURPOSE AND OUTPUT_REGISTERS registers (also to INPUT!!!)
				FOR i IN 1 to NUM_OF_CTRL_WRITE_PORTS LOOP
--					write_addr(i) := conv_integer(ctrl_write_addresses(i));

--					if ctrl_wes(i) = '1' then
--						if write_addr(i) < CTRL_INPUT_OFFSET then
--							sig_ctrl_registers(write_addr(i), 0) <= ctrl_write_data(i)(CTRL_REG_WIDTH - 1 downto 0);
--						end if;
--					end if;
					--				FOR i IN CTRL_INPUT_OFFSET to (CTRL_INPUT_OFFSET + NUM_OF_CTRL_INPUTS - 1) LOOP
					--						ctrl_registers(i) <= ctrl_input_registers(CTRL_REG_WIDTH * (i - CTRL_INPUT_OFFSET + 1) - 1 downto CTRL_REG_WIDTH * (i - CTRL_INPUT_OFFSET));
					--				END LOOP;

					--FOR i IN CTRL_INPUT_OFFSET to (CTRL_INPUT_OFFSET + NUM_OF_CTRL_INPUTS - 1) LOOP
					FOR i in 0 to (generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_INPUTS + CTRL_INPUT_OFFSET - 1) loop
						--ctrl_registers(i) <= ctrl_input_registers(CTRL_REG_WIDTH * (i - CTRL_INPUT_OFFSET + 1) - 1 downto CTRL_REG_WIDTH * (i - CTRL_INPUT_OFFSET));
						--Ericles on Dec 04, 2014: Shift register
						for j in 1 to IC_MAX_DEPTH - 1 loop
							sig_ctrl_registers(i, j) <= sig_ctrl_registers(i, j - 1);
						end loop;
						--Ericles on Dec 04, 2014: Controlling the depth. The parameter "programmable_output_depth" is controlled via software (APB interface)
						case (programmable_output_depth(i)) is
							when 0 to IC_MAX_DEPTH - 1 =>
								ctrl_registers(i) <= sig_ctrl_registers(i, programmable_output_depth(i));
							when others => null;
						end case;

					END LOOP;
				END LOOP;

			end if;
		end if;
		--Ericles on Dec 04, 2014: For the programmable Shift register		
		--FOR i IN CTRL_INPUT_OFFSET to (CTRL_INPUT_OFFSET + NUM_OF_CTRL_INPUTS - 1) LOOP
		FOR i IN 0 to (NUM_OF_CTRL_INPUTS - 1) LOOP
			sig_ctrl_registers(i, 0) <= ctrl_input_registers(i downto i);
		end loop;
		for i in 0 to (generics.CTRL_REG_WIDTH * generics.NUM_OF_CTRL_INPUTS - 1) loop
			programmable_output_depth(i) <= ctrl_programmable_input_depth(i);
		end loop;
	end process ctrl_writing;

	--===========================================================================================
	--===========================================================================================

	ctrl_write_output : process(rst, ctrl_write_data, ctrl_write_addresses, ctrl_registers, sig_ctrl_registers, ctrl_wes)
		variable ctrl_write_address : integer range 0 to MAX_NUM_CONTROL_REGS;
		variable ctrl_write_addr : t_write_addr;
	begin
		if rst = '1' then
			ctrl_output_registers <= (others => '0');

		else
			FOR i IN 0 to NUM_OF_CTRL_INPUTS - 1 LOOP
				ctrl_output_registers(CTRL_REG_WIDTH * (i + 1) - 1 downto CTRL_REG_WIDTH * i) <= ctrl_registers(i + BEGIN_CTRL_OUTPUTS-1);
				--Ericles Sousa on 16 Feb 2015
				--ctrl_output_registers(i downto i) <= ctrl_registers(i);
			END LOOP;
--			FOR i IN 1 to NUM_OF_CTRL_WRITE_PORTS LOOP
--				if ctrl_wes(i) = '1' then
--					ctrl_write_address := conv_integer(ctrl_write_addresses(i));
--					if (BEGIN_CTRL_OUTPUTS <= ctrl_write_address and ctrl_write_address <= END_CTRL_OUTPUTS) then
--						ctrl_output_registers(CTRL_REG_WIDTH * (ctrl_write_address - BEGIN_CTRL_OUTPUTS + 1) - 1 downto CTRL_REG_WIDTH * (ctrl_write_address - BEGIN_CTRL_OUTPUTS)) <= ctrl_write_data(i)(CTRL_REG_WIDTH - 1 downto 0);
--					end if;
--				end if;
--			END LOOP;

--			FOR i IN NUM_OF_CTRL_INPUTS to NUM_OF_CTRL_WRITE_PORTS LOOP
--				if ctrl_wes(1) = '1' then
--					ctrl_write_address := conv_integer(ctrl_write_addresses(1));
--					ctrl_write_addr(1) := conv_integer(ctrl_write_addresses(1));
--					--ctrl_output_registers(CTRL_REG_WIDTH * (ctrl_write_addr(1) - BEGIN_CTRL_OUTPUTS + 1) - 1 downto CTRL_REG_WIDTH * (ctrl_write_addr(1) - BEGIN_CTRL_OUTPUTS)) <= ctrl_write_data(1)(CTRL_REG_WIDTH - 1 downto 0);
--					ctrl_output_registers(1 downto 1) <= ctrl_write_data(1)(CTRL_REG_WIDTH - 1 downto 0);
--
--					if (BEGIN_CTRL_OUTPUTS <= ctrl_write_addr(i) and ctrl_write_addr(i) <= END_CTRL_OUTPUTS) then
--				  	--	ctrl_output_registers(CTRL_REG_WIDTH * (i) - 1 downto CTRL_REG_WIDTH * (i-1)) <= ctrl_registers(i-1 + BEGIN_CTRL_OUTPUTS-1);
--						--ctrl_output_registers(CTRL_REG_WIDTH * (ctrl_write_addr(i) - BEGIN_CTRL_OUTPUTS + 1) - 1 downto CTRL_REG_WIDTH * (ctrl_write_addr(i) - BEGIN_CTRL_OUTPUTS)) <= ctrl_write_data(i)(CTRL_REG_WIDTH - 1 downto 0);
--						--ctrl_output_registers(1 downto 1) <= ctrl_write_data(i)(CTRL_REG_WIDTH - 1 downto 0);
--					end if;
--				end if;
--			END LOOP;

			FOR i IN 1 to NUM_OF_CTRL_WRITE_PORTS-1 LOOP
				if ctrl_wes(i) = '1' then
					ctrl_write_address := conv_integer(ctrl_write_addresses(i));
					ctrl_write_addr(i) := conv_integer(ctrl_write_addresses(i));
					if (BEGIN_CTRL_OUTPUTS <= ctrl_write_address and ctrl_write_address <= END_CTRL_OUTPUTS) then
						--ctrl_output_registers((CTRL_REG_WIDTH * ctrl_write_address) - 1 downto (CTRL_REG_WIDTH * (ctrl_write_address-1))) <= ctrl_write_data(1)(CTRL_REG_WIDTH - 1 downto 0);
						ctrl_output_registers(CTRL_REG_WIDTH*i downto CTRL_REG_WIDTH*(i)) <= ctrl_write_data(i)(CTRL_REG_WIDTH - 1 downto 0);
					end if;
				end if;
			end loop;

		end if;                         -- reset
	end process ctrl_write_output;

	--===========================================================================================
	--===========================================================================================

	ctrl_reading : process(ctrl_read_addresses, ctrl_registers)
	begin
		FOR i IN 1 to NUM_OF_CTRL_READ_PORTS LOOP
			ctrl_read_data(i)(CTRL_REG_WIDTH - 1 downto 0) <= ctrl_registers(conv_integer(ctrl_read_addresses(i)));

		END LOOP;

	end process ctrl_reading;

end Behavioral;



