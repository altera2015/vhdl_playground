----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:49:59 11/19/2019 
-- Design Name: 
-- Module Name:    machine - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- revision 0.01 - file created
-- additional comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity machine is
generic
    (
        C3_P0_MASK_SIZE           : integer := 4;
        C3_P0_DATA_PORT_SIZE      : integer := 32;
        C3_P1_MASK_SIZE           : integer := 4;
        C3_P1_DATA_PORT_SIZE      : integer := 32;
        C3_MEMCLK_PERIOD        : integer := 10000; 
                                           -- Memory data transfer clock period.
        C3_RST_ACT_LOW          : integer := 0; 
                                           -- # = 1 for active low reset,
                                           -- # = 0 for active high reset.
        C3_INPUT_CLK_TYPE       : string := "SINGLE_ENDED"; 
                                           -- input clock type DIFFERENTIAL or SINGLE_ENDED.
        C3_CALIB_SOFT_IP        : string := "TRUE"; 
                                           -- # = TRUE, Enables the soft calibration logic,
                                           -- # = FALSE, Disables the soft calibration logic.
        C3_SIMULATION           : string := "FALSE"; 
                                           -- # = TRUE, Simulating the design. Useful to reduce the simulation time,
                                           -- # = FALSE, Implementing the design.
        C3_MC_CALIB_BYPASS      : string := "FALSE";
        C3_HW_TESTING           : string := "FALSE"; 
                                           -- Determines the address space accessed by the traffic generator,
                                           -- # = FALSE, Smaller address space,
                                           -- # = TRUE, Large address space.
        DEBUG_EN                : integer := 0; 
                                           -- # = 1, Enable debug signals/controls,
                                           --   = 0, Disable debug signals/controls.
        C3_MEM_ADDR_ORDER       : string := "ROW_BANK_COLUMN"; 
                                           -- The order in which user address is provided to the memory controller,
                                           -- ROW_BANK_COLUMN or BANK_ROW_COLUMN.
        C3_NUM_DQ_PINS          : integer := 16; 
                                           -- External memory data width.
        C3_MEM_ADDR_WIDTH       : integer := 13; 
                                           -- External memory address width.
        C3_MEM_BANKADDR_WIDTH   : integer := 2 
                                           -- External memory bank address width.
    );
    port(
        CLK_100MHz : in  std_logic;
        DPSwitch : in  std_logic_vector (7 downto 0);
        reset_signal : in  std_logic;
        LED : out  std_logic_vector (7 downto 0);
        SevenSegment : out  std_logic_vector (7 downto 0);
        SevenSegmentEnable : out  std_logic_vector (2 downto 0);

        -- LPDDR pins
        mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
        mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
        mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
        mcb3_dram_cke                           : out std_logic;
        mcb3_dram_ras_n                         : out std_logic;
        mcb3_dram_cas_n                         : out std_logic;
        mcb3_dram_we_n                          : out std_logic;
        mcb3_dram_dm                            : out std_logic;
        mcb3_dram_udqs                          : inout  std_logic;
        mcb3_rzq                                : inout  std_logic;
        mcb3_dram_udm                           : out std_logic;
        mcb3_dram_dqs                           : inout  std_logic;
        mcb3_dram_ck                            : out std_logic;
        mcb3_dram_ck_n                          : out std_logic;        
        c3_rst0                                 : out std_logic
    );
end machine;

architecture Behavioral of machine is

    component s6_lpddr
     generic(
        C3_P0_MASK_SIZE           : integer := 4;
        C3_P0_DATA_PORT_SIZE      : integer := 32;
        C3_P1_MASK_SIZE           : integer := 4;
        C3_P1_DATA_PORT_SIZE      : integer := 32;
        C3_MEMCLK_PERIOD          : integer := 10000;
        C3_RST_ACT_LOW            : integer := 0;
        C3_INPUT_CLK_TYPE         : string := "SINGLE_ENDED";
        C3_CALIB_SOFT_IP          : string := "TRUE";
        C3_SIMULATION             : string := "TRUE";
        -- C3_MC_CALIB_BYPASS        : string := "FALSE";
        DEBUG_EN                  : integer := 0;
        C3_MEM_ADDR_ORDER         : string := "ROW_BANK_COLUMN";
        C3_NUM_DQ_PINS            : integer := 16;
        C3_MEM_ADDR_WIDTH         : integer := 13;
        C3_MEM_BANKADDR_WIDTH     : integer := 2
    );
    port (
       mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
       mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
       mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
       mcb3_dram_cke                           : out std_logic;
       mcb3_dram_ras_n                         : out std_logic;
       mcb3_dram_cas_n                         : out std_logic;
       mcb3_dram_we_n                          : out std_logic;
       mcb3_dram_dm                            : out std_logic;
       mcb3_dram_udqs                          : inout  std_logic;
       mcb3_rzq                                : inout  std_logic;
       mcb3_dram_udm                           : out std_logic;
       c3_sys_clk                              : in  std_logic;
       c3_sys_rst_i                            : in  std_logic;
       c3_calib_done                           : out std_logic;
       c3_clk0                                 : out std_logic;
       c3_rst0                                 : out std_logic;
       mcb3_dram_dqs                           : inout  std_logic;
       mcb3_dram_ck                            : out std_logic;
       mcb3_dram_ck_n                          : out std_logic;
       c3_p0_cmd_clk                           : in std_logic;
       c3_p0_cmd_en                            : in std_logic;
       c3_p0_cmd_instr                         : in std_logic_vector(2 downto 0);
       c3_p0_cmd_bl                            : in std_logic_vector(5 downto 0);
       c3_p0_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
       c3_p0_cmd_empty                         : out std_logic;
       c3_p0_cmd_full                          : out std_logic;
       c3_p0_wr_clk                            : in std_logic;
       c3_p0_wr_en                             : in std_logic;
       c3_p0_wr_mask                           : in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
       c3_p0_wr_data                           : in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
       c3_p0_wr_full                           : out std_logic;
       c3_p0_wr_empty                          : out std_logic;
       c3_p0_wr_count                          : out std_logic_vector(6 downto 0);
       c3_p0_wr_underrun                       : out std_logic;
       c3_p0_wr_error                          : out std_logic;
       c3_p0_rd_clk                            : in std_logic;
       c3_p0_rd_en                             : in std_logic;
       c3_p0_rd_data                           : out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
       c3_p0_rd_full                           : out std_logic;
       c3_p0_rd_empty                          : out std_logic;
       c3_p0_rd_count                          : out std_logic_vector(6 downto 0);
       c3_p0_rd_overflow                       : out std_logic;
       c3_p0_rd_error                          : out std_logic;
       c3_p1_cmd_clk                           : in std_logic;
       c3_p1_cmd_en                            : in std_logic;
       c3_p1_cmd_instr                         : in std_logic_vector(2 downto 0);
       c3_p1_cmd_bl                            : in std_logic_vector(5 downto 0);
       c3_p1_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
       c3_p1_cmd_empty                         : out std_logic;
       c3_p1_cmd_full                          : out std_logic;
       c3_p1_wr_clk                            : in std_logic;
       c3_p1_wr_en                             : in std_logic;
       c3_p1_wr_mask                           : in std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
       c3_p1_wr_data                           : in std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
       c3_p1_wr_full                           : out std_logic;
       c3_p1_wr_empty                          : out std_logic;
       c3_p1_wr_count                          : out std_logic_vector(6 downto 0);
       c3_p1_wr_underrun                       : out std_logic;
       c3_p1_wr_error                          : out std_logic;
       c3_p1_rd_clk                            : in std_logic;
       c3_p1_rd_en                             : in std_logic;
       c3_p1_rd_data                           : out std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
       c3_p1_rd_full                           : out std_logic;
       c3_p1_rd_empty                          : out std_logic;
       c3_p1_rd_count                          : out std_logic_vector(6 downto 0);
       c3_p1_rd_overflow                       : out std_logic;
       c3_p1_rd_error                          : out std_logic
    );
    end component;


    component mem_test
     generic(
        MASK_SIZE           : integer := 4;
        DATA_PORT_SIZE      : integer := 32
     );
     port (
        clk : in std_logic;
        reset : in std_logic;
        run: in std_logic;
        mem_test_in_progress: out std_logic;
        mem_ok: out std_logic;
        mem_fail: out std_logic;
        --cmd_clk                           : out std_logic;
        cmd_en                            : out std_logic;
        cmd_instr                         : out std_logic_vector(2 downto 0);
        cmd_bl                            : out std_logic_vector(5 downto 0);
        cmd_byte_addr                     : out  std_logic_vector(29 downto 0);
        cmd_empty                         : in std_logic;
        cmd_full                          : in std_logic;
        --wr_clk                            : out std_logic;
        wr_en                             : out std_logic;
        wr_mask                           : out std_logic_vector(MASK_SIZE - 1 downto 0);
        wr_data                           : out std_logic_vector(DATA_PORT_SIZE - 1 downto 0);
        wr_full                           : in std_logic;
        wr_empty                          : in std_logic;
        wr_count                          : in std_logic_vector(6 downto 0);
        wr_underrun                       : in std_logic;
        wr_error                          : in std_logic;
        --rd_clk                            : out std_logic;
        rd_en                             : out std_logic;
        rd_data                           : in std_logic_vector(DATA_PORT_SIZE - 1 downto 0);
        rd_full                           : in std_logic;
        rd_empty                          : in std_logic;
        rd_count                          : in std_logic_vector(6 downto 0);
        rd_overflow                       : in std_logic;
        rd_error                          : in std_logic 
     );
    end component;
    signal bla: std_logic;
    signal should_reset: std_logic;
    signal c3_calib_done : std_logic;
    signal  c3_clk0                                  : std_logic;
    --signal  c3_rst                                   : std_logic;
    
    
    signal  c3_p0_cmd_en                             : std_logic;
    signal  c3_p0_cmd_instr                          : std_logic_vector(2 downto 0);
    signal  c3_p0_cmd_bl                             : std_logic_vector(5 downto 0);
    signal  c3_p0_cmd_byte_addr                      : std_logic_vector(29 downto 0);
    signal  c3_p0_cmd_empty                          : std_logic;
    signal  c3_p0_cmd_full                           : std_logic;
    signal  c3_p0_wr_en                              : std_logic;
    signal  c3_p0_wr_mask                            : std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
    signal  c3_p0_wr_data                            : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p0_wr_full                            : std_logic;
    signal  c3_p0_wr_empty                           : std_logic;
    signal  c3_p0_wr_count                           : std_logic_vector(6 downto 0);
    signal  c3_p0_wr_underrun                        : std_logic;
    signal  c3_p0_wr_error                           : std_logic;
    signal  c3_p0_rd_en                              : std_logic;
    signal  c3_p0_rd_data                            : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p0_rd_full                            : std_logic;
    signal  c3_p0_rd_empty                           : std_logic;
    signal  c3_p0_rd_count                           : std_logic_vector(6 downto 0);
    signal  c3_p0_rd_overflow                        : std_logic;
    signal  c3_p0_rd_error                           : std_logic;

    signal  c3_p1_cmd_en                             : std_logic;
    signal  c3_p1_cmd_instr                          : std_logic_vector(2 downto 0);
    signal  c3_p1_cmd_bl                             : std_logic_vector(5 downto 0);
    signal  c3_p1_cmd_byte_addr                      : std_logic_vector(29 downto 0);
    signal  c3_p1_cmd_empty                          : std_logic;
    signal  c3_p1_cmd_full                           : std_logic;
    signal  c3_p1_wr_en                              : std_logic;
    signal  c3_p1_wr_mask                            : std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
    signal  c3_p1_wr_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p1_wr_full                            : std_logic;
    signal  c3_p1_wr_empty                           : std_logic;
    signal  c3_p1_wr_count                           : std_logic_vector(6 downto 0);
    signal  c3_p1_wr_underrun                        : std_logic;
    signal  c3_p1_wr_error                           : std_logic;
    signal  c3_p1_rd_en                              : std_logic;
    signal  c3_p1_rd_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
    signal  c3_p1_rd_full                            : std_logic;
    signal  c3_p1_rd_empty                           : std_logic;
    signal  c3_p1_rd_count                           : std_logic_vector(6 downto 0);
    signal  c3_p1_rd_overflow                        : std_logic;
    signal  c3_p1_rd_error                           : std_logic;
begin

    LED(0) <= c3_calib_done;
    
    u_s6_lpddr : s6_lpddr
        generic map (
        C3_P0_MASK_SIZE => C3_P0_MASK_SIZE,
        C3_P0_DATA_PORT_SIZE => C3_P0_DATA_PORT_SIZE,
        C3_P1_MASK_SIZE => C3_P1_MASK_SIZE,
        C3_P1_DATA_PORT_SIZE => C3_P1_DATA_PORT_SIZE,
        C3_MEMCLK_PERIOD => C3_MEMCLK_PERIOD,
        C3_RST_ACT_LOW => C3_RST_ACT_LOW,
        C3_INPUT_CLK_TYPE => C3_INPUT_CLK_TYPE,
        C3_CALIB_SOFT_IP => C3_CALIB_SOFT_IP,
        C3_SIMULATION => C3_SIMULATION,
        -- C3_MC_CALIB_BYPASS => C3_MC_CALIB_BYPASS,
        DEBUG_EN => DEBUG_EN,
        C3_MEM_ADDR_ORDER => C3_MEM_ADDR_ORDER,
        C3_NUM_DQ_PINS => C3_NUM_DQ_PINS,
        C3_MEM_ADDR_WIDTH => C3_MEM_ADDR_WIDTH,
        C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH
    )
        port map (

    
            mcb3_dram_dq       =>    mcb3_dram_dq,  
            mcb3_dram_a        =>    mcb3_dram_a,  
            mcb3_dram_ba       =>    mcb3_dram_ba,
            mcb3_dram_ras_n    =>    mcb3_dram_ras_n,                        
            mcb3_dram_cas_n    =>    mcb3_dram_cas_n,                        
            mcb3_dram_we_n     =>    mcb3_dram_we_n,                          
            mcb3_dram_cke      =>    mcb3_dram_cke,                          
            mcb3_dram_ck       =>    mcb3_dram_ck,                          
            mcb3_dram_ck_n     =>    mcb3_dram_ck_n,       
            mcb3_dram_dqs      =>    mcb3_dram_dqs,                          
            mcb3_dram_udqs  =>       mcb3_dram_udqs,    -- for X16 parts           
            mcb3_dram_udm  =>        mcb3_dram_udm,     -- for X16 parts
            mcb3_dram_dm  =>         mcb3_dram_dm,
            c3_sys_clk =>            CLK_100MHz,
            c3_sys_rst_i =>          reset_signal,
            c3_clk0	=>	             c3_clk0,
            c3_rst0		=>           c3_rst0,
            c3_calib_done      =>    c3_calib_done,
            mcb3_rzq         =>      mcb3_rzq,
               
            c3_p0_cmd_clk                           =>  c3_clk0,
            c3_p0_cmd_en                            =>  c3_p0_cmd_en,
            c3_p0_cmd_instr                         =>  c3_p0_cmd_instr,
            c3_p0_cmd_bl                            =>  c3_p0_cmd_bl,
            c3_p0_cmd_byte_addr                     =>  c3_p0_cmd_byte_addr,
            c3_p0_cmd_empty                         =>  c3_p0_cmd_empty,
            c3_p0_cmd_full                          =>  c3_p0_cmd_full,
            c3_p0_wr_clk                            =>  c3_clk0,
            c3_p0_wr_en                             =>  c3_p0_wr_en,
            c3_p0_wr_mask                           =>  c3_p0_wr_mask,
            c3_p0_wr_data                           =>  c3_p0_wr_data,
            c3_p0_wr_full                           =>  c3_p0_wr_full,
            c3_p0_wr_empty                          =>  c3_p0_wr_empty,
            c3_p0_wr_count                          =>  c3_p0_wr_count,
            c3_p0_wr_underrun                       =>  c3_p0_wr_underrun,
            c3_p0_wr_error                          =>  c3_p0_wr_error,
            c3_p0_rd_clk                            =>  c3_clk0,
            c3_p0_rd_en                             =>  c3_p0_rd_en,
            c3_p0_rd_data                           =>  c3_p0_rd_data,
            c3_p0_rd_full                           =>  c3_p0_rd_full,
            c3_p0_rd_empty                          =>  c3_p0_rd_empty,
            c3_p0_rd_count                          =>  c3_p0_rd_count,
            c3_p0_rd_overflow                       =>  c3_p0_rd_overflow,
            c3_p0_rd_error                          =>  c3_p0_rd_error,
            
            
            c3_p1_cmd_clk                           =>  c3_clk0,
            c3_p1_cmd_en                            =>  c3_p1_cmd_en,
            c3_p1_cmd_instr                         =>  c3_p1_cmd_instr,
            c3_p1_cmd_bl                            =>  c3_p1_cmd_bl,
            c3_p1_cmd_byte_addr                     =>  c3_p1_cmd_byte_addr,
            c3_p1_cmd_empty                         =>  c3_p1_cmd_empty,
            c3_p1_cmd_full                          =>  c3_p1_cmd_full,
            c3_p1_wr_clk                            =>  c3_clk0,
            c3_p1_wr_en                             =>  c3_p1_wr_en,
            c3_p1_wr_mask                           =>  c3_p1_wr_mask,
            c3_p1_wr_data                           =>  c3_p1_wr_data,
            c3_p1_wr_full                           =>  c3_p1_wr_full,
            c3_p1_wr_empty                          =>  c3_p1_wr_empty,
            c3_p1_wr_count                          =>  c3_p1_wr_count,
            c3_p1_wr_underrun                       =>  c3_p1_wr_underrun,
            c3_p1_wr_error                          =>  c3_p1_wr_error,
            c3_p1_rd_clk                            =>  c3_clk0,
            c3_p1_rd_en                             =>  c3_p1_rd_en,
            c3_p1_rd_data                           =>  c3_p1_rd_data,
            c3_p1_rd_full                           =>  c3_p1_rd_full,
            c3_p1_rd_empty                          =>  c3_p1_rd_empty,
            c3_p1_rd_count                          =>  c3_p1_rd_count,
            c3_p1_rd_overflow                       =>  c3_p1_rd_overflow,
            c3_p1_rd_error                          =>  c3_p1_rd_error
    );
    
    c3_p1_wr_en <= '0';
    c3_p1_rd_en <= '0';
    c3_p1_cmd_en <= '0';
    
    
    
    
    should_reset <= not c3_calib_done; -- when c3_rst = '0' else '1'; -- or not c3_calib_done;
    bla <= c3_calib_done;
    
    mem_test_0: mem_test port map (
            clk  => c3_clk0,
            reset => should_reset,
            run => bla,
            
            mem_test_in_progress => LED(1),
            mem_ok => LED(2),
            mem_fail => LED(3),
                                
            --cmd_clk                           =>  c3_p0_cmd_clk,
            cmd_en                            =>  c3_p0_cmd_en,
            cmd_instr                         =>  c3_p0_cmd_instr,
            cmd_bl                            =>  c3_p0_cmd_bl,
            cmd_byte_addr                     =>  c3_p0_cmd_byte_addr,
            cmd_empty                         =>  c3_p0_cmd_empty,
            cmd_full                          =>  c3_p0_cmd_full,
            --wr_clk                            =>  c3_p0_wr_clk,
            wr_en                             =>  c3_p0_wr_en,
            wr_mask                           =>  c3_p0_wr_mask,
            wr_data                           =>  c3_p0_wr_data,
            wr_full                           =>  c3_p0_wr_full,
            wr_empty                          =>  c3_p0_wr_empty,
            wr_count                          =>  c3_p0_wr_count,
            wr_underrun                       =>  c3_p0_wr_underrun,
            wr_error                          =>  c3_p0_wr_error,
            --rd_clk                            =>  c3_p0_rd_clk,
            rd_en                             =>  c3_p0_rd_en,
            rd_data                           =>  c3_p0_rd_data,
            rd_full                           =>  c3_p0_rd_full,
            rd_empty                          =>  c3_p0_rd_empty,
            rd_count                          =>  c3_p0_rd_count,
            rd_overflow                       =>  c3_p0_rd_overflow,
            rd_error                          =>  c3_p0_rd_error  
    );
    
    

end Behavioral;

