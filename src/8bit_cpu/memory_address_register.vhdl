-- memory address register
--
-- Modeled after Ben Eaters register schematics
-- https://eater.net/8bit/ram
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;

entity mar_register is

  port ( 
    clk: in std_logic;    
    -- clear the register contents to zeros (async)
    clr: in std_logic;

    -- copy the bus value to the register (sync)
    mi_n: in std_logic;

    -- CPU bus, by default high impedance
    cpu_bus: in std_logic_vector(3 downto 0);

    -- Register Value
    address: out std_logic_vector(3 downto 0) := "0000"

  );

end mar_register;

architecture mar_register_arch of mar_register is  
begin

  store: process(clk,clr) is
  begin
    if clr = '1' then
        address <= "0000";    
    -- asynchronous reset.
    elsif clr='0' and rising_edge(clk) then

        if mi_n = '0' then
          address <= cpu_bus;
        end if;
      
    end if;

  end process store;

end mar_register_arch;
