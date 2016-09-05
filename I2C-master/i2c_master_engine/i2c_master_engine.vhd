----------------------------------------------------------------
--! @file
--! @brief I2C Master's Engine: To act as an i2c master
--! Updated 25/07/2016
--! Changhua DING
----------------------------------------------------------------

-----************************------------
-- Questions:
--	1. Baud Rate ?
--  2. Is ST_BUSY_W bit output necessary ?
-----************************------------




--! use standard library
library ieee;
--! use logic elements
use ieee.std_logic_1164.all;

--! react from the register in the global i2c_engine and output the register changes, SCL and SDA line.
entity i2c_master_engine is
	
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
		 ST_ACK_REC_S: out std_logic;			--! ST_ACK_REC bit write output
		 RX_DATA_W: out std_logic_vector (7 downto 0); 	--! RX_DATA byte output
		 SCL_OUT: out std_logic;				--! SCL output
		 SDA_OUT: out std_logic; 				--! SDA output
		 
		 
	);


end entity i2c_master_engine;


--! Behavioral architecture to describe the i2c master engine's fonction
architecture behavior of i2c_master_engine is

	----- Components -----------------------------------------------------

	-- 1. 
	--! SCL ticks component, to generate SCL tick
	component scl_tick_generator is
	
	generic( max_count: positive := 8
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
		  SCL_error_point : out  STD_LOGIC		--! error point output
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
	--! Stop generator compoenent
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
		  ACK_valued: out std_logic;		--! ACK_valued outpu To inform ACK_out is newly valued
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
	 data_received: out std_logic;	--! data_received bit output
	 RX: out std_logic_vector (7 downto 0) --! RX received byte output
	 );
	
	end component shift_register_receiver;
	
	
	
	----- Signals -----------------------------------------------------
	type state_type is (RESET, INIT, READY_1, START, SEND_ADDR, READ_DATA, WRITE_DATA, STOP, ERROR, READY_2, RESTART);
	signal state: state_type : = RESET;
	signal is_ready: std_logic := '0';
	signal ADDR_RW: std_logic_vector (7 downto 0);
	-- Global siganl
	signal error: std_logic;
	-- SCL_TICK
	signal scl_tick: std_logic;
	-- SCL_detect
	signal rising_point: std_logic;
	signal writing_point: std_logic;
	signal falling_point: std_logic;
	signal sampling_point: std_logic;
	signal stop_point: std_logic;
	signal start_point: std_logic;
	signal error_point: std_logic;
	-- start_generator
	signal command_start: std_logic;
	
begin

	-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! MAP !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	-- 1.
	M_scl_tick: scl_tick_generator
		generic map(max_count => 8)

		port map(clk_50MHz => clk,	--! map to clock input
				 sync_rst => sync_rst,		--! map to synchronous reset input
				 ena => clk_ena,			--! map to clock enable input
				 scl_tick => scl_tick		--! map to scl tick output
				);
	
	-- 2.
	M_scl_out_generator: scl_out_generator	
		generic map(max_state => 10,		--! maximum number of states, that means the number of ticks per SCL cycle, it should be at least 10.
					critical_state => 5)
					
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
				  SCL_error_point => error_point		--! map to error_point signal
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
				 error_out => error,					--! map to error siganl
				 CTL_start => CTL_START_C,				--! map to CTL_START_C (Clear) output
				 sda_out => SDA_OUT						--! map to SDA output
				);
	
	
	-- 5.
	M_stop_generator: stop_generator
		port map(clk: in std_logic;					--! clock input
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
	
	
	-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! MAP !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	--! Combine the 7 bits address and R/W bit
	P_combine_ADDR_RW: process (clk) is
		
	begin
	
	
	end process P_combine_ADDR_RW;
	
	-- Moore State Machine
	
	--! transition and storage process
	P_transition_and_storage: process(clk) is
	
	begin
	
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
			
				if(sync_rst = '1') then
				
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
						end if;
					
					-- 3. READY_1
					when READY_1 =>
					
						if(CTL_ROLE = '1') then
							if(is_ready = '1' and CTL_START = '1') then
								state <= START;
								is_ready <= '0';				-- reset the is_ready to '0'
							end if;
						else	
							state <= STOP;
						end if;
					
					-- 4. START
					when START => 
						if(CTL_ROLE = '1') then
							if(CTL_START = '0') then
								state <= SEND_ADDR;
							end if;
						else	
							state <= STOP;
						end if;
					
					-- 5. SEND_ADDR
					when SEND_ADDR =>
						if(CTL_ROLE = '1') then
							if(CTL_RW = '0') then
								state <= READ_DATA;
							else
								state <= WRITE_DATA;
							end if;
						else	
							state <= STOP;
						end if;
						
					-- 6. READ_DATA
					when READ_DATA =>
						if(CTL_ROLE = '1') then
							if(CTL_STOP = '1') then
								if(CTL_RESTART = '1' or CTL_START = '1') then
									state <= ERROR;
								else
									state <= STOP;
								end if;
							else	
								if(CTL_RESTART = '1' and CTL_START = '1') then
									state <= ERROR;
								else
									if(CTL_RESTART = '1') then
										state <= READY_2;
									else
										state <= ERROR;
									end if;
								end if;
							end if;
						else	
							state <= STOP;
						end if;
					-- 7. WRITE_DATA	
					when WRITE_DATA =>
						if(CTL_ROLE = '1') then
							if(CTL_STOP = '1') then
								if(CTL_RESTART = '1' or CTL_START = '1') then
									state <= ERROR;
								else
									state <= STOP;
								end if;
							else	
								if(CTL_RESTART = '1' and CTL_START = '1') then
									state <= ERROR;
								else
									if(CTL_RESTART = '1') then
										state <= READY_2;
									else
										state <= ERROR;
									end if;
								end if;
							end if;
						else	
							state <= STOP;
						end if;
						
					-- 8. READY_2
					when READY_2 =>
						if(CTL_ROLE = '1') then
						
							if(is_ready = '1' and CTL_RESTART = '1') then
								state <= RESTART;
								is_ready <= '0';				-- reset the is_ready to '0' (transit action)
							end if;
							
						else	
							state <= STOP;
						end if;
					
					-- 9. RESTART
					when RESTART =>
						if(CTL_ROLE = '1') then
							if(CTL_RESTART = '0') then
								state <= SEND_ADDR;
							end if;
						else	
							state <= STOP;
						end if;
						
					when STOP =>
						if(CTL_STOP = '0')
							state <= RESET;
						end if;
					end case;
				
				else
					state <= RESET;
				end if;
				
			end if;		-- clk enable
		end if;		-- clk
	
	end process P_transition_and_storage;
	

	P_statactions: process (state) is
	
	begin
	
		case(state) is
		
		when RESET =>
			ST_BUSY <= '0';
			SCL_OUT <= '1';
			SDA_OUT <= '1';
			
			
		when INIT =>
			ST_BUSY <= '1';
			SCL_OUT <= '1';
			SDA_OUT <= '1';
			
		when READY_1 =>
			ST_BUSY <= '1';
			SCL_OUT <= '1';
			SDA_OUT <= '1';
			ADDR_RW <= SLAVE_ADDR & R/W;		-- concanate the slave address and the read/write bit with R/W at the LSB 
			is_ready <= '1';
			
		when READY_2 =>
			ST_BUSY <= '1';
			SCL_OUT <= '1';
			SDA_OUT <= '1';
			ADDR_RW <= SLAVE_ADDR & R/W;		-- concanate the slave address and the read/write bit with R/W at the LSB 
			is_ready <= '1';
			
			-- .... Generate SCL according to BAUD_RATE ...................
		
		
		
		
		
		end case;
	
	
	
	end process P_statactions;


end architecture behavior;


