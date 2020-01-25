library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder_tb is
end decoder_tb;

architecture sim of decoder_tb is
  component decoder is
    port(
	 clk         		: in  std_logic;
         rst         		: in  std_logic;
	 inst                   : in  unsigned(31 downto 0);
	 reg_1			: out unsigned(7 downto 0);	-- Register 1 fetch.
         reg_2    		: out unsigned(7 downto 0);	-- Register 2 fetch.
         im_num  		: out unsigned(9 downto 0)	-- Imediate number.
        );
  end component;
   
  signal clk         		:  std_logic;
  signal rst         		:  std_logic;
  signal inst                   :  unsigned(31 downto 0);
  signal reg_1			:  unsigned(7 downto 0);	
  signal reg_2    		:  unsigned(7 downto 0);	
  signal im_num  		:  unsigned(9 downto 0);

  signal tb_running 		: boolean := true;

  begin
    U0 : decoder port map(clk => clk, rst => rst, inst => inst, reg_1 => reg_1, reg_2 => reg_2, im_num => im_num);

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

    rst <= '0';
    inst <= "00001100000011000000100000000100";
end sim;

  
  
