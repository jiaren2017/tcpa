----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.06.2016 14:35:13
-- Design Name: 
-- Module Name: constants - Behavioral
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

library work;
package constants is
   constant         BITWIDTH_DUTY_CYCLE     : integer := 7;
  
   constant         BITWIDTH_COUNTERS_RESET : integer := 2;
   constant         BITWIDTH_PWMENABLE      : integer := 1;
   constant         BITWIDTH_SYS_PWM_RATION : integer := 32 - BITWIDTH_COUNTERS_RESET-BITWIDTH_PWMENABLE- BITWIDTH_DUTY_CYCLE ;
--   constant         BITWIDTH_SYS_FREQ : integer := 32;
--   constant         BITWIDTH_PWM_FREQ : integer := 11;
 end constants;
