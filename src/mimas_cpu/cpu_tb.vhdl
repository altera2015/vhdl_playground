--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:02:43 11/17/2019
-- Design Name:   
-- Module Name:   /home/ise/devel/vhdl_playground/src/mimas_cpu/cpu_tb.vhdl
-- Project Name:  mimas_cpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpu
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
 
ENTITY cpu_tb IS
END cpu_tb;
 
ARCHITECTURE behavior OF cpu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu
    PORT(
         clk : IN  std_logic;
         DPSwitch : IN  std_logic_vector(7 downto 0);
         Switch : IN  std_logic_vector(5 downto 0);
         LED : OUT  std_logic_vector(7 downto 0);
         SevenSegment : OUT  std_logic_vector(7 downto 0);
         SevenSegmentEnable : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_100MHz : std_logic := '0';
   signal DPSwitch : std_logic_vector(7 downto 0) := (others => '0');
   signal Switch : std_logic_vector(5 downto 0) := (others => '0');

 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal SevenSegment : std_logic_vector(7 downto 0);
   signal SevenSegmentEnable : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant CLK_100MHz_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu PORT MAP (
          clk => CLK_100MHz,
          DPSwitch => DPSwitch,
          Switch => Switch,
          LED => LED,
          SevenSegment => SevenSegment,
          SevenSegmentEnable => SevenSegmentEnable
        );

   -- Clock process definitions
   CLK_100MHz_process :process
   begin
		CLK_100MHz <= '0';
		wait for CLK_100MHz_period/2;
		CLK_100MHz <= '1';
		wait for CLK_100MHz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_100MHz_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
