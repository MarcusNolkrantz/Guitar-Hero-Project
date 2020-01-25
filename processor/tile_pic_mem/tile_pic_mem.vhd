-- tile_pic_mem.vhd
-- The tile picture memory is a memory read by VGA motor.
-- Each slot in memory represents a tile on the screen.
-- A tile is 8*8, the screen is 160*120 so there are 20*15=300 tiles on the screen.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tile_pic_mem is
  port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    tile_we          : in  std_logic;
    tile_addr_write  : in  unsigned(8 downto 0);
    tile_data_write  : in  std_logic_vector(4 downto 0);

    pixel_x   : in unsigned(9 downto 0);
    pixel_y   : in unsigned(9 downto 0);
    pixel_col : out std_logic_vector(7 downto 0)
  );
end tile_pic_mem;


architecture behaviour of tile_pic_mem is

  signal tile_addr_read : unsigned(8 downto 0) := (others => '0');
  signal tile_data_read : std_logic_vector(4 downto 0) := (others => '0');

  signal tile_mem_index : unsigned(10 downto 0);
  signal tile_mem_pixel_col : std_logic_vector(7 downto 0);

  component RAM is
    generic (
      addr_width : integer;
      data_width : integer;
      length     : integer
    );
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;
      we          : in  std_logic;
      addr_read   : in  unsigned(addr_width-1 downto 0);
      data_read   : out std_logic_vector(data_width-1 downto 0);
      addr_write  : in  unsigned(addr_width-1 downto 0);
      data_write  : in  std_logic_vector(data_width-1 downto 0)
    );
  end component;

  component tile_mem is
    port (
      index      : in unsigned(10 downto 0);
      pixel_col  : out std_logic_vector(7 downto 0)
    );
  end component;

begin




  -- find current tile in tile picture memory
  tile_addr_read <= to_unsigned(20, 5) * pixel_y(8 downto 5) + pixel_x(9 downto 5);
  -- choose pixel on given tile
  tile_mem_index <= unsigned(tile_data_read(4 downto 0)) & pixel_y(4 downto 2) & pixel_x(4 downto 2);
  -- output pixel color
  pixel_col <= tile_mem_pixel_col;


  -- tile memory instantiation
  U0 : tile_mem port map(
    index      => tile_mem_index,
    pixel_col  => tile_mem_pixel_col
  );

  -- instantiate a RAM component with correct values and connect to inputs and outputs
	U1 : RAM
    generic map (
      addr_width  => 9,
      data_width  => 5,
      length      => 300
    )
    port map(
      clk => clk,
      rst => rst,
      we  => tile_we,
      addr_read => tile_addr_read,
      data_read => tile_data_read,
      addr_write => tile_addr_write,
      data_write => tile_data_write
    );


end architecture;
