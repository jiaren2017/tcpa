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
-- Create Date:    16:24:14 08/14/2014 
-- Design Name: 
-- Module Name:    AG_MATRIX_Pipelined - Behavioral 
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

entity AG_MATRIX_Pipelined is
	generic(
		--###########################################################################
		-- AG_MATRIX_Pipelined parameters, do not add to or delete
		--###########################################################################
		DESIGN_TYPE			: integer range 0 to 7  := 0;
		ENABLE_PIXEL_BUFFER_MODE	: integer range 0 to 31 := 1;
		CONFIG_SIZE                     : integer               := 1024;
		
		INDEX_VECTOR_DIMENSION  : integer range 0 to 32 := 3;
		INDEX_VECTOR_DATA_WIDTH : integer range 0 to 32 := 9;

		MATRIX_PIPELINE_DEPTH    : integer range 0 to 32 := 2; -- equals log2(INDEX_VECTOR_DIMENSION) + 1

		INITIAL_DELAY_SELECTOR_WIDTH : integer range 0 to 32 := 6;

		CHANNEL_ADDR_WIDTH      : integer range 0 to 64 := 18; -- 2 * DATA_WIDTH;
		CHANNEL_COUNT           : integer range 0 to 32 := 4;

		CONFIG_ADDR_WIDTH       : integer range 0 to 32 := 8;
		CONFIG_DATA_WIDTH       : integer range 0 to 32 := 9 -- must be the same as INDEX_VECTOR_DATA_WIDTH
	--###########################################################################		
	);
	port(
		clk                 : in  std_logic;
		reset               : in  std_logic;
		gc_reset            : in  std_logic;
		config_rst          : in  std_logic;
		config_clk          : in  std_logic;
		config_en           : in  std_logic;
		config_we           : in  std_logic;
		config_data         : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
		config_wr_addr      : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
		start               : in  std_logic;
		index_vector        : in  std_logic_vector(INDEX_VECTOR_DIMENSION * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
		channels_en         : out std_logic_vector(CHANNEL_COUNT - 1 downto 0);
		channels_addr       : out std_logic_vector(CHANNEL_COUNT * CHANNEL_ADDR_WIDTH - 1 downto 0);
		AG_out_addr         : out std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0);
		AG_en               : in  std_logic;
		AG_out_en           : out std_logic;
		--buffer_interrupts : out std_logic_vector(CHANNEL_COUNT downto 0)
		AG_buffer_interrupt : out std_logic
	);
end AG_MATRIX_Pipelined;

architecture Behavioral of AG_MATRIX_Pipelined is
	---------------------------------- Constant    ------------------------------------
	constant MAX_AC_COUNT            : integer range 0 to 32 := CHANNEL_COUNT;
	constant CONFIG_DEPTH : integer range 0 to 255 := INDEX_VECTOR_DIMENSION + (MAX_AC_COUNT * INDEX_VECTOR_DIMENSION) + 2 * MAX_AC_COUNT + 2 + 1;
	constant INTERNAL_CONFIG_ADDR_WIDTH : integer range 0 to 32 := CONFIG_ADDR_WIDTH; -- must be equals to log2(CONFIG_DEPTH)+1
	---------------------------------- End Constant    --------------------------------

	--------------------- Signals ----------------------------------------------------
	type addr_vect_t is array (CHANNEL_COUNT downto 0) of std_logic_vector(INTERNAL_CONFIG_ADDR_WIDTH - 1 downto 0);
	type data_vect_t is array (CHANNEL_COUNT downto 0) of std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
	type logic_vect_t is array (CHANNEL_COUNT downto 0) of std_logic;

	signal config_wr_addr_i    : addr_vect_t                              := (others => (others => '0'));
	signal buffer_interrupts_i : std_logic_vector(CHANNEL_COUNT downto 0) := (others => '0');
	signal config_en_i         : logic_vect_t;
	signal config_we_i         : logic_vect_t;
	signal config_data_i       : data_vect_t;
	signal AG_out_addr_s, limit: std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0);
	signal AG_out_en_s, stop   : std_logic;
	--------------------- End Signal -------------------------------------------------

	--------------------- Component --------------------------------------------------
	COMPONENT AG_MATRIX_Single is
		generic(
			--###########################################################################
			-- AG_MATRIX_Single parameters, do not add to or delete
			--###########################################################################
			DESIGN_TYPE				: integer range 0 to 7:= 1;
			INDEX_VECTOR_DIMENSION  : integer range 0 to 32 := INDEX_VECTOR_DIMENSION;
			INDEX_VECTOR_DATA_WIDTH : integer range 0 to 32 := INDEX_VECTOR_DATA_WIDTH;
			CONFIG_SIZE             : integer               := CONFIG_SIZE;

			MATRIX_PIPELINE_DEPTH    : integer range 0 to 32 := MATRIX_PIPELINE_DEPTH; -- equals log2(INDEX_VECTOR_DIMENSION) + 1

			CHANNEL_ADDR_WIDTH      : integer range 0 to 64 := CHANNEL_ADDR_WIDTH; -- 2 * DATA_WIDTH;
			CHANNEL_COUNT           : integer range 0 to 32 := CHANNEL_COUNT;

			INITIAL_DELAY_SELECTOR_WIDTH : integer range 0 to 32 := INITIAL_DELAY_SELECTOR_WIDTH;

			MAX_AC_COUNT            : integer range 0 to 32 := MAX_AC_COUNT;

			CONFIG_ADDR_WIDTH       : integer range 0 to 32 := CONFIG_ADDR_WIDTH;
			CONFIG_DATA_WIDTH       : integer range 0 to 32 := CONFIG_DATA_WIDTH -- must be the same as INDEX_VECTOR_DATA_WIDTH
		--###########################################################################		
		);
		port(
			clk              : in  std_logic;
			reset            : in  std_logic;
			gc_reset         : in  std_logic;
			config_rst       : in  std_logic;
			config_clk       : in  std_logic;
			config_en        : in  std_logic;
			config_we        : in  std_logic;
			config_data      : in  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
			config_wr_addr   : in  std_logic_vector(CONFIG_ADDR_WIDTH - 1 downto 0);
			start            : in  std_logic;
			index_vector     : in  std_logic_vector(INDEX_VECTOR_DIMENSION * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);

			AG_out_addr      : out std_logic_vector(CHANNEL_ADDR_WIDTH - 1 downto 0);
			AG_out_en        : out std_logic;
			AG_en            : in  std_logic;
			buffer_interrupt : out std_logic
		);
	end component AG_MATRIX_Single;

--------------------- End Component ----------------------------------------------

--	attribute KEEP_HIERARCHY : string;
--	attribute KEEP_HIERARCHY of AG_MATRIX_Single: component is "TRUE";
	
	attribute syn_preserve : boolean;
	attribute syn_preserve of AG_MATRIX_Single : component is true;
	
begin
	Channel_Generate : for i in 0 to CHANNEL_COUNT generate
		
		
		we_and_en_reg : process(config_wr_addr,config_we,config_en) is
			variable tmp_wr_addr_i : unsigned(INTERNAL_CONFIG_ADDR_WIDTH - 1 downto 0):=(others => '0');
		begin
			if((unsigned(config_wr_addr) < to_unsigned((i+1) * CONFIG_DEPTH,CONFIG_ADDR_WIDTH)) and (unsigned(config_wr_addr) >= to_unsigned(i * CONFIG_DEPTH,CONFIG_ADDR_WIDTH)))then
				config_we_i(i)   <= config_we; 
				config_en_i(i)   <= config_en ;
				tmp_wr_addr_i := unsigned(config_wr_addr(INTERNAL_CONFIG_ADDR_WIDTH - 1 downto 0));
				config_wr_addr_i(i) <= std_logic_vector(tmp_wr_addr_i - (i * CONFIG_DEPTH));
			else
				config_wr_addr_i(i) <= (others => '0');
				config_we_i(i)   <= '0';
				config_en_i(i)   <= '0' ;
			end if;
		end process we_and_en_reg;

--		addr_en_logic : process(reset, clk) is
--		begin
--			if reset = '1' then
--				stop <= '0';
--				limit <= std_logic_vector(to_unsigned(7, CHANNEL_ADDR_WIDTH));
--				
--			elsif rising_edge(clk) then
--				if stop = '0' then
--					if((unsigned(AG_out_addr_s) >= to_unsigned(7, CHANNEL_ADDR_WIDTH))) then
--						if AG_out_en_s='1' then
--							stop <= '1';
--						end if;
--					end if;
--				end if;
--			end if;
--		end process;
--          AG_out_en <= AG_out_en_s when stop = '0' else '0';
--          AG_out_addr <= AG_out_addr_s when stop = '0' else (others=>'0');
          
		config_data_i(i) <= config_data;
		

		AG_OUTPUT : if i = 0 generate
			-- AG OUTPUT
			output_Inst : component AG_MATRIX_Single
				generic map(DESIGN_TYPE				=> DESIGN_TYPE,
						INDEX_VECTOR_DIMENSION  => INDEX_VECTOR_DIMENSION,
					        INDEX_VECTOR_DATA_WIDTH => INDEX_VECTOR_DATA_WIDTH,
					        MATRIX_PIPELINE_DEPTH   => MATRIX_PIPELINE_DEPTH,
						CONFIG_SIZE             => CONFIG_SIZE,
					        CHANNEL_ADDR_WIDTH      => CHANNEL_ADDR_WIDTH,
					        CHANNEL_COUNT           => CHANNEL_COUNT,
					        MAX_AC_COUNT            => MAX_AC_COUNT,
						INITIAL_DELAY_SELECTOR_WIDTH => INITIAL_DELAY_SELECTOR_WIDTH,
					        CONFIG_ADDR_WIDTH       => INTERNAL_CONFIG_ADDR_WIDTH,
					        CONFIG_DATA_WIDTH       => CONFIG_DATA_WIDTH)
				port map(    clk              => clk,
					     reset            => reset,
					     gc_reset         => gc_reset,
					     config_rst       => config_rst,
					     config_clk       => config_clk,
					     config_en        => config_en_i(i),
					     config_we        => config_we_i(i),
					     config_data      => config_data_i(i),
					     config_wr_addr   => config_wr_addr_i(i),
					     start            => start,
					     index_vector     => index_vector,
					     AG_out_addr      => AG_out_addr,
					     AG_en            => AG_en,
					     AG_out_en        => AG_out_en,
					     buffer_interrupt => buffer_interrupts_i(i));
		end generate AG_OUTPUT;

		CHANNEL_OUTPUT : if not (i = 0) generate
			NO_PXB_BUFFER: if (ENABLE_PIXEL_BUFFER_MODE = 0) generate
			
			channel_Inst : component AG_MATRIX_Single
				generic map(DESIGN_TYPE				=> DESIGN_TYPE,
						INDEX_VECTOR_DIMENSION  => INDEX_VECTOR_DIMENSION,
					        INDEX_VECTOR_DATA_WIDTH => INDEX_VECTOR_DATA_WIDTH,
					        MATRIX_PIPELINE_DEPTH   => MATRIX_PIPELINE_DEPTH,
						CONFIG_SIZE             => CONFIG_SIZE,
					        CHANNEL_ADDR_WIDTH      => CHANNEL_ADDR_WIDTH,
					        CHANNEL_COUNT           => CHANNEL_COUNT,
					        MAX_AC_COUNT            => MAX_AC_COUNT,
						INITIAL_DELAY_SELECTOR_WIDTH => INITIAL_DELAY_SELECTOR_WIDTH,
					        CONFIG_ADDR_WIDTH       => INTERNAL_CONFIG_ADDR_WIDTH,
					        CONFIG_DATA_WIDTH       => CONFIG_DATA_WIDTH)
				port map(clk              => clk,
					     reset            => reset,
					     gc_reset         => gc_reset,
					     config_rst       => config_rst,
					     config_clk       => config_clk,
					     config_en        => config_en_i(i),
					     config_we        => config_we_i(i),
					     config_data      => config_data_i(i),
					     config_wr_addr   => config_wr_addr_i(i),
					     start            => start,
					     index_vector     => index_vector,
					     AG_out_addr      => channels_addr(i * CHANNEL_ADDR_WIDTH - 1 downto (i-1) * CHANNEL_ADDR_WIDTH),
					     AG_en            => AG_en,
					     AG_out_en        => channels_en(i-1),
					     buffer_interrupt => buffer_interrupts_i(i));
			end generate NO_PXB_BUFFER;

			PXB_BUFFER: if not (ENABLE_PIXEL_BUFFER_MODE = 0) generate
				channels_addr(i * CHANNEL_ADDR_WIDTH - 1 downto (i-1) * CHANNEL_ADDR_WIDTH) <= (others => '0');
				channels_en(i-1) <= '0';
				buffer_interrupts_i(i) <= '0';
			end generate PXB_BUFFER;

		end generate CHANNEL_OUTPUT;
	end generate Channel_Generate;

	--buffer_interrupts <= buffer_interrupts_i(CHANNEL_COUNT downto 0);
	--it will  be raised an IRQ in case of any bit of buffer_interrupts_i is equal to '1'
	AG_buffer_interrupt <= '0' when (config_rst or reset or gc_reset) = '1' else '1' when (start = '1') and (not (buffer_interrupts_i = (CHANNEL_COUNT downto 0 => '0'))) else '0';

end Behavioral;

