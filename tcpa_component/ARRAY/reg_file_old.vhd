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
-- Module Name:    reg_file - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.type_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;

library STD;
use STD.textio.all;
use IEEE.std_logic_textio.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_file is
	generic(
		-- cadence translate_off	
		INSTANCE_NAME             : string                                                   := "?";
		-- cadence translate_on			  
		--*******************************************************************************--
		-- GENERICS FOR THE NUMBER OF READ AND WRITE PORTS TO REGISTER FILE
		--*******************************************************************************--

		NUM_OF_READ_PORTS         : positive range 1 to MAX_NUM_MEM_READ_PORTS               := CUR_DEFAULT_NUM_MEM_READ_PORTS;
		NUM_OF_WRITE_PORTS        : positive range 1 to MAX_NUM_MEM_WRITE_PORTS              := CUR_DEFAULT_NUM_MEM_WRITE_PORTS;

		--*******************************************************************************--
		-- GENERICS FOR THE NUMBER OF GENERAL PURPOSE, INPUT, AND OUTPUT REGISTERS --
		--*******************************************************************************--

		GEN_PUR_REG_NUM           : integer range 0 to MAX_GEN_PUR_REG_NUM                   := CUR_DEFAULT_GEN_PUR_REG_NUM;

		NUM_OF_OUTPUT_REG         : integer range 0 to MAX_OUTPUT_REG_NUM                    := CUR_DEFAULT_OUTPUT_REG_NUM;
		NUM_OF_INPUT_REG          : integer range 0 to MAX_INPUT_REG_NUM                     := CUR_DEFAULT_INPUT_REG_NUM;

		BEGIN_OUTPUT_REGS         : integer range 0 to MAX_GEN_PUR_REG_NUM                   := CUR_DEFAULT_GEN_PUR_REG_NUM;
		END_OUTPUT_REGS           : integer range 0 to MAX_GEN_PUR_REG_NUM                   := CUR_DEFAULT_GEN_PUR_REG_NUM + CUR_DEFAULT_OUTPUT_REG_NUM - 1;

		--*******************************************************************************--
		-- GENERICS FOR THE NUMBER AND SIZE OF additional FIFOs --
		--*******************************************************************************--

		NUM_OF_FEEDBACK_FIFOS     : integer range 0 to MAX_NUM_FB_FIFO                       := CUR_DEFAULT_NUM_FB_FIFO;
		-- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
		TYPE_OF_FEEDBACK_FIFO_RAM : std_logic_vector(CUR_DEFAULT_NUM_FB_FIFO downto 0)       := (others => '1');
		SIZES_OF_FEEDBACK_FIFOS   : t_fifo_sizes(CUR_DEFAULT_NUM_FB_FIFO downto 0)           := (others => CUR_DEFAULT_FIFO_SIZE);

		FB_FIFOS_ADDR_WIDTH       : t_fifo_sizes(CUR_DEFAULT_NUM_FB_FIFO downto 0)           := (others => CUR_DEFAULT_FIFO_ADDR_WIDTH);

		-- When LUT_RAM_TYPE = '1' => LUT_RAM, else BLOCK_RAM
		TYPE_OF_INPUT_FIFO_RAM    : std_logic_vector(CUR_DEFAULT_INPUT_REG_NUM - 1 downto 0) := (others => '1');
		SIZES_OF_INPUT_FIFOS      : t_fifo_sizes(CUR_DEFAULT_INPUT_REG_NUM - 1 downto 0)     := (others => CUR_DEFAULT_FIFO_SIZE);
		INPUT_FIFOS_ADDR_WIDTH    : t_fifo_sizes(CUR_DEFAULT_INPUT_REG_NUM - 1 downto 0)     := (others => CUR_DEFAULT_FIFO_ADDR_WIDTH);

		--*******************************************************************************--
		-- GENERICS FOR THE REGISTER WIDTH --
		--*******************************************************************************--
		GEN_PUR_REG_WIDTH         : positive range 1 to MAX_GEN_PUR_REG_WIDTH                := CUR_DEFAULT_DATA_WIDTH; --CUR_DEFAULT_GEN_PUR_REG_WIDTH;

		--*******************************************************************************--
		-- GENERICS FOR THE ADDRESS AND DATA WIDTHS
		--*******************************************************************************--

		DATA_WIDTH                : positive range 1 to MAX_DATA_WIDTH                       := CUR_DEFAULT_DATA_WIDTH;
		REG_FILE_ADDR_WIDTH       : positive range 1 to MAX_REG_FILE_ADDR_WIDTH              := CUR_DEFAULT_REG_FILE_ADDR_WIDTH
	);

	port(

		--### SRECO PORTS: ###
		config_reg_data          : out std_logic_vector(CUR_DEFAULT_CONFIG_REG_WIDTH - 1 downto 0);
		config_reg_addr          : out std_logic_vector(2 downto 0);
		config_reg_we            : out std_logic;

		read_addresses_vector    : in  std_logic_vector(REG_FILE_ADDR_WIDTH * NUM_OF_READ_PORTS - 1 downto 0);
		read_data_vector         : out std_logic_vector(DATA_WIDTH * NUM_OF_READ_PORTS - 1 downto 0);

		write_addresses_vector   : in  std_logic_vector(REG_FILE_ADDR_WIDTH * NUM_OF_WRITE_PORTS - 1 downto 0);
		write_data_vector        : in  std_logic_vector(DATA_WIDTH * NUM_OF_WRITE_PORTS - 1 downto 0);

		wes                      : in  std_logic_vector(NUM_OF_WRITE_PORTS downto 1);

		input_registers          : in  std_logic_vector(DATA_WIDTH * NUM_OF_INPUT_REG - 1 downto 0);
		output_registers         : out std_logic_vector(DATA_WIDTH * NUM_OF_OUTPUT_REG - 1 downto 0);

		input_fifos_write_en     : in  std_logic_vector(NUM_OF_INPUT_REG - 1 downto 0);
		en_programmable_fd_depth : in  t_en_programmable_input_fd_depth;
		programmable_fd_depth    : in  t_programmable_input_fd_depth;
		rst_fd_regs              : in  std_logic;
		clk, rst                 : in  std_logic
	);

end reg_file;

architecture Behavioral of reg_file is
	CONSTANT OUTPUT_PIN_SEL_WIDTH : positive := log_width(NUM_OF_WRITE_PORTS + 1);
	CONSTANT INPUT_FIFO_OFFSET    : positive := (GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG);
	CONSTANT FB_FIFO_OFFSET       : positive := (GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG + NUM_OF_INPUT_REG);

	--### SRECO: COMMON OFFSET = REGFILE SIZE
	CONSTANT RF_OFFSET : positive := (GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG + NUM_OF_INPUT_REG + NUM_OF_FEEDBACK_FIFOS);

	type ram_type is array (integer range 0 to GEN_PUR_REG_NUM + NUM_OF_OUTPUT_REG - 1) of std_logic_vector(GEN_PUR_REG_WIDTH - 1 downto 0);

	-- FULL REGISTER FILE ADDR_WIDTH (GEN_PUR REGISTER + OUTPUT_REG + INPUT_REG(FIFO) + FEEDBACK FIFOS)
	type t_addr_array is array (integer range <>) of std_logic_vector(REG_FILE_ADDR_WIDTH - 1 downto 0);
	type t_data_array is array (integer range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	type t_output_pin_data is array (integer range <>) of std_logic_vector((NUM_OF_WRITE_PORTS + 1) * GEN_PUR_REG_WIDTH - 1 downto 0);

	type t_out_pins_sel is array (integer range <>) of std_logic_vector(OUTPUT_PIN_SEL_WIDTH - 1 downto 0);

	--===============================================================================--
	-- WPPE MULTIPLEXER FOR THE OUTPUT PINS COMPONENT DECLARATION --
	--===============================================================================--

	component wppe_multiplexer is
		generic(
			-- cadence translate_off			
			INSTANCE_NAME     : string;
			-- cadence translate_on	
			INPUT_DATA_WIDTH  : positive range 1 to 64; --:= 16;
			OUTPUT_DATA_WIDTH : positive range 1 to 64; --:= 16;
			SEL_WIDTH         : positive range 1 to 16; --:= 2;		
			NUM_OF_INPUTS     : positive range 1 to 64 -- := 4

		);

		port(
			data_inputs : in  std_logic_vector(INPUT_DATA_WIDTH * NUM_OF_INPUTS - 1 downto 0);
			sel         : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			output      : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
		);

	end component;

	--===============================================================================--
	-- FIFO COMMON CLOCK COMPONENT DECLARATION --
	--===============================================================================--
	component fifo_common_clock is
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
			 read_data_out   : OUT std_logic_vector(DATA_WIDTH - 1 downto 0);
			 full_out        : OUT std_logic;
			 empty_out       : OUT std_logic
		);

	END component;

	--===============================================================================--
	--===============================================================================--


	--===============================================================================--
	-- FEED-BACK FIFO COMPONENT DECLARATION --
	--===============================================================================--
	component feedback_fifo is
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

	end component;

	--===============================================================================--
	--===============================================================================--

	CONSTANT ZERO_VECTOR : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

	signal output_pin_data : t_output_pin_data(1 to NUM_OF_OUTPUT_REG);
	signal out_pins_sel    : t_out_pins_sel(1 to NUM_OF_OUTPUT_REG);

	--Ericles: initializing the register as '0'. The TCPA architecture has a limitation and does not 
	--support negative values as immediate assingment in the wppe editor. 
	signal register_file : ram_type := (
		others => (others => '0')
	);

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	-- Conversion of the entity in/out (wide) std_logic_vector(DATA_WIDTH/REG_FILE_ADDR_WIDTH * NUM_OF ... downto 0) signals 
	-- to array of std_logic_vectors(DATA_WIDTH/REG_FILE_ADDR_WIDTH -1 downto 0) indexed with 1 to NUM_OF ...
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	-- Internal array of read addresses und read data grouped to an array for CONVIENIENCE

	signal read_addresses : t_addr_array(1 to NUM_OF_READ_PORTS);
	signal read_data      : t_data_array(1 to NUM_OF_READ_PORTS);

	-- Internal array of write addresses und write data grouped to an array for CONVIENIENCE

	signal write_addresses : t_addr_array(1 to NUM_OF_WRITE_PORTS);
	signal write_data      : t_data_array(1 to NUM_OF_WRITE_PORTS);

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	-- Internal signals for INPUT FIFOS
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	signal input_fifos_read_en : std_logic_vector(NUM_OF_INPUT_REG + INPUT_FIFO_OFFSET - 1 downto INPUT_FIFO_OFFSET);

	signal input_fifos_write_data  : t_data_array(INPUT_FIFO_OFFSET to NUM_OF_INPUT_REG + INPUT_FIFO_OFFSET - 1);
	signal input_fifos_read_data   : t_data_array(INPUT_FIFO_OFFSET to NUM_OF_INPUT_REG + INPUT_FIFO_OFFSET - 1);
	signal input_fifos_full_flags  : std_logic_vector(NUM_OF_INPUT_REG - 1 downto 0);
	signal input_fifos_empty_flags : std_logic_vector(NUM_OF_INPUT_REG - 1 downto 0);

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	-- Internal signals for FEED-BACK FIFOS
	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	signal FEED_BACK_fifos_read_en : std_logic_vector(NUM_OF_FEEDBACK_FIFOS + FB_FIFO_OFFSET -- -1 
		                                              downto FB_FIFO_OFFSET);

	signal FEED_BACK_fifos_write_en : std_logic_vector(NUM_OF_FEEDBACK_FIFOS + FB_FIFO_OFFSET -- -1 
		                                               downto FB_FIFO_OFFSET);
	signal FEED_BACK_fifos_write_data : t_data_array(FB_FIFO_OFFSET to NUM_OF_FEEDBACK_FIFOS + FB_FIFO_OFFSET -- -1
	);
	signal FEED_BACK_fifos_read_data : t_data_array(FB_FIFO_OFFSET to NUM_OF_FEEDBACK_FIFOS + FB_FIFO_OFFSET -- - 1
	);

--#########
--#########
BEGIN                                   --###
	--#########
	--#########

	CHECK_OUTPUT_NOT_REGISTERED : IF NOT OUTPUT_REGISTERED GENERATE

		-- Multiplexed write_ports data + output_register data for the output pins
		CNN_OUT_WES : FOR i in 1 to NUM_OF_OUTPUT_REG GENERATE
			output_pin_data(i) <= write_data_vector & register_file(i + BEGIN_OUTPUT_REGS - 1)(GEN_PUR_REG_WIDTH - 1 downto 0);

		END GENERATE;

		OUT_PINS_MUX_GEN : FOR i in 1 to NUM_OF_OUTPUT_REG GENERATE
			out_pin_mux : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/out_pin_mux_" & Int_to_string(i),
					-- cadence translate_on	
					INPUT_DATA_WIDTH  => GEN_PUR_REG_WIDTH,
					OUTPUT_DATA_WIDTH => GEN_PUR_REG_WIDTH,
					SEL_WIDTH         => OUTPUT_PIN_SEL_WIDTH,
					NUM_OF_INPUTS     => (NUM_OF_WRITE_PORTS + 1)
				)
				port map(
					data_inputs => output_pin_data(i),
					sel         => out_pins_sel(i),
					output      => output_registers(GEN_PUR_REG_WIDTH * i - 1 downto GEN_PUR_REG_WIDTH * (i - 1))
				);

		END GENERATE;

	END GENERATE CHECK_OUTPUT_NOT_REGISTERED;

	CHECK_OUTPUT_REGISTERED : IF OUTPUT_REGISTERED GENERATE
		---- Connect the output pins to the output REGISTERS --> see Alexey's simulator
		----!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		---- Connect the output pins to the output REGISTERS --> see Alexey's simulator
		----!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


		CNN_OUT_PINS : FOR i IN 0 to NUM_OF_OUTPUT_REG - 1 GENERATE
			output_registers(DATA_WIDTH * (i + 1) - 1 downto DATA_WIDTH * (i)) <= register_file(i + BEGIN_OUTPUT_REGS); -- OR ZERO_VECTOR;								 		

		END GENERATE;

	-- Connect the output pins to the output REGISTERS --> see Alexey's simulator
	----!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	---- Connect the output pins to the output REGISTERS --> see Alexey's simulator
	----!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--
	END GENERATE CHECK_OUTPUT_REGISTERED;

	--===============================================================================--
	--===============================================================================--
	-- Generating the INPUT FIFOS

	CHECK_INPUT_FIFO_NUM : IF (NUM_OF_INPUT_REG > 0) GENERATE
		input_fifos : FOR i in NUM_OF_INPUT_REG - 1 + INPUT_FIFO_OFFSET downto INPUT_FIFO_OFFSET GENERATE
			in_fifo : fifo_common_clock
				generic map(
					-- cadence translate_off						
					INSTANCE_NAME => INSTANCE_NAME & "/in_fifo_" & Int_to_string(i),
					-- cadence translate_on	
					LUT_RAM_TYPE  => TYPE_OF_INPUT_FIFO_RAM(i - INPUT_FIFO_OFFSET),
					DATA_WIDTH    => GEN_PUR_REG_WIDTH,
					ADDR_WIDTH    => INPUT_FIFOS_ADDR_WIDTH(i - INPUT_FIFO_OFFSET),
					FIFO_SIZE     => SIZES_OF_INPUT_FIFOS(i - INPUT_FIFO_OFFSET)
				)
				port map(
					clk             => clk,
					rst             => rst,
					read_enable_in  => input_fifos_read_en(i),
					write_enable_in => input_fifos_write_en(i - INPUT_FIFO_OFFSET),
					write_data_in   => input_fifos_write_data(i),
					read_data_out   => input_fifos_read_data(i),
					full_out        => input_fifos_full_flags(i - INPUT_FIFO_OFFSET),
					empty_out       => input_fifos_empty_flags(i - INPUT_FIFO_OFFSET)
				);

		END GENERATE input_fifos;

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- Generating the FEED-BACK FIFOS

	CHECK_FEEDBACK_FIFO_NUM : IF (NUM_OF_FEEDBACK_FIFOS > 0) GENERATE
		feedback_fifos : FOR i in NUM_OF_FEEDBACK_FIFOS - 1 + FB_FIFO_OFFSET downto FB_FIFO_OFFSET GENERATE
			fb_fifo : feedback_fifo
				generic map(
					-- cadence translate_off					
					INSTANCE_NAME => INSTANCE_NAME & "/fb_fifo_" & Int_to_string(i),
					-- cadence translate_on					   
					LUT_RAM_TYPE  => TYPE_OF_FEEDBACK_FIFO_RAM(i - FB_FIFO_OFFSET),
					DATA_WIDTH    => GEN_PUR_REG_WIDTH,
					ADDR_WIDTH    => FB_FIFOS_ADDR_WIDTH(i - FB_FIFO_OFFSET),
					FIFO_SIZE     => SIZES_OF_FEEDBACK_FIFOS(i - FB_FIFO_OFFSET)
				)
				port map(
					clk                      => clk,
					rst                      => rst_fd_regs,
					en_programmable_fd_depth => en_programmable_fd_depth(i - FB_FIFO_OFFSET),
					programmable_fd_depth    => programmable_fd_depth(i - FB_FIFO_OFFSET),
					read_enable_in           => FEED_BACK_fifos_read_en(i),
					write_enable_in          => FEED_BACK_fifos_write_en(i),
					write_data_in            => FEED_BACK_fifos_write_data(i),
					read_data_out            => FEED_BACK_fifos_read_data(i)
				);

		END GENERATE feedback_fifos;

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- Assign the input_registers entity input to the inputs of INPUT FIFOS

	in_fifo_wr_data : FOR i in 1 to NUM_OF_INPUT_REG GENERATE
		input_fifos_write_data(i + INPUT_FIFO_OFFSET - 1) <= input_registers(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- Assign the read addresses from input vector to the INTERNAL read addresses array 

	rd_addr : FOR i in 1 to NUM_OF_READ_PORTS GENERATE
		read_addresses(i) <= read_addresses_vector(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- !!!! Assign the read data from internal read data array to the EXternal read data vector !!!

	rd_data : FOR i in 1 to NUM_OF_READ_PORTS GENERATE
		read_data_vector(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1)) <= read_data(i);

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- Assign the write addresses from input vector to the INTERNAL write addresses array 

	wr_addr : FOR i in 1 to NUM_OF_WRITE_PORTS GENERATE
		write_addresses(i) <= write_addresses_vector(REG_FILE_ADDR_WIDTH * i - 1 downto REG_FILE_ADDR_WIDTH * (i - 1));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- Assign the write data from input vector to the INTERNAL write data array 

	wr_data : FOR i in 1 to NUM_OF_WRITE_PORTS GENERATE
		write_data(i) <= write_data_vector(DATA_WIDTH * i - 1 downto DATA_WIDTH * (i - 1));

	END GENERATE;

	--===============================================================================--
	--===============================================================================--
	-- 1. WRITING AND READING PROCESSES
	--===============================================================================--
	--===============================================================================--


	--===============================================================================--
	-- Writing to the FEEDBACK FIFOs 
	--===============================================================================--

	write_fb_fifo : process(wes, write_addresses, write_data)

		-- shravan : for debug
		-- variable s : line;

		--variable cur_write_address :integer range 0 to FB_FIFO_OFFSET + NUM_OF_FEEDBACK_FIFOS -1;
		variable cur_write_address : integer; --range 0 to RF_OFFSET + 4;
		variable cur_fb_address    : integer; -- range FB_FIFO_OFFSET + NUM_OF_FEEDBACK_FIFOS - 1 downto FB_FIFO_OFFSET;

	begin

		-- Set the write_en signals for the FB FIFOS
		-- all to '0', because
		-- the functional unit that has set the write_en to '1' in
		-- the last clock cycle cannot by iself set it to '0' in
		-- the next clock cycle, because the address for
		-- the operands has already changed


		FEED_BACK_fifos_write_en   <= (others => '0');
		FEED_BACK_fifos_write_data <= (others => (others => '0'));

		FOR i IN 1 to NUM_OF_WRITE_PORTS LOOP

			---- shravan : for debug
			--         write(s,write_addresses_vector);
			--         writeline(output,s);

			--
			cur_write_address := conv_integer(write_addresses(i));

			if wes(i) = '1' then

				--==========================================================	
				if (cur_write_address >= FB_FIFO_OFFSET) and (cur_write_address < RF_OFFSET) then

					-- ==> WRITE intension to the FEEDBACK FIFOS
					--==========================================================	

					-- To ensure the synthesis tool that the array is
					-- not accessed with an index greater than the array size
					-- a constrained variable cur_FB_address is introduced,
					-- which only can take values in the array size

					cur_fb_address := cur_write_address;

					FEED_BACK_fifos_write_en(cur_fb_address) <= '1';

					FEED_BACK_fifos_write_data(cur_fb_address) <= write_data(i)(GEN_PUR_REG_WIDTH - 1 downto 0);

				--				else -- cur_write_address < FB_FIFO_OFFSET
				--					
				--					FEED_BACK_fifos_write_en   <= (others => '0');
				--					FEED_BACK_fifos_write_data <= (others => (others => '0'));				
				--					
				end if;
			--
			--			else	 -- we(i) = '0'
			--
			--					FEED_BACK_fifos_write_en   <= (others => '0');
			--					FEED_BACK_fifos_write_data <= (others => (others => '0'));				
			--					
			end if;

		END LOOP;

	end process write_fb_fifo;

	--===============================================================================--
	--===============================================================================--

	writing : process(clk)

		--variable cur_write_address :integer range 0 to FB_FIFO_OFFSET + NUM_OF_FEEDBACK_FIFOS -1;
		variable cur_write_address       : integer range 0 to RF_OFFSET + 4;
		variable cur_gen_pur_reg_address : integer range 0 to INPUT_FIFO_OFFSET - 1;

	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				--Ericles
				register_file <= (others => (others => '0'));

			else
				FOR i IN 1 to NUM_OF_WRITE_PORTS LOOP
					cur_write_address := conv_integer(write_addresses(i));

					if wes(i) = '1' then

						--==========================================================	
						if (cur_write_address < INPUT_FIFO_OFFSET) then

							-- ==> WRITE to the GENERAL PURPOSE/OUTPUT REGISTERS
							--==========================================================	

							-- To ensure the synthesis tool that the array is
							-- not accessed with an index greater than the array size
							-- a constrained variable cur_GEN_PUR_REG_address is introduced,
							-- which only can take values lying in the array size

							cur_gen_pur_reg_address := cur_write_address;

							register_file(cur_gen_pur_reg_address) <= write_data(i)(GEN_PUR_REG_WIDTH - 1 downto 0);

						end if;         --==: if (cur_write_address < INPUT_FIFO_OFFSET)
					end if;             --==: 	if wes(i) = '1'

				END LOOP;

			end if;

		end if;

	end process writing;

	--===========================================================================================
	--===========================================================================================

	--Writing to the OUTPUT PINS

	write_output : process(wes, write_data, write_addresses)
		variable write_address     : integer range 0 to MAX_GEN_PUR_REG_NUM;
		variable cur_write_address : integer range 0 to MAX_GEN_PUR_REG_NUM;

	begin

		-- Connect to the saved OUTPUT REGISTERS' VALUES!!!
		--
		FOR i IN 1 to NUM_OF_OUTPUT_REG LOOP
			out_pins_sel(i) <= (others => '0');

		END LOOP;

		FOR i IN 1 to NUM_OF_WRITE_PORTS LOOP
			cur_write_address := conv_integer(write_addresses(i));

			if wes(i) = '1' then
				write_address := conv_integer(write_addresses(i));

				if (BEGIN_OUTPUT_REGS <= write_address and write_address <= END_OUTPUT_REGS) then
					out_pins_sel(write_address - BEGIN_OUTPUT_REGS + 1) <= conv_std_logic_vector(i, OUTPUT_PIN_SEL_WIDTH);

				--					output_registers(DATA_WIDTH*(write_address - BEGIN_OUTPUT_REGS +1 ) -1 
				--								 downto DATA_WIDTH*(write_address - BEGIN_OUTPUT_REGS )) 
				--								 			<= write_data(i)(GEN_PUR_REG_WIDTH -1 downto 0);
				--				
				end if;

			elsif i < NUM_OF_OUTPUT_REG or i = NUM_OF_OUTPUT_REG then

			--				output_registers(DATA_WIDTH*i -1 downto DATA_WIDTH*(i -1)) 
			--										   <= register_file(i + BEGIN_OUTPUT_REGS -1);								 		
			--										
			end if;

		END LOOP;

	end process write_output;

	--
	--===========================================================================================
	--===========================================================================================

	--===============================================================================--
	-- Reading from the FEEDBACK FIFOs 
	--===============================================================================--

	--read_fb_fifo :process(read_addresses) --, res)
	--
	--variable cur_read_address :integer range 0 to FB_FIFO_OFFSET + NUM_OF_FEEDBACK_FIFOS -1;
	--variable cur_fb_read_address :integer range FB_FIFO_OFFSET to FB_FIFO_OFFSET + NUM_OF_FEEDBACK_FIFOS -1;
	--
	--begin
	--
	--
	--	 -- Set the read_en signals for the FB FIFOS
	--	 -- all to '0', because
	--	 -- the functional unit that has set the read_en to '1' in
	--	 -- the last clock cycle cannot by iself set it to '0' in
	--	 -- the next clock cycle, because the address for
	--	 -- the operands has already changed
	--
	--	 	FEED_BACK_fifos_read_en <= (others => '0');	  
	--
	--	 FOR i IN 1 to NUM_OF_READ_PORTS LOOP
	--
	--		cur_read_address := conv_integer(read_addresses(i));
	--	
	--		--if res(i) = '1' then
	--
	--				--==========================================================	
	--				if (cur_read_address >= FB_FIFO_OFFSET) then
	--			
	--					-- ==> READing from the FEEDBACK FIFOS
	--				--==========================================================
	--				
	--					-- To ensure the synthesis tool that the array is
	--					-- not accessed with an index greater than the array size
	--					-- a constrained variable cur_FB_READ_address is introduced,
	--					-- which only can take values lying in the array size	
	--
	--						cur_fb_read_address := cur_read_address;
	--			
	--						FEED_BACK_fifos_read_en(cur_fb_read_address) <= '1';
	--
	--				end if;
	--					
	--	 --end if;
	--				
	--				
	--	END LOOP;
	--
	--end process read_fb_fifo;

	--===========================================================================================
	--===========================================================================================

	reading : process(rst, read_addresses, register_file, input_fifos_read_data, FEED_BACK_fifos_read_data)
		variable cur_read_address            : integer range 0 to 512; -- FB_FIFO_OFFSET + NUM_OF_FEEDBACK_FIFOS -1;
		variable cur_gen_pur_read_address    : integer range 0 to INPUT_FIFO_OFFSET - 1;
		variable cur_input_fifo_read_address : integer range INPUT_FIFO_OFFSET to FB_FIFO_OFFSET - 1;
		variable cur_fb_fifo_read_address    : integer range FB_FIFO_OFFSET to FB_FIFO_OFFSET + NUM_OF_FEEDBACK_FIFOS - 1;

	begin
		FEED_BACK_fifos_read_en <= (others => '0');
		input_fifos_read_en     <= (others => '0');

		--read_data <= (others => (others => '0'));  

		FOR i IN 1 to NUM_OF_READ_PORTS LOOP
			if rst = '1' then

			--read_data(i) <= (others => '0');

			else
				cur_read_address := conv_integer(read_addresses(i));

				--==========================================================	
				if (cur_read_address < INPUT_FIFO_OFFSET) then

					-- ==> READ from the GENERAL PURPOSE/OUTPUT REGISTERS
					--==========================================================

					-- To ensure the synthesis tool that the array is
					-- not accessed with an index greater than the array size
					-- a constrained variable cur_GEN_PUR_READ_address is introduced,
					-- which only can take values lying in the array size	


					cur_gen_pur_read_address := cur_read_address;

					read_data(i)(GEN_PUR_REG_WIDTH - 1 downto 0) <= register_file(cur_gen_pur_read_address);

				--==========================================================	
				elsif (cur_read_address >= INPUT_FIFO_OFFSET) and (cur_read_address < FB_FIFO_OFFSET) then

					-- ==> READ from the INPUT FIFOS
					--==========================================================

					-- To ensure the synthesis tool that the array is
					-- not accessed with an index greater than the array size
					-- a constrained variable cur_INPUT_FIFO_READ_address is introduced,
					-- which only can take values lying in the array size	


					cur_input_fifo_read_address := cur_read_address;

					input_fifos_read_en(cur_input_fifo_read_address) <= '1';

					read_data(i)(GEN_PUR_REG_WIDTH - 1 downto 0) <= input_fifos_read_data(cur_input_fifo_read_address);

				--==========================================================	
				elsif (cur_read_address >= FB_FIFO_OFFSET) AND (cur_read_address < FB_FIFO_OFFSET + NUM_OF_FEEDBACK_FIFOS) then

					-- ==> READ from the FEEDBACK FIFOS
					--==========================================================	


					-- To ensure the synthesis tool that the array is
					-- not accessed with an index greater than the array size
					-- a constrained variable cur_FB_FIFO_READ_address is introduced,
					-- which only can take values lying in the array size	


					cur_fb_fifo_read_address := cur_read_address;

					FEED_BACK_fifos_read_en(cur_fb_fifo_read_address) <= '1';

					read_data(i)(GEN_PUR_REG_WIDTH - 1 downto 0) <= FEED_BACK_fifos_read_data(cur_fb_fifo_read_address);

				else
					read_data(i) <= read_data(i);

				end if;

			end if;                     -- rst = '1'

		END LOOP;

	end process reading;

	--#######################
	--##### SRECO PROCESS ###
	writing_sreco : process(wes, write_addresses, write_data)
		variable cur_write_address : integer range 0 to RF_OFFSET + 4;

	begin
		config_reg_data <= (others => '0');
		config_reg_addr <= (others => '0');
		config_reg_we   <= '0';

		FOR i IN 1 to NUM_OF_WRITE_PORTS LOOP
			cur_write_address := conv_integer(write_addresses(i));

			if wes(i) = '1' then
				if (cur_write_address >= RF_OFFSET) and (cur_write_address < RF_OFFSET + 5) then
					config_reg_data <= conv_std_logic_vector(conv_integer(write_data(i)), CUR_DEFAULT_CONFIG_REG_WIDTH);
					config_reg_addr <= conv_std_logic_vector(cur_write_address - RF_OFFSET, 3);
					config_reg_we   <= '1';

				end if;                 --==: if (cur_write_address >= RF_OFFSET) and (cur_write_address < RF_OFFSET + 5)

			end if;                     --==: 	if wes(i) = '1'

		END LOOP;

	end process writing_sreco;

end Behavioral;


