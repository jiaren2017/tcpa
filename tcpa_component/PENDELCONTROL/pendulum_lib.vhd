----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.06.2016 16:58:22
-- Design Name: 
-- Module Name: motor_pwm - Behavioral
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
library grlib; 
use grlib.amba.all; use grlib.devices.all;
library gaisler; 
use gaisler.misc.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library work;
use work.constants.all;
use work.all;

package pendulum_lib is
  component motor_top is
      generic (
        pindex : integer := 0;
        paddr : integer := 0;
        pmask : integer := 16#fff#
      );
      Port ( clk : in STD_LOGIC;
          rstn : in STD_LOGIC;
          pwm_out : out STD_LOGIC;
          pwm_ref : out STD_LOGIC;
          pwmenable     : out STD_LOGIC;
          encoderRot : in std_logic_vector(1 downto 0);
          encoderDist : in std_logic_vector(1 downto 0);
          -- BUS protocol ports ---------------------------------------------- 
          apbi                 : in apb_slv_in_type;
          apbo                 : out apb_slv_out_type;
         
          
          -- LED ports--------------------------------------------------------
          led_blink             : out std_logic_vector(7 downto 3) 

             );
  end component;
end package;
