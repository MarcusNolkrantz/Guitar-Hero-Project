--Maps input index to output note period time.

library ieee;
use ieee.std_logic_1164.ALL;            -- basic IEEE library
use ieee.numeric_std.ALL;               -- IEEE library for the unsigned type

entity audio_mem is
	port(
		audio_index      : in unsigned(2 downto 0); -- 8 notes
		time_period    : out unsigned(11 downto 0) -- amount of thousand clk ticks
	);
end audio_mem;

architecture behaviour of audio_mem is
  	-- audio memory type, 2^3 addresses, 3 bytes data
  	type audio_mem_t is array (0 to 7) of unsigned(11 downto 0);

	--audio memory content
	signal audio_mem_content : audio_mem_t := (
		x"0E3", --note A, 227 dec, 440 mHz
		x"0CA", --note B, 202 dec
		x"17E", --note C, 382 dec
		x"154", --note D, 340 dec
		x"12F", --note E, 303 dec
		x"11E", --note F, 286 dec
		x"0FF", --note G, 255 dec
		x"FFF" 
	);
begin
	time_period <= audio_mem_content(to_integer(audio_index));
end behaviour;
