-- =============================================================================
--!  @project      frame buffer tcpa
-- =============================================================================
--!  @file         dvi_input_interface.vhd
--!  @author       Marcel Brand
--!  @email        marcel.brand@fau.de
--!  @brief        profpga dvi frame buffer with sram
-- =============================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.log2;
    use ieee.math_real.ceil;
library grlib;
    use grlib.amba.all;
    use grlib.stdlib.all;
    use grlib.devices.all;
library unisim;
    use unisim.vcomponents.all;

entity dvi_ahb_interface is
  generic (
    hindex               : integer                    := 0;
    haddr                : integer                    := 16#400#;
    hirq                 : integer                    := 0;
    AHB_WAIT_CYCLES      : integer                    := 1;
    ADDR_W               : positive                   := 22
  );
  port (
    amba_clk : in std_ulogic;
    reset : in std_ulogic;
    
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type;

    px_in_addr  : out std_ulogic_vector(ADDR_W-1 downto 0);
    px_in_data  : out std_ulogic_vector(23 downto 0);
    px_in_valid : out std_ulogic;
    px_in_ready : in  std_ulogic;

    px_out_request_addr  : out std_ulogic_vector(ADDR_W-1 downto 0);
    px_out_request_en    : out std_ulogic;
    px_out_request_ready : in  std_ulogic;

    px_out_data  : in  std_ulogic_vector(ADDR_W +23 downto 0);
    px_out_valid : in  std_ulogic;
    px_out_used  : out std_ulogic;

    frame_in_ctl : in std_ulogic_vector(1 downto 0)
  );
end entity dvi_ahb_interface;

architecture rtl of dvi_ahb_interface is
  type ahb_states is (idle, read, write, wait_result, wait_for_valid_signals);

  signal ahb_state : ahb_states;
  signal r_hready : std_ulogic;
  signal r_hrdata  : std_ulogic_vector(31 downto 0);
  signal r_px_addr : std_ulogic_vector(ADDR_W-1 downto 0);
  signal r_px_wdata : std_ulogic_vector(23 downto 0);
  signal r_px_trans : std_ulogic_vector(1 downto 0);
  signal r_px_valid : std_ulogic;
  signal r_px_out_request_en : std_ulogic;
  signal r_px_out_used : std_ulogic;

  signal r_cur_addr : std_ulogic_vector(ADDR_W-1 downto 0);
  signal r_wait_read : unsigned(1 downto 0);

  signal r_frame_in_ctl_1, r_frame_in_ctl_2, r_frame_in_ctl_3 : std_ulogic_vector(1 downto 0);

  signal r_hirq : std_ulogic;

  constant REVISION  : integer := 1;
  constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( 16#CC#, 16#001#, 0, REVISION, hirq),
    4 => ahb_membar(haddr, '1', '1', 16#FFC#),
    others => zero32);
begin
  px_in_valid <= r_px_valid;
  px_in_addr  <= r_px_addr;
  px_in_data  <= r_px_wdata;
  px_out_request_addr <= r_px_addr; --  out std_ulogic_vector(ADDR_W-1 downto 0);
  px_out_request_en   <= r_px_out_request_en; --  out std_ulogic;
  px_out_used         <= r_px_out_used; --  out std_ulogic;

  ahbso.hsplit <= (others => '0');
  ahbso.hresp <= (others => '0');
  ahbso.hconfig <= hconfig;
  ahbso.hindex <= hindex;
  ahbso.hready <= r_hready;
  ahbrdata : process(px_out_data)
  begin
    ahbso.hrdata <= (others => '0');
    ahbso.hrdata(23 downto 0) <= std_logic_vector(px_out_data(px_out_data'length-1 downto ADDR_W)); -- std_logic_vector(r_hrdata);
    
    
    ahbso.hirq <= (others => '0');
    ahbso.hirq(hirq)    <= r_hirq;
  end process;

  -------------------------------------------------------------------------------------------------
  -- enabling frame buffer (wait until start of next frame) ---------------------------------------
  -- write input frame to fifo --------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  ahb_sm : process (amba_clk, reset)
  begin
    if (reset = '1') then
      ahb_state <= idle;
      r_hready <= '0';
      r_hrdata <= (others => '0');
      r_px_addr <= (others => '0');
      r_px_wdata <= (others => '0');
      r_px_trans <= (others => '0');
      r_px_valid <= '0';
      r_px_out_request_en <= '0';
      r_px_out_used <= '0';
      r_cur_addr <= (others => '0');
      r_wait_read <= to_unsigned(AHB_WAIT_CYCLES, r_wait_read'length);

    elsif (rising_edge(amba_clk)) then
      
      ahb_state <= ahb_state;
      r_hready <= '0';
      r_hrdata <= (others => '0');
      r_px_addr <= r_px_addr;
      r_px_wdata <= r_px_wdata;
      r_px_trans <= r_px_trans;
      r_px_valid <= '0';
      r_px_out_request_en <= '0';
      r_px_out_used <= '0';
      r_wait_read <= to_unsigned(AHB_WAIT_CYCLES, r_wait_read'length);
  

      case(ahb_state) is
        when idle => null;
            if((ahbsi.hsel(HINDEX) and ahbsi.hready) = '1')then
--          if((ahbsi.hsel(HINDEX) and ahbsi.hready and ahbsi.htrans(1)) = '1')then
--          if((ahbsi.hsel(HINDEX) and ahbsi.htrans(1)) = '1')then
              r_hready <= '0';
              r_px_addr  <= std_ulogic_vector(ahbsi.haddr(ADDR_W-1 downto 0));
              r_px_wdata <= std_ulogic_vector(ahbsi.hwdata(23 downto 0));
              r_px_trans <= std_ulogic_vector(ahbsi.htrans);
--            if(ahbsi.htrans(1) = '1')then
                if(ahbsi.hwrite = '1')then
                  ahb_state <= write;
                else
                  ahb_state <= read;
                end if; 
--            else
--              ahb_state <= wait_for_valid_signals;
--            end if;
            end if;

        when wait_for_valid_signals => null;
            if(ahbsi.htrans(1) = '1')then
              r_hready <= '0';
              r_px_trans <= std_ulogic_vector(ahbsi.htrans);
              if(ahbsi.hwrite = '1')then
                ahb_state <= write;
              else
                ahb_state <= read;
              end if; 
            end if;

        when write =>
            if(px_in_ready = '1')then
              r_hready <= '1';
              r_px_valid <= '1';
              r_px_wdata <= std_ulogic_vector(ahbsi.hwdata(23 downto 0));
              if((ahbsi.hsel(HINDEX) and  ahbsi.htrans(1)) = '1')then
                r_px_addr  <= std_ulogic_vector(ahbsi.haddr(ADDR_W-1 downto 0));
                r_px_trans <= std_ulogic_vector(ahbsi.htrans);
                if(ahbsi.hwrite = '1')then
                  ahb_state <= write;
                else
                  ahb_state <= read;
                end if; 
              else
                ahb_state <= idle;
              end if;
            else
              r_hready <= '0';
            end if;

        when read =>

            r_hready <= '0';
            if(((not px_out_request_ready) and ahbsi.hsel(HINDEX) and ahbsi.htrans(1)) = '1' )then
              r_hready <= '1';
              r_hrdata <= (others => '0');
              
            elsif(px_out_valid = '1' and r_px_addr = r_cur_addr) then
              ahb_state <= wait_result;

            elsif(px_out_request_ready = '1')then
              r_cur_addr <= r_px_addr;
              r_px_out_request_en <= '1';
              ahb_state <= wait_result;
            else
              ahb_state <= idle;
            end if;


        when wait_result =>
            if(r_wait_read = 0 and px_out_valid = '1') then
              r_hready <= '1';
              r_hrdata <= (others => '0');
              r_hrdata(23 downto 0) <= px_out_data(px_out_data'length-1 downto ADDR_W);
              r_px_out_used <= '1';

              r_px_addr  <= std_ulogic_vector(ahbsi.haddr(ADDR_W-1 downto 0));
              r_px_wdata <= std_ulogic_vector(ahbsi.hwdata(23 downto 0));
              r_px_trans <= std_ulogic_vector(ahbsi.htrans);

              if (ahbsi.hsel(HINDEX) = '1' and ahbsi.htrans = "11") then
                ahb_state <= wait_result;
              elsif((ahbsi.hsel(HINDEX) and ahbsi.hready and ahbsi.htrans(1)) = '1')then
                if(ahbsi.hwrite = '1')then
                  ahb_state <= write;
                else
                  ahb_state <= read;
                end if; 
              else
                ahb_state <= idle;
              end if;
            else
              if(r_wait_read = 0)then
                r_wait_read <= (others => '0');
              else
                r_wait_read <= r_wait_read -1;
              end if;
              r_hready <= '0';
            end if;

        when others => ahb_state <= idle;
      end case;

      if(r_px_out_used = '1')then
        r_cur_addr <= px_out_data(ADDR_W-1 downto 0);
      end if;

      r_frame_in_ctl_1 <= frame_in_ctl;
      r_frame_in_ctl_2 <= r_frame_in_ctl_1;
      r_frame_in_ctl_3 <= r_frame_in_ctl_2;

      r_hirq <= r_frame_in_ctl_2(1) and not r_frame_in_ctl_3(1);

    end if;
  end process;

end architecture rtl;

  
