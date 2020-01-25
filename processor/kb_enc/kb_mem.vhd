-- The keyboard memory. Contain information about the keys
-- that currently being pressed, '1' when pressed and 
-- otherwise '0'. 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kb_mem is
  port(
    clk         : in  std_logic;			-- System clk.
    rst         : in  std_logic;			-- Restet signal.	
    we          : in  std_logic;			-- Write enable.
    addr_read   : in  unsigned(3 downto 0);		-- Address read from.
    data_read   : out std_logic_vector(0 downto 0);	-- Data that are read.
    addr_write  : in  unsigned(3 downto 0);		-- Address written to.
    data_write  : in  std_logic_vector(0 downto 0)   	-- Writing data.
  );
end kb_mem;


architecture behaviour of kb_mem is

  component RAM is
    generic (
      addr_width : integer;
      data_width : integer;
      length     : integer
    );
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;
      we      	  : in  std_logic;
      addr_read   : in  unsigned(addr_width-1 downto 0);
      data_read   : out std_logic_vector(data_width-1 downto 0);
      addr_write  : in  unsigned(addr_width-1 downto 0);
      data_write  : in std_logic_vector(data_width-1 downto 0)
    );
  end component;

  begin
    -- Keyboard memory, instance of RAM.
    U0 : RAM
    generic map (
      addr_width  => 4,
      data_width  => 1,
      length      => 16
    )
    port map(clk => clk, rst => rst, we  => we, addr_read => addr_read, data_read => data_read, addr_write => addr_write, data_write => data_write);
  
  end behaviour;
