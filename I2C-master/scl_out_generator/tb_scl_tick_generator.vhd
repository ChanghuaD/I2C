-- Test bench for max_cycles.vhd
-- Baud Rate Divisor: 8
-- generate a 50MHz clk_50MHz ==> (period = 20 ns), clock enable: ena = 25MHz, reset
-- 20/06/2016

library ieee;
use ieee.std_logic_1164.all;

entity tb_scl_tick_generator is
end entity tb_scl_tick_generator;

architecture Behavioral of tb_scl_tick_generator is 

	component scl_tick_generator is
		
	generic( max_count: positive := 8);
	
	port( clk_50MHz: in std_logic;
			sync_rst: in std_logic;
			ena: in std_logic;
--			casc_in: in std_logic;
--			count: out integer range 0 to (max_count-1);
			scl_tick: out std_logic);
	end component;
	
	-- generate the clk_ena
	component cascadable_counter is

	generic(max_count: positive := 2);
	port (  clk: in std_logic;
		ena: in std_logic;
		sync_rst: std_logic;
		casc_in: in std_logic;
		count: out integer range 0 to (max_count-1);
		casc_out: out std_logic
		);

	end component;
	
	signal clk_50MHz: std_logic;
	signal sync_rst: std_logic;
	signal ena: std_logic;
	signal casc_in: std_logic;
	signal count: integer;   -- connect to uut
	signal scl_tick: std_logic;
	
	signal rst_1: std_logic;
	signal clk_ena: std_logic;

	constant clk_period: time := 20 ns;
begin 

	-- Generator of the clock enable signal: clk_ena
	gen_ena: cascadable_counter
		
		generic map(max_count => 3)
		port map(clk => clk_50MHz,
			sync_rst => rst_1,
			ena => ena,
			casc_in => casc_in,
			count => open,
			casc_out => clk_ena);




	-- UUT for the max_cycles
	uut:  scl_tick_generator
	
		generic map(max_count => 8)
		port map(clk_50MHz => clk_50MHz,
				sync_rst => sync_rst,
				ena => clk_ena,						-- !!!!!!!!! clk_ena
		--		casc_in => casc_in,
		--		count => count,
				scl_tick => scl_tick);
			
	-- 1. set clk_50MHz at 50MHz => period = 20 ns
	P_clk_signal: process is
	begin
		
		clk_50MHz <= '0';
		wait for clk_period/2;
		clk_50MHz <= '1';
		wait for clk_period/2;
		
	end process P_clk_signal;	
	
	-- 2. set clock enable at 25MHz => period = 40 ns
	P_ena_signal: process is
	begin
	
		ena <= '1'; 
		rst_1 <= '1';
		wait;
		
	end process P_ena_signal;
	
	

	
	
	-- 3. set other signal
	P_other_signals: process is
	begin
		sync_rst <= '1';
		casc_in <= '1';
		wait for 100 ns;
		sync_rst <= '0' ;
		wait for 100 ns;
		sync_rst <= '1';
		wait for 500 ns;
		sync_rst <= '0';
		wait for 500 ns;
		sync_rst <= '1';
		wait for 40 us;
		sync_rst <= '0';
		wait for 40 us;
	end process P_other_signals;

	
	
end Behavioral;

