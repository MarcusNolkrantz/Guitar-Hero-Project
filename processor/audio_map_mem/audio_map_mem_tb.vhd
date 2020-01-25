library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity audio_map_mem_tb is
end audio_map_mem_tb;

architecture sim of audio_map_mem_tb is

	component audio_map_mem is
		port(
			audio_index     : in unsigned(2 downto 0); -- 8 notes
			time_period     : out unsigned(11 downto 0) -- amount of thousand clk ticks
		);
	end component;

  	signal audio_index    : unsigned(2 downto 0) := b"111";
  	signal time_period    : unsigned(11 downto 0);

begin
	U0 : audio_map_mem port map(
		audio_index => audio_index,
		time_period => time_period
	);

	process
	begin
		-- test all mappings to the notes
		for i in 0 to 7 loop
			audio_index <= to_unsigned(i, 3);
			wait for 1 ns;
		end loop;

		-- finish simulation
		wait;
	end process;

end architecture;
