----------------------------------------------------------------
--! @file
--! @brief I2C Master's Engine: To act as an i2c master
--! Created 25/07/2016
--! Updated 08/09/2016
--! Changhua DING
----------------------------------------------------------------

-----************************------------
--
--	1. Baud Rate ?
--  2. Is ST_BUSY_W bit output necessary ?
--  3. ACK_RENEWED bit ???????????????????????? To know the ACK bit is renewed or not
--	 08/09/2016
--	READ_DATA state
-- with a ACK_sent signal
-----************************------------




--! use standard library
library ieee;
--! use logic elements
use ieee.std_logic_1164.all;

--! react from the register in the global i2c_engine and output the register changes, SCL and SDA line.
entity i2c_master_engine is

	generic( max_count_SCL_tick_generator: positive := 8;		--! The number of clk_ena per cycle of SCL_tick_generator
			 max_state_SCL_out_generator: positive := 10;		--! The number of scl_tick per cycle of SCL_OUT signal, this max_state_SCL_out_generator must be at least 10.
			 critical_state_SCL_out_generator: positive := 5		--! The number of scl_tick per cycle in which the SCL is Low state, normally, critical_state_SCL_out_generator = (max_state_SCL_out_generator/2). And the critical_state_SCL_out_generator must be at least 5.
			);
	
	port(clk: in std_logic;				--! clock input
		 clk_ena: in std_logic;			--! clock enable input
		 sync_rst: in std_logic; 		--! synchronous reset input, '0' active
		 
		
		 CTL_ROLE: in std_logic;		--! CTL_ROLE bit input, to activate the master engine
		 CTL_ACK: in std_logic;			--! CTL_ACK bit input
		 CTL_RW: in std_logic; 			--! CTL_RW bit input
		 CTL_RESTART: in std_logic;		--! CTL_RESTART bit input
		 CTL_STOP: in std_logic; 		--! CTL_STOP bit input
		 CTL_START: in std_logic;		--! CTL_START bit input
		 CTL_RESET: in std_logic; 		--! CTL_RESET bit input, '0' active
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
		 ST_BUSY: out std_logic;				--! ST_BUSY bit data output
		 ST_BUSY_W: out std_logic;				--! ST_BUSY bit Write "command" output     
		 ST_RX_FULL_S: out std_logic;			--!	ST_RX_FULL bit Set output
		 ST_TX_EMPTY_S: out std_logic;			--! ST_TX_EMPTY bit set output
	--	 ST_RESTART_DETC_W: out std_logic; 		--! ST_RESTART_DETC bit set output
	--	 ST_STOP_DETC_W: out std_logic;			--! ST_STOP bit write output
	--	 ST_START_DETC_W: out std_logic;		--! ST_START_DETC bit write output
		 ST_ACK_REC: out std_logic;
		 ST_ACK_REC_W: out std_logic;			--! ST_ACK_REC bit write output
		 RX_DATA: out std_logic_vector (7 downto 0); 	--! RX_DATA byte output
		 RX_DATA_W: out std_logic;				--! command RX register
		 SCL_OUT: out std_logic;				--! SCL output
		 SDA_OUT: out std_logic 				--! SDA output
	);


end entity i2c_master_engine;


--! Behavioral architecture to describe the i2c master engine's fonction
architecture behavior of i2c_master_engine is

	----- !!!!!!!!!!!!!!!!!!!!!! Components !!!!!!!!!!!!!!!!!!!!!!!! -----------------------------------------------------

	-- 1. 
	--! SCL ticks component, to generate SCL tick
	component scl_tick_generator is
	
	generic( max_count: positive := 8								-- 
			);
	
	port(clk_50MHz: in std_logic;	--! clock input
		sync_rst: in std_logic;		--! '0' active synchronous reset input
		ena: in std_logic;			--! clock enable input
		scl_tick: out std_logic		--! scl tick output
		);
		
	end component scl_tick_generator;
	
	
	
	-- 2.
	--! SCL out component, to generate the SCL out signal
	component scl_out_generator is
	
	generic(max_state: positive := 10;		--! maximum number of states, that means the number of ticks per SCL cycle, it should be at least 10.
			critical_state: positive := 5	--! the critical state, that means at that state, the SCL change from 0 to 1, if we want to change in the middle of SCL cycle, this number should be (max_state/2).
			);
	
	port(clk: in std_logic;			--! clock input
		 rst: in std_logic;			--! '0' active synchronous reset input
		 scl_tick: in std_logic;	--! scl ticks input
		 scl_in: in std_logic;		--! scl_in input
		 scl_out: out std_logic		--! scl_out output
		);	
	
	end component scl_out_generator;
	
	
	-- 3.
	--! SCL detect component, to detect the details of SCL signal
	component SCL_detect is
	
	Port (sync_rst : in  STD_LOGIC;			--! synchronous reset input
		  clk : in  STD_LOGIC;				--! clock input
		  clk_ena : in  STD_LOGIC;			--! clk enable input
		  SCL_in : in  STD_LOGIC;			--! SCL signal input
		  SCL_tick : in  STD_LOGIC;			--! SCL tick signal input
		  
		  SCL_rising_point : out  STD_LOGIC; 	--! rising point output
		  SCL_stop_point : out  STD_LOGIC;		--! stop point output
		  SCL_sample_point : out  STD_LOGIC;	--! sample point output
		  SCL_start_point : out  STD_LOGIC;		--! start point output
		  SCL_falling_point : out  STD_LOGIC;	--! falling point output
		  SCL_write_point : out  STD_LOGIC;		--! write point output
		  SCL_error_indication : out  STD_LOGIC		--! error point output
		  );
	
	end component SCL_detect;
	
	
	-- 4.
	--! Start generator component
	component start_generator is
	
	port(clk: in std_logic;					--! clock input
	 clk_ena: in std_logic;				--! clock enable input
	 rst: in std_logic;					--! synchronous reset input
	 scl_tick: in std_logic;			--! scl tick input
	 start_point: in std_logic;			--! start point input
	 falling_point: in std_logic;		--! falling point input
	 writing_point: in std_logic;		--! writing point input
	 command_start: in std_logic;		--! command start
	 sda_in: in std_logic;				--! SDA input
	 error_out: out std_logic;			--! error output
	 CTL_start: out std_logic;			--! CTL_start output
	 sda_out: out std_logic				--! SDA output
	 );	
	
	end component start_generator;

	
	-- 5.
	--! Stop generator component
	component stop_generator is
	
	port(clk: in std_logic;					--! clock input
		 clk_ena: in std_logic;				--! clock enable input
		 rst: in std_logic;					--! synchronous reset input
		 scl_tick: in std_logic;			--! scl tick input
		 stop_point: in std_logic;			--! stop point input
		 start_point: in std_logic;			--! start point input
		 writing_point: in std_logic;		--! writing point input
		 falling_point: in std_logic;		--! falling point input
		 command_stop: in std_logic;		--! command stop input
		 sda_in: in std_logic;				--! SDA input	
		 error_out: out std_logic;			--! error output
		 CTL_stop: out std_logic;			--! CTL_stop bit output
		 sda_out: out std_logic				--! SDA output
		 );
	
	
	end component stop_generator;
	
	
	-- 6.
	--! Restart generator component
	component restart_generator is
	
	port(clk: in std_logic;					--! clock input
		 clk_ena: in std_logic;				--! cloc enable input
		 rst: in std_logic;					--! synchronous reset input	
		 scl_tick: in std_logic;			--! scl tick input
		 stop_point: in std_logic;			--! stop point input
		 start_point: in std_logic;			--! start point input
		 writing_point: in std_logic;		--! writing point input
		 falling_point: in std_logic;		--! falling point input
		 command_restart: in std_logic;		--! command restart input
		 sda_in: in std_logic;				--! SDA input
		 error_out: out std_logic;			--! error output
		 CTL_restart: out std_logic;		--! CTL_restart bit output
		 sda_out: out std_logic				--! SDA output
		 );	
	
	end component restart_generator;
	
	
	-- 7.
	--! Shift Register Transmitter Components
	component shift_register_transmitter is
	
	port(clk: in std_logic;					--! clock input
		  clk_ena: in std_logic;			--! clock enable input
		  sync_rst: in std_logic;			--! synchronous reset input
		  TX: in std_logic_vector (7 downto 0);		--! TX register input
		  rising_point: in std_logic;		--! rising_point input
		  sampling_point: in std_logic;		--! sampling_point input
		  falling_point: in std_logic;		--! falling_point input
		  writing_point: in std_logic;		--! writing_point input
		  scl_tick: in std_logic;			--! scl_tick input
		  sda_in: in std_logic;				--! sda_in input
		  ACK_out: out std_logic;			--! ACK_out output
		  ACK_valued: out std_logic;		--! ACK_valued output '1', To inform ACK_out is newly valued
		  TX_captured: out std_logic;		--! TX_captured output, TX_captured = '1'  ==>  the buffer(byte_to_be_sent) captured the data from TX and Microcontroller could update TX register
		  sda_out: out std_logic);			--! sda_out output

	end component shift_register_transmitter;
	
	-- 8.
	--! Shift Register Receiver Components
	component shift_register_receiver is
	
	port(clk: in std_logic;				--! clock input
	 clk_ena: in std_logic;			--! clock enable input
	 sync_rst: in std_logic;		--! synchronous reset input
	 scl_tick: in std_logic;		--! scl_tick input
	 sda_in: in std_logic;			--! sda_in input 
	 falling_point: in std_logic;	--! falling_point input
	 sampling_point: in std_logic;	--! sampling_point input
	 writing_point: in std_logic;	--! writing_point input
	 ACK_in: in std_logic;			--! acknowledge bit input
	 sda_out: out std_logic;		--! sda_out output
	 ACK_sent: out std_logic;		--! ACK_sent output, triger a '1' when ACK is sent
	 data_received: out std_logic;	--! data_received bit output
	 RX: out std_logic_vector (7 downto 0) --! RX received byte output
	 );
	
	end component shift_register_receiver;
	
	
	-- 9.
	--! 2 in 1 8-bit MUX
	component mux_8_bits is
	
	port(SEL: in std_logic;								--! SELECT '0' or '1' 
		 input_0: in  std_logic_vector(7 downto 0);  	--! input '0'
		 input_1: in std_logic_vector(7 downto 0);   	--! input '1'
		 output: out std_logic_vector(7 downto 0);	 	--! ouput
		 error: out std_logic							--! error
		);
	
	end component mux_8_bits;
	
	
	-- 10.
	--! 2 in 1 1-bit MUX
	component demux_1_bit is

	port(SEL: in std_logic;					--! SELECT '0' or '1' 
		 input: in  std_logic;  			--! input '0'
		 output_0: out std_logic;   			--! input '1'
		 output_1: out std_logic;	 			--! ouput
		 error: out std_logic				--! error
	);

	end component demux_1_bit;
	
	
	
	
	
	----- !!!!!!!!!!!!!!!!!!!!! Signals !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!-----------------------------------------------------
	type state_type is (RESET, INIT, READY_1, START, SEND_ADDR, READ_DATA, WRITE_DATA, STOP, ERROR, READY_2, RESTART);
	signal state: state_type;
	signal ADDR_RW: std_logic_vector (7 downto 0);
	
	
	
	
	-- Global siganl
	signal signal_error: std_logic;    			-- The result of the all errors
	-- SCL_TICK
	signal scl_tick: std_logic;
	-- SCL_detect
	signal rising_point: std_logic;
	signal writing_point: std_logic;
	signal falling_point: std_logic;
	signal sampling_point: std_logic;
	signal stop_point: std_logic;
	signal start_point: std_logic;
	signal error_indication: std_logic;
	-- start_generator
	signal command_start: std_logic;
	signal sda_out_start: std_logic;
	signal error_start: std_logic;
	-- stop_generator
	signal command_stop: std_logic;
	signal sda_out_stop: std_logic;
	signal error_stop: std_logic;
	-- restart_generator
	signal command_restart: std_logic;
	signal sda_out_restart: std_logic;
	signal error_restart: std_logic;
	-- TX 
	signal data_to_be_sent: std_logic_vector (7 downto 0);		-- connect with the output of the 8-bit mux
	signal sda_out_tx: std_logic;	
	signal ACK_valued: std_logic;
	signal TX_captured: std_logic;		-- !!!!!!!!!!!!!!
	signal rst_transmitter: std_logic;
	-- RX
	signal sda_out_rx: std_logic;
	signal rst_receiver: std_logic;
	signal ACK_sent: std_logic;
	signal data_received: std_logic;
	-- 8-bit MUX
	signal SEL_TX: std_logic;
	signal error_8_bits_MUX: std_logic;
	-- 1-bit MUX
	signal error_1_bit_MUX: std_logic;
begin

	-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! MAP !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	-- 1.
	M_scl_tick: scl_tick_generator
		generic map(max_count => max_count_SCL_tick_generator)

		port map(clk_50MHz => clk,	--! map to clock input
				 sync_rst => sync_rst,		--! map to synchronous reset input
				 ena => clk_ena,			--! map to clock enable input
				 scl_tick => scl_tick		--! map to scl_tick output (signal)
				);
	
	-- 2.
	M_scl_out_generator: scl_out_generator	
		generic map(max_state => max_state_SCL_out_generator,		--! maximum number of states, that means the number of ticks per SCL cycle, it should be at least 10.
					critical_state => critical_state_SCL_out_generator)
					
		port map(clk => clk,				--! map to clock input
				 rst => sync_rst,			--! map to '0' active synchronous reset input
				 scl_tick => scl_tick,		--! map to scl ticks signal
				 scl_in => SCL_IN,			--! map to SCL_IN input
				 scl_out => SCL_OUT			--! map to SCL_OUT output
				);
	
	-- 3.
	M_SCL_detect: SCL_detect
		port map(sync_rst => sync_rst,		--! map to synchronous reset input
				  clk => clk,				--! map to clock input
				  clk_ena => clk_ena,		--! map to clk enable input
				  SCL_in => SCL_IN,			--! map to SCL_IN input
				  SCL_tick => scl_tick,		--! map to scl_tick signal 
				  
				  SCL_rising_point => rising_point, 	--! map to rising_point signal
				  SCL_stop_point => stop_point,			--! map to stop_point signal
				  SCL_sample_point => sampling_point,	--! map to sampling_point signal
				  SCL_start_point => start_point,		--! map to start point signal
				  SCL_falling_point => falling_point,	--! map to falling point signal
				  SCL_write_point => writing_point,		--! map to writing_point signal
				  SCL_error_indication => error_indication		--! map to error_indication signal
				);
	
	
	
	-- 4.
	M_start_generator: start_generator
		port map(clk => clk,							--! map to clock input
				 clk_ena => clk_ena,					--! map to clock enable input
				 rst => sync_rst,  						--! map to synchronous reset input
				 scl_tick => scl_tick,					--! map to scl tick signal
				 start_point => start_point,			--! map to start point signal
				 falling_point => falling_point,		--! map to falling point signal
				 writing_point => writing_point,		--! map to writing point signal
				 command_start => command_start,		--! map to command start signal
				 sda_in => SDA_IN,						--! map to SDA_IN input
				 error_out => error_start,				--! map to error_start siganl
				 CTL_start => CTL_START_C,				--! map to CTL_START_C (Clear) output
				 sda_out => sda_out_start				--! map to sda_out_start signal
				);
	
	
	-- 5.
	M_stop_generator: stop_generator
		port map(clk => clk,							--! map to clock input
				 clk_ena => clk_ena,					--! map to clock enable input
				 rst => sync_rst,						--! map to synchronous reset input
				 scl_tick => scl_tick,					--! map to scl tick signal
				 stop_point => stop_point,				--! map to stop_point signal
				 start_point => start_point,			--! map to start_point signal
				 writing_point => writing_point,		--! map to writing_point signal
				 falling_point => falling_point,		--! map to falling_point signal
				 command_stop => command_stop,			--! map command_stop signal
				 sda_in => SDA_IN,						--! map to SDA_IN input	
				 error_out => error_stop,				--! map to error_stop signal
				 CTL_stop => CTL_STOP_C,				--! map to CTL_STOP_C (Clear) bit output
				 sda_out => sda_out_stop				--! map to sda_out_stop signal
				);
	
	-- 6. 
	M_restart_generator: restart_generator
		port map(clk => clk,							--! map to clock input
				 clk_ena => clk_ena,					--! map to clk enable input
				 rst => sync_rst,						--! map to synchronous reset input	
				 scl_tick => scl_tick,					--! map to scl_tick signal
				 stop_point=> stop_point,				--! map to stop_point signal
				 start_point => start_point,			--! map to start_point signal
				 writing_point => writing_point,		--! map to writing point signal
				 falling_point => falling_point,		--! map to falling_point signal
				 command_restart => command_restart, 	--! map to command_restart signal
				 sda_in => SDA_IN,						--! map to SDA_IN input
				 error_out => error_restart,			--! map to error_restart signal
				 CTL_restart => CTL_RESTART_C,			--! CTL_RESTART_C (Clear) bit output
				 sda_out => sda_out_restart				--! map to sda_out_restart signal
				);
				
	-- 7. 
	M_shift_register_transmitter: shift_register_transmitter
		port map(clk => clk,							--! map to clock input
				  clk_ena => clk_ena,					--! map to clock enable input
				  sync_rst => rst_transmitter,					--! map to synchronous reset input
				  TX => data_to_be_sent,				--! map to data_to_be_sent signal
				  rising_point => rising_point,			--! map to rising_point signal
				  sampling_point => sampling_point, 	--! map to sampling_point signal
				  falling_point => falling_point, 		--! map to falling_point signal
				  writing_point => writing_point, 		--! map to writing_point signal
				  scl_tick => scl_tick, 				--! map to scl_tick signal
				  sda_in => SDA_IN, 					--! map to SDA_IN input
				  ACK_out => ST_ACK_REC, 				--! ACK_out output WRITE '0' or '1'
				  ACK_valued => ACK_valued,				--! map to ACK_valued signal, signal equals '1' means to inform ACK_out is renewed
				  TX_captured => TX_captured,			--! map to TX_captured signal, (not ST_TX_EMPTY_S output), TX_captured output, TX_captured = '1'  ==>  the buffer(byte_to_be_sent) captured the data from TX and Microcontroller could update TX register
				  sda_out => sda_out_tx  				--! map to sda_out_tx signal
				);
	
	
	
	
	-- 8.
	M_shift_register_receiver: shift_register_receiver
		port map(clk => clk,							--!map to clock input
				 clk_ena => clk_ena,					--! map to clock enable input
				 sync_rst => rst_receiver,				--! map to synchronous reset input
				 scl_tick => scl_tick,					--! map to scl_tick signal
				 sda_in => SDA_IN,						--! map to SDA_IN input 
				 falling_point => falling_point,		--! map to falling_point signal
				 sampling_point => sampling_point, 		--! map to sampling_point signal
				 writing_point => writing_point,		--! map to writing_point signal
				 ACK_in => CTL_ACK,						--! map to acknowledge bit input
				 sda_out => sda_out_rx,					--! map to SDA_OUT output
				 ACK_sent => ACK_sent,		--! ACK_sent output, triger a '1' when ACK is sent
				 data_received => data_received,			--! map to ST_RX_FULL_S bit output
				 RX => RX_DATA 						--! map to RX received byte output
				);
	
	
	
	
	
	-- 9.
	M_TX_ADDR_RW_mux_8_bits: mux_8_bits
		port map(SEL => SEL_TX,						--! map to SEL_TX, SELECT '0' or '1' 
				 input_0 => ADDR_RW,  				--! map to combined ADDR_RW, input '0'
				 input_1 => TX_DATA,  				--! map to TX_DATA, input '1'
				 output => data_to_be_sent,	 		--! map to data_to_be_sent
				 error => error_8_bits_MUX							--! error
				);
	
	
	-- 10.
	M_TX_ADDR_RW_mux_1_bit: demux_1_bit
		port map(SEL => SEL_TX,				--! SELECT '0' or '1' 
			 input => TX_captured,		--! input 
			 output_0 => open, 			--! output '0', when SEL_TX = '0', engine is sending SLAVE_ADDR&RW data, the TX_captured bit should not modify the ST_TX_EMPTY bit
			 output_1 => ST_TX_EMPTY_S,	 		--! ouput '1', when SEL_TX = '1', connect the TX_captured with ST_TX_EMPTY_S output
			 error => error_1_bit_MUX			--! error
		);


	
	
	
	-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! MAP !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	---------------------------------------------
	
	---------------------------------------------
	
	-- Moore State Machine
	
	-- 1.
	--! transition and storage process
	P_transition_and_storage: process(clk) is
	
	begin
	
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
			
				if((sync_rst = '1') AND (CTL_RESET = '1')) then
				
					case(state) is
					
					-- 1. RESET
					when RESET => 
							
						if(CTL_ROLE = '1') then
							state <= INIT;
						end if;
					
					-- 2. INIT
					when INIT =>
						
						if(CTL_ROLE = '1') then
							
							state <= READY_1;
							
						else	
							state <= STOP;
							command_stop <= '1';
						end if;
					
					-- 3. READY_1
					when READY_1 =>
					
						if(CTL_ROLE = '1') then
							if(CTL_START = '1') then
								ADDR_RW <= SLAVE_ADDR & CTL_RW;
								state <= START;
								command_start <= '1';
							end if;
						else	
							state <= STOP;
							command_stop <= '1';
						end if;
					
					-- 4. START
					when START => 
						if(CTL_ROLE = '1') then
							if(CTL_START = '0') then
								command_start <= '0';			-- Reset the command_start to '0'
								state <= SEND_ADDR;
								
							end if;
						else	
							state <= STOP;
							command_stop <= '1';
						end if;
					
					-- 5. SEND_ADDR
					when SEND_ADDR =>
						if(CTL_ROLE = '1') then
							if(ACK_valued = '1') then
								if(CTL_RW = '1') then			-- CTL_RW '1' READ request data
									state <= READ_DATA;
								else
									state <= WRITE_DATA;
								--	SEL_TX <= '1';					-- switch MUX and DEMUX channel, activate TX 
								end if;
							end if;
						else	
							state <= STOP;
							command_stop <= '1';
						end if;
						
					-- 6. READ_DATA
					when READ_DATA =>
						if(CTL_ROLE = '1') then
							if(CTL_STOP = '1') then
								if(CTL_RESTART = '1' or CTL_START = '1') then
									state <= ERROR;
								else
									state <= STOP;
									command_stop <= '1';
								end if;
							else	
								-- !!!!!!!!
								if(ACK_sent = '1') then
									if(CTL_RESTART = '1' and CTL_START = '1') then
										state <= ERROR;
									else
										if(CTL_RESTART = '1') then
											state <= READY_2;
										elsif(CTL_START = '1') then
											state <= ERROR;
										else
											state <= READ_DATA;				-- Stay at READ_DATA state
										end if;
									end if;
								end if;
							end if;
						else	
							state <= STOP;
							command_stop <= '1';
						end if;
						
					-- 7. WRITE_DATA	
					when WRITE_DATA =>
						if(CTL_ROLE = '1') then
							if(CTL_STOP = '1') then
								if(CTL_RESTART = '1' or CTL_START = '1') then
									state <= ERROR;
								else
									state <= STOP;
									command_stop <= '1';
								end if;
							else	
								if(ACK_valued = '1') then				-- Wait for a complete 
									if(CTL_RESTART = '1' and CTL_START = '1') then
										state <= ERROR;
									else
										if(CTL_RESTART = '1') then
											state <= READY_2;
										elsif(CTL_START = '1') then
											state <= ERROR;
										else
											state <= WRITE_DATA;				-- Stay at WRITE_DATA state
										end if;
									end if;
								else
								
								end if;
							end if;
						else	
							state <= STOP;
							command_stop <= '1';
						end if;
						
					-- 8. READY_2
					when READY_2 =>
						if(CTL_ROLE = '1') then
							if(CTL_RESTART = '1') then
								ADDR_RW <= SLAVE_ADDR & CTL_RW;
								state <= RESTART;
								command_restart <= '1';
							end if;
						else	
							state <= STOP;
							command_stop <= '1';
						end if;
					
					-- 9. RESTART
					when RESTART =>
						if(CTL_ROLE = '1') then
							if(CTL_RESTART = '0') then
								command_restart <= '0';
								state <= SEND_ADDR;
								
							end if;
						else	
							state <= STOP;
							command_stop <= '1';
						end if;
						
					when STOP =>
						if(CTL_STOP = '0') then
							state <= RESET;
							command_stop <= '0';
						end if;
						
					when ERROR =>
						state <= STOP;
						command_stop <= '1';
						----- !!!!!!!!
						
						
					end case;
				
				else
					state <= RESET;
				end if;
				
			end if;		-- clk enable
		end if;		-- clk
	
	end process P_transition_and_storage;
	
	
	-- 2.
	P_statactions: process (state) is
	
	begin
	
		ST_BUSY_W <= '1';
		ST_BUSY <= '1';
		
		case(state) is
		
		when RESET =>
			ST_BUSY <= '0';
			ST_BUSY_W <= '0';
		--	SCL_OUT <= '1';
		--	SDA_OUT <= '1';
			rst_receiver <= '0';
			rst_transmitter <= '0';
			SEL_TX <= '0';
			
		when INIT =>
			SEL_TX <= '0';
			rst_receiver <= '0';
			rst_transmitter <= '0';
			
			
		when READY_1 =>
			
			SEL_TX <= '0';
			rst_receiver <= '0';
			rst_transmitter <= '0';
			
		
			
		when READY_2 =>
			
			SEL_TX <= '0';
			rst_receiver <= '0';
			rst_transmitter <= '0';

			-- .... Generate SCL according to BAUD_RATE ...................
		
		-- Generate the start condition on I2C BUS
		when START =>  
			rst_receiver <= '0';
			rst_transmitter <= '0';
			SEL_TX <= '0';
			
		when SEND_ADDR =>
			rst_receiver <= '0';
			rst_transmitter <= '1';			-- SEND address and R/W 
			SEL_TX <= '0';
			--	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			-- How to evite the ST_TX_EMPTY_S be modified when we send address&R/W
			-- Another mux ???
			-- add a signal ???
					
			
		
		
		when READ_DATA =>
			rst_receiver <= '1';
			rst_transmitter <= '0';			-- SEND address and R/W 
			SEL_TX <= '0';
			
		when WRITE_DATA =>
			rst_receiver <= '0';
			rst_transmitter <= '1';			-- SEND address and R/W 
			SEL_TX <= '1';
			
		when STOP =>
			rst_receiver <= '0';
			rst_transmitter <= '0';
			SEL_TX <= '0';
			
		
		when RESTART =>
			rst_receiver <= '0';
			rst_transmitter <= '0';
			SEL_TX <= '0';
			
		when ERROR =>	-- ??????????
			rst_receiver <= '0';
			rst_transmitter <= '0';
			SEL_TX <= '0';
		
			
		
		end case;
	
	
	
	end process P_statactions;
	
	
	-- 3.
	-- AND all sda_out outputs 
	P_SDA_OUT: process(sda_out_restart, sda_out_rx, sda_out_start, sda_out_stop, sda_out_tx) is
	
	begin
	
		SDA_OUT <= sda_out_restart AND sda_out_rx AND sda_out_start AND sda_out_stop AND sda_out_tx;
	
	end process P_SDA_OUT;
	
	-- 4.
	-- OR gate all error signals
	P_SIGNAL_ERROR: process(clk) is
	
	begin
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
			
				if(sync_rst = '1') then
					signal_error <= error_1_bit_MUX OR error_8_bits_MUX OR error_start OR error_stop OR error_restart;   -- OR gate all error signals
				else
					signal_error <= '0';
				end if;
				
			end if;
		end if;
	
	end process;
	
	-- 5.
	-- ST_ACK_REC BIT
	P_ST_ACK: process(clk) is
	begin
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
			
				ST_ACK_REC_W <= ACK_valued;
			end if;
		end if;
	end process P_ST_ACK;
	
	-- 6.
	-- RX BIT
	P_RX: process(clk) is
	begin
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				RX_DATA_W <= data_received;
				ST_RX_FULL_S <= data_received;
			end if;
		end if;
	
	end process P_RX;


end architecture behavior;


