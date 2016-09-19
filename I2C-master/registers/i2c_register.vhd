--------------------------------------------------------------
--!@file register
--!@brief	registers connect with AVALON interface and I2C engine
--! Created on 09/09/2016
--------------------------------------------------------------

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
		 
		 I2C_ST_ACK_REC_W: in std_logic;
		 I2C_ST_START_DETC_S: in std_logic;
		 I2C_ST_STOP_DETC_S: in std_logic;
		 I2C_ST_ERROR_DETC_S: in std_logic;
		 I2C_ST_TX_EMPTY_S: in std_logic;
		 I2C_ST_RX_FULL_S: in std_logic;
		 I2C_ST_ACK_REC: in std_logic;
		 I2C_ST_RW: in std_logic;
		 I2C_ST_RW_W: in std_logic;
		 I2C_ST_BUSY: in std_logic;
		 I2C_ST_BUSY_W: in std_logic;
		 
		 I2C_RX_DATA: in std_logic_vector(7 downto 0);
		 I2C_RX_DATA_W: in std_logic;
		 
		 -- To accomplish with Microcontroller's input ports
		 -- Avalon Slave Interface
		 -- 1 word = 1 byte  --> byte address = word address, don't need address translation between Avalon's Master and Slave
		 
		 AVALON_chipselect: in std_logic;
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
		 
		 -- Control
		 AVALON_irq_ctl_0: out std_logic;
		 AVALON_irq_ctl_1: out std_logic;
		 AVALON_irq_ctl_2: out std_logic;
		 AVALON_irq_ctl_3: out std_logic;
		 AVALON_irq_ctl_4: out std_logic;
		 AVALON_irq_ctl_5: out std_logic;
		 AVALON_irq_ctl_6: out std_logic;
		 AVALON_irq_ctl_7: out std_logic;
		 
		 
		 -- Status
		 AVALON_irq_st_0: out std_logic;
		 AVALON_irq_st_1: out std_logic;
		 AVALON_irq_st_2: out std_logic;
		 AVALON_irq_st_3: out std_logic;
		 AVALON_irq_st_4: out std_logic;
		 AVALON_irq_st_5: out std_logic;
		 AVALON_irq_st_6: out std_logic;
		 AVALON_irq_st_7: out std_logic;
		 
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
	component ADDR_7_bits_W_R is

	port(clk: in std_logic;			--! clk input
		 clk_ena: in std_logic; 	--! clk enable input
		 sync_rst: in std_logic; 	--! synchronous reset input
		 uc_data_input: in std_logic_vector(6 downto 0);		--! MicroController 7-bit input
		 uc_data_input_command: in std_logic;				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
		 data_output: out std_logic_vector(6 downto 0)		--! output 7-bit 
		);

	end component ADDR_7_bits_W_R;


	--------------- signal ------------------------------
	

	--signal CTL0_uc_data_in: std_logic;
	signal ctl_command: std_logic;			-- Command the CTL register (activate by avalon address & write)
	signal st_command: std_logic;			-- Command the STATUS register (activate by avalon address & write)
	signal tx_command: std_logic;			-- Command the TX_DATA register (activate by avalon master)
	signal slv_addr_command: std_logic;		-- Command the slave address word
	signal baudrate_command: std_logic;		-- Command the baudrate register
	signal interrupt_ctl_mask_command: std_logic;	-- Command the interrupt control mask register
	signal interrupt_st_mask_command: std_logic;	-- Command the interrupt status mask register
	
	signal CTL_data: std_logic_vector(7 downto 0);
	signal ST_data: std_logic_vector(7 downto 0);
	
	
	alias slave_address: std_logic_vector (6 downto 0) is AVALON_writedata (6 downto 0);
	alias CTL0: std_logic is CTL_RESET;
	
	
	
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
			 data_out => CTL_RESET				--! data_out output
			);
	
	
	--! CTL1: CTL_START
	M_CTL1: flip_flop_RW_RC 
	port map(clk => clk,						--! clock input
		 clk_ena => clk_ena,				--! clock enable input
		 sync_rst => sync_rst,				--! '0' active synchronous reset input
		 uc_data_in => AVALON_writedata(1),				--! microcontroller data input
		 uc_write_command => ctl_command,			--! '1' active microcontroller write command input
		 i2c_clear_command => I2C_CTL_START_C, 		--! '1' active I2C clear command input
		 data_out => CTL_START					--! data_out output
		);

	--! CTL2: CTL_STOP
	M_CTL2: flip_flop_RW_RC 

		port map(clk => clk,					--! clock input
			 clk_ena => clk_ena,				--! clock enable input
			 sync_rst => sync_rst,			--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(2),			--! microcontroller data input
			 uc_write_command => ctl_command,	--! '1' active microcontroller write command input
			 i2c_clear_command => I2C_CTL_STOP_C,	--! '1' active I2C clear command input
			 data_out => CTL_STOP			--! data_out output
			);
			
			
	--! CTL3: CTL_RESTART
	M_CTL3: flip_flop_RW_RC 

		port map(clk => clk,				--! clock input
			 clk_ena => clk_ena,				--! clock enable input
			 sync_rst => sync_rst,			--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(3),			--! microcontroller data input
			 uc_write_command => ctl_command,	--! '1' active microcontroller write command input
			 i2c_clear_command => I2C_CTL_RESTART_C,	--! '1' active I2C clear command input
			 data_out => CTL_RESTART			--! data_out output
			);
			
	--! CTL4: CTL_RW
	M_CTL4: flip_flop_RW_R 
		port map(clk => clk,						--! clock input
			 clk_ena => clk_ena,				--! clock enable input
			 sync_rst => sync_rst,				--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(4),				--! microcontroller data input
			 uc_write_command => ctl_command,		--! '1' active microcontroller write command input
			 data_out => CTL_RW				--! data_out output
			);
			
	--! CTL5: CTL_ACK
	M_CTL5: flip_flop_RW_R 
		port map(clk => clk,					--! clock input
			 clk_ena => clk_ena,					--! clock enable input
			 sync_rst => sync_rst,				--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(5),				--! microcontroller data input
			 uc_write_command => ctl_command,		--! '1' active microcontroller write command input
			 data_out => CTL_ACK				--! data_out output
			);
			
	--! CTL6: CTL_ROLE
	M_CTL6: flip_flop_RW_R 
		port map(clk => clk,					--! clock input
			 clk_ena => clk_ena,					--! clock enable input
			 sync_rst => sync_rst,				--! '0' active synchronous reset input
			 uc_data_in => AVALON_writedata(6),				--! microcontroller data input
			 uc_write_command => ctl_command,		--! '1' active microcontroller write command input
			 data_out => CTL_ROLE				--! data_out output
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
				  
			data_out 		 => ST_ACK_REC
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
				  
			data_out 		 => ST_START_DETC
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
				  
			data_out 		 => ST_STOP_DETC
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
				  
			data_out 		=> ST_ERROR_DETC
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
				  
			data_out 		=> ST_TX_EMPTY
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
				  
			data_out 		=> ST_RX_FULL
			);
			
			
	--! STATUS6: ST_RW
	M_STATUS6: Flip_flop_R_WR 
		Port map( 
			clk 			=> clk,
			clk_ena 		=> clk_ena,
			sync_rst 		=> sync_rst,
			i2c_write 		=> I2C_ST_RW_W,			-- Write command
			i2c_data_in 	=> I2C_ST_RW,
				  
			data_out 		=> ST_RW
			);
			
	--! STATUS7: ST_BUSY
	M_STATUS7: Flip_flop_R_WR 
		Port map( 
			clk 			=> clk,
			clk_ena 		=> clk_ena,
			sync_rst 		=> sync_rst,
			i2c_write 		=> I2C_ST_BUSY_W,		-- Write command
			i2c_data_in 	=> I2C_ST_BUSY,
				  
			data_out 		=> ST_BUSY
			);
			
			
	-------- TX 8-bit -----------
	M_TX: TX_8_bits_W_R 
		port map(clk => clk,		--! clk input
			 clk_ena => clk_ena,	--! clk enable input
			 sync_rst => sync_rst, 	--! synchronous reset input
			 uc_data_input => AVALON_writedata,		--! MicroController 8-bit input
			 uc_data_input_command => tx_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
			 data_output => TX_DATA		--! output 8-bit 
			);
			
			
	------- RX 8-bit --------------
	M_RX: RX_8_bits_R_W
		port map(clk => clk,	--! clk input
			 clk_ena => clk_ena,		--! clk enable input
			 sync_rst => sync_rst,		--! synchronous reset input
			 i2c_data_input => I2C_RX_DATA,	--! 
			 i2c_data_input_command => I2C_RX_DATA_W,			--! i2c renew command, '1' renew output, '0' don't change output
			 data_output => RX_DATA		--! data_output;
			);	
		
	-------- BAUDRATE	8-bit ---------
	-- ...
	-- ...
	
	
	-------- SLAVE_ADDR 7-bit -----------
	M_SLAVE_ADDR: ADDR_7_bits_W_R 

	port map(clk => clk,		--! clk input
		 clk_ena => clk_ena, 	--! clk enable input
		 sync_rst => sync_rst, 	--! synchronous reset input
		 uc_data_input => slave_address,		--! MicroController 7-bit input
		 uc_data_input_command => slv_addr_command,				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
		 data_output => SLAVE_ADDR		--! output 7-bit 
		);
	
	
	
	
	------------------------------- Process --------------------------------------------------
	
	-- 1.
	-- Command Decoder
	-- activate the word correspond to the avalon address
	P_Decoder_write: process(clk) is
	
	begin
	
		if(rising_edge(clk)) then
		
		
			ctl_command <= '0';
			st_command <= '0';
			tx_command <= '0';
			slv_addr_command <= '0';
			baudrate_command <= '0';
			interrupt_ctl_mask_command <= '0';
			interrupt_st_mask_command <= '0';
			
			if(AVALON_write = '1') then
			
				case(AVALON_address) is
				
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
					-- nothing
				when 9 =>
					interrupt_st_mask_command <= '1';
				
				when 10 => 
					-- nothing
				
				when others => 
					-- nothing
				
				end case;
				
			else
				-- Nothing
			end if;		-- AVALON write 
			
		end if;		-- clk
	
	end process P_Decoder_write;
	
	-- 2.
	-- Read data
	P_Decoder_read: process(clk) is
	
	begin
	
		
		if(rising_edge(clk)) then
		
		CTL_data <= "0000000" & CTL0;
		
			if(AVALON_read = '1') then
				
				AVALON_readvalid <= '1';
				
				case(AVALON_address) is
					
				when 0 => 
					AVALON_readdata <= CTL_data;
				
				when 1 =>
					AVALON_readdata <= ST_data;
				
				when 2 =>
					AVALON_readdata <= ST_data;
					
				end case;
		
			else
				-- Nothing
				AVALON_readvalid <= '0';
			
			end if;		-- AVALON_read 
		
		end if;
	
	end process P_Decoder_read;
	
	
	
	
	
	
end architecture Behavioral;