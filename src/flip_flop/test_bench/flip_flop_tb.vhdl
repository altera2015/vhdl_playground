library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_tb is
end flip_flop_tb;


architecture behaviour of flip_flop_tb is  

    component flip_flop
        port ( 
            clk: in std_logic;
            d: in std_logic;
            o: out std_logic;
            r: in std_logic
        );
    end component;


    component sim_clock
        port ( 
          clk: out std_logic;
          run: in std_logic;
          step: in std_logic
        );
    end component;

    
    for register_0: flip_flop use entity work.flip_flop;

    for clock_0: sim_clock use entity work.sim_clock;
    
        
    signal clk: std_logic;
    signal r: std_logic;
    signal d: std_logic;
    signal o: std_logic;

    signal run_clock: std_logic := '0';
    signal step_clock: std_logic := '0';

begin
  
    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );

    register_0: flip_flop port map ( clk=>clk, r=>r, d=>d, o=>o );

    process

        type check_type is record
            
            -- inputs            
            d : std_logic;

            -- expected outputs.
            o : std_logic;

        end record;
        type check_array_type is array (natural range <>) of check_type;
        constant check_array : check_array_type := (
            ('0', '0'),
            ('1', '1'),
            ('0', '0'),
            ('1', '1'),
            ('0', '0'),
            ('1', '1')
        );

    begin

        -- initialize clock        
        -- step_clock <= '1';
        -- wait for 10 ns;
        -- step_clock <= '0';
        -- wait for 100 ns;

        -- reset UUT
        r <= '1';
        -- propagation delay.
        wait for 1 ps;

        assert o = '0'
            report "bad value after reset" severity error;
        
        wait for 1 ns;
        r <= '0';

        for i in check_array'range loop
            
            d <= check_array(i).d;
            step_clock <= '1';

            wait for 1 ns;
            assert o = check_array(i).o
                report "bad output value" severity error;
            
                step_clock <= '0';
            wait for 1 ns;            

        end loop;


    end process;

end behaviour;
