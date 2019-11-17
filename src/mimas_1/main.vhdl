-- Simple test bench for learning how to use the mimas board.
-- 
-- Ron Bessems <rbessems@gmail.com> 
--
-- 7 segment counts up to FFF
-- 
-- Dip switch 7 and 8 light up leds
-- Dip switch 6 turns off 7 segment display.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx primitives in this code.
--library unisim;
--use unisim.vcomponents.all;


-- These port signals are connected automatically 
-- to the UCF file names!
entity main is
	port(
		CLK_100MHz: in std_logic;
		DPSwitch: in std_logic_vector(2 downto 0);
		LED: out std_logic_vector(1 downto 0);
		SevenSegmentEnable: out std_logic_vector(2 downto 0);
		SevenSegment: out std_logic_vector(7 downto 0)
	);
end main;

architecture main_arch of main is

	component sevenseg
		port(
			value : in  STD_LOGIC_VECTOR (11 downto 0);
			clk : in  STD_LOGIC;
			en : in  STD_LOGIC;
			
			segments : out  STD_LOGIC_VECTOR (6 downto 0);
			digits : out  STD_LOGIC_VECTOR (2 downto 0)	
		);
	end component;
	
	component lights
		port (
			DIP1: in std_logic;
			DIP2: in std_logic;
			LED1: out std_logic;
			LED2: out std_logic		
		);
	end component;	

	
	signal count: std_logic_vector(22 downto 0);
	signal value: std_logic_vector(11 downto 0);	
begin	
	
	process(CLK_100MHz)
	begin
		if rising_edge(CLK_100MHz) then
			count <= std_logic_vector( unsigned(count) + 1 );
			if count = (count'range => '0') then
				value <= std_logic_vector( unsigned(value) + 1 );
			end if;	
		end if;
	end process;	
	
	sevenseg_0: sevenseg port map(
			segments => SevenSegment(7 downto 1),
			digits => SevenSegmentEnable,
			en => DPSwitch(2),
			value => value,
			clk => CLK_100MHz
		);
	SevenSegment(0) <= '1';
	
   lights_0: lights port map (        
        DIP1 => DPSwitch(0),
		  DIP2 => DPSwitch(1),
        LED1 => LED(0),
		  LED2 => LED(1)
    );
	 
	 
end main_arch;

