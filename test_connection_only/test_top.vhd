library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.misc.all;

use work.data_type_pkg.all;

entity test_top is
	generic(
        hindex : integer := 7;                  -- component index for amba-bus
        haddr  : integer := 16#300#;            -- amba-bus-component address
        hmask  : integer := 16#FC0#;            -- compnent size for amba-bus
        hirq   : integer := 0;
        COMP_NUM_POWER  : integer := 4;         -- 2^4 == 16 components
        COMP_SIZE       : integer := 22;        -- 2^22 == 4 MByte
        COMPONENT_A_ID  : integer := 0;         -- component inside test_top
        COMPONENT_B_ID  : integer := 1  
        );
    port(

        ahb_clk         : in  std_ulogic;
        ahb_rstn        : in  std_ulogic;
        
        -- data between top and amba_interface
        ahbsi           : in  ahb_slv_in_type;
        ahbso           : out ahb_slv_out_type
        );
end entity test_top;


architecture behavior of test_top is

    signal  SUM_COMPONENT : integer := 2**COMP_NUM_POWER;
    signal  IF_COMP_data  : arr_IF_COMP(0 to SUM_COMPONENT-1);    -- array of records
    signal  COMP_IF_data  : arr_COMP_IF(0 to SUM_COMPONENT-1);
    signal  COMP_A_IF_out : rec_COMP_IF;
    signal  COMP_B_IF_out : rec_COMP_IF;
    

---------------------------------------------  component declaration
    component amba_interface is
        generic( 
            hindex : integer := 7;                  -- component index for amba-bus
            haddr  : integer := 16#300#;            -- amba-bus-component address
            hmask  : integer := 16#FC0#;            -- compnent size for amba-bus
            hirq   : integer := 0;
            SUM_COMPONENT   : integer;
            COMP_NUM_POWER  : integer := 4;         -- 2^4 == 16 components
            COMP_SIZE       : integer := 22        -- 2^22 == 4 MByte
            );
        port(
            -- CLK: in std_logic;
            -- RST: in std_logic;

            -- data between top and amba_interface
            ahbsi           : in  ahb_slv_in_type;
            ahbso           : out ahb_slv_out_type;
                        
            -- data between amba_interface and component
            IF_COMP_data: out arr_IF_COMP(0 to SUM_COMPONENT-1);    -- array of records
            COMP_IF_data: in  arr_COMP_IF(0 to SUM_COMPONENT-1)
            );	
    end component;


    component single_comp is
        generic( 
            COMPONENT_INDEX: integer;
            SUM_COMPONENT: integer
        );
        port(
            CLK: in std_logic;
            RST: in std_logic;
            IF_COMP_data: in  arr_IF_COMP(0 to SUM_COMPONENT-1);
            COMP_IF_out : out rec_COMP_IF
        ;	
    end component;


begin


---------------------------------------------  component initiation

    interface_i : amba_interface
    generic map(
            hindex => hindex,    -- component index for amba-bus
            haddr  => haddr,    -- amba-bus-component address
            hmask  => hmask, 
            hirq   => hirq,
            SUM_COMPONENT   => SUM_COMPONENT,
            COMP_NUM_POWER  => COMP_NUM_POWER,
            COMP_SIZE       => COMP_SIZE)
    port map(
        -- Input Signals from Bus system to component
        -- clk             => ahb_clk,
        -- RST             => ahb_rstn,
        
        -- data between top and amba_interface
        ahbsi           => ahbsi,        
        ahbso           => ahbso,
        
        -- data between amba_interface and component
        IF_COMP_data    => IF_COMP_data,
        COMP_IF_data    => COMP_IF_data);


        
        
    single_comp_1 : single_comp
    generic map(
        COMPONENT_INDEX => COMPONENT_A_ID,
        SUM_COMPONENT   => SUM_COMPONENT)
    port map(
        -- Input Signals from Bus system to component
        clk             => ahb_clk,
        RST             => ahb_rstn,
        -- Signals from AMBA Interface to component
        IF_COMP_data    => IF_COMP_data,
        -- Signals from component to AMBA Interface
        COMP_IF_out     => COMP_A_IF_out);
        
        
    single_comp_2 : single_comp
    generic map(
        COMPONENT_INDEX => COMPONENT_B_ID,
        SUM_COMPONENT   => SUM_COMPONENT)
    port map(
        -- Input Signals from Bus system to component
        clk             => ahb_clk,
        RST             => ahb_rstn,
        -- Signals from AMBA Interface to component
        IF_COMP_data    => IF_COMP_data,
        -- Signals from component to AMBA Interface
        COMP_IF_out     => COMP_B_IF_out);
        
        
        
    assignment : process(COMP_A_IF_out, COMP_B_IF_out)
    begin
        IF_COMP_data(COMPONENT_A_ID) <= COMP_A_IF_out;
        IF_COMP_data(COMPONENT_B_ID) <= COMP_B_IF_out;
    end;
        
        
        
        
        
        
        
        
        
end behavior; 