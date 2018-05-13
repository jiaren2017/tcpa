library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_test IS
end tb_test;

architecture behav of tb_test is

-- Signal Definition

signal sigA: std_ulogic_vector (4 downto 0);
signal sigB: std_ulogic_vector (4 downto 0);
signal sigC: std_ulogic_vector (4 downto 0);
signal sigClk: std_logic:= '0';
signal sigRst: std_logic:= '0';

-- Component Decleration

component test is
    generic( COMPONENT_ADDRESS: std_ulogic_vector(4 downto 0));
    port(
        test_A: in std_ulogic_vector  (4 downto 0);
        test_B: in std_ulogic_vector (4 downto 0);
        test_C: out std_ulogic_vector (4 downto 0);
        CLK: in std_logic;
        RST: in std_logic
    );
end component;


begin

    -- Component Instantiation

    uut: test
    generic map( COMPONENT_ADDRESS => "10101")
    port map(
        test_A => sigA,
        test_B => sigB,
        test_C => sigC,
        CLK => sigClk,
        RST => sigRst
    );

    -- Set clk
    clock: process
    begin
      sigClk <='0';
      wait for 10 ns;
      sigClk <='1';
      wait for 10 ns;
    end process;


    -- Set Values on Input

    stimuli: process
    begin
      sigA <="11010";
      sigB <="11110";
      sigRst <= '1';
      
      wait for 50 ns;
      
      sigRst <= '0';

      wait for 40 ns;
      
      sigA <="10101";
      sigB <="01010";
      
      wait for 40 ns;
      sigA <="11111";
      sigB <="00001";

      wait for 40 ns;
      
    end process;

end behav;
  

