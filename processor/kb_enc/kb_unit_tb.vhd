library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kb_unit_tb is
end kb_unit_tb;

architecture sim of kb_unit_tb is

  component kb_unit is
    port(
	  clk         		: in  std_logic;
          rst         		: in  std_logic;
          PS2KeyboardCLK	: in std_logic; 
 	  PS2KeyboardData	: in std_logic;			
          addr_read   		: in  unsigned(3 downto 0);
          data_read   		: out std_logic_vector(0 downto 0)       
	);
  end component;

  -- Test signals
  signal clk  	   		:	std_logic;
  signal rst     	   	:  	std_logic;
  signal addr_read   		:	unsigned(3 downto 0) := "0000";
  signal data_read   		: 	std_logic_vector(0 downto 0);
  signal PS2KeyboardCLK 	: 	std_logic;
  signal PS2KeyboardData 	: 	std_logic;

  -- Local signals
  signal serial_data	: 	unsigned(43 downto 0) := "00011100001001001100010000011110100011100001";  -- Signal representing serial data from keyboard (make a, make b, break a).
  signal tb_running 	: boolean := true;


  begin
    U0 : kb_unit port map(clk=>clk, rst=>rst, PS2KeyboardCLK=>PS2KeyboardCLK, PS2KeyboardData=>PS2KeyboardData, addr_read=>addr_read, data_read=>data_read);

    process
    begin
      while tb_running loop
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
      end loop;
      wait;
    end process;
	
    process
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
  
end sim;
