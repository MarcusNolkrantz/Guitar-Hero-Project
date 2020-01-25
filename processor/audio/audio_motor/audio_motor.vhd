library ieee;
use ieee.std_logic_1164.ALL;            
use ieee.numeric_std.ALL; 

--TODO: change signal output to hardware output 


entity audio_motor is
	port (
		clk         : in  std_logic;
		rst         : in  std_logic;
		time_period        : in unsigned(15 downto 0);
		JA      : out std_logic_vector(0 downto 0);
	);
end entity;

architecture behaviour of audio_motor is

	signal outer_counter : unsigned(15 downto 0) := x"0000"; --counts to input signal "time_period"
	signal inner_counter : unsigned(15 downto 0) := x"0000"; --counts to 1000 (dec)
	
	constant thousand : unsigned(15 downto 0) := x"03E8"; --1000 decimal

begin
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				outer_counter <= x"0000";
				inner_counter <= x"0000";
			elsif inner_counter >= thousand then
				inner_counter <= x"0000";
				if (outer_counter >= time_period) then
					outer_counter = x"0000";
				else
					outer_counter <= outer_counter + 1;
				end if;
			else
				inner_counter <= inner_counter + 1;
			end if;
		end if;
	end process;

	JA(0) <= '1' when outer_counter = time_period else '0';
end architecture;
