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
    -- write enable, write to memory when high and clk edge happens
    we : in  std_logic;
    -- address to write to
    address : in  std_logic_vector(3 downto 0);
    -- data input    
    data_in  : in std_logic_vector(7 downto 0);
    -- data output
    data_out : out std_logic_vector(7 downto 0)
  );
end entity local_ram;

architecture rtl of local_ram is

   type ram_type is array (0 to (2**address'length)-1) of std_logic_vector(data_in'range);
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
      if we = '1' then        
        ram(to_integer(unsigned(address))) <= data_in;        
      end if;      
    end if;
  end process;

  data_out <= ram(to_integer(unsigned(address)));
  

end architecture rtl;