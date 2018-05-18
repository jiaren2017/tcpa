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

entity RGB2YUV_TB is
   
end RGB2YUV_TB;

architecture Behavioral of RGB2YUV_TB is
 component RGB2YUV
    port (clk   : in std_logic;
          Red   : in std_logic_vector (7 downto 0);
          Green : in std_logic_vector (7 downto 0);
          Blue  : in std_logic_vector (7 downto 0);
          Y     : out std_logic_vector (7 downto 0);
          U     : out std_logic_vector (7 downto 0);
          V     : out std_logic_vector (7 downto 0));
end component;

signal clk   : std_logic;
signal Red   : std_logic_vector (7 downto 0);
signal Green : std_logic_vector (7 downto 0);
signal Blue  : std_logic_vector (7 downto 0);
signal Y     : std_logic_vector (7 downto 0);
signal U     : std_logic_vector (7 downto 0);
signal V     : std_logic_vector (7 downto 0);

constant TbPeriod : time := 1000 ns; -- EDIT put right period here
signal TbClock : std_logic := '0';

begin

dut : RGB2YUV
port map (clk   => clk,
          Red   => Red,
          Green => Green,
          Blue  => Blue,
          Y     => Y,
          U     => U,
          V     => V);

TbClock <= not TbClock after TbPeriod/2;

-- EDIT: Check that clk is really your main clock signal
clk <= TbClock;

stimuli : process
begin
    red <=  std_logic_vector(to_unsigned(0,8));
    green <= std_logic_vector(to_unsigned(0,8));
    blue <= std_logic_vector(to_unsigned(0,8));
    wait;
end process;



end Behavioral;
