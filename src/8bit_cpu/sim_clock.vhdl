library ieee;
use ieee.std_logic_1164.all;

entity sim_clock is
  port ( 
    clk: out std_logic;
    run: in std_logic;
    step: in std_logic
  );
end sim_clock;

architecture sim_clock_arch of sim_clock
is
  constant clk_period : time := 10 ns;
  signal clk_temp: std_logic := '0';
begin
  -- Clock process definition
  clk_process: process
  begin    
    clk_temp <= '0';
    wait for clk_period/2;
    clk_temp <= '1';
    wait for clk_period/2;    
  end process;

  clk <= clk_temp when run = '1' else
         step;

end sim_clock_arch;
