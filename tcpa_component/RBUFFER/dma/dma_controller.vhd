-------------------------------------------------------------------------------
-- Title      : dma_controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dma_controller.vhd
-- Author     : Martin Riedlberger  <riedlberger@i80pc127>
-- Company    : 
-- Created    : 2015-03-03
-- Last update: 2015-08-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Simple DMA controller
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-03-03  1.0      riedlberger     Created
-- 2016-11-13  1.1      damschen        AHB Split support
-- 2016-12-22  1.2      damschen        Split fix, Memset support
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.stdlib.all;
use grlib.amba.all;
use grlib.devices.all;

library techmap;
use techmap.gencomp.all;

entity dma_controller is
  
  generic (
    mst_hindex : integer := 0;
    slv_hindex : integer := 0;
    slv_haddr  : integer := 0;
    slv_hmask  : integer := 16#FFF#;
    hirq       : integer := 0;
    burst_max  : integer := 256;
    tech       : integer := virtex7;
    ahbaccsz   : integer := 32);
  port (
    rstn  : in  std_ulogic;
    clk   : in  std_ulogic;
    ahbmi : in  ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type);
end entity dma_controller;

architecture rtl of dma_controller is
  constant slv_hconfig : ahb_config_type := (
    --0      => ahb_device_reg (VENDOR_CES, CES_DMAS, 0, 0, hirq),
    0      => ahb_device_reg (VENDOR_GAISLER, CONTRIB_CORE1, 0, 0, hirq),
    4      => ahb_membar(slv_haddr, '0', '0', slv_hmask),
    others => zero32);

  constant mst_hconfig : ahb_config_type := (
    --0      => ahb_device_reg (VENDOR_CES, CES_DMAM, 0, 0, 0),
    0      => ahb_device_reg (VENDOR_GAISLER, CONTRIB_CORE1, 0, 0, 0),
    others => zero32);

  constant dbits : integer := ahbaccsz;
  constant abits : integer := log2(burst_max);

  type dma_state_type is (IDLE_STATE, READ_STATE, READLAST_STATE, WRITE_STATE, WRITELAST_STATE);

  type reg_type is record
    slv_addr   : std_logic_vector(7 downto 2);
    slv_hwrite : std_ulogic;
    slv_hrdata : std_logic_vector(31 downto 0);

    src_addr, dst_addr : unsigned(31 downto 0);
    len                : unsigned(31 downto 0);
    burst_len          : integer range 0 to burst_max;

    enable     : std_ulogic;
    state      : dma_state_type;
    cnt        : integer range 0 to burst_max;
    dsbl_irq   : std_ulogic;
    srcasval   : std_ulogic;
    grant      : std_ulogic;
    active     : std_ulogic;
    mexc       : std_ulogic;
    num_splits : unsigned(31 downto 0);

    b_raddr : std_logic_vector(abits-1 downto 0);
  end record reg_type;

  signal r, rin : reg_type;

  signal b_raddr, b_waddr    : std_logic_vector(abits-1 downto 0);
  signal b_datain, b_dataout : std_logic_vector(dbits-1 downto 0);
  signal b_renable, b_write  : std_ulogic;
  
begin  -- architecture rtl
  
  b_ram : syncram_2p generic map (tech => tech, abits => abits, dbits => dbits)
    port map (clk, b_renable, b_raddr, b_dataout,
              clk, b_write, b_waddr, b_datain);

  comb : process (ahbsi, r, ahbmi, rstn, b_dataout) is
    variable v : reg_type;

    variable slv_haddr : std_logic_vector(7 downto 2);
    variable slv_hsel  : std_ulogic;

    variable haddr   : unsigned(31 downto 0);
    variable hbusreq : std_ulogic;
    variable htrans  : std_logic_vector(1 downto 0);
    variable hwrite  : std_ulogic;
    variable hsize   : std_logic_vector(2 downto 0);
    variable hburst  : std_logic_vector(2 downto 0);
    variable hwdata  : std_logic_vector(dbits-1 downto 0);

    variable vb_raddr, vb_waddr   : std_logic_vector(abits-1 downto 0);
    variable vb_renable, vb_write : std_ulogic;
    variable vb_datain            : std_logic_vector(dbits-1 downto 0);

    variable usr_rst : std_ulogic;
    variable hready  : std_ulogic;
    variable split   : std_ulogic;
    variable irq     : std_logic_vector(NAHBIRQ-1 downto 0);
  begin  -- process comb
    v := r;

    slv_hsel     := '0';
    slv_haddr    := (others => '0');
    v.slv_hrdata := (others => '0');

    hbusreq := r.enable;
    haddr   := (others => '0');
    hwrite  := '0';
    hwdata  := (others => '0');
    htrans  := HTRANS_IDLE;
    hsize   := HSIZE_WORD;
    hburst  := HBURST_SINGLE;

    vb_raddr   := (others => '0');
    vb_waddr   := (others => '0');
    vb_datain  := (others => '0');
    vb_renable := '0';
    vb_write   := '0';

    usr_rst := '0';
    hready  := '0';
    split   := '0';
    irq     := (others => '0');

    --dma state machine
    if ahbmi.hready = '1' then
      v.grant := ahbmi.hgrant(mst_hindex);
      if r.active = '1' and ahbmi.hresp = HRESP_ERROR then
        v.mexc    := '1';
        v.enable  := '0';
        v.active  := '0';
        irq(hirq) := not r.dsbl_irq;
        v.state   := IDLE_STATE;
      elsif r.active = '1' and ahbmi.hresp = HRESP_SPLIT then
	v.active  := '0';
	split     := '1';
	v.num_splits := r.num_splits + 1;
      else
        hready := '1';
      end if;
    end if;

    case r.state is
      when IDLE_STATE =>
        if r.enable = '1' then
          if r.len > 0 then
            if r.srcasval = '1' then
              v.state := WRITE_STATE;
            else
              v.state := READ_STATE;
            end if;
          else
            hbusreq   := '0';
            v.enable  := '0';
            irq(hirq) := not r.dsbl_irq;
          end if;
        end if;
      when READ_STATE =>
        if (hready = '1') and (r.cnt > 0) and (r.active = '1') then
          vb_waddr  := std_logic_vector(to_unsigned(r.cnt-1, abits));
          vb_datain := ahbreadword(ahbmi.hrdata);
          vb_write  := '1';
        end if;
        if (hready and r.grant) = '1' then
          v.active   := '1';
          v.cnt      := r.cnt + 1;
          v.src_addr := r.src_addr + 4;
          if (r.cnt = r.burst_len-1) or (r.cnt = r.len-1) then
            v.state := READLAST_STATE;
          end if;
        end if;
        haddr  := r.src_addr;
        hburst := HBURST_INCR;
        if split = '1' then
          htrans := HTRANS_IDLE;
          v.cnt := r.cnt - 1;
          v.src_addr := r.src_addr - 4;
        elsif (r.cnt = 0) or (r.src_addr(9 downto 0) = "0000000000") then
          htrans := HTRANS_NONSEQ;
        else
          htrans := HTRANS_SEQ;
        end if;
      when READLAST_STATE =>
        if (hready = '1') and (r.cnt > 0) and (r.active = '1') then
          vb_waddr  := std_logic_vector(to_unsigned(r.cnt-1, abits));
          vb_datain := ahbreadword(ahbmi.hrdata);
          vb_write  := '1';

          v.cnt   := 0;
          v.state := WRITE_STATE;

          vb_raddr   := std_logic_vector(to_unsigned(0, abits));
          v.b_raddr  := std_logic_vector(to_unsigned(0, abits));
          vb_renable := '1';          
        elsif split = '1' then
          v.cnt := r.cnt - 1;
          v.src_addr := r.src_addr - 4;
          v.state := READ_STATE;
        end if;
      when WRITE_STATE =>
        if (hready and r.grant) = '1' then
          v.active   := '1';
          v.cnt      := r.cnt + 1;
          v.dst_addr := r.dst_addr + 4;
          v.len      := r.len - 1;
          if r.cnt = r.burst_len - 1 or r.len = 1 then
            v.state := WRITELAST_STATE;
          end if;
        end if;
        if hready = '1' then
          v.b_raddr := std_logic_vector(to_unsigned(r.cnt, abits));
          vb_raddr  := std_logic_vector(to_unsigned(r.cnt, abits));
        else
          vb_raddr := r.b_raddr;
        end if;
        vb_renable := '1';

        haddr  := r.dst_addr;
        if r.srcasval = '0' then
          hwdata := b_dataout;
        else
          hwdata := std_logic_vector(r.src_addr);
        end if;
        hburst := HBURST_INCR;
        hwrite := '1';
        if split = '1' then
          htrans := HTRANS_IDLE;
          v.cnt := r.cnt - 1;
          v.dst_addr := r.dst_addr - 4;
          v.len := r.len + 1;
        elsif (r.cnt = 0) or (r.dst_addr(9 downto 0) = "0000000000") then
          htrans := HTRANS_NONSEQ;
        else
          htrans := HTRANS_SEQ;
        end if;
      when WRITELAST_STATE =>
        vb_raddr   := std_logic_vector(to_unsigned(r.cnt, abits));
        vb_renable := '1';
        if r.srcasval = '0' then
          hwdata := b_dataout;
        else
          hwdata := std_logic_vector(r.src_addr);
        end if;

        if (hready = '1') and (not split = '1') then
          v.cnt := 0;
          if r.len = 0 or r.enable = '0' then
            v.state   := IDLE_STATE;
            hbusreq   := '0';
            v.enable  := '0';
            v.active  := '0';
            irq(hirq) := not r.dsbl_irq;
          else
            if r.srcasval = '1' then
              v.state := WRITE_STATE;
            else
              v.state := READ_STATE;
            end if;
          end if;
        elsif split = '1' then
          v.cnt := r.cnt - 1;
          v.dst_addr := r.dst_addr - 4;
          v.len := r.len + 1;
          v.state := WRITE_STATE;
        end if;
      when others => null;
    end case;

    -- AHB-Slave
    if ahbsi.hready = '1' then
      slv_hsel     := ahbsi.hsel(slv_hindex) and ahbsi.htrans(1);
      v.slv_hwrite := ahbsi.hwrite and slv_hsel;
      v.slv_addr   := ahbsi.haddr(7 downto 2);
    end if;
    if r.slv_hwrite = '1' then
      slv_haddr := r.slv_addr;
    else
      slv_haddr := ahbsi.haddr(7 downto 2);
    end if;
    --ahb slv read
    if slv_hsel = '1' then
      case slv_haddr is
        when "000000" => v.slv_hrdata    := std_logic_vector(r.src_addr);
        when "000001" => v.slv_hrdata    := std_logic_vector(r.dst_addr);
        when "000010" => v.slv_hrdata    := std_logic_vector(r.len);
        when "000011" => v.slv_hrdata(0) := r.enable;
                         v.slv_hrdata(2) := r.mexc;
                         v.slv_hrdata(3) := r.dsbl_irq;
                         v.slv_hrdata(4) := r.srcasval;
                         v.slv_hrdata(31 downto 16) := std_logic_vector(to_unsigned(r.burst_len, 16));
        when "000100" => v.slv_hrdata    := std_logic_vector(r.num_splits);
        when others => null;
      end case;
    end if;
    --ahb slv write
    if r.slv_hwrite = '1' then
      case slv_haddr is
        when "000000" => v.src_addr := unsigned(ahbsi.hwdata(31 downto 0));
        when "000001" => v.dst_addr := unsigned(ahbsi.hwdata(31 downto 0));
        when "000010" => v.len      := unsigned(ahbsi.hwdata(31 downto 0));
        when "000011" => v.enable   := ahbsi.hwdata(0);
                         if v.enable = '1' then
                           v.num_splits := (others => '0');
                           v.mexc := '0';
                         end if;
                         usr_rst    := ahbsi.hwdata(1);
                         v.dsbl_irq := ahbsi.hwdata(3);
                         v.srcasval := ahbsi.hwdata(4);
                         v.burst_len := to_integer(unsigned(ahbsi.hwdata(31 downto 16)));
        when "000100" => null; -- 'num_splits' not writeable
        when others => null;
      end case;
    end if;

    --reset
    if rstn = '0' or usr_rst = '1' then
--    if rstn = '0' then
      v.state      := IDLE_STATE;
      v.src_addr   := (others => '0');
      v.dst_addr   := (others => '0');
      v.len        := (others => '0');
      v.enable     := '0';
      v.active     := '0';
      v.mexc       := '0';
      v.num_splits := (others => '0');

      v.cnt         := 0;
      v.dsbl_irq    := '0';
      v.srcasval    := '0';
      v.burst_len   := 4;
      v.grant       := '0';
    end if;

    rin           <= v;
    --outputs ahb slv
    ahbso.hready  <= '1';
    ahbso.hresp   <= "00";
    ahbso.hrdata  <= ahbdrivedata(r.slv_hrdata);
    ahbso.hsplit  <= (others => '0');
    ahbso.hirq    <= irq;
    ahbso.hconfig <= slv_hconfig;
    ahbso.hindex  <= slv_hindex;

    --outputs ahb mst
    ahbmo.hbusreq <= hbusreq;
    ahbmo.hlock   <= '0';
    ahbmo.htrans  <= htrans;
    ahbmo.haddr   <= std_logic_vector(haddr);
    ahbmo.hwrite  <= hwrite;
    ahbmo.hsize   <= hsize;
    ahbmo.hburst  <= hburst;
    ahbmo.hprot   <= (others => '0');
    ahbmo.hwdata  <= ahbdrivedata(hwdata);
    ahbmo.hirq    <= (others => '0');
    ahbmo.hconfig <= mst_hconfig;
    ahbmo.hindex  <= mst_hindex;

    --outputs buffer
    b_raddr   <= vb_raddr;
    b_waddr   <= vb_waddr;
    b_renable <= vb_renable;
    b_write   <= vb_write;
    b_datain  <= vb_datain;
  end process comb;

  reg : process (clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;
end architecture rtl;
