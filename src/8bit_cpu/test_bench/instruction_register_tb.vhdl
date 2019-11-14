-- 8 bit instruction register Test Bench
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;

entity instruction_register_tb is
end instruction_register_tb;


architecture instruction_register_tb_arch of instruction_register_tb is  

    component sim_clock
        port ( 
          clk: out std_logic;
          run: in std_logic;
          step: in std_logic
        );
    end component;

    component instruction_register
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
            reg: out std_logic_vector(7 downto 0) := "00000000";
        
            -- Instruction Register Value
            ireg: out std_logic_vector(7 downto 4)
        
        
        );
    end component;

    for clock_0: sim_clock use entity work.sim_clock;
    signal clk: std_logic;
    signal run_clock: std_logic := '0';
    signal step_clock: std_logic := '0';


    for register_0: instruction_register use entity work.instruction_register;
    
    signal ao_n: std_logic := '1';
    signal ai_n: std_logic := '1';
    signal clr: std_logic := '0';
    signal cpu_bus: std_logic_vector(7 downto 0) := "ZZZZZZZZ";
    signal register_data: std_logic_vector(7 downto 0);
    signal iregister_data: std_logic_vector(7 downto 4);


begin
  
    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );

    run_clock <= '1';

    register_0: instruction_register port map(
        clk => clk,    
        io_n => ao_n,
        ii_n => ai_n,
        clr => clr,        
        cpu_bus => cpu_bus,
        reg => register_data,
        ireg => iregister_data
    );


    process
    begin

        wait for 7.5 ns;

        cpu_bus <= "10100101";
        ai_n <= '0';
        wait for 10 ns;
        ai_n <= '1';

        assert register_data = "10100101"
            report "register copy failed" severity failure;

        assert iregister_data = "1010"
            report "iregister copy failed" severity failure;

        cpu_bus <= "ZZZZZZZZ";
        
        wait for 10 ns;
        ao_n <= '0';

        wait for 1 ps;
        assert cpu_bus = "00000101"
            report "register to cpu_bus failed" severity failure;            

        wait for 10 ns;
        ao_n <= '1';

        wait for 10 ns;
        clr <= '1';
        wait for 1 ps;
        clr <= '0';
        assert register_data = "00000000"
            report "register reset failed" severity failure;            

        wait for 500 ns;

    end process;



end instruction_register_tb_arch;
