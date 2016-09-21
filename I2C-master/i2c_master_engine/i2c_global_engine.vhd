--!@file i2c_global_engine
--!@brief the global i2c engine including the registers, i2c master engine and i2c slave engine.
--! 20/09/2016

--! Use IEEE library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_global_engine is

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
end entity i2c_global_engine;



architecture Behavioral of i2c_global_engine is

	-------- Components --------------------
	
	--1.
	-- Registers
	component i2c_register is

	port(clk: in std_logic;						-- clk input
		 clk_ena: in std_logic;					-- clk_ena input
		 sync_rst: in std_logic; 				-- synchronous reset input			
		 
		 
		 -- To accomplish with I2C's input ports
		 --
		 --
		 I2C_CTL_START_C: in std_logic;
		 I2C_CTL_STOP_C: in std_logic;
		 I2C_CTL_RESTART_C: in std_logic;
		 
		 I2C_ST_ACK_REC: in std_logic;
		 I2C_ST_ACK_REC_W: in std_logic; 
		 I2C_ST_START_DETC_S: in std_logic;
		 I2C_ST_STOP_DETC_S: in std_logic;
		 I2C_ST_ERROR_DETC_S: in std_logic;
		 I2C_ST_TX_EMPTY_S: in std_logic;
		 I2C_ST_RX_FULL_S: in std_logic;
		 I2C_ST_RW: in std_logic;
		 I2C_ST_RW_W: in std_logic;
		 I2C_ST_BUSY: in std_logic;
		 I2C_ST_BUSY_W: in std_logic;
		 
		 I2C_RX_DATA: in std_logic_vector(7 downto 0);
		 I2C_RX_DATA_W: in std_logic;
		 
		 I2C_SLV_ADDR: in std_logic_vector(6 downto 0);
		 I2C_SLV_ADDR_command: in std_logic;
		 
		 -- To accomplish with Microcontroller's input ports
		 -- Avalon Slave Interface
		 -- 1 word = 1 byte  --> byte address = word address, don't need address translation between Avalon's Master and Slave
		 
	--	 AVALON_chipselect: in std_logic;
		 AVALON_address: in unsigned (3 downto 0);		--
		 AVALON_read: in std_logic;
		 AVALON_write: in std_logic;
		 AVALON_writedata: in std_logic_vector (7 downto 0);
		 
		 
		 
		
		 --------	Outputs	------------------------
		 
		 
		 
		 -- Avalon Slave outputs -----------------------
		 
		 AVALON_readdata: out std_logic_vector (7 downto 0);
		 AVALON_waitrequest: out std_logic;
		 AVALON_readvalid: out std_logic;
		 
		 
		 --------- AVALON Interrupt output	------------------
		 AVALON_irq: out std_logic;
		 
		 
		 ------------------- I2C Outputs Ports 	--------------
		 ---- CTL 0 to 7
		 CTL_RESET: out std_logic;				--! CTL0 
		 CTL_START: out std_logic;				--! CTL1
		 CTL_STOP: out std_logic;				--! CTL2
		 CTL_RESTART: out std_logic;			--! CTL3
		 CTL_RW: out std_logic;					--! CTL4
		 CTL_ACK: out std_logic;				--! CTL5
		 CTL_ROLE: out std_logic;				--! CTL6
		 CTL_RESERVED: out std_logic;			--! CTL7
		
		 ---- STATUS 0 to 7
		 ST_ACK_REC: out std_logic;				--! STATUS0
		 ST_START_DETC: out std_logic;			--! STATUS1
		 ST_STOP_DETC: out std_logic;			--! STATUS2
		 ST_ERROR_DETC: out std_logic;			--! STATUS3
		 ST_TX_EMPTY: out std_logic;			--! STATUS4
		 ST_RX_FULL: out std_logic;				--! STATUS5
		 ST_RW: out std_logic;					--! STATUS6
		 ST_BUSY: out std_logic;				--! STATUS7
		
		 ---- TX 8-bit
		 TX_DATA: out std_logic_vector (7 downto 0);		--! TX 8-bit
		
		 ---- RX 8-bit
		 RX_DATA: out std_logic_vector (7 downto 0); 		--! RX 8-bit
		
		 ---- Baud Rate
		 BAUDRATE: out std_logic_vector (7 downto 0);		--! BAUDRATE 8-bit
		
		 ---- Slave Address 7-bit
		 SLAVE_ADDR: out std_logic_vector (6 downto 0);		--! SLAVE_ADDR 7-bit
		
		 ---- OWN Address 7-bit
		 OWN_ADDR: out std_logic_vector (6 downto 0)		--! Own Address, use for slave role
	);
	
	end component i2c_register;

	-- 2.
	-- i2c master engine
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
		 ST_BUSY: out std_logic;				--! ST_BUSY bit data output 
		 ST_BUSY_W: out std_logic;				--! ST_BUSY bit Write output     
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

	end component i2c_master_engine;

	
	--3.
	-- i2c slave engine
	component I2c_slave_engine is

	port(
			clk								: in std_logic;--! clock input			
			clk_ena							: in std_logic;--! clock_enable input		
			sync_rst						: in std_logic;--! synchronization reset input	
			SCL_in							: in STD_LOGIC;--! I2C clock line input
			SDA_in							: in STD_LOGIC;--! I2C data line input
			
			
			ctl_role_r						: in std_logic;--!read data from bit CTL_ROLE
			ctl_ack_r						: in std_logic;--!read data from bit CTL_ACK
			ctl_reset_r						: in std_logic;--!read data from bit CTL_RESET
			
			
			--status_rxfull_r: in std_logic;
			--status_txempty_r: in std_logic;		
			
			
			txdata							: in std_logic_vector (7 downto 0);--!read data from byte TX
			
			address							: in std_logic_vector (6 downto 0);--!read data from 7 bits OWN_ADDR
			
			sda_out							: out STD_LOGIC;--! means output from I2c_slave_engine to I2C data line 

			status_busy_w					: out std_logic;--! indicate the command of busy state
			status_busy						: out std_logic;--! indicate the situation of busy state
			status_rw						: out std_logic;--! indicate the situation of read or write state
			status_stop_detected_s			: out std_logic;--! indicate the situation of stop state
			status_start_detected_s			: out std_logic;--! indicate the situation of start state
			status_error_detected_s			: out std_logic;--! indicate the situation of error state
			status_rxfull_s					: out std_logic;--! indicate the situation of full RX
			status_txempty_s				: out std_logic;--! indicate the situation of empty TX
			status_ackrec_w					: out std_logic;--! means the command of ACK received
			status_ackrec					: out std_logic;--! means the situation of ACK received
			
			rxdata							: out std_logic_vector (7 downto 0);--!write data to byte RX
			
			interrupt_rw					: out std_logic;--! indicate read/write received update
			
			slave_address					: out std_logic_vector (6 downto 0)--!read data from 7 bits slave_address
			
		  );


	end component I2c_slave_engine;
	
	
	-- 4. MUX 1-bit
	-- 
	component mux_1_bit is

	port(SEL: in std_logic;								--! SELECT '0' or '1' 
		 input_0: in  std_logic;  	--! input '0'
		 input_1: in std_logic;   	--! input '1'
		 output: out std_logic;	 	--! ouput
		 error: out std_logic							--! error
	);

	end component mux_1_bit;
	
	
	-- 5. MUX 8-bit
	--
	component mux_8_bits is

	port(SEL: in std_logic;								--! SELECT '0' or '1' 
		 input_0: in  std_logic_vector(7 downto 0);  	--! input '0'
		 input_1: in std_logic_vector(7 downto 0);   	--! input '1'
		 output: out std_logic_vector(7 downto 0);	 	--! ouput
		 error: out std_logic							--! error
	);

	end component mux_8_bits;
	
	-- 6. Cascadable counter
	component cascadable_counter is

	generic(max_count: positive := 2);
	port (clk: in std_logic;
			ena: in std_logic;
			sync_rst:in std_logic;
			casc_in: in std_logic;
			count: out integer range 0 to (max_count-1);
			casc_out: out std_logic
			);
		
	end component cascadable_counter;
	
	-------------------- SIGNALS -----------------------------------------
	-- CLOCK ENABLE SIGNAL
	signal clk_ena: std_logic;
	
	-------- Signals for Registers input ports ------------
	-- I2C Master use only
	signal signal_I2C_CTL_START_C: std_logic;
	signal signal_I2C_CTL_STOP_C: std_logic;
	signal signal_I2C_CTL_RESTART_C: std_logic;
	
	-- I2C Slave use only
	signal signal_I2C_ST_START_DETC_S:  std_logic;
	signal signal_I2C_ST_STOP_DETC_S:  std_logic;
	signal signal_I2C_ST_ERROR_DETC_S: std_logic;
	signal signal_I2C_ST_RW:  std_logic;
	signal signal_I2C_ST_RW_W:  std_logic;
	signal signal_I2C_SLV_ADDR:  std_logic_vector(6 downto 0);		-- I2C Master engine read that data, but only slave engine could modify this data
	signal signal_I2C_SLV_ADDR_command: std_logic;
	
	-- I2C, Common use signal for Master and Slave, NEED A MUX TO SWITCH THE CHANNEL	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	signal signal_I2C_ST_ACK_REC: std_logic;
	signal signal_I2C_ST_ACK_REC_W: std_logic;
	signal signal_I2C_ST_TX_EMPTY_S: std_logic;
	signal signal_I2C_ST_RX_FULL_S: std_logic;
	signal signal_I2C_ST_BUSY: std_logic;
	signal signal_I2C_ST_BUSY_W: std_logic;
	signal signal_I2C_RX_DATA: std_logic_vector(7 downto 0);
	signal signal_I2C_RX_DATA_W: std_logic;
	
	-- AVALON INPUT
	-- Don't need signal for avalon ports, map directly to the i2c_global_engine inputs
	
	------- Signals for Registers output ports
	signal signal_CTL_RESET:  std_logic;				--! CTL0 
	signal signal_CTL_START:  std_logic;				--! CTL1
	signal signal_CTL_STOP:  std_logic;				--! CTL2
	signal signal_CTL_RESTART:  std_logic;			--! CTL3
	signal signal_CTL_RW: std_logic;					--! CTL4
	signal signal_CTL_ACK: std_logic;				--! CTL5
	signal signal_CTL_ROLE: std_logic;				--! CTL6
	
	signal signal_ST_ACK_REC:  std_logic;				--! STATUS0
	signal signal_ST_START_DETC:  std_logic;			--! STATUS1
	signal signal_ST_STOP_DETC:  std_logic;			--! STATUS2
	signal signal_ST_ERROR_DETC:  std_logic;			--! STATUS3
	signal signal_ST_TX_EMPTY:  std_logic;			--! STATUS4
    signal signal_ST_RX_FULL:  std_logic;				--! STATUS5
	signal signal_ST_RW:  std_logic;					--! STATUS6
	signal signal_ST_BUSY:  std_logic;				--! STATUS7
	
	signal signal_TX_DATA:  std_logic_vector (7 downto 0);		--! TX 8-bit
				
	---- RX 8-bit
	signal signal_RX_DATA:  std_logic_vector (7 downto 0); 		--! RX 8-bit
				
	---- Baud Rate
	signal signal_BAUDRATE:  std_logic_vector (7 downto 0);		--! BAUDRATE 8-bit
				
	---- Slave Address 7-bit
	signal signal_SLAVE_ADDR:  std_logic_vector (6 downto 0);		--! SLAVE_ADDR 7-bit
				
	---- OWN Address 7-bit
	signal signal_OWN_ADDR: std_logic_vector (6 downto 0);		--! Own Address, use for slave role
	
	
	
	-------- Signals for i2c master engine input ports ------------
	--  the master output signal, to connect with mux input
	signal master_ST_BUSY: std_logic;
	signal master_ST_BUSY_W:  std_logic;				--! ST_BUSY bit Write output     
	signal master_ST_RX_FULL_S:  std_logic;			--!	ST_RX_FULL bit Set output
	signal master_ST_TX_EMPTY_S:  std_logic;			--! ST_TX_EMPTY bit set output
	signal master_ST_ACK_REC:  std_logic;
	signal master_ST_ACK_REC_W:  std_logic;			--! ST_ACK_REC bit write output
	signal master_RX_DATA:  std_logic_vector (7 downto 0); 	--! RX_DATA byte output
	signal master_RX_DATA_W:  std_logic;				--! command RX register
	signal master_SDA_OUT:  std_logic;
	
	-- the slave output signals, to connect with mux
	signal slave_SDA_OUT: std_logic;
	signal slave_ST_BUSY_W: std_logic;
	signal slave_ST_BUSY: std_logic;
	signal slave_ST_RX_FULL_S: std_logic;
	signal slave_ST_TX_EMPTY_S: std_logic;
	signal slave_ST_ACK_REC: std_logic;
	signal slave_ST_ACK_REC_W: std_logic;
	signal slave_RX_DATA: std_logic_vector(7 downto 0);
	
	
begin

	

	------------------------ Map ----------------------------------------
	
	-- 0.
	-- Clock enable
	u: cascadable_counter 
	generic map(max_count => N)
	port map(clk => AVALON_clk,
			ena => '1',
			sync_rst => sync_rst,
			casc_in => '1',
			count => open,
			casc_out => clk_ena
			);
	
	
	-- 1.
	-- Registers
	M_registers: i2c_register 
	
		port map(clk => AVALON_clk,					-- clk input
				 clk_ena => '1',				-- clk_ena = '1', same frequency with AVALON_clk
				 sync_rst => sync_rst, 				-- synchronous reset input			
				 
				 
				 -- I2C's input ports
				 
				 I2C_CTL_START_C => signal_I2C_CTL_START_C,
				 I2C_CTL_STOP_C => signal_I2C_CTL_STOP_C,
				 I2C_CTL_RESTART_C => signal_I2C_CTL_RESTART_C,
				 
				 I2C_ST_ACK_REC => signal_I2C_ST_ACK_REC,
				 I2C_ST_ACK_REC_W => signal_I2C_ST_ACK_REC_W, 
				 I2C_ST_START_DETC_S => signal_I2C_ST_START_DETC_S,
				 I2C_ST_STOP_DETC_S => signal_I2C_ST_STOP_DETC_S,
				 I2C_ST_ERROR_DETC_S => signal_I2C_ST_ERROR_DETC_S,
				 I2C_ST_TX_EMPTY_S => signal_I2C_ST_TX_EMPTY_S,
				 I2C_ST_RX_FULL_S => signal_I2C_ST_RX_FULL_S,
				 I2C_ST_RW => signal_I2C_ST_RW,
				 I2C_ST_RW_W => signal_I2C_ST_RW_W,
				 I2C_ST_BUSY => signal_I2C_ST_BUSY,
				 I2C_ST_BUSY_W => signal_I2C_ST_BUSY_W,
				 
				 I2C_RX_DATA => signal_I2C_RX_DATA,
				 I2C_RX_DATA_W => signal_I2C_RX_DATA_W,
				 
				 I2C_SLV_ADDR => signal_I2C_SLV_ADDR,
				 I2C_SLV_ADDR_command => signal_I2C_ST_RW_W,			--- !!! the signal signal_I2C_ST_RW_W command both I2C_ST_RW bit and Slave_ADDR register
				 
				 -- To accomplish with Microcontroller's input ports
				 -- Avalon Slave Interface
				 -- 1 word = 1 byte  --> byte address = word address, don't need address translation between Avalon's Master and Slave
				 
			     -- AVALON_chipselect: in std_logic;
				 AVALON_address => AVALON_address,		
				 AVALON_read => AVALON_read,
				 AVALON_write => AVALON_write,
				 AVALON_writedata => AVALON_writedata,
				 
				 
				 
				
				 --------	Outputs	----------------------------
				 
				 
				 
				 -- Avalon Slave outputs -----------------------
				 
				 AVALON_readdata => AVALON_readdata,
				 AVALON_waitrequest => AVALON_waitrequest,
				 AVALON_readvalid => AVALON_readvalid,
				 
				 
				 --------- AVALON Interrupt output	------------------
				 
				 AVALON_irq => AVALON_irq,
				 
				 ------------------- I2C Outputs Ports 	--------------
				 ---- CTL 0 to 7
				 CTL_RESET => signal_CTL_RESET,				--! CTL0 
				 CTL_START => signal_CTL_START,				--! CTL1
				 CTL_STOP => signal_CTL_STOP,				--! CTL2
				 CTL_RESTART => signal_CTL_RESTART,			--! CTL3
				 CTL_RW => signal_CTL_RW,					--! CTL4
				 CTL_ACK => signal_CTL_ACK,				--! CTL5
				 CTL_ROLE => signal_CTL_ROLE,				--! CTL6
				 CTL_RESERVED => open,					-- Reserved bit
				
				 ---- STATUS 0 to 7
				 ST_ACK_REC => signal_ST_ACK_REC,				--! STATUS0
				 ST_START_DETC => signal_ST_START_DETC,			--! STATUS1
				 ST_STOP_DETC => signal_ST_STOP_DETC,			--! STATUS2
				 ST_ERROR_DETC => signal_ST_ERROR_DETC,			--! STATUS3
				 ST_TX_EMPTY => signal_ST_TX_EMPTY, 			--! STATUS4
				 ST_RX_FULL => signal_ST_RX_FULL,				--! STATUS5
				 ST_RW => signal_ST_RW,					--! STATUS6
				 ST_BUSY => signal_ST_BUSY,				--! STATUS7
				
				 ---- TX 8-bit
				 TX_DATA => signal_TX_DATA,		--! TX 8-bit
				
				 ---- RX 8-bit
				 RX_DATA => signal_RX_DATA, 		--! RX 8-bit
				
				 ---- Baud Rate
				 BAUDRATE => signal_BAUDRATE,		--! BAUDRATE 8-bit		--- How to control Baud rate ????????????????
				
				 ---- Slave Address 7-bit
				 SLAVE_ADDR => signal_SLAVE_ADDR,		--! SLAVE_ADDR 7-bit
				
				 ---- OWN Address 7-bit
				 OWN_ADDR => signal_OWN_ADDR 		--! Own Address, use for slave role
				
				);
	
	-- 2.
	-- i2c master engine
	M_i2c_master_engine: i2c_master_engine 
	
		port map(clk => AVALON_clk,				--! clock input
			 clk_ena => clk_ena,		--! clock enable input
			 sync_rst => sync_rst, 		--! synchronous reset input, '0' active
			 CTL_ROLE => signal_CTL_ROLE,		--! CTL_ROLE bit input, to activate the master engine
			 CTL_ACK => signal_CTL_ACK,			--! CTL_ACK bit input
			 CTL_RW => signal_CTL_RW, 			--! CTL_RW bit input
			 CTL_RESTART => signal_CTL_RESTART,		--! CTL_RESTART bit input
			 CTL_STOP => signal_CTL_STOP, 		--! CTL_STOP bit input
			 CTL_START => signal_CTL_START,		--! CTL_START bit input
			 CTL_RESET => signal_CTL_RESET, 		--! CTL_RESET bit input
			 ST_RX_FULL => signal_ST_RX_FULL, 		--! ST_RX_FULL bit input
			 ST_TX_EMPTY => signal_ST_TX_EMPTY, 	--! ST_TX_EMPTY bit input
			 TX_DATA => signal_TX_DATA,  	--! TX_DATA byte input
			 BAUD_RATE => signal_BAUDRATE,  	--! BAUD_RATE byte input
			 SLAVE_ADDR => signal_SLAVE_ADDR,	--! SLAVE ADDRESS 7 bits input
			 SCL_IN => SCL_IN,			--! SCL input
			 SDA_IN => SDA_IN,			--! SDA input
			 
			 CTL_RESTART_C => signal_I2C_CTL_RESTART_C,			--! CTL_RESTART bit Clear output		MASTER USE ONLY
			 CTL_STOP_C => signal_I2C_CTL_STOP_C,				--! CTL_STOP bit Clear output
			 CTL_START_C => signal_I2C_CTL_STOP_C,			--! CTL_START bit Clear output
			 ST_BUSY => master_ST_BUSY,				--! ST_BUSY bit data output  
			 ST_BUSY_W => master_ST_BUSY_W,				--! ST_BUSY bit Write output     
			 ST_RX_FULL_S => master_ST_RX_FULL_S,			--!	ST_RX_FULL bit Set output
			 ST_TX_EMPTY_S => master_ST_TX_EMPTY_S,			--! ST_TX_EMPTY bit set output
		--	 ST_RESTART_DETC_W: out std_logic; 		--! ST_RESTART_DETC bit set output
		--	 ST_STOP_DETC_W: out std_logic;			--! ST_STOP bit write output
		--	 ST_START_DETC_W: out std_logic;		--! ST_START_DETC bit write output
			 ST_ACK_REC => master_ST_ACK_REC,
			 ST_ACK_REC_W => master_ST_ACK_REC_W,			--! ST_ACK_REC bit write output
			 RX_DATA => master_RX_DATA, 	--! RX_DATA byte output
			 RX_DATA_W => master_RX_DATA_W,				--! command RX register
			 SCL_OUT => SCL_OUT,				--! SCL output
			 SDA_OUT => master_SDA_OUT 				--! SDA output
		);
	

	-- 3.
	-- i2c slave engine
	M_i2c_slave_engine: I2c_slave_engine

	port map(	clk								=> AVALON_clk,								--! clock input			
			clk_ena							=> clk_ena,						--! clock_enable input		
			sync_rst						=> sync_rst,						--! synchronization reset input	
			SCL_in							=> SCL_IN,					--! I2C clock line input
			SDA_in							=> SDA_IN,						--! I2C data line input
			
			
			ctl_role_r						=> signal_CTL_ROLE,					--!read data from bit CTL_ROLE
			ctl_ack_r						=> signal_CTL_ACK,				--!read data from bit CTL_ACK
			ctl_reset_r						=> signal_CTL_RESET,				--!read data from bit CTL_RESET
			
			
			--status_rxfull_r: in std_logic;
			--status_txempty_r: in std_logic;		
			
			
			txdata							=> signal_TX_DATA,							--!read data from byte TX
			
			address							=> signal_OWN_ADDR, 				--!read data from 7 bits OWN_ADDR
			
			--------- OUTPUTS -----------
			
			sda_out							=> slave_SDA_OUT,						--! means output from I2c_slave_engine to I2C data line 

			status_busy_w					=> slave_ST_BUSY_W,				--! indicate the command of busy state
			status_busy						=> slave_ST_BUSY,				--! indicate the situation of busy state
			status_rw						=> signal_I2C_ST_RW,					--! indicate the situation of read or write state
			interrupt_rw					=> signal_I2C_ST_RW_W,	
			
			status_stop_detected_s			=> signal_I2C_ST_STOP_DETC_S,				--! indicate the situation of stop state
			status_start_detected_s			=> signal_I2C_ST_START_DETC_S,				--! indicate the situation of start state
			status_error_detected_s			=> signal_I2C_ST_ERROR_DETC_S,					--! indicate the situation of error state
			status_rxfull_s					=> slave_ST_RX_FULL_S,						--! indicate the situation of full RX
			status_txempty_s				=> slave_ST_TX_EMPTY_S,						--! indicate the situation of empty TX
			status_ackrec_w					=> slave_ST_ACK_REC_W,										--! means the command of ACK received
			status_ackrec					=> slave_ST_ACK_REC,							--! means the situation of ACK received
			
			rxdata							=> slave_RX_DATA,											--!write data to byte RX
			
									--! indicate read/write received update
			
			slave_address					=> signal_I2C_SLV_ADDR									--!read data from 7 bits slave_address
			
		  );

			
	-- 4.
	-- MUX 1-bit
	-- signal_ST_ACK_REC
	M_mux_signal_ST_ACK_REC: mux_1_bit
	
	port map(SEL => signal_CTL_ROLE,							--! SELECT '0' or '1' 
		 input_0 => slave_ST_ACK_REC,  	--! input '0'
		 input_1 => master_ST_ACK_REC,   	--! input '1'
		 output => signal_I2C_ST_ACK_REC,	 	--! ouput
		 error => open							--! error
	);
	
	-- 5.
	-- MUX 1-bit
	M_mux_signal_ST_ACK_REC_W: mux_1_bit
	port map(SEL => signal_CTL_ROLE,							--! SELECT '0' or '1' 
		 input_0 => slave_ST_ACK_REC_W,  	--! input '0'
		 input_1 => master_ST_ACK_REC_W,   	--! input '1'
		 output => signal_I2C_ST_ACK_REC_W,	 	--! ouput
		 error => open							--! error
	);
	
	-- 6. 
	-- Mux 1-bit
	M_mux_signal_I2C_ST_TX_EMPTY_S: mux_1_bit
	port map(SEL => signal_CTL_ROLE,							--! SELECT '0' or '1' 
		 input_0 => slave_ST_TX_EMPTY_S,  	--! input '0'
		 input_1 => master_ST_TX_EMPTY_S,   	--! input '1'
		 output => signal_I2C_ST_TX_EMPTY_S,	 	--! ouput
		 error => open							--! error
	);
	
	
	-- 7. 
	-- Mux 1-bit
	M_mux_signal_I2C_ST_RX_FULL_S: mux_1_bit
	port map(SEL => signal_CTL_ROLE,							--! SELECT '0' or '1' 
		 input_0 => slave_ST_RX_FULL_S,  	--! input '0'
		 input_1 => master_ST_RX_FULL_S,   	--! input '1'
		 output => signal_I2C_ST_RX_FULL_S,	 	--! ouput
		 error => open							--! error
	);
	
	-- 8.
	-- mux 1-bit
	M_mux_signal_I2C_ST_BUSY: mux_1_bit
	port map(SEL => signal_CTL_ROLE,							--! SELECT '0' or '1' 
		 input_0 => slave_ST_BUSY,  	--! input '0'
		 input_1 => master_ST_BUSY,   	--! input '1'
		 output => signal_I2C_ST_BUSY,	 	--! ouput
		 error => open							--! error
	);
	
	-- 9.
	-- mux 1-bit
	M_mux_signal_I2C_ST_BUSY_W: mux_1_bit
	port map(SEL => signal_CTL_ROLE,							--! SELECT '0' or '1' 
		 input_0 => slave_ST_BUSY_W,  	--! input '0'
		 input_1 => master_ST_BUSY_W,   	--! input '1'
		 output => signal_I2C_ST_BUSY_W,	 	--! ouput
		 error => open							--! error
	);
	
	-- 10.
	-- mux 8-bit
	M_mux_signal_RX_DATA: mux_8_bits
	port map(SEL => signal_CTL_ROLE,							--! SELECT '0' or '1' 
		 input_0 => slave_RX_DATA,  	--! input '0'
		 input_1 => master_RX_DATA,   	--! input '1'
		 output => signal_I2C_RX_DATA,	 	--! ouput
		 error => open							--! error
	);
	
	-- 11.
	-- mux_1_bit
	M_mux_signal_RX_DATA_W: mux_1_bit
	port map(SEL => signal_CTL_ROLE,							--! SELECT '0' or '1' 
		 input_0 => slave_ST_RX_FULL_S,  	--! input '0'
		 input_1 => master_RX_DATA_W,   	--! input '1'
		 output => signal_I2C_RX_DATA_W,	 	--! ouput
		 error => open							--! error
	);
	
	
end architecture Behavioral;


