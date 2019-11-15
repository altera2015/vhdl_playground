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
   signal ram : ram_type := (
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000"                
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