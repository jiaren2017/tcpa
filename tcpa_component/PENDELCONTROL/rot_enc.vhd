----------------------------------------------------------------------------------
-- Company: fau
-- Engineer: Andreas Becher
-- 
-- Create Date:    11:20:48 06/03/2015 
-- Design Name: 
-- Module Name:    rot_enc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rot_enc is
    Generic ( Delay : integer range 1 to 1024 := 16);
    Port ( clk : in  STD_LOGIC;
           rst : in STD_LOGIC;
           inca : in  STD_LOGIC;
           incb : in  STD_LOGIC;
           up : out  STD_LOGIC;
           down : out  STD_LOGIC);
end rot_enc;

architecture Behavioral of rot_enc is

    constant SYNC_WIDTH : integer := 8;

    signal sync_a : std_logic_vector(SYNC_WIDTH-1 downto 0) := (others => '0');
    signal sync_b : std_logic_vector(SYNC_WIDTH-1 downto 0) := (others => '0');


    signal stable_cnt : integer range 0 to Delay-1 := 0;



    signal a : std_logic;
    signal b : std_logic;

    type state_t  is (IDLE,AHIGH,ABHIGH,BHIGH);
    signal state : state_t := IDLE;

begin



    sync_a_proc:process
    begin
        wait until rising_edge(clk);
        if(rst = '1') then
            sync_a(sync_a'high downto sync_a'low+1) <= (others => '0');
            sync_a(sync_a'low) <= '1';
        else
            sync_a(sync_a'low) <= inca;
            for i in 1 to sync_a'high loop
                sync_a(i) <= sync_a(i-1);
            end loop;
        end if;
    end process;

    sync_b_proc:process
    begin
        wait until rising_edge(clk);
        if(rst = '1') then
            sync_b(sync_b'high downto sync_b'low+1) <= (others => '0');
            sync_b(sync_b'low) <= '1';
        else
            sync_b(sync_b'low) <= incb;
            for i in 1 to sync_b'high loop
                sync_b(i) <= sync_b(i-1);
            end loop;
        end if;
    end process;


    a <= sync_a(sync_a'high);
    b <= sync_b(sync_b'high);


    cnt_proc:process
    begin
        wait until rising_edge(clk);

        if( rst = '1') then
            stable_cnt <= 0;
        else

            if((sync_a(sync_a'high) /= sync_a(sync_a'high-1)) or (sync_b(sync_b'high) /= sync_b(sync_b'high-1)) ) then
                stable_cnt <= 0;
            else
                if(stable_cnt /= Delay-1) then
                    stable_cnt <= stable_cnt +1;

                end if;
            end if;


        end if;

    end process;




    step_proc:
    process

    begin

        wait until rising_edge(clk);
        if( rst = '1') then
            state <= IDLE;
            up <= '0';
            down <= '0';
        else
            up <= '0';
            down <= '0';
            if(stable_cnt = Delay-1) then

                case state is
                    when IDLE =>

                        if(a = '1'  and b = '1') then
                            state <= ABHIGH;
                        end if;

                        if(a = '1' and b = '0') then
                            state <= AHIGH;
                            up <= '1';
                        end if;

                        if(a = '0' and b = '1') then
                            state <= BHIGH;
                            down <= '1';
                        end if;

                    when AHIGH =>


                        if(a = '0' and b='0') then
                            state <= IDLE;
                            down <= '1';
                        end if;

                        if(a = '1' and b = '1') then
                            state <= ABHIGH;
                            up <= '1';
                        end if;

                    when ABHIGH =>


                        if(a = '0' and b = '1') then
                            state <= BHIGH;
                            up <= '1';
                        end if;

                        if(a = '1' and b='0') then
                            state <= AHIGH;
                            down <= '1';
                        end if;    


                    when BHIGH =>


                        if(a = '1' and b = '1') then
                            state <= ABHIGH;
                            down <= '1';
                        end if;

                        if(b = '0' and a = '0') then
                            state <= IDLE;
                            up <= '1';
                        end if; 




                end case;


            end if;
        end if;
    end process;


end Behavioral;
