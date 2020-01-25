--Address decoder
--
--Used for reading/writing to a memory. This component creates the VGA_motor
--and all memory components used in the project.
--
--NOTE: when inputing an address, the address must be written as if all
--memories are a single array (i.e. address 10 in the data memory might have
--inputed address 136).
--
--Data memory     : read and write
--audio memory    : write only
--sprite memories : write only
--tile memory     : write only
--keyboard memory : read only

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AD is
	port (
		clk      		: in std_logic;
		rst      		: in std_logic;
		write 			: in std_logic;
		addr 				: in unsigned(9 downto 0);
		data_in 		: in std_logic_vector(15 downto 0);
		data_out 		: out std_logic_vector(15 downto 0);-- Address decoder. Data gotten from a memory.

		PS2KeyboardCLK	: in std_logic; 					-- Keyboard unit. USB keyboard PS2 clock.
		PS2KeyboardData : in std_logic;						-- Keyboard unit. USB keyboard PS2 data.
		audio_output 	: out std_logic;					-- Audio unit. Signal to piezo element.
		VGA_r 			: out std_logic_vector(2 downto 0);	--VGA_motor.
		VGA_g 			: out std_logic_vector(2 downto 0);	--VGA_motor.
		VGA_b 			: out std_logic_vector(1 downto 0);	--VGA_motor.
		h_sync 			: out std_logic;					--VGA_motor.
		v_sync 			: out std_logic						--VGA_motor.
	);
end entity AD;

architecture func of AD is



	--////////////////////////////////////////////
	--////////////   COMPONENTS   ////////////////
	--////////////////////////////////////////////

	component RAM is
		generic (
			addr_width : integer;
			data_width : integer;
			length     : integer
		);
		port (
			clk         : in  std_logic;
			rst         : in  std_logic;
			we      		: in  std_logic;
			addr_read   : in  unsigned(addr_width-1 downto 0);
			data_read   : out std_logic_vector(data_width-1 downto 0);
			addr_write  : in  unsigned(addr_width-1 downto 0);
			data_write  : in std_logic_vector(data_width-1 downto 0)
		);
	end component;

	component audio is
		port(
			clk         : in  std_logic;
			rst         : in  std_logic;
			we          : in  std_logic;
			output      : out std_logic;
			addr_write  : in  unsigned(0 downto 0);
			data_write  : in  std_logic_vector(2 downto 0)
		);
	end component;

	component kb_unit is
		port(
			clk			    		: in std_logic;
			rst         		: in  std_logic;										-- The reset signal.
			addr_read  			: in  unsigned(3 downto 0);					-- The input address to the memory.
			data_read       : out std_logic_vector(0 downto 0);	-- The output data on the given address, high if key is currently pressed.
			PS2KeyboardCLK	: in std_logic; 										-- USB keyboard PS2 clock.
			PS2KeyboardData : in std_logic											-- USB keyboard PS2 data.
		);
  	end component;

	component sprite_pic_mem is
		port(
			clk         						: in  std_logic;
			rst         						: in  std_logic;
			sprite_x_we          		: in  std_logic;
			sprite_x_addr_write  		: in  unsigned(4 downto 0);
			sprite_x_data_write  		: in  std_logic_vector(7 downto 0);
			sprite_y_we          		: in  std_logic;
			sprite_y_addr_write  		: in  unsigned(4 downto 0);
			sprite_y_data_write  		: in  std_logic_vector(7 downto 0);
			sprite_num_we          	: in  std_logic;
			sprite_num_addr_write  	: in  unsigned(4 downto 0);
			sprite_num_data_write  	: in  std_logic_vector(2 downto 0);

			pixel_x   							: in unsigned(9 downto 0);--
			pixel_y   							: in unsigned(9 downto 0);--
			pixel_col 							: out std_logic_vector(7 downto 0);--
			collision : out std_logic
		);
	end component;

	component tile_pic_mem is
		port(
			clk         	: in  std_logic;
			rst         	: in  std_logic;
			tile_we         : in  std_logic;
			tile_addr_write : in  unsigned(8 downto 0);
			tile_data_write : in  std_logic_vector(4 downto 0);  --

			pixel_x   		: in unsigned(9 downto 0);--
			pixel_y   		: in unsigned(9 downto 0);--
			pixel_col 		: out std_logic_vector(7 downto 0)--
		);
	end component;

	component VGA_motor is
		port (
			clk         			: in  std_logic;
			rst         			: in  std_logic;
			VGA_r 						: out std_logic_vector(2 downto 0);
			VGA_g 						: out std_logic_vector(2 downto 0);
			VGA_b 						: out std_logic_vector(1 downto 0);
			h_sync 						: out std_logic;
			v_sync 						: out std_logic;

			curr_pixel_x : out unsigned(9 downto 0);
    	curr_pixel_y : out unsigned(9 downto 0);
    	tile_pic_mem_pixel_col : in std_logic_vector(7 downto 0);
    	sprite_pic_mem_pixel_col : in std_logic_vector(7 downto 0)

		);
	end component;

	component DM is
		port(
		  clk         : in  std_logic;
		  rst         : in  std_logic;
		  we          : in  std_logic;
		  addr_read   : in  unsigned(9 downto 0);
		  data_read   : out std_logic_vector(15 downto 0);
		  addr_write  : in  unsigned(9 downto 0);
		  data_write  : in  std_logic_vector(15 downto 0)
		);
	end component;




	--//////////////////////////////////////////////////
	--////////////////   CONSTANTS    //////////////////
	--//////////////////////////////////////////////////

	--Tile memory interval
	constant TM_start : unsigned(9 downto 0) 		:= b"00_0000_0000";
	constant TM_end : unsigned(9 downto 0) 			:= b"01_0010_1011";

	--Sprite memory num interval
	constant SM_num_start : unsigned(9 downto 0)	:= b"01_0010_1100"; -- 300
	constant SM_num_end : unsigned(9 downto 0) 		:= b"01_0100_1011"; -- 331

	--Sprite memory x interval
	constant SM_x_start : unsigned(9 downto 0) 		:= b"01_0100_1100"; --332
	constant SM_x_end : unsigned(9 downto 0) 		:= b"01_0110_1011"; --363

	--Sprite memory y interval
	constant SM_y_start : unsigned(9 downto 0) 		:= b"01_0110_1100";  --364
	constant SM_y_end : unsigned(9 downto 0) 		:= b"01_1000_1011";	 --394

	--Audio memory interval
	constant AM_start : unsigned(9 downto 0) 		:= b"01_1000_1100";
	constant AM_end : unsigned(9 downto 0) 			:= b"01_1000_1100";

	--Keyboard memory interval
	constant KBM_start : unsigned(9 downto 0) 		:= b"01_1000_1101"; -- 397
	constant KBM_end : unsigned(9 downto 0) 		:= b"01_1001_0100";

	--Collision memory interval
	constant CM_start : unsigned(9 downto 0)		:= b"01_1001_0101"; -- 405
	constant CM_end : unsigned(9 downto 0)			:= b"01_1001_0101";

	--Data memory interval
	constant DM_start : unsigned(9 downto 0) 		:= b"01_1001_0110";
	constant DM_end : unsigned(9 downto 0) 			:= b"11_1111_1111";



	--//////////////////////////////////////////////////
	--/////////////////   SIGNALS    ///////////////////
	--//////////////////////////////////////////////////

	-- Signal saving old cs
	signal prev_DM, prev_KBM : std_logic := '0'; 

	--Control signals for setting data to data bus
	signal  CS_DM_write,
			CS_DM_read,
			CS_AM,
			CS_SM_num,
			CS_SM_x,
			CS_SM_y,
			CS_TM,
			CS_KBM,
			CS_CM : std_logic;

	--Write enable signals
	signal  DM_we,
			AM_we,
			TM_we,
			SM_num_we,
			SM_x_we,
			SM_y_we : std_logic;

	--signals containing memory read value
	signal DM_read : std_logic_vector(15 downto 0) := x"0000";
	signal KBM_read : std_logic_vector(15 downto 0):= x"0000";
	signal CM_read : std_logic_vector(15 downto 0) := x"0000";

	--signals for connection between VGA_motor and sprite/tile memory
	signal curr_pixel_x   : unsigned(9 downto 0);	       --
	signal curr_pixel_y   : unsigned(9 downto 0);		     --
	signal sprite_col 		: std_logic_vector(7 downto 0);  --
	signal tile_col  			: std_logic_vector(7 downto 0);--
	signal sprite_collision			: std_logic;

	--write/read addresses
	signal KBM_addr_read : unsigned(9 downto 0);
	signal CM_addr_read : unsigned(9 downto 0);
	signal DM_addr_read : unsigned(9 downto 0);
	signal DM_addr_write : unsigned(9 downto 0);
	signal AM_addr_write : unsigned(9 downto 0);
	signal SM_x_addr_write : unsigned(9 downto 0);
	signal SM_y_addr_write : unsigned(9 downto 0);
	signal SM_num_addr_write : unsigned(9 downto 0);
	signal TM_addr_write : unsigned(9 downto 0);


begin

	--///////////////////////////////////////////////
	--////////////////   PORT MAPS   ////////////////
	--///////////////////////////////////////////////
	--Data memory
	U0 : DM 
	port map (
		clk         	=> clk,
		rst         	=> rst,
		we          	=> DM_we,
		addr_read   	=> DM_addr_read,
		data_read   	=> DM_read,
		addr_write  	=> DM_addr_write,
	  	data_write  	=> data_in
	);

	--Keyboard unit
	U1 : kb_unit
	port map (
		clk             => clk,
		rst             => rst,
		addr_read       => KBM_addr_read(3 downto 0),
		data_read       => KBM_read(0 downto 0),
		PS2KeyboardCLK  => PS2KeyboardCLK,
		PS2KeyboardData => PS2KeyboardData
	);

	--Audio unit
	U2 : audio
	port map (
		clk 		=> clk,
		rst 		=> rst,
		we 			=> AM_we,
		output 		=> audio_output,
		addr_write 	=> AM_addr_write(0 downto 0),
		data_write 	=> data_in(2 downto 0)
	);

	--Sprite pic memory
	U3 : sprite_pic_mem
	port map (
		clk 					=> clk,
		rst 					=> rst,
		sprite_x_we 			=> SM_x_we,
		sprite_x_addr_write 	=> SM_x_addr_write(4 downto 0),
		sprite_x_data_write 	=> data_in(7 downto 0),
		sprite_y_we 			=> SM_y_we,
		sprite_y_addr_write 	=> SM_y_addr_write(4 downto 0),
		sprite_y_data_write 	=> data_in(7 downto 0),
		sprite_num_we 			=> SM_num_we,
		sprite_num_addr_write 	=> SM_num_addr_write(4 downto 0),
		sprite_num_data_write 	=> data_in(2 downto 0),
		pixel_x 				=> curr_pixel_x,
		pixel_y					=> curr_pixel_y,
		pixel_col				=> sprite_col,
		collision				=> sprite_collision
	);

	--Tile pic mem
	U4: tile_pic_mem
	port map (
		clk 			=> clk,
		rst 			=> rst,
		tile_we 		=> TM_we,
		tile_addr_write => TM_addr_write(8 downto 0),
		tile_data_write => data_in(4 downto 0),
		pixel_x 		=> curr_pixel_x,
		pixel_y 		=> curr_pixel_y,
		pixel_col 		=> tile_col
	);

	--VGA motor
	U5: VGA_motor
	port map (
		clk 						=> clk,
		rst 						=> rst,
		VGA_r 						=> VGA_r,
		VGA_g 						=> VGA_g,
		VGA_b 						=> VGA_b,
		h_sync 						=> h_sync,
		v_sync 						=> v_sync,
		curr_pixel_x 						=> curr_pixel_x,
		curr_pixel_y 						=> curr_pixel_y,
		tile_pic_mem_pixel_col 				=> tile_col,
		sprite_pic_mem_pixel_col			=> sprite_col
	);

	--Collision memory
	U6 : RAM
	generic map (
		addr_width  	=> 1,
		data_width  	=> 1,
		length      	=> 1
	)
	port map (
		clk         	=> clk,
		rst         	=> rst,
		we          	=> '1',
		addr_read   	=> CM_addr_read(0 downto 0),
		data_read   	=> CM_read(0 downto 0),
		addr_write  	=> "0",
	  data_write(0)  	=> sprite_collision
	);



	--//////////////////////////////////////////////
	--//////////////////   LOGIC   /////////////////
	--//////////////////////////////////////////////

	--set address relative to the memory start value
	KBM_addr_read 		<= addr  - KBM_start when CS_KBM = '1' else b"00_0000_0000";
	CM_addr_read 		<= addr  - CM_start when CS_CM = '1' else b"00_0000_0000";
	DM_addr_read 		<= addr  - DM_start when CS_DM_read = '1' else b"00_0000_0000";
	DM_addr_write 		<= addr - DM_start when CS_DM_write = '1' else b"00_0000_0000";
	AM_addr_write 		<= addr - AM_start when CS_AM = '1' else b"00_0000_0000";
	SM_x_addr_write 	<= addr - SM_x_start when CS_SM_x = '1' else b"00_0000_0000";
	SM_y_addr_write 	<= addr - SM_y_start when CS_SM_y = '1' else b"00_0000_0000";
	SM_num_addr_write 	<= addr - SM_num_start when CS_SM_num = '1' else b"00_0000_0000";
	TM_addr_write 		<= addr - TM_start when CS_TM = '1' else b"00_0000_0000";


	--Set control signals depending of value in address bus
	CS_DM_read 	<= '1' when (addr >= DM_start) and (addr <= DM_end) else '0';
	CS_DM_write <= '1' when (addr >= DM_start) and (addr <= DM_end) else '0';
	CS_AM 		<= '1' when (addr >= AM_start) and (addr <= AM_end) else '0';
	CS_TM 		<= '1' when (addr >= TM_start) and (addr <= TM_end) else '0';
	CS_SM_num 	<= '1' when (addr >= SM_num_start) and (addr <= SM_num_end) else '0';
	CS_SM_x 	<= '1' when (addr >= SM_x_start) and (addr <= SM_x_end) else '0';
	CS_SM_y 	<= '1' when (addr >= SM_y_start) and (addr <= SM_y_end) else '0';
	CS_KBM 		<= '1' when (addr >= KBM_start) and (addr <= KBM_end) else '0';
	CS_CM		<= '1' when (addr >= CM_start) and (addr <= CM_end) else '0';

	--Set write enable signals
	DM_we 		<= '1' when CS_DM_write = '1' and write = '1' else '0';
	AM_we 		<= '1' when CS_AM = '1' and write = '1' else '0';
	SM_num_we 	<= '1' when CS_SM_num = '1' and write = '1' else '0';
	SM_x_we 	<= '1' when CS_SM_x = '1' and write = '1' else '0';
	SM_y_we 	<= '1' when CS_SM_y = '1' and write = '1' else '0';
	TM_we 		<= '1' when CS_TM = '1' and write = '1' else '0';

	--either read from data mem, keyboard mem or collision mem
	data_out 	<= DM_read when prev_DM = '1' else
				   KBM_read when prev_KBM = '1' else
				   CM_read;

	process(clk)
	begin
		if rising_edge(clk) then
			prev_DM <= CS_DM_read;
			prev_KBM <= CS_KBM;
		end if;
	end process;
		

end architecture func;
