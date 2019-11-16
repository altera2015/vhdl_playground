-- Control Logic Test Bench
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_logic_tb is
end control_logic_tb;


architecture control_logic_tb_arch of control_logic_tb is  

    component sim_clock
        port ( 
          clk: out std_logic;
          run: in std_logic;
          step: in std_logic
        );
    end component;

    component control_logic
        port ( 
            clk: in std_logic;
    
            instruction_bus: in unsigned(3 downto 0);
            carry_flag: in std_logic;
            zero_flag: in std_logic;
    
        
            -- clear
            clr: in std_logic;
        
            -- halt the clock
            hlt: out std_logic;
            -- Memory address in
            mi_n: out std_logic;
            -- RAM In
            ri: out std_logic;
            -- RAM Out
            ro_n: out std_logic;
            -- instruction register out
            io_n: out std_logic;
            -- instruction register in
            ii_n: out std_logic;
        
            -- a register in
            ai_n: out std_logic;
            -- a register out
            ao_n: out std_logic;
        
            -- ALU out
            eo_n: out std_logic;
            -- ALU Sum / Subtract
            su: out std_logic;
        
            -- B register in
            bi_n: out std_logic;
            
            -- output register in
            oi: out std_logic;
            
            -- program counter enable
            ce: out std_logic;
            -- program counter out
            co_n: out std_logic;
            -- program counter load / aka jump
            j_n: out std_logic;

            -- copy flags to flags register.
            fi_n: out std_logic
        
        );
    end component;

    for clock_0: sim_clock use entity work.sim_clock;
    signal clk: std_logic;
    signal run_clock: std_logic := '0';
    signal step_clock: std_logic := '0';


    for control_0: control_logic use entity work.control_logic;
    
    signal instruction_bus: unsigned(3 downto 0) := "0000";

    signal carry_flag: std_logic := '0';
    signal zero_flag: std_logic := '0';
     
    signal clr: std_logic;
    signal hlt: std_logic;    
    signal mi_n: std_logic;    
    signal ri: std_logic;    
    signal ro_n: std_logic;    
    signal io_n: std_logic;    
    signal ii_n: std_logic;
    signal ai_n: std_logic;    
    signal ao_n: std_logic;
    signal eo_n: std_logic;    
    signal su: std_logic;
    signal bi_n: std_logic;
    signal oi: std_logic;
    signal ce: std_logic;    
    signal co_n: std_logic;    
    signal j_n: std_logic;    
    signal fi_n: std_logic;

begin
  
    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );

    run_clock <= '1';
    clr <= '0';

    control_0: control_logic port map(
        clk => clk,    
        instruction_bus => instruction_bus,
        carry_flag => carry_flag,
        zero_flag => zero_flag,
        clr => clr,
        hlt => hlt,
        mi_n => mi_n,
        ri => ri,
        ro_n => ro_n,
        io_n => io_n,
        ii_n => ii_n,
        ai_n => ai_n,
        ao_n => ao_n,
        eo_n => eo_n,
        su => su,
        bi_n => bi_n,
        oi => oi,
        ce => ce,
        co_n => co_n,
        j_n => j_n,
        fi_n => fi_n
    );

    process
    begin
        
        wait for 10 ps;

        ----------
        -- NOP! --
        ----------

        assert hlt = '0'
            report "hlt" severity failure;        
        assert mi_n = '0'
            report "mi_n" severity failure;                
        assert ri = '0'
            report "ri" severity failure;        
        assert ro_n = '1'
            report "ro_n" severity failure;        
        assert io_n = '1'
            report "io_n" severity failure;
        assert ii_n = '1'
            report "ii_n" severity failure;    
        assert ai_n = '1'
            report "ai_n" severity failure;        
        assert ao_n = '1'
            report "ao_n" severity failure;        
        assert eo_n = '1'
            report "eo_n" severity failure;
        assert su = '0'
            report "su" severity failure;  
        assert bi_n = '1'
            report "bi_n" severity failure;    
        assert ai_n = '1'
            report "ai_n" severity failure;        
        assert oi = '0'
            report "oi" severity failure;        
        assert ce = '0'
            report "ce" severity failure;
        assert co_n = '0'
            report "co_n" severity failure;                
        assert j_n = '1'
            report "j_n" severity failure;
        assert fi_n = '1'
            report "fi_n" severity failure;

        wait for 10 ns;

        assert hlt = '0'
            report "hlt" severity failure;        
        assert mi_n = '1'
            report "mi_n" severity failure;                
        assert ri = '0'
            report "ri" severity failure;        
        assert ro_n = '0'
            report "ro_n" severity failure;        
        assert io_n = '1'
            report "io_n" severity failure;
        assert ii_n = '0'
            report "ii_n" severity failure;    
        assert ai_n = '1'
            report "ai_n" severity failure;        
        assert ao_n = '1'
            report "ao_n" severity failure;        
        assert eo_n = '1'
            report "eo_n" severity failure;
        assert su = '0'
            report "su" severity failure;  
        assert bi_n = '1'
            report "bi_n" severity failure;    
        assert ai_n = '1'
            report "ai_n" severity failure;        
        assert oi = '0'
            report "oi" severity failure;        
        assert ce = '1'
            report "ce" severity failure;
        assert co_n = '1'
            report "co_n" severity failure;                
        assert j_n = '1'
            report "j_n" severity failure;
        assert fi_n = '1'
            report "fi_n" severity failure;


        wait for 500 ns;

    end process;



end control_logic_tb_arch;
