library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VGA_motor_test_tb is
  port(
    clk : in std_logic;
    rst : in std_logic;
    VGA_r : out std_logic_vector(2 downto 0);
    VGA_g : out std_logic_vector(2 downto 0);
    VGA_b : out std_logic_vector(1 downto 0);
    h_sync : out std_logic;
    v_sync : out std_logic
  );
end VGA_motor_test_tb;

architecture behaviour of VGA_motor_test_tb is

  -- VGA motor component
  component VGA_motor
    port (
      clk                       : in  std_logic;
      rst                       : in  std_logic;
      VGA_r                     : out std_logic_vector(2 downto 0);
      VGA_g                     : out std_logic_vector(2 downto 0);
      VGA_b                     : out std_logic_vector(1 downto 0);
      h_sync                    : out std_logic;
      v_sync                    : out std_logic;
      curr_pixel_x              : out unsigned(9 downto 0);
      curr_pixel_y              : out unsigned(9 downto 0);
      tile_pic_mem_pixel_col    : in std_logic_vector(7 downto 0);
      sprite_pic_mem_pixel_col  : in std_logic_vector(7 downto 0) 
    );
  end component;

  -- tile picture memory component
  component tile_pic_mem
    port(
      clk             : in std_logic;
      rst             : in std_logic;
      tile_we         : in std_logic;
      tile_addr_write : in unsigned(8 downto 0);
      tile_data_write : in std_logic_vector(4 downto 0);
      pixel_x         : in unsigned(9 downto 0);
      pixel_y         : in unsigned(9 downto 0);
      pixel_col       : out std_logic_vector(7 downto 0)
    );
  end component;

  -- sprite picture memory component
  component sprite_pic_mem
    port(
      clk                   : in std_logic;
      rst                   : in std_logic;
      sprite_x_we           : in std_logic;
      sprite_x_addr_write   : in unsigned(4 downto 0);
      sprite_x_data_write   : in std_logic_vector(7 downto 0);
      sprite_y_we           : in std_logic;
      sprite_y_addr_write   : in unsigned(4 downto 0);
      sprite_y_data_write   : in std_logic_vector(6 downto 0);
      sprite_num_we         : in std_logic;
      sprite_num_addr_write : in unsigned(4 downto 0);
      sprite_num_data_write : in std_logic_vector(2 downto 0);
      pixel_x               : in unsigned(9 downto 0);
      pixel_y               : in unsigned(9 downto 0);
      pixel_col             : out std_logic_vector(7 downto 0)
    );
  end component;

  -- signals to send data to picture memories
  signal tile_we                : std_logic;
  signal tile_addr_write        : unsigned(8 downto 0);
  signal tile_data_write        : std_logic_vector(4 downto 0);
  signal sprite_x_we            : std_logic;
  signal sprite_x_addr_write    : unsigned(4 downto 0);
  signal sprite_x_data_write    : std_logic_vector(7 downto 0);
  signal sprite_y_we            : std_logic;
  signal sprite_y_addr_write    : unsigned(4 downto 0);
  signal sprite_y_data_write    : std_logic_vector(6 downto 0);
  signal sprite_num_we          : std_logic;
  signal sprite_num_addr_write  : unsigned(4 downto 0);
  signal sprite_num_data_write  : std_logic_vector(2 downto 0);

  -- signals between VGA motor and picture memories
  signal curr_pixel_x             : unsigned(9 downto 0);
  signal curr_pixel_y             : unsigned(9 downto 0);
  signal tile_pic_mem_pixel_col   : std_logic_vector(7 downto 0);
  signal sprite_pic_mem_pixel_col : std_logic_vector(7 downto 0);

begin

  -- VGA motor instance
  U0 : VGA_motor port map(
    clk => clk,
    rst => rst,
    VGA_r => VGA_r,
    VGA_g => VGA_g,
    VGA_b => VGA_b,
    h_sync => h_sync,
    v_sync => v_sync,
    curr_pixel_x => curr_pixel_x,
    curr_pixel_y => curr_pixel_y,
    tile_pic_mem_pixel_col => tile_pic_mem_pixel_col,
    sprite_pic_mem_pixel_col => sprite_pic_mem_pixel_col
  );

  -- tile picture memory instance
  U1 : tile_pic_mem port map(
    clk => clk,
    rst => rst,
    tile_we => tile_we,
    tile_addr_write => tile_addr_write,
    tile_data_write => tile_data_write,
    pixel_x => curr_pixel_x,
    pixel_y => curr_pixel_y,
    pixel_col => tile_pic_mem_pixel_col
  );

  -- sprite picture memory instance
  U2 : sprite_pic_mem port map(
    clk => clk,
    rst => rst,
    sprite_x_we => sprite_x_we,
    sprite_x_addr_write => sprite_x_addr_write,
    sprite_x_data_write => sprite_x_data_write,
    sprite_y_we => sprite_y_we,
    sprite_y_addr_write => sprite_y_addr_write,
    sprite_y_data_write => sprite_y_data_write,
    sprite_num_we => sprite_num_we,
    sprite_num_addr_write => sprite_num_addr_write,
    sprite_num_data_write => sprite_num_data_write,
    pixel_x => curr_pixel_x,
    pixel_y => curr_pixel_y,
    pixel_col => sprite_pic_mem_pixel_col
  );

  tile_we <= '1';
  tile_addr_write <= (others => '0');
  tile_data_write <= "00011";

  sprite_num_we <= '1';
  sprite_num_addr_write <= (others => '0');
  sprite_num_data_write <= "000";

  sprite_x_we <= '1';
  sprite_x_addr_write <= (others => '0');
  sprite_x_data_write <= (others => '0');

  sprite_y_we <= '1';
  sprite_y_addr_write <= (others => '0');
  sprite_y_data_write <= (others => '0');

  
end architecture;
