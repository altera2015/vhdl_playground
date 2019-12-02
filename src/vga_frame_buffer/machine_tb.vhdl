--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:06:03 12/02/2019
-- Design Name:   
-- Module Name:   /home/ise/devel/vhdl_playground/src/vga_frame_buffer/machine_tb.vhdl
-- Project Name:  vga_frame_buffer
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
library unisim;
use unisim.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY machine_tb IS
END machine_tb;
 
ARCHITECTURE behavior OF machine_tb IS 
 
   
   constant DEBUG_EN             : integer :=0;   
   constant C3_HW_TESTING      : string := "FALSE";
 
   constant  C3_MEMCLK_PERIOD : integer    := 6000;
   constant C3_RST_ACT_LOW : integer := 0;
   constant C3_INPUT_CLK_TYPE : string := "SINGLE_ENDED";
   constant C3_CLK_PERIOD_NS   : real := 6.0; -- 10000.0 / 1000.0;
   constant C3_TCYC_SYS        : real := C3_CLK_PERIOD_NS/2.0;
   constant C3_TCYC_SYS_DIV2   : time := C3_TCYC_SYS * 1 ns;
   constant C3_NUM_DQ_PINS        : integer := 16;
   constant C3_MEM_ADDR_WIDTH     : integer := 13;
   constant C3_MEM_BANKADDR_WIDTH : integer := 2;
   constant C3_MEM_ADDR_ORDER     : string := "ROW_BANK_COLUMN"; 
      constant C3_P0_MASK_SIZE : integer      := 4;
   constant C3_P0_DATA_PORT_SIZE : integer := 32;  
   constant C3_P1_MASK_SIZE   : integer    := 4;
   constant C3_P1_DATA_PORT_SIZE  : integer := 32;
   constant C3_CALIB_SOFT_IP      : string := "TRUE";
   constant C3_SIMULATION      : string := "TRUE";
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT machine 
    Generic (
        C3_SIMULATION           : string := "FALSE"
    ); 
    PORT(
         clk_100mhz : IN  std_logic;
         reset_button : IN  std_logic;
         restart_button : IN  std_logic;
         LED : OUT  std_logic_vector(7 downto 0);
         SevenSegment : OUT  std_logic_vector(7 downto 0);
         SevenSegmentEnable : OUT  std_logic_vector(2 downto 0);
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         red : OUT  std_logic_vector(2 downto 0);
         green : OUT  std_logic_vector(2 downto 0);
         blue : OUT  std_logic_vector(2 downto 1);
         mcb3_dram_dq : INOUT  std_logic_vector(15 downto 0);
         mcb3_dram_a : OUT  std_logic_vector(12 downto 0);
         mcb3_dram_ba : OUT  std_logic_vector(1 downto 0);
         mcb3_dram_cke : OUT  std_logic;
         mcb3_dram_ras_n : OUT  std_logic;
         mcb3_dram_cas_n : OUT  std_logic;
         mcb3_dram_we_n : OUT  std_logic;
         mcb3_dram_dm : OUT  std_logic;
         mcb3_dram_udqs : INOUT  std_logic;
         mcb3_rzq : INOUT  std_logic;
         mcb3_dram_udm : OUT  std_logic;
         mcb3_dram_dqs : INOUT  std_logic;
         mcb3_dram_ck : OUT  std_logic;
         mcb3_dram_ck_n : OUT  std_logic;
         c3_rst0 : OUT  std_logic
        );
    END COMPONENT;
    
    component lpddr_model_c3 is
    port (
      Clk     : in    std_logic;
      Clk_n   : in    std_logic;
      Cke     : in    std_logic;
      Cs_n    : in    std_logic;
      Ras_n   : in    std_logic;
      Cas_n   : in    std_logic;
      We_n    : in    std_logic;
      Dm      : inout std_logic_vector((C3_NUM_DQ_PINS/16) downto 0);
      Ba      : in    std_logic_vector((C3_MEM_BANKADDR_WIDTH - 1) downto 0);
      Addr    : in    std_logic_vector((C3_MEM_ADDR_WIDTH  - 1) downto 0);
      Dq      : inout std_logic_vector((C3_NUM_DQ_PINS - 1) downto 0);
      Dqs     : inout std_logic_vector((C3_NUM_DQ_PINS/16) downto 0)
      );
    end component;
 


   --Inputs
   signal clk_100mhz : std_logic := '0';
   signal reset_button : std_logic := '0';
   signal restart_button : std_logic := '0';

	--BiDirs
   signal mcb3_dram_dq : std_logic_vector(15 downto 0);
   signal mcb3_dram_udqs : std_logic;
   signal mcb3_rzq : std_logic;
   signal mcb3_dram_dqs : std_logic;

 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal SevenSegment : std_logic_vector(7 downto 0);
   signal SevenSegmentEnable : std_logic_vector(2 downto 0);
   signal hsync : std_logic;
   signal vsync : std_logic;
   signal red : std_logic_vector(2 downto 0);
   signal green : std_logic_vector(2 downto 0);
   signal blue : std_logic_vector(2 downto 1);
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
   signal c3_rst0 : std_logic;

   -- Clock period definitions
   constant clk_100mhz_period : time := 10 ns;

   signal mcb3_dram_dqs_vector : std_logic_vector(1 downto 0);  
   signal mcb3_dram_dm_vector : std_logic_vector(1 downto 0);
   signal mcb3_command               : std_logic_vector(2 downto 0);
   signal mcb3_enable1                : std_logic;
   signal mcb3_enable2              : std_logic
;  
  
BEGIN
 
   rzq_pulldown3 : PULLDOWN port map(O => mcb3_rzq);
   mcb3_command <= (mcb3_dram_ras_n & mcb3_dram_cas_n & mcb3_dram_we_n);

   process(mcb3_dram_ck)
   begin
      if (rising_edge(mcb3_dram_ck)) then
        if (reset_button = '0') then
          mcb3_enable1   <= '0';
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
 
 -----------------------------------------------------------------------------
--read
-----------------------------------------------------------------------------
    mcb3_dram_dqs_vector(1 downto 0)               <= (mcb3_dram_udqs & mcb3_dram_dqs)
                                                           when (mcb3_enable2 = '0' and mcb3_enable1 = '0')
							   else "ZZ";

-----------------------------------------------------------------------------
--write
-----------------------------------------------------------------------------
    mcb3_dram_dqs          <= mcb3_dram_dqs_vector(0)
                              when ( mcb3_enable1 = '1') else 'Z';

    mcb3_dram_udqs          <= mcb3_dram_dqs_vector(1)
                              when (mcb3_enable1 = '1') else 'Z';
    mcb3_dram_dm_vector <= (mcb3_dram_udm & mcb3_dram_dm);
    
     u_mem_c3 : lpddr_model_c3 port map(
        Clk        => mcb3_dram_ck,
        Clk_n      => mcb3_dram_ck_n,
        Cke       => mcb3_dram_cke,
        Cs_n      => '0',
        Ras_n     => mcb3_dram_ras_n,
        Cas_n     => mcb3_dram_cas_n,
        We_n      => mcb3_dram_we_n,
        Dm        => mcb3_dram_dm_vector ,
        Ba        => mcb3_dram_ba,
        Addr      => mcb3_dram_a,
        Dq        => mcb3_dram_dq,
        Dqs       => mcb3_dram_dqs_vector
      );

 
	-- Instantiate the Unit Under Test (UUT)
   uut: machine Generic map (
        C3_SIMULATION => C3_SIMULATION   
   ) PORT MAP (
          clk_100mhz => clk_100mhz,
          reset_button => reset_button,
          restart_button => restart_button,
          LED => LED,
          SevenSegment => SevenSegment,
          SevenSegmentEnable => SevenSegmentEnable,
          hsync => hsync,
          vsync => vsync,
          red => red,
          green => green,
          blue => blue,
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
   clk_100mhz_process :process
   begin
		clk_100mhz <= '0';
		wait for clk_100mhz_period/2;
		clk_100mhz <= '1';
		wait for clk_100mhz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset_button <= '0';
      restart_button <= '0';
      wait for 100 ns;	
      reset_button <= '1';
      restart_button <= '1';
      
      wait for clk_100mhz_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
