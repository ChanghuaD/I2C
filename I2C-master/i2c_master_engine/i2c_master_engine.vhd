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
		 sync_rst: in std_logic; 		--! synchronous reset input
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
	
	
	
	
	
	
	end component shift_register_transmitter;
	
	
begin



end architecture behavior;


