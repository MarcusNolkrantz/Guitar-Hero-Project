library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- ALU that handles operations on 16 bit vectors.
-- Use tab width 2 for readable allignment.

entity ALU is
	port(
		A 		: in unsigned(15 downto 0);      -- Data 1
		B 		: in unsigned(15 downto 0);      -- Data 2
		OP 		: in unsigned(3 downto 0);       -- Operation
		Y 		: out unsigned(15 downto 0);     -- Result 15 downto 0
		H 		: out unsigned(15 downto 0);     -- Result 31 downto 15
		clk 	: in std_logic;                	 -- Sytem clk
		rst 	: in std_logic;                  -- Reset signal
    flags : out unsigned(3 downto 0)       -- Flags (Z-N-C-V)
	);
end ALU;


architecture func of ALU is

signal R : unsigned(31 downto 0) := X"00000000";   -- Result
signal Zc, Nc, Cc, Vc : std_logic;                 -- Temp flags
signal Z, N, C, V : std_logic;                     -- Flags

begin

  ---------- Calculate result ----------------------------------
  --------------------------------------------------------------
	process(OP, A, B)
	begin
		case OP is
			when "0000" => R <= (others => '0'); -- No op
			when "0001" => R(16 downto 0) <= ('0' & A) + ('0' & B);  R(31 downto 17) <= (others => '0');-- a+b
			when "0010" => R(16 downto 0) <= ('0' & A) - ('0' & B);  R(31 downto 17) <= (others => '0');-- a-b
			when "0011" => R <= A * B; -- unsigned mul
			when "0100" => R <= unsigned(signed(A) * signed(B)); -- signed mul
			when "0101" => R(15 downto 0) <=  (A and B); R(31 downto 16) <= (others => '0'); -- and
			when "0110" => R(15 downto 0) <= (A or B);  R(31 downto 16) <= (others => '0');-- or
			when "0111" => R(15 downto 0) <= (A xor B);  R(31 downto 16) <= (others => '0'); -- xor
			when "1000" => R(15 downto 0) <= A sll to_integer(B);  R(31 downto 16) <= (others => '0'); -- lsl
			when "1001" => R(15 downto 0) <= A srl to_integer(B);  R(31 downto 16) <= (others => '0'); --lsr
		  when "1010" => R(15 downto 0) <= A;  R(31 downto 16) <= (others => '0'); -- Pass A through ALU.
		  when "1011" => R(15 downto 0) <= B;  R(31 downto 16) <= (others => '0'); -- Pass B through ALU.
		  when "1100" => R(31 downto 0) <= B & A;  -- Pass through A and B.
			when others => R <= (others => '0'); -- No op;
		end case;
	end process;

  -------------- Calculate flags --------------------------------------------
  --------------------------------------------------------------------------
	Zc <= '1' when R(15 downto 0) = 0 else '0';
--and ((OP = "0011") or (OP = "0100")) else --mul or muls
--		'1' when R(15 downto 0) = 0 and (OP /= "0011") and (OP /= "0100") else -- not mul or muls
--		'0';
	Nc <= R(31) when ((OP = "0011") or (OP = "0100")) else -- not mul or muls
		R(15);

	Cc <= R(31) when ((OP = "0011") or (OP = "0100")) else -- not mul or muls
		R(16);
	Vc <= (not A(15) and not B(15) and R(15)) or (A(15) and B(15) and not R(15)) when (OP = "0001") else -- when add
		(not A(15) and B(15) and R(15)) or (A(15) and not B(15) and not R(15)) when (OP = "0010") else -- when sub '0'
		'0';


  ----------- Assign flag values depending on instruction -------
  ---------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
		        Y <= R(15 downto 0);
		        H <= R(31 downto 16);
			if(rst = '1') then
				Z <= '0'; N <= '0'; C <= '0'; V <= '0';
			else
				case op is
					when "0000" => null;
					when "0001" => Z <= Zc; N <= Nc; C <= Cc; V <= Vc;
					when "0010" => Z <= Zc; N <= Nc; C <= Cc; V <= Vc;
					when "0011" => Z <= Zc; N <= Nc; C <= Cc;
					when "0100" => Z <= Zc; N <= Nc; C <= Cc;
					when "0101" => Z <= Zc; N <= Nc;
					when "0110" => Z <= Zc; N <= Nc;
					when "0111" => Z <= Zc; N <= Nc;
					when "1000" => Z <= Zc; N <= Nc;
					when others => null;

				end case;
			end if;
		end if;
	end process;
		    flags <= Z & N & C & V;
end architecture;
