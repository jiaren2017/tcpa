library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test is
    generic( COMPONENT_ADDRESS: std_ulogic_vector  (4 downto 0));
    port(
        test_A: in std_ulogic_vector  (4 downto 0);
        test_B: in std_ulogic_vector (4 downto 0);
        test_C: out std_ulogic_vector (4 downto 0);
        CLK: in std_logic;
        RST: in std_logic
    );	
end test;

architecture Behavorial of test is


component comp_and is
    generic( COMPONENT_ADDRESS: std_ulogic_vector(4 downto 0));
    port(
        A: in std_ulogic_vector  (4 downto 0);
        B: in std_ulogic_vector (4 downto 0);
        C: out std_ulogic_vector (4 downto 0);
        rst: in std_logic;
        CLK: in std_logic
    );	
end component comp_and;


signal and_a : std_ulogic_vector  (4 downto 0);
signal and_b : std_ulogic_vector  (4 downto 0);
signal and_c : std_ulogic_vector  (4 downto 0);

begin

    and_a <= test_A;
    and_b <= test_B;
    
    comp_and_i : comp_and
    generic map(COMPONENT_ADDRESS => COMPONENT_ADDRESS)
    port map(
        A => test_A, --and_a,
        B => test_B, --and_b,
        C => and_c,
        rst => RST,
        CLK => CLK
    );	
  

    gen: process(CLK,RST)
    begin
        if(CLK'event and CLK='1') then
            if RST = '1' then 
                test_C <= (others=>'0');
            else
                test_C <= and_c;
            end if;
        end if; 
    end process;

end Behavorial;
