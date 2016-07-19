-- This is the test bench for shift_register_receiver entity
--
-- 14/07/2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_shift_register_receiver is

end entity tb_shift_register_receiver;

architecture behavioral of tb_shift_register_receiver is
	
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

	generic(max_state: positive := 8);
	
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
	-- Component shift_register_transmitter
	component shift_register_transmitter is

	port(clk: in std_logic;
		  clk_ena: in std_logic;
		  sync_rst: in std_logic;
		  TX: in std_logic_vector (7 downto 0);		-- To connect with TX register
		  rising_point: in std_logic;
		  sampling_point: in std_logic;
		  falling_point: in std_logic;
		  writing_point: in std_logic;
		  scl_tick: in std_logic;
		  sda_in: in std_logic;
		  ACK_out: out std_logic;
		  write_command: out std_logic;
		  sda_out: out std_logic);				-- write_command = '1'  ==>  the buffer could receive the new data from TX 
													-- and Microcontroller could update TX register
		  
	end component shift_register_transmitter;
	
	-- 6. 
	-- Component Shift register receiver
	component shift_register_receiver is
	port(clk: in std_logic;
	 clk_ena: in std_logic;
	 sync_rst: in std_logic;
	 scl_tick: in std_logic;
	 sda_in: in std_logic;
	 sda_out: out std_logic;
	 falling_point: in std_logic;
	 sampling_point: in std_logic;
	 writing_point: in std_logic;
	 ACK_in: in std_logic;
	 data_received: out std_logic;
	 RX: out std_logic_vector (7 downto 0));
	end component shift_register_receiver;
	
	
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
	-- signals for shift_register_transmitter
	signal TX: std_logic_vector(7 downto 0);
	signal write_command: std_logic;
	signal ACK_out: std_logic;
	signal sda_out_1: std_logic;
	-- signals for shift_register_receiver
	signal data_received: std_logic;
	signal RX: std_logic_vector (7 downto 0);
	signal ACK_in: std_logic;
	signal sda_out_2: std_logic;


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
	generic map(max_state => 8)
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
			SCL_stop_point => open,
			SCL_sample_point => sampling_point,
			SCL_start_point => open,
			SCL_falling_point => falling_point,
			SCL_write_point => writing_point,
			SCL_error_point => open);
			
	-- 5. 
	M_shift_regisiter_transmitter: shift_register_transmitter
	port map(clk => clk_50MHz,
		  clk_ena => clk_ena,
		  sync_rst => rst_variable,
		  TX => TX,		-- To connect with TX register
		  rising_point => rising_point,
		  sampling_point => sampling_point,
		  falling_point => falling_point,
		  writing_point => writing_point,
		  scl_tick => scl_tick,
		  sda_out => sda_out_1,
		  sda_in => sda_in,
		  ACK_out => ACK_out,
		  write_command => write_command);
	
	-- 6.
	M_shift_register_receiver: shift_register_receiver
	port map(clk => clk_50MHz,
	 clk_ena => clk_ena,
	 sync_rst => rst_variable,
	 scl_tick => scl_tick,
	 sda_in => sda_in,
	 sda_out => sda_out_2, 				--sda_out,
	 falling_point => falling_point,
	 sampling_point => sampling_point,
	 writing_point => writing_point,
	 ACK_in => ACK_in,
	 data_received => data_received,
	 RX => RX);
	
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
	
	-- 6. TX
	P_TX: process(write_command) is
	variable number: unsigned (7 downto 0) := (1 downto 0 => '1', others => '0');
	begin
		if(write_command = '1') then
			TX <= std_logic_vector(number) after 30*clk_period;
			if(number = 255) then
				number := (others => '0');
			else
				number := number + 1;
			end if;
		end if;
		
	end process P_TX;
		
	-- 7. SDA
	P_SDA: process(sda_out_1, sda_out_2) is
	
	begin
		sda_out <= sda_out_1 and sda_out_2;
		sda_in <= sda_out_1 and sda_out_2;
	end process P_SDA;
	
	-- 8. ACK_in	-- To send the ACK bit
	P_ACK: process(RX) is
	
	begin
		
		ACK_in <= '0';
	
	end process P_ACK;
	

end architecture behavioral;
