library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comp_and is
    generic( COMPONENT_ADDRESS: std_ulogic_vector(4 downto 0));
    port(
        A: in std_ulogic_vector  (4 downto 0);
        B: in std_ulogic_vector (4 downto 0);
        C: out std_ulogic_vector (4 downto 0);
        rst: in std_logic;
        CLK: in std_logic
    );	
end comp_and;

architecture Behavorial of comp_and is
begin
	
    process_and : process(CLK,rst)
    begin
        if(CLK'event and CLK='1') then
            if rst = '1' then 
                C <= (others=>'0');
            else
                C <= A and B;
            end if;
        end if; 
    end process;
    
end Behavorial;