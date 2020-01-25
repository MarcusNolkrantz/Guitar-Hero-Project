-- RAM.vhd
-- Generic "twin-port" Random Access Memory.
-- Allows reading from one address and writing to one address at the same time.
-- Write enable must be set to 1 for data to be written.
-- Reading and writing is synchronized.


library ieee;
use ieee.std_logic_1164.ALL;            -- basic IEEE library
use ieee.numeric_std.ALL;               -- IEEE library for the unsigned type

entity RAM is
  generic (
    addr_width : integer  := 8;   -- number of bits in addresses (number of addresses can be deduced from this)
    data_width : integer  := 8;   -- number of bits per data row
    length     : integer  := 256  -- number of rows in memory
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
end entity;

architecture behaviour of RAM is

  -- constant length : integer := 2**addr_width; -- number of addresses
  type RAM_t is array (0 to length-1) of std_logic_vector(data_width-1 downto 0);
  signal RAM_content : RAM_t := (others => (others => '0'));

begin
  -- write
  process(clk) begin
    if rising_edge(clk) then
      if we = '1' then
        -- write data_write to addr_write
	--if addr_write < length then
          RAM_content(to_integer(addr_write)) <= data_write;
        --end if;
      --else
	  -- read
	--if addr_read < length then
	--  data_read <= RAM_content(to_integer(addr_read));
	--else 
	--  data_read <= 	(others => '0');
       -- end if;
	end if;	
	data_read <= RAM_content(to_integer(addr_read));
    end if;
  end process;


end architecture;
