library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity combined_tb is
end combined_tb;

architecture sim of combined_tb is

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

component kb_enc is
	port(
		clk 			: in std_logic;
		rst 			: in std_logic;
		PS2KeyboardCLK	        : in std_logic; 		-- USB keyboard PS2 clock
         	PS2KeyboardData		: in std_logic;			-- USB keyboard PS2 data
         	data			: out std_logic;		-- 1 when key is pressed and 0 when released.
        	addr			: out std_logic_vector(3 downto 0);	-- Keys korresponding address in kb_mem
		we 			: out std_logic
		);
end component;


signal clk  	   	:	std_logic;
signal rst     	   	:  	std_logic;
signal we_in        	:   	std_logic;
signal addr_read   	:	unsigned(3 downto 0) := "0000";
signal data_read   	: 	std_logic_vector(0 downto 0);
signal addr_write  	:    	unsigned(3 downto 0);
signal data_write  	:    	std_logic_vector(0 downto 0); 

signal PS2KeyboardCLK 	: 	std_logic;
signal PS2KeyboardData 	: 	std_logic;
signal data		:       std_logic;
signal addr		:  	std_logic_vector(3 downto 0);
signal we 		: 	std_logic;

signal serial_data	: 	unsigned(43 downto 0) := "00011100001001001100010000011110100011100001";  -- make a, make b, break a
signal tb_running : boolean := true;



type kb_mem_t is array (0 to 15) of std_logic_vector(0 downto 0);
signal expected_content : kb_mem_t := (
	"0", "1", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"
);

signal expected : std_logic_vector(0 downto 0);


begin
  U0 : kb_enc port map(clk=>clk, rst=>rst, PS2KeyboardCLK=>PS2KeyboardCLK, PS2KeyboardData=>PS2KeyboardData, data=>data, addr=>addr, we => we);
  U1 : kb_mem port map(clk => clk, rst => rst, we => we, addr_read => addr_read, data_read => data_read, addr_write => unsigned(addr), data_write(0) => data);

  expected <= expected_content(
 	 to_integer(unsigned(addr_read(3 downto 0))));

  clk_gen : process
  begin
    while tb_running loop
      clk <= '0';
      wait for 1 ns;
      clk <= '1';
      wait for 1 ns;
    end loop;
    wait;
  end process;
	
  ps2_clk : process
  begin
    for i in 0 to 1000 loop
      wait for 5 ns;
      PS2KeyboardCLK <= '1';
      PS2KeyboardData <= serial_data(43);
      serial_data <= shift_left(serial_data, 1);
      wait for 5 ns;
      PS2KeyboardCLK <= '0';  		
    end loop;
    tb_running <= false;
  end process;

  rst <= '0';
  

process
	begin
		wait for 500 ns;
		-- test start
		assert false report "beginning of combined test bench" severity note;
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
		assert false report "end of combined test bench" severity note;
		-- finish simulation
		wait;
	end process;


  
end architecture;
