library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Test bench for Pipe_CPU, use tab width 2 for readable allignment.

entity pipeCPU_tb is
end pipeCPU_tb;

architecture sim of pipeCPU_tb is

component pipeCPU is
	port(
		clk 								: in std_logic;													-- System clock
		rst 								: in std_logic;													-- Reset signal
    PS2KeyboardCLK			: in std_logic; 			                  -- Keyboard unit signal to USB keyboard PS2 clock
    PS2KeyboardData 		: in std_logic;				                  -- Keyboard unit signal to USB keyboard PS2 data
	  audio_output 				: out std_logic;			                  -- Audio unit signal to piezo element
		VGA_r 							: out std_logic_vector(2 downto 0);     -- Signal from VGA_motor, red color output
		VGA_g								: out std_logic_vector(2 downto 0);     -- Signal from VGA_motor, green color output
		VGA_b 							: out std_logic_vector(1 downto 0);     -- Signal from VGA_motor, blue color output
		h_sync 							: out std_logic;			                  -- Signal from VGA_motor, horizontal sync
		v_sync 							: out std_logic	                        -- Signal from VGA_motor, vertical sync
	);
end component;

	signal clk 								: std_logic;
	signal rst 								: std_logic;
  signal PS2KeyboardCLK			: std_logic; 			                  -- Keyboard unit signal to USB keyboard PS2 clock
  signal PS2KeyboardData 		: std_logic;				                  -- Keyboard unit signal to USB keyboard PS2 data
  signal audio_output 			: std_logic;			                  -- Audio unit signal to piezo element
	signal VGA_r 							: std_logic_vector(2 downto 0);     -- Signal from VGA_motor, red color output
	signal VGA_g							: std_logic_vector(2 downto 0);     -- Signal from VGA_motor, green color output
	signal VGA_b 							: std_logic_vector(1 downto 0);     -- Signal from VGA_motor, blue color output
	signal h_sync 						: std_logic;			                  -- Signal from VGA_motor, horizontal sync
	signal v_sync 						: std_logic;          
	
begin

	U0 : pipeCPU port map(
		clk => clk,
		rst => rst,
    PS2KeyboardCLK => PS2KeyboardCLK,
    PS2KeyboardData => PS2KeyboardData,
    audio_output => audio_output,
    VGA_r => VGA_r,
    VGA_g => VGA_g,
    VGA_b => VGA_b,
    h_sync => h_sync,
    v_sync => v_sync 
	);
	
	process
	begin
	
		for i in 0 to 450000 loop
			clk <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
		end loop;
		
		wait; -- wait forever, will finish simulation
	end process;
	
	rst <= '0';
	
end architecture;
