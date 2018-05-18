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
-- Create Date:    15:36:23 12/01/05
-- Design Name:    
-- Module Name:    feedback_fifo - Behavioral
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
-- This file was modified by Ericles Sousa on 10th Dec 2014. In this version
-- the depth can be programmable at runtime if via software, the 
-- "en_programmable_fd_depth" signal is 1. 
-- In the TCPA editor the user has to define the maximum depth for the FD Regs
-- and at runtime, it is possible to program each register individually.
-- So far, in our tests we are using the AMBA for interconnecting the TCPA 
-- to a RISC processor (LEON Core).
--
--------------------------------------------------------------------------------
library IEEE;
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.type_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity feedback_fifo is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME : string;
		-- cadence translate_on				
		LUT_RAM_TYPE  : std_logic                                                 := '1'; -- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
		DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH           := CUR_DEFAULT_DATA_WIDTH;
		ADDR_WIDTH    : positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH;
		FIFO_SIZE     : positive range MIN_FIFO_SIZE to MAX_FIFO_SIZE             := CUR_DEFAULT_FIFO_SIZE
	);

	port(clk                      : IN  std_logic;
		 rst                      : IN  std_logic;
		 en_programmable_fd_depth : IN  std_logic;
		 programmable_fd_depth    : in  std_logic_vector(15 downto 0);
		 read_enable_in           : IN  std_logic;
		 write_enable_in          : IN  std_logic;
		 write_data_in            : IN  std_logic_vector(DATA_WIDTH - 1 downto 0);
		 read_data_out            : OUT std_logic_vector(DATA_WIDTH - 1 downto 0)
	);

end feedback_fifo;

architecture Behavioral of feedback_fifo is
	signal dual_data_out       : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal read_enable         : std_logic;
	signal write_enable        : std_logic;
	signal memory_write_allow  : std_logic;
	signal read_data           : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal write_data          : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal full                : std_logic;
	signal empty               : std_logic;
	signal read_addr           : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal write_addr          : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal internal_write_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal read_allow          : std_logic;
	signal write_allow         : std_logic;

	--Ericles on 10th Dec 2014. New signal
	signal sig_en_programmable_fd_depth : std_logic;
	signal sig_programmable_fd_depth    : std_logic_vector(15 downto 0);

	component LUT_feedback_register is
		generic(
			-- cadence translate_off				
			INSTANCE_NAME : string;
			-- cadence translate_on				
			FIFO_SIZE     : positive range MIN_FIFO_SIZE to MAX_FIFO_SIZE             := CUR_DEFAULT_FIFO_SIZE;
			DATA_WIDTH    : positive range MIN_DATA_WIDTH to MAX_DATA_WIDTH           := CUR_DEFAULT_DATA_WIDTH;
			ADDR_WIDTH    : positive range MIN_FIFO_ADDR_WIDTH to MAX_FIFO_ADDR_WIDTH := CUR_DEFAULT_FIFO_ADDR_WIDTH
		);

		port(
			clk                   : in  std_logic;
			rst                   : in  std_logic;
			en_programmable_depth : in  std_logic;
			programmable_depth    : in  std_logic_vector(15 downto 0);
			we                    : in  std_logic;
			d_in                  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			d_out                 : out std_logic_vector(DATA_WIDTH - 1 downto 0)
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
	read_enable   <= read_enable_in;
	write_enable  <= write_enable_in;
	write_data    <= write_data_in;
	read_data_out <= read_data;
	dual_data_out <= read_data;

	memory_write_allow <= (write_enable_in or read_enable_in); -- or read_allow;


	CHECK_LUT_RAM_TYPE : IF LUT_RAM_TYPE = '1' GENERATE

		--------------------------------------------------------------------------
		-- 				LUT RAM instantiation for FIFO. 						--                                                                     --
		--------------------------------------------------------------------------

		LUT_RAM : LUT_feedback_register
			generic map(
				-- cadence translate_off					
				INSTANCE_NAME => INSTANCE_NAME & "/LUT_RAM",
				-- cadence translate_on	
				FIFO_SIZE     => FIFO_SIZE,
				DATA_WIDTH    => DATA_WIDTH,
				ADDR_WIDTH    => ADDR_WIDTH
			)
			port map(
				clk                   => clk,
				rst                   => rst,
				en_programmable_depth => en_programmable_fd_depth,
				programmable_depth    => programmable_fd_depth,
				we                    => memory_write_allow,
				d_in                  => internal_write_data,
				d_out                 => read_data
			);

	END GENERATE;

	CHECK_BLOCK_RAM_TYPE : IF LUT_RAM_TYPE = '0' GENERATE
		--------------------------------------------------------------------------
		-- 				BLOCK RAM instantiation for FIFO. 						--
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
				we         => memory_write_allow,
				write_addr => write_addr,
				read_addr  => read_addr,
				d_in       => internal_write_data,
				d_out      => read_data
			);

	END GENERATE;

	--Ericles 10th Dec 2014: Including "en_programmable_fd_depth" and "programmable_fd_depth" signals
	--Multiplexer for ouput data
	mux : process(sig_en_programmable_fd_depth, write_addr, sig_programmable_fd_depth)
	begin
		case (sig_en_programmable_fd_depth) is
			when '1' =>                 --enable
				if (to_integer(unsigned(write_addr)) < (to_integer(unsigned(sig_programmable_fd_depth(ADDR_WIDTH - 1 downto 0))) - 1)) then
					read_addr <= write_addr + 1;
				else
					read_addr <= (others => '0');
				end if;
			when '0' =>
				if (write_addr < FIFO_SIZE - 1) then
					read_addr <= write_addr + 1;
				else
					read_addr <= (others => '0');
				end if;

			when others =>
				null;
		end case;
	end process;

	sync : process(clk, en_programmable_fd_depth, sig_programmable_fd_depth)
	begin
		if rising_edge(clk) then
			sig_en_programmable_fd_depth <= en_programmable_fd_depth;
			sig_programmable_fd_depth <= sig_programmable_fd_depth;
		end if;
	end process;


	--	read_addr <= write_addr + 1 when write_addr < FIFO_SIZE - 1
	--		else (others => '0');
	--read_addr <= conv_std_logic_vector(conv_integer(write_addr + 1) mod FIFO_SIZE, ADDR_WIDTH);');

	----------------------------------------------------------------
	--                                                            --
	--  Generation of Read and Write address pointers.  They now  --
	--  use binary counters, because it is simpler in simulation, --
	--  and the previous LFSR implementation wasn't in the        --
	--  critical path.                                            --
	--                                                            --
	----------------------------------------------------------------

	--proc5: PROCESS (rst, clk)
	--variable internal_synch :std_logic;
	--BEGIN
	--   IF (rst = '1') THEN
	--      read_addr <= (others => '0');
	--	ELSIF (clk'EVENT AND clk = '1') THEN
	--		if (read_enable = '1') THEN
	--			if(read_addr < FIFO_SIZE -1) then
	--		    	read_addr <= read_addr + '1';
	--			 	internal_synch := '0';
	--			else
	--				read_Addr <= (others => '0');
	--				internal_synch := '0';
	--			end if;
	--   	end if;
	--		if internal_synch = '0' and 			  -- If new data is to be loaded into the FB fifo, the
	--			write_enable_in = '1' and 			  -- read address becomes one greater than the write address
	--			read_enable_in = '0' and 			  -- this leads to the fact, that one word is over-written
	--			(read_addr > write_addr) then		  -- BEFORE it could be read out. Therefore if such a case
	--														  -- arises, that new data has to be written, a care is taken,			
	--			read_addr <= write_addr;			  -- that in the case (read_addr > write_addr) the read_addr is
	--			internal_synch := '1';				  -- set to the write_addr, to prevent loss of one (new) data word.
	--		end if;   
	--	END IF;
	--END PROCESS proc5;

	proc6 : PROCESS(rst, clk)
	BEGIN
		IF (rst = '1') THEN
			write_addr <= (others => '0');
		ELSIF (clk'EVENT AND clk = '1') THEN
			--Ericles on 10th Dec 2014: Including programmable_fd_depth as upper bound and the condition for en_programmable_fd_depth
			if sig_en_programmable_fd_depth = '1' then --enable
				IF (write_enable_in = '1' or read_enable_in = '1') THEN
					if (to_integer(unsigned(write_addr)) = (to_integer(unsigned(sig_programmable_fd_depth(ADDR_WIDTH - 1 downto 0))) - 1)) then
						write_addr <= (others => '0');
					else
						if (to_integer(unsigned(write_addr)) < (to_integer(unsigned(sig_programmable_fd_depth(ADDR_WIDTH - 1 downto 0))) - 1)) then
							write_addr <= write_addr + '1';
						else
							write_addr <= (others => '0');
						end if;
					end if;
				END IF;

			else                        --disabled
				IF (write_enable_in = '1' or read_enable_in = '1') THEN
					if (write_addr = FIFO_SIZE - 1) then
						write_addr <= (others => '0');
					else
						if write_addr < FIFO_SIZE - 1 then
							write_addr <= write_addr + '1';
						else
							write_addr <= (others => '0');
						end if;
					end if;
				END IF;
			end if;

		end if;
	END PROCESS proc6;

	--======================================================================
	--======================================================================

	set_internal_write_data : process(write_data, dual_data_out, read_enable_in)
	begin
		if (write_enable_in = '1') then
			internal_write_data <= write_data;
		else
			internal_write_data <= dual_data_out;
		end if;
	end process;

--======================================================================
--======================================================================


end Behavioral;
	
