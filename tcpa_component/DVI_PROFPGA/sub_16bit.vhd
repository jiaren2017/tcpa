library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sub_16bit is
  port (
      clk : in std_ulogic;
      minuend  : in unsigned(7 downto 0);
      subtrahend   : in unsigned(7 downto 0);
      result    : out unsigned(7 downto 0)
  );
end sub_16bit;

architecture behavioral of sub_s16bit is
  signal r_res_sub : signed(16 downto 0);
begin
  process (clk)
  begin
    if(rising_edge(clk)) then
      r_res_sub <= minuend - subtrahend;
    end if;
  end process;

  result <= r_res_sub;
end behavioral;
