library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REG_tb is
end REG_tb;

architecture sim of REG_tb is

component REG is
  port(
       clk         : in  std_logic;
       rst         : in  std_logic;
       we_1        : in  std_logic;
       we_2        : in std_logic;
       data_in_1   : in std_logic_vector(15 downto 0);
       data_in_2   : in std_logic_vector(15 downto 0);
       data_out_1  : out std_logic_vector(15 downto 0);
       data_out_2  : out std_logic_vector(15 downto 0);
       addr_1      : in unsigned(7 downto 0);
       addr_2      : in unsigned(7 downto 0)
      );
end component;

  signal clk         :  std_logic;
  signal rst         :  std_logic;
  signal we_1        :  std_logic;
  signal we_2        :  std_logic;
  signal data_in_1   :  std_logic_vector(15 downto 0);
  signal data_in_2   :  std_logic_vector(15 downto 0);
  signal data_out_1  :  std_logic_vector(15 downto 0);
  signal data_out_2  :  std_logic_vector(15 downto 0);
  signal addr_1      :  unsigned(7 downto 0);
  signal addr_2      :  unsigned(7 downto 0);

  signal tb_running  : boolean := true;

begin
  U0: REG port map(clk => clk, rst => rst, we_1 => we_1, we_2 => we_2, data_in_1 => data_in_1, data_in_2 => data_in_2, addr_1 => addr_1, addr_2 => addr_2);

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
  addr_1 <= "00000001";
  addr_2 <= "00000000";

end architecture;
