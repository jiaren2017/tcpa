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
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:24:14 08/14/2014 
-- Design Name: 
-- Module Name:    Simple_Matrix_Mult- Behavioral 
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

entity Simple_Matrix_Mult is
	generic(
		--###########################################################################
		-- Simple_Matrix_Multparameters, do not add to or delete
		--###########################################################################
		DATA_WIDTH        : integer range 0 to 32 := 8;
		M         			: integer range 0 to 64 := 5;
		K         : integer range 0 to 64 := 2;
		N         : integer range 0 to 64 := 5;
		PIPELINE_DEPTH     : integer range 0 to 32 := 2 -- equals log2(K) + 1
	--###########################################################################		
	);
	port(
		clk            : in  std_logic;
		reset          : in  std_logic;
		start          : in  std_logic;
		A_Mat 		   : in  std_logic_vector(M * K * DATA_WIDTH - 1 downto 0);
		B_Mat 		   : in  std_logic_vector(K * N * DATA_WIDTH - 1 downto 0);
		C_Mat 		   : out std_logic_vector(M * N * 2 * DATA_WIDTH - 1 downto 0);
		valid 	   	   : OUT std_logic_vector(M * N -1 downto 0)
	);
end Simple_Matrix_Mult;

architecture Behavioral of Simple_Matrix_Mult is
	--------------------- Signals ----------------------------------------------------
	type vect_t is array(K -1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type array_line_vect_t is array(M -1 downto 0) of vect_t;
	signal u          : array_line_vect_t := (others => (others => (others => '0')));
	type vectk_t is array(N -1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type array_column_vect_t is array(K -1 downto 0) of vectk_t;
	signal v          : array_column_vect_t := (others => (others => (others => '0')));
	type vect_2t is array(N -1 downto 0) of std_logic_vector(2 * DATA_WIDTH - 1 downto 0);
	type array_result_vect_t is array(M -1 downto 0) of vect_2t;
	signal res        : array_result_vect_t:= (others => (others => (others => '0')));
	--type valid_t is array (M -1 downto 0) of std_logic_vector(N - 1 downto 0);
	--signal valid      : valid_t	:= (others => (others => '0'));
	type line_vect_t is array(M -1 downto 0) of std_logic_vector(K * DATA_WIDTH - 1 downto 0);
	type col_vect_t is array(N -1 downto 0) of std_logic_vector(K * DATA_WIDTH - 1 downto 0);
	signal u_temp	  : line_vect_t	:= (others => (others => '0'));
	signal v_temp	  : col_vect_t	:= (others => (others => '0'));
	--------------------- End Signal -------------------------------------------------

	--------------------- Component --------------------------------------------------
	COMPONENT Scalar_Product_Simple
		GENERIC(
			DATA_WIDTH    : integer range 0 to 32 := DATA_WIDTH;
			DIMENSION     : integer range 0 to 64 := K;
			PIPELINE_DEPTH : integer range 0 to 32 := PIPELINE_DEPTH -- equals log2(DIMENSION) + 1
		);
		PORT(
			clk   : IN  std_logic;
			reset : IN  std_logic;
			en    : IN  std_logic;
			u     : IN  std_logic_vector(DATA_WIDTH * K - 1 downto 0);
			v     : IN  std_logic_vector(DATA_WIDTH * K - 1 downto 0);
			res   : out std_logic_vector(2 * DATA_WIDTH - 1 downto 0);
			valid : OUT std_logic
		);
	END COMPONENT;
--------------------- End Component ----------------------------------------------
--	attribute KEEP_HIERARCHY : string;
--	attribute KEEP_HIERARCHY of Scalar_Product_Simple: component is "TRUE";
	
	attribute syn_preserve : boolean;
	attribute syn_preserve of Scalar_Product_Simple: component is true;
begin
	

	-- Extract A Mat Parameters from the config reg
	PARAMETERS_M : for i in 0 to M -1 generate
		PARAMETERS_K : for j in 0 to K -1 generate
			u(i)(j)(DATA_WIDTH - 1 downto 0) <= A_Mat(((K * i + (j+1)) * DATA_WIDTH) -1 downto (K * i + j)*DATA_WIDTH);
		end generate PARAMETERS_K;
	end generate PARAMETERS_M;
	
	-- Extract B Mat Parameters from the config reg
	PARAMETERS_K : for i in 0 to K -1 generate
		PARAMETERS_N : for j in 0 to N -1 generate
			v(i)(j)(DATA_WIDTH - 1 downto 0) <= B_Mat(((N * i + (j+1)) * DATA_WIDTH) -1 downto (N * i + j)*DATA_WIDTH);
		end generate PARAMETERS_N;
	end generate PARAMETERS_K;
	
	-- Extract u_temp parameters for the scalar product
	U_TEMP_G : for i in 0 to M -1 generate
		U_TEMP_2: for j in 0 to K -1 generate
			u_temp(i)((j+1) * DATA_WIDTH -1 downto j * DATA_WIDTH)	<= u(i)(j);
		end generate U_TEMP_2;
	end generate U_TEMP_G;
	
		-- Extract u_temp parameters for the scalar product
	V_TEMP_G : for i in 0 to N -1 generate
		V_TEMP_2: for j in 0 to K -1 generate
			v_temp(i)((j+1) * DATA_WIDTH -1 downto j * DATA_WIDTH)	<= v(j)(i);
		end generate V_TEMP_2;
	end generate V_TEMP_G;

	-- Initialize the scalar product components
	SCALAR_I : for i in 0 to M -1 generate
		SCALAR_J : for j in 0 to N-1 generate
			Compute_Inst : Scalar_Product_Simple
				GENERIC MAP(
					DATA_WIDTH    => DATA_WIDTH,
					DIMENSION     => K,
					PIPELINE_DEPTH => PIPELINE_DEPTH
				)
				PORT MAP(
					clk   => clk,
					reset => reset,
					en    => start,
					u     => u_temp(i),
					v     => v_temp(j),
					res   => res(i)(j),
					valid => valid(i * N + j)
			);			
		end generate SCALAR_J;		
	end generate SCALAR_I;
	
	OUTPUT_I : for i in 0 to M-1 generate
		OUTPUT_J : for j in 0 to N -1 generate
			C_Mat((i * N + (j + 1)) * 2* DATA_WIDTH -1 downto (i * N + j) * 2* DATA_WIDTH) <= res(i)(j);
		end generate OUTPUT_J;		
	end generate OUTPUT_I;	
	
end Behavioral;




