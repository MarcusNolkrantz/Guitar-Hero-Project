library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PM_tb is
end PM_tb;

architecture sim of PM_tb is

component PM is
	port(
		addr : in unsigned(8 downto 0);
    		data_out : out unsigned(31 downto 0)
		);
end component;

	signal addr : unsigned(8 downto 0);
	signal data_out : unsigned(31 downto 0);
	
begin

	U0 : PM port map(
		addr => addr,
		data_out => data_out
	);
	
	
	
	addr <= "000000001";
	
end architecture;
