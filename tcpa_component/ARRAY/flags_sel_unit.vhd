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


--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    15:37:03 09/04/08
-- Design Name:    
-- Module Name:    flags_sel_unit - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library wppa_instance_v1_01_a;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;

entity flags_sel_unit is
	generic(
		-- cadence translate_off		  		
		INSTANCE_NAME        : string                 := "flags_sel_unit";
		-- cadence translate_on				
		WPPE_GENERICS_RECORD : t_wppe_generics_record := CUR_DEFAULT_WPPE_GENERICS_RECORD
	);
	port(
		branch_flag_controls_vector : in  std_logic_vector(
			WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS * ( -- See the "TYPE_LIB.vhd" library for definition
				3 +                     -- SEL_FU_WIDTH 
				LOG_MAX_NUM_FU +        -- log(MAX_NUM_FU)
				LOG_MAX_NUM_FLAGS +     -- log(MAX_NUM_FLAGS)
				LOG_MAX_NUM_CTRL_SIG    -- log(MAX_NUM_CTRL_SIG) 
			) - 1 downto 0);
		-- :in  t_flag_controls(1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS);   -- See the "TYPE_LIB.vhd" library for definition
		FU_flag_values_vector       : in  std_logic_vector(
			4 * (MAX_NUM_FU * MAX_NUM_FLAGS + 1) + MAX_NUM_CONTROL_REGS + MAX_NUM_CONTROL_INPUTS + MAX_NUM_CONTROL_OUTPUTS + 1 downto 0);
		--:in  t_FU_flags_values;  -- See the "TYPE_LIB.vhd" library for definition
		branch_flag_values          : out std_logic_vector(1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS)
	);

end flags_sel_unit;

architecture Behavioral of flags_sel_unit is

	--==============================================================================================
	--  =====================  CONVERSION   OF  RECORD_TYPES  TO  STD_LOGIC_VECTOR =================
	--==============================================================================================
	signal branch_flag_controls : t_flag_controls(1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS);

	signal FU_flag_values : t_FU_flags_values;

	--==============================================================================================
	--  =====================  CONVERSION   OF  RECORD_TYPES  TO  STD_LOGIC_VECTOR =================
	--==============================================================================================

	CONSTANT SUM_OF_FU : integer := WPPE_GENERICS_RECORD.NUM_OF_ADD_FU + WPPE_GENERICS_RECORD.NUM_OF_MUL_FU + WPPE_GENERICS_RECORD.NUM_OF_LOGIC_FU + WPPE_GENERICS_RECORD.NUM_OF_SHIFT_FU;
	CONSTANT SIZE_OF_BRANCH_FLAG_CTRL : integer := LOG_MAX_NUM_FU + LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_CTRL_SIG + 3; -- see file type_lib.vhd for detail

	CONSTANT ALL_CTRL_FLAGS_WIDTH     : integer := WPPE_GENERICS_RECORD.NUM_OF_CONTROL_REGS + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS;
	CONSTANT ALL_CTRL_FLAGS_SEL_WIDTH : integer := log_width(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_REGS + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS);

	signal all_adder_flags : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_ADD_FU * MAX_NUM_FLAGS downto 0);
	signal all_mul_flags   : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_MUL_FU * MAX_NUM_FLAGS downto 0);
	signal all_logic_flags : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_LOGIC_FU * MAX_NUM_FLAGS downto 0);
	signal all_shift_flags : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_SHIFT_FU * MAX_NUM_FLAGS downto 0);

	signal all_control_flags : std_logic_vector(WPPE_GENERICS_RECORD.NUM_OF_CONTROL_REGS + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS downto 0);

	type t_selected_FU_array is array (integer range 1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS) of std_logic_vector(MAX_NUM_FLAGS downto 0);

	type t_selected_CTRL_array is array (integer range 1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS) of std_logic;

	type t_selected_flags_array is array (integer range 1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS) of std_logic_vector(SUM_OF_FU * MAX_NUM_FLAGS - 1 downto 0);

	type t_flag_array is array (integer range 1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS) of std_logic;

	type t_fu_ctrl_flag_array is array (integer range 1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS) of std_logic_vector(1 downto 0);

	signal selected_adder_flags : t_selected_FU_array := (others=>(others=>'0'));
	signal selected_mul_flags   : t_selected_FU_array := (others=>(others=>'0'));
	signal selected_logic_flags : t_selected_FU_array := (others=>(others=>'0'));
	signal selected_shift_flags : t_selected_FU_array := (others=>(others=>'0'));
	signal selected_unit_flags  : t_selected_FU_array := (others=>(others=>'0'));
	signal selected_fu_flag     : t_selected_FU_array := (others=>(others=>'0'));

	signal functional_flags_out : t_selected_FU_array;

	signal selected_CTRL_flag : t_selected_CTRL_array;

	signal fu_selected_flags : t_selected_flags_array := (others=>(others=>'0'));
	signal fu_flag           : t_flag_array; -- FINAL FU FLAG

	signal ctrl_flag                : t_flag_array; -- FINAL CONTROL FLAG
	signal fu_ctrl_final_flag_array : t_fu_ctrl_flag_array;

	signal ctrl_unit_selected : std_logic_vector(1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS);

	--===============================================================================--
	-- 2:1 multiplexer component declaration --
	--===============================================================================--

	component mux_2_1 is
		generic(
			-- cadence translate_off		
			INSTANCE_NAME : string;
			-- cadence translate_on			
			DATA_WIDTH    : positive range 1 to MAX_DATA_WIDTH := CUR_DEFAULT_DATA_WIDTH
		);

		port(
			data_inputs : in  std_logic_vector(2 * DATA_WIDTH - 1 downto 0);
			sel         : in  std_logic;
			output      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

	end component mux_2_1;

	--===============================================================================--
	-- Generic multiplexer component declaration --
	--===============================================================================--

	component wppe_multiplexer is
		generic(
			-- cadence translate_off	
			INSTANCE_NAME     : string;
			-- cadence translate_on			
			INPUT_DATA_WIDTH  : positive range 1 to 64;
			OUTPUT_DATA_WIDTH : positive range 1 to 64;
			SEL_WIDTH         : positive range 1 to 32;
			BRANCH_FLAG_INDEX : positive range 1 to 32;
			NUM_OF_FUS        : positive range 1 to 32;
			NUM_OF_INPUTS     : positive range 1 to 64
		);

		port(
			data_inputs : in  std_logic_vector(INPUT_DATA_WIDTH * NUM_OF_INPUTS - 1 downto 0);
			sel         : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
			output      : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
		);

	end component;

begin

	--==============================================================================================
	--  =====================  CONVERSION   OF  RECORD_TYPES  TO  STD_LOGIC_VECTOR =================
	--==============================================================================================
	CONVERT_VECTOR_T_FLAG_CONTROLS : FOR i in 1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS GENERATE
		--branch_flag_controls(i).SEL_FU        <= branch_flag_controls_vector(2 downto 0);
		--branch_flag_controls(i).SEL_FU_NO     <= branch_flag_controls_vector(LOG_MAX_NUM_FU - 1 + 3 downto 3);
		--branch_flag_controls(i).SEL_FLAG      <= branch_flag_controls_vector(LOG_MAX_NUM_FLAGS - 1 + LOG_MAX_NUM_FU + 3 downto LOG_MAX_NUM_FU + 3);
		--branch_flag_controls(i).SEL_CTRL_FLAG <= branch_flag_controls_vector(LOG_MAX_NUM_CTRL_SIG - 1 + LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_FU + 3 downto LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_FU + 3);
		branch_flag_controls(i).SEL_FU        <= branch_flag_controls_vector((SIZE_OF_BRANCH_FLAG_CTRL*(i-1))+ 2 downto (SIZE_OF_BRANCH_FLAG_CTRL*(i-1))+0);
		branch_flag_controls(i).SEL_FU_NO     <= branch_flag_controls_vector((SIZE_OF_BRANCH_FLAG_CTRL*(i-1))+ LOG_MAX_NUM_FU - 1 + 3 downto (SIZE_OF_BRANCH_FLAG_CTRL*(i-1))+3);
		branch_flag_controls(i).SEL_FLAG      <= branch_flag_controls_vector((SIZE_OF_BRANCH_FLAG_CTRL*(i-1))+ LOG_MAX_NUM_FLAGS - 1 + LOG_MAX_NUM_FU + 3 downto (SIZE_OF_BRANCH_FLAG_CTRL*(i-1))+LOG_MAX_NUM_FU + 3);
		branch_flag_controls(i).SEL_CTRL_FLAG <= branch_flag_controls_vector((SIZE_OF_BRANCH_FLAG_CTRL*(i-1))+ LOG_MAX_NUM_CTRL_SIG - 1 + LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_FU + 3 downto (SIZE_OF_BRANCH_FLAG_CTRL*(i-1)) + LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_FU + 3);
	END GENERATE CONVERT_VECTOR_T_FLAG_CONTROLS;

	CONVERT_VECTOR_FU_FLAG_VALUES : FOR i in 1 to 1 GENERATE
		FU_flag_values.ADDER_flags.flags <= FU_flag_values_vector((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 1 - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * (1 - 1));
		FU_flag_values.MUL_flags.flags   <= FU_flag_values_vector((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 2 - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * (2 - 1));
		FU_flag_values.LOGIC_flags.flags <= FU_flag_values_vector((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 3 - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * (3 - 1));
		FU_flag_values.SHIFT_flags.flags <= FU_flag_values_vector((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 4 - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * (4 - 1));
		FU_flag_values.CTRL_flags <= FU_flag_values_vector(((MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 4 + MAX_NUM_CONTROL_REGS + MAX_NUM_CONTROL_INPUTS + MAX_NUM_CONTROL_OUTPUTS + 1) - 1 downto (MAX_NUM_FU * MAX_NUM_FLAGS + 1) * 4);

	END GENERATE CONVERT_VECTOR_FU_FLAG_VALUES;

	--==============================================================================================
	--  =====================  CONVERSION   OF  RECORD_TYPES  TO  STD_LOGIC_VECTOR =================
	--==============================================================================================


	FLAG_CTRL_STRUCTURE : FOR i in 1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS GENERATE
		--fu_ctrl_final_flag_array(i) <= fu_flag(WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS+1-i) & ctrl_flag(i);
		fu_ctrl_final_flag_array(i) <= fu_flag(i) & ctrl_flag(i);

		--=================================================================
		--=================================================================
		ctrl_unit_selected(i) <= NOT (branch_flag_controls(i).SEL_FU(0) AND branch_flag_controls(i).SEL_FU(1) AND branch_flag_controls(i).SEL_FU(2)
			);

		--=================================================================
		--=================================================================

		CHECK_ADD : IF WPPE_GENERICS_RECORD.NUM_OF_ADD_FU > 0 GENERATE
			fu_selected_flags(i)(MAX_NUM_FLAGS * 1 - 1 downto MAX_NUM_FLAGS * (1 - 1)) <= selected_adder_flags(i)(MAX_NUM_FLAGS - 1 downto 0); -- "000" Selected adder flags
			--fu_selected_flags(WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS+1-i)(MAX_NUM_FLAGS * 1 - 1 downto MAX_NUM_FLAGS * (1 - 1)) <= selected_adder_flags(i)(MAX_NUM_FLAGS - 1 downto 0); -- "000" Selected adder flags

			adder_fu_flags_mux : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/adder_fu_mux_" & Int_to_string(i),
					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MAX_NUM_FLAGS,
					OUTPUT_DATA_WIDTH => MAX_NUM_FLAGS,
					SEL_WIDTH         => LOG_MAX_NUM_FU,
					NUM_OF_FUS        => WPPE_GENERICS_RECORD.NUM_OF_ADD_FU,
					BRANCH_FLAG_INDEX => 1,
					NUM_OF_INPUTS     => 1 --MAX_NUM_FU --WPPE_GENERICS_RECORD.NUM_OF_ADD_FU -- NUM_OF_ADD_FU adders 
				)
				port map(
					--data_inputs(MAX_NUM_FU * MAX_NUM_FLAGS - 1 downto 0) => FU_flag_values.ADDER_flags.flags(MAX_NUM_FU * MAX_NUM_FLAGS - 1 downto 0),
					data_inputs(MAX_NUM_FLAGS - 1 downto 0)              => FU_flag_values.ADDER_flags.flags(i*MAX_NUM_FLAGS - 1 downto (i-1)*MAX_NUM_FLAGS),
					sel                                                  => branch_flag_controls(i).SEL_FU_NO,
					output(MAX_NUM_FLAGS - 1 downto 0)                   => selected_adder_flags(i)(MAX_NUM_FLAGS - 1 downto 0)
				);

		END GENERATE CHECK_ADD;

		CHECK_MUL : IF WPPE_GENERICS_RECORD.NUM_OF_MUL_FU > 0 GENERATE
			fu_selected_flags(i)(MAX_NUM_FLAGS * 2 - 1 downto MAX_NUM_FLAGS * (2 - 1)) <= selected_mul_flags(i)(MAX_NUM_FLAGS - 1 downto 0); -- "001" Selected mul flags
			--fu_selected_flags(WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS+1-i)(MAX_NUM_FLAGS * 2 - 1 downto MAX_NUM_FLAGS * (2 - 1)) <= selected_mul_flags(i)(MAX_NUM_FLAGS - 1 downto 0); -- "001" Selected mul flags

			mul_fu_flags_mux : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/mul_fu_mux_" & Int_to_string(i),
					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MAX_NUM_FLAGS,
					OUTPUT_DATA_WIDTH => MAX_NUM_FLAGS,
					SEL_WIDTH         => log_width(MAX_NUM_FU),
					NUM_OF_FUS        => WPPE_GENERICS_RECORD.NUM_OF_MUL_FU,
					BRANCH_FLAG_INDEX => 1,
					NUM_OF_INPUTS     => 1 --MAX_NUM_FU --WPPE_GENERICS_RECORD.NUM_OF_MUL_FU -- NUM_OF_MUL_FU mults 
				)
				port map(
				--	data_inputs(MAX_NUM_FLAGS * MAX_NUM_FU - 1 downto 0) => FU_flag_values.MUL_flags.flags(MAX_NUM_FLAGS * MAX_NUM_FU - 1 downto 0),
					data_inputs(MAX_NUM_FLAGS -1 downto 0)               => FU_flag_values.MUL_flags.flags(i*MAX_NUM_FLAGS - 1 downto (i-1)*MAX_NUM_FLAGS),
					sel                                                  => branch_flag_controls(i).SEL_FU_NO,
					output(MAX_NUM_FLAGS - 1 downto 0)                   => selected_mul_flags(i)(MAX_NUM_FLAGS - 1 downto 0)
				);

		END GENERATE CHECK_MUL;

		CHECK_LOGIC : IF WPPE_GENERICS_RECORD.NUM_OF_LOGIC_FU > 0 GENERATE
			fu_selected_flags(i)(MAX_NUM_FLAGS * 3 - 1 downto MAX_NUM_FLAGS * (3 - 1)) <= selected_logic_flags(i)(MAX_NUM_FLAGS - 1 downto 0); -- "011" Selected logic flags
			--fu_selected_flags(WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS+1-i)(MAX_NUM_FLAGS * 3 - 1 downto MAX_NUM_FLAGS * (3 - 1)) <= selected_logic_flags(i)(MAX_NUM_FLAGS - 1 downto 0); -- "011" Selected logic flags

			LOGIC_fu_flags_mux : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/logic_fu_mux_" & Int_to_string(i),
					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MAX_NUM_FLAGS,
					OUTPUT_DATA_WIDTH => MAX_NUM_FLAGS,
					SEL_WIDTH         => log_width(MAX_NUM_FU),
					NUM_OF_FUS        => WPPE_GENERICS_RECORD.NUM_OF_LOGIC_FU,
					BRANCH_FLAG_INDEX => 1,
					NUM_OF_INPUTS     => 1 --MAX_NUM_FU --WPPE_GENERICS_RECORD.NUM_OF_LOGIC_FU -- NUM_OF_LOGIC_FU logic 
				)
				port map(
					--data_inputs(MAX_NUM_FLAGS * MAX_NUM_FU - 1 downto 0) => FU_flag_values.LOGIC_flags.flags(MAX_NUM_FLAGS * MAX_NUM_FU - 1 downto 0),
					data_inputs(MAX_NUM_FLAGS - 1 downto 0)              => FU_flag_values.LOGIC_flags.flags(i*MAX_NUM_FLAGS - 1 downto (i-1)*MAX_NUM_FLAGS),
					sel                                                  => branch_flag_controls(i).SEL_FU_NO,
					output(MAX_NUM_FLAGS - 1 downto 0)                   => selected_LOGIC_flags(i)(MAX_NUM_FLAGS - 1 downto 0)
				);

		END GENERATE CHECK_LOGIC;

		CHECK_SHIFT : IF WPPE_GENERICS_RECORD.NUM_OF_SHIFT_FU > 1 GENERATE -- TODO 0 not working
			--4!!! wrong if one of the above fus is not included
			fu_selected_flags(i)(MAX_NUM_FLAGS * 4 - 1 downto MAX_NUM_FLAGS * (4 - 1)) <= selected_shift_flags(i)(MAX_NUM_FLAGS - 1 downto 0); -- "100" Selected shift flags
			--fu_selected_flags(WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS+1-i)(MAX_NUM_FLAGS * 4 - 1 downto MAX_NUM_FLAGS * (4 - 1)) <= selected_shift_flags(i)(MAX_NUM_FLAGS - 1 downto 0); -- "100" Selected shift flags

			SHIFT_fu_flags_mux : wppe_multiplexer
				generic map(
					-- cadence translate_off
					INSTANCE_NAME     => INSTANCE_NAME & "/shift_fu_mux_" & Int_to_string(i),
					-- cadence translate_on
					INPUT_DATA_WIDTH  => MAX_NUM_FLAGS,
					OUTPUT_DATA_WIDTH => MAX_NUM_FLAGS,
					SEL_WIDTH         => log_width(MAX_NUM_FU),
					NUM_OF_FUS        => WPPE_GENERICS_RECORD.NUM_OF_SHIFT_FU,
					BRANCH_FLAG_INDEX => 1,
					NUM_OF_INPUTS     => 1 --MAX_NUM_FU --WPPE_GENERICS_RECORD.NUM_OF_SHIFT_FU -- NUM_OF_SHIFT_FU shifters 
				)
				port map(
					--data_inputs(MAX_NUM_FLAGS * MAX_NUM_FU - 1 downto 0) => FU_flag_values.SHIFT_flags.flags(MAX_NUM_FLAGS * MAX_NUM_FU - 1 downto 0),
					data_inputs(MAX_NUM_FLAGS - 1 downto 0)              => FU_flag_values.SHIFT_flags.flags(i*MAX_NUM_FLAGS - 1 downto (i-1)*MAX_NUM_FLAGS),
					sel                                                  => branch_flag_controls(i).SEL_FU_NO,
					output(MAX_NUM_FLAGS - 1 downto 0)                   => selected_SHIFT_flags(i)(MAX_NUM_FLAGS - 1 downto 0)
				);

		END GENERATE CHECK_SHIFT;

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
		--       SEL_FU Multiplexer
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	

		CHECK_SUM_OF_FU : IF SUM_OF_FU > 0 GENERATE
			fu_unit_selected_flags_mux : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/all_fu_flags_mux_" & Int_to_string(i),
					-- cadence translate_on	
					INPUT_DATA_WIDTH  => MAX_NUM_FLAGS,
					OUTPUT_DATA_WIDTH => MAX_NUM_FLAGS,
					--SEL_WIDTH         => log_width(MAX_NUM_FU),
					--SEL_WIDTH         => log_width(SUM_OF_FU), -- 4 FU types: ADD, MUL, LOGIC, SHIFT, (+ DIV, ...)
                                        SEL_WIDTH         => 3,
					NUM_OF_FUS        => 4,
					BRANCH_FLAG_INDEX => 1,
					NUM_OF_INPUTS     => SUM_OF_FU
				)
				port map(
					data_inputs                        => fu_selected_flags(i), -- This signal receives as input flags from all FUS
					sel                                => branch_flag_controls(i).SEL_FU,
					output(MAX_NUM_FLAGS - 1 downto 0) => functional_flags_out(i)(MAX_NUM_FLAGS - 1 downto 0)
				);

		END GENERATE CHECK_SUM_OF_FU;

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
		--       SEL_FLAG Multiplexer
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	


		FU_FLAG_SELECT : IF SUM_OF_FU > 0 GENERATE
			fu_flag_select_mux : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/fu_flags_mux_" & Int_to_string(i),
					-- cadence translate_on	
					INPUT_DATA_WIDTH  => 1,
					OUTPUT_DATA_WIDTH => 1,
					SEL_WIDTH         => log_width(MAX_NUM_FLAGS),
					NUM_OF_FUS        => 1,
					BRANCH_FLAG_INDEX => 1,
					NUM_OF_INPUTS     => MAX_NUM_FLAGS
				)
				port map(
					data_inputs(MAX_NUM_FLAGS - 1 downto 0) => functional_flags_out(i)(MAX_NUM_FLAGS - 1 downto 0),
					sel                                     => branch_flag_controls(i).SEL_FLAG,
					output(0)                               => fu_flag(i)
				);

		END GENERATE FU_FLAG_SELECT;

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
		--       SEL_CTRL_FLAG Multiplexer
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	


		CTRL_FLAG_SELECT : IF ALL_CTRL_FLAGS_WIDTH > 0 GENERATE
			ctrl_flag_select_mux : wppe_multiplexer
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME     => INSTANCE_NAME & "/ctrl_flags_mux_" & Int_to_string(i),
					-- cadence translate_on	
					INPUT_DATA_WIDTH  => 1,
					OUTPUT_DATA_WIDTH => 1,
					SEL_WIDTH         => ALL_CTRL_FLAGS_SEL_WIDTH,
                                        --SEL_WIDTH         => log_width(ALL_CTRL_FLAGS_WIDTH),
					NUM_OF_FUS        => 1,
					BRANCH_FLAG_INDEX => 1,
					NUM_OF_INPUTS     => ALL_CTRL_FLAGS_WIDTH
				)
				port map(
					--data_inputs => FU_flag_values.CTRL_flags((WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS+1-i) * ALL_CTRL_FLAGS_WIDTH - 1 downto (WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS-i)*ALL_CTRL_FLAGS_WIDTH),
					data_inputs => FU_flag_values.CTRL_flags(i*ALL_CTRL_FLAGS_WIDTH - 1 downto (i-1)*ALL_CTRL_FLAGS_WIDTH),
					sel         => branch_flag_controls(i).SEL_CTRL_FLAG(ALL_CTRL_FLAGS_SEL_WIDTH - 1 downto 0),
					output(0)   => ctrl_flag(i)
				);


		END GENERATE CTRL_FLAG_SELECT;

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
		--       FINAL FLAG SELECT Multiplexer
		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	


		FINAL_FLAG_SELECT : IF SUM_OF_FU > 0 GENERATE
			final_flag_select_mux : mux_2_1
				generic map(
					-- cadence translate_off	
					INSTANCE_NAME => INSTANCE_NAME & "/final_flag_mux_" & Int_to_string(i),
					-- cadence translate_on	
					DATA_WIDTH    => 1
				)
				port map(
					data_inputs => fu_ctrl_final_flag_array(i),
					sel         => ctrl_unit_selected(i),
					output(0)   => branch_flag_values(i)
				);

		END GENERATE FINAL_FLAG_SELECT;

	END GENERATE FLAG_CTRL_STRUCTURE;

end Behavioral;

