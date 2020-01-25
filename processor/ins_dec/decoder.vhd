library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder is 
  port(
       inst 	: in unsigned(31 downto 0);	-- Instruction.
       clk      : in std_logic;			-- System clk.
       rst      : in std_logic;			-- Reset signal.
       reg_1	: out unsigned(7 downto 0);	-- Register 1 fetch.
       reg_2    : out unsigned(7 downto 0);	-- Register 2 fetch.
       im_num   : out unsigned(9 downto 0)	-- Imediate number.
      );
end decoder;

architecture behaviour of decoder is

constant nop   : unsigned(5 downto 0) := "000000";
constant store : unsigned(5 downto 0) := "000001";
constant load  : unsigned(5 downto 0) := "000010";
constant add   : unsigned(5 downto 0) := "000011";
constant addi  : unsigned(5 downto 0) := "000100";

alias op  : unsigned(5 downto 0) is inst(31 downto 26);
alias d   : unsigned(7 downto 0) is inst(25 downto 18);
alias a   : unsigned(7 downto 0) is inst(17 downto 10);
alias b   : unsigned(7 downto 0) is inst(9 downto 2);
alias num : unsigned(9 downto 0) is inst(9 downto 0);

begin 
  
  process(clk)
  begin
    case op is 
      when "000011" =>  reg_1 <= a; reg_2 <= b; -- add
      when "000100" =>  reg_1 <= a; im_num <= num; --addi		
      when others => null;
    end case;
  end process;
 
end architecture;
