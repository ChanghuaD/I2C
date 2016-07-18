-- This is the shift register receiver entity
-- To receive the sda bit and combine to an entire byte with double buffer

library ieee;
use ieee.std_logic_1164.all;

entity shift_register_receiver is

port(clk: in std_logic;
	 clk_ena: in std_logic;
	 sync_rst: in std_logic;
	 scl_tick: in std_logic;
	 sda_in: in std_logic;
	 falling_point: in std_logic;
	 sampling_point: in std_logic;
	 data_received: out std_logic;
	 RX: out std_logic_vector (7 downto 0));


end entity shift_register_receiver;

architecture FSM of shift_register_receiver is

signal reg_write: std_logic;
signal go: std_logic;
signal data: std_logic_vector (7 downto 0);
signal byte_to_be_used: std_logic_vector (7 downto 0);
type state_type is (CLEAR, S7, S6, S5, S4, S3, S2, S1, S0, READ_DATA);
signal state: state_type := CLEAR;

begin

	-- Moore Machine
	
	-- 1. 
	-- Transition and storage
	P_transition_and_storage: process(clk) is
	
	
	begin
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				if(sync_rst = '1') then
					case state is
					
					when CLEAR => 
					
						if(sampling_point = '1' and scl_tick = '1') then
							state <= S7;
						end if;
						
					when S7 =>
					
						if(sampling_point = '1' and scl_tick = '1') then
							state <= S6;
						end if;
						
					when S6 => 
					
						if(sampling_point = '1' and scl_tick = '1') then
							state <= S5;
						end if;
					
					when S5 => 
					
						if(sampling_point = '1' and scl_tick = '1') then
							state <= S4;
						end if;
						
					when S4 => 
					
						if(sampling_point = '1' and scl_tick = '1') then
							state <= S3;
						end if;
						
					when S3 => 
					
						if(sampling_point = '1' and scl_tick = '1') then
							state <= S2;
						end if;
						
					when S2 => 
					
						if(sampling_point = '1' and scl_tick = '1') then
							state <= S1;
						end if;
					
					when S1 => 
					
						if(sampling_point = '1' and scl_tick = '1') then
							state <= S0;
						end if;
						
					when S0 =>
					
						if(falling_point = '1' and scl_tick = '1') then
							state <= READ_DATA;
						end if;
						
					when READ_DATA =>
					
						if(go = '1') then
							state <= CLEAR;
						end if;
					
					end case;
				else
					state <= CLEAR;
				end if;
		
			end if;		-- if(clk_ena = '1')
		end if;			-- if(rising_edge(clk))
		
	
	end process P_transition_and_storage;
	
	
	
	-- 2.
	-- State actions
	P_stataction: process(state) is
	
	begin
	
		case state is
		
		when CLEAR =>
		
			data_received <= '1';
			reg_write <= '0';
			data <= (others => '0');
		
		when S7 => 
			data_received <= '0';
			reg_write <= '0';
			data(7) <= sda_in;
			
		when S6 => 
			data_received <= '0';
			reg_write <= '0';
			data(6) <= sda_in;
		
		when S5 => 
			data_received <= '0';
			reg_write <= '0';
			data(5) <= sda_in;
		
		when S4 => 
			data_received <= '0';
			reg_write <= '0';
			data(4) <= sda_in;
		
		when S3 => 
			data_received <= '0';
			reg_write <= '0';
			data(3) <= sda_in;
			
		when S2 => 
			data_received <= '0';
			reg_write <= '0';
			data(2) <= sda_in;
		
		when S1 => 
			data_received <= '0';
			reg_write <= '0';
			data(1) <= sda_in;
			
		when S0 => 
			data_received <= '0';
			reg_write <= '0';
			data(0) <= sda_in;	
			
		when READ_DATA => 
		
			data_received <= '0';
			reg_write <= '1';
			byte_to_be_used <= data;
			
		end case;
	
	end process P_stataction;
	
	-- 3.
	-- Internal buffer
	P_internal_buffer: process(clk) is
	
	begin
		if(rising_edge(clk)) then
			if(clk_ena = '1' ) then
				if(sync_rst = '1') then
					go <= '0';
					if(reg_write = '1') then
						RX <= byte_to_be_used;
						go <= '1';
					end if;
				else 
					-- Nothing
				end if;
			
			end if;
		end if;
	
	end process P_internal_buffer;
	
end architecture FSM;





