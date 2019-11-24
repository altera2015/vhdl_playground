----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:52:23 11/19/2019 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    port (
        CLK_100MHz : in  std_logic;
        DPSwitch : in  std_logic_vector (7 downto 0);
        Switch : in  std_logic_vector (5 downto 0);
        LED : out  std_logic_vector (7 downto 0);
        SevenSegment : out  std_logic_vector (7 downto 0);
        SevenSegmentEnable : out  std_logic_vector (2 downto 0)  
    );
end main;

architecture Behavioral of main is
begin
    LED <= "00000000";
end Behavioral;

