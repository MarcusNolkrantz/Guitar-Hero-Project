library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type

entity kb_enc is
	port ( 
		clk	         	: in std_logic;		
		rst		        : in std_logic;		
		PS2KeyboardCLK	: in std_logic; 	
		PS2KeyboardData	: in std_logic;		
		data			: out std_logic;		
		addr			: out unsigned(3 downto 0);
		we			: buffer std_logic
	);		
end KB_ENC;


architecture behavioral of kb_enc is
	type state_type is (IDLE, MAKE, BREAK);					-- declare state types for PS2
	signal PS2state : state_type;
	signal PS2Clk			: std_logic;					-- Synchronized PS2 clock
	signal PS2Data			: std_logic;					-- Synchronized PS2 data
	signal PS2Clk_Q1		: std_logic; 
	signal PS2Clk_Q2 		: std_logic;					-- PS2 clock one pulse flip flop
	signal PS2Clk_op 		: std_logic;					-- PS2 clock one pulse 
	signal BC11				: std_logic; 
	signal PS2Data_sr 		: std_logic_vector(10 downto 0);-- PS2 data shift register 
	signal PS2BitCounter	: unsigned(3 downto 0);			-- PS2 bit counter
	signal make_q			: std_logic;					-- make one pulse flip flop
	signal make_op			: std_logic;					-- make one pulse
	signal ScanCode			: std_logic_vector(7 downto 0);	-- scan code

begin

	-- Synchronize PS2-KBD signals
	process(clk)
	begin
		if rising_edge(clk) then
			PS2Clk <= PS2KeyboardCLK;
			PS2Data <= PS2KeyboardData;
		end if;
	end process;


	-- Generate one cycle pulse from PS2 clock, negative edge
	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				PS2Clk_Q1 <= '1';
				PS2Clk_Q2 <= '0';
			else
				PS2Clk_Q1 <= PS2Clk;
				PS2Clk_Q2 <= not PS2Clk_Q1;
			end if;
		end if;
	end process;
	PS2Clk_op <= (not PS2Clk_Q1) and (not PS2Clk_Q2);


	-- PS2 data shift register
	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				PS2Data_sr <= "00000000000";
			elsif PS2Clk_op = '1' then
				PS2Data_sr <= PS2Data & PS2Data_sr(10 downto 1);
			end if;
		end if;
	end process;
	ScanCode <= PS2Data_sr(8 downto 1);


	-- PS2 bit counter
	-- The purpose of the PS2 bit counter is to tell the PS2 state machine when to change state
	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' or BC11 = '1' then
				BC11 <= '0';
				PS2BitCounter <= "0000";
			elsif PS2Clk_op = '1' then
				if PS2BitCounter = "1010" then				
					BC11 <= '1';
				else
					PS2BitCounter <= PS2BitCounter + 1;
				end if;
			end if;
		end if;
	end process;


	-- PS2 state
	-- Either MAKE or BREAK state is identified from the scancode
	-- Only single character scan codes are identified
	-- The behavior of multiple character scan codes is undefined
	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				PS2state <= IDLE;
				data <= '0';			
			elsif (PS2state = IDLE) then
				we <= '0';
				if (BC11 = '1') and ScanCode /= x"F0" then
					PS2state <= MAKE;
				elsif (BC11 = '1') and ScanCode = x"F0" then
					PS2state <= BREAK;
				end if;
			elsif PS2state = BREAK then
				if (BC11 = '1') then 
					PS2state <= IDLE;
					we <= '1';
					data <= '0';
				end if;
			elsif PS2state = MAKE then
				PS2state <= IDLE;
				data <= '1';
				we <= '1';
			end if;
		end if;
	end process;


	-- Switch statement that sets output address and data depending on
	-- the scancode and the is_break signal.
	process(ScanCode)
	begin
		case ScanCode is
			when X"15" => addr <= "0000"; -- q
			when X"1D" => addr <= "0001"; -- w
			when X"24" => addr <= "0010"; -- e
			when X"2D" => addr <= "0011"; -- r
			when X"2C" => addr <= "0100"; -- t
			when others => addr <= "0101";-- space
		end case;
	end process;

end behavioral;
