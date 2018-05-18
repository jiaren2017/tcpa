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


--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.all;

use wppa_instance_v1_01_a.ALL;

package wppe_lib is
	constant MAX_DIGITS : integer := 20;
	subtype int_string_buf is string(1 to MAX_DIGITS);

	--===============================================================================--
	--===============================================================================--
	-- MAXIMUM AND MINIMUM INTERCONNECT CONFIGURATION
	-- REGISTER WIDTH (FOR THE SELECT INPUTS OF ICN MULTIPLEXERS
	-- in the ICN_WRAPPER COMPONENT)

	CONSTANT MAX_CONFIG_REG_WIDTH : integer := 64;
	CONSTANT MIN_CONFIG_REG_WIDTH : integer := 0;

	--===============================================================================--
	--===============================================================================--
	-- MAXIMUM AND MINIMUM GLOBAL CONFIGURATION BUS ADDR WIDTH

	CONSTANT MAX_BUS_ADDR_WIDTH : integer := 64;
	CONSTANT MIN_BUS_ADDR_WIDTH : integer := 8;

	-- MAXIMUM AND MINIMUM GLOBAL CONFIGURATION BUS DATA WIDTH

	CONSTANT MAX_BUS_DATA_WIDTH : integer := 64;
	CONSTANT MIN_BUS_DATA_WIDTH : integer := 8;

	--===============================================================================--
	--===============================================================================--
	-- MAXIMUM GLOBAL CONFIGURATION MEMORY ADDR WIDTH

	CONSTANT MAX_SOURCE_ADDR_WIDTH : integer := 16;

	-- MAXIMUM GLOBAL CONFIGURATION MEMORY DATA WIDTH
	CONSTANT MAX_SOURCE_DATA_WIDTH : integer := 64;

	-- MAXIMUM GLOBAL CONFIGURATION MEMORY SIZE
	CONSTANT MAX_SOURCE_MEM_SIZE : integer := 65536;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM NUMBER OF VERTICAL WPPEs --
	-- ###########
	CONSTANT MAX_NUM_WPPE_VERTICAL : integer := 10; --3;

	--===============================================================================--

	-- MINIMUM NUMBER OF VERTICAL WPPEs --													  

	CONSTANT MIN_NUM_WPPE_VERTICAL : integer := 1;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM NUMBER OF HORIZONTAL WPPEs --
	-- ###########
	CONSTANT MAX_NUM_WPPE_HORIZONTAL : integer := 10; --3;

	--===============================================================================--

	-- MINIMUM NUMBER OF HORIZONTAL WPPEs --													  

	CONSTANT MIN_NUM_WPPE_HORIZONTAL : integer := 1;

	--===============================================================================--
	--===============================================================================--


	--===============================================================================--
	--===============================================================================--

	--*******************************************************************************--
	-- Turning the ASSERT ... messages on for simulation and off for synthesis
	--*******************************************************************************--

	CONSTANT NUM_OF_WPPE : INTEGER := 1;

	CONSTANT CUR_SIM_MODE : BOOLEAN := false;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM NUMBER OF FEED-BACK FIFOS --

	CONSTANT MAX_NUM_FB_FIFO : POSITIVE := 16;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM FIFO SIZE --

	CONSTANT MAX_FIFO_SIZE : POSITIVE := 1024;

	-- MINIMUM FIFO SIZE --

	CONSTANT MIN_FIFO_SIZE : POSITIVE := 1;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM FIFO ADDRESS WIDTH --

	CONSTANT MAX_FIFO_ADDR_WIDTH : POSITIVE := 12;

	-- MINIMUM FIFO ADDRESS WIDTH --

	--Ericles on Dec 05, 2014: The correct value should 0. However, due to some implemenation issues
	-- of the TCPA, we decided to dump the minimum value as 1 from TCPA editor.
	CONSTANT MIN_FIFO_ADDR_WIDTH : POSITIVE := 1;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM INSTRUCTION WIDTH --

	CONSTANT MAX_INSTR_WIDTH : POSITIVE := 32;

	-- MINIMUM INSTRUCTION WIDTH --

	CONSTANT MIN_INSTR_WIDTH : POSITIVE := 8;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM  BRANCH INSTRUCTION WIDTH --

	CONSTANT MAX_BRANCH_INSTR_WIDTH : POSITIVE := 256;

	-- MINIMUM INSTRUCTION WIDTH --

	CONSTANT MIN_BRANCH_INSTR_WIDTH : POSITIVE := 8;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM BRANCH FLAGS NUMBER --

	CONSTANT MAX_BRANCH_FLAGS_NUM : INTEGER := 8;

	-- MINIMUM BRANCH FLAGS NUMBER --

	CONSTANT MIN_BRANCH_FLAGS_NUM : INTEGER := 0;

	--===============================================================================--

	-- MAXIMUM  BRANCH TARGET WIDTH --

	CONSTANT MAX_BRANCH_TARGET_WIDTH : POSITIVE := 32;

	-- MINIMUM BRANCH TARGET WIDTH --

	CONSTANT MIN_BRANCH_TARGET_WIDTH : POSITIVE := 1;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM and MINIMUM ADDRESS AND DATA WIDTHS --

	CONSTANT MAX_DATA_WIDTH : POSITIVE := 128;
	CONSTANT MIN_DATA_WIDTH : POSITIVE := 1;

	CONSTANT MAX_ADDR_WIDTH : POSITIVE := 32;
	CONSTANT MIN_ADDR_WIDTH : POSITIVE := 1;

	--===============================================================================--
	--===============================================================================--

	-- Register File address width

	CONSTANT MAX_REG_FILE_ADDR_WIDTH : POSITIVE := 8;

	--===============================================================================--
	--===============================================================================--

	-- GENERAL PURPOSE REGISTER WIDTH --

	CONSTANT MAX_GEN_PUR_REG_WIDTH : POSITIVE := 32;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM NUMBER OF GENERAL PURPOSE REGISTERS --

	CONSTANT MAX_GEN_PUR_REG_NUM : POSITIVE := 32;

	-- MAXIMUM WIDTH OF THE REGISTER FIELD IN THE INSTRUCTION

	CONSTANT MAX_REG_FIELD_WIDTH : POSITIVE := 5; -- = log_2(MAX_GEN_PUR_REG_NUM)

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM WIDTH OF THE OPCODE FIELD IN THE INSTRUCTION

	CONSTANT MAX_OPCODE_FIELD_WIDTH : POSITIVE := 5;

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM NUMBER OF INPUT REGISTERS --

	CONSTANT MAX_INPUT_REG_NUM : POSITIVE := 16;

	--===============================================================================--

	-- MAXIMUM NUMBER OF OUTPUT REGISTERS --

	CONSTANT MAX_OUTPUT_REG_NUM : POSITIVE := 16;

	--===============================================================================--

	-- MAXIMUM MEMORY SIZE --

	CONSTANT MAX_MEM_SIZE : POSITIVE := 1024;

	-- MINIMUM MEMORY SIZE --
	-- shravan : 20120627 : undo this change
	--		CONSTANT MIN_MEM_SIZE :POSITIVE := 8;
	CONSTANT MIN_MEM_SIZE : POSITIVE := 4;
	--===============================================================================--

	-- MAXIMUM NUMBER OF MEMORY READ PORTS --

	CONSTANT MAX_NUM_MEM_READ_PORTS : POSITIVE := 32;

	--===============================================================================--

	-- MAXIMUM NUMBER OF MEMORY WRITE PORTS --

	CONSTANT MAX_NUM_MEM_WRITE_PORTS : POSITIVE := 32;

	--===============================================================================--

	-- MAXIMUM NUMBER OF FUNCTIONAL UNITS --
	--Ericles
	CONSTANT MAX_NUM_FU : POSITIVE := 20; --7;
	--		CONSTANT MAX_NUM_ADD_FU   :POSITIVE := 5;
	--		CONSTANT MAX_NUM_MUL_FU   :POSITIVE := 5;
	--		CONSTANT MAX_NUM_DIV_FU   :POSITIVE := 5;
	--		CONSTANT MAX_NUM_LOGIC_FU :POSITIVE := 5;	
	--		CONSTANT MAX_NUM_SHIFT_FU :POSITIVE := 5;
	--		CONSTANT MAX_NUM_DPU_FU   :POSITIVE := 5;	
	--		CONSTANT MAX_NUM_CPU_FU   :POSITIVE := 5;	

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM NUMBER OF CONTROL REGISTER FILE READ PORTS --

	CONSTANT MAX_NUM_CTRL_READ_PORTS : POSITIVE := 8;

	--===============================================================================--

	-- MAXIMUM NUMBER OF CONTROL WRITE PORTS --

	CONSTANT MAX_NUM_CTRL_WRITE_PORTS : POSITIVE := 8;

	--===============================================================================--

	-- CONTROL Register File address width

	CONSTANT MAX_CTRL_REGFILE_ADDR_WIDTH : POSITIVE := 5;

	--===============================================================================--

	-- CONTROL REGISTER WIDTH --

	CONSTANT MAX_CTRL_REG_WIDTH : POSITIVE := 8;

	--===============================================================================--	

	CONSTANT MAX_NUM_CONTROL_REGS : INTEGER := 16;

	--===============================================================================--	

	CONSTANT MAX_NUM_CONTROL_INPUTS : INTEGER := 8;

	--===============================================================================--	

	CONSTANT MAX_NUM_CONTROL_OUTPUTS : INTEGER := 8;

	--===============================================================================--		


	--===============================================================================--			

	type t_1BitArray is array (natural range <>) of std_logic_vector(0 downto 0);
	type t_2BitArray is array (natural range <>) of std_logic_vector(1 downto 0);
	type t_3BitArray is array (natural range <>) of std_logic_vector(2 downto 0);

	type t_4BitArray is array (natural range <>) of std_logic_vector(3 downto 0);
	type t_5BitArray is array (natural range <>) of std_logic_vector(4 downto 0);
	type t_8BitArray is array (natural range <>) of std_logic_vector(7 downto 0);
	type t_9BitArray is array (natural range <>) of std_logic_vector(8 downto 0);
	type t_13BitArray is array (natural range <>) of std_logic_vector(12 downto 0);
	type t_16BitArray is array (natural range <>) of std_logic_vector(15 downto 0);

	type t_DataWidthArray is array (natural range <>) of std_logic_vector(MAX_DATA_WIDTH - 1 downto 0);
	type t_AddrWidthArray is array (natural range <>) of std_logic_vector(MAX_ADDR_WIDTH - 1 downto 0);

	type t_fifo_sizes is array (natural range <>) of integer range 0 to 2048;
	type t_int_array is array (natural range <>) of integer range 0 to 32;

	-- cadence translate_off
	FUNCTION my_digit_to_char(input : integer) return character;

	PROCEDURE Int_to_string_proc(
		constant val    : in  integer;
		variable result : out int_string_buf;
		variable last   : out integer);

	FUNCTION Int_to_string(val : integer) return string; --int_string_buf;
	-- cadence translate_on

	FUNCTION max_value(values : t_int_array(4 downto 1)) RETURN integer;

	FUNCTION log_width(in_width : integer) RETURN integer;

	--===============================================================================--		
	--===============================================================================--		

	FUNCTION TO_NATURAL(in_vec : std_logic_vector) RETURN natural;

	--===============================================================================--		
	--===============================================================================--	

	FUNCTION int2slvect(int_value : INTEGER; size : INTEGER) RETURN std_logic_vector;

	--===============================================================================--		
	--===============================================================================--	

	FUNCTION check_if_null(parameter : in INTEGER) RETURN INTEGER;

	--===============================================================================--		
	--===============================================================================--																												


	-- MAXIMUM FU INPUT-MUX SELECT WIDTHS --		+ 1 because of the instr_decoder data output

	CONSTANT MAX_MUX_SEL_WIDTH : positive := 18; --log_width(MAX_NUM_MEM_READ_PORTS + MAX_INPUT_REG_NUM + 1);

	--===============================================================================--
	--===============================================================================--

	-- MAXIMUM FU OUTPUT-DEmux SELECT WIDTHS --	

	CONSTANT MAX_DEmux_SEL_WIDTH : positive := 18; --log_width(MAX_NUM_MEM_WRITE_PORTS + MAX_OUTPUT_REG_NUM);

--===============================================================================--
--===============================================================================--


end wppe_lib;

--===============================================================================--		

package body wppe_lib is
	FUNCTION max_value(values : t_int_array(4 downto 1)) RETURN integer IS
		variable temp : integer range 0 to 256 := 0;
	begin
		FOR i in values'high downto values'low LOOP
			if values(i) > temp then
				temp := values(i);

			end if;

		END LOOP;

		return temp;

	END max_value;

	-- cadence translate_off	 
	FUNCTION my_digit_to_char(input : integer) return character IS
		variable tmp : character;

	begin
		case input is
			when 0      => tmp := '0';
			when 1      => tmp := '1';
			when 2      => tmp := '2';
			when 3      => tmp := '3';
			when 4      => tmp := '4';
			when 5      => tmp := '5';
			when 6      => tmp := '6';
			when 7      => tmp := '7';
			when 8      => tmp := '8';
			when 9      => tmp := '9';
			when others => tmp := '?';

		end case;

		return tmp;

	END my_digit_to_char;

	procedure Int_to_string_proc(
		constant val    : in  integer;
		variable result : out int_string_buf;
		variable last   : out integer)
		is
		variable buf    : string(MAX_DIGITS downto 1);
		variable pos    : integer := 1;
		variable tmp    : integer := abs (val);
		variable digit  : integer;
		variable my_int : integer;

	begin
		loop
			digit    := abs (tmp MOD 10); -- MOD of integer'left returns neg number!
			tmp      := tmp / 10;
			my_int   := digit;
			--	    buf(pos) := character'val(character'pos('0') + digit);
			buf(pos) := my_digit_to_char(my_int);
			pos      := pos + 1;
			exit when tmp = 0;
		end loop;
		if val < 0 then
			buf(pos) := '-';
			pos      := pos + 1;
		end if;
		pos              := pos - 1;
		result(1 to pos) := buf(pos downto 1);
		last             := pos;
	end Int_to_string_proc;             -- procedure


	function Int_to_string(val : integer) return string --int_string_buf --string
		is
		variable buf  : int_string_buf;
		variable last : integer;

	begin
		Int_to_string_proc(val, buf, last);

		return buf(1 to last);
	end Int_to_string;                  -- function

	-- cadence translate_on

	--===============================================================================--		
	--===============================================================================--		

	FUNCTION log_width(in_width : integer) RETURN integer IS
		variable j : integer;
	Begin
		j := 1;
		if (in_width < 1) then
			return 0;
		elsif (in_width = 1) then
			return 1;
		else
			for i in 1 to 31 loop
				if (2 ** j >= in_width) then
					return i;
				end if;
				j := j + 1;
			end loop;
		end if;

	END log_width;

	--===============================================================================--		
	--===============================================================================--	

	FUNCTION check_if_null(parameter : in INTEGER) RETURN INTEGER IS
		variable answer : integer := 0;

	begin
		if (parameter = 0) then
			answer := 0;

		else
			answer := 1;

		end if;

		return answer;

	end check_if_null;

	--===============================================================================--		
	--===============================================================================--	

	FUNCTION TO_NATURAL(in_vec : std_logic_vector) RETURN natural IS
		variable res : natural;
	BEGIN
		res := 0;
		for i in in_vec'high downto in_vec'low loop
			if in_vec(i) = '1' then
				res := res + 2 ** i;
			end if;
		end loop;
		return res;
	END TO_NATURAL;

	--===============================================================================--		
	--===============================================================================--		

	FUNCTION int2slvect(int_value : INTEGER;
		                size      : INTEGER) RETURN std_logic_vector IS
		VARIABLE result : std_logic_vector(size - 1 DOWNTO 0);
	BEGIN
		FOR i IN 0 TO size - 1 LOOP
			IF ((int_value / (2 ** i)) REM 2) = 0 THEN
				result(i) := '0';
			ELSE
				result(i) := '1';
			END IF;
		END LOOP;
		RETURN result;
	END int2slvect;

--===============================================================================--		
--===============================================================================--	


end wppe_lib;
