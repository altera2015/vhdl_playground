library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity machine is

    generic(
        C3_P0_MASK_SIZE           : integer := 4;
        C3_P0_DATA_PORT_SIZE      : integer := 32;
        C3_P1_MASK_SIZE           : integer := 4;
        C3_P1_DATA_PORT_SIZE      : integer := 32;
        C3_MEMCLK_PERIOD        : integer := 6000; 
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

    port ( 
        clk_100mhz : in std_logic;
        reset_button : in std_logic; -- button is high when not pressed.
        LED : out std_logic_vector(7 downto 0);
        SevenSegment : out  std_logic_vector (7 downto 0);
        SevenSegmentEnable : out  std_logic_vector (2 downto 0);        
        -- VGA output
        hsync : out  std_logic;
        vsync : out  std_logic;
        red : out  std_logic_vector (2 downto 0);
        green : out  std_logic_vector (2 downto 0);
        blue : out  std_logic_vector (2 downto 1);
        
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

architecture machine_arch of machine is

    component core_clock
        port (
            -- Clock in ports
            CLK_IN1           : in     std_logic;
            -- Clock out ports
            CLK_100          : out    std_logic;
            CLK_50          : out    std_logic;
            CLK_166          : out    std_logic;
            -- Status and control signals
            RESET             : in     std_logic;
            LOCKED            : out    std_logic
        );
    end component;

    component vga
        generic (
            
            H_VISIBLE       : integer := 800;
            H_FRONT_PORCH   : integer := 56;
            H_SYNC_PULSE    : integer := 120;
            H_BACK_PORCH    : integer := 64;
        
            V_VISIBLE       : integer := 600;
            V_FRONT_PORCH   : integer := 37;
            V_SYNC_PULSE    : integer := 6;
            V_BACK_PORCH    : integer := 23
            
        );
        port (
            clk      : in std_logic; -- expecting 100MHz.
            h_sync_n : out std_logic;
            v_sync_n : out std_logic;
            x        : out unsigned(9 downto 0);
            y        : out unsigned(9 downto 0);
            blank    : out std_logic  
        );
    
    end component;
    
    
    --
    -- Warning, when recreating the lpddr3 core a critical modification
    -- to the RTL files will be lost.
    -- 
    -- The IBUF needs to be removed from user_design/rtl/memc3_infrastructure.vhd
    --
    component lpddr3
        generic(
            C3_P0_MASK_SIZE           : integer := 4;
            C3_P0_DATA_PORT_SIZE      : integer := 32;
            C3_P1_MASK_SIZE           : integer := 4;
            C3_P1_DATA_PORT_SIZE      : integer := 32;
            C3_MEMCLK_PERIOD          : integer := 6000;
            C3_RST_ACT_LOW            : integer := 0;
            C3_INPUT_CLK_TYPE         : string := "SINGLE_ENDED";
            C3_CALIB_SOFT_IP          : string := "TRUE";
            C3_SIMULATION             : string := "FALSE";
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
    
    
    -- Memory Connectivity.    
    signal  c3_calib_done                            : std_logic;
    signal  c3_clk0                                  : std_logic;
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
    
    
    
    
    -- VGA Output
    signal x: unsigned(9 downto 0);
    signal y: unsigned(9 downto 0);
    signal blank: std_logic;
    signal CLK_50 : std_logic;
    signal CLK_100 : std_logic;
    signal CLK_166 : std_logic;
    signal RESET : std_logic;
    signal LOCKED : std_logic; 

begin
        

    RESET <= not reset_button;
               
    vga_0: vga port map (
       clk => c3_clk0,
       h_sync_n => hsync,
       v_sync_n => vsync,
       x => x,
       y => y,
       blank => blank
    );
    
    
    u_lpddr3 : lpddr3 generic map (
        C3_P0_MASK_SIZE => C3_P0_MASK_SIZE,
        C3_P0_DATA_PORT_SIZE => C3_P0_DATA_PORT_SIZE,
        C3_P1_MASK_SIZE => C3_P1_MASK_SIZE,
        C3_P1_DATA_PORT_SIZE => C3_P1_DATA_PORT_SIZE,
        C3_MEMCLK_PERIOD => C3_MEMCLK_PERIOD,
        C3_RST_ACT_LOW => C3_RST_ACT_LOW,
        C3_INPUT_CLK_TYPE => C3_INPUT_CLK_TYPE,
        C3_CALIB_SOFT_IP => C3_CALIB_SOFT_IP,
        C3_SIMULATION => C3_SIMULATION,
        DEBUG_EN => DEBUG_EN,
        C3_MEM_ADDR_ORDER => C3_MEM_ADDR_ORDER,
        C3_NUM_DQ_PINS => C3_NUM_DQ_PINS,
        C3_MEM_ADDR_WIDTH => C3_MEM_ADDR_WIDTH,
        C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH
    ) port map (
    
        -- clock and reset inputs
        c3_sys_clk         =>    clk_100mhz,
        c3_sys_rst_i       =>    RESET,                        

        -- Pinouts
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
        mcb3_dram_udqs     =>    mcb3_dram_udqs,    -- for X16 parts           
        mcb3_dram_udm      =>    mcb3_dram_udm,     -- for X16 parts
        mcb3_dram_dm       =>    mcb3_dram_dm,
        mcb3_rzq           =>    mcb3_rzq,

        -- clock output.
        c3_clk0	           =>    c3_clk0,
        -- reset
        c3_rst0		       =>    c3_rst0,
        -- calibration done
        c3_calib_done      =>    c3_calib_done,

        -- MIG
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
    
    

    -- disable 7 segment displays
    SevenSegmentEnable <= "111";
    SevenSegment <= "11111111";

    -- LED outputs
    LED(0) <= c3_calib_done;    
    LED(1) <= '0';
    LED(2) <= '0';
    LED(3) <= '0';
    LED(4) <= '0';
    LED(5) <= '0';
    LED(6) <= '0';
    LED(7) <= '0';
    
    -- disable interfaces for now.
    c3_p1_wr_en <= '0';
    c3_p1_rd_en <= '0';
    c3_p1_cmd_en <= '0';
    
    c3_p0_wr_en <= '0';
    c3_p0_rd_en <= '0';
    c3_p0_cmd_en <= '0';


    -- Red, white and blue!
    red <= "111" when blank='0' and y < 400 else "000";
    green <= "111" when blank='0' and y>=200 and y < 400 else "000";
    blue <= "11" when blank='0' and y >= 200 else "00";  

end machine_arch;

