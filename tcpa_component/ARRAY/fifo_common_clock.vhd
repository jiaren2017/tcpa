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
-- Create Date:    13:21:14 11/01/05
-- Design Name:    
-- Module Name:    fifo_common_clock - Behavioral; 

--****************************************************************
--	taken from Xilinx 7.0 ISE_Examples v2_fifo_vhd_258
--	and modified to meet current needs 
-- ==> GENERIC (DATA_WIDTH, FIFO_SIZE)
--****************************************************************

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
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library UNISIM;
--use UNISIM.VCOMPONENTS.ALL;


use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

entity fifo_common_clock is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME : string;
		-- cadence translate_on				
		LUT_RAM_TYPE  : std_logic                                                 := '1'; -- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH           := CUR_DEFAULT_DATA_WIDTH;
		ADDR_WIDTH    : positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH;
		FIFO_SIZE     : positive range MIN_FIFO_SIZE to MAX_FIFO_SIZE             := CUR_DEFAULT_FIFO_SIZE
	);

	port(clk             : IN  std_logic;
		 rst             : IN  std_logic;
		 read_enable_in  : IN  std_logic;
		 write_enable_in : IN  std_logic;
		 write_data_in   : IN  std_logic_vector(DATA_WIDTH - 1 downto 0);
		 --dual_data_in:	  IN  std_logic_vector(DATA_WIDTH -1 downto 0);
		 read_data_out   : OUT std_logic_vector(DATA_WIDTH - 1 downto 0);
		 full_out        : OUT std_logic;
		 empty_out       : OUT std_logic
	);

END fifo_common_clock;

architecture behavioral of fifo_common_clock is
	signal write_addr, read_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);

	component LUT_fifo_memory is
		generic(
			-- cadence translate_off
			INSTANCE_NAME : string;
			-- cadence translate_on				
			FIFO_SIZE     : positive range MIN_FIFO_SIZE to MAX_FIFO_SIZE             := CUR_DEFAULT_FIFO_SIZE;
			DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH           := CUR_DEFAULT_DATA_WIDTH;
			ADDR_WIDTH    : positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH
		);

		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			we         : in  std_logic;
			write_addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			read_addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			d_in       : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			d_out      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component;

	component BRAM_fifo_memory is
		generic(
			-- cadence translate_off				
			INSTANCE_NAME : string;
			-- cadence translate_on				
			FIFO_SIZE     : positive range MIN_FIFO_SIZE to MAX_FIFO_SIZE             := CUR_DEFAULT_FIFO_SIZE;
			DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH           := CUR_DEFAULT_DATA_WIDTH;
			ADDR_WIDTH    : positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH
		);

		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			we         : in  std_logic;
			write_addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			read_addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
			d_in       : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			d_out      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component;

BEGIN
	CHECK_LUT_RAM_TYPE : IF LUT_RAM_TYPE = '1' GENERATE

		--------------------------------------------------------------------------
		--                                                                      --
		-- 			LUT RAM instantiation for FIFO									   -- 
		--------------------------------------------------------------------------

		LUT_RAM : LUT_fifo_memory
			generic map(
				-- cadence translate_off					
				INSTANCE_NAME => INSTANCE_NAME & "/LUT_RAM",
				-- cadence translate_on	
				FIFO_SIZE     => FIFO_SIZE,
				DATA_WIDTH    => DATA_WIDTH,
				ADDR_WIDTH    => ADDR_WIDTH
			)
			port map(
				clk        => clk,
				rst        => rst,
				we         => '1',      --'write_enable_in,
				write_addr => write_addr,
				read_addr  => read_addr,
				d_in       => write_data_in,
				d_out      => read_data_out
			);

	END GENERATE;

	CHECK_BLOCK_RAM_TYPE : IF LUT_RAM_TYPE = '0' GENERATE

		--------------------------------------------------------------------------
		--                                                                      --
		-- 			BLOCK RAM instantiation for FIFO									   -- 
		--------------------------------------------------------------------------

		BLOCK_RAM : BRAM_fifo_memory
			generic map(
				-- cadence translate_off					
				INSTANCE_NAME => INSTANCE_NAME & "/BLOCK_RAM",
				-- cadence translate_on	
				FIFO_SIZE     => FIFO_SIZE,
				DATA_WIDTH    => DATA_WIDTH,
				ADDR_WIDTH    => ADDR_WIDTH
			)
			port map(
				clk        => clk,
				rst        => rst,
				we         => write_enable_in,
				write_addr => write_addr,
				read_addr  => read_addr,
				d_in       => write_data_in,
				d_out      => read_data_out
			);

	END GENERATE;

--	CONSTANT HALF_ADDR_WIDTH :POSITIVE := ADDR_WIDTH / 2;	
--
----========================================================================================================
----========================================================================================================
--
--	FUNCTION make_ored_bit(vect :in std_logic_vector; len :in integer range 0 to 32) RETURN std_logic;
--
----========================================================================================================
--
--	FUNCTION make_anded_bit(vect :in std_logic_vector; len :in integer range 0 to 32) RETURN std_logic;
--
----========================================================================================================
----========================================================================================================
--
--
----========================================================================================================
----========================================================================================================
--	FUNCTION make_ored_bit(vect :in std_logic_vector; len :in integer range 0 to 32) RETURN std_logic IS
--
--		variable result :std_logic;
--
--		begin
--			
--			result := '0';
--
--			FOR i in vect'high downto vect'low LOOP
--
--				result := result OR vect(i);
--
--			END LOOP;
--
--		return result;
--
--	end function;
----========================================================================================================
--
--FUNCTION make_anded_bit(vect :in std_logic_vector; len :in integer range 0 to 32) RETURN std_logic IS
--
--		variable result :std_logic;
--
--		begin
--			
--			result := '1';
--
--			FOR i in vect'high downto vect'low LOOP
--			
--				result := result AND vect(i);
--
--			END LOOP;
--
--		return result;
--
--	end function;
--
----========================================================================================================
----========================================================================================================
--
--	signal dual_data_out	:std_logic_vector(DATA_WIDTH -1 downto 0);
--							 
--	signal ored_first_half_fcounter  :std_logic;
--	signal ored_second_half_fcounter :std_logic;
--
--	signal anded_first_half_fcounter	 :std_logic;
--	signal anded_second_half_fcounter :std_logic;
--
--	signal read_enable:           std_logic;
--	signal write_enable:          std_logic;
--	signal memory_write_allow:		std_logic;
--	signal read_data:             std_logic_vector(DATA_WIDTH -1 downto 0);
--   signal write_data:            std_logic_vector(DATA_WIDTH -1 downto 0);
--   signal full:                  std_logic;
--   signal empty:                 std_logic;
--   signal read_addr:             std_logic_vector(ADDR_WIDTH -1 downto 0);
--   signal write_addr:            std_logic_vector(ADDR_WIDTH -1 downto 0);
--	signal internal_write_addr:   std_logic_vector(ADDR_WIDTH -1 downto 0);
--	signal internal_write_counter: std_logic_vector(ADDR_WIDTH -1 downto 0);
--	signal internal_write_data:	std_logic_vector(DATA_WIDTH -1 downto 0);
--	signal write_offset:				std_logic_vector(ADDR_WIDTH -1 downto 0);
--	signal fcounter:              std_logic_vector(ADDR_WIDTH -1 downto 0);
--   signal read_allow:            std_logic;
--   signal write_allow:           std_logic;
--   signal fcnt_allow:            std_logic;
--   signal fcntandout:            std_logic_vector(3 downto 0);
--   signal ra_or_fcnt0:           std_logic;
--   signal wa_or_fcnt0:           std_logic;
--   signal emptyg:                std_logic;
--   signal fullg:                 std_logic;
--
--component LUT_fifo_memory is
--
--	generic (
--			
--			FIFO_SIZE  	:positive range MIN_FIFO_SIZE  to MAX_FIFO_SIZE  := CUR_DEFAULT_FIFO_SIZE;
--			DATA_WIDTH	:positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH;
--			ADDR_WIDTH	:positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH
--	);
--
--	port (
--					clk : in std_logic;
--					rst : in std_logic;					
--					we  : in std_logic;
--					write_addr : in std_logic_vector(ADDR_WIDTH -1 downto 0);
--					read_addr  : in std_logic_vector(ADDR_WIDTH -1 downto 0);
--					d_in  : in std_logic_vector(DATA_WIDTH -1 downto 0);
--					d_out : out std_logic_vector(DATA_WIDTH -1 downto 0)
--			);
--
--
--end component;
--
--component BRAM_fifo_memory is
--
--	generic (
--			
--			FIFO_SIZE  	:positive range MIN_FIFO_SIZE  to MAX_FIFO_SIZE  := CUR_DEFAULT_FIFO_SIZE;
--			DATA_WIDTH	:positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH;
--			ADDR_WIDTH	:positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH
--	);
--
--	port (
--					clk : in std_logic;
--					rst : in std_logic;					
--					we  : in std_logic;
--					write_addr : in std_logic_vector(ADDR_WIDTH -1 downto 0);
--					read_addr  : in std_logic_vector(ADDR_WIDTH -1 downto 0);
--					d_in  : in std_logic_vector(DATA_WIDTH -1 downto 0);
--					d_out : out std_logic_vector(DATA_WIDTH -1 downto 0)
--			);
--
--
--end component;
--
--
--BEGIN
--   read_enable <= read_enable_in;
--   write_enable <= write_enable_in;
--   write_data <= write_data_in;
--   read_data_out <= read_data;
--	dual_data_out <= read_data;
--
--	internal_write_addr <= write_addr;
--	internal_write_data <= write_data; 
--	write_offset        <= write_addr;
--
--
--	memory_write_allow <= write_enable_in; -- or read_enable_in; -- or read_allow;
--   full_out <= full;
--   empty_out <= empty;
--
--CHECK_ADDR_WIDTH: IF ADDR_WIDTH > 2 GENERATE
--	
--	ored_first_half_fcounter  <= make_ored_bit(fcounter(HALF_ADDR_WIDTH downto 0), HALF_ADDR_WIDTH + 1);
--	ored_second_half_fcounter <= make_ored_bit(fcounter(ADDR_WIDTH -1 downto HALF_ADDR_WIDTH + 1), HALF_ADDR_WIDTH);
--
--	anded_first_half_fcounter	<= make_anded_bit(fcounter(HALF_ADDR_WIDTH downto 1), HALF_ADDR_WIDTH);
--	anded_second_half_fcounter	<= make_anded_bit(fcounter(ADDR_WIDTH -1 downto HALF_ADDR_WIDTH + 1), HALF_ADDR_WIDTH);
--
--END GENERATE;
--
--SET_IF_ADDR_ONE: IF ADDR_WIDTH = 1 GENERATE
--
--	ored_first_half_fcounter  <= '0';
--	ored_second_half_fcounter <= '0';
--	
--	anded_first_half_fcounter	<= '0';
--	anded_second_half_fcounter	<= '0';
--
--END GENERATE;
--
--
--CHECK_LUT_RAM_TYPE :IF LUT_RAM_TYPE = '1' GENERATE
--	
--	--------------------------------------------------------------------------
--	--                                                                      --
--	-- 			LUT RAM instantiation for FIFO									   -- 
--	--------------------------------------------------------------------------
--
--	LUT_RAM: LUT_fifo_memory 
--				generic map(
--				
--						FIFO_SIZE  	=> FIFO_SIZE,
--						DATA_WIDTH	=> DATA_WIDTH,
--						ADDR_WIDTH	=> ADDR_WIDTH
--				
--				)
--
--				port map (
--
--						clk 	=> clk,
--						rst 	=> rst,
--						we  	=> memory_write_allow, --write_allow,
--						write_addr => write_addr,
--						read_addr  => read_addr,
--						d_in  => internal_write_data,
--						d_out => read_data
--										
--				);
--
--END GENERATE;
--
--CHECK_BLOCK_RAM_TYPE :IF LUT_RAM_TYPE = '0' GENERATE
--
--	--------------------------------------------------------------------------
--	--                                                                      --
--	-- 			BLOCK RAM instantiation for FIFO									   -- 
--	--------------------------------------------------------------------------
--
--	BLOCK_RAM: BRAM_fifo_memory 
--				generic map(
--				
--						FIFO_SIZE  	=> FIFO_SIZE,
--						DATA_WIDTH	=> DATA_WIDTH,
--						ADDR_WIDTH	=> ADDR_WIDTH
--				
--				)
--
--				port map (
--
--						clk 	=> clk,
--						rst 	=> rst,
--						we  	=> memory_write_allow, --write_allow,
--						write_addr => write_addr,
--						read_addr  => read_addr,
--						d_in  => internal_write_data,
--						d_out => read_data
--										
--				);
--
--END GENERATE;
--			
-----------------------------------------------------------------
----                                                           --
----  Set allow flags, which control the clk enables for     --
----  read, write, and count operations.                       --
----                                                           --
-----------------------------------------------------------------
-- 
--proc1: PROCESS (rst, clk)
--BEGIN
--   IF (rst = '1') THEN
--      read_allow <= '0';
--	ELSIF (clk'EVENT AND clk = '1') THEN
--	   read_allow <= read_enable;-- AND NOT (fcntandout(0) AND fcntandout(1)
--                    				  --AND NOT write_allow);
--	END IF;
--END PROCESS proc1;
--
--proc2: PROCESS (rst, clk)
--BEGIN
--   IF (rst = '1') THEN
--      write_allow <= '0';
--   ELSIF (clk'EVENT AND clk = '1') THEN
--	    write_allow <= write_enable; 
--   END IF;
--END PROCESS proc2;
--
--fcnt_allow <= write_allow XOR read_allow;
--
-----------------------------------------------------------------
----                                                           --
----  Empty flag is set on rst (initial), or when on the  --
----  next clk cycle, Write Enable is low, and either the    --
----  FIFOcount is equal to 0, or it is equal to 1 and Read    --
----  Enable is high (about to go Empty).                      --
----                                                           --
-----------------------------------------------------------------
--
--ra_or_fcnt0 <= (read_allow OR NOT fcounter(0));
--
---- With the constant FIFO memory size of 512 (ADDR_WIDTH = 9)
---- the bits from fcounter were used for control logic.
---- To keep the FIFO memory size a GENERIC they were
---- replaced by functions make_ored_bit(vect :in std_logic_vector, len :in integer) 
---- and make_anded_bit(vect :in std_logic_vector, len :in integer) 
--
----fcntandout(0) <= NOT (fcounter(4) OR fcounter(3) OR fcounter(2) OR fcounter(1) OR fcounter(0));
----fcntandout(1) <= NOT (fcounter(8) OR fcounter(7) OR fcounter(6) OR fcounter(5));
--
--fcntandout(0)	<= NOT ored_first_half_fcounter;		 -- ORIGINAL CHANGED see two lines above
--fcntandout(1)  <= NOT ored_second_half_fcounter;    -- ORIGNIAL CHANGED	see one line above
--
--emptyg <= (fcntandout(0) AND fcntandout(1) AND ra_or_fcnt0 AND NOT write_allow);
--
--proc3: PROCESS (clk, rst)
--BEGIN
--   IF (rst = '1') THEN
--      empty <= '1';
--   ELSIF (clk'EVENT AND clk = '1') THEN
--      empty <= emptyg;
--   END IF;
--END PROCESS proc3;
--
-----------------------------------------------------------------
----                                                           --
----  Full flag is set on rst (but it is cleared on the   --
----  first valid clk edge after rst is removed), or    --
----  when on the next clk cycle, Read Enable is low, and    --
----  either the FIFOcount is equal to 1FF (hex), or it is     --
----  equal to 1FE and the Write Enable is high (about to go   --
----  Full).                                                   --
----                                                           --
-----------------------------------------------------------------
--
--wa_or_fcnt0 <= (write_allow OR fcounter(0));
--
---- With the constant FIFO memory size of 512 (ADDR_WIDTH = 9)
---- the bits from fcounter were used for control logic.
---- To keep the FIFO memory size a GENERIC they were
---- replaced by functions make_ored_bit(vect :in std_logic_vector, len :in integer) 
---- and make_anded_bit(vect :in std_logic_vector, len :in integer) 
--
----fcntandout(2) <= (fcounter(4) AND fcounter(3) AND fcounter(2) AND fcounter(1));
----fcntandout(3) <= (fcounter(8) AND fcounter(7) AND fcounter(6) AND fcounter(5));
--
--
--  fcntandout(2) <= anded_first_half_fcounter;	  -- ORIGINAL CHANGED see two lines above
--  fcntandout(3) <= anded_second_half_fcounter;	  -- ORIGNIAL CHANGED	see one line above
--
--fullg <= (fcntandout(2) AND fcntandout(3) AND wa_or_fcnt0 AND NOT read_allow);
--
--proc4: PROCESS (clk, rst)
--BEGIN
--   IF (rst = '1') THEN
--      full <= '1';
--   ELSIF (clk'EVENT AND clk = '1') THEN
--      full <= fullg;
--   END IF;
--END PROCESS proc4;
--
------------------------------------------------------------------
----                                                            --
----  Generation of Read and Write address pointers.  They now  --
----  use binary counters, because it is simpler in simulation, --
----  and the previous LFSR implementation wasn't in the        --
----  critical path.                                            --
----                                                            --
------------------------------------------------------------------
--
--proc5: PROCESS (rst, clk)
--variable internal_synch :std_logic;
--BEGIN
--   IF (rst = '1') THEN
--      read_addr <= (others => '0');
--	ELSIF (clk'EVENT AND clk = '1') THEN
--		if (read_enable = '1') THEN
--		    read_addr <= read_addr + '1';
--			 internal_synch := '0';
--   	end if;
--		if internal_synch = '0' and 
--			write_enable_in = '1' and 
--			read_enable_in = '0' and 
--			(read_addr > write_addr) then
--			
--			read_addr <= write_addr;
--			internal_synch := '1';
--		end if;   
--	END IF;
--END PROCESS proc5;
--
--proc6: PROCESS (rst, clk)
--BEGIN
--   IF (rst = '1') THEN
--      write_addr <= (others => '0');
--	ELSIF (clk'EVENT AND clk = '1') THEN
--		IF (write_enable_in = '1' or read_enable_in = '1') THEN
--			if(write_addr = FIFO_SIZE -1) then
--				write_addr <= (others => '0');
--			else
--				write_addr <= write_addr + '1';
--			end if;
--		END IF;
--	END IF;
--END PROCESS proc6;
--
------------------------------------------------------------------
----                                                            --
----  Generation of FIFOcount outputs.  Used to determine how   --
----  full FIFO is, based on a counter that keeps track of how  --
----  many words are in the FIFO.  Also used to generate Full   --
----  and Empty flags.  Only the upper four bits of the counter --
----  are sent outside the module.                              --
----                                                            --
------------------------------------------------------------------
--
--proc7: PROCESS (rst, clk)
--BEGIN
--   IF (rst = '1') THEN
--      fcounter <= (others => '0');
--   ELSIF (clk'EVENT AND clk = '1') THEN
--      IF (fcnt_allow = '1') THEN
--	         IF (read_allow = '0') THEN
--	            fcounter <= fcounter + '1';
--	         ELSE
--            fcounter <= fcounter - '1';
--         END IF;
--      END IF;
--   END IF;
--END PROCESS proc7;
--
--
----======================================================================
----======================================================================
--
----set_internal_write_addr :process(write_addr, internal_write_counter, read_enable_in,
----											 write_data, dual_data_out)--, read_allow)
----
----begin
----
----	if (read_enable_in = '0') then --or read_allow) = '0' then
----
----		internal_write_addr <= write_addr;
----		internal_write_data <= write_data; -- write_data <==> write_data_in
----		write_offset        <= write_addr;
----	
----	else
----
----		internal_write_data <= dual_data_out;
----		internal_write_addr <= internal_write_counter;
----
----	end if;
----
----end process;
----
----======================================================================
----======================================================================
--
----set_internal_write_counter: PROCESS (rst, clk)
----BEGIN
----   IF (rst = '1') THEN
----      internal_write_counter <= (others => '0');
----   ELSIF (clk'EVENT AND clk = '1') THEN
----		if read_enable_in = '1' or read_allow = '1' then
----			
----			internal_write_counter <= internal_write_counter + 1;
----
----		else
----
----			internal_write_counter <= write_offset;
----
----		end if;
----
----	END IF;
----END PROCESS;
----
----======================================================================
----======================================================================
--

END behavioral;

