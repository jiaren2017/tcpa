library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_s16bit is
  port (
      clk : in std_ulogic;
      summand1  : in signed(16 downto 0);
      summand2  : in signed(16 downto 0);
      result    : out signed(16 downto 0)
  );
end add_s16bit;
  
architecture behavioral of add_s16bit is
  signal r_res_add : signed(16 downto 0);
begin
  process (clk, summand1, summand2)
  begin
    if(rising_edge(clk)) then
      r_res_add <= summand1 + summand2;
    end if;
  end process;

  result <= r_res_add;
end behavioral;

