-- ALU Test Bench
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;


architecture alu_tb_arch of alu_tb is  

    component sim_clock
        port ( 
            clk: out std_logic;
            run: in std_logic;
            step: in std_logic
        );
    end component;

    component alu
        port ( 
            -- clock signal
            clk: in std_logic;

            -- copies values to flags when low.
            fi_n: in std_logic;
            -- clear
            clr: out std_logic;
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

            cf: out std_logic;
            zf: out std_logic      
        );
    end component;

    type test_vector_type is record
        su : std_logic;    
        a, b, sum : std_logic_vector(7 downto 0);        
        carry, zero : std_logic;
    end record; 
    type test_vector_array is array (natural range <>) of test_vector_type;
    constant test_vector : test_vector_array := (
        --su, a,          b,          sum,        carrry, zero
        ('0', "00000000", "00000000", "00000000", '0', '1'),
        ('0', "00000001", "00000001", "00000010", '0', '0'),
        ('0', "11111111", "00000001", "00000000", '1', '1'),
        ('1', "00000000", "00000001", "11111111", '1', '0'),
        ('1', "00000010", "00000001", "00000001", '0', '0'),
        ('1', "00000010", "00000010", "00000000", '0', '1')
    );


    for alu_0: alu use entity work.alu;
    
    for clock_0: sim_clock use entity work.sim_clock;
    signal clk: std_logic;
    signal run_clock: std_logic := '1';
    signal step_clock: std_logic := '0';

    signal clr: std_logic := '0';
    signal fi_n: std_logic := '1';
    signal eo_n: std_logic := '1';
    signal su: std_logic := '1';
    signal a_reg: std_logic_vector(7 downto 0);
    signal b_reg: std_logic_vector(7 downto 0);
    signal result: std_logic_vector(7 downto 0);
    signal cpu_bus: std_logic_vector(7 downto 0) := "ZZZZZZZZ";    
    signal zero: std_logic;
    signal carry: std_logic;


begin
    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );
    
    alu_0: alu port map( 
        clk => clk,
        clr => clr,
        fi_n => fi_n,
        eo_n=>eo_n, 
        su=>su,
        a_reg=>a_reg,
        b_reg=>b_reg,
        result=>result,
        cpu_bus=>cpu_bus,
        zf=>zero,
        cf=>carry
    );

    process        
    begin
        clr <= '1';
        wait for 2 ns;
        clr <= '0';

        for i in test_vector'range loop

            eo_n <= '1';
            -- wait for 10 ns;
                
            a_reg <= test_vector(i).a;
            b_reg <= test_vector(i).b;
            su <= test_vector(i).su;            

            fi_n <= '0';
            wait for 10 ns;
            fi_n <= '1';

            assert ( result = test_vector(i).sum )  and
                   ( carry = test_vector(i).carry ) and 
                   ( zero = test_vector(i).zero ) and
                   ( cpu_bus = "ZZZZZZZZ" )                 
                
                report  "test_vector " & integer'image(i) & " failed "                     
                severity failure;


            eo_n <= '0';
            wait for 10 ns;

            assert ( cpu_bus = test_vector(i).sum )
                report  "test_vector " & integer'image(i) & " failed "                     
                severity failure;

        end loop;

        wait for 500 ns;

    end process;



end alu_tb_arch;
