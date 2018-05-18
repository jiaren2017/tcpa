library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity div_16bit is
  port (
      clk : in std_ulogic;
      dividend  : in unsigned(7 downto 0);
      divisor   : in unsigned(7 downto 0);
      valid_in  : in std_ulogic;
      result    : out unsigned(15 downto 0);
      valid     : out std_ulogic
  );
end div_16bit;

architecture behavioral of div_16bit is
  signal w_dividend : std_logic_vector(15 downto 0);
  signal w_divisor : std_logic_vector(7 downto 0);
  signal w_res_div : std_logic_vector(23 downto 0);
  signal w_valid : std_logic;
  
  signal r_divisor_is_zero : std_logic_vector(4 downto 1);
  
  component div_gen_16_8_p4 IS
    PORT (
      aclk : IN STD_LOGIC;
      s_axis_divisor_tvalid : IN STD_LOGIC;
      s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axis_dividend_tvalid : IN STD_LOGIC;
      s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      m_axis_dout_tvalid : OUT STD_LOGIC;
      m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
    );
  END component;
  
begin

  check_divisor : process(clk)
  begin
    if(rising_edge(clk))then
      r_divisor_is_zero(4) <= r_divisor_is_zero(3);
      r_divisor_is_zero(3) <= r_divisor_is_zero(2);
      r_divisor_is_zero(2) <= r_divisor_is_zero(1);
      if(divisor = 0)then
        r_divisor_is_zero(1) <= '1';
      else
        r_divisor_is_zero(1) <= '0';
      end if;
      
    end if;
  end process;

  w_dividend <= std_logic_vector(dividend & "00000000");
  w_divisor <= std_logic_vector(divisor);

  divider_16_8_p4 : div_gen_16_8_p4
  port map (
    aclk => clk,
    s_axis_dividend_tvalid => std_logic(valid_in),
    s_axis_dividend_tdata  => w_dividend,
    s_axis_divisor_tvalid  => std_logic(valid_in),
    s_axis_divisor_tdata   => w_divisor,
    m_axis_dout_tvalid => w_valid,
    m_axis_dout_tdata  => w_res_div
  ); 

  result <= unsigned(w_res_div(17 downto 2)) when r_divisor_is_zero(4) = '0' else
            to_unsigned(0, 16);
  valid <= std_ulogic(w_valid);
end;