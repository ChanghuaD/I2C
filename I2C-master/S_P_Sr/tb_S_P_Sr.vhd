-- Test bench for start, stop and restart condition

-- 19/07/2016
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_S_P_Sr is
end entity tb_S_P_Sr;

architecture behavioral of tb_S_P_Sr is
	
	-- 1.
	-- Component cascadable_counter
	-- To generate the clk_ena signal
	component cascadable_counter is		
	
	generic(max_count: positive := 2);
	port (clk: in std_logic;
		 ena: in std_logic;
		 sync_rst: in std_logic;
		 casc_in: in std_logic;
		 count: out integer range 0 to (max_count-1);
		 casc_out: out std_logic);			-- Similar to clk_ena
	
	end component cascadable_counter;
	
	-- 2.
	-- component scl_tick_generator
	component scl_tick_generator is
	
	generic( max_count: positive := 8);
	
	port(clk_50MHz: in std_logic;
		 sync_rst: in std_logic;
		 ena: in std_logic;
		 scl_tick: out std_logic);
		
	end component scl_tick_generator;
	
	-- 3.
	-- To generate SCL signal
	component scl_out_generator is 

	generic(max_state: positive := 10;
			critical_state: positive := 5);
	
	port(clk: in std_logic;
		 rst: in std_logic;
		 scl_tick: in std_logic;			-- receive the scl_in signal from scl_tick_generator entity 
		 scl_in: in std_logic;
		scl_out: out std_logic);
		 
	end component scl_out_generator;
	
	-- 4.
	-- To detect scl 
	component SCL_detect is
	Port ( sync_rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           clk_ena : in  STD_LOGIC;
           SCL_in : in  STD_LOGIC;
			  SCL_tick : in  STD_LOGIC;
			  
			  SCL_rising_point : out  STD_LOGIC;
			  SCL_stop_point : out  STD_LOGIC;
			  SCL_sample_point : out  STD_LOGIC;
			  SCL_start_point : out  STD_LOGIC;
			  SCL_falling_point : out  STD_LOGIC;
			  SCL_write_point : out  STD_LOGIC;
			  SCL_error_point : out  STD_LOGIC
			  );
	end component SCL_detect;
	
	-- 5. 
	-- To generate Start
	component start_generator is
	port(clk: in std_logic;
	 clk_ena: in std_logic;
	 rst: in std_logic;
	 scl_tick: in std_logic;
	 start_point: in std_logic;
	 falling_point: in std_logic;
	 writing_point: in std_logic;
	 command_start: in std_logic;
	 sda_in: in std_logic;
	 error_out: out std_logic;
	 CTL_start: out std_logic;
	 sda_out: out std_logic);

	end component start_generator;
	
	
	-- 6.
	component stop_generator is

	port(clk: in std_logic;
		 clk_ena: in std_logic;
		 rst: in std_logic;
		 scl_tick: in std_logic;
		 stop_point: in std_logic;
		 start_point: in std_logic;
		 writing_point: in std_logic;
		 falling_point: in std_logic;
		 command_stop: in std_logic;
		 sda_in: in std_logic;
		 error_out: out std_logic;
		 CTL_stop: out std_logic;
		 sda_out: out std_logic);

	end component stop_generator;
	
	
	-- 7.
	component restart_generator is

	port(clk: in std_logic;
		 clk_ena: in std_logic;
		 rst: in std_logic;
		 scl_tick: in std_logic;
		 stop_point: in std_logic;
		 start_point: in std_logic;
		 writing_point: in std_logic;
		 falling_point: in std_logic;
		 command_restart: in std_logic;
		 sda_in: in std_logic;
		 error_out: out std_logic;
		 CTL_restart: out std_logic;
		 sda_out: out std_logic);


	end component restart_generator;
	
	
	-- Signals
	-- Constant
	constant clk_period: time := 20 ns;
	-- general signals
	signal clk_50MHz: std_logic;
	signal rst_variable: std_logic;
	signal sda_out: std_logic;
	signal sda_in: std_logic;
	-- Signals for cascadable_counter(always '1')
	signal rst_1: std_logic;
	signal ena_1: std_logic;
	signal casc_in_1: std_logic;
	signal clk_ena: std_logic;
	-- signals for scl_tick
	signal scl_tick: std_logic;
	-- signals for scl_out_generator
	signal scl_in_fast: std_logic;
	signal scl_in_slow: std_logic;
	signal scl_out: std_logic;
	-- signals for SCL_detect
	signal rising_point: std_logic;
	signal writing_point: std_logic;
	signal falling_point: std_logic;
	signal sampling_point: std_logic;
	signal stop_point: std_logic;
	signal start_point: std_logic;
	signal error_point: std_logic;
	-- signals for start_generator
	signal command_start: std_logic;
	signal CTL_start: std_logic;
	signal sda_out_S: std_logic;
	signal error_out_S: std_logic;
	-- signals for stop_generator
	signal command_stop: std_logic;
	signal CTL_stop: std_logic;
	signal sda_out_P: std_logic;
	signal error_out_P: std_logic;
	-- signals for restart_generator
	signal command_restart: std_logic;
	signal CTL_restart: std_logic;
	signal sda_out_Sr: std_logic;
	signal error_out_Sr: std_logic;
	

begin

	-- Map ---------------------------------------
	
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
	M_scl_tick: scl_tick_generator
	generic map(max_count => 8)
	port map(clk_50MHz => clk_50MHz,
		 sync_rst => rst_variable,
		 ena => clk_ena,
		 scl_tick => scl_tick);
		 
	
	-- 3.
	M_scl_out: scl_out_generator
	generic map(max_state => 10,
				critical_state => 5)
	port map(clk => clk_50MHz,
		 rst => rst_variable,
		 scl_tick => scl_tick,			-- receive the scl_in signal from scl_tick_generator entity 
		 scl_in => scl_in_fast,
		scl_out => scl_out);
	
	
	-- 4. 
	M_scl_detect: SCL_detect
	port map(sync_rst => rst_variable,
            clk => clk_50MHz,
            clk_ena => clk_ena,
            SCL_in => scl_in_fast,
			SCL_tick => scl_tick,	  
			SCL_rising_point => rising_point,
			SCL_stop_point => stop_point,
			SCL_sample_point => sampling_point,
			SCL_start_point => start_point,
			SCL_falling_point => falling_point,
			SCL_write_point => writing_point,
			SCL_error_point => error_point);
			
	
	-- 5. 
	M_start_generator: start_generator
	port map(clk => clk_50MHz,
			 clk_ena => clk_ena,
			 rst => rst_variable,
			 scl_tick => scl_tick,
			 start_point => start_point,
			 falling_point => falling_point,
			 writing_point => writing_point,
			 command_start => command_start,
			 sda_in => sda_in,
			 error_out => error_out_S,
			 CTL_start => CTL_start,
			 sda_out => sda_out_S);
			 
			 
	-- 6 . 
	M_stop_generator: stop_generator
	port map(clk => clk_50MHz,
		 clk_ena => clk_ena,
		 rst => rst_variable,
		 scl_tick => scl_tick,
		 stop_point => stop_point,
		 start_point => start_point,
		 writing_point => writing_point,
		 falling_point => falling_point,
		 command_stop => command_stop,
		 sda_in => sda_in,
		 error_out => error_out_P,
		 CTL_stop => CTL_stop,
		 sda_out => sda_out_P);
		 
		 
	-- 7.
	M_restart_generator: restart_generator
	port map(clk => clk_50MHz,
			 clk_ena => clk_ena,
			 rst => rst_variable,
			 scl_tick => scl_tick,
			 stop_point => stop_point,
			 start_point => start_point,
			 writing_point => writing_point,
			 falling_point => falling_point,
			 command_restart => command_restart,
			 sda_in => sda_in,
			 error_out => error_out_Sr,
			 CTL_restart => CTL_restart,
			 sda_out => sda_out_Sr);
	
	-- Process -----------------------------------
	-- 1. Clock 50MHz
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
	P_slow_scl: process(scl_out) is			-- simulate a slow scl_in 
	
	begin
		if(falling_edge(scl_out)) then
			scl_in_slow <= '0';
		elsif(rising_edge(scl_out)) then
			scl_in_slow <= '0', '1' after 26*clk_period;
		end if;
	end process P_slow_scl;
	
	
	
	
	-- 5. P_fast_scl
	P_fast_scl: process(scl_out) is			-- simulate a fast scl_in
	
	begin
	
		scl_in_fast <= scl_out;
	
	end process P_fast_scl;
	
	-- 6. P_commands
	P_command: process is
	
	begin
	
		command_start <= '0';
		command_stop <= '0';
		command_restart <= '0';
		wait for 50 us;
		command_start <= '1';
		command_stop <= '0';
		command_restart <= '0';
		wait for 50 us;
		command_start <= '0';
		command_stop <= '1';
		command_restart <= '0';
		wait for 50 us;
		command_start <= '0';
		command_stop <= '0';
		command_restart <= '1';
		wait for 50 us;
		command_start <= '0';
		command_stop <= '0';
		command_restart <= '0';
		wait;
	
	end process P_command;
	
	-- 7. P_SDA
	P_SDA: process(sda_out_S, sda_out_P, sda_out_Sr) is
	
	begin
	
		sda_out <= ((sda_out_S and sda_out_P) and sda_out_Sr);
		sda_in <= ((sda_out_S and sda_out_P) and sda_out_Sr);
	
	end process P_SDA;

	
	


end architecture behavioral;