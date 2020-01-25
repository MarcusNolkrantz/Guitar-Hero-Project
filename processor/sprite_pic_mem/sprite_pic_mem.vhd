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
    sprite_y_data_write  : in  std_logic_vector(7 downto 0);
    sprite_num_we          : in  std_logic;
    sprite_num_addr_write  : in  unsigned(4 downto 0);
    sprite_num_data_write  : in  std_logic_vector(2 downto 0);

    pixel_x   : in unsigned(9 downto 0);
    pixel_y   : in unsigned(9 downto 0);
    pixel_col : out std_logic_vector(7 downto 0);
    collision : out std_logic
  );
end sprite_pic_mem;


architecture behaviour of sprite_pic_mem is

  component sprite_mem is
    port (
      index : in unsigned(8 downto 0);
      color : out std_logic_vector(7 downto 0)
    );
  end component;

  constant sprite_amount : integer := 32;

  type sprite_x_mem_t is array (0 to sprite_amount-1) of std_logic_vector(7 downto 0);
  type sprite_y_mem_t is array (0 to sprite_amount-1) of std_logic_vector(7 downto 0);
  type sprite_num_mem_t is array (0 to sprite_amount-1) of std_logic_vector(2 downto 0);

  signal sprite_x_mem : sprite_x_mem_t := (others => (others => '0'));
  signal sprite_y_mem : sprite_y_mem_t := (others => (others => '0'));
  signal sprite_num_mem : sprite_num_mem_t := (others => (others => '0'));

  signal sprite_mem_index : unsigned(8 downto 0) := (others => '0');
  signal sprite_mem_color : std_logic_vector(7 downto 0) := (others => '0');
  signal sprite_at_pixel : std_logic := '0';
  signal sprite_collision : std_logic := '0';

begin

  -- sprite memory instantiation
  U0 : sprite_mem port map(
    index => sprite_mem_index,
    color => sprite_mem_color
  );

  -- write
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        sprite_x_mem <= (others => (others => '0'));
      elsif sprite_x_we = '1' then
          sprite_x_mem(to_integer(sprite_x_addr_write)) <= sprite_x_data_write;
      end if;
    end if;
  end process;

  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        sprite_y_mem <= (others => (others => '0'));
      elsif sprite_y_we = '1' then
          sprite_y_mem(to_integer(sprite_y_addr_write)) <= sprite_y_data_write;
      end if;
    end if;
  end process;

  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        sprite_num_mem <= (others => (others => '0'));
      elsif sprite_num_we = '1' then
          sprite_num_mem(to_integer(sprite_num_addr_write)) <= sprite_num_data_write;
      end if;
    end if;
  end process;


  -- read
  process(clk)
    variable sprite_delta_x : unsigned(7 downto 0);
    variable sprite_delta_y : unsigned(7 downto 0);
    variable sprite_mem_index_var : unsigned(8 downto 0);
    variable sprite_at_pixel_var : std_logic;
    variable sprite_collision_var : std_logic;
    alias pixel_x_pos is pixel_x(9 downto 2);
    alias pixel_y_pos is pixel_y(9 downto 2);
  begin
    if rising_edge(clk) then
      -- reset variables
      sprite_mem_index_var := (others => '0');
      sprite_at_pixel_var := '0';
      sprite_collision_var := '0';

      -- set variables
      for s in 0 to sprite_amount-1 loop
        sprite_delta_x := pixel_x_pos - unsigned(sprite_x_mem(s));
        sprite_delta_y := pixel_y_pos - unsigned(sprite_y_mem(s));

        if (sprite_delta_x >= 0) and (sprite_delta_x < 8) and (sprite_delta_y >= 0) and (sprite_delta_y < 8) and not (sprite_num_mem(s) = "000") then
          -- sprite s is at current pixel
          if sprite_at_pixel_var = '0' then
            -- first sprite at pixel
            sprite_at_pixel_var := '1';
            sprite_mem_index_var := unsigned(sprite_num_mem(s)(2 downto 0)) & sprite_delta_y(2 downto 0) & sprite_delta_x(2 downto 0);
          else
            -- collision
            sprite_collision_var := '1';
          end if;
        end if;
      end loop;

      sprite_mem_index <= sprite_mem_index_var;
      sprite_at_pixel <= sprite_at_pixel_var;
      sprite_collision <= sprite_collision_var;

    end if;
  end process;

  pixel_col <= sprite_mem_color when sprite_at_pixel = '1' else (others => '0');
  collision <= sprite_collision;

end architecture;
