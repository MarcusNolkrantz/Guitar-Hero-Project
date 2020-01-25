library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kb_unit is
  port(
	clk			: in std_logic;
	rst         		: in  std_logic;			-- The reset signal.
        addr_read  		: in  unsigned(3 downto 0);		-- The input address to the memory.
        data_read   		: out std_logic_vector(0 downto 0);	-- The output data on the given address, high if key is currently pressed.
	PS2KeyboardCLK	        : in std_logic; 			-- USB keyboard PS2 clock.
 	PS2KeyboardData		: in std_logic				-- USB keyboard PS2 data.  
	);        
  end kb_unit;

architecture arc of kb_unit is
  component kb_mem
    port(
	  clk         : in  std_logic;					-- System clk.
          rst         : in  std_logic;					-- Rst signal.
          we          : in  std_logic;					-- Write enable.
          addr_read   : in  unsigned(3 downto 0);			-- Read address.
          data_read   : out std_logic_vector(0 downto 0);		-- The output data on the given address, high if key is currently pressed.
          addr_write  : in  unsigned(3 downto 0);			-- Write address.
          data_write  : in  std_logic_vector(0 downto 0)		-- Write data.
	);
  end component;

  component kb_enc
    port(
	  clk 			: in std_logic;				-- System clk.
	  rst 			: in std_logic;				-- Rst signal.
       	  PS2KeyboardCLK	: in std_logic; 			-- USB keyboard PS2 clock.
	  PS2KeyboardData	: in std_logic;				-- USB keyboard PS2 data.
          data			: out std_logic;			-- 1 when key is pressed and 0 when released.
          addr			: out unsigned(3 downto 0);	-- Address to keys korresponding address in kb_mem.
	  we 			: out std_logic				-- Write enable, yes or no.
	);
  end component;

  -- Intermediate signals between keyboard encoder and keyboard memory
  signal data_s			: std_logic;				
  signal addr_s 		: unsigned(3 downto 0);		
  signal we_s			: std_logic;				

  begin
    -- Keyboard encoder component
    U0 : kb_enc port map(clk=>clk, rst=>rst, PS2KeyboardCLK=>PS2KeyboardCLK, PS2KeyboardData=>PS2KeyboardData, data=>data_s, addr=>addr_s, we => we_s);
    
    -- Keyboard memory component
    U1 : kb_mem port map(clk => clk, rst => rst, we => we_s, addr_read => addr_read, data_read => data_read, addr_write => addr_s, data_write(0) => data_s);
 
  
end arc;
