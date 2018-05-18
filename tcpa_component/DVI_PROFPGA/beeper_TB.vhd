library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity beeper_tb is
end entity;

architecture beh of beeper_tb is
  signal beeper_clk : std_ulogic := '0';
  signal cfg_clk    : std_ulogic := '0';
  signal reset : std_ulogic;

  constant COUNTER_WIDTH : integer := 2;
  signal beeper_cfg_wdata : std_ulogic_vector(COUNTER_WIDTH-1 downto 0);
  signal beeper_cfg_rdata : std_ulogic_vector(COUNTER_WIDTH-1 downto 0);
  signal beeper_cfg_addr  : std_ulogic_vector(0 downto 0);
  signal beeper_cfg_we    : std_ulogic;
  signal beeper_cfg_en    : std_ulogic;

  signal beeper_out       : std_ulogic;
  
  component beeper is
    generic (
      COUNTER_WIDTH : positive
    );
    port (
      beeper_clk : in std_ulogic;
      cfg_clk    : in std_ulogic;
      reset : in std_ulogic;

      beeper_cfg_wdata : in  std_ulogic_vector(COUNTER_WIDTH-1 downto 0);
      beeper_cfg_rdata : out std_ulogic_vector(COUNTER_WIDTH-1 downto 0);
      beeper_cfg_addr  : in  std_ulogic_vector(0 downto 0);
      beeper_cfg_we    : in  std_ulogic;
      beeper_cfg_en    : in  std_ulogic;

      beeper_out        : out std_ulogic
    );
  end component beeper;

begin

  cfg_clk <= not cfg_clk after 16.666 ns;
  beeper_clk <= not beeper_clk after 5 ns;

  beeper_i : beeper
  generic map(
    COUNTER_WIDTH => COUNTER_WIDTH
  )
  port map(
    beeper_clk => beeper_clk,
    cfg_clk    => cfg_clk,
    reset => reset,

    beeper_cfg_wdata => beeper_cfg_wdata,
    beeper_cfg_rdata => beeper_cfg_rdata,
    beeper_cfg_addr  => beeper_cfg_addr,
    beeper_cfg_we    => beeper_cfg_we,
    beeper_cfg_en    => beeper_cfg_en,

    beeper_out       => beeper_out
  );

  stimuli : process
  begin
    reset <= '1';

    beeper_cfg_wdata <= (others => '0');
    beeper_cfg_addr  <= "0";
    beeper_cfg_we    <= '0';
    beeper_cfg_en    <= '0';

    wait for 33.333 ns;

    reset <= '0';
    beeper_cfg_wdata <= "01";
    beeper_cfg_addr  <= "0";
    beeper_cfg_we    <= '1';
    beeper_cfg_en    <= '1';

    wait for 33.333 ns;

    beeper_cfg_we    <= '0';
    beeper_cfg_en    <= '0';

    wait for 333.333 ns;

    beeper_cfg_wdata <= "01";
    beeper_cfg_addr  <= "1";
    beeper_cfg_we    <= '1';
    beeper_cfg_en    <= '1';

    wait for 33.333 ns;

    beeper_cfg_we    <= '0';
    beeper_cfg_en    <= '0';

    wait for 333.333 ns;

    beeper_cfg_wdata <= "11";
    beeper_cfg_addr  <= "1";
    beeper_cfg_we    <= '1';
    beeper_cfg_en    <= '1';

    wait for 33.333 ns;

    beeper_cfg_we    <= '0';
    beeper_cfg_en    <= '0';

    wait for 333.333 ns;


    
  end process;

end beh;
