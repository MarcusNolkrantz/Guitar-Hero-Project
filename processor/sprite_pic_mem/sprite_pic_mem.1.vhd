-- sprite_pic_mem.vhd
-- The sprite picture memoory is a memory read by VGA motor.
-- There are 3 memories for each sprite: one for x position, one for y position
-- and one containing which sprite from sprite_mem to show.

-- There are 8 different sprites in sprite_mem, 32 sprites are supported on
-- screen at a time.
-- Since the screen is 160*120, the x position is 8 bits and the y position is
-- 7 bits.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sprite_pic_mem is
  port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    sprite_x_we          : in  std_logic;
    sprite_x_addr_write  : in  unsigned(4 downto 0);
    sprite_x_data_write  : in  std_logic_vector(7 downto 0);
    sprite_y_we          : in  std_logic;
    sprite_y_addr_write  : in  unsigned(4 downto 0);
    sprite_y_data_write  : in  std_logic_vector(6 downto 0);
    sprite_num_we          : in  std_logic;
    sprite_num_addr_write  : in  unsigned(4 downto 0);
    sprite_num_data_write  : in  std_logic_vector(2 downto 0);

    pixel_x   : in unsigned(9 downto 0);
    pixel_y   : in unsigned(9 downto 0);
    pixel_col : out std_logic_vector(7 downto 0)
  );
end sprite_pic_mem;


architecture behaviour of sprite_pic_mem is

  constant sprite_amount : integer := 32;

  type sprite_x_mem_t is array (0 to sprite_amount-1) of std_logic_vector(7 downto 0);
  type sprite_y_mem_t is array (0 to sprite_amount-1) of std_logic_vector(6 downto 0);
  type sprite_num_mem_t is array (0 to sprite_amount-1) of std_logic_vector(2 downto 0);

  signal sprite_x_mem : sprite_x_mem_t := (others => (others => '0'));
  signal sprite_y_mem : sprite_y_mem_t := (others => (others => '0'));
  signal sprite_num_mem : sprite_num_mem_t := (others => (others => '0'));

  signal sprite_pixel_x : unsigned(2 downto 0);
  signal sprite_pixel_y : unsigned(2 downto 0);
  signal sprite_num : unsigned(2 downto 0);
  signal sprite_pixel_col : std_logic_vector(7 downto 0);

  signal sprite_at_pixel : std_logic := '0';
  signal collision : std_logic := '0';

  component sprite_mem is
    port (
      sprite_num      : in unsigned(2 downto 0);
      sprite_pixel_x  : in unsigned(2 downto 0);
      sprite_pixel_y  : in unsigned(2 downto 0);
      sprite_pixel_col : out std_logic_vector(7 downto 0)
    );
  end component;

begin

  -- sprite memory instantiation
  U0 : sprite_mem port map(
    sprite_num => sprite_num,
    sprite_pixel_x => sprite_pixel_x,
    sprite_pixel_y => sprite_pixel_y,
    sprite_pixel_col => sprite_pixel_col
  );

  -- write
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        sprite_x_mem <= (others => (others => '0'));
        sprite_y_mem <= (others => (others => '0'));
        sprite_num_mem <= (others => (others => '0'));
      else
        if sprite_x_we = '1' then
          sprite_x_mem(to_integer(sprite_x_addr_write)) <= sprite_x_data_write;
        end if;
        if sprite_y_we = '1' then
          sprite_y_mem(to_integer(sprite_y_addr_write)) <= sprite_y_data_write;
        end if;
        if sprite_num_we = '1' then
          sprite_num_mem(to_integer(sprite_num_addr_write)) <= sprite_num_data_write;
        end if;
      end if;
    end if;
  end process;

  -- read
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        sprite_at_pixel <= '0';
        collision <= '0';
      else
        sprite_at_pixel <= '0';
        collision <= '0';
        for s in 0 to sprite_amount-1 loop
          -- check if sprite is at position (one sprite location pixel is 4x4 screen pixels)
          if pixel_x(9 downto 2) <= unsigned(sprite_x_mem(s)) and unsigned(sprite_x_mem(s)) < pixel_x(9 downto 2) + 8 and
             pixel_y(8 downto 2) <= unsigned(sprite_y_mem(s)) and unsigned(sprite_y_mem(s)) < pixel_y(8 downto 2) + 8 then
            if sprite_at_pixel = '0' then
              sprite_at_pixel <= '1';
            else
              collision <= '1';
            end if;
          end if;
        end loop;
      end if;
    end if;
  end process;

  -- choose pixel on sprite
  pixel_col <= sprite_pixel_col when sprite_at_pixel = '1' else "00000000";
  sprite_pixel_x <= pixel_x(2 downto 0); -- mod 8
  sprite_pixel_y <= pixel_y(2 downto 0); -- mod 8



end architecture;
