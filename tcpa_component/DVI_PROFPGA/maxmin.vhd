library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maxmin is
  port(
    clk : in std_logic;
    A, B, C : in unsigned(7 downto 0);
    max_i : out unsigned(1 downto 0);
    min_i : out unsigned(1 downto 0)
  );
end maxmin;
  
architecture behavioral of maxmin is
  signal r_min_i, r_max_i : unsigned(1 downto 0);
begin
  process (clk, A, B, C)
    variable AbtB, AbtC, BbtC : boolean;
    begin
--    if(rising_edge(clk))then
        AbtB := (A >= B);
        AbtC := (A >= C);
        BbtC := (B >= C);
        if (AbtB) then
          if (AbtC) then
            r_max_i <= "00"; -- A
            if (BbtC) then
              r_min_i <= "10"; -- C
            else
              r_min_i <= "01"; -- B
            end if;
          else
            r_min_i <= "01"; -- B
            r_max_i <= "10"; -- C
          end if;
        else
          if (AbtC) then
            r_min_i <= "10"; -- C
            r_max_i <= "01"; -- B
          else
            r_min_i <= "00"; -- A
            if (BbtC) then
              r_max_i <= "01"; -- B
            else
              r_max_i <= "10"; -- C
            end if;
          end if;
        end if;
--    end if;
  end process;
  
  max_i <= r_max_i;
  min_i <= r_min_i;
end;
