--Audio memory. A single memory address that is three bits wide.
--                                audio.vhd
--              audio_mem ---> audio_map_mem ---> audio_motor ---> "hardware output"
--
--                   
--
--TODO: set output to output-pin
-- 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity audio is
  port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    we          : in  std_logic;
    output      : out std_logic;
    addr_write  : in  unsigned(0 downto 0);
    data_write  : in  std_logic_vector(2 downto 0)   
  );
end audio;




architecture behaviour of audio is

	--RAM decl
	component RAM is
	  generic (
		addr_width : integer;
		data_width : integer;
		length     : integer
	  );
	  port (
		clk         : in  std_logic;
		rst         : in  std_logic;
		we      	: in  std_logic;
		addr_read   : in  unsigned(addr_width-1 downto 0);
		data_read   : out std_logic_vector(data_width-1 downto 0);
		addr_write  : in  unsigned(addr_width-1 downto 0);
		data_write  : in std_logic_vector(data_width-1 downto 0)
	  );
	end component;

	--AUDIO_MAP_MEM decl
	component audio_map_mem is 
		port(
			audio_index    : in std_logic_vector(2 downto 0); -- 8 notes
			time_period    : out unsigned(11 downto 0) -- amount of thousand clk ticks
		);
	end component;

	--AUDIO_MOTOR decl
	component audio_motor is 
		port(
			clk         : in  std_logic;
			rst         : in  std_logic;
			time_period : in unsigned(11 downto 0);
			output      : out std_logic
		);
	end component;



	--SIGNALS
	signal audio_index  : std_logic_vector(2 downto 0);
	signal time_period  : unsigned(11 downto 0);
	signal addr_read : unsigned(0 downto 0);



begin

	--RAM inst
	U0 : RAM
	generic map (
		addr_width  => 1,
		data_width  => 3,
		length      => 1
	)
	port map (
		clk         => clk,
		rst         => rst,
		we          => we,
		addr_read   => addr_read,
		data_read   => audio_index,
		addr_write  => addr_write,
	    data_write  => data_write 
	);

	--AUDIO_MAP_MEM inst
	U1 : audio_map_mem
	port map (
		audio_index => audio_index,
		time_period => time_period
	);
	
	--AUDIO_MOTOR inst
	U2 : audio_motor
	port map (
		clk         => clk,
		rst         => rst,
		time_period => time_period,
		output      => output
	);
end architecture;
