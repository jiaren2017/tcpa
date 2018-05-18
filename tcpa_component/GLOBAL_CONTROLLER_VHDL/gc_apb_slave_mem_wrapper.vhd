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

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib; 
use grlib.amba.all; 
use grlib.devices.all;
library gaisler; 
use gaisler.misc.all;
use work.data_type_pkg.all;     -- for input and output format between amba_interface and tcpa components


entity gc_apb_slave_mem_wrapper is
	generic (
				pindex : integer := 0;
				-- paddr : integer  := 0;
				-- pmask : integer  := 16#ff0#;
                pirq : integer   := 0;
				NO_OF_WORDS      : integer := 1024;		
                SUM_COMPONENT   : integer
			);
	port (
			rstn        : in std_ulogic;
			clk         : in std_ulogic;
			start       : in  std_logic;
			stop        : in  std_logic;
			--apbi        : in apb_slv_in_type;
			conf_en     : in std_ulogic;
			rnready     : in std_ulogic;
			config_done : in std_ulogic;			
			gc_done     : in std_ulogic;			
			gc_irq      : out std_logic;
			--apbo        : out apb_slv_out_type;
			dout        : out std_logic_vector(31 downto 0);
			pdone       : out std_ulogic;
			gc_reset    : out std_ulogic;

            IF_COMP_data    : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
            GC_IF_data      : out rec_COMP_IF   --gc_apb_slave_mem_wrapper
			
		);
end gc_apb_slave_mem_wrapper;

architecture rtl of gc_apb_slave_mem_wrapper is

		constant REVISION : integer := 0;
		-- constant PCONFIG : apb_config_type := (
												-- 0 => ahb_device_reg (VENDOR_CONTRIB, CONTRIB_CORE1, 0, REVISION, pirq),
												-- 1 => apb_iobar(paddr, pmask)
											  -- );
			
		signal isr_en, isr_en_reg     : std_logic_vector(31 downto 0);
		signal delay_counter          : std_logic_vector(31 downto 0);
		signal counter                : integer;
		signal delay_counter_reg      : integer;
		signal irq, gc_irq_reg, pdone_reg : std_logic;	
		signal start_counter          : std_logic;

		--component definition
		component gc_apb_slave_mem
			generic (
						NO_OF_WORDS	: integer := 1024
					);
			port (
					clk 	: in std_ulogic;
					resetn	: in std_ulogic;
					paddr	: in std_logic_vector(31 downto 0);
					pwrite	: in std_ulogic;
					pwdata	: in std_logic_vector(31 downto 0);
					psel	: in std_logic;
					penable : in std_ulogic;
					conf_en : in std_ulogic;
					rnready : in std_ulogic;
					config_done : in std_ulogic;
					prdata	: out std_logic_vector(31 downto 0);
					dout 	: out std_logic_vector(31 downto 0);
					pdone   : out std_ulogic;
					gc_irq  : in std_ulogic;
					isr_en 	: out std_logic_vector(31 downto 0);
					delay_counter 	: out std_logic_vector(31 downto 0);
					gc_reset: out std_ulogic
			 	);
		end component;
	
	begin
		--instantiation of slave component
		inst_gc_apb_slave :	gc_apb_slave_mem
			generic map (
							NO_OF_WORDS => 	NO_OF_WORDS
						)
			port map (
						clk => clk,
						resetn => rstn,
						paddr => IF_COMP_data(hindex).haddr,    --apbi.paddr,
						pwrite => IF_COMP_data(hindex).hwrite,  --apbi.pwrite,
						pwdata => IF_COMP_data(hindex).hwdata,  --apbi.pwdata,
						psel =>	IF_COMP_data(hindex).hsel,      --apbi.psel(pindex),
						penable => '1',        --apbi.penable,
						conf_en => conf_en,
						rnready => rnready,
						config_done => config_done,
						prdata	=> GC_IF_data.hrdata,     --apbo.prdata,
						dout => dout,
						pdone => pdone_reg,
						gc_irq => gc_irq_reg,
						isr_en => isr_en,
						delay_counter => delay_counter,
						gc_reset => gc_reset
					 );
		pdone <= pdone_reg;
		gc_irq <= gc_irq_reg;

		comb: process (rstn, IF_COMP_data, irq)     --comb: process (rstn, apbi, irq)
		begin
			-- --apbo.pirq <= (others => '0'); -- No IRQ
			-- apbo.pirq(pirq) <= irq;
			-- apbo.pindex <= pindex; -- VHDL generic
			-- apbo.pconfig <= PCONFIG; -- Config constant
			GC_IF_data.pirq <= irq;
			GC_IF_data.hindex <= pindex; -- VHDL generic

            
            

		end process;

		reg : process(clk, rstn) 
		begin
			if rstn = '0' then
				delay_counter_reg  <= 0;
				isr_en_reg  <= (others =>'0');

			elsif rising_edge(clk) then
				delay_counter_reg  <= to_integer(unsigned(delay_counter));
				isr_en_reg  <= isr_en;
			end if;
		end process;	

		irq_process : process(clk, rstn, isr_en_reg)
		begin
			if(rstn = '0') then
				irq           <= '0';
				gc_irq_reg    <= '0';
				counter       <= 0;
				start_counter <= '0';

			elsif(rising_edge(clk)) then
				irq <= '0';

				if(pdone_reg = '0') then
					irq           <= '0';
					gc_irq_reg    <= '0';
					counter       <= 0;
					start_counter <= '0';
					
				elsif(start = '1') then 
					if(gc_done = '1') then
						start_counter <= '1';
					end if;

					if(unsigned(isr_en_reg) = 1) then
						if(((not gc_irq_reg) and start_counter) = '1') then
							if(counter = delay_counter_reg) then
								irq <= '1';
								gc_irq_reg <= '1';
								start_counter <= '0';
							else
								counter <= counter + 1;
							end if;
						end if;
					end if;
				end if;
			end if;
		end process;
end rtl;
	
