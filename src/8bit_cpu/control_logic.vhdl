-- Control Logic
--
-- Modeled after Ben Eaters schematics
-- https://eater.net/8bit/control
--
-- Ron Bessems <rbessems@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_logic is

  port ( 
    clk: in std_logic;
    
    instruction_bus: in std_logic_vector(3 downto 0);
    reset_button: in std_logic := '0';
    carry_flag: in std_logic;
    zero_flag: in std_logic;
    

    -- clear
    clr: out std_logic;

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

end control_logic;

architecture control_logic_arch of control_logic is

    -- Output flags.
    constant CHLT : bit_vector(15 downto 0) := "1000000000000000";
    constant CMI  : bit_vector(15 downto 0) := "0100000000000000";
    constant CRI  : bit_vector(15 downto 0) := "0010000000000000";
    constant CRO  : bit_vector(15 downto 0) := "0001000000000000";
    constant CIO  : bit_vector(15 downto 0) := "0000100000000000";
    constant CII  : bit_vector(15 downto 0) := "0000010000000000";
    constant CAI  : bit_vector(15 downto 0) := "0000001000000000";
    constant CAO  : bit_vector(15 downto 0) := "0000000100000000";
    constant CEO  : bit_vector(15 downto 0) := "0000000010000000";
    constant CSU  : bit_vector(15 downto 0) := "0000000001000000";
    constant CBI  : bit_vector(15 downto 0) := "0000000000100000";
    constant COI  : bit_vector(15 downto 0) := "0000000000010000";
    constant CCE  : bit_vector(15 downto 0) := "0000000000001000";
    constant CCO  : bit_vector(15 downto 0) := "0000000000000100";
    constant CJ   : bit_vector(15 downto 0) := "0000000000000010";
    constant CFI  : bit_vector(15 downto 0) := "0000000000000001";
    constant C0   : bit_vector(15 downto 0) := "0000000000000000";

    -- Instructions
    constant JC   : std_logic_vector(3 downto 0) := "0111";
    constant JZ   : std_logic_vector(3 downto 0) := "1000";

    type microcode_stages is array(0 to 7) of bit_vector(15 downto 0);
    type microcode_array is array (0 to 15) of microcode_stages;
        
    -- Microcode from 
    -- https://github.com/beneater/eeprom-programmer/blob/master/microcode-eeprom-with-flags/microcode-eeprom-with-flags.ino
    constant microcode : microcode_array := (    
        (CMI or CCO, CRO or CII or CCE, C0,         C0,         C0,                       C0, C0, C0),      -- NOP
        (CMI or CCO, CRO or CII or CCE, CIO or CMI, CRO or CAI, C0,                       C0, C0, C0),      -- LDA
        (CMI or CCO, CRO or CII or CCE, CIO or CMI, CRO or CBI, CEO or CAI or CFI,        C0, C0, C0),      -- ADD
        (CMI or CCO, CRO or CII or CCE, CIO or CMI, CRO or CBI, CEO or CAI or CSU or CFI, C0, C0, C0),      -- SUB
        (CMI or CCO, CRO or CII or CCE, CIO or CMI, CAO or CRI, C0,                       C0, C0, C0),      -- STA
        (CMI or CCO, CRO or CII or CCE, CIO or CAI, C0,         C0,                       C0, C0, C0),      -- LDI
        (CMI or CCO, CRO or CII or CCE, CIO or CJ,  C0,         C0,                       C0, C0, C0),      -- JMP
        (CMI or CCO, CRO or CII or CCE, CIO,        C0,         C0,                       C0, C0, C0),      -- JC
        (CMI or CCO, CRO or CII or CCE, CIO,        C0,         C0,                       C0, C0, C0),      -- JZ
        (CMI or CCO, CRO or CII or CCE, C0,         C0,         C0,                       C0, C0, C0),      -- NOP
        (CMI or CCO, CRO or CII or CCE, C0,         C0,         C0,                       C0, C0, C0),      -- NOP
        (CMI or CCO, CRO or CII or CCE, C0,         C0,         C0,                       C0, C0, C0),      -- NOP
        (CMI or CCO, CRO or CII or CCE, C0,         C0,         C0,                       C0, C0, C0),      -- NOP
        (CMI or CCO, CRO or CII or CCE, C0,         C0,         C0,                       C0, C0, C0),      -- NOP
        (CMI or CCO, CRO or CII or CCE, CAO or COI, C0,         C0,                       C0, C0, C0),      -- OUT
        (CMI or CCO, CRO or CII or CCE, CHLT,       C0,         C0,                       C0, C0, C0)       -- HLT
    );

    -- variable stages : microcode_stages;
    signal micro_flags: bit_vector(15 downto 0);
    signal stage: unsigned(2 downto 0) := "000";
begin
    
    micro_flags <= microcode(to_integer(unsigned(instruction_bus)))(to_integer(unsigned(stage)));

    hlt  <= to_stdulogic (micro_flags(15));
    mi_n <= not to_stdulogic (micro_flags(14));
    ri   <= to_stdulogic (micro_flags(13));
    ro_n <= not to_stdulogic (micro_flags(12));
    io_n <= not to_stdulogic (micro_flags(11));
    ii_n <= not to_stdulogic (micro_flags(10));
    ai_n <= not to_stdulogic (micro_flags(9));
    ao_n <= not to_stdulogic (micro_flags(8));
    eo_n <= not to_stdulogic (micro_flags(7));
    su   <= to_stdulogic (micro_flags(6));
    bi_n <= not to_stdulogic (micro_flags(5));
    oi   <= to_stdulogic (micro_flags(4));
    ce   <= to_stdulogic (micro_flags(3));
    co_n <= not to_stdulogic (micro_flags(2));

    -- Conditional jumps here for instruction JC and JZ
    j_n <= '0' when (stage = "0010") and (instruction_bus = JC) and carry_flag = '1' else
           '0' when (stage = "0010") and (instruction_bus = JZ) and zero_flag = '1' else
           not to_stdulogic(micro_flags(1));
    
    fi_n <= not to_stdulogic (micro_flags(0));

    clr <= reset_button;
    
    process(clk, clr)
    begin
        if clr = '1' then
            stage <= "000";
        elsif clr = '0' and falling_edge(clk) then
            stage <= stage + 1;
        end if;
    end process;

    
end control_logic_arch;
