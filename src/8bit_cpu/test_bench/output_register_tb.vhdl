-- 8 bit output register Test Bench
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;

entity output_register_tb is
end output_register_tb;


architecture output_register_tb_arch of output_register_tb is  

    component sim_clock
        port ( 
          clk: out std_logic;
          run: in std_logic;
          step: in std_logic
        );
    end component;

    component output_register
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
    end component;

    for clock_0: sim_clock use entity work.sim_clock;
    signal clk: std_logic;
    signal run_clock: std_logic := '0';
    signal step_clock: std_logic := '0';


    for register_0: output_register use entity work.output_register;
    
    signal oi: std_logic := '0';
    signal clr: std_logic := '0';
    signal cpu_bus: std_logic_vector(7 downto 0) := "ZZZZZZZZ";
    signal register_data: std_logic_vector(7 downto 0);


begin
  
    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );

    run_clock <= '1';

    register_0: output_register port map(
        clk => clk,            
        oi => oi,
        clr => clr,        
        cpu_bus => cpu_bus,
        reg => register_data
    );


    process
    begin

        wait for 7.5 ns;

        cpu_bus <= "10101010";
        oi <= '1';
        wait for 10 ns;
        oi <= '0';

        assert register_data = "10101010"
            report "register copy failed" severity failure;

        cpu_bus <= "ZZZZZZZZ";
        
        wait for 10 ns;

        assert register_data = "10101010"
            report "register copy failed" severity failure;

        wait for 10 ns;
        clr <= '1';
        wait for 1 ps;
        clr <= '0';
        assert register_data = "00000000"
            report "register reset failed" severity failure;            

        wait for 500 ns;

    end process;



end output_register_tb_arch;
