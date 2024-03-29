-- 8 bit data register
--
-- Modeled after Ben Eaters register schematics
-- https://eater.net/8bit/registers
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;

entity data_register is

  port ( 
    clk: in std_logic;
    
    -- clear the register contents to zeros (async)
    clr: in std_logic;
    -- copy the bus value to the register (sync)
    ai_n: in std_logic;
    -- place the register value on the bus (async)
    ao_n: in std_logic;

    -- CPU bus, by default high impedance
    cpu_bus: inout std_logic_vector(7 downto 0);

    -- Register Value
    reg: out std_logic_vector(7 downto 0)

  );

end data_register;

architecture data_register_arch of data_register is  
    signal reg_internal: std_logic_vector(7 downto 0) := "00000000";
begin

  reg <= reg_internal;
  cpu_bus <= "ZZZZZZZZ" when ao_n = '1' else reg_internal;

  process(clk,clr)
  begin
    if clr = '1' then
      reg_internal <= "00000000";    
    -- asynchronous reset.
    elsif clr='0' and rising_edge(clk) then

        if ai_n = '0' and ao_n = '1' then
          reg_internal <= cpu_bus;
        end if;
      
    end if;

  end process;

end data_register_arch;
