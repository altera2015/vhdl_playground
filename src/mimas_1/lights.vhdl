library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lights is
	port(
		DIP1: in std_logic;
		DIP2: in std_logic;
		LED1: out std_logic;
		LED2: out std_logic
	);
end lights;

architecture Behavioral of lights is
begin
	LED1 <= not DIP1;
	LED2 <= not DIP2;

end Behavioral;

