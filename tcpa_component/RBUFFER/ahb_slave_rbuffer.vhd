---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  
-- Project Name:  
--
-- Engineers:     Jupiter Bakakeu and Ericles Sousa
-- Create Date:   
-- Description:  
--
--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Company: Department of Computer Science 12, FAU 
-- Engineer: Ericles Sousa
-- 
-- Create Date:    14:45:18 05/14/2014 
-- Design Name:    ahb_example
-- Module Name:    ahb_example - Behavioral 
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
-- AHB example able to stall the processor for a number of cycles
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library work;
use work.AG_BUFFER_type_lib.all;

use work.data_type_pkg.all;     -- for input and output format between amba_interface and tcpa components

entity ahb_slave_rbuffer is
	generic(
		BUFFER_SIZE              : integer               := 4096;
		BUFFER_CHANNEL_SIZE      : integer               := 1024;

		CONFIG_DATA_WIDTH        : integer range 0 to 32 := 32;
		CONFIG_ADDR_WIDTH        : integer range 0 to 32 := 10;
		CONFIG_SIZE              : integer               := 1024;

		CHANNEL_COUNT            : integer range 0 to 32 := 4;
		CHANNEL_DATA_WIDTH       : integer range 0 to 32 := 32;
		CHANNEL_ADDR_WIDTH       : integer range 0 to 64 := 18; -- 2 * INDEX_VECTOR_DATA_WIDTH;

		MAX_DATA_WIDTH           : integer range 0 to 32 := 32; -- max(CONFIG_DATA_WIDTH,CHANNEL_DATA_WIDTH
		NUM_OF_BUFFER_STRUCTURES : integer range 1 to  8 := 4;

		hindex                   : integer               := 0;
		hirq                     : integer               := 0;
			-- haddr                    : integer               := haddr;
			-- hmask                    : integer               := hmask
        SUM_COMPONENT            : integer
	);
	port(
		-- AHB Bus Interface
		ahb_clk                : in  std_ulogic;
		ahb_rstn               : in  std_ulogic;
			-- ahbsi                    : in  ahb_slv_in_type;
			-- ahbso                    : out ahb_slv_out_type
        IF_COMP_data             : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
        rbuffer_IF_data          : out rec_COMP_IF;  

		-- Configuration Write port
		config_clk             : out std_logic;
		config_rst             : out std_logic;
		config_en              : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
		config_we              : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
		config_data            : out std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_DATA_WIDTH) - 1 downto 0);
		config_wr_addr         : out std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_ADDR_WIDTH) - 1 downto 0);
		config_wr_data_out     : in  std_logic_vector((NUM_OF_BUFFER_STRUCTURES*CONFIG_DATA_WIDTH) - 1 downto 0);

		-- Configuration state
		config_start           : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
		restart_ext            : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
		config_soft_rst        : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
		config_done            : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
		AG_buffer_interrupt    : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
--		buffer_interrupts      : in  std_logic_vector(CHANNEL_COUNT downto 0);
		buffer_addr_lsb        : out std_logic_vector(CHANNEL_ADDR_WIDTH-1 downto 0);

		-- Glocal Controller
		gc_reset               : in  std_logic;

		-- Buffer Channel Interface
		cpu_tcpa_buffer         : in cpu_tcpa_buffer_type;
		channel_bus_clk         : out std_logic;
		channel_bus_rst         : out std_logic;
		channel_bus_input_en    : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT - 1 downto 0);
		channel_bus_input_we    : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT - 1 downto 0);
		channel_bus_input_addr  : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_ADDR_WIDTH * CHANNEL_COUNT - 1 downto 0);
		channel_bus_input_data  : out std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0);
		channel_bus_output_data : in  std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_DATA_WIDTH * CHANNEL_COUNT - 1 downto 0)
	);
end;
architecture rtl of ahb_slave_rbuffer is
	-- constant hconfig : ahb_config_type := (
		-- 0      => ahb_device_reg(
			-- VENDOR_CONTRIB,
			-- CONTRIB_CORE1,
			-- 0,
			-- 0,
			-- hirq
		-- ),
		-- 4      => ahb_membar(
			-- haddr,
			-- '0',
			-- '0',
			-- hmask
		-- ),
		-- others => zero32
	-- );

	type tcpa_ahb_slave is record
		hready : std_ulogic;
		en     : std_ulogic;
		wen    : std_ulogic;
		ren    : std_ulogic;
		addr   : std_logic_vector(AHB_LSB_BIT_DECODE - 1 downto 0);
	end record;
	constant FIST_ADDR                       : std_logic_vector(31 downto 0) := ahb_addr_decoding(CHECK_FIRST_ADDR, haddr, hmask);
	constant LAST_ADDR                       : std_logic_vector(31 downto 0) := ahb_addr_decoding(CHECK_lAST_ADDR, haddr, hmask);
	constant FIRST_BUFFER_CONFIG_ADDR        : std_logic_vector(31 downto 0) := ahb_addr_decoding(CHECK_FIRST_BUFFER_CONFIG_ADDR, haddr, hmask);
	constant LAST_BUFFER_CONFIG_ADDR         : std_logic_vector(31 downto 0) := ahb_addr_decoding(CHECK_LAST_BUFFER_CONFIG_ADDR, haddr, hmask);
	constant FIRST_BUFFER_ADDR               : std_logic_vector(31 downto 0) := ahb_addr_decoding(CHECK_FIRST_BUFFER_ADDR, haddr, hmask);
	constant LAST_BUFFER_ADDR                : std_logic_vector(31 downto 0) := ahb_addr_decoding(CHECK_LAST_BUFFER_ADDR, haddr, hmask);
	
	signal r, c                              : tcpa_ahb_slave;
	signal current_addr                      : std_logic_vector(AHB_LSB_BIT_DECODE - 1 downto 0);

	type t_out_selector is array(0 to NUM_OF_BUFFER_STRUCTURES-1) of std_logic_vector(CHANNEL_COUNT downto 0);
	--signal out_selector                    : std_logic_vector(CHANNEL_COUNT downto 0) := (others => '0');
	signal out_selector                      : t_out_selector := (others=>(others=> '0'));

	type t_out_selector_output_data is array(0 to NUM_OF_BUFFER_STRUCTURES-1) of std_logic_vector(MAX_DATA_WIDTH - 1 downto 0);
	signal output_data                       : t_out_selector_output_data := (others=>(others=>'0'));
	signal ahb_output_channel_sel            : t_out_selector;
	signal ahb_output_buffer_sel             : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
	signal ahb_output_final_sel             : integer range 0 to NUM_OF_BUFFER_STRUCTURES-1;

	type t_out_selector_input_data is array(0 to NUM_OF_BUFFER_STRUCTURES-1) of std_logic_vector((CHANNEL_COUNT + 1) * MAX_DATA_WIDTH - 1 downto 0);
--	signal out_selector_input_data           : std_logic_vector((CHANNEL_COUNT + 1) * MAX_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal out_selector_input_data           : t_out_selector_input_data := (others=>(others=>'0'));
 
	signal config_done_r                     : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
	signal AG_buffer_interrupts_r            : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0)                            := (others => '0');
--	signal buffer_interrupts_r               : std_logic_vector(CHANNEL_COUNT downto 0)                            := (others => '0');
	signal non_hierarchical_buffer_interrupt : std_logic := '0';
	signal config_start_r                    : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
	signal restart_r                         : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
	signal config_soft_rst_r                 : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
	signal config_en_i, config_we_i          : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);
	signal isr_catched                       : std_logic;
	signal read_config_flags, temp          : std_logic_vector(NUM_OF_BUFFER_STRUCTURES-1 downto 0);

	type t_address_map is array(0 to NUM_OF_BUFFER_STRUCTURES-1) of integer;
	signal config_addr_map, config_addr_map_debug : t_address_map := (others=>0);
	signal buffer_addr_map, buffer_addr_map_debug : t_address_map := (others=>0);
	signal debug_addr_map : t_address_map := (others=>0);

	component general_Multiplexer is
		generic(
			SEL_WIDTH  : integer range 0 to 32 := CHANNEL_COUNT + 1;
			DATA_WIDTH : integer range 0 to 32 := MAX_DATA_WIDTH
		);
		port(
			select_val  : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			data_input  : in  std_logic_vector(SEL_WIDTH * DATA_WIDTH - 1 downto 0);
			data_output : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	end component general_Multiplexer;

	----attribute syn_preserve : boolean;
	----attribute syn_preserve of r, c : signal is true;
	----attribute syn_keep : boolean;
	----attribute syn_keep of r, c : signal is true;

begin

	--------------------------------------------------------------------------------------
	-- Hardware/Software Interface. Via Software it is possible to configure a set of parameters ...
	--------------------------------------------------------------------------------------

	HW_SW_INTERFACE : process(IF_COMP_data, ahb_rstn, r)       --HW_SW_INTERFACE : process(ahbsi, ahb_rstn, r)
		variable v        : tcpa_ahb_slave;
		variable tmp_addr : std_logic_vector(AHB_LSB_BIT_DECODE - 1 downto 0);
	begin
		v        := r;
		v.hready := '1';
		v.en     := (IF_COMP_data(hindex).hsel and IF_COMP_data(hindex).htrans(1) and IF_COMP_data(hindex).hready);      --(ahbsi.hsel(hindex) and ahbsi.htrans(1) and ahbsi.hready);
		v.wen    := (IF_COMP_data(hindex).hsel and IF_COMP_data(hindex).hready and IF_COMP_data(hindex).hwrite);         --(ahbsi.hsel(hindex) and ahbsi.hready and ahbsi.hwrite);
		v.ren    := (IF_COMP_data(hindex).hsel and IF_COMP_data(hindex).hready and not IF_COMP_data(hindex).hwrite);     --(ahbsi.hsel(hindex) and ahbsi.hready and not ahbsi.hwrite);
		v.addr   := IF_COMP_data(hindex).haddr(AHB_LSB_BIT_DECODE+1 downto 2);                     --ahbsi.haddr(AHB_LSB_BIT_DECODE+1 downto 2);

		if ((r.wen or not r.hready) = '1') then
			tmp_addr := r.addr;
		--else
		elsif (IF_COMP_data(hindex).hsel = '1') then       --elsif (ahbsi.hsel(hindex) = '1') then
			tmp_addr := IF_COMP_data(hindex).haddr(AHB_LSB_BIT_DECODE+1 downto 2); --i.e., (20 downto 2)       --ahbsi.haddr(AHB_LSB_BIT_DECODE+1 downto 2); --i.e., (20 downto 2)
			for buffer_id in 0 to NUM_OF_BUFFER_STRUCTURES-1 loop
				debug_addr_map(buffer_id)  <= to_integer((unsigned(tmp_addr)));
			end loop;	
		end if;

		if ahb_rstn = '0' then
			v.en     := '0';
			v.wen    := '0';
			v.ren    := '1';
			v.hready := '1';
		end if;

		c            <= v;
		rbuffer_IF_data.hready <= r.hready;       --ahbso.hready <= r.hready;
		current_addr <= tmp_addr;
	end process;

	BUFFER_CONFIG_ENABLE : for buffer_id in 0 to NUM_OF_BUFFER_STRUCTURES-1 generate
	config_addr_map(buffer_id) <=  buffer_id*(CONFIG_SIZE+BUFFER_SIZE) + to_integer(unsigned(FIRST_BUFFER_CONFIG_ADDR(CONFIG_ADDR_WIDTH+1 downto 2)   ));
	buffer_addr_map(buffer_id) <=  buffer_id*(CONFIG_SIZE+BUFFER_SIZE) + to_integer(unsigned(FIRST_BUFFER_ADDR(CHANNEL_ADDR_WIDTH+1 downto 2)));
--	debug_addr_map(buffer_id)  <= to_integer((unsigned(current_addr(CHANNEL_ADDR_WIDTH - 1 downto 0))) - config_addr_map(buffer_id));

	generate_label : for i in 0 to CHANNEL_COUNT generate
		CONFIGURATION_GEN : if i = 0 generate
			MAX_COUNT_BIG : if MAX_DATA_WIDTH > CONFIG_DATA_WIDTH generate
				out_selector_input_data(buffer_id)(CONFIG_DATA_WIDTH - 1 downto 0) <= config_wr_data_out((buffer_id+1)*CONFIG_DATA_WIDTH - 1 downto buffer_id*CONFIG_DATA_WIDTH) 
											when (unsigned(r.addr) > config_addr_map(buffer_id)) 
											and (unsigned(r.addr) < config_addr_map(buffer_id)+CONFIG_SIZE)
											else (CONFIG_DATA_WIDTH - 1 downto CHANNEL_COUNT + 4 => '0') & AG_buffer_interrupts_r(buffer_id) & config_done_r(buffer_id) & config_start_r(buffer_id) & config_soft_rst_r(buffer_id);

				out_selector_input_data(buffer_id)(MAX_DATA_WIDTH - 1 downto CONFIG_DATA_WIDTH) <= (MAX_DATA_WIDTH - 1 downto CONFIG_DATA_WIDTH => '0');
			end generate MAX_COUNT_BIG;

			MAX_COUNT_EQUALS : if MAX_DATA_WIDTH = CONFIG_DATA_WIDTH generate
				out_selector_input_data(buffer_id)(MAX_DATA_WIDTH - 1 downto 0) <= config_wr_data_out((buffer_id+1)*CONFIG_DATA_WIDTH - 1 downto buffer_id*CONFIG_DATA_WIDTH) 
											when (unsigned(r.addr) > config_addr_map(buffer_id))
											and (unsigned(r.addr) < config_addr_map(buffer_id)+CONFIG_SIZE)
											else (CONFIG_DATA_WIDTH - 1 downto 4 => '0') & AG_buffer_interrupts_r(buffer_id) & config_done_r(buffer_id) & config_start_r(buffer_id) & config_soft_rst_r(buffer_id);
			end generate MAX_COUNT_EQUALS;

			config_wr_addr((buffer_id+1)*CONFIG_ADDR_WIDTH - 1 downto buffer_id*CONFIG_ADDR_WIDTH)  <= std_logic_vector(unsigned(current_addr(CONFIG_ADDR_WIDTH - 1 downto 0)) - config_addr_map(buffer_id) - 1) 
									when (unsigned(current_addr(CHANNEL_ADDR_WIDTH - 1 downto 0)) > (config_addr_map(buffer_id)))
									and (unsigned(current_addr(CHANNEL_ADDR_WIDTH - 1 downto 0)) < (config_addr_map(buffer_id)+CONFIG_SIZE))
									else current_addr(CONFIG_ADDR_WIDTH - 1 downto 0);
			config_en(buffer_id)       <= '1' 
					when (((r.en) = '1') 
					and (unsigned(r.addr) > config_addr_map(buffer_id)) 
					and unsigned(r.addr) < config_addr_map(buffer_id)+CONFIG_SIZE) -- greater than FIRST_BUFFER_CONFIG_ADDR, because the first position is reserved for reset and status signals
					or (((c.en and c.ren) = '1') 
					and (unsigned(c.addr) > config_addr_map(buffer_id)) 
					and unsigned(c.addr) < config_addr_map(buffer_id)+CONFIG_SIZE) -- greater than FIRST_BUFFER_CONFIG_ADDR, because the first position is reserved for reset and status signals
					else '0';

			config_we(buffer_id)       <= '1' 
					when ((r.en and r.wen) = '1') 
					and (unsigned(r.addr) > config_addr_map(buffer_id)) 
					and (unsigned(r.addr) < config_addr_map(buffer_id)+CONFIG_SIZE) 
					else '0';

			config_data((buffer_id+1)*CONFIG_DATA_WIDTH - 1 downto buffer_id*CONFIG_DATA_WIDTH)     <= IF_COMP_data(hindex).hwdata(CONFIG_DATA_WIDTH - 1 downto 0);     --ahbsi.hwdata(CONFIG_DATA_WIDTH - 1 downto 0) 
									when ((r.en and r.wen) = '1') 
									and (unsigned(r.addr) > config_addr_map(buffer_id)) 
									and (unsigned(r.addr) < config_addr_map(buffer_id)+CONFIG_SIZE)
									else (CONFIG_DATA_WIDTH - 1 downto 0 => '0');

			out_selector(buffer_id)(i)	<= '1' 
						when (((r.en and r.ren) = '1') 
						and (unsigned(r.addr) >=  config_addr_map(buffer_id) + (i * (unsigned(FIRST_BUFFER_ADDR(CHANNEL_ADDR_WIDTH+1 downto 2)))) 
						and unsigned(r.addr) < config_addr_map(buffer_id)+CONFIG_SIZE + ((i + 1) * (unsigned(FIRST_BUFFER_ADDR(CHANNEL_ADDR_WIDTH+1 downto 2)))))) 
--						and (unsigned(r.addr) >=  config_addr_map(buffer_id))
--						and (unsigned(r.addr) < config_addr_map(buffer_id)+CONFIG_SIZE)) 
						else '0';
				
			ahb_output_channel_sel(buffer_id)(i)   <= '1' when
						(((r.en and r.ren) = '1') 
						and (unsigned(r.addr) >= config_addr_map(buffer_id))
						and (unsigned(r.addr) < config_addr_map(buffer_id)+CONFIG_SIZE)) 
						else '0';


			end generate CONFIGURATION_GEN;

			CHANNEL_GEN : if not (i = 0) generate
				MAX_COUNT_BIG : if MAX_DATA_WIDTH > CHANNEL_DATA_WIDTH generate
					out_selector_input_data(buffer_id)(i * MAX_DATA_WIDTH + CHANNEL_DATA_WIDTH - 1 downto i * MAX_DATA_WIDTH)       <= 
					channel_bus_output_data((buffer_id*CHANNEL_DATA_WIDTH*CHANNEL_COUNT) + i * CHANNEL_DATA_WIDTH - 1 downto (buffer_id*CHANNEL_DATA_WIDTH*CHANNEL_COUNT) + (i - 1) * CHANNEL_DATA_WIDTH);
					out_selector_input_data(buffer_id)((i + 1) * MAX_DATA_WIDTH - 1 downto i * MAX_DATA_WIDTH + CHANNEL_DATA_WIDTH) <= (MAX_DATA_WIDTH - 1 downto CHANNEL_DATA_WIDTH => '0');
				end generate MAX_COUNT_BIG;

				MAX_COUNT_EQUALS : if MAX_DATA_WIDTH = CHANNEL_DATA_WIDTH generate
					out_selector_input_data(buffer_id)((i + 1) * MAX_DATA_WIDTH - 1 downto i * MAX_DATA_WIDTH) <= 
					channel_bus_output_data((buffer_id*CHANNEL_DATA_WIDTH*CHANNEL_COUNT) + i * CHANNEL_DATA_WIDTH - 1 downto (buffer_id*CHANNEL_DATA_WIDTH*CHANNEL_COUNT) + (i - 1) * CHANNEL_DATA_WIDTH);
				end generate MAX_COUNT_EQUALS;
				--(((i+1)*CHANNEL_DATA_WIDTH*CHANNEL_COUNT)-1 downto i*CHANNEL_DATA_WIDTH*CHANNEL_COUNT)
				--channel_bus_input_addr((buffer_id*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH) + i * CHANNEL_ADDR_WIDTH - 1 downto (buffer_id*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH) + (i - 1) * CHANNEL_ADDR_WIDTH) <= current_addr(CHANNEL_ADDR_WIDTH - 1 downto 0);
				channel_bus_input_addr((buffer_id*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH) + i * CHANNEL_ADDR_WIDTH - 1 downto (buffer_id*CHANNEL_COUNT*CHANNEL_ADDR_WIDTH) + (i - 1) * CHANNEL_ADDR_WIDTH) <= 
				std_logic_vector((unsigned(current_addr)) - config_addr_map(buffer_id));


				channel_bus_input_en((buffer_id*CHANNEL_COUNT) + i - 1)                                                            <= '1' when 
				((r.en = '1') and
				unsigned(r.addr) >= buffer_addr_map(buffer_id) and
				unsigned(r.addr)  < buffer_addr_map(buffer_id) + BUFFER_SIZE) or
				((c.en = '1') and
				unsigned(c.addr) >= buffer_addr_map(buffer_id) and 
				unsigned(c.addr)  < (buffer_addr_map(buffer_id) + BUFFER_SIZE))  else '0';

				channel_bus_input_we((buffer_id)*CHANNEL_COUNT + i - 1)                                                          <= '1' when 
				(((r.en and r.wen) = '1') and 
				unsigned(r.addr) >= buffer_addr_map(buffer_id) and
				unsigned(r.addr)  < buffer_addr_map(buffer_id) + BUFFER_SIZE)
				else '0';

				channel_bus_input_data((buffer_id*CHANNEL_COUNT*CHANNEL_DATA_WIDTH) + i * CHANNEL_DATA_WIDTH - 1 downto (buffer_id*CHANNEL_COUNT*CHANNEL_DATA_WIDTH) + (i - 1) * CHANNEL_DATA_WIDTH) <= IF_COMP_data(hindex).hwdata(CHANNEL_DATA_WIDTH - 1 downto 0) when --ahbsi.hwdata(CHANNEL_DATA_WIDTH - 1 downto 0) when 
				(((r.en and r.wen) = '1') and 
				unsigned(r.addr) >= (buffer_addr_map(buffer_id)) and
				unsigned(r.addr)  < (buffer_addr_map(buffer_id) + BUFFER_SIZE))
				else (others => '0');

				out_selector(buffer_id)(i)                                                                        <= '1' when 
				((r.en and r.ren) = '1') 
				and (unsigned(r.addr)) >= buffer_addr_map(buffer_id) + ((i-1) * CUR_DEFAULT_BUFFER_CHANNEL_SIZE) 
				and unsigned(r.addr) < buffer_addr_map(buffer_id) + ((i * CUR_DEFAULT_BUFFER_CHANNEL_SIZE))
			--	and (unsigned(r.addr) >= buffer_addr_map(buffer_id)) 
			--	and (unsigned(r.addr) < buffer_addr_map(buffer_id) + BUFFER_SIZE)
				else '0';

				ahb_output_channel_sel(buffer_id)(i)                                                                      <= '1' when
				(((r.en and r.ren) = '1') 
				and (unsigned(r.addr) >= buffer_addr_map(buffer_id)) 
				and (unsigned(r.addr) < buffer_addr_map(buffer_id)+BUFFER_SIZE))
				else '0';

			end generate CHANNEL_GEN;
		end generate generate_label;

		--------------------------------------------------------------------------------------
		-- Generate Channel output
		--------------------------------------------------------------------------------------
		OUTPUT_MULTIPLEXER : general_Multiplexer
			generic map(
				SEL_WIDTH  => CHANNEL_COUNT + 1,
				DATA_WIDTH => MAX_DATA_WIDTH
			)
			port map(
				select_val  => out_selector(buffer_id),
				data_input  => out_selector_input_data(buffer_id),
				data_output => output_data(buffer_id)
			);

			ahb_output_buffer_sel(buffer_id) <= '1' when (not ((ahb_output_channel_sel(buffer_id)) = (CHANNEL_COUNT downto 0 => '0'))) else '0';
		end generate BUFFER_CONFIG_ENABLE;

		Configuration_State_Proc : process(ahb_clk, ahb_rstn) is
		begin
			if ahb_rstn = '0' then
				config_start_r      <= (others=>'0');
				restart_r           <= (others=>'0');
				config_soft_rst_r   <= (others=>'0');
				config_done_r       <= (others=>'0');
				AG_buffer_interrupts_r <= (others => '0');
				buffer_addr_lsb     <= (others=>'0');
			elsif rising_edge(ahb_clk) then
				config_done_r       <= config_done;
				AG_buffer_interrupts_r <= AG_buffer_interrupt;
				buffer_addr_lsb(CHANNEL_ADDR_WIDTH-1 downto 0)        <= FIRST_BUFFER_ADDR(CHANNEL_ADDR_WIDTH+1 downto 2); --propagating a constant value through a signal
				for buffer_id in 0 to NUM_OF_BUFFER_STRUCTURES-1 loop
					if ((r.en and r.wen) = '1') and (unsigned(r.addr) = config_addr_map(buffer_id)) then
						config_soft_rst_r(buffer_id) <= IF_COMP_data(hindex).hwdata(0);        --ahbsi.hwdata(0);
						config_start_r(buffer_id)    <= IF_COMP_data(hindex).hwdata(1);        --ahbsi.hwdata(1);
						restart_r(buffer_id)         <= IF_COMP_data(hindex).hwdata(2);        --ahbsi.hwdata(2);
					end if;
				end loop;
			end if;
		end process Configuration_State_Proc;
				
		--Because of the log operation, buffer structures with higher index have higher priority
		ahb_output_final_sel <= log2_32bits(to_integer(unsigned(ahb_output_buffer_sel))) when ((r.en or c.en) = '1');
		rbuffer_IF_data.hrdata(MAX_DATA_WIDTH - 1 downto 0) <= output_data(ahb_output_final_sel);     --ahbso.hrdata(MAX_DATA_WIDTH - 1 downto 0) <= output_data(ahb_output_final_sel);
		--ahbso.hrdata(MAX_DATA_WIDTH - 1 downto 0) <= output_data(0);

		process(ahb_rstn, gc_reset, ahb_clk) begin
			if (ahb_rstn = '0') or (gc_reset = '1') then
				isr_catched <= '0';
			 
			elsif rising_edge(ahb_clk) then
				non_hierarchical_buffer_interrupt <= '0';
				if(isr_catched = '0') then	
					if unsigned(AG_buffer_interrupts_r) >= 1 then
						non_hierarchical_buffer_interrupt <= '1';
						isr_catched <= '1';
					end if;
				end if;
			end if;
		end process;

		--------------------------------------------------------------------------------------
		-- Common Bus Interfaces
		--------------------------------------------------------------------------------------
		channel_bus_clk <= ahb_clk;
		channel_bus_rst <= not ahb_rstn;
		config_clk      <= ahb_clk;
		config_rst      <= not ahb_rstn;

		config_soft_rst <= config_soft_rst_r;
		config_start    <= config_start_r;
		restart_ext     <= restart_r;

		-- ahbso.hresp      <= HRESP_OKAY;
		-- ahbso.hsplit     <= (others => '0');
		-- --ahbso.hirq(hirq) <= '0';
		-- ahbso.hirq(hirq) <= non_hierarchical_buffer_interrupt;
		-- ahbso.hconfig    <= hconfig;
		-- ahbso.hindex     <= hindex;
		rbuffer_IF_data.hresp      <= HRESP_OKAY;
		rbuffer_IF_data.hsplit     <= (others => '0');
		rbuffer_IF_data.hirq       <= non_hierarchical_buffer_interrupt;
		rbuffer_IF_data.hindex     <= hindex;
        
        
        
        
		regs : process(ahb_clk)
		begin
			if rising_edge(ahb_clk) then
				r <= c;
			end if;
		end process;
	end;



