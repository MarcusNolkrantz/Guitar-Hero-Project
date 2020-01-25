-- VGA_motor.vhd
-- Drives the VGA monitor. Needs to be connected to parts of the
-- tile_pic_mem and sprite_pic_mem.


library ieee;
use ieee.std_logic_1164.ALL;            -- basic IEEE library
use ieee.numeric_std.ALL;               -- IEEE library for the unsigned type

entity VGA_motor is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;

    VGA_r : out std_logic_vector(2 downto 0);
    VGA_g : out std_logic_vector(2 downto 0);
    VGA_b : out std_logic_vector(1 downto 0);
    h_sync : out std_logic;
    v_sync : out std_logic;

    curr_pixel_x : out unsigned(9 downto 0);
    curr_pixel_y : out unsigned(9 downto 0);
    tile_pic_mem_pixel_col : in std_logic_vector(7 downto 0);
    sprite_pic_mem_pixel_col : in std_logic_vector(7 downto 0)
  );
end entity;

architecture behaviour of VGA_motor is

  -- signals for VGA motor
  signal pixel_x : unsigned(9 downto 0) := (others => '0'); -- horizontal pixel counter
  signal pixel_y : unsigned(9 downto 0) := (others => '0'); -- vertical pixel counter
  signal clk_div : unsigned(1 downto 0) := (others => '0'); -- clock divisor, generates 25MHz signal
  signal clk_25  : std_logic := '0';            -- 25MHz clock

  signal blank   : std_logic := '0'; -- blanking signal
  signal color    : std_logic_vector(7 downto 0) := (others => '0'); -- color to use for current pixel

begin

  -- clock divisor, generate clk_25
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        clk_div <= (others => '0');
      else
        clk_div <= clk_div + 1;
      end if;
    end if;
  end process;

  clk_25 <= '1' when clk_div = 3 else '0';

  -- horizontal pixel counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pixel_x <= (others => '0');
      elsif clk_25 = '1' then
        if pixel_x = 799 then
          pixel_x <= (others => '0');
        else
          pixel_x <= pixel_x + 1;
        end if;
      end if;
    end if;
  end process;
  curr_pixel_x <= pixel_x;

  -- vertical pixel counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pixel_y <= (others => '0');
      elsif clk_25 = '1' then
        if pixel_y = 521 then
          pixel_y <= (others => '0');
        elsif pixel_x = 799 then
          pixel_y <= pixel_y + 1;
        end if;
      end if;
    end if;
  end process;
  curr_pixel_y <= pixel_y;

  -- horizontal sync
  h_sync <= '1' when pixel_x >= 656 and pixel_x < 752 else
            '0';

  -- vertical sync
  v_sync <= '1' when pixel_y >= 490 and pixel_y < 492 else
            '0';

  -- blank
  blank <= '1' when pixel_x > 640 or pixel_y > 480 else
           '0';

  -- determine color
  process(clk)
  begin
    if rising_edge(clk) then
      if blank = '0' then
        -- get color from sprite if it is not transparent
        if not(sprite_pic_mem_pixel_col = "00000000") then
          color <= sprite_pic_mem_pixel_col;
        else
          color <= tile_pic_mem_pixel_col;
        end if;
      else
        color <= (others => '0');
      end if;
    end if;
  end process;

  VGA_r(2 downto 0) <= color(7 downto 5);
  VGA_g(2 downto 0) <= color(4 downto 2);
  VGA_b(1 downto 0) <= color(1 downto 0);


end architecture;
