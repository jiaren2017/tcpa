----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.06.2016 16:47:10
-- Design Name: 
-- Module Name: pwm - Behavioral
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
use work.constants.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;

entity pwm is
--    generic (
--            sys_frequency : unsigned(bitwidth_sys_freq -1 downto 0) := to_unsigned(100000,bitwidth_sys_freq) ;
--            pwm_frequency : unsigned(bitwidth_pwm_freq-1 downto 0)  := to_unsigned(100,bitwidth_pwm_freq)); -- frequency in kHz
    Port ( clk : in std_logic;
           rst_n : in std_logic;
           ratio_sys_pwm_freq : in unsigned(BITWIDTH_SYS_PWM_RATION -1 downto 0);
           duty_cycle : in unsigned(BITWIDTH_DUTY_CYCLE -1 downto 0); --integer from 0 to 127
           pwm_out : out STD_LOGIC);
end pwm;

architecture Behavioral of pwm is


signal  counter     : unsigned(BITWIDTH_SYS_PWM_RATION-1 downto 0); 
signal  max_counter : unsigned(BITWIDTH_SYS_PWM_RATION -1 downto 0);
--signal  max_counter  : unsigned(bitwidth_sys_freq-1 downto 0) := (sys_frequency / pwm_frequency) -1;
signal  change_output : unsigned(BITWIDTH_SYS_PWM_RATION-1 downto 0);
signal  ratio_sys_pwm_freq_reg : unsigned(BITWIDTH_SYS_PWM_RATION-1 downto 0); 
signal duty_cycle_reg : unsigned(BITWIDTH_DUTY_CYCLE -1 downto 0);
begin

max_counter <=  ratio_sys_pwm_freq_reg;

process(clk)
begin
    if rising_edge(clk) then
        if(rst_n='0') then
            pwm_out <= '0';
            counter <= (others => '0');
        else
            counter <= counter+1;
            if counter = max_counter then
                 pwm_out <= '1';
                 counter <= (others => '0');
            elsif counter = change_output then
                pwm_out <= '0';
            end if;
            
        end if;
    end if;
end process;


process(clk)
begin
    if rising_edge(clk) then
      if(rst_n='0') then
          ratio_sys_pwm_freq_reg <=  to_unsigned(830, BITWIDTH_SYS_PWM_RATION);
          duty_cycle_reg <= to_unsigned(64,BITWIDTH_DUTY_CYCLE);
      else
          if ratio_sys_pwm_freq > 0 then
            ratio_sys_pwm_freq_reg <=   ratio_sys_pwm_freq;
          end if;
          if duty_cycle > 0 then
            duty_cycle_reg <=   duty_cycle;
          end if;
         
      end if;
    end if;     

end process;

process(clk)
 variable tmp : unsigned (BITWIDTH_SYS_PWM_RATION + BITWIDTH_DUTY_CYCLE-1  downto 0);
begin
    if rising_edge(clk) then
        if(rst_n='0')then
            change_output <= (others => '0');
        else    
            tmp := duty_cycle_reg * max_counter;
            tmp:=  tmp srl BITWIDTH_DUTY_CYCLE;
            change_output <= tmp(BITWIDTH_SYS_PWM_RATION-1 downto 0);
        end if;    
    end if;
end process;


end Behavioral;
