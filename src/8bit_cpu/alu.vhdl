-- 8 bit add and subtract ALU
--
-- Modeled after Ben Eaters ALU schematics
-- https://eater.net/8bit/alu
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is

  port ( 
    -- output result onto Bus
    eo_n: in std_logic;
    -- sums A+B if '1' otherwise subtract
    su: in std_logic;

    -- CPU bus, by default high impedance
    a_reg: in std_logic_vector(7 downto 0);
    b_reg: in std_logic_vector(7 downto 0);
    
    -- result of operation
    result: out std_logic_vector(7 downto 0);

    cpu_bus: out std_logic_vector(7 downto 0);
    
    zero: out std_logic;
    carry: out std_logic

  );

end alu;

architecture behaviour of alu is
    signal temp : unsigned(8 downto 0);
begin

    temp <= unsigned( "0" & a_reg ) + unsigned( "0" & b_reg ) when su = '1' else
            unsigned( "0" & a_reg ) - unsigned( "0" & b_reg ) when su = '0';

    result <= std_logic_vector(temp(7 downto 0));
    zero <= '1' when result = "00000000" else '0';
    carry <= temp(8);

    cpu_bus <= "ZZZZZZZZ" when eo_n = '1' else
               result when eo_n = '0';

end behaviour;
