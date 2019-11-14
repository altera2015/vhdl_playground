-- 8 bit output register
--
-- Modeled after Ben Eaters schematics
-- https://eater.net/8bit/output
--
-- Ron Bessems <rbessems@gmail.com>

-- This does not include the output to the LED digits.

library ieee;
use ieee.std_logic_1164.all;

entity output_register is

  port ( 
    clk: in std_logic;
    
    -- clear the register contents to zeros (async)
    clr: in std_logic;
    -- copy the bus value to the register (sync)
    oi: in std_logic;

    -- CPU bus, by default high impedance
    cpu_bus: inout std_logic_vector(7 downto 0);

    -- Register Value
    reg: out std_logic_vector(7 downto 0) := "00000000"

  );

end output_register;

architecture output_register_arch of output_register is  
begin
  
  process(clk,clr)
  begin
    if clr = '1' then
      reg <= "00000000";    
    -- asynchronous reset.
    elsif clr='0' and rising_edge(clk) then

        if oi = '1' then
          reg <= cpu_bus;
        end if;
      
    end if;

  end process;

end output_register_arch;
