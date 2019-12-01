library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Screen refresh rate	72 Hz
-- Vertical refresh	48.076923076923 kHz
-- Pixel freq.	50.0 MHz
-- Horizontal timing (line)
-- Polarity of horizontal sync pulse is positive.

-- Scanline part	Pixels	Time [µs]
-- Visible area	800	16
-- Front porch	56	1.12
-- Sync pulse	120	2.4
-- Back porch	64	1.28
-- Whole line	1040	20.8
-- Vertical timing (frame)
-- Polarity of vertical sync pulse is positive.

-- Frame part	Lines	Time [ms]
-- Visible area	600	12.48
-- Front porch	37	0.7696
-- Sync pulse	6	0.1248
-- Back porch	23	0.4784
-- Whole frame	666	13.8528

entity vga is
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
    
end vga;

architecture vga_arch of vga is
    
    constant H_BLANK       : integer := (H_FRONT_PORCH+H_SYNC_PULSE+H_BACK_PORCH);
    constant V_BLANK       : integer := (V_FRONT_PORCH+V_SYNC_PULSE+V_BACK_PORCH);
    constant H_WHOLE_FRAME : integer := (H_VISIBLE+H_BLANK);
    constant V_WHOLE_FRAME : integer := (V_VISIBLE+V_BLANK);
    
    signal x_c : integer range 0 to 1024 := 0;
    signal y_c : integer range 0 to 1024 := 0;
    signal div : integer range 0 to 1 := 0;   
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            div <= div + 1;
            if div = 1 then
                div <= 0;
                x_c <= x_c + 1;
                if x_c = H_WHOLE_FRAME then
                    x_c <= 0;            
                    y_c <= y_c + 1;
                    if y_c = V_WHOLE_FRAME then
                        y_c <= 0;
                    end if;
                end if;
            end if;
        end if;   
    end process;
    
    blank <= '1' when x_c < H_BLANK else
             '1' when x_c > H_WHOLE_FRAME else
             '1' when y_c > V_WHOLE_FRAME - V_BLANK else
             '0';
             
    h_sync_n <= '0' when ( (x_c >= H_FRONT_PORCH) and (x_c <= ( H_FRONT_PORCH + H_SYNC_PULSE ))) else
                '1';

    v_sync_n <= '0' when ( (y_c >= (V_VISIBLE + V_FRONT_PORCH)) and (y_c <= ( V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE ))) else
                '1';

    x <= to_unsigned(x_c - H_BLANK, x'length) when x_c >= H_BLANK else
         to_unsigned(0, x'length);
         
    y <= to_unsigned(y_c, y'length) when y_c < V_VISIBLE else
         to_unsigned(0, y'length);

end vga_arch;

