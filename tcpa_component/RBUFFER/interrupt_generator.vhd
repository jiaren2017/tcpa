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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
library work;
use work.AG_BUFFER_type_lib.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity interrupt_generator is
	generic(
		--###########################################################################
		-- Reconfigurable Buffer parameters
		--###########################################################################
		BUFFER_SIZE                           : integer               := 4096;
		BUFFER_SIZE_ADDR_WIDTH                : integer               := 12;
		BUFFER_CHANNEL_SIZE                   : integer               := 1024;
		BUFFER_CHANNEL_ADDR_WIDTH             : integer               := 10;
	        BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := TRUE;
	        EN_ELASTIC_BUFFER                     : boolean               := FALSE;

		-- Pixel Buffer Mode Architecture
		ENABLE_PIXEL_BUFFER_MODE	      : integer range 0 to 31 := 1;

		-- RAMs Parameters
		ADDR_WIDTH                            : integer range 0 to 32 := 18;
		DATA_WIDTH                            : integer range 0 to 32 := 32;
		CONFIG_DATA_WIDTH                     : integer range 0 to 32 := 32;
		ADDR_HEADER_WIDTH                     : integer range 0 to 54 := 8; 
		SEL_REG_WIDTH                         : integer range 0 to 8  := 4;
		-- Channel Count
		MAX_CHANNEL_CNT                       : integer               := 4
		--###########################################################################		
	);
	port(
		rst               : in std_logic; 
		start             : in std_logic; 
		buffer_direction  : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		irq_channel_depth : in std_logic_vector(MAX_CHANNEL_CNT * CONFIG_DATA_WIDTH -1 downto 0);
		irq_channel_en    : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		irq_clear         : in std_logic;
		buffer_event      : out std_logic;

		-- Port A -- Always connected to Bus side
		clka              : in std_logic;
		ena               : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		wea               : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		addra             : in std_logic_vector(ADDR_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);

		-- Port B -- Always connected to TCPA side
		clkb              : in std_logic;
		enb               : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		web               : in std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
		addrb             : in std_logic_vector(ADDR_WIDTH * MAX_CHANNEL_CNT - 1 downto 0);
		irq_out           : out std_logic_vector(MAX_CHANNEL_CNT -1 downto 0)
	);
end interrupt_generator;

architecture Behavioral of interrupt_generator is
type t_irq_channel_depth is array (MAX_CHANNEL_CNT - 1 downto 0) of  std_logic_vector(CONFIG_DATA_WIDTH - 1 downto 0);

type t_channel_addr is array (MAX_CHANNEL_CNT - 1 downto 0) of  std_logic_vector(BUFFER_CHANNEL_ADDR_WIDTH - 1 downto 0);
type t_buffer_addr is array (MAX_CHANNEL_CNT - 1 downto 0) of  std_logic_vector(ADDR_WIDTH - 1 downto 0);

signal tcpa_w_addrb, tcpa_r_addrb : t_buffer_addr;
signal bus_w_addra, bus_r_addra : t_buffer_addr;

signal tcpa_w_channel_addrb, tcpa_r_channel_addrb : t_channel_addr;
signal bus_w_channel_addra, bus_r_channel_addra   : t_channel_addr;

signal bus_wen, bus_ren   : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
signal tcpa_wen, tcpa_ren : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);

signal channel_depth : t_irq_channel_depth;
signal irq_en, sig_irq_out : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);

signal input_buffer, output_buffer  : std_logic;
signal buffer_empty, buffer_full    : std_logic; 

signal channel_full  : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
signal channel_empty : std_logic_vector(MAX_CHANNEL_CNT - 1 downto 0);
begin


	generate_buffer_irq : process(clkb, rst)
	begin
		if(rst = '1') then
			buffer_full <= '0';	
			buffer_empty <= '0';	

		elsif(clkb'event and clkb = '1') then
			if(start = '1') then
				if(input_buffer = '1') then
					--buffer is considered empty when all channels are empty
					if(((channel_empty = (MAX_CHANNEL_CNT - 1 downto 0  => '1')))) then
						--Stop TCPA
						buffer_empty <= '1';
					else
						buffer_empty <= '0';
					end if;
				elsif(output_buffer = '1') then
					--Buffer is considered full when all channels are full
					if(((channel_full = (MAX_CHANNEL_CNT - 1 downto 0  => '1')))) then
						--Stop TCPA
						buffer_full <= '1';
					else
						buffer_full <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	generate_channel_irq : process(clkb, rst)
	begin
		if(rst = '1') then
			channel_full <= (others=>'0');	
			channel_empty <= (others=>'1');	
			irq_en <= (others=>'0');	
			sig_irq_out    <= (others=>'0');

		elsif(clkb'event and clkb = '1') then

			for i in 0 to MAX_CHANNEL_CNT -1 loop
				irq_en(i) <= irq_channel_en(i);	
				sig_irq_out(i) <= '0';
					
				if(irq_en(i) = '1') then
					--If input buffer. It means, Bus write into this buffer and TCPA reads from it
					if(input_buffer = '1') then
						if(irq_clear = '1') then
							if(sig_irq_out(i) = '1') then
								channel_empty(i) <= '0';
								sig_irq_out(i) <= '0';
							end if;
						end if;
						if((bus_wen(i) = '1') and (unsigned(bus_w_channel_addra(i)) >= unsigned(tcpa_r_channel_addrb(i)))) then
							channel_empty(i) <= '0';
						--IRQ condition. Here, we only raise an IRQ	
						elsif( (tcpa_ren(i) = '1') and ((unsigned(tcpa_r_addrb(i)) = unsigned(channel_depth(i))) or (unsigned(tcpa_r_channel_addrb(i)) = unsigned(channel_depth(i)))) )then
							channel_empty(i) <= '1';
							sig_irq_out(i) <= '1';
						end if;

					--If Output buffer. It means, Bus read from this buffer and TCPA writes into it
					else
						if(irq_clear = '1') then
							if(sig_irq_out(i) = '1') then
								channel_full(i) <= '0';
								sig_irq_out(i) <= '0';
							end if;
                                                end if;
						if((bus_ren(i) = '1') and (unsigned(bus_r_channel_addra(i)) >= unsigned(tcpa_w_channel_addrb(i)))) then
							channel_full(i) <= '0';
						elsif( (tcpa_wen(i) = '1') and ((unsigned(tcpa_w_addrb(i)) = unsigned(channel_depth(i))) or (unsigned(tcpa_w_channel_addrb(i)) = unsigned(channel_depth(i)))) ) then
							channel_full(i) <= '1';
							sig_irq_out(i) <= '1';
						end if;
					end if;
				end if;
			end loop;
			
		end if;
	end process;

	reg_bus_addra : process(clka, addra, wea, ena, input_buffer, output_buffer)
	begin	
		if(clka'event and clka = '1') then
			for i in 0 to MAX_CHANNEL_CNT - 1 loop
				bus_wen(i) <= '0';
				bus_ren(i) <= '0';
				if(((wea(i) and ena(i) and input_buffer)  = '1')) then
					bus_wen(i) <= '1';

				elsif(((wea(i) = '0') and ((ena(i) and output_buffer) = '1'))) then
					bus_ren(i) <= '1';
				end if;
			end loop;
		end if;
	end process;

	reg_tcpa_addrb : process(clkb, addrb, web, enb, input_buffer, output_buffer)
	begin	
		if(clkb'event and clkb = '1') then
			for i in 0 to MAX_CHANNEL_CNT - 1 loop
				tcpa_ren(i) <= '0';
				tcpa_wen(i) <= '0';
				if(start = '1') then
					if(((web(i) and enb(i) and output_buffer)  = '1')) then
						tcpa_wen(i) <= '1';
	
					elsif(((web(i) = '0') and ((enb(i) and input_buffer) = '1'))) then
						tcpa_ren(i) <= '1';
					end if;
				end if;
			end loop;
		end if;
	end process;

	--Note: Currently, only the individual channel_depth are considered for raising an IRQ.
	-- In future, we shall consider the entire address in case of concatenated buffers.

	--This signal goes to RBuffer_hirq.vhd
	irq_out <= sig_irq_out;

	--in_CSR(CHANNEL_ADDR_WIDTH) <= '1' when tmp_out_valid = (R - 1 downto 0 => '1') else '0';
	input_buffer  <= '1' when buffer_direction = (MAX_CHANNEL_CNT-1 downto 0 => '1') else '0';
	output_buffer <= not input_buffer; 


	--An buffer event will occur when all channel are empty or full
	buffer_event <= '1' when ((start = '1') and ((buffer_full or buffer_empty) = '1')) else '0';

	irq_gen : for i in 0 to MAX_CHANNEL_CNT -1 generate
		channel_depth(i) <= irq_channel_depth((i+1)*CONFIG_DATA_WIDTH -1 downto i*CONFIG_DATA_WIDTH) when irq_en(i) = '1' else (others=>'0') when rst = '1';
	
		--Look at the address of the entire buffer structure	
		bus_w_addra(i) <= addra((i+1)*ADDR_WIDTH - 1  downto i*ADDR_WIDTH) when bus_wen(i) = '1' else (others=>'0') when rst = '1'; 
		bus_r_addra(i) <= addrb((i+1)*ADDR_WIDTH - 1  downto i*ADDR_WIDTH) when bus_ren(i) = '1' else (others=>'0') when rst = '1'; 
		tcpa_w_addrb(i) <= addrb((i+1)*ADDR_WIDTH - 1  downto i*ADDR_WIDTH) when tcpa_wen(i) = '1' else (others=>'0') when rst = '1';
		tcpa_r_addrb(i) <= addrb((i+1)*ADDR_WIDTH - 1  downto i*ADDR_WIDTH) when tcpa_ren(i) = '1' else (others=>'0') when rst = '1';

		--Look at the addresses of each buffer channel
		bus_w_channel_addra(i)  <= addra((i+1)*ADDR_WIDTH - (ADDR_WIDTH-BUFFER_CHANNEL_ADDR_WIDTH) - 1  downto i*ADDR_WIDTH) when (bus_wen(i) and ena(i)) = '1' else (others=>'0') when rst = '1'; 
		bus_r_channel_addra(i)  <= addrb((i+1)*ADDR_WIDTH - (ADDR_WIDTH-BUFFER_CHANNEL_ADDR_WIDTH) - 1  downto i*ADDR_WIDTH) when (bus_ren(i) and ena(i)) = '1' else (others=>'0') when rst = '1'; 
		tcpa_w_channel_addrb(i) <= addrb((i+1)*ADDR_WIDTH - (ADDR_WIDTH-BUFFER_CHANNEL_ADDR_WIDTH) - 1  downto i*ADDR_WIDTH) when (tcpa_wen(i) and enb(i)) = '1' else (others=>'0') when rst = '1';
		tcpa_r_channel_addrb(i) <= addrb((i+1)*ADDR_WIDTH - (ADDR_WIDTH-BUFFER_CHANNEL_ADDR_WIDTH) - 1  downto i*ADDR_WIDTH) when (tcpa_ren(i) and enb(i)) = '1' else (others=>'0') when rst = '1';

	end generate;
end Behavioral;



