library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity audio_motor_tb is
end audio_motor_tb;

architecture sim of audio_motor_tb is

	component audio_motor is
		port (
			clk         : in  std_logic;
			rst         : in  std_logic;
			time_period : in unsigned(15 downto 0);
			output      : out std_logic
		);
	end component;

  	signal clk          : std_logic;
	signal rst          : std_logic;
	signal time_period  : unsigned(15 downto 0) := x"0004";
	signal output       : std_logic;

begin
	U0 : audio_motor port map(
		clk => clk,
		rst => rst,
		time_period => time_period,
		output => output
	);
	
	process
	begin
		for i in 0 to 1000000 loop
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
