-- 8 bit instruction register
--
-- Modeled after Ben Eaters register schematics
-- https://eater.net/8bit/registers
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_register is

  port ( 
    clk: in std_logic;
    
    -- clear the register contents to zeros (async)
    clr: in std_logic;
    -- copy the bus value to the register (sync)
    ii_n: in std_logic;
    -- place the register value on the bus (async)
    io_n: in std_logic;

    -- CPU bus, by default high impedance
    cpu_bus: inout std_logic_vector(7 downto 0);

    -- Register Value
    reg: out std_logic_vector(7 downto 0);

    -- Instruction Register Value
    ireg: out unsigned(3 downto 0) := "0000"


  );

end instruction_register;

architecture instruction_register_arch of instruction_register is  
begin

  
  cpu_bus <= "ZZZZZZZZ" when io_n = '1' else "0000" & reg(3 downto 0);
  
  process(clk,clr)
  begin
    if clr = '1' then
      reg <= "00000000";
      ireg <= "0000";
    -- asynchronous reset.
    elsif clr='0' and rising_edge(clk) then

        if ii_n = '0' and io_n = '1' then
          reg <= cpu_bus;
          ireg <= unsigned( cpu_bus(7 downto 4));
        end if;
      
    end if;

  end process;

end instruction_register_arch;
