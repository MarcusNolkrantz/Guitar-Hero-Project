library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kb_test is
  port(
		clk			: in std_logic;
		rst         		: in  std_logic;			-- The reset signal.        addr_read  		: in  unsigned(3 downto 0);		-- The input address to the memory.
		PS2KeyboardCLK	        : in std_logic; 			-- USB keyboard PS2 clock.
 		PS2KeyboardData		: in std_logic;				-- USB keyboard PS2 data.  
		led : out std_logic_vector(5 downto 0)
	);        
  end kb_test;

architecture arc of kb_test is

	component kb_unit is
		port(
			clk			: in std_logic;
			rst         		: in  std_logic;			-- The reset signal.
        	addr_read  		: in  unsigned(3 downto 0);		-- The input address to the memory.
        	data_read   		: out std_logic_vector(0 downto 0);	-- The output data on the given address, high if key is currently pressed.
			PS2KeyboardCLK	        : in std_logic; 			-- USB keyboard PS2 clock.
 			PS2KeyboardData		: in std_logic				-- USB keyboard PS2 data.  
		);        
	end component;

	constant addr_max : unsigned(3 downto 0) := b"0101";
	constant counter_max : unsigned(15 downto 0) := x"FFFF";

	signal addr : unsigned(3 downto 0);	
	signal data : std_logic_vector(0 downto 0);
	signal counter : unsigned(15 downto 0) := x"0000";

begin

	u0 : kb_unit 
	port map (
		clk => clk,
		rst => rst,
		addr_read => addr,
		data_read => data,
		PS2KeyboardCLK => PS2KeyboardCLK,
		PS2KeyboardData => PS2KeyboardData
	);
	
	led(0) <= '1' when addr = b"0000" and data = "1" else '0';
	led(1) <= '1' when addr = b"0001" and data = "1" else '0';
	led(2) <= '1' when addr = b"0010" and data = "1" else '0';
	led(3) <= '1' when addr = b"0011" and data = "1" else '0';
	led(4) <= '1' when addr = b"0100" and data = "1" else '0';
	led(5) <= '1' when addr = b"0101" and data = "1" else '0';

	process(clk)
  	begin
    	if rising_edge(clk) then
      		if (counter = counter_max) then
				counter <= x"0000";
				if (addr = addr_max) then
					addr <= b"0000";
				else
					addr <= addr + 1;
				end if;
			else
				counter <= counter +1;
      		end if;
    	end if;
  end process;
	
end arc;
