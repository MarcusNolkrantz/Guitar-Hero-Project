-- tile_mem.vhd
-- Tile memory. Maps tile number and pixel to a color.

library ieee;
use ieee.std_logic_1164.ALL;            -- basic IEEE library
use ieee.numeric_std.ALL;               -- IEEE library for the unsigned type

entity tile_mem is
  port(
    index     : in unsigned(10 downto 0); -- 2048 pixels
    pixel_col : out std_logic_vector(7 downto 0) -- 256 colors
  );
end tile_mem;

architecture behaviour of tile_mem is

  -- tile memory type
  -- number of pixels in memory: 8*8*32 = 2048
  -- number of bits per pixel: 4
  type tile_mem_t is array (0 to 2047) of std_logic_vector(7 downto 0);

  -- tile memory contents
  signal tile_mem_content : tile_mem_t := (
    -- default tile
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
    x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",
    -- background
    x"00",x"04",x"04",x"04",x"04",x"04",x"04",x"00",
    x"08",x"10",x"10",x"10",x"10",x"10",x"10",x"08",
    x"08",x"10",x"10",x"10",x"10",x"10",x"10",x"08",
    x"08",x"10",x"10",x"10",x"10",x"10",x"10",x"08",
    x"08",x"10",x"10",x"10",x"10",x"10",x"10",x"08",
    x"08",x"10",x"10",x"10",x"10",x"10",x"10",x"08",
    x"08",x"10",x"10",x"10",x"10",x"10",x"10",x"08",
    x"00",x"0c",x"0c",x"0c",x"0c",x"0c",x"0c",x"00",
    -- guitar
    x"25",x"25",x"25",x"25",x"25",x"25",x"25",x"25",
    x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",
    x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",
    x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",
    x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",
    x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",
    x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",x"ac",
    x"97",x"97",x"97",x"97",x"97",x"97",x"97",x"97",
    -- numbers 0-4
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"00",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"0f",x"0f",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"0f",x"0f",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    -- numbers 5-9
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"0f",x"0f",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"0f",x"0f",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"0f",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"0f",x"00",x"00",
    x"00",x"00",x"00",x"0f",x"0f",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    -- fill rest with black
    others => (others => '1')
  );


  begin
    pixel_col <= tile_mem_content(to_integer(index));
  end behaviour;
