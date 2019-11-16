-- CPU
--
-- Modeled after Ben Eaters schematics
-- https://eater.net/8bit
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is    
end entity;

architecture cpu_arch of cpu is
    

    signal clr: std_logic;
    signal cpu_bus: std_logic_vector(7 downto 0) := "ZZZZZZZZ";
    



    --=======================================================--
    -- Clock
    --=======================================================--

    component sim_clock
        port ( 
          clk: out std_logic;
          run: in std_logic;
          step: in std_logic
        );
    end component;

    
    for clock_0: sim_clock use entity work.sim_clock;
    signal clk: std_logic;
    signal run_clock: std_logic := '1';
    signal step_clock: std_logic := '0';


    --=======================================================--
    -- ALU
    --=======================================================--

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
        
    for alu_0: alu use entity work.alu;    
    signal eo_n: std_logic := '1';
    signal su: std_logic := '1';
    signal a_reg: std_logic_vector(7 downto 0);
    signal b_reg: std_logic_vector(7 downto 0);
    signal result: std_logic_vector(7 downto 0);    
    signal zero: std_logic;
    signal carry: std_logic;
    signal fi_n: std_logic := '0';


    --=======================================================--
    -- Program Counter
    --=======================================================--    
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
            pc: out std_logic_vector(3 downto 0)      
        
        );
    end component;

    for program_counter_0: program_counter use entity work.program_counter;

    signal pc: std_logic_vector(3 downto 0);
    signal co_n: std_logic := '1';
    signal ce: std_logic := '0';
    signal j_n: std_logic := '1';
    

    --=======================================================--
    -- Output Register
    --=======================================================--  
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
            reg: out std_logic_vector(7 downto 0)        
        );
    end component;

    for output_register_0: output_register use entity work.output_register;
    
    signal oi: std_logic := '0';
    signal register_data: std_logic_vector(7 downto 0);


    --=======================================================--
    -- MAR Register
    --=======================================================--  
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
            address: out std_logic_vector(3 downto 0)       
        
        );
    end component;

    for mar_register_0: mar_register use entity work.mar_register;
    signal mi_n: std_logic := '1';    

    --=======================================================--
    -- RAM
    --=======================================================--  
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

    for ram_0: local_ram use entity work.local_ram;
    
    signal ro_n: std_logic := '0';
    signal ri: std_logic := '0';  
    signal address: std_logic_vector(3 downto 0) := "0000";    


    --=======================================================--
    -- Instruction Register
    --=======================================================--  
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
            reg: out std_logic_vector(7 downto 0) ;
        
            -- Instruction Register Value
            ireg: out unsigned(3 downto 0)
        
        
        );
    end component;  

    for instruction_register_0: instruction_register use entity work.instruction_register;
    
    signal io_n: std_logic := '1';
    signal ii_n: std_logic := '1';
    -- signal register_data: std_logic_vector(7 downto 0);
    signal iregister: unsigned(3 downto 0);


    --=======================================================--
    -- Data Registers
    --=======================================================--  
    component data_register
        port ( 
            clk: in std_logic;
    
            -- clear the register contents to zeros (async)
            clr: in std_logic;
            -- copy the bus value to the register (sync)
            ai_n: in std_logic;
            -- place the register value on the bus (async)
            ao_n: in std_logic;
        
            -- CPU bus, by default high impedance
            cpu_bus: inout std_logic_vector(7 downto 0);
        
            -- Register Value
            reg: out std_logic_vector(7 downto 0) 
        
        );
    end component;
    
    for register_A: data_register use entity work.data_register;
    for register_B: data_register use entity work.data_register;
    
    signal ao_n: std_logic := '1';
    signal ai_n: std_logic := '1';
    signal register_data_A: std_logic_vector(7 downto 0);

    signal bo_n: std_logic := '1';
    signal bi_n: std_logic := '1';
    signal register_data_B: std_logic_vector(7 downto 0);


    --=======================================================--
    -- Control Logic
    --=======================================================--  
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
    
    for control_0: control_logic use entity work.control_logic;
    signal hlt: std_logic;   
    signal reset_button: std_logic := '0';
        
    signal por_clr: std_logic;
    

    --=======================================================--
    -- Power On Reset
    --=======================================================--  
    component por
        port (            
            clk :     in std_logic;
            reset_signal: out std_logic        
        );
    end component;
    for por_0: por use entity work.por;
begin

    clock_0: sim_clock port map( 
        clk=>clk, 
        run=>run_clock,
        step=>step_clock
    );
    
    run_clock <= not hlt;
    

    por_0: por port map (        
        clk => clk,
        reset_signal => por_clr
    );
    clr <= reset_button or por_clr;

    control_0: control_logic port map(
        clk => clk,    
        instruction_bus => iregister,
        carry_flag => carry,
        zero_flag => zero,
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

    alu_0: alu port map( 
        clk => clk,
        clr => clr,
        fi_n => fi_n,
        eo_n=>eo_n, 
        su=>su,
        a_reg=>register_data_A,
        b_reg => register_data_B,
        --result=>result,
        cpu_bus=>cpu_bus,
        zf=>zero,
        cf=>carry
    );

    program_counter_0: program_counter port map(
        clk => clk,    
        co_n => co_n,
        clr => clr,        
        cpu_bus => cpu_bus,
        j_n => j_n,
        ce => ce,
        pc => pc
    );


    output_register_0: output_register port map(
        clk => clk,            
        oi => oi,
        clr => clr,        
        cpu_bus => cpu_bus
        -- reg => register_data
    );

    mar_register_0: mar_register port map(
        clk => clk,    
        mi_n => mi_n,
        clr => clr,        
        cpu_bus => cpu_bus,
        address => address
    );

    ram_0: local_ram port map( 
        clk=>clk,
        ro_n=>ro_n,
        ri=>ri,
        cpu_bus=>cpu_bus,
        address=>address
    );

    instruction_register_0: instruction_register port map(
        clk => clk,    
        io_n => io_n,
        ii_n => ii_n,
        clr => clr,        
        cpu_bus => cpu_bus,
        -- reg => register_data,
        ireg => iregister
    );

    register_a: data_register port map(
        clk => clk,    
        ao_n => ao_n,
        ai_n => ai_n,
        clr => clr,        
        cpu_bus => cpu_bus,
        reg => register_data_A
    );

    register_b: data_register port map(
        clk => clk,    
        ao_n => bo_n,
        ai_n => bi_n,
        clr => clr,        
        cpu_bus => cpu_bus,
        reg => register_data_B
    );



end cpu_arch;

      
