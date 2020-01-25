library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kb_enc_tb is
end kb_enc_tb;

architecture sim of kb_enc_tb is


-- Component declaration
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

	-- Inputs
	signal clk 		: std_logic;
	signal rst 		: std_logic;
	signal PS2KeyboardCLK 	: std_logic;
	signal PS2KeyboardData 	: std_logic;
	
	-- Outputs
	signal data		: std_logic;	   			
	signal addr 		: std_logic_vector (3 downto 0);
	signal we		: std_logic;


	-- Locals
	signal serial_data	: 	unsigned(10 downto 0) :=  "00011100001";  --Start - Bits backwards - partity - stop 
	signal tb_running : boolean := true;

begin
	U0 : kb_enc port map(clk => clk, rst => rst, PS2KeyboardCLK => PS2KeyboardCLK, PS2KeyboardData => PS2KeyboardData, data => data, addr => addr, we => we);

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
	 		PS2KeyboardData <= serial_data(10);
	  		serial_data <= shift_left(serial_data, 1);
			wait for 5 ns;
	  		PS2KeyboardCLK <= '0';  		
		end loop;
		tb_running <= false;
	end process;

	rst <= '0';
	
	
	
end architecture;
