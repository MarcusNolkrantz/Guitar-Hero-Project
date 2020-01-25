--Audio memory. A single memory address that is three bits wide.
--Used to determine what note defined in "audio_note_mem" should be play. 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity audio_mem is
  port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    we          : in  std_logic;
    addr_read   : in  unsigned(0 downto 0);
    data_read   : out std_logic_vector(2 downto 0);
    addr_write  : in  unsigned(0 downto 0);
    data_write  : in  std_logic_vector(2 downto 0)   
  );
end audio_mem;


architecture behaviour of audio_mem is

component RAM is
  generic (
    addr_width : integer;
    data_width : integer;
    length     : integer
  );
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    we      	: in  std_logic;
    addr_read   : in  unsigned(addr_width-1 downto 0);
    data_read   : out std_logic_vector(data_width-1 downto 0);
    addr_write  : in  unsigned(addr_width-1 downto 0);
    data_write  : in std_logic_vector(data_width-1 downto 0)
  );
end component;

begin

  --Audio memory
	U0 : RAM
    generic map (
      addr_width  => 1,
      data_width  => 3,
      length      => 1
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

end architecture;
