library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tile_mem_tb is
end tile_mem_tb;

architecture sim of tile_mem_tb is

component tile_mem is
	port(
    tile_num      : in unsigned(5 downto 0);
    tile_pixel_x  : in unsigned(2 downto 0);
    tile_pixel_y  : in unsigned(2 downto 0);
    tile_pixel    : out std_logic_vector(3 downto 0)
	);
end component;

  signal tile_num      : unsigned(5 downto 0) := b"111111";
  signal tile_pixel_x  : unsigned(2 downto 0) := b"000";
  signal tile_pixel_y  : unsigned(2 downto 0) := b"000";
  signal tile_pixel    : std_logic_vector(3 downto 0);

	type tile_mem_t is array (0 to 63) of std_logic_vector(3 downto 0);
	constant expected_pixels : tile_mem_t := (
		x"0", x"1", x"2", x"3",x"4", x"5", x"6", x"7",
		x"8", x"9", x"A", x"B",x"C", x"D", x"E", x"F",
		x"0", x"1", x"2", x"3",x"4", x"5", x"6", x"7",
		x"8", x"9", x"A", x"B",x"C", x"D", x"E", x"F",
		x"0", x"1", x"2", x"3",x"4", x"5", x"6", x"7",
		x"8", x"9", x"A", x"B",x"C", x"D", x"E", x"F",
		x"0", x"1", x"2", x"3",x"4", x"5", x"6", x"7",
		x"8", x"9", x"A", x"B",x"C", x"D", x"E", x"F"
	);

	signal expected_pixel : std_logic_vector(3 downto 0);

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
		assert false report "beginning of tile_mem test bench" severity note;
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
