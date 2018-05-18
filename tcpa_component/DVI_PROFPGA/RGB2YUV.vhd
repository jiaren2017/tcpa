----------------------------------------------------------------------------------
-- Company: 
-- Engineer: weichslgartner
-- 
-- Create Date: 05.08.2016 16:42:03
-- Design Name: 
-- Module Name: RGB2YUV - Behavioral
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
-- RGB to YUV conversion according to https://en.wikipedia.org/wiki/YUV#Full_swing_for_BT.601
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx lea f cells in this code.
--library unisim;
--use unisim.vcomponents.all;

entity rgb2yuv is
    port ( clk : in std_ulogic;
           red : in std_ulogic_vector (7 downto 0);
           green : in std_ulogic_vector (7 downto 0);
           blue : in std_ulogic_vector (7 downto 0);
           y : out std_ulogic_vector (7 downto 0);
           u : out std_ulogic_vector (7 downto 0);
           v : out std_ulogic_vector (7 downto 0));
end rgb2yuv;

architecture behavioral of rgb2yuv is
--signal u_debug : signed (17 downto 0);
--signal v_debug : signed (17 downto 0);
begin 

--comb : process(red, green, blue) is
  process(clk)
    variable y_tmp16 : unsigned (15 downto 0);
    variable u_tmp16 : signed (17 downto 0);
    variable v_tmp16 : signed (17 downto 0);
    variable y_tmp8  : unsigned (7 downto 0);
    variable u_tmp8  : signed (8 downto 0);
    variable v_tmp8  : signed (8 downto 0);
    begin
        if rising_edge(clk) then
            y_tmp16 := (76 * unsigned(red)) + (150 * unsigned(green)) + (29 * unsigned(blue));
            u_tmp16 := (-43 * signed('0' & red)) + (-84 * signed('0' & green)) + (127 * signed('0' &  blue));
            v_tmp16 := (127 * signed('0' &red)) + (-106 * signed('0' &green)) + (-21 * signed('0' & blue));
            y_tmp16 :=  y_tmp16  + 128;
            u_tmp16 :=  u_tmp16  + 128;
            v_tmp16 :=  v_tmp16  + 128;
         --   u_debug <= u_tmp16;
         --  v_debug <= v_tmp16;
            y_tmp8  :=  y_tmp16 (15 downto 8);
            u_tmp8  := u_tmp16(15) &   u_tmp16 (15 downto 8);
            v_tmp8  := v_tmp16(15) &   v_tmp16 (15 downto 8);
            
            
            u_tmp8  :=  u_tmp8 +128;
            v_tmp8  :=  v_tmp8 +128;
            y <=  std_ulogic_vector( y_tmp8);
            u <=  std_ulogic_vector( u_tmp8(7 downto 0 ));
            v <=  std_ulogic_vector(v_tmp8(7 downto 0 ) );
        end if;    
 end process;       


end Behavioral;


