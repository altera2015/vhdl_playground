library ieee;
use ieee.std_logic_1164.all;

entity flip_flop is
  port ( 
    clk: in std_logic;
    d: in std_logic;
    o: out std_logic;
    r: in std_logic
  );
end flip_flop;

architecture behaviour of flip_flop is  
begin
  
  process(clk, r)
  begin
    -- asynchronous reset.
    if r = '1' then
      o <= '0';        
    elsif rising_edge(clk) then
        o <= d;
    end if;
  end process;

end behaviour;
