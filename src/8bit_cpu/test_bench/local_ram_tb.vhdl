-- Local ram Test Bench
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;


entity local_ram_tb is
end local_ram_tb;


architecture local_ram_tb_arch of local_ram_tb is  

    component sim_clock
        port ( 
            clk: out std_logic;
            run: in std_logic;
            step: in std_logic
        );
    end component;


    component local_ram
        port (
            clk : in  std_logic;  
            -- output ram value on bus
            ro_n: in std_logic;
            -- read value from bus
            ri : in  std_logic;
            -- address to write to
            address : in  std_logic_vector(3 downto 0);
            -- data output
            cpu_bus : inout std_logic_vector(7 downto 0)
        );
    end component;

    type test_vector_type is record
        address : std_logic_vector(3 downto 0);
        value : std_logic_vector(7 downto 0);        
    end record; 
    type test_vector_array is array (natural range <>) of test_vector_type;
    constant test_vector : test_vector_array := (        
        ("0000", "10100000"),
        ("0001", "01010001"),
        ("0010", "10100010"),
        ("0011", "01010011"),
        ("0100", "10100100"),
        ("0101", "01010101"),
        ("0110", "10100110"),
        ("0111", "01010111"),
        ("1000", "10101000"),
        ("1001", "01011001"),
        ("1010", "10101010"),
        ("1011", "01011011"),
        ("1100", "10101100"),
        ("1101", "01011101"),
        ("1110", "10101110"),
        ("1111", "01011111")        
    );


    for clock_0: sim_clock use entity work.sim_clock;
    signal clk: std_logic;
    signal run_clock: std_logic := '0';
    signal step_clock: std_logic := '0';    

    for ram_0: local_ram use entity work.local_ram;
    
    signal ro_n: std_logic := '0';
    signal ri: std_logic := '0';    
    signal cpu_bus: std_logic_vector(7 downto 0);
    signal address: std_logic_vector(3 downto 0) := "0000";

begin
    
    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );

    run_clock <= '0';

    
    ram_0: local_ram port map( 
        clk=>clk,
        ro_n=>ro_n,
        ri=>ri,
        cpu_bus=>cpu_bus,
        address=>address
    );

    process        
    begin

        for i in test_vector'range loop
        
            ro_n <= '1';

            cpu_bus <= test_vector(i).value;
            address <= test_vector(i).address;
            ri <= '1';
            
            wait for 1 ns;
            step_clock <= '1';
            wait for 1 ns;
            step_clock <= '0';

            ri <= '0';

            cpu_bus <= "ZZZZZZZZ";
            ro_n <= '0';
            
            assert ( cpu_bus = test_vector(i).value )                
                report  "test_vector " & integer'image(i) & " write failed "                     
                severity failure;

        end loop;


        ro_n <= '0';
        for i in test_vector'range loop
            
            address <= test_vector(i).address;
                        
            wait for 1 ns;
            step_clock <= '1';
            wait for 1 ns;
            step_clock <= '0';
            
            assert ( cpu_bus = test_vector(i).value )                
                report  "test_vector " & integer'image(i) & " read failed "                     
                severity failure;

        end loop;



        wait for 500 ns;

    end process;



end local_ram_tb_arch;
