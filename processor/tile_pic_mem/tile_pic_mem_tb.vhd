library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tile_pic_mem_tb is
end tile_pic_mem_tb;

architecture sim of tile_pic_mem_tb is

  component tile_pic_mem is
  	port(
      clk         : in  std_logic;
      rst         : in  std_logic;
      tile_we          : in  std_logic;
      tile_addr_write  : in  unsigned(8 downto 0);
      tile_data_write  : in  std_logic_vector(5 downto 0);

      pixel_x   : in unsigned(9 downto 0);
      pixel_y   : in unsigned(8 downto 0);
      pixel_col : out std_logic_vector(3 downto 0)
  	);
  end component;

  signal clk : std_logic;
  signal rst : std_logic;
  signal tile_we : std_logic;
  signal tile_addr_write : unsigned(8 downto 0);
  signal tile_data_write : std_logic_vector(5 downto 0);

  signal pixel_x   : unsigned(9 downto 0);
  signal pixel_y   : unsigned(8 downto 0);
  signal pixel_col : std_logic_vector(3 downto 0);

begin

	U0 : tile_pic_mem port map(
    clk => clk,
    rst => rst,
    tile_we => tile_we,
    tile_addr_write => tile_addr_write,
    tile_data_write => tile_data_write,
    pixel_x => pixel_x,
    pixel_y => pixel_y,
    pixel_col => pixel_col
	);

	process
	begin
		-- test one row of tile_pic_mem
		assert false report "beginning of tile_pic_mem test bench" severity note;

		-- some initial values
    tile_we <= '1';
    tile_addr_write <= (others => '0');
    tile_data_write <= "111111"; -- last tile is test tile

    pixel_x <= (others => '0');
    pixel_y <= (others => '0');

    -- write tiles to memory
    for t in 0 to 79 loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
      tile_addr_write <= tile_addr_write + 1;
    end loop;
    wait for 5 ns;

    -- make sure the correct color is outputted from the tile_pic_mem
    for y in 0 to 7 loop
      for x in 0 to 639 loop
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        pixel_x <= pixel_x + 1;
      end loop;
      pixel_y <= pixel_y + 1;
      pixel_x <= (others => '0');
    end loop;

		-- test end
		assert false report "end of tile_pic_mem test bench" severity note;
		-- finish simulation
		wait;
	end process;

end architecture;
