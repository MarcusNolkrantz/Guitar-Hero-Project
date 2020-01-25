library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity audio_tb is
end audio_tb;

architecture sim of audio_tb is

	component audio is
		port(
    		clk         : in  std_logic;
			rst         : in  std_logic;
			we          : in  std_logic;
			output      : out std_logic;
			addr_write  : in  unsigned(0 downto 0);
			data_write  : in  std_logic_vector(2 downto 0)   
		);
	end component;

  	signal clk          : std_logic;
	signal rst          : std_logic;
	signal we           : std_logic;-- := '1';
	signal addr_read    : unsigned(0 downto 0);-- := "0";
	signal output       : std_logic;
	signal addr_write   : unsigned(0 downto 0);-- := "0";
	signal data_write   : std_logic_vector(2 downto 0);-- := "000";   

begin
	U0 : audio port map(
		clk         => clk,
		rst         => rst,
		we          => we,
		output      => output,
		addr_write  => addr_write,
		data_write  => data_write
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
