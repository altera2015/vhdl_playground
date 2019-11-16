-- 8 bit 16 byte memory
--
-- Modeled after Ben Eaters register schematics
-- https://eater.net/8bit/ram
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_Std.all;

entity local_ram is
  port (
    clk : in  std_logic;  
    -- output ram value on bus
    ro_n: in std_logic;
    -- read value from bus
    ri : in  std_logic;
    -- address to write to
    address : in  std_logic_vector(3 downto 0);
    -- data output
    cpu_bus : inout std_logic_vector(7 downto 0)
  );
end entity local_ram;

architecture local_ram_arch of local_ram is

   type ram_type is array (0 to (2**address'length)-1) of std_logic_vector(cpu_bus'range);
   
  --  signal ram : ram_type := (
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000",
  --       "00000000"                
  --  );   


    signal ram : ram_type := (
      "00011110", -- LDA (0x0e) a = 1             00
      "00101111", -- ADD (0x0f) b = 2, a => 3     01
      "00111111", -- SUB (0x0f) b = 2  a => 1     02
      "01001101", -- STA (ex0d) (d) => 1          03
      "01010000", -- LDI 0 a >= 0                 04
      "00011101", -- LDA (0x0d) a >= 1            05
      "01011111", -- LDI F  a=> f                 06
      "11100000", -- OUT                          07
      "00101100", -- ADD (0xc) a=> 0xe c = 1      08
      "01110000", -- JC jump!                     09
      
      "11110000", -- HALT                         0a
      "01100000", -- JMP 0                        0b
      "11111111", --                              0c
      "00000000", --                              0d
      "00000001", --                              0e
      "00000010"  --                              0f
  );   


begin

  process(clk)
  begin    
    if rising_edge(clk) then
      if ri = '1' then        
        ram(to_integer(unsigned(address))) <= cpu_bus;        
      end if;      
    end if;
  end process;

  cpu_bus <= ram(to_integer(unsigned(address))) when ro_n = '0' else "ZZZZZZZZ";
  
end architecture local_ram_arch;