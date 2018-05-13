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

entity amba_interface is    --   test ONLY the connectivity of amba_interface with test_tcpa_comp.vhd
	generic(
        hindex : integer := 1;
        haddr  : integer := 16#800#;
        hmask  : integer := 16#FC0#;
        hirq   : integer := 0;
        
        --tcpa component address
        TEST_COMPONENT_ADDRESS  : std_logic_vector(31 downto 0);
        TEST_COMPONENT_ID       : integer;
        
        COMP_NUM_POWER  : integer := 4;         -- 2^4 == 16 components
        COMP_SIZE       : integer := 22         -- 2^22 == 4 MByte
        );
    port(
        -- Input Signals from Bus-System to AMBA Interface
        ahb_clk         : in  std_ulogic;
        ahb_rstn        : in  std_ulogic;
        ahbsi           : in  ahb_slv_in_type;
        -- Output signals from AMBA Interface to Bus-System
        ahbso           : out ahb_slv_out_type;
        );
end entity amba_interface;

architecture Behavioral of amba_interface is

---------------------------------------  component declaration
component test_tcpa_comp is
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
        COMP_IF_hready     : out std_ulogic;                     -- transfer done
        COMP_IF_hresp      : out std_logic_vector(1 downto 0);   -- response type
        COMP_IF_hrdata     : out std_logic_vector(31 downto 0);  -- read data bus
        COMP_IF_hsplit     : out std_logic_vector(15 downto 0);  -- split completion
        COMP_IF_hirq       : out std_ulogic;                      -- interrupt bus
        COMP_IF_index      : out integer                      -- interrupt bus
        );
end component test_tcpa_comp;

---------------------------------------  signal declaration

    -- Signals from AMBA Interface to component
    signal IF_COMP_hsel       :  std_ulogic;                    -- slave select
    signal IF_COMP_haddr      :  std_logic_vector(31 downto 0); -- address bus (byte)
    signal IF_COMP_hwrite     :  std_ulogic; -- read/write
    signal IF_COMP_htrans     :  std_logic_vector(1 downto 0);  -- transfer type
    signal IF_COMP_hwdata     :  std_logic_vector(31 downto 0); -- write data bus
    signal IF_COMP_hready     :  std_ulogic; -- transfer done
            
    -- Signals from component to AMBA Interface
    signal COMP_IF_hready     :  std_ulogic;                     -- transfer done
    signal COMP_IF_hresp      :  std_logic_vector(1 downto 0);   -- response type
    signal COMP_IF_hrdata     :  std_logic_vector(31 downto 0);  -- read data bus
    signal COMP_IF_hsplit     :  std_logic_vector(15 downto 0);  -- split completion
    signal COMP_IF_hirq       :  std_ulogic                      -- interrupt bus
    signal COMP_IF_index      :  integer                      -- only for diagnose


	constant SLV_CONFIG : ahb_config_type := (
		0      => ahb_device_reg(VENDOR_CONTRIB, CONTRIB_CORE1, 0, 0, 0),
		4      => ahb_membar(haddr, '0', '0', hmask),
		others => zero32);

        
    type component_addr_type is array (0 to 2**COMP_NUM_POWER-1) of std_logic_vector(31 downto 0);   
    signal component_addr_array : component_addr_type := (others => (others => '0'));
    
    signal mask_intern : std_logic_vector(31 downto 0) := to_stdlogicvector(to_bitvector((x"FFFFFFFF")) srl (32-COMP_NUM_POWER-COMP_SIZE));        -- 0x03FFFFFF
    signal component_size : integer := 2**COMP_SIZE;
    
    signal addr_mask : std_logic_vector(31 downto 0);
    signal addr_srl : std_logic_vector(31 downto 0);
    signal addr_array_index: integer range 0 to 2**COMP_NUM_POWER;
    signal IF_component_addr : std_logic_vector(31 downto 0);
        
begin

---------------------------------------------------   Initiation of test_tcpa_comp
    test_tcpa_comp_i : test_tcpa_comp
    generic map(
        comp_address => TEST_COMPONENT_ADDRESS, 
        index => TEST_COMPONENT_ID)
    port map(
        -- Input Signals from Bus system to component
        clk                => ahb_clk,
        rstn               => ahb_rstn,
        -- Signals from AMBA Interface to component
        IF_COMP_hsel       =>  IF_COMP_hsel,        -- slave select
        IF_COMP_haddr      =>  IF_COMP_haddr,       -- address bus (byte)
        IF_COMP_hwrite     =>  IF_COMP_hwrite,      -- read/write
        IF_COMP_htrans     =>  IF_COMP_htrans,      -- transfer type
        IF_COMP_hwdata     =>  IF_COMP_hwdata,      -- write data bus
        IF_COMP_hready     =>  IF_COMP_hready,      -- transfer done
        
        -- Signals from component to AMBA Interface
        COMP_IF_hready     =>  COMP_IF_hready,      -- transfer done
        COMP_IF_hresp      =>  COMP_IF_hresp,       -- response type
        COMP_IF_hrdata     =>  COMP_IF_hrdata,      -- read data bus
        COMP_IF_hsplit     =>  COMP_IF_hsplit,      -- split completion
        COMP_IF_hirq       =>  COMP_IF_hirq,        -- interrupt bus
        COMP_IF_index      =>  COMP_IF_index
        );

        
    addr_mask  <= ahbsi.haddr and mask_intern;
    addr_srl   <= to_stdlogicvector(to_bitvector(addr_mask) srl COMP_SIZE);
    addr_array_index <= to_integer(unsigned(addr_srl));  
    
-----------------------------------------------------------------  generate address - array
    gen_addr_array : process(ahb_clk, ahb_rstn)
    begin
        if(ahb_clk'event and ahb_clk='1') then
            if ahb_rstn = '0' then 
                for i  in 0 to 2**COMP_NUM_POWER-1 loop
                    component_addr_array(i) <= std_logic_vector(to_unsigned((i*(component_size)),32));
                end loop;
                report "********* Component_Addr_ARRAY is READY *********"; 
            end if;
        end if;
    end process gen_addr_array;
    
-----------------------------------------------------------------  find out the component address of interest
    arbitration : process (ahb_clk, ahb_rstn, ahbsi, addr_array_index)
    begin
        if(ahb_clk'event and ahb_clk='1') then
            if ahb_rstn = '0' then 
                IF_component_addr        <= (others => '0');
                report "********* ahb_rstn is ON *********";
            else
                IF_component_addr      <= (others => '0');
                if ahbsi.hsel(hindex) = '1' then            -- check whether the amba_interface is called
                    IF_component_addr  <= component_addr_array(addr_array_index);
                    report "********* addr_array_index is " & integer'image(addr_array_index) & " *********";
                end if;
            end if;
        end if;    
    end process arbitration;
                   
-----------------------------------------------------------------  configure the output signals to component   
    output_to_comp: process (IF_component_addr)      
    begin
        case IF_component_addr is
            when TEST_COMPONENT_ADDRESS =>  ---------------------        Component: RBuffer_hirq       
                IF_COMP_hready    <=  ahbsi.hready;
                IF_COMP_hsel      <=  '1';
                IF_COMP_haddr     <=  ahbsi.haddr;
                IF_COMP_hwrite    <=  ahbsi.hwrite;
                IF_COMP_htrans    <=  ahbsi.htrans;
                IF_COMP_hwdata    <=  ahbsi.hwdata;
                
            when others =>
                IF_COMP_hready    <=  '0';
                IF_COMP_hsel      <=  '0';
                IF_COMP_haddr     <=  (others=>'0');
                IF_COMP_hwrite    <=  '0';
                IF_COMP_htrans    <=  (others=>'0');
                IF_COMP_hwdata    <=  (others=>'0');
        end case;        
    end process;
            
-----------------------------------------------------------------  configure the output signals to bus   
    output_to_bus: process (IF_component_addr)      
    begin
        case IF_component_addr is
            when TEST_COMPONENT_ADDRESS =>  ---------------------        Component: RBuffer_hirq       
                if COMP_IF_index = TEST_COMPONENT_ID then
                    ahbso.hrdata         <= COMP_IF_hrdata;
                    ahbso.hready         <= COMP_IF_hready;
                    ahbso.hresp          <= COMP_IF_hresp;       
                    ahbso.hirq           <= COMP_IF_hirq;
                    ahbso.hsplit         <= COMP_IF_hsplit;
                    ahbso.hconfig        <= SLV_CONFIG;
                    ahbso.hindex         <= hindex;
                end if;
                
            when others =>
                ahbso.hrdata         <= (others => '0');
                ahbso.hready         <= '0';
                ahbso.hresp          <= "00";       -- status: okay
                ahbso.hirq           <= (others => '0');
                ahbso.hsplit         <= (others => '0');
                ahbso.hconfig        <= SLV_CONFIG;
                ahbso.hindex         <= hindex;
        end case;        
    end process;

        
end Behavioral; 
















































































