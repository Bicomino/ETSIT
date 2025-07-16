--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:48:15 09/20/2024
-- Design Name:   
-- Module Name:   /home/ise/P1ADH/testbench_mult_sec.vhd
-- Project Name:  P1ADH
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mult_sec
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testbench_mult_sec IS
END testbench_mult_sec;
 
ARCHITECTURE behavior OF testbench_mult_sec IS 
 
    COMPONENT mult_sec
	PORT(-- inbus  : IN std_logic_vector(7 downto 0);
			inbus_Q : in std_logic_vector(15 downto 0);
			inbus_M : in std_logic_vector(31 downto 0);
		   i      : IN std_logic;
		   -- weq    : IN std_logic;
		   -- wem    : IN std_logic;
		   rst    : IN std_logic;
		   clk    : IN std_logic;          
		   -- outbus : OUT std_logic_vector(15 downto 0)
			outbus : OUT std_logic_vector(47 downto 0));
	END COMPONENT;

	-- SIGNAL inbus :  std_logic_vector(7 downto 0):="00000000";
	SIGNAL inbus_Q : std_logic_vector(15 downto 0):="0000000000000000";
	SIGNAL inbus_M : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	-- SIGNAL outbus :  std_logic_vector(15 downto 0);
	SIGNAL outbus :  std_logic_vector(47 downto 0);
	SIGNAL i :  std_logic:='0';
	-- SIGNAL weqm :  std_logic:='0';
	-- SIGNAL wemm :  std_logic:='0';
	SIGNAL rst :  std_logic:='1';
	SIGNAL clk :  std_logic:='0';

	constant periodo: time := 100 ns;
 
BEGIN
 
uut: mult_sec PORT MAP(
		-- inbus => inbus,
		inbus_Q => inbus_Q,
		inbus_M => inbus_M,
		outbus => outbus,
		i => i,
		-- weq => weqm,
		-- wem => wemm,
		rst => rst,
		clk => clk 	);

	clk <= not clk after periodo/2;

-- Asignacion secuencial de estimulos
   tb : PROCESS
   BEGIN		
      rst <= '1';					--reset inicial
	   wait for 2*periodo;
	   rst <= '0';					--desactivamos el reset
		
		-- PRUEBA
		
	   wait for 2*periodo;
		inbus_M <= "00000000000000001000000000000001"; -- operando M = 32769 (65538 = 2^16 + 2¹)
		inbus_Q <= "0000000000000010"; -- operando Q = 2
		wait for 1*periodo;
	   I <= '1';					  --inicio de la multiplicacion
	   wait for periodo;
	   I <= '0';
	   -- wait for 16*periodo; -- resultado aparece tras 16 ciclos
      wait for 24*periodo;

      wait;
   end process;

END;
