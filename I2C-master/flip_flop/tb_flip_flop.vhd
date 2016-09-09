-----------------------------------------------
--! @file
--! @brief test bench for flip flops
--! Updated 21/07/0216
--! Changhua DING
-----------------------------------------------

--! use standard library
library ieee;
--! use logic elements
use ieee.std_logic_1164.all;

--! flip flop test bench entity 
entity tb_flip_flop is
end entity tb_flip_flop;

architecture behavior of tb_flip_flop is

		
	---- Component --------------------------------------------------

	-- 1.
	--! Component cascadable_counter
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
	--! Component flip_flop_RW_RC 
	component flip_flop_RW_RC is
	
	port(clk: in std_logic;					--! clock input
		 clk_ena: in std_logic;				--! clock enable input
		 sync_rst: in std_logic;			--! '0' active synchronous reset input
		 uc_data_in: in std_logic;			--! microcontroller data input
		 uc_write_command: in std_logic;	--! '1' active microcontroller write command input
		 i2c_clear_command: in std_logic;	--! '1' active I2C clear command input
		 data_out: out std_logic			--! data_out output
	);

	end component flip_flop_RW_RC;
	
	-- 3.
	--! Component flip_flop_RW_R 
	component flip_flop_RW_R is

	port(clk: in std_logic;						--! clock input
		 clk_ena: in std_logic;					--! clock enable input
		 sync_rst: in std_logic;				--! '0' active synchronous reset input
		 uc_data_in: in std_logic;				--! microcontroller data input
		 uc_write_command: in std_logic;		--! '1' active microcontroller write command input
		 data_out: out std_logic				--! data_out output
	);

	end component flip_flop_RW_R;
	
	
	-- 4. TX
	component TX_8_bits_W_R is

	port(clk: in std_logic;			--! clk input
		 clk_ena: in std_logic; 	--! clk enable input
		 sync_rst: in std_logic; 	--! synchronous reset input
		 uc_data_input: in std_logic_vector(7 downto 0);		--! MicroController 8-bit input
		 uc_data_input_command: in std_logic;				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
		 data_output: out std_logic_vector(7 downto 0)		--! output 8-bit 
		);

	end component TX_8_bits_W_R;
	
	
	-- 5.
	component RX_8_bits_R_W is
	
	port(clk: in std_logic;		--! clk input
		 clk_ena: in std_logic;			--! clk enable input
		 sync_rst: in std_logic;		--! synchronous reset input
		 i2c_data_input: in std_logic_vector(7 downto 0);	--! 
		 i2c_data_input_command: in std_logic;				--! i2c renew command, '1' renew output, '0' don't change output
		 data_output: out std_logic_vector(7 downto 0)		--! data_output;
		);	
	
	end component RX_8_bits_R_W;
	
	
	
	---- Signals --------------------------------------------------------
	

	--	
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
	-- signals for flip_flop_RW_RC
	signal RW_RC_data_in: std_logic;
	signal RW_RC_write_command: std_logic;
	signal RW_RC_clear_command: std_logic;
	signal RW_RC_data_out: std_logic;
	-- signals for flip_flop_RW_R
	signal RW_R_data_in: std_logic;
	signal RW_R_write_command: std_logic;
	signal RW_R_data_out: std_logic;
	-- TX
	signal TX_uc_data_input:  std_logic_vector(7 downto 0);		--! MicroController 8-bit input
	signal TX_uc_data_input_command:  std_logic;				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
	signal TX_data_output:  std_logic_vector(7 downto 0);		--! output 8-bit  
	-- RX
	signal RX_i2c_data_input:  std_logic_vector(7 downto 0);	--! 
	signal RX_i2c_data_input_command: std_logic;				--! i2c renew command, '1' renew output, '0' don't change output
	signal RX_data_output:  std_logic_vector(7 downto 0);		--! data_output;

begin
	
	-- Map ------------------------------------------------------------------
	
	-- 1.
	--! clock enable 
	M_clk_ena: cascadable_counter
	generic map (max_count => 3)
	port map(clk => clk_50MHz,
		 ena => ena_1,
		 sync_rst => rst_1,
		 casc_in => casc_in_1,
		 count => open,
		 casc_out => clk_ena);
		 
		 
	-- 2.
	--! flip_flop_RW_RC
	M_RW_RC: flip_flop_RW_RC
	port map(clk => clk_50MHz,
			 clk_ena => clk_ena,
			 sync_rst => rst_variable,
			 uc_data_in => RW_RC_data_in,
			 uc_write_command => RW_RC_write_command,
			 i2c_clear_command => RW_RC_clear_command,
			 data_out => RW_RC_data_out
	);
	
	
	
	-- 3.
	--! flip_flop_RW_R
	M_RW_R: flip_flop_RW_R
	port map(clk => clk_50MHz,
			 clk_ena => clk_ena,
			 sync_rst => rst_variable,
			 uc_data_in => RW_R_data_in,
			 uc_write_command => RW_R_write_command,
			 data_out => RW_R_data_out
	);
	
	
	-- 4. TX
	M_TX: TX_8_bits_W_R 

	port map(clk => clk_50MHz,						--! clk input
		 clk_ena => clk_ena, 						--! clk enable input
		 sync_rst => rst_variable, 					--! synchronous reset input
		 uc_data_input => TX_uc_data_input,						--! MicroController 8-bit input
		 uc_data_input_command => TX_uc_data_input_command,		--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
		 data_output => TX_data_output							--! output 8-bit 
		);

	
	
	-- 5.
	M_RX: RX_8_bits_R_W 
	
	port map(clk => clk_50MHz,	--! clk input
		 clk_ena => clk_ena,		--! clk enable input
		 sync_rst => rst_variable,		--! synchronous reset input
		 i2c_data_input => RX_i2c_data_input,	--! 
		 i2c_data_input_command => 	RX_i2c_data_input_command,			--! i2c renew command, '1' renew output, '0' don't change output
		 data_output => RX_data_output		--! data_output;
		);	
	
	
	
	
	
	-- Process --------------------------------------------------------------
	-- 
	
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
	
	-- 4. RW_RC
	P_RW_RC: process is
	begin
	
		RW_RC_data_in <= '1';
		RW_RC_clear_command <= '0';
		RW_RC_write_command <= '0';
		wait for 50 us;
		RW_RC_data_in <= '1';
		RW_RC_clear_command <= '0';
		RW_RC_write_command <= '1';
		wait for 1 us;
		RW_RC_data_in <= '0';
		RW_RC_clear_command <= '0';
		RW_RC_write_command <= '0';
		wait for 50 us;
		RW_RC_data_in <= '1';
		RW_RC_clear_command <= '1';
		RW_RC_write_command <= '0';
		wait for 1 us;
		RW_RC_data_in <= '1';
		RW_RC_clear_command <= '0';
		RW_RC_write_command <= '0';
		wait for 50 us;
		RW_RC_data_in <= '1';
		RW_RC_clear_command <= '1';
		RW_RC_write_command <= '1';
		wait;

	end process P_RW_RC;
	
	-- 5. RW_R
	P_RW_R: process is
	begin
	
		RW_R_data_in <= '1';
		RW_R_write_command <= '0';
		wait for 75 us;
		RW_R_data_in <= '1';
		RW_R_write_command <= '1';
		wait;
		
	end process P_RW_R;	
	
	
	-- 6. TX
	P_TX: process is
	begin
		 TX_uc_data_input <= (3 downto 0 => '0', others => '1');
		 TX_uc_data_input_command <= '0';
		 wait for 50 us;
		 TX_uc_data_input_command <= '1';
		 wait for 1 us;
		 TX_uc_data_input_command <= '0';
		 wait;
	
	end process P_TX;
	
	-- 6. RX
	P_RX: process is
	begin
		 RX_i2c_data_input <= (3 downto 0 => '0', others => '1');
		 RX_i2c_data_input_command <= '0';
		 wait for 50 us;
		 RX_i2c_data_input_command <= '1';
		 wait for 1 us;
		 RX_i2c_data_input_command <= '0';
		 wait;
	
	end process P_RX;

end architecture behavior;


