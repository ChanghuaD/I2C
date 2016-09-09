--------------------------------------------------------------
--!@file register
--!@brief	registers connect with AVALON interface and I2C engine
--! Created on 09/09/2016
--------------------------------------------------------------

--! Use standard library
library IEEE;
--! Use logic elements
use IEEE.STD_LOGIC_1164.ALL;

entity i2c_register is

	port(clk: in std_logic;						-- clk input
		 clk_ena: in std_logic;					-- clk_ena input
		 sync_rst: in std_logic; 				-- synchronous reset input			
		 
		 
		 -- To accomplish with I2C's input ports
		 --
		 --
		 
		 
		 
		 -- To accomplish with Microcontroller's input ports
		 --
		 --
		 
		 
		 
		 
		 ------------------- Outputs Ports
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

architecture Behavioral of register_slave is


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
	

	

	
	
begin



	--------------- Map -----------------------------------
	M_CTL_ROLE:	flip_flop_RW_R
	port map(clk => clk,						--! clock input
			 clk_ena => clk_ena,					--! clock enable input
			 sync_rst => sync_rst,				--! '0' active synchronous reset input
			 uc_data_in =>				--! microcontroller data input
			 uc_write_command: in std_logic;		--! '1' active microcontroller write command input
			 data_out => CTL_ROLE				--! data_out output
			);
