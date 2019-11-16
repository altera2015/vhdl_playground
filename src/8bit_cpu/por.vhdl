library ieee;
use ieee.std_logic_1164.all;
 
entity por is
  port (    
        clk :     in std_logic;
        reset_signal: out std_logic
  );
end entity por;
 

architecture por_arch of por is
   signal q0: std_logic := '1';
   signal q1: std_logic := '0';
   signal q2: std_logic := '0';   
begin
    process(clk)    
    begin
        if rising_edge(clk) then
            -- q0<=q0;
            q1<=q0;
            q2<=q1;
        end if;
    end process;

reset_signal <= not (q0 and q1 and q2);
 
end architecture por_arch;