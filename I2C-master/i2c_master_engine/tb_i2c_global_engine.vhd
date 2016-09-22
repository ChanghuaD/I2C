--!@file Testbench for I2C global engine
--!@brief Simulate a avalon master(Microcontroller) which control the register via avalon interface
--!@details 

------------------------------------------------------
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Result of testbench 
-- 1. we have to initiate the i2c_global_engine synchronous reset input at '0', in order to initiate the register's value and evite the 'U' or 'X' value in the register
-- 2. for IRQ_TX_EMPTY 










-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_i2c_global_engine is

end entity tb_i2c_global_engine;

architecture Behaviroal of tb_i2c_global_engine is


	component i2c_global_engine is

	generic (N: positive := 3);

	port(AVALON_clk: in std_logic;						-- clk input
		 --clk_ena: in std_logic;					-- clk_ena input
		 sync_rst: in std_logic; 				-- synchronous reset input	
		
		 -- AVALON INPUT PORTS
		 -- AVALON MM SIGNALS
		 AVALON_address: in unsigned (3 downto 0);		
		 AVALON_read: in std_logic;
		 AVALON_write: in std_logic;
		 AVALON_writedata: in std_logic_vector (7 downto 0);
		 
		 -- I2C INPUT PORTS
		 SCL_IN: in std_logic;			--! SCL input
		 SDA_IN: in std_logic;			--! SDA input
		 
		 
		 -- AVALON OUTPUT PORTS
		 -- interrupt IRQ SIGNALS
		 -- 
		 AVALON_irq: out std_logic;
		 
		 -- readdata
		 AVALON_readdata: out std_logic_vector(7 downto 0);
		 AVALON_readvalid: out std_logic;
		 
		 -- waitrequest
		 AVALON_waitrequest: out std_logic;
		 
		 
		 -- I2C OUTPUT PORTS
		 SCL_OUT: out std_logic;				--! SCL output
		 SDA_OUT: out std_logic 				--! SDA output

	);
	end component i2c_global_engine;

	------------ SIGNALS -------------------
	-- Signals
	-- Constant
	constant clk_period: time := 20 ns;
	
	signal clk_50MHz: std_logic;
	signal sync_rst: std_logic;
	signal AVALON_address: unsigned (3 downto 0);
	signal AVALON_read: std_logic;
	signal AVALON_write: std_logic;
	signal AVALON_writedata:  std_logic_vector (7 downto 0);
	signal AVALON_readdata: std_logic_vector (7 downto 0);
	signal AVALON_readvalid: std_logic;
	signal AVALON_waitrequest: std_logic;
	signal AVALON_irq: std_logic;
	
	signal SCL: std_logic;
	signal SDA: std_logic;			--! SDA input
	
begin

	------------------ Map	-----------------------
	uut: i2c_global_engine
	port map(AVALON_clk => clk_50MHz,						-- clk input
		 sync_rst => sync_rst, 				-- synchronous reset input	
		
		 -- AVALON INPUT PORTS
		 -- AVALON MM SIGNALS
		 AVALON_address => AVALON_address,		
		 AVALON_read => AVALON_read,
		 AVALON_write => AVALON_write,
		 AVALON_writedata => AVALON_writedata,
		 
		 -- I2C INPUT PORTS
		 SCL_IN => SCL,			--! SCL input
		 SDA_IN => SDA,			--! SDA input
		 
		 
		 -- AVALON OUTPUT PORTS
		 -- interrupt IRQ SIGNALS
		 -- 
		 AVALON_irq => AVALON_irq,
		 
		 -- readdata
		 AVALON_readdata => AVALON_readdata,
		 AVALON_readvalid => AVALON_readvalid,
		 
		 -- waitrequest
		 AVALON_waitrequest => AVALON_waitrequest,
		 
		 
		 -- I2C OUTPUT PORTS
		 SCL_OUT => SCL,				--! SCL output
		 SDA_OUT => SDA 				--! SDA output

	);
	
	
	--------------- Process --------------
	
	
	-- 1.
	-- Avalon clock
	P_clk_50_MHz: process is
	begin
		clk_50MHz <= '0';
		wait for clk_period/2;
		clk_50MHz <= '1';
		wait for clk_period/2;
	end process P_clk_50_MHz;
	
	-- 2.
	-- sync_rst
	P_sync_rst: process is 
	begin
		sync_rst <= '0';
		wait for clk_period;
		sync_rst <= '1';
		wait;
	end process P_sync_rst;
	
	-- 3.
	P_avalon: process is
	begin
		
		
		AVALON_address <= "0000";	-- 
		AVALON_read <= '0';
		AVALON_write <= '0';
		AVALON_writedata <= "00000000";
		wait for 11 ns;
		AVALON_address <= "0010";			-- write TX register "0101010101"
		AVALON_write <= '1';
		AVALON_writedata <= "01010101";
		wait for clk_period;
		AVALON_address <= "0000";			-- Initiation
		AVALON_write <= '1';
		AVALON_writedata <= "00000000";
		wait for clk_period;
		AVALON_address <= "0010";			-- Read TX register 
		AVALON_write <= '0';
		AVALON_read <= '1';
		AVALON_writedata <= "00000000";
		wait for clk_period;
		AVALON_address <= "0101";			-- Write slave address 7-bit "0000111"
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00000111";
		wait for clk_period;
		AVALON_address <= "1010";			-- Write irq status mask "01111111"
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "01111111";
		wait for clk_period;
		AVALON_address <= "0111";			-- Write irq ctl mask "01111111"
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00001110";
		wait for clk_period;
		AVALON_address <= "0000";			-- Write CTL, CTL_role = '1',CTL_RW = '0', CTL_START = '1', CTL_RESET = '1'
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "01000011";
		wait for clk_period;
		AVALON_write <= '0';
		AVALON_read <= '0';
		
		wait until (AVALON_irq = '1');		-- irq_ctl_Start
		wait for 1 ns;
		AVALON_address <= "1001";			-- Read IRQ_CTL 
		AVALON_write <= '0';
		AVALON_read <= '1';
		AVALON_writedata <= "00000000";
		wait for clk_period;
		AVALON_address <= "1010";			-- Read IRQ_ST 
		AVALON_write <= '0';
		AVALON_read <= '1';
		AVALON_writedata <= "00000000";
		wait for clk_period;
		AVALON_address <= "0000";			-- Write CTL, CTL_role = '1', CTL_RESET = '1', clear CTL_START
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "01000001";
		wait for clk_period;
		AVALON_address <= "1000";			-- Write Clear IRQ_CTL_START 
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00000010";
	
		--- ACK after slave_address and RW
		wait until (AVALON_irq = '1');		-- IRQ_ST_ACK_REC
		wait for 1 ns;
		AVALON_address <= "1010";			-- Read IRQ_ST 
		AVALON_write <= '0';
		AVALON_read <= '1';
		AVALON_writedata <= "00000000";
		wait for clk_period;
		AVALON_address <= "1001";			-- Read IRQ_CTL 
		AVALON_write <= '0';
		AVALON_read <= '1';
		AVALON_writedata <= "00000000";
		wait for clk_period;
		AVALON_address <= "0001";			-- Read ST 
		AVALON_write <= '0';
		AVALON_read <= '1';
		AVALON_writedata <= "00000000";
		wait for clk_period;
		AVALON_address <= "1011";			-- CLEAR IRQ_ST_ACK_REC
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00000001";
		
		
		
		
		wait until (AVALON_irq = '1');		-- IRQ_ST_TX_EMPTY 
		wait for 1 ns;
		AVALON_address <= "1011";			-- CLEAR IRQ_ST_TX_EMPTY, IRQ_ST_ACK_REC = '0' and IRQ_ST_TX_EMPTY = '1' 
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00010000";
		
		
		wait until (AVALON_irq = '1');		-- IRQ_ST_ACK_REC 
		wait for 1 ns;
		AVALON_address <= "0010";			-- write TX register "11110000"
		AVALON_write <= '1';
		AVALON_writedata <= "11110000";
		wait for clk_period;
		AVALON_address <= "0001";			-- CLEAR ST_TX_EMPTY
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00010000";
		wait for clk_period;
		AVALON_address <= "1011";			-- CLEAR IRQ_ST_ACK_REC, IRQ_ST_ACK_REC = '1' and IRQ_ST_TX_EMPTY = '0' 
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00000001";
		
		wait until (AVALON_irq = '1');		-- IRQ_ST_TX_EMPTY 
		wait for 1 ns;
		AVALON_address <= "1011";			-- CLEAR IRQ_ST_TX_EMPTY, IRQ_ST_ACK_REC = '0' and IRQ_ST_TX_EMPTY = '1' 
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00010000";
		
		wait until (AVALON_irq = '1');		-- IRQ_ST_ACK_REC 
		wait for 1 ns;
		AVALON_address <= "0001";			-- CLEAR ST_TX_EMPTY
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00010000";
		wait for clk_period;
		AVALON_address <= "1011";			-- CLEAR IRQ_ST_ACK_REC, IRQ_ST_ACK_REC = '1' and IRQ_ST_TX_EMPTY = '0' 
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "00000001";
		wait for clk_period;
		AVALON_address <= "0000";			-- Write CTL, CTL_role = '1',CTL_RW = '0', CTL_START = '1', CTL_RESET = '1'
		AVALON_write <= '1';
		AVALON_read <= '0';
		AVALON_writedata <= "01000101";
		
		
		wait;
		
		
		
	
	end process P_avalon;

	
	
	
	
end architecture;