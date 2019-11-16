-- 4 bit program counter
--
-- Modeled after Ben Eaters program counter schematic
-- https://eater.net/8bit/pc
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is

  port ( 
    clk: in std_logic;
    
    -- clear the register contents to zeros (async)
    clr: in std_logic;
    -- count up at next clock edge.
    ce: in std_logic;
    -- copy the bus value to the program counter (sync)
    j_n: in std_logic;
    -- place the program counter value on the bus (async)
    co_n: in std_logic;

    -- CPU bus, by default high impedance
    cpu_bus: inout std_logic_vector(7 downto 0);

    -- Program counter
    pc: out std_logic_vector(3 downto 0)

  );

end program_counter;

architecture program_counter_arch of program_counter is  
begin

  cpu_bus <= "ZZZZZZZZ" when co_n = '1' else "0000" & pc;

  process(clk,clr)    
  begin
    if clr = '1' then
      pc <= "0000";    
    -- asynchronous reset.
    elsif clr='0' and rising_edge(clk) then

        if ce = '1' then          
          pc <= std_logic_vector(unsigned(pc) + 1);
        end if;

        if j_n = '0' then
          pc <= cpu_bus(3 downto 0);
        end if;
      
    end if;

  end process;

end program_counter_arch;
