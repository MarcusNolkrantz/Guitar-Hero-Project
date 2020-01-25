-- sprite_mem.vhd
-- Sprite memory. Maps and pixel to a color.

library ieee;
use ieee.std_logic_1164.ALL;            -- basic IEEE library
use ieee.numeric_std.ALL;               -- IEEE library for the unsigned type

entity sprite_mem is
  port(
    index : in unsigned(8 downto 0); -- 8 sprites, 512 pixels
    color  : out std_logic_vector(7 downto 0) -- 256 colors
  );
end sprite_mem;

architecture behaviour of sprite_mem is

  -- sprite memory type
  -- number of pixels in memory: 8*8*8 = 512
  -- number of bits per pixel: 8
  type sprite_mem_t is array (0 to 511) of std_logic_vector(7 downto 0);

  -- tile memory contents
  signal sprite_mem_content : sprite_mem_t := (
    -- transparent sprite
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
    -- note sprites
    x"00",x"00",x"e0",x"e0",x"e0",x"e0",x"00",x"00",
    x"00",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"00",
    x"e0",x"e0",x"e0",x"ff",x"ff",x"e0",x"e0",x"e0",
    x"e0",x"e0",x"e0",x"ff",x"ff",x"e0",x"e0",x"e0",
    x"e0",x"e0",x"e0",x"9f",x"9f",x"e0",x"e0",x"e0",
    x"80",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"80",
    x"00",x"80",x"e0",x"e0",x"e0",x"e0",x"80",x"00",
    x"00",x"00",x"80",x"80",x"80",x"80",x"00",x"00",
    x"00",x"00",x"78",x"78",x"78",x"78",x"00",x"00",
    x"00",x"78",x"78",x"78",x"78",x"78",x"78",x"00",
    x"78",x"78",x"78",x"ff",x"ff",x"78",x"78",x"78",
    x"78",x"78",x"78",x"ff",x"ff",x"78",x"78",x"78",
    x"78",x"78",x"78",x"9f",x"9f",x"78",x"78",x"78",
    x"10",x"78",x"78",x"78",x"78",x"78",x"78",x"10",
    x"00",x"10",x"78",x"78",x"78",x"78",x"10",x"00",
    x"00",x"00",x"10",x"10",x"10",x"10",x"00",x"00",
    x"00",x"00",x"fc",x"fc",x"fc",x"fc",x"00",x"00",
    x"00",x"fc",x"fc",x"fc",x"fc",x"fc",x"fc",x"00",
    x"fc",x"fc",x"fc",x"ff",x"ff",x"fc",x"fc",x"fc",
    x"fc",x"fc",x"fc",x"ff",x"ff",x"fc",x"fc",x"fc",
    x"fc",x"fc",x"fc",x"9f",x"9f",x"fc",x"fc",x"fc",
    x"f4",x"fc",x"fc",x"fc",x"fc",x"fc",x"fc",x"f4",
    x"00",x"f4",x"fc",x"fc",x"fc",x"fc",x"f4",x"00",
    x"00",x"00",x"f4",x"f4",x"f4",x"f4",x"00",x"00",
    x"00",x"00",x"07",x"07",x"07",x"07",x"00",x"00",
    x"00",x"07",x"07",x"07",x"07",x"07",x"07",x"00",
    x"07",x"07",x"07",x"ff",x"ff",x"07",x"07",x"07",
    x"07",x"07",x"07",x"ff",x"ff",x"07",x"07",x"07",
    x"07",x"07",x"07",x"9f",x"9f",x"07",x"07",x"07",
    x"01",x"07",x"07",x"07",x"07",x"07",x"07",x"01",
    x"00",x"01",x"07",x"07",x"07",x"07",x"01",x"00",
    x"00",x"00",x"01",x"01",x"01",x"01",x"00",x"00",
    x"00",x"00",x"f0",x"f0",x"f0",x"f0",x"00",x"00",
    x"00",x"f0",x"f0",x"f0",x"f0",x"f0",x"f0",x"00",
    x"f0",x"f0",x"f0",x"ff",x"ff",x"f0",x"f0",x"f0",
    x"f0",x"f0",x"f0",x"ff",x"ff",x"f0",x"f0",x"f0",
    x"f0",x"f0",x"f0",x"9f",x"9f",x"f0",x"f0",x"f0",
    x"b0",x"f0",x"f0",x"f0",x"f0",x"f0",x"f0",x"b0",
    x"00",x"b0",x"f0",x"f0",x"f0",x"f0",x"b0",x"00",
    x"00",x"00",x"b0",x"b0",x"b0",x"b0",x"00",x"00",
    -- blank note
    x"00",x"00",x"97",x"97",x"97",x"97",x"00",x"00",
    x"00",x"97",x"04",x"04",x"04",x"04",x"97",x"00",
    x"97",x"04",x"00",x"00",x"00",x"00",x"04",x"97",
    x"97",x"00",x"00",x"00",x"00",x"00",x"00",x"97",
    x"97",x"00",x"00",x"00",x"00",x"00",x"00",x"97",
    x"04",x"97",x"00",x"00",x"00",x"00",x"97",x"04",
    x"00",x"04",x"97",x"97",x"97",x"97",x"04",x"00",
    x"00",x"00",x"04",x"04",x"04",x"04",x"00",x"00",
    -- blank note, pressed
    x"00",x"00",x"97",x"97",x"97",x"97",x"00",x"00",
    x"00",x"97",x"04",x"04",x"04",x"04",x"97",x"00",
    x"97",x"04",x"00",x"00",x"00",x"00",x"04",x"97",
    x"97",x"00",x"00",x"97",x"97",x"00",x"00",x"97",
    x"97",x"00",x"00",x"04",x"04",x"00",x"00",x"97",
    x"04",x"97",x"00",x"00",x"00",x"00",x"97",x"04",
    x"00",x"04",x"97",x"97",x"97",x"97",x"04",x"00",
    x"00",x"00",x"04",x"04",x"04",x"04",x"00",x"00",
    -- fill rest with transparent pixels
    others => (others => '0')
  );
  begin
    color <= sprite_mem_content(to_integer(index));
  end behaviour;
