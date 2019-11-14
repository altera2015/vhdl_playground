-- memory address register Test Bench
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;

entity mar_register_tb is
end mar_register_tb;


architecture mar_register_tb_arch of mar_register_tb is  

    component sim_clock
        port ( 
          clk: out std_logic;
          run: in std_logic;
          step: in std_logic
        );
    end component;

    component mar_register
        port ( 
            clk: in std_logic;    
            -- clear the register contents to zeros (async)
            clr: in std_logic;
        
            -- copy the bus value to the register (sync)
            mi_n: in std_logic;
        
            -- CPU bus, by default high impedance
            cpu_bus: in std_logic_vector(7 downto 0);
        
            -- Register Value
            address: out std_logic_vector(3 downto 0) := "0000"        
        
        );
    end component;

    for clock_0: sim_clock use entity work.sim_clock;
    signal clk: std_logic;
    signal run_clock: std_logic := '0';
    signal step_clock: std_logic := '0';


    for register_0: mar_register use entity work.mar_register;
    
    signal mi_n: std_logic := '1';    
    signal clr: std_logic := '0';
    signal cpu_bus: std_logic_vector(7 downto 0) := "ZZZZZZZZ";
    signal address_data: std_logic_vector(3 downto 0);


begin
  
    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );

    run_clock <= '1';

    register_0: mar_register port map(
        clk => clk,    
        mi_n => mi_n,
        clr => clr,        
        cpu_bus => cpu_bus,
        address => address_data
    );


    process
    begin

        wait for 7.5 ns;

        cpu_bus <= "10101110";
        mi_n <= '0';
        wait for 10 ns;
        mi_n <= '1';
        cpu_bus <= "ZZZZZZZZ";
        wait for 10 ns;

        assert address_data = "1110"
            report "address copy failed" severity failure;


        cpu_bus <= "01011111";
        mi_n <= '0';
        wait for 10 ns;
        mi_n <= '1';
        cpu_bus <= "ZZZZZZZZ";
        wait for 10 ns;

        assert address_data = "1111"
            report "address copy failed" severity failure;



        wait for 10 ns;
        clr <= '1';
        wait for 1 ps;
        clr <= '0';
        assert address_data = "0000"
            report "address reset failed" severity failure;            

        wait for 500 ns;

    end process;



end mar_register_tb_arch;
