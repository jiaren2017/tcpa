library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type_pkg.all;


entity single_comp is
    generic( 
        COMPONENT_INDEX: integer;
        SUM_COMPONENT: integer
    );
    port(
        CLK: in std_logic;
        RST: in std_logic;
        IF_COMP_data: in  arr_IF_COMP(0 to SUM_COMPONENT-1);
    --    COMP_IF_out: out arr_COMP_IF(0 to SUM_COMPONENT-1)
        COMP_IF_out : out rec_COMP_IF
    );	
end single_comp;

architecture behavior of single_comp is

    signal  intern_data : std_logic_vector(31 downto 0);            -- intern signal


begin
	
    Output_to_IF : process(CLK,rst,IF_COMP_data,intern_data)
    begin
        if(CLK'event and CLK='1') then
            if rst = '1' then 
                intern_data <= (others => '0');
                COMP_IF_out.hrdata    <=  (others => '0');
                COMP_IF_out.hready    <=  '0';
                COMP_IF_out.hresp     <=  (others => '0');
                COMP_IF_out.hirq      <=  '0';
                COMP_IF_out.hsplit    <=  (others => '0');
                COMP_IF_out.hindex    <=  0;
                
            else
                COMP_IF_out.hrdata    <=  (others => '0');
                COMP_IF_out.hready    <=  '0';
                COMP_IF_out.hresp     <=  (others => '0');
                COMP_IF_out.hirq      <=  '0';
                COMP_IF_out.hsplit    <=  (others => '0');
                COMP_IF_out.hindex    <=  0;
            
                if IF_COMP_data(COMPONENT_INDEX).hsel = '1' then                -- check the selection
                    if IF_COMP_data(COMPONENT_INDEX).hwrite = '1' then          -- wrie data to component
                        intern_data <= IF_COMP_data(COMPONENT_INDEX).hwdata;
                        COMP_IF_out.hready    <=  '1';
                    else                                                        -- read data from component
                        COMP_IF_out.hrdata    <=  intern_data;
                        COMP_IF_out.hready    <=  '1';
                        COMP_IF_out.hindex    <=  COMPONENT_INDEX;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end behavior;
