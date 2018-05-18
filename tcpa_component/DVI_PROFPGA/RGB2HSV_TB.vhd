----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.08.2016 17:02:22
-- Design Name: 
-- Module Name: RGB2YUV_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity RGB2HSV_TB is
   
end RGB2HSV_TB;

architecture Behavioral of RGB2HSV_TB is
signal clk   : std_logic;
signal R     : std_ulogic_vector (7 downto 0);
signal G     : std_ulogic_vector (7 downto 0);
signal B     : std_ulogic_vector (7 downto 0);
signal H     : std_ulogic_vector (7 downto 0);
signal S     : std_ulogic_vector (7 downto 0);
signal V     : std_ulogic_vector (7 downto 0);

signal addr, addr_out : std_ulogic_vector(21 downto 0);
signal valid, valid_out : std_ulogic;

constant TbPeriod : time := 1000 ns;
signal TbClock : std_logic := '0';

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

dut : RGB2HSV
generic map(
  addr_w => 22
)
port map (
  clk   => clk,
  R     => R,
  G     => G,
  B     => B,
  valid_in => valid,
  addr_in => addr,

  H     => H,
  S     => S,
  V     => V,
  valid => valid_out,
  addr => addr_out
);

TbClock <= not TbClock after TbPeriod/2;

-- EDIT: Check that clk is really your main clock signal
clk <= TbClock;

stimuli : process
begin

    valid <= '0';
    wait for TbPeriod*2;

    R <= std_ulogic_vector(to_unsigned(0, 8));
    G <= std_ulogic_vector(to_unsigned(0, 8));
    B <= std_ulogic_vector(to_unsigned(0, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(0, 22));
    wait for TbPeriod;
    
    
    R <= std_ulogic_vector(to_unsigned(255, 8));
    G <= std_ulogic_vector(to_unsigned(255, 8));
    B <= std_ulogic_vector(to_unsigned(255, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(1, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(255, 8));
    G <= std_ulogic_vector(to_unsigned(0, 8));
    B <= std_ulogic_vector(to_unsigned(0, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(2, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(0, 8));
    G <= std_ulogic_vector(to_unsigned(255, 8));
    B <= std_ulogic_vector(to_unsigned(0, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(3, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(0, 8));
    G <= std_ulogic_vector(to_unsigned(0, 8));
    B <= std_ulogic_vector(to_unsigned(255, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(4, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(255, 8));
    G <= std_ulogic_vector(to_unsigned(255, 8));
    B <= std_ulogic_vector(to_unsigned(0, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(5, 22));
    wait for TbPeriod;   
             

    R <= std_ulogic_vector(to_unsigned(0, 8));
    G <= std_ulogic_vector(to_unsigned(255, 8));
    B <= std_ulogic_vector(to_unsigned(255, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(6, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(255, 8));
    G <= std_ulogic_vector(to_unsigned(0, 8));
    B <= std_ulogic_vector(to_unsigned(255, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(7, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(192, 8));
    G <= std_ulogic_vector(to_unsigned(192, 8));
    B <= std_ulogic_vector(to_unsigned(192, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(8, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(128, 8));
    G <= std_ulogic_vector(to_unsigned(128, 8));
    B <= std_ulogic_vector(to_unsigned(128, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(9, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(128, 8));
    G <= std_ulogic_vector(to_unsigned(0, 8));
    B <= std_ulogic_vector(to_unsigned(0, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(10, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(128, 8));
    G <= std_ulogic_vector(to_unsigned(128, 8));
    B <= std_ulogic_vector(to_unsigned(0, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(11, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(0, 8));
    G <= std_ulogic_vector(to_unsigned(128, 8));
    B <= std_ulogic_vector(to_unsigned(0, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(12, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(128, 8));
    G <= std_ulogic_vector(to_unsigned(0, 8));
    B <= std_ulogic_vector(to_unsigned(128, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(13, 22));
    wait for TbPeriod;
                

    R <= std_ulogic_vector(to_unsigned(0, 8));
    G <= std_ulogic_vector(to_unsigned(128, 8));
    B <= std_ulogic_vector(to_unsigned(128, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(14, 22));
    wait for TbPeriod;
        
    
    R <= std_ulogic_vector(to_unsigned(0, 8));
    G <= std_ulogic_vector(to_unsigned(0, 8));
    B <= std_ulogic_vector(to_unsigned(128, 8));
    valid <= '1';
    addr <= std_ulogic_vector(to_unsigned(15, 22));
    wait for TbPeriod;  
                      
        
end process;

test : process
begin

    wait until valid_out = '1';
    wait for TbPeriod/2;
    
    assert(not((H = "00000000") and (S = "00000000") and (V = "00000000"))) report "Conversion of RGB = (0, 0, 0) failed." severity failure;
    
    wait for TbPeriod;
        
    assert(not((H = "00000000") and (S = "00000000") and (V = "11111111"))) report "Conversion of RGB = (255, 255, 255) failed." severity failure;
        
    wait for TbPeriod;
        
    assert(not((H = "00000000") and (S = "11111111") and (V = "11111111"))) report "Conversion of RGB = (255, 0, 0) failed." severity failure;
        
    wait for TbPeriod;
        
    assert(not((H = "00111100") and (S = "11111111") and (V = "11111111"))) report "Conversion of RGB = (0, 255, 0) failed." severity failure;
    
    wait for TbPeriod;
        
    assert(not((H = "01111000") and (S = "11111111") and (V = "11111111"))) report "Conversion of RGB = (0, 0, 255) failed." severity failure;
    
    wait for TbPeriod;   
        
    assert(not((H = "00011110") and (S = "11111111") and (V = "11111111"))) report "Conversion of RGB = (255, 255, 0) failed." severity failure;
             
    wait for TbPeriod;
        
    assert(not((H = "01011010") and (S = "11111111") and (V = "11111111"))) report "Conversion of RGB = (0, 255, 255) failed." severity failure;
        
    wait for TbPeriod;
        
    assert(not((H = "10010110") and (S = "11111111") and (V = "11111111"))) report "Conversion of RGB = (255, 0, 255) failed." severity failure;
        
    wait for TbPeriod;
        
    assert(not((H = "00000000") and (S = "00000000") and (V = "11000000"))) report "Conversion of RGB = (192, 192, 192) failed." severity failure;
        
    wait for TbPeriod;
        
    assert(not((H = "00000000") and (S = "00000000") and (V = "10000000"))) report "Conversion of RGB = (128, 128, 128) failed." severity failure;
        
    wait for TbPeriod;
        
    assert(not((H = "00000000") and (S = "11111111") and (V = "10000000"))) report "Conversion of RGB = (128, 0, 0) failed." severity failure;
        
    wait for TbPeriod;
        
    assert(not((H = "00011110") and (S = "11111111") and (V = "10000000"))) report "Conversion of RGB = (128, 128, 0) failed." severity failure;
        
    wait for TbPeriod;
        
    assert(not((H = "00111100") and (S = "11111111") and (V = "10000000"))) report "Conversion of RGB = (0, 128, 0) failed." severity failure;
    
    wait for TbPeriod;
        
    assert(not((H = "10010110") and (S = "11111111") and (V = "10000000"))) report "Conversion of RGB = (128, 0, 128) failed." severity failure;

    wait for TbPeriod;
        
    assert(not((H = "01011010") and (S = "11111111") and (V = "10000000"))) report "Conversion of RGB = (0, 128, 128) failed." severity failure;
        
    wait for TbPeriod;  
        
    assert(not((H = "01111000") and (S = "11111111") and (V = "10000000"))) report "Conversion of RGB = (0, 0, 128) failed." severity failure;
                      
    assert(true) report "Test successful!" severity failure;
end process;



end Behavioral;
