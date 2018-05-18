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

----------------------------------------------------------------------------------
-- Company:        Hardware/Software Co-design (LS12) at FAU Erlangen-Nuernberg
-- Engineer:       Ericles Sousa
-- 
-- Create Date:    17:56:04 08/27/2014 
-- Design Name: 
-- Module Name:    TCPA_TOP - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:    Top file for integrating all components of a TCPA architecture
-- 
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- This file also contains the contribution of the following Engineers:
-- Srinivas Boppu and Jupiter Bakakeu
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--library IEEE, synplify;
use IEEE.std_logic_1164.all;
--use synplify.attributes.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library techmap;
use techmap.gencomp.all;

library tcpa_lib;
use tcpa_lib.AG_BUFFER_type_lib.all;

library wppa_instance_v1_01_a;
use wppa_instance_v1_01_a.ALL;

use wppa_instance_v1_01_a.WPPE_LIB.all;
use wppa_instance_v1_01_a.DEFAULT_LIB.all;
use wppa_instance_v1_01_a.ARRAY_LIB.all;
use wppa_instance_v1_01_a.TYPE_LIB.all;
use wppa_instance_v1_01_a.INVASIC_LIB.all;

package tcpa_top_lib is 
  component TCPA_TOP is
    generic(
      --###########################################################################
      -- TCPA_TOP parameters, do not add to or delete
      --###########################################################################
      NUM_OF_BUFFER_STRUCTURES              : positive range 1 to 4 := CUR_DEFAULT_NUM_OF_BUFFER_STRUCTURES;
      BUFFER_SIZE                           : integer               := CUR_DEFAULT_MAX_BUFFER_SIZE;
      BUFFER_SIZE_ADDR_WIDTH                : integer               := CUR_DEFAULT_BUFFER_ADDR_WIDTH;
      BUFFER_CHANNEL_SIZE                   : integer               := CUR_DEFAULT_BUFFER_CHANNEL_SIZE;
      BUFFER_CHANNEL_ADDR_WIDTH             : integer               := CUR_DEFAULT_BUFFER_CHANNEL_ADDR_WIDTH;
      BUFFER_CHANNEL_SIZES_ARE_POWER_OF_TWO : boolean               := CUR_DEFAULT_CHANNEL_SIZES_ARE_POWER_OF_TWO;
      EN_ELASTIC_BUFFER                     : boolean               := CUR_DEFAULT_EN_ELASTIC_BUFFER;
      AG_BUFFER_CONFIG_SIZE                 : integer               := CUR_DEFAULT_AG_BUFFER_CONFIG_SIZE;
      AG_BUFFER_NORTH                       : t_ag_buffer_generics  := CUR_DEFAULT_AG_BUFFER_NORTH;
      AG_BUFFER_WEST                        : t_ag_buffer_generics  := CUR_DEFAULT_AG_BUFFER_WEST;
      AG_BUFFER_SOUTH                       : t_ag_buffer_generics  := CUR_DEFAULT_AG_BUFFER_SOUTH;
      AG_BUFFER_EAST                        : t_ag_buffer_generics  := CUR_DEFAULT_AG_BUFFER_EAST;

      RBUFFER_HIRQ_AHB_INDEX                : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_INDEX;
      RBUFFER_HIRQ_AHB_ADDR                 : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_ADDR;
      RBUFFER_HIRQ_AHB_MASK                 : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_MASK;
      RBUFFER_HIRQ_AHB_IRQ                  : integer               := CUR_DEFAULT_RBUFFER_HIRQ_AHB_IRQ;

      INDEX_VECTOR_DIMENSION                : integer range 0 to 32 := 3;
      INDEX_VECTOR_DATA_WIDTH               : integer range 0 to 32 := 17;-- 9;
      MATRIX_PIPELINE_DEPTH                 : integer range 0 to 32 := 2; -- equals log2(INDEX_VECTOR_DIMENSION) + 1
   
      --#######################################################################
      GC_pindex                             : integer;
      GC_paddr                              : integer               := 16#801#;
      GC_pmask                              : integer               := 16#FFC#;
      GC_pirq                               : integer;

      ----------------------------------------------------------------------------
      -- CM
      ----------------------------------------------------------------------------
      CM_pindex                             : integer;
      CM_paddr                              : integer               := 16#820#;
      CM_pmask                              : integer               := 16#FF0#;

      RR_pindex                            : integer;
      RR_paddr                             : integer                := 16#810#;
      RR_pmask                             : integer                := 16#FF0#;

      FI_pindex                            : integer                := 15;
      FI_pirq                              : integer;
      FI_paddr                             : integer                := 16#8A0#;
      FI_pmask                             : integer                := 16#FFC#;
      
      --#######################################################################		
      ITERATION_VARIABLE_WIDTH              : integer               := 16;--default value. This constant value is defined in the file GLOBAL_CONTROLLER/minmax_comparator_matrix.v 
      DIMENSION                             : integer               := 3; --default value
      SELECT_WIDTH                          : integer               := 3; --default value
      NO_REG_TO_PROGRAM                     : integer               := 4; --default value
      MATRIX_ELEMENT_WIDTH                  : integer               := 8; --default value
      DATA_WIDTH                            : integer               := 8; --default value
      MAX_NO_OF_PROGRAM_BLOCKS              : integer               := 35;--default value
      NUM_OF_IC_SIGNALS                     : integer               := 3  --default value		
    );
    port(
      dclk_in            : in  std_logic;

      -- TCPA Signals
      TCPA_clk           : in  std_logic;

      ahb_clk_in         : in  std_logic;
      ahb_rstn_in        : in  std_logic;

      -- AG AHB
      ahbsi_in           : in  ahb_slv_in_type;
      ahbso_out_NORTH    : out ahb_slv_out_type;
      ahbso_out_SOUTH    : out ahb_slv_out_type;
      ahbso_out_EAST     : out ahb_slv_out_type;
      ahbso_out_WEST     : out ahb_slv_out_type;
      RBuffer_hirq_out   : out ahb_slv_out_type;
      
      reconfig_regs_apbo : out apb_slv_out_type;
      CM_apbo            : out apb_slv_out_type;
      FI_apbo            : out apb_slv_out_type;
      -- GC Conf Memory APB
      apbi_in            : in  apb_slv_in_type;
      GC_apbo_out        : out apb_slv_out_type
    );
  end component TCPA_TOP;

end tcpa_top_lib;




