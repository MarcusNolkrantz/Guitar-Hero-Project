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

	type expected_notes_t is array (0 to 7) of unsigned(11 downto 0);
	constant expected_notes : expected_notes_t := (
		x"0E3", --note A, 227 dec, 440 mHz
		x"0CA", --note B, 202 dec
		x"17E", --note C, 382 dec
		x"154", --note D, 340 dec
		x"12F", --note E, 303 dec
		x"11E", --note F, 286 dec
		x"0FF", --note G, 255 dec
		x"FFF" 
	);

	signal expected_note : unsigned(11 downto 0);

begin

	U0 : tile_mem port map(
		tile_num => tile_num,
		tile_pixel_x => tile_pixel_x,
    tile_pixel_y => tile_pixel_y,
    tile_pixel => tile_pixel
	);

	expected_pixel <= expected_pixels(
		to_integer(unsigned(tile_pixel_y(2 downto 0) & tile_pixel_x(2 downto 0))));

	process
	begin
		-- test start
		assert false report "beginning of audio_map_mem test bench" severity note;
		-- test all pixels in last tile
		for y in 0 to 7 loop
			for x in 0 to 7 loop
				assert tile_pixel = expected_pixel
					 report "wrong pixel output: expected " &
					 				integer'image(to_integer(unsigned(expected_pixel)))
					 				& " got " &
									integer'image(to_integer(unsigned(tile_pixel)))
									severity error;
					tile_pixel_x <= tile_pixel_x + 1;
					wait for 1 ns;
			end loop;
			tile_pixel_x <= b"000";
			tile_pixel_y <= tile_pixel_y + 1;
			wait for 1 ns;
		end loop;
		-- test end
		assert false report "end of tile_mem test bench" severity note;
		-- finish simulation
		wait;
	end process;

end architecture;
