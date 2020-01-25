library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kb_test_tb is
  port(
		clk			: in std_logic;
		rst         		: in  std_logic;			-- The reset signal.        addr_read  		: in  unsigned(3 downto 0);		-- The input address to the memory.
		PS2KeyboardCLK	        : in std_logic; 			-- USB keyboard PS2 clock.
 		PS2KeyboardData		: in std_logic;				-- USB keyboard PS2 data.  
		led : out std_logic_vector(5 downto 0)
	);        
  end kb_test_tb;

architecture arc of kb_test_tb is
	
end arc;
