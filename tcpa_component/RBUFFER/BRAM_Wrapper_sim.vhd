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
-- Create Date:    14:09:21 08/09/2014 
-- Design Name: 
-- Module Name:    BRAM_Wrapper - Behavioral 
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

entity BRAM_Wrapper is
	generic(
		--###########################################################################
		-- BRAM_Wrapper parameters, do not add to or delete
		--###########################################################################
		BUFFER_SIZE                                       : integer               := 4096;
		BUFFER_SIZE_ADDR_WIDTH                            : integer               := 12;
		BUFFER_CHANNEL_SIZE                               : integer               := 1024;
		BUFFER_CHANNEL_ADDR_WIDTH                         : integer               := 10;
	        BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO             : boolean               := TRUE;
	        EN_ELASTIC_BUFFER                                 : boolean               := FALSE;
		DATA_WIDTH                                        : integer range 0 to 32 := 32;
		ADDR_WIDTH                                        : integer range 0 to 32 := 18;
		ADDR_HEADER_WIDTH                                 : integer range 0 to 32 := 8;
		SEL_REG_WIDTH                                     : integer range 0 to 8  := 3
	--###########################################################################		
	);
	port(
		rst                           : IN STD_LOGIC;
		-- Port A
		clka                          : IN  STD_LOGIC;
		ena                           : in  std_logic;
		wea                           : in  std_logic;
		addra                         : IN  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
		dina                          : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		douta                         : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		second_clka                   : IN  STD_LOGIC;
		second_ena                    : in  std_logic;
		second_addra                  : IN  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
		second_dina                   : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		config_header_addr_to_match_a : in  std_logic_vector(ADDR_HEADER_WIDTH - 1 downto 0);
		config_width_sel_a            : in  std_logic_vector(SEL_REG_WIDTH - 1 downto 0);
		config_use_second_a           : in  std_logic;

		-- Port B
		clkb                          : IN  STD_LOGIC;
		enb                           : in  std_logic;
		addrb                         : IN  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
		dinb                          : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		doutb                         : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		config_header_addr_to_match_b : in  std_logic_vector(ADDR_HEADER_WIDTH - 1 downto 0);
		config_width_sel_b            : in  std_logic_vector(SEL_REG_WIDTH - 1 downto 0);
		
		buffer_addr_lsb               : in std_logic_vector(ADDR_WIDTH - 1 downto 0);

		-- Direction
		buffer_direction              : in  std_logic; -- '1' == Data flows from portA to portB and in the inverse direction if set to '0'

		filtered_en_out_a             : out std_logic := '0';
		filtered_en_out_b             : out std_logic := '0'
	);
end BRAM_Wrapper;

architecture Behavioral of BRAM_Wrapper is
	---------------------------------- Signals ------------------------------------
	signal tmp_clk_a     : std_logic;
	signal tmp_din_a     : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal tmp_addr_a    : std_logic_vector(BUFFER_CHANNEL_ADDR_WIDTH-1 downto 0);
	signal tmp_addr_b    : std_logic_vector(BUFFER_CHANNEL_ADDR_WIDTH-1 downto 0);
	signal filtered_ena  : std_logic := '0';
	signal filtered_enb  : std_logic := '0';
	signal porta_we      : std_logic_vector(3 downto 0);
	signal portb_we      : std_logic_vector(3 downto 0);
	signal clka_i        : std_logic;
	signal clkb_i        : std_logic;
	signal second_clka_i : std_logic;
	signal dinb_s        : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	signal enb_s         : std_logic;
	signal stop          : std_logic;
	signal msb_en_a, msb_en_b   : std_logic_vector(BUFFER_SIZE_ADDR_WIDTH-1 downto 0);
	---------------------------------- End Signals --------------------------------

	---------------------------------- Attribute ----------------------------------
	attribute BUFFER_TYPE : string;
	attribute BUFFER_TYPE of tmp_clk_a : signal is "BUFG";
	attribute CLOCK_SIGNAL : string;
	attribute CLOCK_SIGNAL of clka_i : signal is "yes";
	attribute CLOCK_SIGNAL of clkb_i : signal is "yes";
	attribute CLOCK_SIGNAL of second_clka_i : signal is "yes";
	---------------------------------- End Attribute ------------------------------

	---------------------------------- Components ---------------------------------
	component Enable_Logic is
		generic(
			SEL_WIDTH                             : integer range 0 to 8  := SEL_REG_WIDTH;
			ADDR_WIDTH                            : integer range 0 to 32 := ADDR_HEADER_WIDTH;
	        	BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := TRUE;
		        EN_ELASTIC_BUFFER                     : boolean               := FALSE
		);
		port(
			header_addr_to_match : in  std_logic_vector(ADDR_HEADER_WIDTH - 1 downto 0);
			config_width_sel     : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			config_use_second    : in  std_logic;
			input_1_header_addr  : in  std_logic_vector(ADDR_HEADER_WIDTH - 1 downto 0);
			input_2_header_addr  : in  std_logic_vector(ADDR_HEADER_WIDTH - 1 downto 0);
			input_1_en           : in  std_logic;
			input_2_en           : in  std_logic;
			en_output            : out std_logic
		);
	end component;

	COMPONENT BRAM_infered
		generic(
		        BUFFER_SIZE               : integer               := 4096;
		        BUFFER_CHANNEL_SIZE       : integer               := 1024;
			BUFFER_CHANNEL_ADDR_WIDTH : integer       := 10;
			DATA_WIDTH                : integer range 0 to 32 := DATA_WIDTH
		);
		PORT(
			-- Port A
			clka  : IN  STD_LOGIC;
			ena   : IN  STD_LOGIC;
			wea   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			addra : IN  STD_LOGIC_VECTOR(BUFFER_CHANNEL_ADDR_WIDTH-1 DOWNTO 0);
			dina  : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		
			-- Port B
			clkb  : IN  STD_LOGIC;
			enb   : IN  STD_LOGIC;
			web   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			addrb : IN  STD_LOGIC_VECTOR(BUFFER_CHANNEL_ADDR_WIDTH-1 DOWNTO 0);
			dinb  : IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
			doutb : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
		);
	END COMPONENT;
---------------------------------- End Components -----------------------------
begin
--	process(clkb, rst) begin
--		if rst = '1' then
--			stop <= '0';
--
--		elsif rising_edge(clkb) then
--			--dinb_s <= dinb;
--			--tmp_addr_b <= addrb(9 downto 0);
--			--enb_s <= enb;
--			enb_s <= '0' when signed(addrb(7 downto 0)) = x"07" else enb;
--			if stop = '0' then
--				if (signed(addrb(7 downto 0)) = x"07") then
--					if enb = '1' then
--						stop <= '1';
--					end if;
--				end if;
--			else
--				enb_s <= '0';
--				tmp_addr_b <= (others=>'0');
--				dinb_s <= (others=>'0');
--
--			end if;
--		end if;
--	end process;

--	process(stop, addrb, enb) begin
--		case stop is 
--			when '1' =>
--				enb_s <= '0';
--				tmp_addr_b <= (others=>'0');
--				dinb_s <= (others=>'0');
--			when '0' =>
--				dinb_s <= dinb;
--				tmp_addr_b <= addrb(9 downto 0);
--				enb_s <= enb;
--			when others =>
--				null;
--		end case;
--	end process;

	-- port directions
	porta_we <= wea & wea & wea & wea when config_use_second_a = '0' else second_ena&second_ena&second_ena&second_ena;
	portb_we <= (others=>'1') when buffer_direction = '0' else (others=>'0');

	filtered_en_out_a <= filtered_ena;
	filtered_en_out_b <= filtered_enb;
	clka_i            <= clka;
	clkb_i            <= clkb;
	second_clka_i     <= second_clka;
        msb_en_a            <= std_logic_vector(unsigned(addra(BUFFER_SIZE_ADDR_WIDTH-1 downto 0)) - unsigned(buffer_addr_lsb(BUFFER_SIZE_ADDR_WIDTH-1 downto 0)));
        msb_en_b            <= std_logic_vector(unsigned(addrb(BUFFER_SIZE_ADDR_WIDTH-1 downto 0)));

	-- Enable Logic for Port A (Data may come from bus, if it is configure as a addressable RAM. However, data may also come from the previous buffer if it is working as a pixel buffer)
	buffer_enable_logic_port_a : Enable_Logic
		generic map(
			SEL_WIDTH                             => SEL_REG_WIDTH,
			ADDR_WIDTH                            => ADDR_HEADER_WIDTH,
	        	BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
		        EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER
		)
		port map(
			header_addr_to_match => config_header_addr_to_match_a,
			config_width_sel     => config_width_sel_a,
			config_use_second    => config_use_second_a,
			input_1_header_addr  => msb_en_a(BUFFER_SIZE_ADDR_WIDTH-1 downto BUFFER_SIZE_ADDR_WIDTH-ADDR_HEADER_WIDTH),
			input_2_header_addr  => second_addra(ADDR_WIDTH - 1 downto ADDR_WIDTH - ADDR_HEADER_WIDTH),
			input_1_en           => ena,
			input_2_en           => second_ena,
			en_output            => filtered_ena
		);

	-- Internaal BRAM
	--if Pixel buffer is used config_use_second_a is '1'. Therefore, the clock would come from the AG
	--Otherwise, the clock is given by the bus
	tmp_clk_a <= clka_i when config_use_second_a = '0' else second_clka_i;

	tmp_addr_a <= std_logic_vector((unsigned(addra(BUFFER_CHANNEL_ADDR_WIDTH-1 downto 0))) - (unsigned(buffer_addr_lsb(BUFFER_CHANNEL_ADDR_WIDTH-1 downto 0))))  when config_use_second_a = '0' else second_addra(BUFFER_CHANNEL_ADDR_WIDTH-1 downto 0);
	tmp_addr_b <= addrb(BUFFER_CHANNEL_ADDR_WIDTH-1 downto 0);
	tmp_din_a  <= dina when config_use_second_a = '0' else second_dina;
	internal_BRAM : BRAM_infered
		generic map(
		        BUFFER_SIZE               => BUFFER_SIZE,
		        BUFFER_CHANNEL_SIZE       => BUFFER_CHANNEL_SIZE,
			BUFFER_CHANNEL_ADDR_WIDTH => BUFFER_CHANNEL_ADDR_WIDTH,
			DATA_WIDTH                => DATA_WIDTH
		)
		PORT MAP(
			clka  => tmp_clk_a,
			ena   => filtered_ena,
			wea   => porta_we,
			addra => tmp_addr_a,
			dina  => tmp_din_a,
			douta => douta,
			clkb  => clkb_i,
			enb   => filtered_enb,
			web   => portb_we,
			addrb => tmp_addr_b,
			dinb  => dinb,
			doutb => doutb
		);

	-- Enable Logic for Port B (Here, data always come from TCPA)
	buffer_enable_logic_port_b : Enable_Logic
		generic map(
			SEL_WIDTH                             => SEL_REG_WIDTH,
			ADDR_WIDTH                            => ADDR_HEADER_WIDTH,
	        	BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO => BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO,
		        EN_ELASTIC_BUFFER                     => EN_ELASTIC_BUFFER
		)
		port map(
			header_addr_to_match => config_header_addr_to_match_b,
			config_width_sel     => config_width_sel_b,
			config_use_second    => '1',
			input_1_en           => '0',
			input_2_en           => enb,
			input_1_header_addr  => (ADDR_HEADER_WIDTH - 1 downto 0 => '1'),
			--input_2_header_addr  => addrb(ADDR_WIDTH - 1 downto ADDR_WIDTH - ADDR_HEADER_WIDTH),
			input_2_header_addr  => msb_en_b(BUFFER_SIZE_ADDR_WIDTH-1 downto BUFFER_SIZE_ADDR_WIDTH-ADDR_HEADER_WIDTH),
			en_output            => filtered_enb
		);

end Behavioral;

