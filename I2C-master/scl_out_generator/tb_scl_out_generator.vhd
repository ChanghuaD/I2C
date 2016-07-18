-- Test bench to test scl_out.vhd
-- This test bench include three entities: 
-- 	1.	cascadable_counter (to generate a clk_ena signal)
--	2.	scl_tick_generator (to generate scl_tick signal)
--	3. 	scl_out (verify the signal scl_out from this entity)
--
--	05/07/2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;	 	


entity tb_scl_out_generator is 
end entity tb_scl_out_generator;


architecture Behavioral of tb_scl_out_generator is

	-- component cascadable_counter
	component cascadable_counter is
	
	generic(max_count: positive := 2);
	port (clk: in std_logic;
		 ena: in std_logic;
		 sync_rst:std_logic;
		 casc_in: in std_logic;
		 count: out integer range 0 to (max_count-1);
		 casc_out: out std_logic);
	
	end component cascadable_counter;

	
	-- component scl_tick_generator
	component scl_tick_generator is
	
	generic( max_count: positive := 8);
	
	port(clk_50MHz: in std_logic;
		 sync_rst: in std_logic;
		 ena: in std_logic;
		 scl_tick: out std_logic);
		
	end component scl_tick_generator;
	
	
	
	-- component scl_out
	component scl_out_generator is 

	generic(max_state: positive := 8);
	
	port(clk: in std_logic;
		 rst: in std_logic;
		 scl_tick: in std_logic;			-- receive the scl_in signal from scl_tick_generator entity 
		 scl_in: in std_logic;
		scl_out: out std_logic);
		 
	end component scl_out_generator;
	
	
	
	-- The signals
	signal clk_50MHz: std_logic;
	signal rst_1: std_logic;			-- Always 1
	signal ena_1: std_logic;			-- Always 1
	signal casc_in_1: std_logic;		-- Always 1
	
	signal rst_variable:std_logic;		-- a variable rst
	signal clk_ena: std_logic;
	signal scl_tick: std_logic;
	
	
	signal scl_out: std_logic;
	signal scl_in_slow: std_logic := '0';
	signal scl_in_fast: std_logic := '0';

	constant clk_period: time := 5 ns;
	
begin
	
	
	gen_clk_ena: cascadable_counter
		
		generic map(max_count => 3)
		port map(clk => clk_50MHz,
				sync_rst => rst_1,
				ena => ena_1,
				casc_in => casc_in_1,
				count => open,
				casc_out => clk_ena);


	gen_scl_tick_generator: scl_tick_generator
	
		generic map(max_count => 8)  
		port map(clk_50MHz => clk_50MHz,
				 sync_rst => rst_variable,
				 ena => clk_ena,
				 scl_tick => scl_tick); 
		 


	uut: scl_out_generator 
	
		generic map(max_state => 8)
	
		port map(clk => clk_50MHz,
				rst => rst_variable,
				scl_tick => scl_tick,			-- receive the scl_in signal from scl_tick_generator entity 
				scl_in => scl_in_fast,
				scl_out => scl_out);		-- Clock stretching 


				
				
	-- 1. P_slow_scl
	P_slow_scl: process(scl_out) is			-- simulate a slow scl_in 
	
	begin
		if(falling_edge(scl_out)) then
			scl_in_slow <= '0';
		elsif(rising_edge(scl_out)) then
			scl_in_slow <= '0', '1' after 26*clk_period;
		end if;
	end process P_slow_scl;
	
	-- 2. P_fast_scl
	P_fast_scl: process(scl_out) is			-- simulate a fast scl_in
	
	begin
	
		scl_in_fast <= scl_out;
	
	end process P_fast_scl;
	
	
	-- 3. P_clk_signal
	P_clk_signal: process is
	begin
		
		clk_50MHz <= '0';
		wait for clk_period/2;
		clk_50MHz <= '1';
		wait for clk_period/2;
		
	end process P_clk_signal;	
	
	-- 4. P_ena_signal
	P_ena_signal: process is				-- set clock enable at 25MHz => period = 40 ns
	begin
	
		ena_1 <= '1'; 
		rst_1 <= '1';
		wait;
		
	end process P_ena_signal;
	
	-- 5. P_others_signals
	P_syncrst_signals: process is
	begin
		rst_variable <= '0';
		wait for 1 us;
		rst_variable <= '1';
		wait for 50 us;
		rst_variable <= '0';
		wait for 5 us;
		rst_variable <= '1';
		wait;
	end process P_syncrst_signals;
	
	-- 5. P_others_signals
	P_others_signals: process is
	begin
		casc_in_1 <= '1';
		wait;
	end process P_others_signals;

end Behavioral;






