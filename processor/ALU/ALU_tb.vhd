library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU_tb is
end ALU_tb;

architecture sim of ALU_tb is


-- Component declaration
component ALU is
	port(
		clk : in std_logic;
		rst : in std_logic;
		A : in unsigned (15 downto 0);
		B : in unsigned (15 downto 0);
		OP : in unsigned(3 downto 0);
		Y : out unsigned(15 downto 0);
		H : out unsigned(15 downto 0)
		);
end component;

	-- Inputs
	signal clk : std_logic;
	signal rst : std_logic;
	signal A : unsigned (15 downto 0) := X"0001";
	signal B : unsigned (15 downto 0) := X"0000";
	signal OP : unsigned (3 downto 0) := "1010";

	-- Outputs
	signal Y : unsigned(15 downto 0);
	signal H : unsigned(15 downto 0);
	

begin
	UUT : ALU port map(
		clk => clk,
		rst => rst,
		A => A,
		B => B,
		OP => OP,
		Y => Y,
		H => H		
	);
	
	process
	begin
		for i in 0 to 450 loop
			clk <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
		end loop;
		wait; -- wait forever, will finish simulation
	end process;

	
			
	
	
end architecture;
