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
-- Module Name:    AG_MATRIX_Single - Behavioral 
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

entity AG_MATRIX_Single is
	generic(
		--###########################################################################
		-- AG_MATRIX_Single parameters, do not add to or delete
		--###########################################################################
		DESIGN_TYPE             : integer range 0 to 7  := 1;
		INDEX_VECTOR_DIMENSION  : integer range 0 to 32 := 3;
		INDEX_VECTOR_DATA_WIDTH : integer range 0 to 32 := 9;
		CONFIG_SIZE             : integer               := 1024;

		MATRIX_PIPELINE_DEPTH    : integer range 0 to 32 := 2; -- equals log2(INDEX_VECTOR_DIMENSION) + 1

		CHANNEL_ADDR_WIDTH      : integer range 0 to 64 := 18; -- 2 * DATA_WIDTH;
		CHANNEL_COUNT           : integer range 0 to 32 := 4;

		MAX_AC_COUNT            : integer range 0 to 32 := 8;

		INITIAL_DELAY_SELECTOR_WIDTH : integer range 0 to 32 := 6;

		CONFIG_ADDR_WIDTH       : integer range 0 to 32 := 6;
		CONFIG_DATA_WIDTH       : integer range 0 to 32 := 9 -- must be the same as INDEX_VECTOR_DATA_WIDTH
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
end AG_MATRIX_Single;

architecture Behavioral of AG_MATRIX_Single is
	---------------------------------- Constant    ------------------------------------
	constant R            : integer range 0 to 64 := MAX_AC_COUNT;
	constant K            : integer range 0 to 64 := INDEX_VECTOR_DIMENSION;
	constant CONFIG_DEPTH : integer               := 2 ** CONFIG_ADDR_WIDTH;
	---------------------------------- End Constant    --------------------------------

	--------------------- Signals ----------------------------------------------------
	--type config_data_t is array (CONFIG_DEPTH - 1 downto 0) of std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
	type config_data_t is array (CONFIG_SIZE - 1 downto 0) of std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);
	signal config_reg : config_data_t := (others => (others => '0'));
	attribute RAM_STYLE : string;
	attribute RAM_STYLE of config_reg : signal is "BLOCK";

	type k_vect_t is array (K - 1 downto 0) of std_logic_vector(INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	type r_2vect_t is array (R - 1 downto 0) of std_logic_vector(2 * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	type temp_test_r_2vect_t is array (R - 1 downto 0) of std_logic_vector(INDEX_VECTOR_DATA_WIDTH - 1 downto 0);

	type rk_mat_t is array (R - 1 downto 0) of k_vect_t;

	signal output_mat      : k_vect_t  := (others => (others => '0'));
	signal output_en_mat   : rk_mat_t  := (others => (others => (others => '0')));
	signal limit_output    : r_2vect_t := (others => (others => '0'));
	signal temp_test       : temp_test_r_2vect_t := (others => (others => '0'));
	signal overflow_output : std_logic_vector(2 * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	signal overflow_output_s : signed(INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	signal initial_delay   : std_logic_vector(INITIAL_DELAY_SELECTOR_WIDTH - 1 downto 0):=(others => '0');
	signal initial_delay_i : integer range 0 to 2**INITIAL_DELAY_SELECTOR_WIDTH := 0;

	type long_vect_t is array (R - 1 downto 0) of std_logic_vector(1 * K * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	type dlong_vect_t is array (R - 1 downto 0) of std_logic_vector(1 * 2 * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	type en_vect_t is array (R - 1 downto 0) of std_logic_vector(1 - 1 downto 0);

	signal output_A_Mat     : std_logic_vector(1 * K * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	signal output_B_Mat     : std_logic_vector(1 * K * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	signal output_C_Mat     : std_logic_vector(2 * INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	signal output_en_A_Mat  : long_vect_t;
	signal output_en_B_Mat  : long_vect_t;
	signal output_en_C_Mat  : dlong_vect_t;
	signal output_en_valids : en_vect_t;
	signal tmp_out_valid    : std_logic_vector(R - 1 downto 0);

	signal output_addr_valids : std_logic_vector(1 - 1 downto 0);

	signal index_vect    : k_vect_t                                                   := (others => (others => '0'));
	signal AG_out_addr_i : std_logic_vector(2 * INDEX_VECTOR_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal in_CSR : std_logic_vector(CHANNEL_ADDR_WIDTH downto 0) := (others => '0');
	signal out_CSR : std_logic_vector(CHANNEL_ADDR_WIDTH downto 0) := (others => '0');
	signal AG_out_addr_i_s : signed(2 * INDEX_VECTOR_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal buffer_interrupt_s, irq, start_s : std_logic := '0';	
	signal AG_out_en_s, AG_en_i, AG_en_s, overflow_flag, irq_en : std_logic := '0';	
	signal counter    : integer range 0 to (2**INITIAL_DELAY_SELECTOR_WIDTH) :=0;
	--------------------- End Signal -------------------------------------------------

	--------------------- Component --------------------------------------------------
	COMPONENT Simple_Matrix_Mult_Pipelined
		generic(
			DATA_WIDTH    : integer range 0 to 32 := INDEX_VECTOR_DATA_WIDTH;
			M             : integer range 0 to 64 := CHANNEL_COUNT;
			K             : integer range 0 to 64 := INDEX_VECTOR_DIMENSION;
			N             : integer range 0 to 64 := 1;
			PIPELINE_DEPTH : integer range 0 to 32 := MATRIX_PIPELINE_DEPTH -- equals log2(K) + 1
		--###########################################################################		
		);
		port(
			clk   : in  std_logic;
			reset : in  std_logic;
			start : in  std_logic;
			A_Mat : in  std_logic_vector(M * K * DATA_WIDTH - 1 downto 0);
			B_Mat : in  std_logic_vector(K * N * DATA_WIDTH - 1 downto 0);
			C_Mat : out std_logic_vector(M * N * 2 * DATA_WIDTH - 1 downto 0);
			valid : OUT std_logic_vector(M * N - 1 downto 0)
		);
	end component;

	COMPONENT Simple_Matrix_Mult
		generic(
			DATA_WIDTH    : integer range 0 to 32 := INDEX_VECTOR_DATA_WIDTH;
			M             : integer range 0 to 64 := CHANNEL_COUNT;
			K             : integer range 0 to 64 := INDEX_VECTOR_DIMENSION;
			N             : integer range 0 to 64 := 1;
			PIPELINE_DEPTH : integer range 0 to 32 := MATRIX_PIPELINE_DEPTH -- equals log2(K) + 1
		--###########################################################################		
		);
		port(
			clk   : in  std_logic;
			reset : in  std_logic;
			start : in  std_logic;
			A_Mat : in  std_logic_vector(M * K * DATA_WIDTH - 1 downto 0);
			B_Mat : in  std_logic_vector(K * N * DATA_WIDTH - 1 downto 0);
			C_Mat : out std_logic_vector(M * N * 2 * DATA_WIDTH - 1 downto 0);
			valid : OUT std_logic_vector(M * N - 1 downto 0)
		);
	end component;
	
	component CSR is
		generic(
			--###########################################################################
			-- CSR parameters, do not add to or delete
			--###########################################################################
			DELAY_SELECTOR_WIDTH : integer range 0 to 32 := 5;
			DATA_WIDTH           : integer range 0 to 32 := CHANNEL_ADDR_WIDTH + 1
		--###########################################################################		
		);
		port(
			clk         : in  std_logic;
			rst         : in  std_logic;
			selector    : in  std_logic_vector(DELAY_SELECTOR_WIDTH - 1 downto 0);
			data_input  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
			data_output : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	
	end component;

--------------------- End Component ----------------------------------------------
--	attribute KEEP_HIERARCHY : string;
--	attribute KEEP_HIERARCHY of Simple_Matrix_Mult_Pipelined: component is "TRUE";
	
	attribute syn_preserve : boolean;
	attribute syn_preserve of Simple_Matrix_Mult_Pipelined: component is true;
	
begin
	-- Configuration Process
	CONFIG_PROCESS : process(config_clk, config_rst) is
	begin
		if config_rst = '1' then
			config_reg <= (others => (others => '0'));
		elsif rising_edge(config_clk) then
			if config_en = '1' then
				if (config_we = '1') then
					config_reg(to_integer(unsigned(config_wr_addr))) <= config_data;
				end if;
			end if;
		end if;
	end process CONFIG_PROCESS;

	--CHANNEL_ADDR_WIDTH = 18
	--	CHANNEL_COUNT = 4
	--	CONFIG_ADDR_WIDTH = 6
	--	CONFIG_DATA_WIDTH = 9
	--	DESIGN_TYPE = 0
	--	INDEX_VECTOR_DATA_WIDTH = 9
	--	INDEX_VECTOR_DIMENSION = 3
	--	MATRIX_PIPELINE_DEPTH = 2
	--	MAX_AC_COUNT = 8
	-- Initialize the index_mat
	INDEX_MAT_I : for i in 0 to K - 1 generate
		index_vect(i) <= index_vector((i + 1) * INDEX_VECTOR_DATA_WIDTH - 1 downto i * INDEX_VECTOR_DATA_WIDTH);
	end generate INDEX_MAT_I;

	------------------- Output -----------------------------------------------------------------------------------------------------------------------------	
	-- Initialize the output_mat
	OUTPUT_MAT_I : for i in 0 to K - 1 generate
		output_mat(i) <= config_reg(i)(INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	end generate OUTPUT_MAT_I;

	-- Initialize the ouput_en_mat
	OUTPUT_EN_MAT_I : for i in 0 to R - 1 generate
		EN_MAT_J : for j in 0 to K - 1 generate
			output_en_mat(i)(j) <= config_reg(i * K + j + K)(INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
		end generate EN_MAT_J;
	end generate OUTPUT_EN_MAT_I;

	-- Initialize the limit for AG_en
	Limit_VECT : for i in 0 to R - 1 generate
		check_width : if 2 * INDEX_VECTOR_DATA_WIDTH <= CONFIG_DATA_WIDTH generate
			limit_output(i)(2 * INDEX_VECTOR_DATA_WIDTH - 1 downto 0) <= config_reg(2 * i + K + (R * K))(INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
		end generate check_width;
		check_width_2 : if (2 * INDEX_VECTOR_DATA_WIDTH > CONFIG_DATA_WIDTH) generate
			limit_output(i)(CONFIG_DATA_WIDTH - 1 downto 0)                           <= config_reg(2 * i + K + (R * K))(CONFIG_DATA_WIDTH - 1 downto 0);
			limit_output(i)(2 * INDEX_VECTOR_DATA_WIDTH - 1 downto CONFIG_DATA_WIDTH) <= config_reg(2 * i + K + (R * K) + 1)(2 * INDEX_VECTOR_DATA_WIDTH - 1 - CONFIG_DATA_WIDTH downto 0);
		end generate check_width_2;
	end generate Limit_VECT;

	-- Initialize the Buffer Overflow Limits that generate the Interrupts
	check_width_o : if 2 * INDEX_VECTOR_DATA_WIDTH <= CONFIG_DATA_WIDTH generate
		overflow_output(INDEX_VECTOR_DATA_WIDTH - 1 downto 0) <= config_reg(K + (R * K) + 2 * R)(INDEX_VECTOR_DATA_WIDTH - 1 downto 0);
	end generate check_width_o;
	check_width_2_o : if (2 * INDEX_VECTOR_DATA_WIDTH > CONFIG_DATA_WIDTH) generate
		overflow_output(CONFIG_DATA_WIDTH - 1 downto 0)                           <= config_reg(K + (R * K) + 2 * R)(CONFIG_DATA_WIDTH - 1 downto 0);
		overflow_output(2 * INDEX_VECTOR_DATA_WIDTH - 1 downto CONFIG_DATA_WIDTH) <= config_reg(K + (R * K) + 2 * R + 1)(2 * INDEX_VECTOR_DATA_WIDTH - 1 - CONFIG_DATA_WIDTH downto 0);
	end generate check_width_2_o;
	
	-- Initialize the initial delay
	--initial_delay(INITIAL_DELAY_SELECTOR_WIDTH - 1 downto 0) <= config_reg(K + (R * K) + 2 * R + 2)(INITIAL_DELAY_SELECTOR_WIDTH - 1 downto 0);
	initial_delay_i <= to_integer(unsigned(config_reg(K + (R * K) + 2 * R + 2)(INITIAL_DELAY_SELECTOR_WIDTH - 1 downto 0))) + 3;
	initial_delay(INITIAL_DELAY_SELECTOR_WIDTH - 1 downto 0) <= std_logic_vector(to_unsigned(initial_delay_i, INITIAL_DELAY_SELECTOR_WIDTH));


	-- Component Output
	OUTPUT_A_I : for i in 0 to K - 1 generate
		output_A_Mat((i + 1) * INDEX_VECTOR_DATA_WIDTH - 1 downto i * INDEX_VECTOR_DATA_WIDTH) <= output_mat(i);
		output_B_Mat((i + 1) * INDEX_VECTOR_DATA_WIDTH - 1 downto i * INDEX_VECTOR_DATA_WIDTH) <= index_vect(i);
	end generate OUTPUT_A_I;

	DESIGN_TYPE_PIPELINED_OUTPUT : if DESIGN_TYPE = 0 generate
		output_addr_compute : Simple_Matrix_Mult
			generic map(
				DATA_WIDTH    => INDEX_VECTOR_DATA_WIDTH,
				M             => 1,
				K             => K,
				N             => 1,
				PIPELINE_DEPTH => MATRIX_PIPELINE_DEPTH
			--###########################################################################		
			)
			port map(
				clk   => clk,
				reset => reset,
				start => start_s,
				A_Mat => output_A_Mat,
				B_Mat => output_B_Mat,
				C_Mat => output_C_Mat,
				valid => output_addr_valids
			);
	end generate DESIGN_TYPE_PIPELINED_OUTPUT;

	DESIGN_TYPE_PIPELINED_OUTPUT_2 : if DESIGN_TYPE = 1 generate
		output_addr_compute : Simple_Matrix_Mult_Pipelined
			generic map(
				DATA_WIDTH    => INDEX_VECTOR_DATA_WIDTH,
				M             => 1,
				K             => K,
				N             => 1,
				PIPELINE_DEPTH => MATRIX_PIPELINE_DEPTH
			--###########################################################################		
			)
			port map(
				clk   => clk,
				reset => reset,
				start => start_s,
				A_Mat => output_A_Mat,
				B_Mat => output_B_Mat,
				C_Mat => output_C_Mat,
				valid => output_addr_valids
			);
	end generate DESIGN_TYPE_PIPELINED_OUTPUT_2;

	--AG_out_addr_i <= output_C_Mat  when irq = '0' else (others=>'0');
	--AG_out_addr   <= AG_out_addr_i(CHANNEL_ADDR_WIDTH - 1 downto 0) when output_addr_valids = "1" else (others => '0');
	in_CSR(CHANNEL_ADDR_WIDTH-1 downto 0) <= AG_out_addr_i(CHANNEL_ADDR_WIDTH - 1 downto 0) when output_addr_valids = "1" else (others => '0');
	AG_out_addr   <= out_CSR(CHANNEL_ADDR_WIDTH-1 downto 0) when irq = '0' else (others=>'0');
	-- Component Output en
	EN_OUTPUT_AB : for it in 0 to R - 1 generate
		OUTPUT_MAT_I_IT : for i in 0 to K - 1 generate
			output_en_A_Mat(it)((i + 1) * INDEX_VECTOR_DATA_WIDTH - 1 downto i * INDEX_VECTOR_DATA_WIDTH) <= output_en_mat(it)(i);
			output_en_B_Mat(it)((i + 1) * INDEX_VECTOR_DATA_WIDTH - 1 downto i * INDEX_VECTOR_DATA_WIDTH) <= index_vect(i);
		end generate OUTPUT_MAT_I_IT;

		DESIGN_TYPE_PIPELINED : if DESIGN_TYPE = 1 generate
			output_en_compute : Simple_Matrix_Mult_Pipelined
				generic map(
					DATA_WIDTH    => INDEX_VECTOR_DATA_WIDTH,
					M             => 1,
					K             => K,
					N             => 1,
					PIPELINE_DEPTH => MATRIX_PIPELINE_DEPTH
				--###########################################################################		
				)
				port map(
					clk   => clk,
					reset => reset,
					start => start_s,
					A_Mat => output_en_A_Mat(it),
					B_Mat => output_en_B_Mat(it),
					C_Mat => output_en_C_Mat(it),
					valid => output_en_valids(it)
				);
		end generate DESIGN_TYPE_PIPELINED;

		DESIGN_TYPE_SIMPLE : if DESIGN_TYPE = 0 generate
			output_en_compute : Simple_Matrix_Mult
				generic map(
					DATA_WIDTH    => INDEX_VECTOR_DATA_WIDTH,
					M             => 1,
					K             => K,
					N             => 1,
					PIPELINE_DEPTH => MATRIX_PIPELINE_DEPTH
				--###########################################################################		
				)
				port map(
					clk   => clk,
					reset => reset,
					start => start_s,
					A_Mat => output_en_A_Mat(it),
					B_Mat => output_en_B_Mat(it),
					C_Mat => output_en_C_Mat(it),
					valid => output_en_valids(it)
				);
		end generate DESIGN_TYPE_SIMPLE;
                temp_test(it) <= limit_output(it)(INDEX_VECTOR_DATA_WIDTH-1 downto 0);

		--tmp_out_valid(it) <= '1' when (output_en_C_Mat(it) >= limit_output(it)) and (output_en_valids(it) = "1") else '0';
		--tmp_out_valid(it) <= '1' when (output_en_C_Mat(it) >= limit_output(it) and output_en_valids(it) = "1") else '0';
		--tmp_out_valid(it) <= '1' when (unsigned(output_en_C_Mat(it)(INDEX_VECTOR_DATA_WIDTH-1 downto 0)) >= (unsigned(temp_test(it)(INDEX_VECTOR_DATA_WIDTH-1 downto 0))) and unsigned(output_en_valids(it)) = "1") else '0';

		--Previous version
		--tmp_out_valid(it) <= '1' when (signed(output_en_C_Mat(it)(INDEX_VECTOR_DATA_WIDTH-1 downto 0)) >= (signed(temp_test(it)(INDEX_VECTOR_DATA_WIDTH-1 downto 0))) and unsigned(output_en_valids(it)) = "1") else '0';

		--New implementation from March 2017
		CHECK_ADDRESS_CONDITION_BOUNDS : if(it < INDEX_VECTOR_DIMENSION) generate
			tmp_out_valid(it) <= '1' when (signed(index_vector((it+1)*INDEX_VECTOR_DATA_WIDTH-1 downto it*INDEX_VECTOR_DATA_WIDTH)) >= (signed(temp_test(it)(INDEX_VECTOR_DATA_WIDTH-1 downto 0))) and unsigned(output_en_valids(it)) = "1") else '0';
--			tmp_out_valid(0) <= '1' when (signed(index_vector((1)*INDEX_VECTOR_DATA_WIDTH-1 downto 0*INDEX_VECTOR_DATA_WIDTH)) >= (signed(temp_test(0)(INDEX_VECTOR_DATA_WIDTH-1 downto 0))) and unsigned(output_en_valids(0)) = "1") else '0';
--			tmp_out_valid(1) <= '1' when (signed(index_vector((2)*INDEX_VECTOR_DATA_WIDTH-1 downto 1*INDEX_VECTOR_DATA_WIDTH)) >= (signed(temp_test(1)(INDEX_VECTOR_DATA_WIDTH-1 downto 0))) and unsigned(output_en_valids(1)) = "1") else '0';
--			tmp_out_valid(2) <= '1' when (signed(index_vector((3)*INDEX_VECTOR_DATA_WIDTH-1 downto 2*INDEX_VECTOR_DATA_WIDTH)) >= (signed(temp_test(2)(INDEX_VECTOR_DATA_WIDTH-1 downto 0))) and unsigned(output_en_valids(2)) = "1") else '0';
--			tmp_out_valid(3) <= '1'; 
		end generate CHECK_ADDRESS_CONDITION_BOUNDS;

		CHECK_ADDRESS_CONDITION_BOUNDS_2 : if(it >= INDEX_VECTOR_DIMENSION) generate
			tmp_out_valid(it) <= '1'; 
		end generate CHECK_ADDRESS_CONDITION_BOUNDS_2;

	end generate EN_OUTPUT_AB;

--	in_CSR(CHANNEL_ADDR_WIDTH) <= '1' when unsigned(tmp_out_valid(INDEX_VECTOR_DIMENSION - 1 downto 0)) =  else '0';
	in_CSR(CHANNEL_ADDR_WIDTH) <= '1' when tmp_out_valid = (R - 1 downto 0 => '1') else '0';
	--AG_out_en <= '1' when tmp_out_valid = (R - 1 downto 0 => '1') else '0';
	--AG_out_en_s <= out_CSR(CHANNEL_ADDR_WIDTH) when start = '1' else '0';
	AG_out_en_s <= out_CSR(CHANNEL_ADDR_WIDTH);
	AG_out_en <= AG_out_en_s when irq = '0' else '0';
	
	-- Buffers Interrupts
--	AG_out_addr_i_s <= signed(AG_out_addr_i) when irq = '0' else (others=>'0');
	overflow_output_s <= signed(overflow_output(INDEX_VECTOR_DATA_WIDTH - 1 downto 0)) when irq = '0' else (others=>'0');
--	overflow_output_s <= signed(temp_test(0)(INDEX_VECTOR_DATA_WIDTH - 1 downto 0)) when irq = '0' else (others=>'0');
	buffer_interrupt <= buffer_interrupt_s;
	start_s <= start when irq = '0' else '0';

	AG_EN_PROCESS : process(clk, reset, irq, start, AG_en, initial_delay_i)
	begin
		if (reset = '1') then
			AG_en_s <= '0';
			counter <= 0;

		elsif (clk'event and clk = '1') then
--			AG_en_i <= AG_en;
--			start_s <= start;
			if((start and AG_en)='1') then
				if(counter = initial_delay_i) then
					AG_en_s <= '1';
				else
					counter <= counter + 1;
					AG_en_s <= '0';
				end if;

			elsif(start = '0' or irq = '1') then
				AG_en_s <= '0';
			end if;
		end if;
	end process;

	ISR_PROCESS : process(clk, reset, gc_reset)
	begin
		if (reset or gc_reset) = '1' then
			irq <= '0'; --here gc_reset or reset are used to clean-up the irq flag
			buffer_interrupt_s <= '0';
			overflow_flag <= '0';

		elsif rising_edge(clk) then
--			AG_out_en_s <= out_CSR(CHANNEL_ADDR_WIDTH);
			irq_en <= overflow_output(CONFIG_DATA_WIDTH);

			if (AG_out_en_s and AG_en_s) = '1' then
				if((to_integer(unsigned(out_CSR(CHANNEL_ADDR_WIDTH-1 downto 0)))) >= to_integer(unsigned(overflow_output_s))) then
					overflow_flag <= '1';
					if(irq_en  = '1') then
						irq <= '1';
						buffer_interrupt_s <= '1'; --this signal triggers the ahbo.pirq during one cycle only
					end if;
				else
					overflow_flag <= '0';
				end if;
			end if;
--			AG_out_addr   <= (others=>'0');
			if(irq = '1') then
				buffer_interrupt_s <= '0'; --this signal triggers the ahbo.pirq during one cycle only
				AG_out_addr_i <= (others=>'0');
--				AG_out_en <= '0';
			else
--				AG_out_en <= AG_out_en_s;
--				AG_out_addr   <= out_CSR(CHANNEL_ADDR_WIDTH-1 downto 0);
				AG_out_addr_i <= output_C_Mat;
			end if;
		end if;
	end process;


	initial_delay_Inst:component CSR
		generic map(DELAY_SELECTOR_WIDTH => INITIAL_DELAY_SELECTOR_WIDTH,
			        DATA_WIDTH           => CHANNEL_ADDR_WIDTH + 1)
		port map(clk         => clk,
			     rst         => reset,
			     selector    => initial_delay,
			     data_input  => in_CSR,
			     data_output => out_CSR);
	
	
end Behavioral;

