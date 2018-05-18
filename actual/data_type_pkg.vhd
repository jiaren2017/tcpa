library ieee;
use ieee.std_logic_1164.all;

package data_type_pkg is
 
    -- data from amba_interface to component
    type rec_IF_COMP is record
        hsel        : std_ulogic;
        hready      : std_ulogic;
        haddr       : std_logic_vector(31 downto 0);
        hwrite      : std_ulogic;
        htrans      : std_logic_vector(1 downto 0);
        hwdata      : std_logic_vector(31 downto 0); 
    end record rec_IF_COMP;  
 
    -- data from amba_interface to component
    type rec_COMP_IF is record
        hrdata      : std_logic_vector(31 downto 0);
        hready      : std_ulogic;                       -- inform bus:  write OK!       
        hresp       : std_logic_vector(1 downto 0);
        hirq        : std_ulogic;
        hsplit      : std_logic_vector(15 downto 0);
        hindex      : integer;
    end record rec_COMP_IF;
 
    type arr_IF_COMP is array (natural range <>) of rec_IF_COMP;     -- here the bus and component has the same data format
    type arr_COMP_IF is array (natural range <>) of rec_COMP_IF;
    
    

   
end data_type_pkg;