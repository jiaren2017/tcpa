----------------------------------------------------------------------------------
-- Company: Hw/Sw Co-design (LS12) - FAU
-- Engineer: Éricles Sousa
-- 
-- Create Date: 27.07.2016 10:00
-- Design Name: 
-- Module Name: constants - Behavioral
-- Project Name: Inverted Pendulum
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

library work;
package motor_apb_lib is
	constant MOTOR_PINDEX                       : integer := 10;
	constant MOTOR_PADDR                        : integer := 16#00A#;
	constant MOTOR_PMASK                        : integer := 16#FFF#;
end motor_apb_lib;
