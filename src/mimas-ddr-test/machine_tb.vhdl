--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:31:55 11/19/2019
-- Design Name:   
-- Module Name:   /home/ise/devel/vhdl_playground/src/mimas-ddr-test/machine_tb.vhdl
-- Project Name:  mimas-ddr-test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: machine
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
library unisim;
use unisim.vcomponents.all;

ENTITY machine_tb IS
END machine_tb;
 
ARCHITECTURE behavior OF machine_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT machine
    GENERIC(
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
        C3_SIMULATION           : string := "TRUE"; 
                                           -- # = TRUE, Simulating the design. Useful to reduce the simulation time,
                                           -- # = FALSE, Implementing the design.
        C3_MC_CALIB_BYPASS      : string := "TRUE";
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
    PORT(
         CLK_100MHz : IN  std_logic;
         DPSwitch : IN  std_logic_vector(7 downto 0);        
         reset_signal : in  std_logic;
         LED : OUT  std_logic_vector(7 downto 0);
         SevenSegment : OUT  std_logic_vector(7 downto 0);
         SevenSegmentEnable : OUT  std_logic_vector(2 downto 0);
             
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
    END COMPONENT;
    
    component lpddr_model_c3
        port (
            Clk : in std_logic;
            Clk_n : in std_logic;
            Cke : in std_logic;
            Cs_n : in std_logic;
            Ras_n : in std_logic;
            Cas_n : in std_logic;
            We_n : in std_logic;
            Addr : in std_logic_vector(12 downto 0);
            Ba : in std_logic_vector(1 downto 0);
            Dq : inout std_logic_vector(15 downto 0);
            Dqs : inout std_logic_vector(1 downto 0);
            Dm : inout std_logic_vector(1 downto 0)
       );
    end component;

   --Inputs
   signal CLK_100MHz : std_logic := '0';
   signal DPSwitch : std_logic_vector(7 downto 0) := (others => '0');
   -- signal Switch : std_logic_vector(5 downto 0) := (others => '0');

	--BiDirs;
   signal mcb3_rzq : std_logic;


 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal SevenSegment : std_logic_vector(7 downto 0);
   signal SevenSegmentEnable : std_logic_vector(2 downto 0);
   

   signal mcb3_dram_dqs : std_logic;
   signal mcb3_dram_udqs : std_logic;
   signal mcb3_dram_dq : std_logic_vector(15 downto 0);
   signal mcb3_dram_a : std_logic_vector(12 downto 0);
   signal mcb3_dram_ba : std_logic_vector(1 downto 0);
   signal mcb3_dram_cke : std_logic;
   signal mcb3_dram_ras_n : std_logic;
   signal mcb3_dram_cas_n : std_logic;
   signal mcb3_dram_we_n : std_logic;
   signal mcb3_dram_dm : std_logic;
   signal mcb3_dram_udm : std_logic;
   signal mcb3_dram_ck : std_logic;
   signal mcb3_dram_ck_n : std_logic;
   signal ram_cs: std_logic;
   signal mcb3_dram_dmsv : std_logic_vector(1 downto 0);
   signal mcb3_dram_dqsv : std_logic_vector(1 downto 0);
   -- signal mcb3_dram_dqs_vector : std_logic_vector(1 downto 0);
   
   signal c3_rst0 : std_logic;
   
   -- Clock period definitions
   constant CLK_100MHz_period : time := 10 ns;
   signal reset_signal: std_logic;
    
    
   signal mcb3_command               : std_logic_vector(2 downto 0);
   signal mcb3_enable1                : std_logic;
   signal mcb3_enable2              : std_logic;    
BEGIN
    
-- ========================================================================== --
-- Memory model instances                                                     -- 
-- ========================================================================== --

    mcb3_command <= (mcb3_dram_ras_n & mcb3_dram_cas_n & mcb3_dram_we_n);

    process(mcb3_dram_ck)
    begin
      if (rising_edge(mcb3_dram_ck)) then
        if (c3_rst0 = '1') then
          mcb3_enable1 <= '0';
          mcb3_enable2 <= '0';
        elsif (mcb3_command = "100") then
          mcb3_enable2 <= '0';
        elsif (mcb3_command = "101") then
          mcb3_enable2 <= '1';
        else
          mcb3_enable2 <= mcb3_enable2;
        end if;
        mcb3_enable1     <= mcb3_enable2;
      end if;
    end process;

    lpddr_model_c3_0 : lpddr_model_c3 port map (
    
            Clk => mcb3_dram_ck,
            Clk_n => mcb3_dram_ck_n,
            Cke => mcb3_dram_cke,
            Cs_n => ram_cs,
            Ras_n => mcb3_dram_ras_n,
            Cas_n => mcb3_dram_cas_n,
            We_n =>mcb3_dram_we_n,
            Addr => mcb3_dram_a,
            Ba => mcb3_dram_ba,
            Dq =>mcb3_dram_dq,
            Dqs => mcb3_dram_dqsv,
            Dm => mcb3_dram_dmsv
    );
    

-----------------------------------------------------------------------------
--read
-----------------------------------------------------------------------------
    mcb3_dram_dqsv(1 downto 0) <= (mcb3_dram_udqs & mcb3_dram_dqs)
                                                          when (mcb3_enable2 = '0' and mcb3_enable1 = '0')
						   else "ZZ";

-----------------------------------------------------------------------------
--write
-----------------------------------------------------------------------------
    mcb3_dram_dqs          <= mcb3_dram_dqsv(0)
                              when ( mcb3_enable1 = '1') else 'Z';

    mcb3_dram_udqs          <= mcb3_dram_dqsv(1)
                              when (mcb3_enable1 = '1') else 'Z';    
    
    mcb3_dram_dmsv <= mcb3_dram_udm & mcb3_dram_dm;
    --mcb3_dram_dqsv <= mcb3_dram_udqs & mcb3_dram_dqs;
    
    ram_cs <= '0';
    

    rzq_pulldown3 : PULLDOWN port map(O => mcb3_rzq);
    --mcb3_rzq <= 'L';
    
	-- Instantiate the Unit Under Test (UUT)
   uut: machine PORT MAP (
          CLK_100MHz => CLK_100MHz,
          DPSwitch => DPSwitch,
          reset_signal => reset_signal,
          LED => LED,
          SevenSegment => SevenSegment,
          SevenSegmentEnable => SevenSegmentEnable,
          
          mcb3_dram_dq => mcb3_dram_dq,
          mcb3_dram_a => mcb3_dram_a,
          mcb3_dram_ba => mcb3_dram_ba,
          mcb3_dram_cke => mcb3_dram_cke,
          mcb3_dram_ras_n => mcb3_dram_ras_n,
          mcb3_dram_cas_n => mcb3_dram_cas_n,
          mcb3_dram_we_n => mcb3_dram_we_n,
          mcb3_dram_dm => mcb3_dram_dm,
          mcb3_dram_udqs => mcb3_dram_udqs,
          mcb3_rzq => mcb3_rzq,
          mcb3_dram_udm => mcb3_dram_udm,
          mcb3_dram_dqs => mcb3_dram_dqs,
          mcb3_dram_ck => mcb3_dram_ck,
          mcb3_dram_ck_n => mcb3_dram_ck_n,
          c3_rst0 => c3_rst0
        );

   -- Clock process definitions
   CLK_100MHz_process :process
   begin
		CLK_100MHz <= '0';
		wait for CLK_100MHz_period/2;
		CLK_100MHz <= '1';
		wait for CLK_100MHz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset_signal <= '1';
      wait for 100 ns;	
      reset_signal <= '0';

      wait for CLK_100MHz_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
