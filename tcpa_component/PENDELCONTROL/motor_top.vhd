----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.06.2016 16:58:22
-- Design Name: 
-- Module Name: motor_pwm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
library grlib; 
use grlib.amba.all; use grlib.devices.all;
library gaisler; 
use gaisler.misc.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library work;
use work.constants.all;
use work.all;

entity motor_top is
    generic (
      pindex : integer := 0;
      paddr : integer := 0;
      pmask : integer := 16#fff#
    );
    Port ( clk : in STD_LOGIC;
        rstn : in STD_LOGIC;
        pwm_out : out STD_LOGIC;
        pwm_ref : out STD_LOGIC;
        pwmenable     : out STD_LOGIC;
        encoderRot : in std_logic_vector(1 downto 0);
        encoderDist : in std_logic_vector(1 downto 0);
        -- BUS protocol ports ---------------------------------------------- 
        apbi                 : in apb_slv_in_type;
        apbo                 : out apb_slv_out_type;
       
        
        -- LED ports--------------------------------------------------------
        led_blink             : out std_logic_vector(7 downto 3) 

           );
end motor_top;

architecture Behavioral of motor_top is

component  pwm is
--    generic (sys_frequency : unsigned(31 downto 0) := to_unsigned(100000,32) ;
--            pwm_frequencvy : unsigned(10 downto 0)  := to_unsigned(100,11)); -- frequency in kHz
    Port ( clk : in std_logic;
           rst_n : in std_logic;
           ratio_sys_pwm_freq :  unsigned(BITWIDTH_SYS_PWM_RATION-1 downto 0);
           duty_cycle : in unsigned(BITWIDTH_DUTY_CYCLE-1 downto 0); --integer from 0 to 127
           pwm_out : out STD_LOGIC);
end component;

component rot_enc is
	 Generic ( Delay : integer := 3);
    Port ( clk : in  STD_LOGIC;
			     rst : in STD_LOGIC;
           inca : in  STD_LOGIC;
           incb : in  STD_LOGIC;
           up : out  STD_LOGIC;
           down : out  STD_LOGIC);
end component;


component QuadEncSimple is
 
    Port ( RST       : IN  STD_LOGIC;
           CLK       : IN  STD_LOGIC;
           QuadA     : IN  STD_LOGIC;
           QuadB     : IN  STD_LOGIC;
           AngleCnt  : OUT STD_LOGIC_VECTOR (15 downto 0)
			  );
end component;



signal duty_cycle             :   unsigned(BITWIDTH_DUTY_CYCLE-1 downto 0);
signal ratio_sys_pwm_freq   :   unsigned(BITWIDTH_SYS_PWM_RATION-1 downto 0);

signal ref_duty_cycle : unsigned (BITWIDTH_DUTY_CYCLE -1 downto 0) := to_unsigned(64,BITWIDTH_DUTY_CYCLE);
--signal duty_cycle : unsigned (BITWIDTH_DUTY_CYCLE -1 downto 0) := to_unsigned(10,BITWIDTH_DUTY_CYCLE);


-- SIGNAL for slave model to read and write -----------------------------------
signal slv_reg0 ,  slv_reg1, slv_reg2 , slv_reg3		: std_logic_vector(31 downto 0) := (others => '0');

-- System attribute initialising ---------------------------------------
constant REVISION 				: integer := 0;


constant PCONFIG : apb_config_type := (
0 => ahb_device_reg (VENDOR_CONTRIB, CONTRIB_CORE1, 0, REVISION, 0),
1 => apb_iobar(paddr, pmask));
------------------------------------------------------------------------
type registers is record
    reg : std_logic_vector(31 downto 0);
end record;
signal r, rin, rin_slv0 : registers; 
signal pwm_out_s, pwm_ref_s : std_logic;
signal up_rot, down_rot,up_dist, down_dist: std_logic;
signal rot_counter, dist_counter : signed(31 downto 0);
signal rst, reset_rot_counter, reset_dist_counter  : std_logic;
signal     AngleCnt  : STD_LOGIC_VECTOR (15 downto 0);
signal simpelEncRst : std_logic;

begin

ratio_sys_pwm_freq <=unsigned(slv_reg0(31 - BITWIDTH_COUNTERS_RESET-BITWIDTH_PWMENABLE downto BITWIDTH_DUTY_CYCLE));
ref_duty_cycle <= to_unsigned(64,BITWIDTH_DUTY_CYCLE);
duty_cycle <= unsigned(slv_reg0(BITWIDTH_DUTY_CYCLE-1 downto 0));
rst <= not rstn;

PWM_REF_MODULE: pwm 
--generic map(sys_frequency =>to_unsigned(100000,32),
-- pwm_frequencvy => to_unsigned(1000,11))
port map(
           clk => clk,
           rst_n => rstn,
           ratio_sys_pwm_freq => ratio_sys_pwm_freq,
           duty_cycle => ref_duty_cycle,
           pwm_out => pwm_ref_s
);
PWM_MODULE2: pwm 
port map(
           clk => clk,
           rst_n => rstn,
           ratio_sys_pwm_freq => ratio_sys_pwm_freq,
           duty_cycle => duty_cycle ,
           pwm_out => pwm_out_s
);


ROT_ENC_MODULE:  rot_enc
generic map(delay => 500)
port map(
            clk => clk,
            rst  => rst,
            inca => not encoderRot(0),
            incb  => not encoderRot(1),
            up => up_rot,
            down => down_rot
);


ROT_DIST_MODULE:  rot_enc
generic map(delay => 500)
port map(
            clk => clk,
            rst  => rst,
            inca => encoderDist(0),
            incb  => encoderDist(1),
            up => up_dist,
            down => down_dist
);

ROT_SIMPLES_MODULE: QuadEncSimple  
    Port map( RST       => simpelEncRst,
           CLK      => clk,
           QuadA    => encoderRot(0),
           QuadB      => encoderRot(1),
           AngleCnt  =>AngleCnt
			  );

simpelEncRst <= rst or reset_rot_counter;
pwm_out <=  pwm_out_s;
pwm_ref <= pwm_ref_s;
--led_blink(7) <= pwm_out_s;
--led_blink(6) <= pwm_ref_s;
--led_blink(5 downto 3 ) <= slv_reg0  (2 downto 0);
--direction <= '1';


 -- functional reading and writing with two registers proccess-----------------------------------------------
     READ_WRITE_PROC : process(rstn,apbi)
	      variable readdata : std_logic_vector(31 downto 0);
	      variable var_svl_reg0, var_svl_reg1, var_svl_reg2, var_svl_reg3  : std_logic_vector(31 downto 0);
	      variable reg0, reg1, reg2, reg3 : registers; -- reg0 for Writing,reg1 for Reading
              begin
          --    if rising_edge(clk) then
                reg1.reg := slv_reg1;
                reg2.reg := slv_reg2;
                reg3.reg := slv_reg3;
                var_svl_reg0 := slv_reg0;
                var_svl_reg1 := slv_reg1;
                var_svl_reg2 := slv_reg2;
                var_svl_reg3 := slv_reg3;
                -- write registers
                if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
                  case apbi.paddr(4 downto 2) is
                    when "000" => reg0.reg(31 downto 0) := apbi.pwdata(31 downto 0); -- write data from apbo write bus
                    when others => null;
                    end case;
                end if;
                
                -- read register
                readdata := (others => '0');
                case apbi.paddr(4 downto 2) is
                  when "001" => readdata := reg1.reg(31 downto 0); 
                  when "010" => readdata := reg2.reg(31 downto 0); -- This is for debugging prurpose only
                  when "011" => readdata := var_svl_reg0; --
                  when "100" => readdata := reg3.reg(31 downto 0); -- Here, we read the content from slv_reg1 that changes based on the controller
                  when others => null;
                end case;
                
                -- system reset
                if rstn = '0' then 
                  reg0.reg := (others => '0');
                  reg1.reg := (others => '0');
                  reg2.reg := (others => '0');
                  reg3.reg := (others => '0');
                  readdata := (others => '0');
                
                end if;
                
                rin <= reg0;
                apbo.prdata <= readdata; -- drive apb read bus
     --         end if;
   end process;
   
   
    apbo.pirq <= (others => '0');
    apbo.pindex <= pindex;
    apbo.pconfig <= PCONFIG;
  

    regs : process(clk)
    begin
	  if rising_edge(clk) then 
        if rstn = '0' then 
            slv_reg0 <= (others => '0');
        else 
-- 	    r <= rin; 
            slv_reg0 <= rin.reg; --takes the input from register 0 (reg0)
        end if;    
	  end if;
    end process;



    pwm_enable : process(clk)
    begin
      if rstn = '0' then 
          pwmenable <= '0';
          reset_rot_counter <=  '0';
          reset_dist_counter <=  '0';

	    elsif rising_edge(clk) then 
          pwmenable <= slv_reg0(31);
          reset_rot_counter <= slv_reg0(30);
          reset_dist_counter <= slv_reg0(29);

            
	    end if;
    end process;


    rot_counter_proc : process(clk)
    begin
	  if rising_edge(clk) then 
        if rstn = '0' or  reset_rot_counter = '1'  then 
            rot_counter <=(others => '0');
        elsif up_rot = '1' then
            rot_counter <= rot_counter +1;
        elsif down_rot = '1' then
            rot_counter <= rot_counter -1;

        end if;

            
	  end if;
    end process;


     dist_counter_proc : process(clk)
    begin
	  if rising_edge(clk) then 
        if rstn = '0' or  reset_dist_counter = '1' then 
            dist_counter <=(others => '0');
        elsif up_dist = '1' then
            dist_counter <= dist_counter +1;
        elsif down_dist = '1' then
            dist_counter <= dist_counter -1;

        end if;

            
	  end if;
    end process;

    slv_reg1 <=std_logic_vector(rot_counter);
    slv_reg2 <=std_logic_vector(dist_counter);
    slv_reg3 <= x"0000" & AngleCnt;
end Behavioral;
