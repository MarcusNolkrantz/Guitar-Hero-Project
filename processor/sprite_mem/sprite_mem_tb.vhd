library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sprite_mem_tb is
end sprite_mem_tb;

architecture sim of sprite_mem_tb is

component sprite_mem is
	port(
		sprite_num        : in unsigned(2 downto 0);
		sprite_pixel_x  : in unsigned(2 downto 0);
		sprite_pixel_y  : in unsigned(2 downto 0);
		sprite_pixel    : out std_logic_vector(3 downto 0)
	);
end component;

  signal sprite_num      : unsigned(2 downto 0) := b"111";
  signal sprite_pixel_x  : unsigned(2 downto 0) := b"000";
  signal sprite_pixel_y  : unsigned(2 downto 0) := b"000";
  signal sprite_pixel    : std_logic_vector(3 downto 0);

	type sprite_mem_t is array (0 to 63) of std_logic_vector(3 downto 0);
  signal expected_pixels : sprite_mem_t := (
		x"F", x"F", x"F", x"F",x"F", x"F", x"F", x"F",
		x"F", x"F", x"F", x"F",x"F", x"F", x"F", x"F",
		x"F", x"F", x"F", x"F",x"F", x"F", x"F", x"F",
		x"F", x"F", x"F", x"F",x"F", x"F", x"F", x"F",
		x"F", x"F", x"F", x"F",x"F", x"F", x"F", x"F",
		x"F", x"F", x"F", x"F",x"F", x"F", x"F", x"F",
		x"F", x"F", x"F", x"F",x"F", x"F", x"F", x"F",
		x"F", x"F", x"F", x"F",x"F", x"F", x"F", x"F"
	);

	signal expected_pixel : std_logic_vector(3 downto 0);

begin

	U0 : sprite_mem port map(
		sprite_num => sprite_num,
		sprite_pixel_x => sprite_pixel_x,
    sprite_pixel_y => sprite_pixel_y,
    sprite_pixel => sprite_pixel
	);

	expected_pixel <= expected_pixels(
		to_integer(unsigned(sprite_pixel_y(2 downto 0) & sprite_pixel_x(2 downto 0))));

	process
	begin
		-- test start
		assert false report "beginning of sprite_mem test bench" severity note;
		-- test all pixels in last sprite
		for y in 0 to 7 loop
			for x in 0 to 7 loop
				assert sprite_pixel = expected_pixel
					 report "wrong pixel output: expected " &
					 				integer'image(to_integer(unsigned(expected_pixel)))
					 				& " got " &
									integer'image(to_integer(unsigned(sprite_pixel)))
									severity error;
					sprite_pixel_x <= sprite_pixel_x + 1;
					wait for 1 ns;
			end loop;
			sprite_pixel_x <= b"000";
			sprite_pixel_y <= sprite_pixel_y + 1;
			wait for 1 ns;
		end loop;
		-- test end
		assert false report "end of sprite_mem test bench" severity note;
		-- finish simulation
		wait;
	end process;

end architecture;
