library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kb_mem_tb is
end kb_mem_tb;

architecture sim of kb_mem_tb is

component kb_mem is
	port(
		clk         : in  std_logic;
   	        rst         : in  std_logic;
                we          : in  std_logic;
                addr_read   : in  unsigned(3 downto 0);
                data_read   : out std_logic_vector(0 downto 0);
                addr_write  : in  unsigned(3 downto 0);
                data_write  : in  std_logic_vector(0 downto 0)
	);
end component;

	signal clk  	   :	std_logic;
        signal rst     	   :  	std_logic;
        signal we          :    std_logic;
        signal addr_read   :	unsigned(3 downto 0) := "0000";
        signal data_read   : 	std_logic_vector(0 downto 0);
        signal addr_write  :    unsigned(3 downto 0);
        signal data_write  :    std_logic_vector(0 downto 0); 

	type kb_mem_t is array (0 to 15) of std_logic_vector(0 downto 0);
	signal expected_content : kb_mem_t := (
		"1", "1", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"
	);

	signal expected : std_logic_vector(0 downto 0);

begin

	U0 : kb_mem port map(
		clk => clk,
		rst => rst,
    		we => we,
    		addr_read => addr_read,
		data_read => data_read,
		addr_write => addr_write,
		data_write => data_write
	);

	expected <= expected_content(
		to_integer(unsigned(addr_read(3 downto 0))));

	process
	begin
		-- test start
		assert false report "beginning of kb_mem test bench" severity note;
		-- test all memory locations
		for i in 0 to 15 loop
			assert data_read = expected
				 report "wrong output: expected " &
				 				integer'image(to_integer(unsigned(expected)))
				 				& " got " &
								integer'image(to_integer(unsigned(data_read)))
								severity error;
				addr_read <= addr_read + 1;
				wait for 1 ns;
		end loop;
			
		-- test end
		assert false report "end of sprite_mem test bench" severity note;
		-- finish simulation
		wait;
	end process;

end architecture;
