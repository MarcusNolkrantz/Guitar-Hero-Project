library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity test is
  port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    JA      : out STD_LOGIC_VECTOR(0 downto 0)
  );
end test;

architecture behaviour of test is
	component audio is
		port(
			clk         : in  std_logic;
			rst         : in  std_logic;
			we          : in  std_logic;
			JA      : out std_logic_vector(0 downto 0);
			addr_write  : in  unsigned(0 downto 0);
			data_write  : in  std_logic_vector(2 downto 0)   
		);
	end component;



	--SIGNALS
	signal addr  : unsigned(0 downto 0) := "0";
	signal data : std_logic_vector(2 downto 0) := "001";
	signal we : std_logic := '1';
	signal e : std_logic;
begin
	U0 : audio
	port map (
		clk => clk,
		rst => rst,
		we => we, 
		JA => JA,
		addr_write => addr,
		data_write => data
	);
end architecture;
