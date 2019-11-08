-- 8 bit data register Test Bench
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;


architecture behaviour of alu_tb is  

    component alu
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
    end component;

    type test_vector_type is record
        su : std_logic;    
        a, b, sum : std_logic_vector(7 downto 0);        
        carry, zero : std_logic;
    end record; 
    type test_vector_array is array (natural range <>) of test_vector_type;
    constant test_vector : test_vector_array := (
        --su, a,          b,          sum,        carrry, zero
        ('1', "00000000", "00000000", "00000000", '0', '1'),
        ('1', "00000001", "00000001", "00000010", '0', '0'),
        ('1', "11111111", "00000001", "00000000", '1', '1'),
        ('0', "00000000", "00000001", "11111111", '1', '0'),
        ('0', "00000010", "00000001", "00000001", '0', '0'),
        ('0', "00000010", "00000010", "00000000", '0', '1')
    );


    for alu_0: alu use entity work.alu;
    
    signal eo_n: std_logic := '1';
    signal su: std_logic := '1';
    signal a_reg: std_logic_vector(7 downto 0);
    signal b_reg: std_logic_vector(7 downto 0);
    signal result: std_logic_vector(7 downto 0);
    signal cpu_bus: std_logic_vector(7 downto 0) := "ZZZZZZZZ";    
    signal zero: std_logic;
    signal carry: std_logic;


begin
  
    alu_0: alu port map( 
        eo_n=>eo_n, 
        su=>su,
        a_reg=>a_reg,
        b_reg=>b_reg,
        result=>result,
        cpu_bus=>cpu_bus,
        zero=>zero,
        carry=>carry
    );

    process        
    begin


        for i in test_vector'range loop

            eo_n <= '1';
            wait for 1 ns;
                
            a_reg <= test_vector(i).a;
            b_reg <= test_vector(i).b;
            su <= test_vector(i).su;
            
            wait for 1 ns;

            assert ( result = test_vector(i).sum )  and
                   ( carry = test_vector(i).carry ) and 
                   ( zero = test_vector(i).zero ) and
                   ( cpu_bus = "ZZZZZZZZ" )                 
                
                report  "test_vector " & integer'image(i) & " failed "                     
                severity failure;


            eo_n <= '0';
            wait for 1 ns;

            assert ( cpu_bus = test_vector(i).sum )
                report  "test_vector " & integer'image(i) & " failed "                     
                severity failure;

        end loop;

        wait for 500 ns;

    end process;



end behaviour;
