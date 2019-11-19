library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity machine is
    port (
        CLK_100MHz : in  std_logic;
        DPSwitch : in  std_logic_vector (7 downto 0);
        Switch : in  std_logic_vector (5 downto 0);
        LED : out  std_logic_vector (7 downto 0);
        SevenSegment : out  std_logic_vector (7 downto 0);
        SevenSegmentEnable : out  std_logic_vector (2 downto 0)  
    );
    
end machine;

architecture machine_arch of machine is

    --=======================================================--
    -- CPU
    --=======================================================--    
    component cpu
        port ( 
            clk : in  std_logic;
            reset: in std_logic;
            out_reg: out std_logic_vector(7 downto 0);
            LED : out  std_logic_vector (7 downto 0)
        );
    end component;
    
    --=======================================================--
    -- Seven Segment Display
    --=======================================================--     
    component sevenseg
        port(
            value : in  std_logic_vector (11 downto 0);
            clk : in  std_logic;
            en : in  std_logic;

            segments : out  std_logic_vector (6 downto 0);
            digits : out  std_logic_vector (2 downto 0)	
        );
    end component;    
  
	signal seven_segment_enabled: std_logic := '1';
	signal output_register_data: std_logic_vector(7 downto 0) := "00000000";
    signal extended_output_register_data: std_logic_vector(11 downto 0); 

    signal clock_100MHz: std_logic;
    signal clock_3MHz: std_logic;
    signal LOCKED: std_logic;
    
    component slow_clock
    port
     (-- Clock in ports
      clkin            : in     std_logic;
      -- Clock out ports
      CLK_OUT1          : out    std_logic;
      CLK_OUT2          : out    std_logic;
      -- Status and control signals
      LOCKED            : out    std_logic
     );
    end component;
    
    signal counter: unsigned(14 downto 0);
    signal terminal: std_logic;
    signal clock_really_slow: std_logic;
    signal reset: std_logic;
begin

    slow_clock_0: slow_clock port map (
        -- Clock in ports
        clkin => CLK_100MHz,
        -- Clock out ports
        CLK_OUT1 => clock_100MHz,
        CLK_OUT2 => clock_3MHz,
        -- Status and control signals
        LOCKED => LOCKED
    );
    
    process(clock_3MHz)
    begin
        if rising_edge(clock_3MHz) then            
            counter <= counter + 1;
            if counter = "000000000000000" then
                terminal <= '1';
            else
                terminal <= '0';
            end if;
        end if;
    end process;


    bufgce_0: BUFGCE port map (
        I => clock_3MHz,
        o => clock_really_slow,
        CE => terminal
    );
    
    reset <= not Switch(0);
    
    cpu_0: cpu port map(
        clk => clock_really_slow,    
        reset => reset,
        out_reg => output_register_data,
        LED => LED
    );



    seven_segment_enabled <= DPSwitch(0);    

    extended_output_register_data <= "0000" & output_register_data;
    sevenseg_0: sevenseg port map(
        segments => SevenSegment(7 downto 1),
        digits => SevenSegmentEnable,
        en => seven_segment_enabled,
        value => extended_output_register_data,
        clk => clock_100MHz
    );
	SevenSegment(0) <= '1';


end machine_arch;

