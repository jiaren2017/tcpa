---------------------------------------------------------------------------------------------------------------------------------
-- (C) Copyright 2013 Chair for Hardware/Software Co-Design, Department of Computer Science 12,
-- University of Erlangen-Nuremberg (FAU). All Rights Reserved
--------------------------------------------------------------------------------------------------------------------------------
-- Module Name:  
-- Project Name:  
--
-- Engineer:     
-- Create Date:   
-- Description:  
--
--------------------------------------------------------------------------------------------------------------------------------


-- file power_controller.vhd
-- marked 15.04.2009

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.WPPE_LIB.ALL;
use WORK.DEFAULT_LIB.ALL;
use WORK.ARRAY_LIB.ALL;

use WORK.TYPE_LIB.all;

entity PWR_CONTROLLER is
	generic(

		-- cadence translate_off			
		INSTANCE_NAME        : string                 := "?";
		-- cadence translate_on	

		WPPE_GENERICS_RECORD : t_wppe_generics_record := CUR_DEFAULT_WPPE_GENERICS_RECORD
	);

	port(
		clk, reset : std_logic;
		input      : in  std_logic_vector(1 downto 0); -- SEE TYPE_LIB.vhd FOR DEFINITIONS
		output     : out std_logic_vector(5 downto 0)
	);

end entity;

architecture rtl of PWR_CONTROLLER is
	type state_type is (POWER_OFF, ISOLATE, SAVE, CLK_OFF, POWER_ON, POWER_UP, PWR_ON_RESET, RESTORE, CLK_ON, CONNECT);

	signal INSTANCE_STATE : state_type;

begin
	pcu_fsm : process(clk, reset)
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				INSTANCE_STATE <= POWER_OFF;

				output(save_bit)         <= AUS;
				output(nrestore_bit)     <= n_AUS;
				output(iso_bit)          <= AN;
				output(pso_bit)          <= n_AN;
				output(clk_so_bit)       <= AN;
				output(pwr_up_reset_bit) <= AN;

			else

				--	 	output(save_bit)      <= AUS;
				--	 	output(nrestore_bit)  <= n_AUS;
				--        
				--    output(iso_bit)     <= AUS;
				--    output(pso_bit)     <= n_AUS;
				--	 	output(clk_so_bit)  <= AUS;

				case INSTANCE_STATE is
					when POWER_ON =>
						if (input(power_down_bit) = AN) then
						--         INSTANCE_STATE <= ISOLATE;
						end if;

						output(save_bit)     <= AUS;
						output(nrestore_bit) <= n_AUS;

						output(iso_bit)    <= AUS;
						output(pso_bit)    <= n_AUS;
						output(clk_so_bit) <= AUS;

						output(pwr_up_reset_bit) <= AUS;

					when ISOLATE =>
						INSTANCE_STATE <= SAVE;

						output(save_bit)     <= AUS;
						output(nrestore_bit) <= n_AUS;

						output(iso_bit) <= AN;

						output(pso_bit)    <= n_AUS;
						output(clk_so_bit) <= AUS;

						output(pwr_up_reset_bit) <= AUS;

					when SAVE =>
						INSTANCE_STATE <= CLK_OFF;

						output(save_bit)     <= AN;
						output(nrestore_bit) <= n_AUS;
						output(iso_bit)      <= AN;

						output(pso_bit)    <= n_AUS;
						output(clk_so_bit) <= AUS;

						output(pwr_up_reset_bit) <= AUS;

					when CLK_OFF =>
						INSTANCE_STATE <= POWER_OFF;

						output(save_bit)     <= AN;
						output(nrestore_bit) <= n_AUS;

						output(iso_bit) <= AN;
						output(pso_bit) <= n_AUS;

						output(clk_so_bit) <= AN;

						output(pwr_up_reset_bit) <= AUS;

					when POWER_OFF =>
						if (input(power_down_bit) = AUS
						--	AND WPPE_GENERICS_RECORD.POWER_OFF = '0'
						) then
							INSTANCE_STATE <= POWER_UP;
						else
							INSTANCE_STATE <= POWER_OFF;
						end if;

						output(save_bit)     <= AUS;
						output(nrestore_bit) <= n_AUS;

						output(iso_bit) <= AN;
						output(pso_bit) <= n_AN;

						output(clk_so_bit) <= AN;

						output(pwr_up_reset_bit) <= AN;

					when POWER_UP =>
						if (input(power_down_ready_bit) = n_AN) then
							INSTANCE_STATE <= PWR_ON_RESET;
						else
							INSTANCE_STATE <= POWER_UP;
						end if;

						output(save_bit)     <= AUS;
						output(nrestore_bit) <= n_AUS;

						output(iso_bit) <= AN;

						output(pso_bit) <= n_AUS;

						output(clk_so_bit) <= AN;

						output(pwr_up_reset_bit) <= AN;

					when PWR_ON_RESET =>
						INSTANCE_STATE <= RESTORE;

						output(save_bit)     <= AUS;
						output(nrestore_bit) <= n_AUS;

						output(iso_bit) <= AN;

						output(pso_bit) <= n_AUS;

						output(clk_so_bit) <= AN;

						output(pwr_up_reset_bit) <= AN;

					when RESTORE =>
						INSTANCE_STATE <= CONNECT;

						output(save_bit)     <= AUS;
						output(nrestore_bit) <= n_AN;

						output(iso_bit) <= AN;
						output(pso_bit) <= n_AUS;

						output(clk_so_bit) <= AN;

						output(pwr_up_reset_bit) <= AN;

					when CONNECT =>
						INSTANCE_STATE <= CLK_ON;

						output(save_bit)     <= '0';
						output(nrestore_bit) <= n_AN;

						output(iso_bit)    <= AN;
						output(pso_bit)    <= n_AUS;
						output(clk_so_bit) <= AN;

						output(pwr_up_reset_bit) <= AN;

					when CLK_ON =>
						INSTANCE_STATE <= POWER_ON;

						output(save_bit)     <= AUS;
						output(nrestore_bit) <= n_AUS;

						output(iso_bit) <= AUS;
						output(pso_bit) <= n_AUS;

						output(clk_so_bit) <= AUS;

						output(pwr_up_reset_bit) <= AN;

					when others =>
						INSTANCE_STATE <= POWER_OFF;

						output(save_bit)     <= AUS;
						output(nrestore_bit) <= n_AUS;
						output(iso_bit)      <= AUS;
						output(pso_bit)      <= n_AUS;
						output(clk_so_bit)   <= AUS;

						output(pwr_up_reset_bit) <= AUS;

				end case;

			end if;
		end if;
	end process;

end architecture;
