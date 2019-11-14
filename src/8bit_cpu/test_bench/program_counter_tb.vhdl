-- Program Counter Test Bench
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;

entity program_counter_tb is
end program_counter_tb;


architecture program_counter_tb_arch of program_counter_tb is  

    component sim_clock
        port ( 
          clk: out std_logic;
          run: in std_logic;
          step: in std_logic
        );
    end component;

    component program_counter
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
            pc: out std_logic_vector(3 downto 0) := "0000"      
        
        );
    end component;

    for clock_0: sim_clock use entity work.sim_clock;
    signal clk: std_logic;
    signal run_clock: std_logic := '0';
    signal step_clock: std_logic := '0';


    for program_counter_0: program_counter use entity work.program_counter;
    
    signal co_n: std_logic := '1';
    signal ce: std_logic := '0';
    signal j_n: std_logic := '1';
    signal clr: std_logic := '0';
    signal cpu_bus: std_logic_vector(7 downto 0) := "ZZZZZZZZ";
    signal pc: std_logic_vector(3 downto 0);


begin
  
    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );

    run_clock <= '1';

    program_counter_0: program_counter port map(
        clk => clk,    
        co_n => co_n,
        clr => clr,        
        cpu_bus => cpu_bus,
        j_n => j_n,
        ce => ce,
        pc => pc
    );


    process
    begin

        wait for 7.5 ns;

        cpu_bus <= "00000001";
        j_n <= '0';
        wait for 10 ns;
        j_n <= '1';
        cpu_bus <= "ZZZZZZZZ";
        wait for 10 ns;

        assert pc = "0001"
            report "pc failed" severity failure;
        
        wait for 20 ns;
        assert pc = "0001"
            report "pc failed" severity failure;

        co_n <= '0';
        wait for 2 ns;

        assert cpu_bus = "00000001"
            report "pc failed" severity failure;

        ce <= '1';
        wait for 10 ns;

        assert cpu_bus = "00000010"
            report "pc failed" severity failure;

        wait for 10 ns;

        assert cpu_bus = "00000011"
            report "pc failed" severity failure;
    
        wait for 10 ns;
        assert cpu_bus = "00000100"
            report "pc failed" severity failure;

    
        wait for 10 ns;
        clr <= '1';
        wait for 1 ps;
        clr <= '0';
        assert pc = "0000"
            report "pc failed" severity failure;            

        wait for 500 ns;

    end process;



end program_counter_tb_arch;