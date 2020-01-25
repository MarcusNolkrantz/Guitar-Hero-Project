library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------- 4 step pipeline -------------
-- 1. Read instruction from PM. 
-- 2. Fetch from registers.
-- 3. Execute operation in ALU or read/save from memories.
-- 4. Write back to register.

-- Has support for dataforwarding between registers and
-- stalls program for a while by sending in nop instructions
-- after jump or conditional jump instructions.

-- Use tab width 2 for readable allignment.


entity pipeCPU is
	port (
		clk 								: in std_logic;													-- System clock
		rst 								: in std_logic;													-- Reset signal
    PS2KeyboardCLK			: in std_logic; 			                  -- Keyboard unit signal to USB keyboard PS2 clock
    PS2KeyboardData 		: in std_logic;				                  -- Keyboard unit signal to USB keyboard PS2 data
	  audio_output 				: out std_logic;			                  -- Audio unit signal to piezo element
		VGA_r 							: out std_logic_vector(2 downto 0);     -- Signal from VGA_motor, red color output
		VGA_g								: out std_logic_vector(2 downto 0);     -- Signal from VGA_motor, green color output
		VGA_b 							: out std_logic_vector(1 downto 0);     -- Signal from VGA_motor, blue color output
		h_sync 							: out std_logic;			                  -- Signal from VGA_motor, horizontal sync
		v_sync 							: out std_logic	                        -- Signal from VGA_motor, vertical sync
	);
end pipeCPU;

architecture func of pipeCPU is
  
  ------ Signals for reprsentation of the pipeline steps ------
  ------------------------------------------------------------
  signal IR1 	 		: unsigned(31 downto 0);
  alias IR1_op 		: unsigned(5 downto 0) is IR1(31 downto 26);			-- instruction
  alias IR1_d	 		: unsigned(7 downto 0) is IR1(25 downto 18);			-- destination
  alias IR1_a  		: unsigned(7 downto 0) is IR1(17 downto 10);			-- operand a
  alias IR1_b  		: unsigned(7 downto 0) is IR1(9 downto 2);				-- operand b
  alias IR1_i  	  : unsigned(9 downto 0) is IR1(9 downto 0);				-- immediate
  alias IR1_addr  : unsigned(9 downto 0) is IR1(9 downto 0);				-- address

  signal IR2 			: unsigned(31 downto 0);
  alias IR2_op 		: unsigned(5 downto 0) is IR2(31 downto 26);			
  alias IR2_d 		: unsigned(7 downto 0) is IR2(25 downto 18);
  alias IR2_a 		: unsigned(7 downto 0) is IR2(17 downto 10);
  alias IR2_b 		: unsigned(7 downto 0) is IR2(9 downto 2);
  alias IR2_i 		: unsigned(9 downto 0) is IR2(9 downto 0);
  alias IR2_addr 	: unsigned(9 downto 0) is IR2(9 downto 0);

  signal IR3 			: unsigned(31 downto 0);
  alias IR3_op 		: unsigned(5 downto 0) is IR3(31 downto 26);
  alias IR3_d 		: unsigned(7 downto 0) is IR3(25 downto 18);
  alias IR3_a 		: unsigned(7 downto 0) is IR3(17 downto 10);
  alias IR3_b 		: unsigned(7 downto 0) is IR3(9 downto 2);
  alias IR3_i 		: unsigned(9 downto 0) is IR3(9 downto 0);
  alias IR3_addr 	: unsigned(9 downto 0) is IR3(9 downto 0);

  signal IR4 			: unsigned(31 downto 0);
  alias IR4_op 		: unsigned(5 downto 0) is IR4(31 downto 26);
  alias IR4_d 		: unsigned(7 downto 0) is IR4(25 downto 18);
  alias IR4_a 		: unsigned(7 downto 0) is IR4(17 downto 10);
  alias IR4_b 		: unsigned(7 downto 0) is IR4(9 downto 2);
  alias IR4_i 		: unsigned(9 downto 0) is IR4(9 downto 0);
  alias IR4_addr 	: unsigned(9 downto 0) is IR4(9 downto 0);
  
  
	------- Signal for dataforwarding--------------------
  -----------------------------------------------------
  signal forward_res 			: unsigned(15 downto 0);  	-- Previous result from ALU
  signal EXEC_1 						: unsigned(9 downto 0);   -- Data 1 to ALU for certain instructions
  signal EXEC_2 						: unsigned(9 downto 0);   -- Data 2 to ALU for certain instructions
  

	
	------- Signal for handling jump and conditional 
  ------- jump instructions ----------------------
  signal jmp_mux_1 : boolean := false;
  signal jmp_mux_2 : boolean := false;
  signal jmp_mux_3 : boolean := false;


  ------ Signals for the registers ---------------
  ------------------------------------------------
  -- Port 1 --
  signal REG_we_1           : std_logic := '0';                  -- Write enable
  signal REG_data_in_1 			: std_logic_vector(9 downto 0);      -- Register data input
  signal REG_data_out_1 		: std_logic_vector(9 downto 0);      -- Register data output
  signal REG_addr_read_1    : unsigned(7 downto 0);              -- Register reading address
  signal REG_addr_write_1   : unsigned(7 downto 0);              -- Register writing address
  
  -- Port 2 --
  signal REG_we_2           : std_logic := '0';
  signal REG_data_in_2 			: std_logic_vector(9 downto 0);
  signal REG_data_out_2 		: std_logic_vector(9 downto 0);
  signal REG_addr_read_2		: unsigned(7 downto 0);
  signal REG_addr_write_2   : unsigned(7 downto 0);


  ---------- Signals for the ALU ----------------
  -----------------------------------------------
  signal ALU_A  		: unsigned(15 downto 0);    -- ALU data 1
  signal ALU_B  		: unsigned(15 downto 0);    -- ALU data 2
  signal ALU_OP 		: unsigned(3 downto 0);     -- ALU operation
  signal ALU_Y  		: unsigned(15 downto 0);    -- ALU result bits 15 downto 0
  signal ALU_H  		: unsigned(15 downto 0);    -- ALU result bits 31 downto 15
  signal ALU_flags 	: unsigned(3 downto 0);     -- ALU flags: (zero - negative - carry - overflow)


  --------- Signals for Program memory ----------
  -----------------------------------------------
  signal PM_addr 			: unsigned(9 downto 0);    -- PM address
  signal PM_data_out 	: unsigned(31 downto 0);   -- Data on corresponding address

  
  -------- Signals for Address decoder ----------
  -----------------------------------------------
  signal AD_write 	        : std_logic;                        -- Write enable
  signal AD_addr 	        	: unsigned(9 downto 0);             -- Address to read from
  signal AD_data_in        	: std_logic_vector(15 downto 0);    -- Data at corresponding address
  signal AD_data_out        : std_logic_vector(15 downto 0);    -- Data at corresponding address
  

  ------------- Internal signals ---------------
  ----------------------------------------------
  signal PC   : unsigned(9 downto 0) := B"0000010011"; -- Program counter
	signal prev_data : std_logic_vector(15 downto 0);  -- Previous data read from AD
	signal result      : unsigned(15 downto 0);



  -------------- Constants ---------------------
  ----------------------------------------------
  -- Oparations --
  constant I_NOP   : unsigned(5 downto 0) := "000000";   -- NOP 
  constant I_LD    : unsigned(5 downto 0) := "000001";   -- Load 
  constant I_LDS   : unsigned(5 downto 0) := "000010";   -- Load direct form data space
  constant I_LDI   : unsigned(5 downto 0) := "000011";   -- Load an immediate
  constant I_ST    : unsigned(5 downto 0) := "000100";   -- Store indirect 
  constant I_STS   : unsigned(5 downto 0) := "000101";   -- Store direct
  constant I_SUBI  : unsigned(5 downto 0) := "000110";   -- Subtract immediate
  constant I_LSR   : unsigned(5 downto 0) := "000111";   -- Logical shift right
  constant I_LSL   : unsigned(5 downto 0) := "001000";   -- Logical shift left
  constant I_OR    : unsigned(5 downto 0) := "001001";   -- Or 
  constant I_CMP   : unsigned(5 downto 0) := "001010";   -- Compare
  constant I_CMPI  : unsigned(5 downto 0) := "001011";   -- Compare with immediate
  constant I_JMP   : unsigned(5 downto 0) := "001100";   -- Jump
  constant I_BRNE  : unsigned(5 downto 0) := "001101";   -- Branch if not equal
  constant I_BREQ  : unsigned(5 downto 0) := "001110";   -- Branch if equal
  constant I_BRMI  : unsigned(5 downto 0) := "001111";   -- Branch if negative
  constant I_BRPL  : unsigned(5 downto 0) := "010000";   -- Branch if positiv
  constant I_SUB   : unsigned(5 downto 0) := "010001";   -- Subtract
  constant I_ADD   : unsigned(5 downto 0) := "010010";   -- Add
  constant I_ADDI  : unsigned(5 downto 0) := "010011";   -- Add with immediate
  constant I_INC   : unsigned(5 downto 0) := "010100";   -- Increase
  constant I_DEC   : unsigned(5 downto 0) := "010101";   -- Decrease
  constant I_AND   : unsigned(5 downto 0) := "010110";   -- And
  constant I_ANDI  : unsigned(5 downto 0) := "010111";   -- And with immediate
  constant I_ORI   : unsigned(5 downto 0) := "011000";   -- Or with immediate

  -- Instructions --
  constant NOP     : unsigned(31 downto 0) := X"00000000";  -- Blank instruction
  


  ------- Program memory component ----------
  -------------------------------------------
  component PM is
    port(
      addr : in unsigned(9 downto 0);
      data_out : out unsigned(31 downto 0)
      );
  end component;


  ------------ Register component -----------
  -------------------------------------------
  component REG is
    port(
       clk 						: in std_logic;
       rst 						: in std_logic;

       -- Port 1 --
       we_1       		: in std_logic;
       data_in_1 			: in std_logic_vector(9 downto 0);
       data_out_1 		: out std_logic_vector(9 downto 0);
       addr_write_1 	: in unsigned(7 downto 0);
       addr_read_1		: in unsigned(7 downto 0);

       -- Port 2 --
       we_2           : in std_logic;
       data_in_2 			: in std_logic_vector(9 downto 0);
       data_out_2 		: out std_logic_vector(9 downto 0);
       addr_read_2		: in unsigned(7 downto 0);
       addr_write_2		: in unsigned(7 downto 0)
			);
  end component;

  

  ----------- ALU component ----------
  ------------------------------------
  component ALU is
    port(
	 		A 			: in unsigned(15 downto 0);
      B 			: in unsigned(15 downto 0);
	 		OP 			: in unsigned(3 downto 0);
	 		Y 			: out unsigned(15 downto 0);
	 		H 			: out unsigned(15 downto 0);
	 		clk 		: in std_logic;
	 		rst 		: in std_logic;
      flags 	: out unsigned(3 downto 0)
      );
  end component;


  ------- Address decoder component --------
  ------------------------------------------
  component AD is 
    port( 
			clk      						: in std_logic;
			rst      						: in std_logic;
			write 							: in std_logic;
			addr 								: in unsigned(9 downto 0);
			data_in             : in std_logic_vector(15 downto 0);
			data_out						: out std_logic_vector(15 downto 0);
      PS2KeyboardCLK			: in std_logic; 			
      PS2KeyboardData 		: in std_logic;				
			audio_output 				: out std_logic;			
			VGA_r 							: out std_logic_vector(2 downto 0);
			VGA_g								: out std_logic_vector(2 downto 0);
			VGA_b 							: out std_logic_vector(1 downto 0);
			h_sync 							: out std_logic;			
			v_sync 							: out std_logic	
      );
  end component;
  

  begin	
    ----------- Port maping --------------
    --------------------------------------
    -- Program memory --
    U1 : PM port map( addr => PM_addr, 
											data_out => PM_data_out);
  
    -- Registers --
    U2 : REG port map(clk => clk, 
											rst => rst, 
											we_1 => REG_we_1, 
											we_2 => REG_we_2, 
											data_in_1 => REG_data_in_1, 
											data_in_2 => REG_data_in_2, 
		      						addr_read_1 => REG_addr_read_1, 
											addr_read_2 => REG_addr_read_2, 
											addr_write_1 => REG_addr_write_1, 
                      addr_write_2 => REG_addr_write_2, 
											data_out_1 => REG_data_out_1, 
											data_out_2 => REG_data_out_2);  

    -- ALU --
    U3 : ALU port map(clk => clk, 
											rst => rst, 
											A => ALU_A, 
											B => ALU_B, 
											OP => ALU_OP, 
											Y => ALU_Y, 
											H => ALU_H, 
											flags => ALU_flags);

    U4 : AD port map(clk => clk, 
										rst => rst, 
										write => AD_write, 
										addr => AD_addr, 
										data_in => AD_data_in, 
										data_out => AD_data_out,
                    PS2KeyboardCLK => PS2KeyboardCLK, 
										PS2KeyboardData => PS2KeyboardData, 
										audio_output => audio_output, 
										VGA_r => VGA_r, 
										VGA_g => VGA_g, 
										VGA_b => VGA_b, 
										h_sync => h_sync, 
										v_sync => v_sync);
      

	---- Update the program counter ----
  ------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
		  if (rst='1') then
		    PC <= (others => '0');
		  
		  elsif (IR1_OP = I_JMP) then
		    PC <= IR1_addr;
		 
		 elsif (IR3_OP = I_BREQ) then
		    if(ALU_flags(3) = '1') then
		      PC <= IR3_addr;
		    else
		      PC <= PC - 2;
		    end if;
		  
		 elsif (IR3_OP = I_BRNE) then
		    if(ALU_flags(3) = '0') then
		      PC <= IR3_addr;
		    else 
		      PC <= PC - 2;
		    end if;

		 elsif (IR3_OP = I_BRMI) then
		    if(ALU_flags(2) = '1') then
		      PC <= IR3_addr;
		    else 
		      PC <= PC - 2;
		    end if;
		 
		  elsif (IR3_OP = I_BRPL) then
		    if(ALU_flags(3) = '0' and ALU_flags(2) = '0') then
		      PC <= IR3_addr;
		    else 
		      PC <= PC - 2;
		    end if;
		  
		  else  
		    PC <= PC + 1;
		  end if;
		end if;
		PM_addr <= PC;
	end process;


  -- Update the instructions registers -- 
  -- in the pipeline --------------------
	process(clk)
	begin
		if rising_edge(clk) then
		  if (rst='1') then
		    IR1 <= (others => '0');
		    IR2 <= (others => '0');
		    IR3 <= (others => '0');
		    IR4 <= (others => '0');
		  elsif(jmp_mux_1 or jmp_mux_2 or jmp_mux_3) then 
		    IR2 <= IR1;
		    IR3 <= IR2;
		    IR4 <= IR3;
		    IR1 <= NOP;
		  else
		    IR2 <= IR1;
		    IR3 <= IR2;
		    IR4 <= IR3;
		    IR1 <= PM_data_out;
		  end if;
		end if;
	end process;



	--------- Assign jmp_muxes ---------
  ------------------------------------
  -- jmp_mux_1 --
	with IR1_op select 
		jmp_mux_1 <= true when I_JMP,
		             true when I_BREQ,
		             true when I_BRNE,
		             true when I_BRPL,
		             true when I_BRMI,
		             false when others;

	-- jmp_mux_2 --
	with IR2_op select 
		jmp_mux_2 <= true when I_BREQ,
		             true when I_BRNE,
		             true when I_BRPL,
		             true when I_BRMI,
		             false when others;

	-- jmp_mux_3 --
	with IR3_op select 
		jmp_mux_3 <= true when I_BREQ,
		             true when I_BRNE,
		             true when I_BRPL,
		             true when I_BRMI,
		             false when others;

	

  ----- Dataforwarding logic ------
  ---------------------------------
	
   -- Save old ALU result --
	process(clk)
	begin 
		if rising_edge(clk) then		
				forward_res <= result;
		end if;
	end process;


	result <= unsigned(AD_data_out) when (IR3_op = I_LDS or IR3_op = I_LD) else ALU_Y;  

  -- Dataforwarding for register 1 --
	process(IR2, AD_data_out, result)
  variable IR3_writes 			: boolean;                -- Does operation in IR3 write to a registerA?
  variable IR4_writes 			: boolean;                -- Does operation in IR4 write to a registerB?
	begin   
    IR3_writes := IR3_op = I_LD or IR3_op = I_LDS or IR3_op = I_LDI or IR3_op = I_SUBI or IR3_op = I_LSR or IR3_op = I_LSL or IR3_op = I_OR or IR3_op = 
								I_SUB or IR3_op = I_ADD or IR3_op = I_ADDI or IR3_op = I_INC or IR3_op = I_DEC or IR3_op = I_AND or IR3_op = I_ANDI or IR3_op = I_ORI; 
    
    IR4_writes := IR4_op = I_LD or IR4_op = I_LDS or IR4_op = I_LDI or IR4_op = I_SUBI or IR4_op = I_LSR or IR4_op = I_LSL or IR4_op = I_OR or IR4_op = 	
							I_SUB or IR4_op = I_ADD or IR4_op = I_ADDI or IR4_op = I_INC or IR4_op = I_DEC or IR4_op = I_AND or IR4_op = I_ANDI or IR4_op = I_ORI;

	
	  if(IR2_a = IR3_d and IR3_writes) then   -- If a writing instruction is in IR3 and IR2_a reads from the same register. Take current result from ALU.
				EXEC_1 <= result(9 downto 0);
	
		elsif(IR2_a = IR4_d and IR4_writes) then  -- If a writing instruction is in IR4 and IR2_a reads from the same register. Take previous result from ALU
	     EXEC_1 <= forward_res(9 downto 0);
	  
		elsif(IR2_op /= I_ST) then               -- No data forwarding for all instructions except ST.
	    EXEC_1 <= unsigned(REG_data_out_1);
		
		else																		-- No data forwarding for ST.
			EXEC_1 <= unsigned(REG_data_out_2);
	  end if;
	end process;

	-- Dataforwarwding for register 2 --
	process(IR2, result)
	variable IR3_writes 			: boolean;                -- Does operation in IR3 write to a registerA?
  variable IR4_writes 			: boolean;                -- Does operation in IR4 write to a registerB?
	begin
    
    IR3_writes := IR3_op = I_LD or IR3_op = I_LDS or IR3_op = I_LDI or IR3_op = I_SUBI or IR3_op = I_LSR or IR3_op = I_LSL or IR3_op = I_OR or IR3_op = 
								I_SUB or IR3_op = I_ADD or IR3_op = I_ADDI or IR3_op = I_INC or IR3_op = I_DEC or IR3_op = I_AND or IR3_op = I_ANDI or IR3_op = I_ORI;
    
    IR4_writes := IR4_op = I_LD or IR4_op = I_LDS or IR4_op = I_LDI or IR4_op = I_SUBI or IR4_op = I_LSR or IR4_op = I_LSL or IR4_op = I_OR or IR4_op = 	
							I_SUB or IR4_op = I_ADD or IR4_op = I_ADDI or IR4_op = I_INC or IR4_op = I_DEC or IR4_op = I_AND or IR4_op = I_ANDI or IR4_op = I_ORI;
																																	
																													
	  if(IR2_b = IR3_d and IR3_writes and IR2_op /= I_ST) then   	-- If a writing instruction is in IR3, IR2_b reads from the same register and is not STORE.
			EXEC_2 <= result(9 downto 0); 														 	-- Take current result from ALU.
    
		elsif(IR2_d = IR3_d and IR3_writes and IR2_op = I_ST) then    -- (SPECIAL CASE) If a writing instruction is in IR3, IR2_d reads from the same register 
      EXEC_2 <= result(9 downto 0);															  -- and is a STORE. Take current result from ALU.
	  
		elsif(IR2_b = IR4_d and IR4_writes and IR2_op /= I_ST) then   -- If a writing instruction is in IR4 and IR2_b reads from the same register.
	    EXEC_2 <= forward_res(9 downto 0);      										-- Take previous result from ALU.
		
		elsif(IR2_d = IR4_d and IR4_writes and IR2_op = I_ST) then  -- (SPECIAL CASE) If a writing instruction is in IR4, IR2_d reads from the same register 
      EXEC_2 <= forward_res(9 downto 0);												-- and is a STORE. Take previous result from ALU.
	  
		elsif(IR2_op /= I_ST) then							-- No data forwarding for all instructions except ST.
	    EXEC_2 <= unsigned(REG_data_out_2);
		
		else
      EXEC_2 <= unsigned(REG_data_out_1);  -- No data forwarding for ST.
	  end if;
	end process;



	------- Set ALU input -----------------
  ---------------------------------------
  -- Operation --
	with IR2_op select
		ALU_op <= "0001" when I_ADD,
		          "0001" when I_ADDI,
		          "0110" when I_OR,
		          "0110" when I_ORI,
			  			"0010" when I_SUB,
		          "0010" when I_SUBI,
		          "0101" when I_AND,
		          "0101" when I_ANDI,
		          "0001" when I_INC,
		          "0010" when I_DEC,
			  			"1000" when I_LSL,
		          "1001" when I_LSR,
		          "0010" when I_CMP,
		          "0010" when I_CMPI,
		          "1010" when I_LD,
		          "1011" when I_LDI,
		          "1010" when I_LDS, 
		          "1100" when I_ST,
		          "1100" when I_STS,
		          "0000" when others;

	
	--Data 1 --
	ALU_A <= unsigned("000000" & EXEC_1);
							

  -- Data 2 --
	with IR2_op select 
		ALU_B <= "000000" & EXEC_2 when I_ADD, 
		         "000000" & EXEC_2 when I_OR, 
		         "000000" & EXEC_2 when I_SUB, 
		         "000000" & EXEC_2 when I_AND, 
		         "000000" & EXEC_2 when I_CMP, 
		         ("000000" & IR2_I) when I_ADDI,      
		         ("000000" & IR2_I) when I_ORI,
		         ("000000" & IR2_I) when I_LSL,      
		         ("000000" & IR2_I) when I_LSR,
		         ("000000" & IR2_I) when I_SUBI,      
		         ("000000" & IR2_I) when I_ANDI,
		         ("000000" & IR2_I) when I_CMPI,
		         ("000000" & IR2_I) when I_LDI,           
		         X"0001" when I_INC,
		         X"0001" when I_DEC,         
		         X"0000" when others;


  
  ------------ Set input to registers -------------
  -------------------------------------------------
	with IR1_op select
		REG_addr_read_1 <= IR1_a when I_LD,
                       IR1_d when I_ST,
											 IR1_a when I_STS,
                       IR1_a when I_SUBI,
											 IR1_a when I_LSR,
                       IR1_a when I_LSL,
											 IR1_a when I_OR,
                       IR1_a when I_CMP,
											 IR1_a when I_CMPI,
                       IR1_a when I_SUB,
											 IR1_a when I_ADD,
                       IR1_a when I_ADDI,
											 IR1_a when I_INC,
                       IR1_a when I_DEC,
											 IR1_a when I_AND,
                       IR1_a when I_ANDI,
											 IR1_a when I_ORI,
                       X"00" when others;
	
	
  with IR1_op select
		REG_addr_read_2 <= IR1_a when I_ST,
											 IR1_b when I_OR,
											 IR1_b when I_CMP,
											 IR1_b when I_SUB,
											 IR1_b when I_ADD,
											 IR1_b when I_AND,
		                   X"00" when others;

		         
	 -- Data_in --
	with IR3_op select
		REG_data_in_1 <= std_logic_vector(ALU_Y(9 downto 0)) when I_ADD,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_ADDI,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_OR,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_ORI,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_SUB,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_SUBI,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_AND,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_ANDI,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_INC,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_DEC,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_LSL,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_LSR,
		                 std_logic_vector(ALU_Y(9 downto 0)) when I_LDI,
										 AD_data_out(9 downto 0) when I_LD,
		                 AD_data_out(9 downto 0) when I_LDS,
		                 "0000000000" when others;
  REG_data_in_2 <= "0000000000";
   
  -- Writing address --
	with IR3_op select
		REG_addr_write_1 <=  IR3_d when I_ADD,
		                     IR3_d when I_ADDI,
		                     IR3_d when I_OR,
		                     IR3_d when I_ORI,
				     						 IR3_d when I_SUB,
		                     IR3_d when I_SUBI,
		                     IR3_d when I_AND,
		                     IR3_d when I_ANDI,
		                     IR3_d when I_INC,
		                     IR3_d when I_DEC,
		                     IR3_d when I_LSL,
		                     IR3_d when I_LSR,
		                     IR3_d when I_LD,
		                     IR3_d when I_LDI,
		                     IR3_d when I_LDS,
		                     X"00" when others;
  REG_addr_write_2 <= X"00";
	
  -- Write enable _
	with IR3_op select
		REG_we_1 <=  '1' when I_ADD,
		             '1' when I_ADDI,
		             '1' when I_OR,
		             '1' when I_ORI,
		             '1' when I_SUB,
		             '1' when I_SUBI,
		             '1' when I_AND,
		             '1' when I_ANDI,
		             '1' when I_INC,
		             '1' when I_DEC,
		             '1' when I_LSL,
		             '1' when I_LSR,
		             '1' when I_LD,
		             '1' when I_LDI,
		             '1' when I_LDS,
		             '0' when others;
	REG_we_2 <= '0';

	
  --------------- Set input to Address decoder ---------------
  ------------------------------------------------------------
  -- Writing data --
  with IR2_op select 
		AD_data_in <= std_logic_vector("000000" & EXEC_1) when I_ST,
							 		std_logic_vector("000000" & EXEC_1) when I_STS,
		          	 	X"0000" when others;

  -- Writing address --
	with IR2_op select 
		AD_addr <= EXEC_2 when I_ST,
							 IR2_addr when I_STS,
							 EXEC_1 when I_LD,
							 IR2_addr when I_LDS,
		           "0000000000" when others;
  
-- Write enable --
	with IR2_op select 
		AD_write <= '1' when I_ST,
		            '1' when I_STS,
		            '0' when others;

end architecture;
