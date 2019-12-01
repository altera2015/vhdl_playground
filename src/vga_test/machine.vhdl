library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity machine is
    port ( clk_100mhz : in std_logic;
           hsync : out  std_logic;
           vsync : out  std_logic;
           red : out  std_logic_vector (2 downto 0);
           green : out  std_logic_vector (2 downto 0);
           blue : out  std_logic_vector (2 downto 1));
end machine;

architecture machine_arch of machine is

    component vga
        generic (
            
            H_VISIBLE       : integer := 800;
            H_FRONT_PORCH   : integer := 56;
            H_SYNC_PULSE    : integer := 120;
            H_BACK_PORCH    : integer := 64;
        
            V_VISIBLE       : integer := 600;
            V_FRONT_PORCH   : integer := 37;
            V_SYNC_PULSE    : integer := 6;
            V_BACK_PORCH    : integer := 23
            
        );
        port (
            clk      : in std_logic; -- expecting 100MHz.
            h_sync_n : out std_logic;
            v_sync_n : out std_logic;
            x        : out unsigned(9 downto 0);
            y        : out unsigned(9 downto 0);
            blank    : out std_logic  
        );
    
    end component;

    signal x: unsigned(9 downto 0);
    signal y: unsigned(9 downto 0);
    signal blank: std_logic;

begin
    
    vga_0: vga port map (
       clk => clk_100mhz,
       h_sync_n => hsync,
       v_sync_n => vsync,
       x => x,
       y => y,
       blank => blank
    );

    red <= "111" when blank='0' and y < 400 else "000";
    green <= "111" when blank='0' and y>=200 and y < 400 else "000";
    blue <= "11" when blank='0' and y >= 200 else "00";

    -- red <= "000" when blank='1' else "111";
    -- green <= "000" when blank='1' else "000";
    -- blue <= "00" when blank='1' else "00";    

end machine_arch;

