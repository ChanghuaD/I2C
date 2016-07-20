-- Generate a start condition (S) on I2C Line
-- 
-- 19/07/2016


library ieee;
use ieee.std_logic_1164.all;

entity start_generator is

port(clk: in std_logic;
	 clk_ena: in std_logic;
	 rst: in std_logic;
	 scl_tick: in std_logic;
	 start_point: in std_logic;
	 falling_point: in std_logic;
	 writing_point: in std_logic;
	 command_start: in std_logic;
	 sda_in: in std_logic;
	 error_out: out std_logic;
	 CTL_start: out std_logic;
	 sda_out: out std_logic);

end entity start_generator;

architecture fsm of start_generator is
	
	
	type state_type is (Init, H, L, ERROR, SET_CTL);
	signal state: state_type;
begin
	
	
	-- Moore & Mealy Combined State Machine
	-- Transition and storage
	P_transition_and_storages: process (clk) is
	
	begin
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				if(rst = '1') then
						case state is 
						
						when INIT => 
							if(writing_point = '1' and command_start = '1') then		-- command_start = '1'
								state <= H;
							end if;
						
						when H => 
							if(start_point = '1' ) then
								state <= L;
							end if;
	
							
						when L => 
							if(falling_point = '1') then
								if(sda_in = '0') then
									state <= SET_CTL;
								else
									state <= ERROR;
								end if;
							end if;
							
						when SET_CTL =>
							state <= INIT;
						
						when ERROR =>
							state <= INIT;
							
						end case;
					
				else
					state <= INIT;
				
				end if;  -- if rst = '1'
			end if;		-- if clk_ena
		end if;		-- if clk
	end process P_transition_and_storages;

	-- State actions
	P_statactions: process(state) is
	
	
	begin
	
		case state is
		
		when INIT =>
			sda_out <= '1';
			CTL_start <= '1';
			error_out <= '0';
			
		when H =>
			sda_out <= '1';
			CTL_start <= '1';
			error_out <= '0';
			
		when L =>
			sda_out <= '0';
			CTL_start <= '1';
			error_out <= '0';
			
		when SET_CTL =>
		
			sda_out <= '1';
			CTL_start <= '0';
			error_out <= '0';
		
		when ERROR =>
			sda_out <= '1';
			CTL_start <= '1';
			error_out <= '1';

		end case;
		
	end process P_statactions;

end architecture fsm;