library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rgb2hsv is
    generic (
      ADDR_W : positive
    );
    port ( 
      clk : in std_ulogic;

      r : in std_ulogic_vector (7 downto 0);
      g : in std_ulogic_vector (7 downto 0);
      b : in std_ulogic_vector (7 downto 0);
      addr_in : in std_ulogic_vector(ADDR_W-1 downto 0);
      valid_in : in std_ulogic;
 
      h : out std_ulogic_vector (7 downto 0);
      s : out std_ulogic_vector (7 downto 0);
      v : out std_ulogic_vector (7 downto 0);
      addr : out std_ulogic_vector(ADDR_W-1 downto 0);
      valid : out std_ulogic
    );
end rgb2hsv;


architecture behavioral of rgb2hsv is
  type addr_delay_array is array (natural range <>) of std_ulogic_vector(ADDR_W-1 downto 0);
  type S_delay_array is array (natural range <>) of std_ulogic_vector(7 downto 0);
  type max_i_delay_array is array (natural range <>) of unsigned(1 downto 0);
  type C_max_delay_array is array (natural range <>) of unsigned(7 downto 0);

  signal min_i, max_i : unsigned (1 downto 0);
  signal max_i_delay : max_i_delay_array(1 to 7);
  signal C_max, C_min : unsigned(7 downto 0);
  signal C_max_delay : C_max_delay_array(1 to 7);
  signal H_region_result, H_div_result, H_region_result_mod_6, H_region_constant : signed(16 downto 0);
  signal delta, H_sub_result : signed(8 downto 0);
  signal H_dividend, H_divisor, H_result, C_max_16bit : unsigned(15 downto 0);
  signal H_mul_result : unsigned(31 downto 0);
  signal H_sub_minuend, H_sub_subtrahend : unsigned(7 downto 0);
  signal S_dividend, S_divisor, S_result : unsigned(15 downto 0);
  signal H_div_valid : std_ulogic;

  signal r_H : unsigned(7 downto 0);
  signal r_V : unsigned(7 downto 0);
  signal r_S : S_delay_array(3 to 7);

  signal addr_delay : addr_delay_array(1 to 7);
  signal valid_delay : std_ulogic_vector(1 to 7);
  
  constant REGION0 : integer := 0;
  constant REGION1 : integer := 16#200#;
  constant REGION2 : integer := 16#400#;
    component rgb2yuv is
      port ( clk : in std_ulogic;
             red : in std_ulogic_vector (7 downto 0);
             green : in std_ulogic_vector (7 downto 0);
             blue : in std_ulogic_vector (7 downto 0);
             y : out std_ulogic_vector (7 downto 0);
             u : out std_ulogic_vector (7 downto 0);
             v : out std_ulogic_vector (7 downto 0));
  end component rgb2yuv;

  component div_16bit is
    port (
        clk : in std_ulogic;
        dividend  : in unsigned(7 downto 0);
        divisor   : in unsigned(7 downto 0);
        valid_in  : in std_ulogic;
        result    : out unsigned(15 downto 0);
        valid     : out std_ulogic
    );
  end component;
  
  
  component div_s16bit is
    port (
        clk : in std_ulogic;
        dividend  : in signed(8 downto 0);
        divisor   : in signed(8 downto 0);
        valid_in  : in std_ulogic;
        result    : out signed(16 downto 0);
        valid     : out std_ulogic
    );
  end component;
  
  component mul_16bit is
    port (
        clk : in std_ulogic;
        multiplicant: in unsigned(15 downto 0);
        multiplier : in unsigned(15 downto 0);
        result    : out unsigned(31 downto 0)
    );
  end component;
    
  component sub_s16bit is
    port (
        clk : in std_ulogic;
        minuend  : in unsigned(7 downto 0);
        subtrahend   : in unsigned(7 downto 0);
        result    : out signed(8 downto 0)
    );
  end component;
    
  component add_s16bit is
    port (
        clk : in std_ulogic;
        summand1  : in signed(16 downto 0);
        summand2  : in signed(16 downto 0);
        result    : out signed(16 downto 0)
    );
  end component;
    
  component maxmin is
    port(
      clk : in std_logic;
      A, B, C : in unsigned(7 downto 0);
      max_i : out unsigned(1 downto 0);
      min_i : out unsigned(1 downto 0)
    );
  end component;
    
  component mux_3_1_8bit is
    port(
      clk : in std_logic;
      A, B, C : in unsigned(7 downto 0);
      control : in unsigned(1 downto 0);
      result : out unsigned(7 downto 0)
    );
  end component;
        
  component mux_3_1_s16bit is
    port(
      clk : in std_logic;
      A, B, C : in signed(16 downto 0);
      control : in unsigned(1 downto 0);
      result : out signed(16 downto 0)
    );
  end component;
  
  component rgb2hsv is
    generic (
      ADDR_W : positive
    );
    port ( 
      clk : in std_ulogic;

      r : in std_ulogic_vector (7 downto 0);
      g : in std_ulogic_vector (7 downto 0);
      b : in std_ulogic_vector (7 downto 0);
      addr_in : in std_ulogic_vector(ADDR_W-1 downto 0);
      valid_in : in std_ulogic;
 
      h : out std_ulogic_vector (7 downto 0);
      s : out std_ulogic_vector (7 downto 0);
      v : out std_ulogic_vector (7 downto 0);
      addr : out std_ulogic_vector(ADDR_W-1 downto 0);
      valid : out std_ulogic
    );
  end component;
begin 

---- Pipeline stage 0 ---

  compare : maxmin
  port map(
    clk => clk,
    A => unsigned(R),
    B => unsigned(G),
    C => unsigned(B),
    max_i => max_i,
    min_i => min_i
  );

  choose_minuend_delta : mux_3_1_8bit
  port map(
    clk => clk,
    A => unsigned(R),
    B => unsigned(G),
    C => unsigned(B),
    control => max_i,
    result => C_max
  );

  choose_subtrahend_delta : mux_3_1_8bit 
  port map(
    clk => clk,
    A => unsigned(R),
    B => unsigned(G),
    C => unsigned(B),
    control => min_i,
    result => C_min
  );
  
  delta_sub : sub_s16bit
  port map(
    clk => clk,
    minuend => C_max,
    subtrahend => C_min,
    result => delta
  );

  choose_minuend_H : mux_3_1_8bit 
  port map(
    clk => clk,
    A => unsigned(G),
    B => unsigned(B),
    C => unsigned(R),
    control => max_i,
    result => H_sub_minuend
  );

  choose_subtrahend_H : mux_3_1_8bit
  port map(
    clk => clk,
    A => unsigned(B),
    B => unsigned(R),
    C => unsigned(G),
    control => max_i,
    result => H_sub_subtrahend
  );

  H_sub : sub_s16bit
  port map(
    clk => clk,
    minuend => H_sub_minuend,
    subtrahend => H_sub_subtrahend,
    result => H_sub_result
  );

  delay_stage0 : process(clk)
  begin
    if(rising_edge(clk))then
      max_i_delay(1) <= max_i;
      C_max_delay(1) <= C_max;
      addr_delay(1) <= addr_in;
      valid_delay(1) <= valid_in;
    end if;
  end process;

---- Pipeline stage 1 ---

  H_div : div_s16bit
  port map(
    clk => clk,
    dividend => H_sub_result,
    divisor => delta,
    valid_in => valid_delay(1),
    result => H_div_result,
    valid => H_div_valid
  );

  S_div : div_16bit
  port map(
    clk => clk,
    dividend => unsigned(std_logic_vector(delta(7 downto 0))),
    divisor => C_max_delay(1),
    valid_in => valid_delay(1),
    result => S_result,
    valid => open
  );
  
  delay_stage1 : process(clk)
  begin
    if(rising_edge(clk))then
      max_i_delay(2) <= max_i_delay(1);
      C_max_delay(2) <= C_max_delay(1);
      addr_delay(2) <= addr_delay(1);
    end if;
  end process;

---- Pipeline stage 2 ---

  delay_stage2 : process(clk)
  begin
    if(rising_edge(clk))then
      max_i_delay(3) <= max_i_delay(2);
      C_max_delay(3) <= C_max_delay(2);
      addr_delay(3) <= addr_delay(2);
    end if;
  end process;

---- Pipeline stage 3 ---
  
  delay_stage3 : process(clk)
  begin
    if(rising_edge(clk))then
      max_i_delay(4) <= max_i_delay(3);
      C_max_delay(4) <= C_max_delay(3);
      addr_delay(4) <= addr_delay(3);
    end if;
  end process;

---- Pipeline stage 4 ---
    
  delay_stage4 : process(clk)
  begin
    if(rising_edge(clk))then
      max_i_delay(5) <= max_i_delay(4);
      C_max_delay(5) <= C_max_delay(4);
      addr_delay(5) <= addr_delay(4);
    end if;
  end process;

---- Pipeline stage 5 ---

  choose_region_constant : mux_3_1_s16bit
  port map(
    clk => clk,
    A => to_signed(REGION0, 17),
    B => to_signed(REGION1, 17),
    C => to_signed(REGION2, 17),
    control => max_i_delay(5),
    result => H_region_constant
  );

  H_add_region_constant : add_s16bit
  port map(
    clk => clk,
    summand1 => H_div_result,
    summand2 => H_region_constant,
    result => H_region_result
  );

  delay_stage5 : process(clk)
  begin
    if rising_edge(clk) then
      if(S_result(15 downto 8) > 0)then
          r_S(6) <= "11111111";
        else
          r_S(6) <= std_ulogic_vector(S_result(7 downto 0));
      end if;
      C_max_delay(6) <= C_max_delay(5);
      addr_delay(6) <= addr_delay(5);
      valid_delay(6) <= H_div_valid;
    end if;
          
  end process;       

---- Pipeline stage 6 ---

  H_mod_6 : process(H_region_result)
  begin
    if(H_region_result < 0) then
      H_region_result_mod_6 <= H_region_result + to_signed(16#600#, 17);
    else
      H_region_result_mod_6 <= H_region_result;
    end if;
  end process;

  H_mul : mul_16bit
  port map(
    clk => clk,
    multiplicant => unsigned(std_logic_vector(H_region_result_mod_6(15 downto 0))),
    multiplier => to_unsigned(16#002B#, 16), -- 60/360
    result => H_mul_result
  );

  delay_stage6 : process(clk)
  begin
    if rising_edge(clk) then
      r_S(7) <= r_S(6);
      r_V <= C_max_delay(6);
      addr_delay(7) <= addr_delay(6);
      valid_delay(7) <= valid_delay(6);
    end if;
        
  end process;       

---- Pipeline stage 7 ---

  H <= std_ulogic_vector(H_mul_result(24 downto 17));
  S <= std_ulogic_vector(r_S(7));
  V <= std_ulogic_vector(r_V);
  addr <= addr_delay(7);
  valid <= valid_delay(7);


end Behavioral;
