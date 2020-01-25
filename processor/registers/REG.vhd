library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REG is 
  port(
       clk 		: in std_logic;
       rst 		: in std_logic;
       we_1             : in std_logic;
       data_in_1 	: in std_logic_vector(9 downto 0);
       data_out_1 	: out std_logic_vector(9 downto 0);
       addr_read_1 	: in unsigned(7 downto 0);
       addr_write_1     : in unsigned(7 downto 0);
       we_2             : in std_logic;
       data_in_2 	: in std_logic_vector(9 downto 0);
       data_out_2 	: out std_logic_vector(9 downto 0);
       addr_read_2	: in unsigned(7 downto 0);
       addr_write_2     : in unsigned(7 downto 0)
      );
end entity;
 

architecture behaviour of REG is

  type REG_t is array(0 to 31) of std_logic_vector(9 downto 0);
  signal REG_content : REG_t := (
                                others => (others => '0')
                                );

  begin
    process(clk) begin
      if rising_edge(clk) then
        if(rst = '1') then
          REG_content <= (others =>(others => '0')); 
        end if;

        if(we_1 = '1') then 
          REG_content(to_integer(addr_write_1)) <= data_in_1;
        end if;

	if(we_2 = '1') then
          REG_content(to_integer(addr_write_2)) <= data_in_2;
        end if;

        data_out_1 <= REG_content(to_integer(addr_read_1));
        data_out_2 <= REG_content(to_integer(addr_read_2));
      end if;
    end process;
  end architecture;
        


