library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RAM_tb is
end RAM_tb;

architecture sim of RAM_tb is

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

  signal clk  : std_logic := '0';
  signal rst  : std_logic := '0';
  signal we   : std_logic := '0';
  signal addr_read   : unsigned(1 downto 0) := b"00";
  signal data_read   : std_logic_vector(1 downto 0);
  signal addr_write  : unsigned(1 downto 0) := b"00";
  signal data_write  : std_logic_vector(1 downto 0) := b"00";

begin

	U0 : RAM
    generic map (
      addr_width  => 2,
      data_width  => 2,
      length      => 4
    )
    port map(
		  clk => clk,
      rst => rst,
      we  => we,
      addr_read => addr_read,
      data_read => data_read,
      addr_write => addr_write,
      data_write => data_write
    );

	process
	begin

        report "read doesn't match write: expected " &
               integer'image(to_integer(to_unsigned(1, 4)- to_unsigned(11, 4)))
               severity note;
	wait;

		-- test start
		assert false report "beginning of RAM test bench" severity note;

    -- check write/read
    for i in 0 to 3 loop
      -- enable writing
      we <= '1';
      clk <= '0';
      wait for 5 ns;
      -- data should now be written and read
      clk <= '1';
      wait for 5 ns;
      -- make sure correct data is at addr
      assert data_read = data_write
        report "read doesn't match write: expected " &
               integer'image(to_integer(unsigned(data_write)))
               & " got " &
               integer'image(to_integer(unsigned(data_read)))
               severity error;
      -- change data and addresses
      data_write <= std_logic_vector(unsigned(data_write) + 1);
      addr_write <= addr_write + 1;
      addr_read  <= addr_read  + 1;

    end loop;

    -- check rst
    rst <= '1';
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;

    for i in 0 to 3 loop
      -- make sure all data is 0
      assert data_read = "00"
        report "read after rst resulted in non-zero value"
        severity error;
      addr_read  <= addr_read  + 1;
      wait for 5 ns;

    end loop;

		-- test end
		assert false report "end of RAM test bench" severity note;
		-- finish simulation
		wait;
	end process;

end architecture;
