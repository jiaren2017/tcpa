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

entity amba_interface is
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

            -- data between top and amba_interface
            ahbsi           : in  ahb_slv_in_type;
            ahbso           : out ahb_slv_out_type;
            
            -- data between amba_interface and component
            IF_COMP_data    : out arr_IF_COMP(0 to SUM_COMPONENT-1);    -- array of records
            COMP_IF_data    : in  arr_COMP_IF(0 to SUM_COMPONENT-1)
            -- RB_IF_data      : in rec_COMP_IF    -- RBuffer_hirq
            -- GC_IF_data      : in rec_COMP_IF;   --gc_apb_slave_mem_wrapper_addr
            -- FI_IF_data      : in rec_COMP_IF;   -- faule invasion
            -- RR_IF_data      : in rec_COMP_IF;   -- reconfig_registers
            -- HW_IF_data      : in rec_COMP_IF;   -- top_hardware_interface
            -- AG_EAST_IF_data : in rec_COMP_IF;   -- AG_Buffer_Wrapper_EAST
            -- AG_WEST_IF_data : in rec_COMP_IF;   -- AG_Buffer_Wrapper_WEST
            -- AG_SOUTH_IF_data : in rec_COMP_IF;  -- AG_Buffer_Wrapper_SOUTH
            -- AG_NORTH_IF_data : in rec_COMP_IF;  -- AG_Buffer_Wrapper_NORTH
            
            -- AG_IF_ahbso_EAST_valid           :  in std_ulogic;
            -- AG_IF_ahbso_WEST_valid           :  in std_ulogic;  
            -- AG_IF_ahbso_SOUTH_valid          :  in std_ulogic;
            -- AG_IF_ahbso_NORTH_valid          :  in std_ulogic;
            -- faultTOP_IF_apbo_valid           :  in std_ulogic
            
            );	
end entity amba_interface;

architecture behavior of amba_interface is

    signal mask_intern : std_logic_vector(31 downto 0) := to_stdlogicvector(to_bitvector((x"FFFFFFFF")) srl (32-COMP_NUM_POWER-COMP_SIZE));        -- 0x03FFFFFF for 16 component with 4MB size(each)
    signal addr_mask : std_logic_vector(31 downto 0);
    signal addr_srl : std_logic_vector(31 downto 0);
    signal addr_array_index: integer range 0 to 2**COMP_NUM_POWER;
    
	constant AMBA_IF_CONFIG : ahb_config_type := (
		0      => ahb_device_reg(VENDOR_CONTRIB, CONTRIB_CORE1, 0, 0, 0),
		4      => ahb_membar(haddr, '0', '0', hmask),
		others => zero32);

begin

-----------------------------------------------------  calculate the index of interest
    addr_mask  <= ahbsi.haddr and mask_intern;
    addr_srl   <= to_stdlogicvector(to_bitvector(addr_mask) srl COMP_SIZE);
    addr_array_index <= to_integer(unsigned(addr_srl));  

    
--------------------------------------------------  configure the output signals to component  
    Output_to_COMP: process (addr_array_index, ahbsi)      
    begin
        for i  in 0 to SUM_COMPONENT-1 loop
            IF_COMP_data(i).hsel     <= '0';
            IF_COMP_data(i).hready   <= '0';
            IF_COMP_data(i).haddr    <= (others=>'0');
            IF_COMP_data(i).hwrite   <= '0';
            IF_COMP_data(i).htrans   <= (others=>'0');
            IF_COMP_data(i).hwdata   <= (others=>'0');
        end loop;
    
        if ahbsi.hsel(hindex) = '1' then                        -- check whether the input is for tcpa component
            IF_COMP_data(addr_array_index).hsel     <= '1';
            IF_COMP_data(addr_array_index).hready   <= ahbsi.hready;
            IF_COMP_data(addr_array_index).haddr    <= ahbsi.haddr;
            IF_COMP_data(addr_array_index).hwrite   <= ahbsi.hwrite;
            IF_COMP_data(addr_array_index).htrans   <= ahbsi.htrans;
            IF_COMP_data(addr_array_index).hwdata   <= ahbsi.hwdata;
        end if;
    end process;
    
    
-----------------------------------------------  configure the output signals to top  
    Output_to_TOP: process (ahbsi, addr_array_index, COMP_IF_data)      
    begin	
    
        --  default assignment
        ahbso.hrdata         <= (others => '0');
        ahbso.hready         <= '0';       	            -- inform bus:  write OK!
        ahbso.hresp          <= (others => '0');        -- status
        ahbso.hirq           <= '0';
        ahbso.hsplit         <= (others => '0');
        ahbso.hindex         <= 0;
        ahbso.hconfig        <= AMBA_IF_CONFIG;
        ahbso.hindex         <= hindex; 
        
        
        --if ahbsi.hsel(hindex) = '1' then                        -- check whether the input is for tcpa component
        ---------- Write data
        if ahbsi.hwrite = '1' then							
            if addr_array_index = COMP_IF_data(addr_array_index).hindex then   -- check whether the index are correct
                ahbso.hrdata         <= (others => '0');
                ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                ahbso.hirq           <= (others => '0');
                ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
            end if;

        ---------- Read data
        else			                       
            if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check whether the index are correct
                ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                ahbso.hready         <= COMP_IF_data(addr_array_index).hready;      -- inform bus:  write OK!
                ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;       -- status
                ahbso.hirq           <= (others => '0');
                ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
            end if;
        end if;
        --end if;
        
        
        
        
        
        
        
        
        
        
        
        -- ---------- Write data
        -- if ahbsi.hwrite = '1' then		
            -- if addr_array_index = RBuffer_hirq_addr then  ---------------------        Component: RBuffer_hirq     
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then        -- check whether the index are correct
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = AG_Buffer_NORTH_ID and AG_IF_ahbso_NORTH_valid = '1' then ---------------------   Component: AHB_AG_Buffer_Wrapper_NORTH
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then                -- check ID
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
    
            -- elsif addr_array_index = AG_Buffer_SOUTH_ID and AG_IF_ahbso_SOUTH_valid = '1' then ---------------------   Component: AHB_AG_Buffer_Wrapper_SOUTH
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then                -- check ID
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = AG_Buffer_WEST_ID and AG_IF_ahbso_WEST_valid = '1' then ---------------------   Component: AHB_AG_Buffer_Wrapper_WEST
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then                -- check ID
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = AG_Buffer_EAST_ID and AG_IF_ahbso_EAST_valid = '1' then ---------------------   Component: AHB_AG_Buffer_Wrapper_EAST
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then                -- check ID
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = top_hardware_interface_addr then           --------------------- Component: top_hardware_interface       
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check ID
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
    
            -- elsif addr_array_index = reconfig_registers_ID then ---------------------     Component: reconfig_registers     
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check ID
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = gc_apb_slave_mem_wrapper_ID then ---------------------     Component: gc_apb_slave_mem_wrapper
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check ID
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = fault_injection_top_ID and faultTOP_IF_apbo_valid = '1' then ---------------------     Component: gc_apb_slave_mem_wrapper
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check ID
                    -- ahbso.hrdata         <= (others => '0');
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= COMP_IF_data(addr_array_index).hirq;
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
                
        -- ---------- Read data
        -- else			            

            -- if addr_array_index = RBuffer_hirq_addr then  ---------------------        Component: RBuffer_hirq     
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then        -- check whether the index are correct
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = AG_Buffer_NORTH_ID and AG_IF_ahbso_NORTH_valid = '1' then ---------------------   Component: AHB_AG_Buffer_Wrapper_NORTH
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then                -- check ID
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
    
            -- elsif addr_array_index = AG_Buffer_SOUTH_ID and AG_IF_ahbso_SOUTH_valid = '1' then ---------------------   Component: AHB_AG_Buffer_Wrapper_SOUTH
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then                -- check ID
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = AG_Buffer_WEST_ID and AG_IF_ahbso_WEST_valid = '1' then ---------------------   Component: AHB_AG_Buffer_Wrapper_WEST
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then                -- check ID
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = AG_Buffer_EAST_ID and AG_IF_ahbso_EAST_valid = '1' then ---------------------   Component: AHB_AG_Buffer_Wrapper_EAST
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then                -- check ID
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = top_hardware_interface_addr then           --------------------- Component: top_hardware_interface       
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check ID
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
    
            -- elsif addr_array_index = reconfig_registers_ID then ---------------------     Component: reconfig_registers     
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check ID
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = gc_apb_slave_mem_wrapper_ID then ---------------------     Component: gc_apb_slave_mem_wrapper
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check ID
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
                
            -- elsif addr_array_index = fault_injection_top_ID and faultTOP_IF_apbo_valid = '1' then ---------------------     Component: gc_apb_slave_mem_wrapper
                -- if addr_array_index = COMP_IF_data(addr_array_index).hindex then      -- check ID
                    -- ahbso.hrdata         <= COMP_IF_data(addr_array_index).hrdata;
                    -- ahbso.hready         <= COMP_IF_data(addr_array_index).hready;       	-- inform bus:  write OK!
                    -- ahbso.hresp          <= COMP_IF_data(addr_array_index).hresp;          -- status
                    -- ahbso.hirq           <= (others => '0');
                    -- ahbso.hsplit         <= COMP_IF_data(addr_array_index).hsplit;
                -- end if;
            -- end if;
        -- end if;
    end process;

        
end behavior;     





























































