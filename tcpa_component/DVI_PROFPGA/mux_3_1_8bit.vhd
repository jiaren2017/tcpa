library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_3_1_8bit is
  port(
    clk : in std_logic;
    A, B, C : in unsigned(7 downto 0);
    control : in unsigned(1 downto 0);
    result : out unsigned(7 downto 0)
  );
end mux_3_1_8bit;

architecture behavioral of mux_3_1_8bit is
begin
  result <= A when control = "00" else
            B when control = "01" else
            C;
end;
