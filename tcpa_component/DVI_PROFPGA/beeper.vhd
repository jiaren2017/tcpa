-- =============================================================================
--!  @project      pendulum demo
-- =============================================================================
--!  @file         beeper.vhd
--!  @author       Marcel Brand
--!  @email        marcel.brand@fau.de
--!  @brief        sets bit of beeper via apb
-- =============================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library unisim;
    use unisim.vcomponents.all;

entity beeper is
  generic (
    COUNTER_WIDTH : positive;
    DIVIDER_WIDTH : positive
  );
  port (
    beeper_clk : in std_ulogic;
    cfg_clk    : in std_ulogic;
    reset : in std_ulogic;

    beeper_cfg_wdata : in  std_ulogic_vector(max(COUNTER_WIDTH, DIVIDER_WIDTH)-1 downto 0);
    beeper_cfg_rdata : out std_ulogic_vector(max(COUNTER_WIDTH, DIVIDER_WIDTH)-1 downto 0);
    beeper_cfg_addr  : in  std_ulogic_vector(1 downto 0);
    beeper_cfg_we    : in  std_ulogic;
    beeper_cfg_en    : in  std_ulogic;

    beeper_out        : out std_ulogic
  );
end entity beeper;

architecture rtl of beeper is

  signal r_beeper, r_beeper_feedback : std_ulogic;
  signal r_divider : unsigned(DIVIDER_WIDTH-1 downto 0);
  signal r_counter : unsigned(COUNTER_WIDTH-1 downto 0);
  signal r_beeper_cfg_rdata : std_ulogic_vector(COUNTER_WIDTH-1 downto 0);

  signal r_beeper_out, r_beep, r_beep_enable : std_ulogic;
  signal r_divider_out : unsigned(DIVIDER_WIDTH-1 downto 0);
  signal r_counter_out : unsigned(COUNTER_WIDTH-1 downto 0);
  signal r_countdown : unsigned(COUNTER_WIDTH-1 downto 0);
  signal clk_counter : unsigned(DIVIDER_WIDTH-1 downto 0);

begin
  beeper_out <= r_beeper_enable when r_divider_out = 0 else                
                beeper_clk and r_beeper_enable when r_divider_out = 1 else
                r_beeper_enable and r_beep;
                
  beeper_cfg_rdata <= r_beeper_cfg_rdata;

  -------------------------------------------------------------------------------------------------
  -- Configuration of beeper controller -----------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  config : process(cfg_clk, reset)
  begin
    if(reset = '1')then
      r_beeper <= '0';
      r_beeper_feedback <= '0';
      r_divider <= (others => '0');
      r_counter <= (others => '0');

    elsif(rising_edge(cfg_clk))then
      r_beeper <= r_beeper;
      r_beeper_feedback <= r_beeper_out;

      if(r_beeper_feedback = '1')then
        r_beeper <= '0';
      end if;

      if((beeper_cfg_en and beeper_cfg_we) = '1')then
        case(beeper_cfg_addr)is
          when "00" => r_beeper <= beeper_cfg_wdata(0);
          when "01" => r_divider <= unsigned(beeper_cfg_wdata(r_divider'range));
          when "10" => r_counter <= unsigned(beeper_cfg_wdata(r_counter'range));
          when others => null;
        end case;
      else 
        r_beeper_cfg_rdata <= (others => '0');
        case(beeper_cfg_addr)is
          when "00" => r_beeper_cfg_rdata(0) <= r_beeper;
          when "01" => r_beeper_cfg_rdata(r_divider'range) <= std_ulogic_vector(r_divider);
          when "10" => r_beeper_cfg_rdata(r_counter'range) <= std_ulogic_vector(r_counter);
          when others => null;
        end case;

      end if;

    end if;
  end process;

  beeper_ctrl : process(beeper_clk, reset)
  begin
    if(reset = '1')then
      r_beeper_out <= '0';
      r_beep <= '0';
      r_beep_enable <= '0';
      r_divider_out <= (others => '0');
      r_counter_out <= (others => '0');
      clk_counter <= to_unsigned(1, clk_counter'length);
      
    else
      if(rising_edge(beeper_clk))then
        r_beeper_out <= r_beeper;
        r_divider_out <= r_divider;
        r_counter_out <= r_counter;
        r_beep_enable <= '0';

        if(r_beeper_out = '1')then
          r_countdown <= r_counter_out;
        end if;

        if(r_countdown > 0)then
          r_countdown <= r_countdown - 1;
          r_beep_enable <= '1';
        end if;

        if(clk_counter = r_divider_out)then
          r_beep <= not r_beep;
          clk_counter <= to_unsigned(1, clk_counter'length);
        else
          r_beep <= r_beep;
          clk_counter <= clk_counter + to_unsigned(1, clk_counter'length);
        end if;
      end if;

    end if;
  end process;

end architecture;

  
