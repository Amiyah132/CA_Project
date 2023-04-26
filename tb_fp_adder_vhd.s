LIBRARY IEEE;
USE work.CLOCKS.all;   -- Entity that uses CLOCKS
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_textio.all;
USE std.textio.all;
USE work.txt_util.all;

ENTITY tb_fp_adder1 IS

END;

ARCHITECTURE TESTBENCH OF tb_fp_adder1 IS


---------------------------------------------------------------
-- COMPONENTS
---------------------------------------------------------------

COMPONENT fp_adder 			-- In/out Ports
  port(A      : in  std_logic_vector(31 downto 0);
       B      : in  std_logic_vector(31 downto 0);
       clk    : in  std_logic;
       reset  : in  std_logic;
       start  : in  std_logic;
       done   : out std_logic;
       sum : out std_logic_vector(31 downto 0)
    
);
END COMPONENT;

COMPONENT CLOCK
	port(CLK: out std_logic);
END COMPONENT;

---------------------------------------------------------------
-- Read/Write FILES
---------------------------------------------------------------


FILE in_file : TEXT open read_mode is 	"fp_adder_Input.txt";   -- Inputs, reset, enr,enl
FILE exo_file : TEXT open read_mode is 	"fp_adder_Output.txt";   -- Expected output (binary)
FILE out_file : TEXT open  write_mode is  "fp_adder_dataout_dacus.txt";
FILE xout_file : TEXT open  write_mode is "fp_adder_TestOut_dacus.txt";
FILE hex_out_file : TEXT open  write_mode is "fp_adder_hex_out_dacus.txt";

---------------------------------------------------------------
-- SIGNALS 
---------------------------------------------------------------

  SIGNAL A: std_logic_vector(31 downto 0):= (OTHERS => 'X');
  SIGNAL B: std_logic_vector(31 downto 0):= (OTHERS => 'X');
  SIGNAL clk: std_logic;
  SIGNAL reset: std_logic;
  SIGNAL start:std_logic;
  SIGNAL done:std_logic;
  SIGNAL sum:std_logic_vector(31 downto 0):= (OTHERS => 'X');

  SIGNAL Exp_sum : std_logic_vector(31 downto 0):= (OTHERS => 'X');
  SIGNAL Test_Out_Q : STD_LOGIC:= 'X';
  SIGNAL LineNumber: integer:=0;



---------------------------------------------------------------
-- BEGIN 
---------------------------------------------------------------

BEGIN

---------------------------------------------------------------
-- Instantiate Components 
---------------------------------------------------------------


U0: CLOCK port map (CLK);
Instfp_adder: fp_adder port map (A, B, clk, reset, start, done, sum);

---------------------------------------------------------------
-- PROCESS 
---------------------------------------------------------------
PROCESS

variable in_line, exo_line, out_line, xout_line : LINE;
variable comment, xcomment : string(1 to 128);
variable i : integer range 1 to 128;
variable simcomplete : boolean; 

variable vA   : std_logic_vector(31 downto 0):= (OTHERS => 'X');
variable vB   : std_logic_vector(31 downto 0):= (OTHERS => 'X');
variable vclk   : std_logic;
variable vreset : std_logic;
variable vstart : std_logic;
variable vdone : std_logic;
variable vSpace : character;
variable vsum:std_logic_vector(31 downto 0):= (OTHERS => 'X');

variable vExp_sum : std_logic_vector(31 downto 0):= (OTHERS => 'X');
variable vTest_Out_Q : std_logic := '0';
variable vlinenumber: integer;

BEGIN

simcomplete := false;
while (not simcomplete) LOOP
  
	if (not endfile(in_file) ) then
		readline(in_file, in_line);
	else
		simcomplete := true;
	end if;

	if (not endfile(exo_file) ) then
		readline(exo_file, exo_line);
	else
		simcomplete := true;
	end if;
	
	if (in_line(1) = '-') then  --Skip comments
		next;
	elsif (in_line(1) = '.')  then  --exit Loop
	  Test_Out_Q <= 'Z';
		simcomplete := true;
	elsif (in_line(1) = '#') then        --Echo comments to out.txt
	  i := 1;
	  while in_line(i) /= '.' LOOP
		comment(i) := in_line(i);
		i := i + 1;
	  end LOOP;

	elsif (exo_line(1) = '-') then  --Skip comments
		next;
	elsif (exo_line(1) = '.')  then  --exit Loop
	  	  Test_Out_Q  <= 'Z';
		  simcomplete := true;
	elsif (exo_line(1) = '#') then        --Echo comments to out.txt
	     i := 1;
	   while exo_line(i) /= '.' LOOP
		 xcomment(i) := exo_line(i);
		 i := i + 1;
	   end LOOP;

	
	  write(out_line, comment);
	  writeline(out_file, out_line);
	  
	  write(xout_line, xcomment);
	  writeline(xout_file, xout_line);

	  
	ELSE      --Begin processing


		--read(in_line, vOp_A);
		--Op_A  <= vOp_A;

		--read(exo_line, vexp_sum );
    		--Exp_sum      <= vexp_sum;
	   read(in_line, vA); 
	   A <= vA; 
	   read (in_line,vB);
	   B  <= vB;
	   read (in_line,vreset);
	   reset <= vreset;
	   read (in_line,vstart);
	   start <= vstart;
	 
	  read(exo_line, vEXP_sum );
		exp_sum      <= vEXP_sum;
		
		
    vlinenumber :=LineNumber;
    
    write(out_line, vlinenumber);
    write(out_line, STRING'("."));
    write(out_line, STRING'("    "));

	

    CYCLE(1,CLK);
    
    Exp_sum      <= vexp_sum;
    
      
    if (exp_sum = sum) then
      Test_Out_Q <= '0';
    else
      Test_Out_Q <= 'X';
    end if;

		--vsum 	:= sum;
		vTest_Out_Q:= Test_Out_Q;
          		
		--write(out_line, vsum, left, 32);
		write(out_line, STRING'("       "));                           --ht is ascii for horizontal tab
		write(out_line,vTest_Out_Q, left, 5);                           --ht is ascii for horizontal tab
		write(out_line, STRING'("       "));                           --ht is ascii for horizontal tab
		write(out_line, vexp_sum, left, 32);
		write(out_line, STRING'("       "));                           --ht is ascii for horizontal tab
		writeline(out_file, out_line);
		print(xout_file,    str(LineNumber)& "." & "    " &    str(sum) & "          " &   str(Exp_sum)  & "          " & str(Test_Out_Q) );
	
	END IF;
	LineNumber<= LineNumber+1;

	END LOOP;
	WAIT;
	
	END PROCESS;

END TESTBENCH;

CONFIGURATION cfgfp_adder OF tb_fp_adder1 IS
	FOR TESTBENCH
		FOR Instfp_adder: fp_adder
			use entity work.fp_adder(structural);
		END FOR;
	END FOR;
END;
