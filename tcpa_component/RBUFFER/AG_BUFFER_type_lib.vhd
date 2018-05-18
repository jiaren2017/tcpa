---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  
-- Project Name:  
--
-- Engineer:     Jupiter Bakakeu and Ericles Sousa 
-- Create Date:   
-- Description: 
--
--------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------
-- Copyright (C) 2014 by University of Erlangen-Nuremberg,
-- Department of Computer Science, Hardware/Software Co-Design, Germany.
-- All rights reserved.
--------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.math_real.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

package AG_BUFFER_type_lib is

	function log2_32bits(A: integer) return integer;
	function check_if_power_of_two(number: integer) return boolean;
	function ahb_addr_decoding(flag : std_logic_vector(2 downto 0); haddr : integer; hmask : integer) return std_logic_vector;
--	type cpu_tcpa_buffer_type is record
--		cpu_addr : std_logic_vector(31 downto 0);	
--		cpu_en   : std_logic;	
--		cpu_we   : std_logic;	
--	end record;
	--===============================================================================--		
	--             AG + RBUFFER CONFIGURATION TYPES
	--===============================================================================--		
	type t_ag_buffer_generics is record
		--###########################################################################
		-- TCPA_TOP parameters, do not add to or delete
		--###########################################################################
		DESIGN_TYPE			: integer range 0 to 7;
		--ENABLE_PIXEL_BUFFER_MODE	: integer range 0 to 31 ;
		ENABLE_PIXEL_BUFFER_MODE	: integer range 0 to 1 ;

		CONFIG_DATA_WIDTH               : integer range 0 to 32 ;
		CONFIG_ADDR_WIDTH               : integer range 0 to 32 ;

		CHANNEL_DATA_WIDTH              : integer range 0 to 32 ;
		CHANNEL_ADDR_WIDTH              : integer range 0 to 64 ; -- 2 * INDEX_VECTOR_DATA_WIDTH;
		CHANNEL_COUNT                   : integer range 0 to 32 ;

		AG_CONFIG_ADDR_WIDTH            : integer range 0 to 32 ; -- must be computed

		BUFFER_CONFIG_ADDR_WIDTH        : integer range 0 to 32 ; -- must be computed
		BUFFER_CONFIG_DATA_WIDTH        : integer range 0 to 32 ; -- must be allways set to 32
		BUFFER_ADDR_HEADER_WIDTH        : integer range 0 to 54 ; -- = 2 * INDEX_VECTOR_DATA_WIDTH - 10; -- Sice we are using 32x1kbits RAMs
		BUFFER_SEL_REG_WIDTH            : integer range 0 to 8  ; -- = log2(ADDR_HEADER_WIDTH)
		BUFFER_CSR_DELAY_SELECTOR_WIDTH : integer range 0 to 32 ; 

		AG_hindex                       : integer;
		AG_hirq                         : integer;
		AG_haddr                        : integer;
		AG_hmask                        : integer;
	end record;

	constant AHB_MSB_BIT_DECODE                         : integer;
	constant AHB_LSB_BIT_DECODE                         : integer;
	constant CHECK_FIRST_ADDR                           : std_logic_vector(2 downto 0);
	constant CHECK_lAST_ADDR                            : std_logic_vector(2 downto 0); 
	constant CHECK_FIRST_BUFFER_CONFIG_ADDR             : std_logic_vector(2 downto 0); 
	constant CHECK_LAST_BUFFER_CONFIG_ADDR              : std_logic_vector(2 downto 0); 
	constant CHECK_FIRST_BUFFER_ADDR                    : std_logic_vector(2 downto 0); 
	constant CHECK_LAST_BUFFER_ADDR                     : std_logic_vector(2 downto 0);
	constant CUR_DEFAULT_MAX_BUFFER_SIZE                : integer;
	constant CUR_DEFAULT_AG_BUFFER_CONFIG_SIZE          : integer;
	constant CUR_DEFAULT_BUFFER_ADDR_WIDTH              : integer;
	constant CONFIG_DATA_WIDTH                          : integer;
	constant CONFIG_ADDR_WIDTH                          : integer;
	constant CUR_DEFAULT_AG_BUFFER_NORTH                : t_ag_buffer_generics;
	constant CUR_DEFAULT_AG_BUFFER_WEST                 : t_ag_buffer_generics;
	constant CUR_DEFAULT_AG_BUFFER_SOUTH                : t_ag_buffer_generics;
	constant CUR_DEFAULT_AG_BUFFER_EAST                 : t_ag_buffer_generics;
	constant CUR_DEFAULT_NUM_OF_BUFFER_STRUCTURES       : integer;
	constant NUM_OF_BUFFER_CHANNELS                     : integer;
	constant CUR_DEFAULT_BUFFER_CHANNEL_SIZE            : integer;
	constant CUR_DEFAULT_BUFFER_CHANNEL_ADDR_WIDTH      : integer;
	constant CUR_DEFAULT_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean;
        constant CUR_DEFAULT_EN_ELASTIC_BUFFER              : boolean;
	constant BUFFER_CSR_DELAY_SELECTOR_WIDTH            : integer;
	constant CUR_DEFAULT_RBUFFER_HIRQ_AHB_INDEX         : integer;
	constant CUR_DEFAULT_RBUFFER_HIRQ_AHB_IRQ           : integer;
	constant CUR_DEFAULT_RBUFFER_HIRQ_AHB_ADDR          : integer;
	constant CUR_DEFAULT_RBUFFER_HIRQ_AHB_MASK          : integer;

	--===============================================================================--		
	--===============================================================================--		

end AG_BUFFER_type_lib;


package body AG_BUFFER_type_lib is
	
	function check_if_power_of_two(number: integer) return boolean is
	variable bound : integer;
	begin
	  for i in 1 to 32 loop  -- Works for up to 32 bit integers
		bound := (2**i);
		if (number = bound) then
			return true;
		elsif (bound > number) then
			return false;
		end if;
	  end loop;
	end function;

	function log2_32bits(A: integer) return integer is
	begin
	  for I in 1 to 30 loop  -- Works for up to 32 bit integers
	    if(2**I > A) then 
		return integer(I-1);  
		--return integer(I);  
	    end if;
	  end loop;
	end function;

	constant CUR_DEFAULT_NUM_OF_BUFFER_STRUCTURES       : integer := 4;
	constant NUM_OF_BUFFER_CHANNELS                     : integer := 4;
	constant CUR_DEFAULT_MAX_BUFFER_SIZE                : integer := 16*1024;--2**17; --the buffer size has to be a multiple of power of 2 (i.e., 1024, 2048, 4096, 8192, 16384, etc...)
	constant AG_BUFFER_CONFIG_SIZE                      : integer := 1024;
	constant CUR_DEFAULT_AG_BUFFER_CONFIG_SIZE          : integer := AG_BUFFER_CONFIG_SIZE;
	constant CUR_DEFAULT_BUFFER_ADDR_WIDTH              : integer := integer(ceil(log2(real(CUR_DEFAULT_MAX_BUFFER_SIZE))));
	constant CUR_DEFAULT_BUFFER_CHANNEL_SIZE            : integer := integer(ceil(real(CUR_DEFAULT_MAX_BUFFER_SIZE/NUM_OF_BUFFER_CHANNELS)));
	constant CUR_DEFAULT_BUFFER_CHANNEL_ADDR_WIDTH      : integer := integer(ceil(log2(real(CUR_DEFAULT_BUFFER_CHANNEL_SIZE))));
	constant CUR_DEFAULT_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean := check_if_power_of_two(CUR_DEFAULT_BUFFER_CHANNEL_SIZE);
	constant CUR_DEFAULT_EN_ELASTIC_BUFFER              : boolean := FALSE;
	constant BUFFER_CSR_DELAY_SELECTOR_WIDTH            : integer := 9;

	constant CUR_DEFAULT_RBUFFER_HIRQ_AHB_INDEX         : integer := 14;
	constant CUR_DEFAULT_RBUFFER_HIRQ_AHB_IRQ           : integer := 14;
	constant CUR_DEFAULT_RBUFFER_HIRQ_AHB_ADDR          : integer := 16#500#;
	constant CUR_DEFAULT_RBUFFER_HIRQ_AHB_MASK          : integer := 16#FFF#;

	constant BUS_ALIGNMENT_BITS                         : integer := 4; --Because the memory addresses on the bus are aligned to 4 bits, i.e., each memory address is incrememented every 4 bits. 
	constant AHB_MSB_BIT_DECODE                         : integer := 12;
	constant AHB_LSB_BIT_DECODE                         : integer := 19;
	constant FUNCTION_ERROR                             : std_logic_vector(31 downto 0) := (others=>'1');

	constant CHECK_FIRST_ADDR                           : std_logic_vector(2 downto 0) := "000";
	constant CHECK_lAST_ADDR                            : std_logic_vector(2 downto 0) := "001"; 
	constant CHECK_FIRST_BUFFER_CONFIG_ADDR             : std_logic_vector(2 downto 0) := "010"; 
	constant CHECK_LAST_BUFFER_CONFIG_ADDR              : std_logic_vector(2 downto 0) := "011"; 
	constant CHECK_FIRST_BUFFER_ADDR                    : std_logic_vector(2 downto 0) := "100"; 
	constant CHECK_LAST_BUFFER_ADDR                     : std_logic_vector(2 downto 0) := "101";

	--constant CONFIG_ADDR_WIDTH                          : integer := integer(ceil(log2(real(AG_BUFFER_CONFIG_SIZE))));
	constant CONFIG_ADDR_WIDTH                          : integer := integer(ceil(log2(real(CUR_DEFAULT_MAX_BUFFER_SIZE))));
	constant CONFIG_DATA_WIDTH                          : integer := 32;
	constant BUFFER_ADDR_WIDTH                          : integer := integer(ceil(log2(real(CUR_DEFAULT_MAX_BUFFER_SIZE))));
	constant BUFFER_DATA_WIDTH                          : integer := 32; 

	constant EN_PIXEL_BUFFER                            : integer range 0 to 1 := 1;
	constant BUFFER_MODE                                : integer range 0 to 1 := EN_PIXEL_BUFFER;

	--Ericles: This function decodes a set of addresses in the Bank Address Register of an AHB device.
        --Here, we also identify the address range of an AHB component. This function performs the following operation:
	--addr_offset = ((mask xor AHB_MASK) + 1) * AHB_ADDR_OFFSET
        --last_addr = first_addr + addr_offset
	function ahb_addr_decoding(flag           : std_logic_vector(2 downto 0); haddr : integer; hmask : integer) return std_logic_vector is
		constant AHB_ADDR_OFFSET          : integer := 2**20; -- 1 MByte is the minimum address range occupied by an AHB memory bank as defined by AMBA 2.0
		constant AHB_MASK                 : std_logic_vector(AHB_MSB_BIT_DECODE-1 downto 0) := x"FFF";

		variable first_addr               : std_logic_vector(31 downto 0);
		variable last_addr                : std_logic_vector(31 downto 0);

		variable first_buffer_config_addr : std_logic_vector(31 downto 0);
		variable last_buffer_config_addr  : std_logic_vector(31 downto 0);

		variable first_buffer_addr        : std_logic_vector(31 downto 0);
		variable last_buffer_addr         : std_logic_vector(31 downto 0);

		variable bar_mask                 : std_logic_vector(AHB_MSB_BIT_DECODE-1 downto 0);
		variable addr_offset              : integer;
	begin
		first_addr := (others=>'0');
		first_addr(31 downto 20) := std_logic_vector(to_unsigned(haddr, 12));
		case (flag) is
			when  CHECK_FIRST_ADDR =>
				return std_logic_vector(first_addr);

			when  CHECK_lAST_ADDR =>
				bar_mask    := std_logic_vector(to_unsigned(hmask, 12)) xor AHB_MASK;
				addr_offset := to_integer(unsigned(bar_mask) + 1) * AHB_ADDR_OFFSET;
		                last_addr   := first_addr or std_logic_vector(to_unsigned(addr_offset, 32));
				return std_logic_vector(last_addr);

			when CHECK_FIRST_BUFFER_CONFIG_ADDR =>
				first_buffer_config_addr := first_addr;
				return std_logic_vector(first_buffer_config_addr);

			when CHECK_LAST_BUFFER_CONFIG_ADDR =>
				last_buffer_config_addr := first_addr or (std_logic_vector(to_unsigned((AG_BUFFER_CONFIG_SIZE*BUS_ALIGNMENT_BITS)-1, 32)));
				return std_logic_vector(last_buffer_config_addr);

			when CHECK_FIRST_BUFFER_ADDR =>
				first_buffer_addr := first_addr or (std_logic_vector(to_unsigned(AG_BUFFER_CONFIG_SIZE*BUS_ALIGNMENT_BITS, 32)));
				return std_logic_vector(first_buffer_addr);

			when CHECK_LAST_BUFFER_ADDR =>
				last_buffer_addr := first_addr or (std_logic_vector(to_unsigned((AG_BUFFER_CONFIG_SIZE+CUR_DEFAULT_MAX_BUFFER_SIZE)*BUS_ALIGNMENT_BITS-1, 32)));
				return std_logic_vector(last_buffer_addr);
	
			when others =>
				return std_logic_vector(FUNCTION_ERROR);
		end case;
	end function;

	

	CONSTANT CUR_DEFAULT_AG_BUFFER_NORTH : t_ag_buffer_generics := (
		0,       -- DESIGN_TYPE
		BUFFER_MODE,       -- ENABLE_PIXEL_BUFFER_MODE
		CONFIG_DATA_WIDTH, --32,      -- CONFIG_DATA_WIDTH
		CONFIG_ADDR_WIDTH, --10,      -- CONFIG_ADDR_WIDTH

		CONFIG_DATA_WIDTH, --32,      -- CHANNEL_DATA_WIDTH
		AHB_LSB_BIT_DECODE, --CONFIG_ADDR_WIDTH, --18,      -- CHANNEL_ADDR_WIDTH
		CUR_DEFAULT_NUM_WPPE_HORIZONTAL, --4,       -- CHANNEL_COUNT,                     --Ericles: it has to be equal to the number of HORIZONTAL PEs

		CONFIG_ADDR_WIDTH, --8,       -- AG_CONFIG_ADDR_WIDTH

		BUFFER_ADDR_WIDTH, --CONFIG_ADDR_WIDTH, --8,       -- BUFFER_CONFIG_ADDR_WIDTH 
		BUFFER_DATA_WIDTH,            -- BUFFER_CONFIG_DATA_WIDTH
		CUR_DEFAULT_BUFFER_ADDR_WIDTH,       -- BUFFER_ADDR_HEADER_WIDTH
		4,       -- BUFFER_SEL_REG_WIDTH
		BUFFER_CSR_DELAY_SELECTOR_WIDTH,

		3, --5, --10,      -- AG_hindex
		3,       -- AG_hirq
		16#850#, -- AG_haddr
		16#FFC#  -- AG_hmask
	);


	CONSTANT CUR_DEFAULT_AG_BUFFER_WEST : t_ag_buffer_generics := (
		0,       -- DESIGN_TYPE
		BUFFER_MODE,       -- ENABLE_PIXEL_BUFFER_MODE
		CONFIG_DATA_WIDTH, --32,      -- CONFIG_DATA_WIDTH
		CONFIG_ADDR_WIDTH, --10,      -- CONFIG_ADDR_WIDTH
                                                            
		CONFIG_DATA_WIDTH, --32,      -- CHANNEL_DATA_WIDTH
		AHB_LSB_BIT_DECODE, --CONFIG_ADDR_WIDTH, --18,      -- CHANNEL_ADDR_WIDTH
		CUR_DEFAULT_NUM_WPPE_VERTICAL, --4,       -- CHANNEL_COUNT,                     --Ericles: it has to be equal to the number of VERTICAL PEs
                                                            
		CONFIG_ADDR_WIDTH, --8,       -- AG_CONFIG_ADDR_WIDTH
                                                            
		BUFFER_ADDR_WIDTH, --CONFIG_ADDR_WIDTH, --8,       -- BUFFER_CONFIG_ADDR_WIDTH 
		BUFFER_DATA_WIDTH,             -- BUFFER_CONFIG_DATA_WIDTH
		CUR_DEFAULT_BUFFER_ADDR_WIDTH,       -- BUFFER_ADDR_HEADER_WIDTH
		4,       -- BUFFER_SEL_REG_WIDTH
		BUFFER_CSR_DELAY_SELECTOR_WIDTH,
                                                            
		5, --6,--4,       -- AG_hindex
		5,       -- AG_hirq
		16#860#, -- AG_haddr
		16#FFC#  -- AG_hmask
	);
	
	CONSTANT CUR_DEFAULT_AG_BUFFER_SOUTH : t_ag_buffer_generics := (
		0,       -- DESIGN_TYPE
		BUFFER_MODE,       -- ENABLE_PIXEL_BUFFER_MODE
		CONFIG_DATA_WIDTH, --32,      -- CONFIG_DATA_WIDTH
		CONFIG_ADDR_WIDTH, --10,      -- CONFIG_ADDR_WIDTH
                                                            
		CONFIG_DATA_WIDTH, --32,      -- CHANNEL_DATA_WIDTH
		AHB_LSB_BIT_DECODE, --CONFIG_ADDR_WIDTH, --18,      -- CHANNEL_ADDR_WIDTH
		CUR_DEFAULT_NUM_WPPE_HORIZONTAL, --4,       -- CHANNEL_COUNT,                     --Ericles: it has to be equal to the number of HORIZONTAL PEs
                                                            
		CONFIG_ADDR_WIDTH, --8,       -- AG_CONFIG_ADDR_WIDTH
                                                            
		BUFFER_ADDR_WIDTH, --CONFIG_ADDR_WIDTH, --8,       -- BUFFER_CONFIG_ADDR_WIDTH 
		BUFFER_DATA_WIDTH,            -- BUFFER_CONFIG_DATA_WIDTH
		CUR_DEFAULT_BUFFER_ADDR_WIDTH,       -- BUFFER_ADDR_HEADER_WIDTH
		4,       -- BUFFER_SEL_REG_WIDTH
		BUFFER_CSR_DELAY_SELECTOR_WIDTH,
                                                            
		7, --7, --5,       -- AG_hindex
		7,       -- AG_hirq
		16#870#, -- AG_haddr
		16#FFC#  -- AG_hmask
	);
	
	CONSTANT CUR_DEFAULT_AG_BUFFER_EAST : t_ag_buffer_generics := (
		0,       -- DESIGN_TYPE
		BUFFER_MODE,       -- ENABLE_PIXEL_BUFFER_MODE
		CONFIG_DATA_WIDTH, --32,      -- CONFIG_DATA_WIDTH
		CONFIG_ADDR_WIDTH, --10,      -- CONFIG_ADDR_WIDTH
                                                            
		CONFIG_DATA_WIDTH, --32       --CHANNEL_DATA_WIDTH
		AHB_LSB_BIT_DECODE, --CONFIG_ADDR_WIDTH, --18,      -- CHANNEL_ADDR_WIDTH
		CUR_DEFAULT_NUM_WPPE_VERTICAL, --4,       -- CHANNEL_COUNT,                     --Ericles: it has to be equal to the number of VERTICAL PEs
                                                            
		CONFIG_ADDR_WIDTH, --8,       -- AG_CONFIG_ADDR_WIDTH
                                                            
		BUFFER_ADDR_WIDTH, --CONFIG_ADDR_WIDTH, --8,       -- BUFFER_CONFIG_ADDR_WIDTH 
		BUFFER_DATA_WIDTH,            -- BUFFER_CONFIG_DATA_WIDTH
		CUR_DEFAULT_BUFFER_ADDR_WIDTH,       -- BUFFER_ADDR_HEADER_WIDTH
		4,       -- BUFFER_SEL_REG_WIDTH
		BUFFER_CSR_DELAY_SELECTOR_WIDTH,
                                                            
		9, --8, --6,       -- AG_hindex
		9,       -- AG_hirq
		16#880#, -- AG_haddr
		16#FFC#  -- AG_hmask
	);

	--===============================================================================--		
	--===============================================================================--		

end AG_BUFFER_type_lib;


