---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  RBuffer_hirq
-- Project Name: Hierarchical Interrupt Request 
--
-- Engineer:     Éricles Sousa
-- Create Date:  March, 2017 
-- Description:  This is a hierarchical interrupt request module for the reconfigurable buffer strcuture
--
--------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.stdlib.all;
use grlib.amba.all;
use grlib.devices.all;

library techmap;
use techmap.gencomp.all;

use work.data_type_pkg.all;     -- for input and output format between amba_interface and tcpa components


entity RBuffer_hirq is
  
	generic (
		NUM_OF_BUFFER_STRUCTURES : integer := 4;
		CHANNEL_COUNT_NORTH      : integer := 4;
		CHANNEL_COUNT_WEST       : integer := 4;
		CHANNEL_COUNT_SOUTH      : integer := 4;
		CHANNEL_COUNT_EAST       : integer := 4;
		hindex                   : integer := 0;
		-- haddr                    : integer := 0;
		-- hmask                    : integer := 16#FFF#;
		hirq                     : integer := 0;
        SUM_COMPONENT            : integer
        );
	port (
		rstn                 : in  std_ulogic;
		clk                  : in  std_ulogic;
		irq_clear            : out std_logic_vector(3 downto 0);

		north_buffers_irq    : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_NORTH - 1 downto 0) := (others => '0');
		west_buffers_irq     : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1 downto 0)  := (others => '0');
		south_buffers_irq    : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_SOUTH - 1 downto 0) := (others => '0');
		east_buffers_irq     : in std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_EAST - 1 downto 0)  := (others => '0');

		-- ahbsi                : in  ahb_slv_in_type;
		-- ahbso                : out ahb_slv_out_type
        IF_COMP_data         : in  arr_IF_COMP(0 to SUM_COMPONENT-1);
        RB_IF_data           : out rec_COMP_IF    -- RBuffer_hirq
        );
end entity RBuffer_hirq;

architecture rtl of RBuffer_hirq is
  constant NUM_OF_REGISTERS : integer := 16;
  constant AHB_ADDR_WIDTH   : integer := 18;

  -- constant slv_hconfig : ahb_config_type := (
    -- 0      => ahb_device_reg (VENDOR_GAISLER, CONTRIB_CORE1, 0, 0, hirq),
    -- 4      => ahb_membar(haddr, '0', '0', hmask),
    -- others => zero32);


  type first_level_reg is record 
	pending : std_logic;
	clear   : std_logic;
	enable  : std_logic;
	mode    : std_logic;
	order   : std_logic_vector(1 downto 0);
	id      : std_logic_vector(1 downto 0);
  end record first_level_reg;

  type second_level_reg is record 
	id0 : std_logic_vector(31 downto 0);
	id1 : std_logic_vector(31 downto 0);
	id2 : std_logic_vector(31 downto 0);
	id3 : std_logic_vector(31 downto 0);
  end record second_level_reg;

  type reg_type is record
    slv_addr   : std_logic_vector(AHB_ADDR_WIDTH+1 downto 2);
    slv_hwrite : std_ulogic;
    slv_din    : std_logic_vector(31 downto 0);
    slv_dout   : std_logic_vector(31 downto 0);
    slv_hrdata : std_logic_vector(31 downto 0);
    ahb_addr   : integer range 0 to 2**(AHB_ADDR_WIDTH+1);
  end record reg_type;

  signal north_irq, rin_north_irq : first_level_reg;
  signal south_irq, rin_south_irq : first_level_reg;
  signal west_irq,  rin_west_irq  : first_level_reg;
  signal east_irq,  rin_east_irq  : first_level_reg;

  signal north_buffers, north_buffers_reg : second_level_reg;
  signal west_buffers,  west_buffers_reg  : second_level_reg;
  signal south_buffers, south_buffers_reg : second_level_reg;
  signal east_buffers,  east_buffers_reg  : second_level_reg;

  signal set_hirq : std_logic;
  signal r, rin   : reg_type;
  signal set_north_irq, set_west_irq, set_south_irq, set_east_irq : std_logic;
  signal catch_north_irq, catch_west_irq, catch_south_irq, catch_east_irq : std_logic;
  signal temp_north_irqs : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_NORTH - 1 downto 0) := (others => '0');
  signal temp_east_irqs  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_EAST - 1 downto 0)  := (others => '0');
  signal temp_south_irqs : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_SOUTH - 1 downto 0) := (others => '0');
  signal temp_west_irqs  : std_logic_vector(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1 downto 0)  := (others => '0');

  --ADDRESS MAP: FIRST LEVEL REGISTER
  constant FIRST_LEVEL_ADDR_INDEX_0 : integer := 0; 

  --ADDRESS MAP: SECOND LEVEL REGISTERS
  constant EAST_BUFFERS_ADDR_BUFFER_ID0 : integer := FIRST_LEVEL_ADDR_INDEX_0 + 1; 
  constant EAST_BUFFERS_ADDR_BUFFER_ID1 : integer := EAST_BUFFERS_ADDR_BUFFER_ID0 + 1; 
  constant EAST_BUFFERS_ADDR_BUFFER_ID2 : integer := EAST_BUFFERS_ADDR_BUFFER_ID1 + 1; 
  constant EAST_BUFFERS_ADDR_BUFFER_ID3 : integer := EAST_BUFFERS_ADDR_BUFFER_ID2 + 1;

  constant SOUTH_BUFFERS_ADDR_BUFFER_ID0 : integer := EAST_BUFFERS_ADDR_BUFFER_ID3 + 1;
  constant SOUTH_BUFFERS_ADDR_BUFFER_ID1 : integer := SOUTH_BUFFERS_ADDR_BUFFER_ID0 + 1;
  constant SOUTH_BUFFERS_ADDR_BUFFER_ID2 : integer := SOUTH_BUFFERS_ADDR_BUFFER_ID1 + 1;
  constant SOUTH_BUFFERS_ADDR_BUFFER_ID3 : integer := SOUTH_BUFFERS_ADDR_BUFFER_ID2 + 1;

  constant WEST_BUFFERS_ADDR_BUFFER_ID0 : integer := SOUTH_BUFFERS_ADDR_BUFFER_ID3 + 1;
  constant WEST_BUFFERS_ADDR_BUFFER_ID1 : integer := WEST_BUFFERS_ADDR_BUFFER_ID0 + 1;
  constant WEST_BUFFERS_ADDR_BUFFER_ID2 : integer := WEST_BUFFERS_ADDR_BUFFER_ID1 + 1;
  constant WEST_BUFFERS_ADDR_BUFFER_ID3 : integer := WEST_BUFFERS_ADDR_BUFFER_ID2 + 1;

  constant NORTH_BUFFERS_ADDR_BUFFER_ID0 : integer := WEST_BUFFERS_ADDR_BUFFER_ID3 + 1;
  constant NORTH_BUFFERS_ADDR_BUFFER_ID1 : integer := NORTH_BUFFERS_ADDR_BUFFER_ID0 + 1;
  constant NORTH_BUFFERS_ADDR_BUFFER_ID2 : integer := NORTH_BUFFERS_ADDR_BUFFER_ID1 + 1;
  constant NORTH_BUFFERS_ADDR_BUFFER_ID3 : integer := NORTH_BUFFERS_ADDR_BUFFER_ID2 + 1;

  constant AHB_DEBUG_ADDR : integer := NORTH_BUFFERS_ADDR_BUFFER_ID3 + 1; --i.e, AHB_DEBUG_ADDR = 18

begin 
--  comb : process (ahbsi, r, rstn) is
  comb : process (IF_COMP_data, r, rstn) is
    variable v             : reg_type;
    variable slv_hsel      : std_ulogic;
    variable usr_rst       : std_ulogic;
    variable var_north_irq : first_level_reg;
    variable var_south_irq : first_level_reg;
    variable var_west_irq  : first_level_reg;
    variable var_east_irq  : first_level_reg;
    variable var_temp      : std_logic_vector(31 downto 0);
  begin  
    v := r;
    var_north_irq := north_irq;
    var_west_irq  := west_irq;
    var_east_irq  := east_irq;
    var_south_irq := south_irq;

    slv_hsel     := '0';
    v.slv_hrdata := (others => '0');
    v.slv_dout   := (others => '0');

    usr_rst := '0';

    -- AHB-Slave
    if IF_COMP_data(hindex).hready = '1' then                                                   --if ahbsi.hready = '1' then
      slv_hsel     := IF_COMP_data(hindex).hsel and IF_COMP_data(hindex).htrans(1);            --ahbsi.hsel(hindex) and ahbsi.htrans(1);
      v.slv_hwrite := IF_COMP_data(hindex).hwrite and slv_hsel;                                 --ahbsi.hwrite and slv_hsel;
      v.slv_addr   := IF_COMP_data(hindex).haddr(AHB_ADDR_WIDTH+1 downto 2);                    --ahbsi.haddr(AHB_ADDR_WIDTH+1 downto 2);
      v.ahb_addr   := to_integer(unsigned(IF_COMP_data(hindex).haddr(AHB_ADDR_WIDTH+1 downto 2)));             --to_integer(unsigned(ahbsi.haddr(AHB_ADDR_WIDTH+1 downto 2)));
    end if;

    if r.slv_hwrite = '1' then
      v.ahb_addr   := to_integer(unsigned(r.slv_addr));
    else
      v.ahb_addr := to_integer(unsigned(IF_COMP_data(hindex).haddr(AHB_ADDR_WIDTH+1 downto 2)));       --to_integer(unsigned(ahbsi.haddr(AHB_ADDR_WIDTH+1 downto 2)));
    end if;

    --ahb slv read
    if slv_hsel = '1' then
      case v.ahb_addr is

	--FIRST LEVEL REGISTER: 
        when FIRST_LEVEL_ADDR_INDEX_0 =>
		v.slv_hrdata(1 downto 0) := east_irq.id;
		v.slv_hrdata(3 downto 2) := east_irq.order;
		v.slv_hrdata(4) := east_irq.mode;
		v.slv_hrdata(5) := east_irq.enable;
		v.slv_hrdata(6) := east_irq.clear;
		v.slv_hrdata(7) := east_irq.pending;

		v.slv_hrdata(9 downto 8)   := south_irq.id;
		v.slv_hrdata(11 downto 10) := south_irq.order;
		v.slv_hrdata(12) := south_irq.mode;
		v.slv_hrdata(13) := south_irq.enable;
		v.slv_hrdata(14) := south_irq.clear;
		v.slv_hrdata(15) := south_irq.pending;

		v.slv_hrdata(17 downto 16) := west_irq.id;
		v.slv_hrdata(19 downto 18) := west_irq.order;
		v.slv_hrdata(20) := west_irq.mode;
		v.slv_hrdata(21) := west_irq.enable;
		v.slv_hrdata(22) := west_irq.clear;
		v.slv_hrdata(23) := west_irq.pending;

		v.slv_hrdata(25 downto 24) := north_irq.id;
		v.slv_hrdata(27 downto 26) := north_irq.order;
		v.slv_hrdata(28) := north_irq.mode;
		v.slv_hrdata(29) := north_irq.enable;
		v.slv_hrdata(30) := north_irq.clear;
		v.slv_hrdata(31) := north_irq.pending;

	--SECOND LEVEL REGISTERS: EAST BUFFERS
        when EAST_BUFFERS_ADDR_BUFFER_ID0 => 
		v.slv_hrdata  :=  east_buffers_reg.id0;

        when EAST_BUFFERS_ADDR_BUFFER_ID1 => 
		v.slv_hrdata    := east_buffers_reg.id1;

        when EAST_BUFFERS_ADDR_BUFFER_ID2 => 
		v.slv_hrdata    := east_buffers_reg.id2;

        when EAST_BUFFERS_ADDR_BUFFER_ID3 => 
		v.slv_hrdata    := east_buffers_reg.id3;


	--SECOND LEVEL REGISTERS: SOUTH BUFFERS
        when SOUTH_BUFFERS_ADDR_BUFFER_ID0 => 
		v.slv_hrdata    := south_buffers_reg.id0;

        when SOUTH_BUFFERS_ADDR_BUFFER_ID1 => 
		v.slv_hrdata    := south_buffers_reg.id1;

        when SOUTH_BUFFERS_ADDR_BUFFER_ID2 => 
		v.slv_hrdata    := south_buffers_reg.id2;

        when SOUTH_BUFFERS_ADDR_BUFFER_ID3 => 
		v.slv_hrdata    := south_buffers_reg.id3;

	--SECOND LEVEL REGISTERS: WEST BUFFERS
        when WEST_BUFFERS_ADDR_BUFFER_ID0 => 
		v.slv_hrdata    := west_buffers_reg.id0;

        when WEST_BUFFERS_ADDR_BUFFER_ID1 => 
		v.slv_hrdata    := west_buffers_reg.id1;

        when WEST_BUFFERS_ADDR_BUFFER_ID2 => 
		v.slv_hrdata    := west_buffers_reg.id2;

        when WEST_BUFFERS_ADDR_BUFFER_ID3 => 
		v.slv_hrdata    := west_buffers_reg.id3;

	--SECOND LEVEL REGISTERS: NORTH BUFFERS
        when NORTH_BUFFERS_ADDR_BUFFER_ID0 => 
		v.slv_hrdata    := north_buffers_reg.id0;

        when NORTH_BUFFERS_ADDR_BUFFER_ID1 => 
		v.slv_hrdata    := north_buffers_reg.id1;

        when NORTH_BUFFERS_ADDR_BUFFER_ID2 => 
		v.slv_hrdata    := north_buffers_reg.id2;

        when NORTH_BUFFERS_ADDR_BUFFER_ID3 => 
		v.slv_hrdata    := north_buffers_reg.id3;

        when AHB_DEBUG_ADDR + 1=> 
		--v.slv_hrdata    := x"A5A5" & r.slv_din(16 downto 0);
		v.slv_hrdata    := r.slv_din;

        when others => 
		null;
      end case;
    end if;
    --ahb slv write
    if r.slv_hwrite = '1' then
      case v.ahb_addr is
        when FIRST_LEVEL_ADDR_INDEX_0 =>
		var_north_irq.clear  := IF_COMP_data(hindex).hwdata(30); -- irq_north.clear    --var_north_irq.clear  := ahbsi.hwdata(30); -- irq_north.clear
		var_north_irq.enable := IF_COMP_data(hindex).hwdata(29); -- irq_north.enable   --var_north_irq.enable := ahbsi.hwdata(29); -- irq_north.enable

		var_west_irq.clear  := IF_COMP_data(hindex).hwdata(22); -- irq_west.clear      --var_west_irq.clear  := ahbsi.hwdata(22); -- irq_west.clear
		var_west_irq.enable := IF_COMP_data(hindex).hwdata(21); -- irq_west.enable     --var_west_irq.enable := ahbsi.hwdata(21); -- irq_west.enable

		var_south_irq.clear  := IF_COMP_data(hindex).hwdata(14); -- irq_south.clear    --var_south_irq.clear  := ahbsi.hwdata(14); -- irq_south.clear
		var_south_irq.enable := IF_COMP_data(hindex).hwdata(13); -- irq_south.enable   --var_south_irq.enable := ahbsi.hwdata(13); -- irq_south.enable

		var_east_irq.clear  := IF_COMP_data(hindex).hwdata(6); -- irq_east.clear       --var_east_irq.clear  := ahbsi.hwdata(6); -- irq_east.clear
		var_east_irq.enable := IF_COMP_data(hindex).hwdata(5); -- irq_east.enable      --var_east_irq.enable := ahbsi.hwdata(5); -- irq_east.enable
       
	--For example, 0x50000048, i.e., BASE_ADDR + 0x48 (BASE_ADDR + 18*BUS_ALIGNMENT) 
	when AHB_DEBUG_ADDR + 1 => 
		v.slv_din := IF_COMP_data(hindex).hwdata(31 downto 0);         --ahbsi.hwdata(31 downto 0);

        when others => 
		null;
      end case;
    end if;


    --reset
    if rstn = '0' or usr_rst = '1' then
      v.slv_din    := (others => '0');
      v.slv_dout   := (others => '0');

      var_north_irq.clear   := '0';
      var_north_irq.enable  := '0';
      var_north_irq.pending := '0';
      var_north_irq.id      := (others=> '0');
      var_north_irq.order   := (others=> '0');
      var_north_irq.mode    := '0';

      var_west_irq.clear   := '0';
      var_west_irq.enable  := '0';
      var_west_irq.pending := '0';
      var_west_irq.id      := (others=> '0');
      var_west_irq.order   := (others=> '0');
      var_west_irq.mode    := '0';

      var_south_irq.clear   := '0';
      var_south_irq.enable  := '0';
      var_south_irq.pending := '0';
      var_south_irq.id      := (others=> '0');
      var_south_irq.order   := (others=> '0');
      var_south_irq.mode    := '0';

      var_east_irq.clear   := '0';
      var_east_irq.enable  := '0';
      var_east_irq.pending := '0';
      var_east_irq.id      := (others=> '0');
      var_east_irq.order   := (others=> '0');
      var_east_irq.mode    := '0';


    end if;

    rin           <= v;
    rin_north_irq <= var_north_irq;
    rin_west_irq  <= var_west_irq;
    rin_south_irq <= var_south_irq;
    rin_east_irq  <= var_east_irq;
    

  
  end process comb;
	--outputs ahb slv
	RB_IF_data.hrdata         <= ahbdrivedata(r.slv_hrdata);     --ahbso.hrdata         <= ahbdrivedata(r.slv_hrdata);
	RB_IF_data.hready         <= '1';                            --ahbso.hready         <= '1';
	RB_IF_data.hresp          <= "00";                           --ahbso.hresp          <= "00";
	RRB_IF_data.hirq           <= set_hirq;                       --ahbso.hirq(hindex)   <= set_hirq;
	RB_IF_data.hsplit         <= (others => '0');                --ahbso.hsplit         <= (others => '0');
    RB_IF_data.hindex         <= hindex;                         --ahbso.hindex         <= hindex;
--	RBuff_hirq_IF_hconfig        <= slv_hconfig;                    --ahbso.hconfig        <= slv_hconfig;


	irq_ctrl : process (rstn, clk)
	begin
		if rstn = '0' then

			set_north_irq <= '0';
			set_west_irq  <= '0';
			set_south_irq <= '0';
			set_east_irq  <= '0';

			catch_north_irq <= '0';
			catch_west_irq  <= '0';
			catch_south_irq <= '0';
			catch_east_irq  <= '0';

			north_irq.clear   <= '0';
			north_irq.enable  <= '0';
			north_irq.pending <= '0';
			north_irq.id      <= (others=> '0');
			north_irq.order   <= (others=> '0');
			north_irq.mode    <= '0';
			
			west_irq.clear   <= '0';
			west_irq.enable  <= '0';
			west_irq.pending <= '0';
			west_irq.id      <= (others=> '0');
			west_irq.order   <= (others=> '0');
			west_irq.mode    <= '0';
			
			south_irq.clear   <= '0';
			south_irq.enable  <= '0';
			south_irq.pending <= '0';
			south_irq.id      <= (others=> '0');
			south_irq.order   <= (others=> '0');
			south_irq.mode    <= '0';
			
			east_irq.clear   <= '0';
			east_irq.enable  <= '0';
			east_irq.pending <= '0';
			east_irq.id      <= (others=> '0');
			east_irq.order   <= (others=> '0');
			east_irq.mode    <= '0';

	      		north_buffers_reg    <= (others => (others => '0'));
		      	west_buffers_reg     <= (others => (others => '0'));
		      	south_buffers_reg    <= (others => (others => '0'));
		      	east_buffers_reg     <= (others => (others => '0'));


		elsif rising_edge(clk) then
			r           <= rin;
			north_irq <= rin_north_irq;
			west_irq  <= rin_west_irq;
			south_irq <= rin_south_irq;
			east_irq  <= rin_east_irq;
		
	
			----------------	
			-- NORTH IRQs --
			----------------	
			set_north_irq      <= '0';
			--temp_north_irqs(0) <= north_buffers_irq(0);
			--OR all elements of an n-bit array
			--for i in 1 to (NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_NORTH - 1) loop
			--	temp_north_irqs(i) <= temp_north_irqs(i-1) or north_buffers_irq(i);
			--end loop;
			--north_irq.pending <= temp_north_irqs(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_NORTH - 1);
			if((catch_north_irq = '0') and (not (north_buffers_irq = (NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1 downto 0 => '0')))) then
				north_buffers_reg <= north_buffers;
				north_irq.pending <= '1';
				catch_north_irq   <= '1';
				set_north_irq     <= '1';
				north_irq.pending <= '1';		
				north_irq.clear   <= '0';
			elsif(rin_north_irq.clear = '1') then
				north_buffers_reg <= (others => (others => '0'));
				catch_north_irq  <= '0';
				north_irq.pending <= '0';
				north_irq.clear   <= '0';
			end if;


			----------------	
			-- WEST IRQs  --
			----------------	
			set_west_irq      <= '0';
			--temp_west_irqs(0) <= west_buffers_irq(0);
			--OR all elements of an n-bit array
			--for i in 1 to (NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1) loop
			--	temp_west_irqs(i) <= temp_west_irqs(i-1) or west_buffers_irq(i);
			--end loop;
			--west_irq.pending <= temp_west_irqs(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1);
			--if(west_irq.pending = '1' and catch_west_irq = '0') then
			if((catch_west_irq = '0') and (not (west_buffers_irq = (NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1 downto 0 => '0')))) then
				west_buffers_reg <= west_buffers;
				west_irq.pending <= '1';
				catch_west_irq   <= '1';
				set_west_irq     <= '1';
				west_irq.pending <= '1';		
				west_irq.clear   <= '0';
			elsif(rin_west_irq.clear = '1') then
				west_buffers_reg <= (others => (others => '0'));
				catch_west_irq  <= '0';
				west_irq.pending <= '0';
				west_irq.clear   <= '0';
			end if;

			----------------	
			-- SOUTH IRQs --
			----------------	
			set_south_irq      <= '0';
			--temp_south_irqs(0) <= south_buffers_irq(0);
			--OR all elements of an n-bit array
			--for i in 1 to (NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_SOUTH - 1) loop
			--	temp_south_irqs(i) <= temp_south_irqs(i-1) or south_buffers_irq(i);
			--end loop;
			--south_irq.pending <= temp_south_irqs(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_SOUTH - 1);
			if((catch_south_irq = '0') and (not (south_buffers_irq = (NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1 downto 0 => '0')))) then
				south_buffers_reg <= south_buffers;
				south_irq.pending <= '1';
				catch_south_irq   <= '1';
				set_south_irq     <= '1';
				south_irq.pending <= '1';		
				south_irq.clear   <= '0';
			elsif(rin_south_irq.clear = '1') then
				south_buffers_reg <= (others => (others => '0'));
				catch_south_irq  <= '0';
				south_irq.pending <= '0';
				south_irq.clear   <= '0';
			end if;


			----------------	
			-- EAST IRQs  --
			----------------	
			set_east_irq      <= '0';
			--temp_east_irqs(0) <= east_buffers_irq(0);
			--OR all elements of an n-bit array
			--for i in 1 to (NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_EAST - 1) loop
			--	temp_east_irqs(i) <= temp_east_irqs(i-1) or east_buffers_irq(i);
			--end loop;
			--east_irq.pending <= temp_east_irqs(NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_EAST - 1);
			if((catch_east_irq = '0') and (not (east_buffers_irq = (NUM_OF_BUFFER_STRUCTURES * CHANNEL_COUNT_WEST - 1 downto 0 => '0')))) then
				east_buffers_reg <= east_buffers;
				east_irq.pending <= '1';
				catch_east_irq   <= '1';
				set_east_irq     <= '1';
				east_irq.pending <= '1';		
				east_irq.clear   <= '0';
			elsif(rin_east_irq.clear = '1') then
				east_buffers_reg <= (others => (others => '0'));
				catch_east_irq  <= '0';
				east_irq.pending <= '0';
				east_irq.clear   <= '0';
			end if;

		end if;

	      	north_buffers    <= (others => (others => '0'));
	      	west_buffers     <= (others => (others => '0'));
	      	south_buffers    <= (others => (others => '0'));
	      	east_buffers     <= (others => (others => '0'));
		north_buffers.id0(CHANNEL_COUNT_NORTH - 1 downto 0) <= north_buffers_irq(1*CHANNEL_COUNT_NORTH - 1 downto 0*CHANNEL_COUNT_NORTH);
		north_buffers.id1(CHANNEL_COUNT_NORTH - 1 downto 0) <= north_buffers_irq(2*CHANNEL_COUNT_NORTH - 1 downto 1*CHANNEL_COUNT_NORTH);
		north_buffers.id2(CHANNEL_COUNT_NORTH - 1 downto 0) <= north_buffers_irq(3*CHANNEL_COUNT_NORTH - 1 downto 2*CHANNEL_COUNT_NORTH);
		north_buffers.id3(CHANNEL_COUNT_NORTH - 1 downto 0) <= north_buffers_irq(4*CHANNEL_COUNT_NORTH - 1 downto 3*CHANNEL_COUNT_NORTH);
		
		west_buffers.id0(CHANNEL_COUNT_WEST - 1 downto 0) <= west_buffers_irq(1*CHANNEL_COUNT_WEST - 1 downto 0*CHANNEL_COUNT_WEST);
		west_buffers.id1(CHANNEL_COUNT_WEST - 1 downto 0) <= west_buffers_irq(2*CHANNEL_COUNT_WEST - 1 downto 1*CHANNEL_COUNT_WEST);
		west_buffers.id2(CHANNEL_COUNT_WEST - 1 downto 0) <= west_buffers_irq(3*CHANNEL_COUNT_WEST - 1 downto 2*CHANNEL_COUNT_WEST);
		west_buffers.id3(CHANNEL_COUNT_WEST - 1 downto 0) <= west_buffers_irq(4*CHANNEL_COUNT_WEST - 1 downto 3*CHANNEL_COUNT_WEST);
	
		south_buffers.id0(CHANNEL_COUNT_SOUTH - 1 downto 0) <= south_buffers_irq(1*CHANNEL_COUNT_SOUTH - 1 downto 0*CHANNEL_COUNT_SOUTH);
		south_buffers.id1(CHANNEL_COUNT_SOUTH - 1 downto 0) <= south_buffers_irq(2*CHANNEL_COUNT_SOUTH - 1 downto 1*CHANNEL_COUNT_SOUTH);
		south_buffers.id2(CHANNEL_COUNT_SOUTH - 1 downto 0) <= south_buffers_irq(3*CHANNEL_COUNT_SOUTH - 1 downto 2*CHANNEL_COUNT_SOUTH);
		south_buffers.id3(CHANNEL_COUNT_SOUTH - 1 downto 0) <= south_buffers_irq(4*CHANNEL_COUNT_SOUTH - 1 downto 3*CHANNEL_COUNT_SOUTH);
	
		east_buffers.id0(CHANNEL_COUNT_EAST - 1 downto 0) <= east_buffers_irq(1*CHANNEL_COUNT_EAST - 1 downto 0*CHANNEL_COUNT_EAST);
		east_buffers.id1(CHANNEL_COUNT_EAST - 1 downto 0) <= east_buffers_irq(2*CHANNEL_COUNT_EAST - 1 downto 1*CHANNEL_COUNT_EAST);
		east_buffers.id2(CHANNEL_COUNT_EAST - 1 downto 0) <= east_buffers_irq(3*CHANNEL_COUNT_EAST - 1 downto 2*CHANNEL_COUNT_EAST);
		east_buffers.id3(CHANNEL_COUNT_EAST - 1 downto 0) <= east_buffers_irq(4*CHANNEL_COUNT_EAST - 1 downto 3*CHANNEL_COUNT_EAST);

		-- irq_clear(3) <= south_irq.clear ... irq_clear(0) <= north_irq_clear
		irq_clear <= south_irq.clear &  east_irq.clear & west_irq.clear & north_irq.clear;
		set_hirq <= set_north_irq or set_west_irq or set_south_irq or set_east_irq;
	end process;

end architecture rtl;




