library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mul_16bit is
  port (
      clk : in std_ulogic;
      multiplicant: in unsigned(15 downto 0);
      multiplier : in unsigned(15 downto 0);
      result    : out unsigned(31 downto 0)
  );
end mul_16bit;
  
architecture behavioral of mul_16bit is
  signal r_res_mul : unsigned(31 downto 0);
begin
  process (clk, multiplicant, multiplier)
  begin
    if(rising_edge(clk)) then
      r_res_mul <= multiplicant * multiplier;
    end if;
  end process;

  result <= r_res_mul;
end;
