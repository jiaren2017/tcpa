-- Read Quadrature Encoder
--
-- counts quadrature encoder signals
-- outputs rotation number and angle count
--
-- generic: number of counts for one complete revolution
--
-- Author: P.Kroh

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity QuadEncRots is
    Generic ( CNTPERROT : unsigned(15 downto 0) := X"1000" );
    Port ( RST       : IN  STD_LOGIC;
           CLK       : IN  STD_LOGIC;
           QuadA     : IN  STD_LOGIC;
           QuadB     : IN  STD_LOGIC;
           NumRot    : OUT STD_LOGIC_VECTOR (7 downto 0); -- signed, 2 complement!
           AngleCnt  : OUT STD_LOGIC_VECTOR (15 downto 0)
			  );
end QuadEncRots;
 

architecture Behavioral of QuadEncRots is
 
signal QuadA_buf : STD_LOGIC; -- previous signal level of encoder channel a
signal QuadB_buf : STD_LOGIC; -- previous signal level of encoder channel b
 
signal Rot: signed(7 downto 0) := X"00"; -- number of rotations
signal Count: unsigned(15 downto 0) := X"0000"; -- number of encoder counts
 

begin
 
NumRot <= STD_LOGIC_VECTOR(Rot);
AngleCnt <= STD_LOGIC_VECTOR(Count);

process (CLK)
	variable Count_En : STD_LOGIC; -- enable count change
	variable Count_Dir : STD_LOGIC; -- rotation direction
begin
	if rising_edge(CLK) then
		Count_En := QuadA xor QuadA_buf xor QuadB xor QuadB_buf;
		Count_Dir := QuadA xor QuadB_buf;
		QuadA_buf <= QuadA;
		QuadB_buf <= QuadB;

		if RST = '1' then
			Rot <= X"00";
			Count <= X"0000";
		else
			if Count_En ='1' then
				if Count_Dir ='1' then
					if Count = (CNTPERROT - 1) then
						Count <= X"0000";
						Rot <= Rot + 1;
					else
						Count <= Count + 1;
					end if;
				else
					if Count = X"0000" then
						Count <= (CNTPERROT - 1);
						Rot <= Rot - 1;
					else
						Count <= Count - 1;
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

 
end Behavioral;
