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
    -- clock signal
    clk: in std_logic;

    -- copies values to flags when low.
    fi_n: in std_logic;

    -- clear
    clr: out std_logic;

    -- output result onto Bus
    eo_n: in std_logic;
    -- A-B if '1' otherwise sum
    su: in std_logic;

    -- CPU bus, by default high impedance
    a_reg: in std_logic_vector(7 downto 0);
    b_reg: in std_logic_vector(7 downto 0);
    
    -- result of operation
    result: out std_logic_vector(7 downto 0);

    cpu_bus: out std_logic_vector(7 downto 0);
    
    cf: out std_logic;
    zf: out std_logic

  );

end alu;

architecture alu_arch of alu is
    signal temp : unsigned(8 downto 0);
    signal zero: std_logic;
    signal carry: std_logic;  
begin

    temp <= unsigned( "0" & a_reg ) + unsigned( "0" & b_reg ) when su = '0' else
            unsigned( "0" & a_reg ) - unsigned( "0" & b_reg ) when su = '1';

    result <= std_logic_vector(temp(7 downto 0));
    zero <= '1' when result = "00000000" else '0';
    carry <= temp(8);

    cpu_bus <= "ZZZZZZZZ" when eo_n = '1' else
               result when eo_n = '0';

    process(clk, clr)
    begin

      if clr='1' then
        cf <= '0';
        zf <= '0';
      elsif rising_edge(clk) then
        if ( fi_n = '0' ) then
          cf <= carry;
          zf <= zero;        
        end if;
      end if;

    end process;

end alu_arch;
