-- shift_register_transmitter
--	With an internal buffer
--
-- Inputs: clk, 
-- 	go, 
-- 	sync_rst,  
-- 	byte_to_be_sent, 
-- 	rising_point, 
-- 	writing_point, 
--  scl_tick
-- Outputs: sda_out, write_command
--
-- 13/07/2016


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;	

entity shift_register_transmitter is

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
		  sda_out: out std_logic);			-- write_command = '1'  ==>  the buffer(byte_to_be_sent) could receive the new data from TX 
											-- and Microcontroller could update TX register
		  
end entity shift_register_transmitter;


architecture fsm of shift_register_transmitter is

	signal reg_write: std_logic;						-- reg_write is the internal signal to inform the internal buffer to renew the data from byte_to_be_sent
	signal go: std_logic;
	signal byte_to_be_sent: std_logic_vector(7 downto 0);
	signal data: std_logic_vector(7 downto 0);					-- ????????????????????????????
	type state_type is(CLEAR, WRITE_DATA, S7, S6, S5, S4, S3, S2, S1, S0, S_WAIT, RECEIVE_ACK);
	signal state: state_type := CLEAR;
	
begin

	--Moore Machine 
	
	-- Transition and storage
	P_transition_and_storage: process (clk) is
	
	
	begin
	
		if(rising_edge(clk)) then
		
			if(clk_ena = '1') then
				if(sync_rst = '0') then			-- rst 0 actif
					state <= CLEAR;
				else
				
					case state is
					
					when CLEAR => 
						if(go = '1') then
							state <= WRITE_DATA;
						end if;
					
					when WRITE_DATA => 
						
						if (writing_point = '1' and scl_tick = '1') then
							state <= S7;
						end if;
						
					when S7 =>
						if (writing_point = '1' and scl_tick = '1') then
							state <= S6;
						end if;
					
					when S6 =>
						if (writing_point = '1' and scl_tick = '1') then
							state <= S5;
						end if;
					
					when S5 =>
						if (writing_point = '1' and scl_tick = '1') then
							state <= S4;
						end if;
					
					when S4 =>
						if (writing_point = '1' and scl_tick = '1') then
							state <= S3;
						end if;
						
					when S3 =>
						if (writing_point = '1' and scl_tick = '1') then
							state <= S2;
						end if;
						
					when S2 =>
						if (writing_point = '1' and scl_tick = '1') then
							state <= S1;
						end if;
						
					when S1 =>
						if (writing_point = '1' and scl_tick = '1') then
							state <= S0;
						end if;
						
					when S0 =>
						if (writing_point = '1' and scl_tick = '1') then			-- rising_point
							state <= S_WAIT;
						end if;
						
					when S_WAIT =>
						if(sampling_point = '1' and scl_tick ='1') then
							state <= RECEIVE_ACK;
						end if;
						
					when RECEIVE_ACK => 
						if(falling_point = '1' and scl_tick = '1') then
							state <= CLEAR;
						end if;	
						
					end case;
					
				end if; -- if (sync_rst ='1') 
			end if; -- if (clk_ena = '1')
		end if;   -- if(rising_edge(clk))
	
			
	end process P_transition_and_storage;
	
	
	-- Outputs conditions
	P_stataction: process(state) is
	
	begin
		case state is
		
		when CLEAR =>
			data <= (others => '0');			-- Clear internal buffer to x0
			write_command <= '0';
			reg_write <= '0';
		
		when WRITE_DATA => 
		
			write_command <= '1';
			reg_write <= '1';
			data <= byte_to_be_sent;
			
		when S7 => 
			write_command <= '0';
			reg_write <= '0';
			sda_out <= data(7);
		
	
		when S6 => 
			write_command <= '0';
			reg_write <= '0';
			sda_out <= data(6);
			
			
		when S5 => 
			write_command <= '0';
			reg_write <= '0';
			sda_out <= data(5);
			
		
		when S4 => 
			write_command <= '0';
			reg_write <= '0';
			sda_out <= data(4);
		
			
		when S3 => 
			write_command <= '0';
			reg_write <= '0';
			sda_out <= data(3);
		
		
		when S2 => 
			write_command <= '0';
			reg_write <= '0';
			sda_out <= data(2);
		
			
		when S1 => 
			write_command <= '0';
			reg_write <= '0';
			sda_out <= data(1);
		
			
		when S0 => 
			write_command <= '0';
			reg_write <= '0';
			sda_out <= data(0);
			
		when S_WAIT =>
			write_command <= '0';
			reg_write <= '0';
			sda_out <= '1';			-- To AND with others SDA
			
		when RECEIVE_ACK =>
			write_command <= '0';
			reg_write <= '0';
			ACK_out <= sda_in;
			
			
		end case;

	end process P_stataction;
		
	-- Internal buffer process
	P_internal_buffer : process(clk) is
	
	begin
		if(rising_edge(clk)) then
		
			if(clk_ena = '1') then
				if(sync_rst = '1') then
					go <= '0';
					if(reg_write <= '1') then
					
						byte_to_be_sent <= TX;
						go <= '1';
					end if;
				else
					-- nothing ???????
				end if;  -- if(rst)
			end if;   	-- if(rising clk)
	
		end if;
	end process P_internal_buffer;


end architecture fsm;
