library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AD_tb is
end AD_tb;

architecture sim of AD_tb is
	component AD is 
		port (
			clk      		: in std_logic;
			rst      		: in std_logic;
			write 			: in std_logic;
			addr_read 		: in unsigned(9 downto 0);
			data_read 		: out std_logic_vector(15 downto 0);
			addr_write 		: in unsigned(9 downto 0);
			data_write 		: in std_logic_vector(15 downto 0);-- Address decoder. Data gotten from a memory. 
				
			PS2KeyboardCLK	: in std_logic; 					-- Keyboard unit. USB keyboard PS2 clock.
			PS2KeyboardData : in std_logic;						-- Keyboard unit. USB keyboard PS2 data.
			audio_output 	: out std_logic;					-- Audio unit. Signal to piezo element.
			VGA_r 			: out std_logic_vector(2 downto 0);	--VGA_motor.
			VGA_g 			: out std_logic_vector(2 downto 0);	--VGA_motor.
			VGA_b 			: out std_logic_vector(1 downto 0);	--VGA_motor.
			h_sync 			: out std_logic;					--VGA_motor.
			v_sync 			: out std_logic						--VGA_motor.
		);
	end component;


	signal clk      		: std_logic;
	signal rst      		: std_logic;
	signal write 			: std_logic := '0';
	signal addr_write 			: unsigned(9 downto 0) := b"01_1001_0101";
	signal data_write 		: std_logic_vector(15 downto 0) := x"FFFF";
	signal addr_read 		: unsigned(9 downto 0) := b"01_1001_0101";
	signal data_read 		: std_logic_vector(15 downto 0);-- Address decoder. Data gotten from a memory. 		
	signal PS2KeyboardCLK	: std_logic; 					-- Keyboard unit. USB keyboard PS2 clock.
	signal PS2KeyboardData : std_logic;						-- Keyboard unit. USB keyboard PS2 data.
	signal audio_output 	: std_logic;					-- Audio unit. Signal to piezo element.
	signal VGA_r 			: std_logic_vector(2 downto 0);	--VGA_motor.
	signal VGA_g 			: std_logic_vector(2 downto 0);	--VGA_motor.
	signal VGA_b 			: std_logic_vector(1 downto 0);	--VGA_motor.
	signal h_sync 			: std_logic;					--VGA_motor.
	signal v_sync 			: std_logic;						--VGA_motor.


begin
	UUT : AD port map(
		clk => clk,
		rst => rst,
		write => write,
		addr_read => addr_read,
		data_read => data_read,
		addr_write => addr_write,
		data_write => data_write,
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
		for i in 0 to 450 loop
			clk <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
		end loop;
		wait; -- wait forever, will finish simulation
	end process;

	rst <= '1', '0' after 7 ns;
	
	
end architecture;



		
