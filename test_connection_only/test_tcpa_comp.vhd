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


entity test_tcpa_comp is
    generic(
        comp_address: std_logic_vector(31 downto 0);
        index : integer
    );
    port(
        -- Input Signals from Bus system to component
        clk                : in  std_ulogic;
        rstn               : in  std_ulogic;
        
        -- Signals from AMBA Interface to component
        IF_COMP_hsel       : in std_ulogic;                    -- slave select
        IF_COMP_haddr      : in std_logic_vector(31 downto 0); -- address bus (byte)
        IF_COMP_hwrite     : in std_ulogic; -- read/write
        IF_COMP_htrans     : in std_logic_vector(1 downto 0);  -- transfer type
        IF_COMP_hwdata     : in std_logic_vector(31 downto 0); -- write data bus
        IF_COMP_hready     : in std_ulogic; -- transfer done
        
        -- Signals from component to AMBA Interface
        COMP_IF_hready     : out std_ulogic; -- transfer done
        COMP_IF_hresp      : out std_logic_vector(1 downto 0);   -- response type
        COMP_IF_hrdata     : out std_logic_vector(31 downto 0);  -- read data bus
        COMP_IF_hsplit     : out std_logic_vector(15 downto 0);  -- split completion
        COMP_IF_hirq       : out std_ulogic;                     -- interrupt bus
        COMP_IF_index      : out integer                      -- interrupt bus
        );
end entity test_tcpa_comp;

architecture Behavioral of test_tcpa_comp is
    signal intern_haddr     : std_logic_vector(31 downto 0);
    signal intern_hwdata    : std_logic_vector(31 downto 0);
        
begin
   
    arbitration : process (clk, rstn, IF_COMP_hsel, IF_COMP_haddr, IF_COMP_hwrite, IF_COMP_hwdata, intern_haddr, intern_hwdata)
    begin
        if(clk'event and clk='1') then
            if rstn = '0' then                          -- reset
                intern_haddr    <= (others => '0');
                intern_hwdata   <= (others => '0');
                
                COMP_IF_hready  <= '0';                 -- default output 
                COMP_IF_hresp   <= (others => '0');
                COMP_IF_hrdata  <= (others => '0');
                COMP_IF_hsplit  <= (others => '0');
                COMP_IF_hirq    <= '0';
                COMP_IF_index   <= 0;
                
            else
                COMP_IF_hready  <= '0';                 -- default
                COMP_IF_hresp   <= (others => '0');
                COMP_IF_hrdata  <= (others => '0');
                COMP_IF_hsplit  <= (others => '0');
                COMP_IF_hirq    <= '0';
                COMP_IF_index   <= 0;
                
                if IF_COMP_hsel = '1' then                      -- check whether the component is called
                    if IF_COMP_hwrite = '1' then                -- write signal
                        intern_haddr    <= IF_COMP_haddr;
                        intern_hwdata   <= IF_COMP_hwdata;
                    else                                        -- read signal
                        if intern_haddr = IF_COMP_haddr then    -- check the address of data
                            COMP_IF_hready  <= '1';                
                            COMP_IF_hresp   <= (others => '0');
                            COMP_IF_hrdata  <= intern_hwdata;
                            COMP_IF_hsplit  <= (others => '0');
                            COMP_IF_hirq    <= '0';
                            COMP_IF_index   <= index;
                        end if;
                    end if;
                end if;
            end if;
        end if;    
    end process;
        
end Behavioral; 




















































































