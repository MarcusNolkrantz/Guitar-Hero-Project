library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test_tb is
end test_tb;

architecture sim of test_tb is

	component test is
		port(
    		clk         : in  std_logic;
			rst         : in  std_logic;
			JA      : out std_logic_vector(0 downto 0)
		);
	end component;

  	signal clk          : std_logic;
	signal rst          : std_logic;
	signal JA       : std_logic_vector(0 downto 0);


begin
	U0 : test port map(
		clk         => clk,
		rst         => rst,
		JA      => JA
	);
	
	process
	begin
		for i in 0 to 100000000 loop
			if i = 0 then
				rst <= '1';
			else
				rst <= '0'; 
			end if;
			 clk <= '1';
			wait for 1 ns;
			clk <= '0';
			wait for 1 ns;
		end loop;
		

		-- finish simulation
		wait;
	end process;
end architecture;
