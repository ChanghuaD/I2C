--------------------------------------------------------------
--!@file register
--!@brief	registers connect with AVALON interface and I2C engine
--! Created on 09/09/2016
--------------------------------------------------------------

------------
-- Waitrequest signal is always '0' now.
-- 
------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	

entity i2c_register is

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
		 AVALON_waitrequest: out std_logic;				-- !!!!!!!!!!!!!!!!!
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
	
end entity i2c_register;

architecture Behavioral of i2c_register is


	------------ Component ----------------------------

	-- 1.
	component Flip_flop_R_WR is

		Port( 
			clk 			: in  STD_LOGIC;
			clk_ena 		: in  STD_LOGIC;
			sync_rst 		: in  STD_LOGIC;
			i2c_write 		: in  STD_LOGIC;
			i2c_data_in 	: in  STD_LOGIC;
				  
			data_out 		: out  STD_LOGIC
			);
			  
	end component Flip_flop_R_WR;

	-- 2.
	component Flip_flop_RC_S is

		Port( 
			clk 			: in  STD_LOGIC;
			clk_ena 		: in  STD_LOGIC;
			sync_rst 		: in  STD_LOGIC;
			uc_clear 		: in  STD_LOGIC;
			uc_clear_command: in  STD_LOGIC;
			i2c_set 		: in  STD_LOGIC;
				  
			data_out 		: out  STD_LOGIC
			);
			  
	end component Flip_flop_RC_S;

	-- 3.
	component flip_flop_RW_R is

		port(clk: in std_logic;						--! clock input
			 clk_ena: in std_logic;					--! clock enable input
			 sync_rst: in std_logic;				--! '0' active synchronous reset input
			 uc_data_in: in std_logic;				--! microcontroller data input
			 uc_write_command: in std_logic;		--! '1' active microcontroller write command input
			 data_out: out std_logic				--! data_out output
			);

	end component flip_flop_RW_R;

	-- 4.
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


	-- 5.
	component TX_8_bits_W_R is

		port(clk: in std_logic;			--! clk input
			 clk_ena: in std_logic; 	--! clk enable input
			 sync_rst: in std_logic; 	--! synchronous reset input
			 uc_data_input: in std_logic_vector(7 downto 0);		--! MicroController 8-bit input
			 uc_data_input_command: in std_logic;				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
			 data_output: out std_logic_vector(7 downto 0)		--! output 8-bit 
			);

	end component TX_8_bits_W_R;
	
	-- 6.
	component RX_8_bits_R_W is
	
		port(clk: in std_logic;		--! clk input
			 clk_ena: in std_logic;			--! clk enable input
			 sync_rst: in std_logic;		--! synchronous reset input
			 i2c_data_input: in std_logic_vector(7 downto 0);	--! 
			 i2c_data_input_command: in std_logic;				--! i2c renew command, '1' renew output, '0' don't change output
			 data_output: out std_logic_vector(7 downto 0)		--! data_output;
			);	
	
	end component RX_8_bits_R_W;

	-- 7.
	component ADDR_7_bits_RW_R is

	port(clk: in std_logic;			--! clk input
		 clk_ena: in std_logic; 	--! clk enable input
		 sync_rst: in std_logic; 	--! synchronous reset input
		 uc_data_input: in std_logic_vector(6 downto 0);		--! MicroController 7-bit input
		 uc_data_input_command: in std_logic;				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
		 data_output: out std_logic_vector(6 downto 0)		--! output 7-bit 
		);

	end component ADDR_7_bits_RW_R;
	
	
	-- 8.
	component ADDR_7_bits_W_W is
	
	port(clk: in std_logic;			--! clk input
		 clk_ena: in std_logic; 	--! clk enable input
		 sync_rst: in std_logic; 	--! synchronous reset input
		 uc_data_input: in std_logic_vector(6 downto 0);		--! MicroController 7-bit input
		 uc_data_input_command: in std_logic;				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
		 i2c_data_input: in std_logic_vector(6 downto 0);
		 i2c_data_input_command: in std_logic;
		 
		 data_output: out std_logic_vector(6 downto 0)		--! output 7-bit 
		);
	
	end component ADDR_7_bits_W_W;
	
	-- 9.
	component Flip_flop_interrupt_RC_mask is

    Port( 
		clk 			: in  STD_LOGIC;
        clk_ena 		: in  STD_LOGIC;
		sync_rst 		: in  STD_LOGIC;
        clear_in 			: in  STD_LOGIC;
		mask_in 		: in  STD_LOGIC;
		set_in			: in  STD_LOGIC;	
			  
		data_out 		: out  STD_LOGIC
		);
          
	end component Flip_flop_interrupt_RC_mask;


	--------------- signal ------------------------------
	signal avalon_irq_st: std_logic;
	signal avalon_irq_ctl: std_logic;
	

	--signal CTL0_uc_data_in: std_logic;
	signal ctl_command: std_logic;			-- Command the CTL register (activate by avalon address & write)
	signal st_command: std_logic;			-- Command the STATUS register (activate by avalon address & write)
	signal tx_command: std_logic;			-- Command the TX_DATA register (activate by avalon master)
	signal baudrate_command: std_logic;		-- Command the baudrate register
	signal slv_addr_command: std_logic;		-- Command the slave address word
	signal own_addr_command: std_logic;
	signal interrupt_ctl_mask_command: std_logic;	-- Command the interrupt control mask register
	signal interrupt_ctl_clear_command: std_logic;	-- Command the interrupt control clear register
	signal interrupt_ctl_command: std_logic;
	signal interrupt_st_mask_command: std_logic;	-- Command the interrupt status mask register
	signal interrupt_st_clear_command: std_logic;	-- Command the interrupt status clear register
	signal interrupt_st_command: std_logic;
	
	signal signal_CTL_data: std_logic_vector(7 downto 0);
	signal signal_ST_data: std_logic_vector(7 downto 0);
	
	--- Signals correspond to output
	
	---- CTL 0 to 7
	signal	 signal_CTL_RESET:  std_logic;				--! CTL0 
	signal	 signal_CTL_START:  std_logic;				--! CTL1
	signal	 signal_CTL_STOP:  std_logic;				--! CTL2
	signal	 signal_CTL_RESTART:  std_logic;			--! CTL3
	signal	 signal_CTL_RW:  std_logic;				--! CTL4
	signal	 signal_CTL_ACK: std_logic;				--! CTL5
	signal	 signal_CTL_ROLE:  std_logic;				--! CTL6
	signal	 signal_CTL_RESERVED:  std_logic := '0';			--! CTL7
		
		 ---- STATUS 0 to 7
	signal	 signal_ST_ACK_REC:  std_logic;			--! STATUS0
	signal	 signal_ST_START_DETC:  std_logic;			--! STATUS1
	signal	 signal_ST_STOP_DETC:  std_logic;			--! STATUS2
	signal	 signal_ST_ERROR_DETC: std_logic;			--! STATUS3
	signal	 signal_ST_TX_EMPTY:  std_logic;			--! STATUS4
	signal	 signal_ST_RX_FULL:  std_logic;			--! STATUS5
	signal	 signal_ST_RW:  std_logic;					--! STATUS6
	signal	 signal_ST_BUSY:  std_logic;				--! STATUS7
		
		 ---- TX 8-bit
	signal	 signal_TX_DATA:  std_logic_vector (7 downto 0);		--! TX 8-bit
		
		 ---- RX 8-bit
	signal	 signal_RX_DATA:  std_logic_vector (7 downto 0); 		--! RX 8-bit
		
		 ---- Baud Rate
	signal	 signal_BAUDRATE:  std_logic_vector (7 downto 0);		--! BAUDRATE 8-bit
		
		 ---- Slave Address 7-bit
	signal	 signal_SLAVE_ADDR: std_logic_vector (6 downto 0);		--! SLAVE_ADDR 7-bit
		
		 ---- OWN Address 7-bit
	signal	 signal_OWN_ADDR: std_logic_vector (6 downto 0);		--! Own Address, use for slave role
	
	
		 ---- Waitrequest SIGNALS
	signal 	 signal_waitrequest: std_logic:= '0';						--! waitrequest signal 
	
	
	
		 ---- INTERRUPT CTL MASK
	signal 	 signal_IRQ_CTL_MASK: std_logic_vector(7 downto 0);
	
		 ---- INTERRUPT CTL MASK
	signal 	 signal_IRQ_CTL_CLEAR: std_logic_vector(7 downto 0);
	
		---- INTERRUPT CTL
	signal   signal_IRQ_CTL: std_logic_vector(7 downto 0);
	signal 	 signal_IRQ_CTL0: std_logic;
	signal 	 signal_IRQ_CTL1: std_logic;
	signal 	 signal_IRQ_CTL2: std_logic;
	signal 	 signal_IRQ_CTL3: std_logic;
	signal 	 signal_IRQ_CTL4: std_logic;
	signal 	 signal_IRQ_CTL5: std_logic;
	signal 	 signal_IRQ_CTL6: std_logic;
	signal 	 signal_IRQ_CTL7: std_logic;
	
	
	
		
		 ---- INTERRUPT ST MASK
	signal 	 signal_IRQ_ST_MASK: std_logic_vector(7 downto 0);
	
		 ---- INTERRUPT ST MASK
	signal 	 signal_IRQ_ST_CLEAR: std_logic_vector(7 downto 0);
	
	---- INTERRUPT STATUS
	signal 	 signal_IRQ_ST: std_logic_vector(7 downto 0);
	signal	 signal_IRQ_ST0: std_logic;
	signal	 signal_IRQ_ST1: std_logic;
	signal	 signal_IRQ_ST2: std_logic;
	signal	 signal_IRQ_ST3: std_logic;
	signal	 signal_IRQ_ST4: std_logic;
	signal	 signal_IRQ_ST5: std_logic;
	signal	 signal_IRQ_ST6: std_logic;
	signal	 signal_IRQ_ST7: std_logic;
	
	
	--- alias
	alias slave_address: std_logic_vector (6 downto 0) is AVALON_writedata (6 downto 0);
	alias own_address: std_logic_vector(6 downto 0) is AVALON_writedata (6 downto 0);
	
	alias CTL0: std_logic is signal_CTL_RESET;
	alias CTL1: std_logic is signal_CTL_START;
	alias CTL2: std_logic is signal_CTL_STOP;
	alias CTL3: std_logic is signal_CTL_RESTART;
	alias CTL4: std_logic is signal_CTL_RW;
	alias CTL5: std_logic is signal_CTL_ACK;
	alias CTL6: std_logic is signal_CTL_ROLE;
	alias CTL7: std_logic is signal_CTL_RESERVED;
	
	alias ST0: std_logic is signal_ST_ACK_REC;
	alias ST1: std_logic is signal_ST_START_DETC;
	alias ST2: std_logic is signal_ST_STOP_DETC;
	alias ST3: std_logic is signal_ST_ERROR_DETC;
	alias ST4: std_logic is signal_ST_TX_EMPTY;
	alias ST5: std_logic is signal_ST_RX_FULL;
	alias ST6: std_logic is signal_ST_RW;
	alias ST7: std_logic is signal_ST_BUSY;
	
	
	
	
	
	
	
begin



	--------------- Map -----------------------------------
	
	------- CTL ------------------
	
	--! CTL0: CTL_RESET
	M_CTL0:	flip_flop_RW_R
	port map(clk => clk,						--! clock input
			 clk_ena => clk_ena,					--! clock enable input
			 sync_rst => sync_rst,				--! '0' active synchronous reset input
			 uc_data_in =>	AVALON_writedata(0),			--! microcontroller data input
			 uc_write_command => ctl_command,		--! '1' active microcontroller write command input
			 data_out => signal_CTL_RESET				--! data_out output
			);
	
	
	--! CTL1: CTL_START
	M_CTL1: flip_flop_RW_RC 
	port map(clk => clk,						--! clock input
		 clk_ena => clk_ena,				--! clock enable input
		 sync_rst => sync_rst,				--! '0' active synchronous reset input
		 uc_data_in => AVALON_writedata(1),				--! microcontroller data input
		 uc_write_command => ctl_command,			--! '1' active microcontroller write command input
		 i2c_clear_command => I2C_CTL_START_C, 		--! '1' active I2C clear command input
		 data_out => signal_CTL_START					--! data_out output
		);

	--! CTL2: CTL_STOP
	M_CTL2: flip_flop_RW_RC 

		port map(clk => clk,					--! clock input
			 clk_ena => clk_ena,				--! clock enable input
			 sync_rst => sync_rst,			--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(2),			--! microcontroller data input
			 uc_write_command => ctl_command,	--! '1' active microcontroller write command input
			 i2c_clear_command => I2C_CTL_STOP_C,	--! '1' active I2C clear command input
			 data_out => signal_CTL_STOP			--! data_out output
			);
			
			
	--! CTL3: CTL_RESTART
	M_CTL3: flip_flop_RW_RC 

		port map(clk => clk,				--! clock input
			 clk_ena => clk_ena,				--! clock enable input
			 sync_rst => sync_rst,			--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(3),			--! microcontroller data input
			 uc_write_command => ctl_command,	--! '1' active microcontroller write command input
			 i2c_clear_command => I2C_CTL_RESTART_C,	--! '1' active I2C clear command input
			 data_out => signal_CTL_RESTART			--! data_out output
			);
			
	--! CTL4: CTL_RW
	M_CTL4: flip_flop_RW_R 
		port map(clk => clk,						--! clock input
			 clk_ena => clk_ena,				--! clock enable input
			 sync_rst => sync_rst,				--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(4),				--! microcontroller data input
			 uc_write_command => ctl_command,		--! '1' active microcontroller write command input
			 data_out => signal_CTL_RW				--! data_out output
			);
			
	--! CTL5: CTL_ACK
	M_CTL5: flip_flop_RW_R 
		port map(clk => clk,					--! clock input
			 clk_ena => clk_ena,					--! clock enable input
			 sync_rst => sync_rst,				--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(5),				--! microcontroller data input
			 uc_write_command => ctl_command,		--! '1' active microcontroller write command input
			 data_out => signal_CTL_ACK				--! data_out output
			);
			
	--! CTL6: CTL_ROLE
	M_CTL6: flip_flop_RW_R 
		port map(clk => clk,					--! clock input
			 clk_ena => clk_ena,					--! clock enable input
			 sync_rst => sync_rst,				--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(6),				--! microcontroller data input
			 uc_write_command => ctl_command,		--! '1' active microcontroller write command input
			 data_out => signal_CTL_ROLE				--! data_out output
			);
	
	
	--! CTL7: CTL_RESERVED
	--	...
	--	...
	
	----- STATUS ----------------
	
	--! STATUS0: ST_ACK_REC
	M_STATUS0: Flip_flop_R_WR 
		Port map( 
			clk 			 => clk,
			clk_ena 		 => clk_ena,
			sync_rst 		 => sync_rst,
			i2c_write 		 => I2C_ST_ACK_REC_W,
			i2c_data_in 	 => I2C_ST_ACK_REC,
				  
			data_out 		 => signal_ST_ACK_REC
			);
	
	--   !!!!!!!!!!!!!!!!!
	--! STATUS1: ST_START_DETC
	M_STATUS1: Flip_flop_RC_S 
		Port map( 
			clk 			 => clk,
			clk_ena 		 => clk_ena,
			sync_rst 		 => sync_rst,
			uc_clear 		 => AVALON_writedata(1), 		-- Clear signal; '0': don't modify the content; '1': clear the bit content to '0' 
			uc_clear_command => st_command,
			i2c_set 		 => I2C_ST_START_DETC_S,
				  
			data_out 		 => signal_ST_START_DETC
			);
	
	--   !!!!!!!!!!!!!!!!!
	--! STATUS2: ST_STOP_DETC
	M_STATUS2: Flip_flop_RC_S 
		Port map( 
			clk 			 => clk,
			clk_ena 		 => clk_ena,
			sync_rst 		 => sync_rst,
			uc_clear 		 => AVALON_writedata(2),		-- Clear command
			uc_clear_command => st_command,
			i2c_set 		 => I2C_ST_STOP_DETC_S,
				  
			data_out 		 => signal_ST_STOP_DETC
			);
			
	--! STATUS3: ST_ERROR_DETC
	M_STATUS3: Flip_flop_RC_S 
		Port map( 
			clk 			=> clk,
			clk_ena 		=> clk_ena,
			sync_rst 		=> sync_rst,
			uc_clear 		=> AVALON_writedata(3),		-- Clear command
			uc_clear_command => st_command,
			i2c_set 		=> I2C_ST_ERROR_DETC_S,
				  
			data_out 		=> signal_ST_ERROR_DETC
			);
			
	--! STATUS4: ST_TX_EMPTY
	M_STATUS4: Flip_flop_RC_S 
		Port map( 
			clk 			=> clk,
			clk_ena 		=> clk_ena,
			sync_rst 		=> sync_rst,
			uc_clear 		=> AVALON_writedata(4),		-- Clear command
			uc_clear_command => st_command,
			i2c_set 		=> I2C_ST_TX_EMPTY_S,
				  
			data_out 		=> signal_ST_TX_EMPTY
			);
		
		
	--! STATUS5: ST_RX_FULL
	M_STATUS5: Flip_flop_RC_S 

		Port map( 
			clk 			=> clk,
			clk_ena 		=> clk_ena,
			sync_rst 		=> sync_rst,
			uc_clear 		=> AVALON_writedata(5),
			uc_clear_command => st_command,
			i2c_set 		=> I2C_ST_RX_FULL_S,
				  
			data_out 		=> signal_ST_RX_FULL
			);
			
			
	--! STATUS6: ST_RW
	M_STATUS6: Flip_flop_R_WR 
		Port map( 
			clk 			=> clk,
			clk_ena 		=> clk_ena,
			sync_rst 		=> sync_rst,
			i2c_write 		=> I2C_ST_RW_W,			-- Write command
			i2c_data_in 	=> I2C_ST_RW,
				  
			data_out 		=> signal_ST_RW
			);
			
	--! STATUS7: ST_BUSY
	M_STATUS7: Flip_flop_R_WR 
		Port map( 
			clk 			=> clk,
			clk_ena 		=> clk_ena,
			sync_rst 		=> sync_rst,
			i2c_write 		=> I2C_ST_BUSY_W,		-- Write command
			i2c_data_in 	=> I2C_ST_BUSY,
				  
			data_out 		=> signal_ST_BUSY
			);
			
			
	-------- TX 8-bit -----------
	M_TX: TX_8_bits_W_R 
		port map(clk => clk,		--! clk input
			 clk_ena => clk_ena,	--! clk enable input
			 sync_rst => sync_rst, 	--! synchronous reset input
			 uc_data_input => AVALON_writedata,		--! MicroController 8-bit input
			 uc_data_input_command => tx_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
			 data_output => signal_TX_DATA		--! output 8-bit 
			);
			
			
	------- RX 8-bit --------------
	M_RX: RX_8_bits_R_W
		port map(clk => clk,	--! clk input
			 clk_ena => clk_ena,		--! clk enable input
			 sync_rst => sync_rst,		--! synchronous reset input
			 i2c_data_input => I2C_RX_DATA,	--! 
			 i2c_data_input_command => I2C_RX_DATA_W,			--! i2c renew command, '1' renew output, '0' don't change output
			 data_output => signal_RX_DATA		--! data_output;
			);	
		
	-------- BAUDRATE	8-bit ---------
	-- ...
	-- ...
	M_BAUDRATE: TX_8_bits_W_R
		port map(clk => clk,		--! clk input
				 clk_ena => clk_ena,	--! clk enable input
				 sync_rst => sync_rst, 	--! synchronous reset input
				 uc_data_input => AVALON_writedata,		--! MicroController 8-bit input
				 uc_data_input_command => baudrate_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
				 data_output => signal_BAUDRATE		--! output 8-bit 
				);
	
	-------- SLAVE_ADDR 7-bit -----------
	M_SLAVE_ADDR: ADDR_7_bits_W_W 
		port map(clk => clk,		--! clk input
			 clk_ena => clk_ena, 	--! clk enable input
			 sync_rst => sync_rst, 	--! synchronous reset input
			 uc_data_input => slave_address,		--! (6 downto 0) of writedata; MicroController 7-bit input
			 uc_data_input_command => slv_addr_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
			 i2c_data_input => I2C_SLV_ADDR,
			 i2c_data_input_command => I2C_SLV_ADDR_command,
			 
			 data_output => signal_SLAVE_ADDR		--! output 7-bit 
			);
	
	
	-------- OWN ADDR 7-bit ---------------
	M_OWN_ADDR: ADDR_7_bits_RW_R
		port map(clk => clk,		--! clk input
			 clk_ena => clk_ena, 	--! clk enable input
			 sync_rst => sync_rst, 	--! synchronous reset input
			 uc_data_input => own_address,		--!  (6 downto 0) of writedata; MicroController 7-bit input
			 uc_data_input_command => own_addr_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
			 data_output => signal_OWN_ADDR		--! output 7-bit 
			);
			
			
	-------- INTERRUPT CTL MASK	--------------
	M_IRQ_CTL_MASK: TX_8_bits_W_R
		port map(clk => clk,		--! clk input
				 clk_ena => clk_ena,	--! clk enable input
				 sync_rst => sync_rst, 	--! synchronous reset input
				 uc_data_input => AVALON_writedata,		--! MicroController 8-bit input
				 uc_data_input_command => interrupt_ctl_mask_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
				 data_output => signal_IRQ_CTL_MASK	--! output 8-bit 
				);
				
				
	-------- INTERRUPT CTL CLEAR --------------
	M_IRQ_CTL_CLEAR: TX_8_bits_W_R
		port map(clk => clk,
				 clk_ena => clk_ena,
				 sync_rst => sync_rst,
				 uc_data_input => AVALON_writedata,		--! MicroController 8-bit input
				 uc_data_input_command => interrupt_ctl_clear_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
				 data_output => signal_IRQ_CTL_CLEAR	--! output 8-bit 
		);
	
	
	--- !!!!!!
	------- INTERRUPT CTL 
	--	....
	
	--  IRQ_CTL0 
	--  CTL_RESET
	M_IRQ_CTL0:  Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_CTL_CLEAR(0),
				 mask_in 		=> signal_IRQ_CTL_MASK(0),
				 set_in		=> CTL0,  		-- CTL0 = '1' --> IRQ_CTL0 = '1'	
					  
				 data_out 		=> signal_IRQ_CTL0
				 );
				 
	--  IRQ_CTL1 
	--  CTL_START
	M_IRQ_CTL1:  Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_CTL_CLEAR(1),				 
				 mask_in 		=> signal_IRQ_CTL_MASK(1),
				 set_in		=> CTL1,  			
					  
				 data_out 		=> signal_IRQ_CTL1
				 );
          
	--  IRQ_CTL2 
	--  CTL_STOP
	M_IRQ_CTL2:  Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_CTL_CLEAR(2),				 
				 mask_in 		=> signal_IRQ_CTL_MASK(2),
				 set_in		=> CTL2,  			
					  
				 data_out 		=> signal_IRQ_CTL2
				 );
	
	--  IRQ_CTL3 
	--  CTL_RESTART
	M_IRQ_CTL3:  Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_CTL_CLEAR(3),				 
				 mask_in 		=> signal_IRQ_CTL_MASK(3),
				 set_in		=> CTL3,  			
					  
				 data_out 		=> signal_IRQ_CTL3
				 );
	
	
	--  IRQ_CTL4 
	--  CTL_RW
	M_IRQ_CTL4:  Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_CTL_CLEAR(4),				 
				 mask_in 		=> signal_IRQ_CTL_MASK(4),
				 set_in		=> CTL4,  			
					  
				 data_out 		=> signal_IRQ_CTL4
				 );
				 
	--  IRQ_CTL5 
	--  CTL_ACK
	M_IRQ_CTL5:  Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_CTL_CLEAR(5),
				 mask_in 		=> signal_IRQ_CTL_MASK(5),
				 set_in		=> CTL5,  			
					  
				 data_out 		=> signal_IRQ_CTL5
				 );
				 
				 
	--  IRQ_CTL6 
	--  CTL_ROLE
	M_IRQ_CTL6:  Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_CTL_CLEAR(6),
				 mask_in 		=> signal_IRQ_CTL_MASK(6),
				 set_in		=> CTL6,  			
					  
				 data_out 		=> signal_IRQ_CTL6
				 );
				 
				 
	--  IRQ_CTL7 
	--  CTL_RESERVED
	M_IRQ_CTL7:  Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_CTL_CLEAR(7),
				 mask_in 		=> signal_IRQ_CTL_MASK(7),
				 set_in		=> CTL7,  			-- initialized at '0'
					  
				 data_out 		=> signal_IRQ_CTL7
				 );
	
	
	------ INTERRUPT ST MASK
	M_IRQ_ST_MASK: TX_8_bits_W_R
		port map(clk => clk,		--! clk input
				 clk_ena => clk_ena,	--! clk enable input
				 sync_rst => sync_rst, 	--! synchronous reset input
				 uc_data_input => AVALON_writedata,		--! MicroController 8-bit input
				 uc_data_input_command => interrupt_st_mask_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
				 data_output => signal_IRQ_ST_MASK	--! output 8-bit 
				);
	
	------ INTERRUPT ST CLEAR		
	M_IRQ_ST_CLEAR: TX_8_bits_W_R
		port map(clk => clk,		--! clk input
				 clk_ena => clk_ena,	--! clk enable input
				 sync_rst => sync_rst, 	--! synchronous reset input
				 uc_data_input => AVALON_writedata,		--! MicroController 8-bit input
				 uc_data_input_command => interrupt_st_clear_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
				 data_output => signal_IRQ_ST_CLEAR	--! output 8-bit 
				);
				
	-- !!!!!!!!!!!!		
	------- INTERRUPT ST
	--	....
	
	-- IRQ_ST0
	-- ST_ACK_REC
	M_IRQ_ST0: Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_ST_CLEAR(0),
				 mask_in 		=> signal_IRQ_ST_MASK(0),
				 set_in		=> I2C_ST_ACK_REC_W,  			-- write command for ST_ACK_REC, we use that input signal to determine the irq value
					  
				 data_out 		=> signal_IRQ_ST0
				 );
	
	-- IRQ_ST1	
	-- ST_START_DETC
	M_IRQ_ST1: Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_ST_CLEAR(1),
				 mask_in 		=> signal_IRQ_ST_MASK(1),
				 set_in		=> ST1,  			-- value in the ST1 register
					  
				 data_out 		=> signal_IRQ_ST1
				 );
				 
	-- IRQ_ST2	
	-- ST_STOP_DETC
	M_IRQ_ST2: Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_ST_CLEAR(2),
				 mask_in 		=> signal_IRQ_ST_MASK(2),
				 set_in		=> ST2,  			-- value in the ST1 register
					  
				 data_out 		=> signal_IRQ_ST2
				 );
				 
	-- IRQ_ST3
	-- ST_ERROR_DETC
	M_IRQ_ST3: Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_ST_CLEAR(3),
				 mask_in 		=> signal_IRQ_ST_MASK(3),
				 set_in		=> ST3,  			-- value in the ST1 register
					  
				 data_out 		=> signal_IRQ_ST3
				 );
				 
	
	-- IRQ_ST4
	-- ST_TX_EMPTY
	M_IRQ_ST4: Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_ST_CLEAR(4),
				 mask_in 		=> signal_IRQ_ST_MASK(4),
				 set_in		=> ST4,  			-- value in the ST1 register
					  
				 data_out 		=> signal_IRQ_ST4
				 );
				 
				 
	-- IRQ_ST5
	-- ST_RX_FULL
	M_IRQ_ST5: Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_ST_CLEAR(5),
				 mask_in 		=> signal_IRQ_ST_MASK(5),
				 set_in		=> ST5,  			-- value in the ST1 register
					  
				 data_out 		=> signal_IRQ_ST5
				 );			 
				 
				 
	-- IRQ_ST6
	-- ST_RW
	M_IRQ_ST6: Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_ST_CLEAR(6),
				 mask_in 		=> signal_IRQ_ST_MASK(6),
				 set_in		=> I2C_ST_RW_W,  			-- value in the ST1 register
					  
				 data_out 		=> signal_IRQ_ST6
				 );
				 
				 
	-- IRQ_ST7
	-- ST_BUSY
	M_IRQ_ST7: Flip_flop_interrupt_RC_mask 

		port map(clk 			=> clk,
				 clk_ena 		=> clk_ena,
				 sync_rst 	    => sync_rst,
				 clear_in 		=> signal_IRQ_ST_CLEAR(7),
				 mask_in 		=> signal_IRQ_ST_MASK(7),
				 set_in		=> ST7,  			-- ST_BUSY BIT, normally the mask of that bit should keep at '0'
					  
				 data_out 		=> signal_IRQ_ST7
				 );			 
				 
	------------------------------- Process --------------------------------------------------
	
	-- 1.
	-- Command Decoder
	-- activate the word correspond to the avalon address
	P_Decoder_write: process(AVALON_address, AVALON_write) is
	
	begin
	
		
		
		
			ctl_command <= '0';
			st_command <= '0';
			tx_command <= '0';
			slv_addr_command <= '0';
			baudrate_command <= '0';
			interrupt_ctl_mask_command <= '0';
			interrupt_ctl_clear_command <= '0';
			interrupt_ctl_command <= '0';
			interrupt_st_mask_command <= '0';
			interrupt_st_clear_command <= '0';
			interrupt_st_command <= '0';
			
			if(AVALON_write = '1') then
			
				case (to_integer(AVALON_address)) is
				
				when 0 =>
					ctl_command <= '1';
				
				when 1 => 
					st_command <= '1';
				
				when 2 =>
					tx_command <= '1';
					
				when 3 =>
					-- nothing
				
				when 4 =>
					baudrate_command <= '1';
				
				when 5 =>
					slv_addr_command <= '1';
					
				when 6 =>
					-- nothing
					
				when 7 =>
					interrupt_ctl_mask_command <= '1';
					
				when 8 =>
					interrupt_ctl_clear_command <= '1';
					
				when 9 =>
					-- Microcontroller can't modify directly the irq_ctl register
					
				when 10 =>
					interrupt_st_mask_command <= '1';
				
				when 11 => 
					interrupt_st_clear_command <= '1';
					
				when 12 => 
					-- Microcontroller can't modify directly the irq_st register
				
				when others => 
					-- Nothing
					-- ....
					
				end case;
				
			else
				-- Nothing
			end if;		-- AVALON write 
			
	
	
	end process P_Decoder_write;
	
	-- 2.
	-- Read data
	P_Decoder_read: process(AVALON_address, AVALON_read) is
	
	begin
	
		
		
		signal_CTL_data <= (CTL7 & CTL6 & CTL5 & CTL4 & CTL3 & CTL2 & CTL1 & CTL0);
		signal_ST_data <= (ST7 & ST6 & ST5 & ST4 & ST3 & ST2 & ST1 & ST0);
		signal_IRQ_CTL <= (signal_IRQ_CTL7 & signal_IRQ_CTL6 & signal_IRQ_CTL5 & signal_IRQ_CTL4 & signal_IRQ_CTL3 & signal_IRQ_CTL2 & signal_IRQ_CTL1 & signal_IRQ_CTL0);
		signal_IRQ_ST <= (signal_IRQ_ST7 & signal_IRQ_ST6 & signal_IRQ_ST5 & signal_IRQ_ST4 & signal_IRQ_ST3 & signal_IRQ_ST2 & signal_IRQ_ST1 & signal_IRQ_ST0);
		
			if(AVALON_read = '1') then
				
				AVALON_readvalid <= '1';
				
				case (to_integer(AVALON_address)) is
					
				when 0 => 
					AVALON_readdata <= signal_CTL_data;
				
				when 1 =>
					AVALON_readdata <= signal_ST_data;
				
				when 2 =>
					AVALON_readdata <= signal_TX_DATA;
					
				when 3 =>
					AVALON_readdata <= signal_RX_DATA;
				
				when 4 => 
					AVALON_readdata <= signal_BAUDRATE;
					
				when 5 =>
					AVALON_readdata <= '0' & signal_SLAVE_ADDR;			--- !!! signal_SLAVE_ADDR 7-bit, readdata 8-bit;
					
					
				when 6 =>
					AVALON_readdata <= '0' & signal_OWN_ADDR;
					
				when 7 =>
					AVALON_readdata <= signal_IRQ_CTL_MASK;
					
				when 8 =>
					AVALON_readdata <= signal_IRQ_CTL_CLEAR;
					
				when 9 =>
					----  ????
					AVALON_readdata <= signal_IRQ_CTL;
				
				when 10 =>
					AVALON_readdata <= signal_IRQ_ST_MASK;
					
				when 11 =>
					---- ?????
					AVALON_readdata <= signal_IRQ_ST_CLEAR;
					
				when 12 => 
					AVALON_readdata <= signal_IRQ_ST;
				
				when others =>
					---- Nothing
					
				end case;
		
			else
				-- Nothing
				AVALON_readvalid <= '0';
			
			end if;		-- AVALON_read 
		
	
	end process P_Decoder_read;
	
	-- 3.
	-- I2C OUTPUTS AND SIGNALS
	P_Outputs: process(clk) is
	
	begin
	
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				 CTL_RESET <= signal_CTL_RESET;			--! CTL0 
				 CTL_START <= signal_CTL_START;				--! CTL1
				 CTL_STOP <= signal_CTL_STOP;				--! CTL2
				 CTL_RESTART <= signal_CTL_RESTART;			--! CTL3
				 CTL_RW <= signal_CTL_RW;					--! CTL4
				 CTL_ACK <= signal_CTL_ACK;				--! CTL5
				 CTL_ROLE <= signal_CTL_ROLE;				--! CTL6
				 CTL_RESERVED <= signal_CTL_RESERVED;			--! CTL7
				
				 ---- STATUS 0 to 7
				 ST_ACK_REC <= signal_ST_ACK_REC;				--! STATUS0
				 ST_START_DETC <= signal_ST_START_DETC;			--! STATUS1
				 ST_STOP_DETC <= signal_ST_STOP_DETC;			--! STATUS2
				 ST_ERROR_DETC <= signal_ST_ERROR_DETC;			--! STATUS3
				 ST_TX_EMPTY <= signal_ST_TX_EMPTY;			--! STATUS4
				 ST_RX_FULL <= signal_ST_RX_FULL;				--! STATUS5
				 ST_RW <= signal_ST_RW;					--! STATUS6
				 ST_BUSY <= signal_ST_BUSY;				--! STATUS7
				
				 ---- TX 8-bit
				 TX_DATA <= signal_TX_DATA;		--! TX 8-bit
				
				 ---- RX 8-bit
				 RX_DATA <= signal_RX_DATA; 		--! RX 8-bit
				
				 ---- Baud Rate
				 BAUDRATE <= signal_BAUDRATE;		--! BAUDRATE 8-bit
				
				 ---- Slave Address 7-bit
				 SLAVE_ADDR <= signal_SLAVE_ADDR;		--! SLAVE_ADDR 7-bit
				
				 ---- OWN Address 7-bit
				 OWN_ADDR <= signal_OWN_ADDR;		--! Own Address, use for slave role
				
			end if;
	
		end if;
		 
	end process P_Outputs;
	
	

	
	
	-- 5. 
	-- BAUDRATE
	-- ....
	
	-- 6.
	P_IRQ: process(clk) is
	begin
	
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				if(sync_rst = '1') then
					avalon_irq_ctl <= (signal_IRQ_CTL0 OR signal_IRQ_CTL1 OR signal_IRQ_CTL2 OR signal_IRQ_CTL3 OR signal_IRQ_CTL4 OR signal_IRQ_CTL5 OR signal_IRQ_CTL6 OR signal_IRQ_CTL7);
					avalon_irq_st <= (signal_IRQ_ST0 OR signal_IRQ_ST1 OR signal_IRQ_ST2 OR signal_IRQ_ST3 OR signal_IRQ_ST4 OR signal_IRQ_ST5 OR signal_IRQ_ST6 OR signal_IRQ_ST7);
					--AVALON_irq <= avalon_irq_st OR avalon_irq_ctl;
					AVALON_irq <= (signal_IRQ_CTL0 OR signal_IRQ_CTL1 OR signal_IRQ_CTL2 OR signal_IRQ_CTL3 OR signal_IRQ_CTL4 OR signal_IRQ_CTL5 OR signal_IRQ_CTL6 OR signal_IRQ_CTL7) OR (signal_IRQ_ST0 OR signal_IRQ_ST1 OR signal_IRQ_ST2 OR signal_IRQ_ST3 OR signal_IRQ_ST4 OR signal_IRQ_ST5 OR signal_IRQ_ST6 OR signal_IRQ_ST7);
				else
					avalon_irq_ctl <= '0';
					avalon_irq_st <= '0';
					AVALON_irq <= '0';		------ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				end if;
				
			end if;
		end if;
	
	end process P_IRQ;
	
	
	-- 7.
	-- Waitrequest
	P_waitrequest: process(signal_waitrequest) is
	
	begin
	
		AVALON_waitrequest <= signal_waitrequest;
	
	end process P_waitrequest;
	
	
	
end architecture Behavioral;