-- Test memory writing and reading 1 word (32bits) at a time.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- https://www.xilinx.com/support/documentation/user_guides/ug388.pdf
entity mem_test is
    generic(
        MASK_SIZE           : integer := 4;
        DATA_PORT_SIZE      : integer := 32;
        MAX_MEMORY          : integer := 67108864
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        run: in std_logic;
        
        mem_test_in_progress: out std_logic;
        mem_ok: out std_logic;
        mem_fail: out std_logic;
            
        
        cmd_en                            : out std_logic;
        cmd_instr                         : out std_logic_vector(2 downto 0);
        cmd_bl                            : out std_logic_vector(5 downto 0);
        cmd_byte_addr                     : out  std_logic_vector(29 downto 0);
        cmd_empty                         : in std_logic;
        cmd_full                          : in std_logic;
        
        wr_en                             : out std_logic;
        wr_mask                           : out std_logic_vector(MASK_SIZE - 1 downto 0);
        wr_data                           : out std_logic_vector(DATA_PORT_SIZE - 1 downto 0);
        wr_full                           : in std_logic;
        wr_empty                          : in std_logic;
        wr_count                          : in std_logic_vector(6 downto 0);
        wr_underrun                       : in std_logic;
        wr_error                          : in std_logic;
        
        rd_en                             : out std_logic;
        rd_data                           : in std_logic_vector(DATA_PORT_SIZE - 1 downto 0);
        rd_full                           : in std_logic;
        rd_empty                          : in std_logic;
        rd_count                          : in std_logic_vector(6 downto 0);
        rd_overflow                       : in std_logic;
        rd_error                          : in std_logic 
    );
end mem_test;

architecture Behavioral of mem_test is

    signal address: unsigned(29 downto 0) := (others=>'0');
    
    type mem_test_state is ( Idle, WaitForWrQueue, WritingWrQueue, WaitForCmdQueue, WritingCmdQueue, 
                            PrepareRead, CommandRead, WaitForReadData, Done );
        
    signal state_reg: mem_test_state := Idle;
    
begin
    
    wr_mask <= "0000";
    
    s: process(clk, reset)
    begin
        if reset = '1' then
            mem_test_in_progress <= '0';
            mem_fail <= '0';
            mem_ok <= '0';
            address <= (others=>'0');            
            wr_en <= '0';
            cmd_en <= '0';
            state_reg <= Idle;
            
        elsif rising_edge(clk) then
        
            cmd_en <= '0';
            wr_en <= '0';
            rd_en <= '0';            
                        
            case (state_reg) is
            
                when Idle =>
                
                    mem_fail <= '0';
                    mem_ok <= '0';
                    mem_test_in_progress <= '0';
                    if run = '1' then
                        state_reg <= WritingWrQueue;
                    end if;                
                    
                when WaitForWrQueue =>
                
                    mem_test_in_progress <= '1';
                    if wr_full = '0' and cmd_full='0' then
                        wr_data <= "11111010111110101111101011111010";
                        wr_en <= '1';
                        state_reg <= WritingWrQueue;                        
                    end if;
                    
                when WritingWrQueue =>
                
                    if cmd_full = '0' then                        
                        cmd_instr <= "000";
                        cmd_byte_addr <= std_logic_vector(address);
                        cmd_bl <= "000000"; --write 1 word                        
                        state_reg <= WaitForCmdQueue;
                    end if;
                    
                when WaitForCmdQueue =>
                
                    cmd_en <= '1';
                    state_reg <= WritingCmdQueue;
                    
                when WritingCmdQueue =>
                    
                    address <= address + 4;
                    -- if to_integer(address) = 16777216 then
                    if to_integer(address) = MAX_MEMORY then
                        state_reg <= PrepareRead;
                        address <= to_unsigned(0, address'length); --(others => '0');                        
                    else
                        state_reg <= WaitForWrQueue;
                    end if;
                
                when PrepareRead =>
                
                    if cmd_full = '0' and wr_empty='1' then
                        cmd_instr <= "001";
                        cmd_byte_addr <= std_logic_vector(address);
                        cmd_bl <= "000000"; -- read 1 word
                        state_reg <= CommandRead;
                    end if;                    
                   
                when CommandRead =>
                    
                    cmd_en <= '1';                    
                    state_reg <= WaitForReadData;
                
                when WaitForReadData =>
                    
                    if rd_count /= "0000000" then
                        rd_en <= '1';    
                        if rd_data /= "11111010111110101111101011111010" then
                            mem_fail <= '1';
                            state_reg <= Done;
                        else
                            address <= address + 4;
                            if to_integer(address) = MAX_MEMORY then 
                                state_reg <= Done;
                                mem_ok <= '1';
                            else
                                state_reg <= PrepareRead;                            
                            end if;
                        
                        end if;
                        
                    end if;
                    
                when Done =>
                    mem_test_in_progress <= '0';
                when others =>
                    wr_en <= '0';
            end case;

        end if;
    
    end process;

end Behavioral;

