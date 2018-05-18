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
-- Create Date:    20:25:21 10/18/05
-- Design Name:    
-- Module Name:    branch_control - Behavioral
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
library wppa_instance_v1_01_a;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.ALL;
use wppa_instance_v1_01_a.DEFAULT_LIB.ALL;
use wppa_instance_v1_01_a.TYPE_LIB.ALL;
use wppa_instance_v1_01_a.ARRAY_LIB.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity branch_control is
	generic(
		-- cadence translate_off		  		
		INSTANCE_NAME        : string                                                                                                                    := "???";
		-- cadence translate_on	
		WPPE_GENERICS_RECORD : t_wppe_generics_record                                                                                                    := CUR_DEFAULT_WPPE_GENERICS_RECORD;
		BRANCH_INSTR_WIDTH   : positive range MIN_BRANCH_INSTR_WIDTH to MAX_BRANCH_INSTR_WIDTH                                                           := CUR_DEFAULT_BRANCH_INSTR_WIDTH;

		ADDR_WIDTH           : positive range MIN_ADDR_WIDTH to MAX_ADDR_WIDTH                                                                           := CUR_DEFAULT_ADDR_WIDTH;

		BRANCH_TARGET_WIDTH  : positive range MIN_BRANCH_TARGET_WIDTH to MAX_BRANCH_TARGET_WIDTH                                                         := CUR_DEFAULT_BRANCH_TARGET_WIDTH;

		-- 55 bit default branch instruction width <==> Opcode + 4 branch targets a 13 bits !!!
		BEGIN_OPCODE         : positive range MIN_BRANCH_INSTR_WIDTH - 1 to MAX_BRANCH_INSTR_WIDTH - 1                                                   := CUR_DEFAULT_BRANCH_OPCODE_BEGIN;
		END_OPCODE           : positive range MIN_BRANCH_INSTR_WIDTH - 1 - MAX_OPCODE_FIELD_WIDTH to MAX_BRANCH_INSTR_WIDTH - 1 - MAX_OPCODE_FIELD_WIDTH := CUR_DEFAULT_BRANCH_OPCODE_END;
		-- 3  bit Opcode width
		-- Number of flags which are evaluated by the branch unit
		-- This results in the total of 2**(NUM_OF_BRANCH_FLAGS) 
		-- branch targets.
		-- One of this branch targets is taken after the 
		-- evaluation of the flags
		NUM_OF_BRANCH_FLAGS  : integer range 0 to 8                                                                                                      := CUR_DEFAULT_BRANCH_FLAGS_NUM
	);

	port(
		clk, rst                    : in  std_logic;
		instruction_in              : in  std_logic_vector(BRANCH_INSTR_WIDTH - 1 downto 0);
		pc                          : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
		enable_tcpa                 : in  std_logic;
		branch_flag_controls_vector : out std_logic_vector(
			WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS * ( -- See the "TYPE_LIB.vhd" library for definition
				3 +                     -- SEL_FU_WIDTH 
				LOG_MAX_NUM_FU +        -- log(MAX_NUM_FU)
				LOG_MAX_NUM_FLAGS +     -- log(MAX_NUM_FLAGS)
				LOG_MAX_NUM_CTRL_SIG    -- log(MAX_NUM_CTRL_SIG) 
			) - 1 downto 0
		);
		--t_flag_controls(1 to NUM_OF_BRANCH_FLAGS);   -- See the "WPPE_LIB.vhd" library for definition
		branch_flag_values          : in  std_logic_vector(1 to NUM_OF_BRANCH_FLAGS)
	);

end branch_control;

architecture Behavioral of branch_control is
	signal branch_flag_controls : t_flag_controls(1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS);
        
	-- shravan : 20120319 : FLAG_SEL_WIDTH computation corrected
	--CONSTANT FLAG_SEL_WIDTH :integer := 
	--		BRANCH_INSTR_WIDTH - (
	--										(BEGIN_OPCODE - END_OPCODE + 1) + BRANCH_TARGET_WIDTH*(2**NUM_OF_BRANCH_FLAGS)
	--	 								) / NUM_OF_BRANCH_FLAGS;

	CONSTANT FLAG_SEL_WIDTH : integer := (BRANCH_INSTR_WIDTH - (
			                              (BEGIN_OPCODE - END_OPCODE + 1) + BRANCH_TARGET_WIDTH * (2 ** NUM_OF_BRANCH_FLAGS)
		                                  )) / NUM_OF_BRANCH_FLAGS;

	                                      CONSTANT FU_NUM_ARRAY : t_int_array(1 to 4) := (WPPE_GENERICS_RECORD.NUM_OF_ADD_FU,
		                                  WPPE_GENERICS_RECORD.NUM_OF_MUL_FU,
		                                  WPPE_GENERICS_RECORD.NUM_OF_LOGIC_FU,
		                                  WPPE_GENERICS_RECORD.NUM_OF_SHIFT_FU);
	                                      CONSTANT SEL_UNIT_WIDTH : integer := 3;
	                                      CONSTANT MAX_VALUE      : integer := max_value(FU_NUM_ARRAY);
	                                      CONSTANT SEL_NO_WIDTH   : integer := log_width(MAX_VALUE);
	                                      CONSTANT SEL_FLAG_WIDTH : integer := log_width(MAX_NUM_FLAGS);
	                                      CONSTANT SEL_CTRL_WIDTH : integer := log_width(
		                                  WPPE_GENERICS_RECORD.NUM_OF_CONTROL_REGS + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_INPUTS + WPPE_GENERICS_RECORD.NUM_OF_CONTROL_OUTPUTS);

	                                      -- shravan : 25-april-2012 : new constant BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH computed
	                                      CONSTANT BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH : integer range 0 to 1024 := 3 + LOG_MAX_NUM_FU + LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_CTRL_SIG;

	                                      -- shravan: 20120317: the following constant expressions can be simplified, but how are they different from above ones ? example: FLAG_SEL_FU_WIDTH = SEL_UNIT_WIDTH -1 ??
	                                      -- CONSTANT FLAG_SEL_FU_WIDTH :integer range 0 to 63 := (END_OPCODE -1) -
	                                      -- 																					 (END_OPCODE -1 - FLAG_SEL_WIDTH +
	                                      -- 																					 (FLAG_SEL_WIDTH - SEL_UNIT_WIDTH) +1);
	                                      CONSTANT FLAG_SEL_FU_WIDTH : integer range 0 to 63 := SEL_UNIT_WIDTH - 1;

	                                      -- CONSTANT FLAG_SEL_NO_WIDTH :integer range 0 to 63 :=	(END_OPCODE -1) - SEL_UNIT_WIDTH -																					
	                                      -- 																					 (END_OPCODE -1 -		
	                                      -- 																							FLAG_SEL_WIDTH +
	                                      -- 																					 (FLAG_SEL_WIDTH - SEL_UNIT_WIDTH
	                                      -- 																					 					  - SEL_NO_WIDTH) +1);

	                                      CONSTANT FLAG_SEL_NO_WIDTH : integer range 0 to 63 := SEL_NO_WIDTH - 1;

	                                      -- CONSTANT FLAG_SEL_FLAG_WIDTH :integer range 0 to 63 := (END_OPCODE -1) - SEL_UNIT_WIDTH - SEL_NO_WIDTH
	                                      -- 																						-	 
	                                      -- 																					 (END_OPCODE -1 -		
	                                      -- 																							FLAG_SEL_WIDTH +
	                                      -- 																					   (FLAG_SEL_WIDTH - SEL_UNIT_WIDTH
	                                      -- 																					                 - SEL_NO_WIDTH
	                                      -- 																										  - SEL_FLAG_WIDTH) +1);

	                                      CONSTANT FLAG_SEL_FLAG_WIDTH : integer range 0 to 63 := SEL_FLAG_WIDTH - 1;

	                                      -- CONSTANT FLAG_SEL_CTRL_WIDTH :integer range 0 to 63 := (END_OPCODE -1) - SEL_UNIT_WIDTH - SEL_NO_WIDTH - SEL_FLAG_WIDTH
	                                      -- 																					   - 
	                                      -- 																					 (END_OPCODE -1 -		
	                                      -- 																							FLAG_SEL_WIDTH +
	                                      -- 																					    (FLAG_SEL_WIDTH - SEL_UNIT_WIDTH
	                                      -- 																					                 - SEL_NO_WIDTH
	                                      -- 																										  - SEL_FLAG_WIDTH
	                                      -- 																										  - SEL_CTRL_WIDTH) +1);
	                                      CONSTANT FLAG_SEL_CTRL_WIDTH : integer range 0 to 63 := SEL_CTRL_WIDTH - 1;

	                                      -- LAYOUT of the BRANCH INSTRUCTION:
	                                      ------------------------------------------------------------------------------------------------------------------------------------------------
	                                      -- | OPCODE_WIDTH | SELECTS_FOR_BRANCH_FLAG_N | SELECTS_FOR_BRANCH_FLAG_N-1 | ... | SELECTS_FOR_BRANCH_FLAG_1 | BRANCH_TAR_N | ... | BRANCH_TAR_1 |
	                                      ------------------------------------------------------------------------------------------------------------------------------------------------
	                                      -- BITS:
	                                      ------------------------------------------------------------------------------------------------------------------------------------------------
	                                      -- | BRANCH_INSTR_WIDTH                                ............                                                                | x ... 2  1 0 |
	                                      ------------------------------------------------------------------------------------------------------------------------------------------------

	                                      -- LAYOUT of the SELECTS_FOR_BRANCH_FLAG_x -field:
	                                      --------------------------------------------------------------
	                                      -- | SELECT_UNIT | SELECT_NO |SELECT_FU_FLAG | SELECT_CTRL_FLAG |
	                                      --------------------------------------------------------------
	                                      -- SELECT UNIT     : 3 bits
	                                      -- SELECT Number   : log(MAX(Num. of different FU units))
	                                      -- SELECT FLAG     : log(MAX_NUM_FLAGS)
	                                      -- SELECT CTRL FLAG:	log(NUM_OF_CTRL_IN + NUM_OF_CTRL_OUT + NUM_OF_CTRL_GenPurpose)


	                                      function conditional_test(
		                                  ---------------------------------------------------------
		                                  -- Current number of flags to be tested
		                                  -- in the current run of the function
		                                  flags_number : in positive range 1 to 8;
		                                  ---------------------------------------------------------
		                                  -- Values of the flags to be tested  		 
		                                  flags_values : in std_logic_vector(NUM_OF_BRANCH_FLAGS - 1 downto 0);
		                                  ---------------------------------------------------------
		                                  -- Which branch target, from the (2^flags_number) 
		                                  -- possible/given, should be chosen,
		                                  -- if the branch condition is evaluated to true
		                                  current_target : in positive range 1 to 256;
		                                  ---------------------------------------------------------
		                                  -- The values of all branch targets were put
		                                  -- together to one big std_logic_vector with the
		                                  -- following layout: 
		                                  -- | target_x | target_x-1 | ... | target_2 | target_1 |
		                                  -- |              ...                          2  1  0 |
		                                  branch_targets : in std_logic_vector(BRANCH_TARGET_WIDTH * (2 ** NUM_OF_BRANCH_FLAGS) - 1 downto 0);
		                                  ---------------------------------------------------------
		                                  -- The width of each branch target
		                                  BRANCH_TARGET_WIDTH : in positive range 1 to 64
		                                  ---------------------------------------------------------
		                                  )
		                                  -- The right branch target is returned						
		                                  return std_logic_vector;

	                                      function conditional_test(
		                                  ---------------------------------------------------------
		                                  -- Current number of flags to be tested
		                                  -- in the current run of the function
		                                  flags_number : in positive range 1 to 8;
		                                  ---------------------------------------------------------
		                                  -- Values of the flags to be tested  		 
		                                  flags_values : in std_logic_vector(NUM_OF_BRANCH_FLAGS - 1 downto 0);
		                                  ---------------------------------------------------------									 
		                                  -- Which branch target, from the (2^flags_number) 
		                                  -- possible/given, should be chosen,
		                                  -- if the branch condition is evaluated to true
		                                  current_target : in positive range 1 to 256;
		                                  ---------------------------------------------------------
		                                  -- The values of all branch targets were put
		                                  -- together to one big std_logic_vector with the
		                                  -- following layout: 
		                                  -- | target_x | target_x-1 | ... | target_2 | target_1 |
		                                  -- |              ...                          2  1  0 |
		                                  branch_targets : in std_logic_vector(BRANCH_TARGET_WIDTH * (2 ** NUM_OF_BRANCH_FLAGS) - 1 downto 0);
		                                  ---------------------------------------------------------									 
		                                  -- The width of each branch target
		                                  BRANCH_TARGET_WIDTH : in positive range 1 to 64
		                                  ---------------------------------------------------------
		                                  )
		                                  -- The right branch target is returned						
		                                  return std_logic_vector is
		                                  variable target : std_logic_vector(BRANCH_TARGET_WIDTH - 1 downto 0);

	                                      begin
		                                  if flags_number = 1 then
			                              if flags_values(0) = '1' then
				                          target(BRANCH_TARGET_WIDTH - 1 downto 0) := branch_targets(BRANCH_TARGET_WIDTH * current_target - 1 downto BRANCH_TARGET_WIDTH * (current_target - 1));
			                              else
				                          target(BRANCH_TARGET_WIDTH - 1 downto 0) := branch_targets(BRANCH_TARGET_WIDTH * (current_target + 1) - 1 downto BRANCH_TARGET_WIDTH * current_target);
			                              end if;

		                                  else
			                              if (flags_values(flags_number - 1) = '0') then
				                          target(BRANCH_TARGET_WIDTH - 1 downto 0) := conditional_test(flags_number - 1,
						                  flags_values,
						                  current_target,
						                  branch_targets,
						                  BRANCH_TARGET_WIDTH
					                      );

			                              else
				                          target(BRANCH_TARGET_WIDTH - 1 downto 0) := conditional_test(flags_number - 1,
						                  flags_values,
						                  current_target - 2 ** (flags_number - 1),
						                  branch_targets,
						                  BRANCH_TARGET_WIDTH
					                      );

			                              end if;

		                                  end if;

		                                  return target;

	                                      end conditional_test;

	                                      --==========================================================================

	                                      signal new_pc                 : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	                                      signal branch_targets         : std_logic_vector(BRANCH_TARGET_WIDTH * (2 ** NUM_OF_BRANCH_FLAGS) - 1 downto 0);
	                                      signal registered_instruction : std_logic_vector(BRANCH_INSTR_WIDTH - 1 downto 0);
	                                      signal branch_pc              : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	                                      signal next_pc                : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	                                      signal registered_pc          : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	                                      signal opcode                 : std_logic_vector(2 downto 0);
	                                      signal flags                  : std_logic_vector(NUM_OF_BRANCH_FLAGS - 1 downto 0);

begin

	                                      --==============================================================================================
	                                      --  =====================  CONVERSION   OF  RECORD_TYPES  TO  STD_LOGIC_VECTOR =================
	                                      --==============================================================================================
	                                      CONVERT_T_FLAGS_TYPE : FOR i in 1 to WPPE_GENERICS_RECORD.NUM_OF_BRANCH_FLAGS GENERATE

		                                  -------------------------------------------------------------------------------
		                                  -- shravan : 25-april-2012 : Multiple Branch Flags Fix : In the buggy code
		                                  -- branch_flag_controls_vector are over-written with branch_flag_controls of different
		                                  -- flags to the same location, ideally they should be concatenated (not over-written)


		                                  --		branch_flag_controls_vector(2 downto 0) <= branch_flag_controls(i).SEL_FU;
		                                  --		
		                                  --		branch_flag_controls_vector(LOG_MAX_NUM_FU -1 +3 downto 3) <= branch_flag_controls(i).SEL_FU_NO;
		                                  --		
		                                  --		branch_flag_controls_vector(LOG_MAX_NUM_FLAGS -1 + LOG_MAX_NUM_FU + 3 
		                                  --											downto LOG_MAX_NUM_FU +3) 
		                                  --				<= branch_flag_controls(i).SEL_FLAG;
		                                  --
		                                  --		branch_flag_controls_vector(LOG_MAX_NUM_CTRL_SIG -1 +
		                                  --		  								    LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_FU + 3 
		                                  --																downto  LOG_MAX_NUM_FLAGS + 
		                                  --																		LOG_MAX_NUM_FU + 3
		                                  --																)
		                                  --				<= branch_flag_controls(i).SEL_CTRL_FLAG;


		                                  --        shift := (i-1)*BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH; 
		                                  branch_flag_controls_vector(2 + (i - 1) * BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH downto 0 + (i - 1) * BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH) <= branch_flag_controls(i).SEL_FU;

		                                  branch_flag_controls_vector(LOG_MAX_NUM_FU - 1 + 3 + (i - 1) * BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH downto 3 + (i - 1) * BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH) <= branch_flag_controls(i).SEL_FU_NO;

		                                  branch_flag_controls_vector(LOG_MAX_NUM_FLAGS - 1 + LOG_MAX_NUM_FU + 3 + (i - 1) * BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH downto LOG_MAX_NUM_FU + 3 + (i - 1) * BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH) <= branch_flag_controls(i).SEL_FLAG;

		                                  branch_flag_controls_vector(LOG_MAX_NUM_CTRL_SIG - 1 + LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_FU + 3 + (i - 1) * BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH downto LOG_MAX_NUM_FLAGS + LOG_MAX_NUM_FU + 3 + (i - 1) * BRANCH_FLAG_CONTROL_VECTOR_INDIVIDUAL_FLAG_WIDTH
		                                  ) <= branch_flag_controls(i).SEL_CTRL_FLAG;
	                                      -------------------------------------------------------------------------------

	                                      END GENERATE CONVERT_T_FLAGS_TYPE;
	                                      --==============================================================================================
	                                      --  =====================  CONVERSION   OF  RECORD_TYPES  TO  STD_LOGIC_VECTOR =================
	                                      --==============================================================================================   


	                                      FLAG_TO_DOWNTO_CONVERSION : FOR i in 1 to NUM_OF_BRANCH_FLAGS GENERATE
		                                  flags(i - 1) <= branch_flag_values(i);

	                                      END GENERATE FLAG_TO_DOWNTO_CONVERSION;

	                                      -- !!! SET THE BRANCH TARGET ALWAYS TO THE 2 ADDRESS !!! --
	                                      --branch_pc <= registered_instruction(BRANCH_TARGET_WIDTH -1 downto 0);


	                                      branch_pc <= conditional_test( ---------------------------------------------------------
			                              -- Current number of flags to be tested
			                              -- in the current run of the function
			                              -- flags_number   :in positive range 1 to 8;
			                              NUM_OF_BRANCH_FLAGS,
			                              ---------------------------------------------------------
			                              -- Values of the flags to be tested  		 
			                              --flags_values   :in 
			                              --		std_logic_vector(NUM_OF_BRANCH_FLAGS -1 downto 0);
			                              flags(NUM_OF_BRANCH_FLAGS - 1 downto 0),
			                              ---------------------------------------------------------
			                              -- Which branch target, from the (2^flags_number) 
			                              -- possible/given, should be chosen,
			                              -- if the branch condition is evaluated to true
			                              --current_target :in positive range 1 to 256;
			                              (2 ** NUM_OF_BRANCH_FLAGS) - 1,
			                              ---------------------------------------------------------
			                              -- The values of all branch targets were put
			                              -- together to one big std_logic_vector with the
			                              -- following layout: 
			                              -- | target_x | target_x-1 | ... | target_2 | target_1 |
			                              -- |              ...                          2  1  0 |
			                              -- branch_targets :in 
			                              -- std_logic_vector(BRANCH_TARGET_WIDTH*NUM_OF_BRANCH_FLAGS -1 downto 0);
			                              branch_targets,
			                              ---------------------------------------------------------
			                              -- The width of each branch target
			                              --BRANCH_TARGET_WIDTH 	 :in positive range 1 to 64
			                              BRANCH_TARGET_WIDTH
		                                  );

	                                      register_insruction : process(clk, rst, instruction_in)
	                                      begin
		                                  if clk'event and clk = '1' then
			                              if rst = '1' then
				                          opcode                 <= instruction_in(BEGIN_OPCODE downto END_OPCODE);
				                          registered_instruction <= instruction_in;

			                              else
				                          opcode                 <= instruction_in(BEGIN_OPCODE downto END_OPCODE);
				                          registered_instruction <= instruction_in;

			                              end if;

		                                  end if;

	                                      end process;

	                                      -- Assembler semantics:
	                                      --   IF N(ADD0) JMP cycle6, cycle5

	                                      --      if negative ADD0 = true  jump cycle 6
	                                      --   	  if negative ADD0 = false jump cycle 5

	                                      --   Corresponding branch instruction (target width = 4 bit, branch_select = 9 bit, branch_flags_nr = 1)
	                                      --   000 000001000 0110 0101 (len=20)
	                                      --   BRA N(ADD0)   6    5

	                                      REVERSE_BRANCH_TARGETS : FOR i in 1 to 2 ** NUM_OF_BRANCH_FLAGS GENERATE
		                                  branch_targets(BRANCH_TARGET_WIDTH * i - 1 downto BRANCH_TARGET_WIDTH * (i - 1)) <= instruction_in(BRANCH_TARGET_WIDTH * (2 ** NUM_OF_BRANCH_FLAGS - i + 1) - 1 downto BRANCH_TARGET_WIDTH * (2 ** NUM_OF_BRANCH_FLAGS - i)
			                              );

	                                      END GENERATE REVERSE_BRANCH_TARGETS;

	                                      --================================================================================
	                                      --================================================================================


	                                      BRANCH_FLAGS_COND : IF NUM_OF_BRANCH_FLAGS > 0 GENERATE
		                                  BRANCH_FIELDS_DECODE : FOR i in 1 to NUM_OF_BRANCH_FLAGS GENERATE
		                                  begin

			                              --branch_flag_controls(i).SEL_FU(2 downto FLAG_SEL_FU_WIDTH +1)  <= (others => '0');

			                              branch_flag_controls(i).SEL_FU(FLAG_SEL_FU_WIDTH downto 0) <= instruction_in(
					                      END_OPCODE - 1 - FLAG_SEL_WIDTH * (i - 1) downto END_OPCODE - 1 - FLAG_SEL_WIDTH * i + (FLAG_SEL_WIDTH - SEL_UNIT_WIDTH) + 1
				                          );

			                              branch_flag_controls(i).SEL_FU_NO(LOG_MAX_NUM_FU - 1 downto FLAG_SEL_NO_WIDTH + 1) <= (others             => '0');
			                              branch_flag_controls(i).SEL_FU_NO(FLAG_SEL_NO_WIDTH downto 0)                      <= instruction_in(
					                      END_OPCODE - 1 - FLAG_SEL_WIDTH * (i - 1) - SEL_UNIT_WIDTH downto END_OPCODE - 1 - FLAG_SEL_WIDTH * i + (FLAG_SEL_WIDTH - SEL_UNIT_WIDTH - SEL_NO_WIDTH) + 1
				                          );

			                              --branch_flag_controls(i).SEL_FLAG(LOG_MAX_NUM_FLAGS-1 downto  FLAG_SEL_FLAG_WIDTH +1) <= (others => '0');
			                              branch_flag_controls(i).SEL_FLAG(FLAG_SEL_FLAG_WIDTH downto 0) <= instruction_in(
					                      END_OPCODE - 1 - FLAG_SEL_WIDTH * (i - 1) - SEL_UNIT_WIDTH - SEL_NO_WIDTH downto END_OPCODE - 1 - FLAG_SEL_WIDTH * i + (FLAG_SEL_WIDTH - SEL_UNIT_WIDTH - SEL_NO_WIDTH - SEL_FLAG_WIDTH) + 1
				                          );

			                              branch_flag_controls(i).SEL_CTRL_FLAG(LOG_MAX_NUM_CTRL_SIG - 1 downto FLAG_SEL_CTRL_WIDTH + 1) <= (others => '0');
			                              branch_flag_controls(i).SEL_CTRL_FLAG(FLAG_SEL_CTRL_WIDTH downto 0)                            <= instruction_in(
					                      END_OPCODE - 1 - FLAG_SEL_WIDTH * (i - 1) - SEL_UNIT_WIDTH - SEL_NO_WIDTH - SEL_FLAG_WIDTH downto END_OPCODE - 1 - FLAG_SEL_WIDTH * i + (FLAG_SEL_WIDTH - SEL_UNIT_WIDTH - SEL_NO_WIDTH - SEL_FLAG_WIDTH - SEL_CTRL_WIDTH) + 1
				                          );

		                                  END GENERATE BRANCH_FIELDS_DECODE;

	                                      END GENERATE;

	                                      --================================================================================
	                                      --================================================================================
	                                      -- Fill up with the SAME branch address

	                                      --fill_hilfs_branches :FOR i IN 1 to 2**NUM_OF_BRANCH_FLAGS -1 GENERATE
	                                      --
	                                      --	hilfs_branch_targets(BRANCH_TARGET_WIDTH*i -1 downto BRANCH_TARGET_WIDTH*(i-1)) 
	                                      --			<= registered_instruction(ADDR_WIDTh -1 downto 0);
	                                      --
	                                      --END GENERATE;

	                                      --================================================================================
	                                      --================================================================================

	                                      decode_instruction : process(clk, rst) --clk, rst, registered_instruction, flags, new_pc, branch_targets)

	                                      --variable opcode         :std_logic_vector(2 downto 0); -- :integer range 0 to 16; --   
	                                      --variable branch_targets :std_logic_vector(0 to BRANCH_TARGET_WIDTH*(2**NUM_OF_BRANCH_FLAGS) -1);

	                                      begin

	                                      --------------------
	                                      -- Layout of flags:
	                                      --------------------

	                                      --================================================================================
	                                      -- 	flags(0) => ZERO FLAG: 
	                                      --						result of the subtraction by the first adder FU was equal to 0
	                                      --================================================================================
	                                      -- 	flags(1) => OVERFLOW FLAG:
	                                      --						the operands result of the addition by the first adder FU was 
	                                      --================================================================================
	                                      -- 	flags(2) => NEGATIVE FLAG:
	                                      --						result of the subtraction by the first adder FU was negative
	                                      --================================================================================
	                                      -- 	flags(3) => CARRY FLAG:
	                                      --						result of the addition by the first adder FU was too big
	                                      --================================================================================


	                                      end process decode_instruction;

	                                      next_pc <= registered_pc when rst = '1' else registered_pc + 1 when enable_tcpa = '1';

	                                      pc <= (others => '0') when rst = '1' else branch_pc when instruction_in(BEGIN_OPCODE downto END_OPCODE) = "000" and enable_tcpa = '1' else next_pc;

	                                      --registered_pc <= (others => '0') when rst = '1' else
	                                      --	branch_pc when instruction_in(BEGIN_OPCODE downto END_OPCODE) = "000" else
	                                      --	next_pc;

	                                      mapping : process(clk, rst, branch_pc, next_pc)
	                                      begin
		                                  if rst = '1' then
			                              --	pc <= (others => '0');
			                              registered_pc <= (others => '0');

		                                  elsif clk'event and clk = '1' then
			                              if (enable_tcpa = '1') then --if '1' the TCPA proceeds with the computation, by increamenting the instruction memory addresses
				                          if instruction_in(BEGIN_OPCODE downto END_OPCODE) = "000" then
					                      --			pc <= branch_pc;
					                      registered_pc <= branch_pc;

				                          else
					                      --			pc <= next_pc;
					                      registered_pc <= next_pc;
				                          end if;
			                              else --(enable_tcpa = '0')
				                          --registered_pc <= registered_pc;
				                          registered_pc <= (others=>'0');
			                              end if;
		                                  end if;

	                                      end process mapping;
end Behavioral;

