----------------------------------------------------------------
--! @file
--! @brief Test Bench for I2C Master's Engine: To act as an i2c master
--! Updated 07/09/2016
--! Changhua DING
----------------------------------------------------------------

--- *****************************************************
--	Test the start
--
--
--- *****************************************************

--! use standard library
library ieee;
--! use logic elements and numeric elements
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! test bench for i2c_master_engine
entity tb_i2c_master_engine is

end entity tb_i2c_master_engine;

architecture Behavior of tb_i2c_master_engine is

	-- Cascadable counter
	component cascadable_counter is		
	
	generic(max_count: positive := 2);
	port (clk: in std_logic;
		 ena: in std_logic;
		 sync_rst: in std_logic;
		 casc_in: in std_logic;
		 count: out integer range 0 to (max_count-1);
		 casc_out: out std_logic);			-- Similar to clk_ena
	
	end component cascadable_counter;

	component i2c_master_engine is
	
	port(clk: in std_logic;				--! clock input
		 clk_ena: in std_logic;			--! clock enable input
		 sync_rst: in std_logic; 		--! synchronous reset input, '0' active
		 CTL_ROLE: in std_logic;		--! CTL_ROLE bit input, to activate the master engine
		 CTL_ACK: in std_logic;			--! CTL_ACK bit input
		 CTL_RW: in std_logic; 			--! CTL_RW bit input
		 CTL_RESTART: in std_logic;		--! CTL_RESTART bit input
		 CTL_STOP: in std_logic; 		--! CTL_STOP bit input
		 CTL_START: in std_logic;		--! CTL_START bit input
		 CTL_RESET: in std_logic; 		--! CTL_RESET bit input
		 ST_RX_FULL: in std_logic; 		--! ST_RX_FULL bit input
		 ST_TX_EMPTY: in std_logic; 	--! ST_TX_EMPTY bit input
		 TX_DATA: in std_logic_vector (7 downto 0);  	--! TX_DATA byte input
		 BAUD_RATE: in std_logic_vector (7 downto 0);  	--! BAUD_RATE byte input
		 SLAVE_ADDR: in std_logic_vector (6 downto 0);	--! SLAVE ADDRESS 7 bits input
		 SCL_IN: in std_logic;			--! SCL input
		 SDA_IN: in std_logic;			--! SDA input
		 
		 CTL_RESTART_C: out std_logic;			--! CTL_RESTART bit Clear output
		 CTL_STOP_C: out std_logic;				--! CTL_STOP bit Clear output
		 CTL_START_C: out std_logic;			--! CTL_START bit Clear output
		 ST_BUSY_W: out std_logic;				--! ST_BUSY bit Write output     
		 ST_RX_FULL_S: out std_logic;			--!	ST_RX_FULL bit Set output
		 ST_TX_EMPTY_S: out std_logic;			--! ST_TX_EMPTY bit set output
		 ST_RESTART_DETC_W: out std_logic; 		--! ST_RESTART_DETC bit set output
		 ST_STOP_DETC_W: out std_logic;			--! ST_STOP bit write output
		 ST_START_DETC_W: out std_logic;		--! ST_START_DETC bit write output
		 ST_ACK_REC_W: out std_logic;			--! ST_ACK_REC bit write output
		 RX_DATA_W: out std_logic_vector (7 downto 0); 	--! RX_DATA byte output
		 SCL_OUT: out std_logic;				--! SCL output
		 SDA_OUT: out std_logic					--! SDA output 
	);


	end component i2c_master_engine;




	-- Signals
	-- Constant
	constant clk_period: time := 20 ns;
	-- general signals
	signal clk_50MHz: std_logic;
	signal rst_variable: std_logic;
	-- Signals for cascadable_counter(always '1')
	signal rst_1: std_logic;
	signal ena_1: std_logic;
	signal casc_in_1: std_logic;
	signal clk_ena: std_logic;
	--------------
	--------------
	signal CTL_ROLE: std_logic;		--! CTL_ROLE bit input, to activate the master engine
	signal CTL_ACK: std_logic;			--! CTL_ACK bit input
	signal CTL_RW: std_logic; 			--! CTL_RW bit input
	signal CTL_RESTART:  std_logic;		--! CTL_RESTART bit input
	signal CTL_STOP:  std_logic ; 		--! CTL_STOP bit input
	signal CTL_START:  std_logic := '1';		--! CTL_START bit input
	signal CTL_RESET:  std_logic; 		--! CTL_RESET bit input
	signal ST_RX_FULL:  std_logic; 		--! ST_RX_FULL bit input
	signal ST_TX_EMPTY:  std_logic; 	--! ST_TX_EMPTY bit input
	signal TX_DATA:  std_logic_vector (7 downto 0);  	--! TX_DATA byte input
	signal BAUD_RATE:  std_logic_vector (7 downto 0);  	--! BAUD_RATE byte input
	signal SLAVE_ADDR:  std_logic_vector (6 downto 0);	--! SLAVE ADDRESS 7 bits input
	
	signal SCL_IN:  std_logic;			--! SCL input
	signal SDA_IN:  std_logic;			--! SDA input
	 
	signal CTL_RESTART_C:  std_logic;			--! CTL_RESTART bit Clear output
	signal CTL_STOP_C:  std_logic;				--! CTL_STOP bit Clear output
	signal CTL_START_C:  std_logic;			--! CTL_START bit Clear output
	signal ST_BUSY_W:  std_logic;				--! ST_BUSY bit Write output     
	signal ST_RX_FULL_S:  std_logic;			--!	ST_RX_FULL bit Set output
	signal ST_TX_EMPTY_S:  std_logic;			--! ST_TX_EMPTY bit set output
	signal ST_RESTART_DETC_W:  std_logic; 		--! ST_RESTART_DETC bit set output
	signal ST_STOP_DETC_W:  std_logic;			--! ST_STOP bit write output
	signal ST_START_DETC_W:  std_logic;		--! ST_START_DETC bit write output
	signal ST_ACK_REC_W:  std_logic;			--! ST_ACK_REC bit write output
	signal RX_DATA_W:  std_logic_vector (7 downto 0); 	--! RX_DATA byte output
	
	signal SCL_OUT:  std_logic;				--! SCL output
	signal SDA_OUT:  std_logic; 				--! SDA output
	
	---
	---
	signal scl_in_fast: std_logic;
	signal scl_in_slow: std_logic;
	
	
begin

	-- 1.
	M_clk_ena: cascadable_counter
	generic map (max_count => 3)
	port map(clk => clk_50MHz,
		 ena => ena_1,
		 sync_rst => rst_1,
		 casc_in => casc_in_1,
		 count => open,
		 casc_out => clk_ena);
		 
	
	-- 2.	
	M_i2c_master_engine: i2c_master_engine 
	
	port map(clk => clk_50MHz,				--! clock input
			 clk_ena => clk_ena,		--! clock enable input
			 sync_rst => rst_variable, 		--! synchronous reset input, '0' active
			 CTL_ROLE => CTL_ROLE,		--! CTL_ROLE bit input, to activate the master engine
			 CTL_ACK => CTL_ACK,			--! CTL_ACK bit input
			 CTL_RW => CTL_RW, 			--! CTL_RW bit input
			 CTL_RESTART => CTL_RESTART,		--! CTL_RESTART bit input
			 CTL_STOP => CTL_STOP, 		--! CTL_STOP bit input
			 CTL_START => CTL_START,		--! CTL_START bit input
			 CTL_RESET => CTL_RESET, 		--! CTL_RESET bit input
			 ST_RX_FULL => ST_RX_FULL, 		--! ST_RX_FULL bit input
			 ST_TX_EMPTY => ST_TX_EMPTY,	--! ST_TX_EMPTY bit input
			 TX_DATA => TX_DATA,  	--! TX_DATA byte input
			 BAUD_RATE => BAUD_RATE,  	--! BAUD_RATE byte input
			 SLAVE_ADDR => SLAVE_ADDR,	--! SLAVE ADDRESS 7 bits input
			 
			 SCL_IN => scl_in_fast,			--! SCL input					-- scl_in_fast 	!!!!!!!!!!!!!
			 SDA_IN => SDA_IN,			--! SDA input
			 
			 CTL_RESTART_C => CTL_RESTART_C,			--! CTL_RESTART bit Clear output
			 CTL_STOP_C => CTL_STOP_C,				--! CTL_STOP bit Clear output
			 CTL_START_C => CTL_START_C,			--! CTL_START bit Clear output
			 ST_BUSY_W => ST_BUSY_W,				--! ST_BUSY bit Write output     
			 ST_RX_FULL_S => ST_RX_FULL_S,			--!	ST_RX_FULL bit Set output
			 ST_TX_EMPTY_S => ST_TX_EMPTY_S,			--! ST_TX_EMPTY bit set output
			 ST_RESTART_DETC_W => ST_RESTART_DETC_W, 		--! ST_RESTART_DETC bit set output
			 ST_STOP_DETC_W => ST_STOP_DETC_W,			--! ST_STOP bit write output
			 ST_START_DETC_W => ST_START_DETC_W,		--! ST_START_DETC bit write output
			 ST_ACK_REC_W => ST_ACK_REC_W,			--! ST_ACK_REC bit write output
			 RX_DATA_W => RX_DATA_W, 	--! RX_DATA byte output
			 
			 SCL_OUT => SCL_OUT,				--! SCL output
			 SDA_OUT => SDA_OUT				--! SDA output
			);
			
			
	-- Process
	
	-- 1.
	P_clk_50MHz: process is 
	
	begin
	
		clk_50MHz <= '0';
		wait for clk_period/2;
		clk_50MHz <= '1';
		wait for clk_period/2;
		
	end process P_clk_50MHz;
	
	-- 2. P_others_signal
	P_others_signal: process is				-- set clock enable at 25MHz => period = 40 ns
	begin
	
		ena_1 <= '1'; 
		rst_1 <= '1';
		casc_in_1 <= '1';
		wait;
		
	end process P_others_signal;
	
	-- 3. sync_rst signal
	P_syncrst_signals: process is
	begin
		rst_variable <= '0';
		wait for 1 us;
		rst_variable <= '1';
		wait;
	end process P_syncrst_signals;
	
	-- 4. P_slow_scl
	P_slow_scl: process(SCL_OUT) is			-- simulate a slow scl_in 
	
	begin
		if(falling_edge(SCL_OUT)) then
			scl_in_slow <= '0';
		elsif(rising_edge(SCL_OUT)) then
			scl_in_slow <= '0', '1' after 26*clk_period;
		end if;
	end process P_slow_scl;
	
	
	
	
	-- 5. P_fast_scl
	P_fast_scl: process(SCL_OUT) is			-- simulate a fast scl_in
	
	begin
	
		scl_in_fast <= SCL_OUT;
	
	end process P_fast_scl;
	
	
	-- 6. P_fast_scl
	P_sda: process(SDA_OUT) is			-- simulate a fast scl_in
	
	begin
	
		SDA_IN <= SDA_OUT;
	
	end process P_sda;
	
	
	-- 7.
	P_CTL: process is
	
	begin
		CTL_ROLE <= '1';
		CTL_RESTART <= '0';
		
		SLAVE_ADDR <= (2 downto 0 => '1', others => '0');
		CTL_RW <= '0';		-- RW: '0' Write transmission, '1' READ request of DATA
		wait for 2 us;
		
		
		wait;
	
	end process P_CTL;
	
	-- 8.
	P_CTL_START: process(CTL_START_C) is
	
	begin
		
		if(CTL_START_C = '0') then
			CTL_START <= '0';
		else	
		end if;
	end process P_CTL_START;
	
	-- 9. TX DATA   AND   CTL_STOP
	P_TX_DATA: process(ST_TX_EMPTY_S) is
	variable number: unsigned (7 downto 0) := (1 downto 0 => '1', others => '0');
	begin
		TX_DATA <= std_logic_vector(number);
		
		if(ST_TX_EMPTY_S = '1') then
			ST_TX_EMPTY <= '1';
		
			if(number = 255) then
				number := (others => '0');
			else
				number := number + 1;
			end if;
			
			ST_TX_EMPTY <= '0';
			
		else
		end if;
		
		-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		-- ???????????????????????????????????????????????????????????????????????????????????????????
		-- The shift transmitter will only transmit untill number "8" but "9".
		if(number >= 10) then
			CTL_STOP <= '1';
		else
			CTL_STOP <= '0';
		
		end if;
	
	
	end process P_TX_DATA;
	
	

end architecture Behavior;