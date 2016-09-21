---------------------------------------------
--! @file 
--! @brief Restart generator, to generate a restart condition (Sr)
--!	Updated 21/07/2016
--! Changhua DING
---------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;


--! Restart generator entity
entity restart_generator is

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
		 CTL_restart: out std_logic;		--! CTL_restart bit Clear command output, 
		 sda_out: out std_logic				--! SDA output
		 );	


end entity restart_generator;


--! Finite State Machine, behavioral architecture, Moore and Mealy combined state machine
architecture fsm of restart_generator is
	
	type state_type is (INIT, L1, H, L2, S_ERROR, SET_CTL);
	signal state: state_type;

begin

	-- Transition and storage
	P_transition_and_storages: process (clk) is
	
	begin
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				if(rst = '1') then
						case state is 
						
						when INIT => 
							if(writing_point = '1' and command_restart = '1') then		-- command_restart = '1'
								state <= L1;
							end if;
						
						when L1 => 
							if(stop_point = '1' ) then
								state <= H;
							end if;
							
						when H => 
							if(start_point = '1') then
								state <= L2;
							end if;
							
						when L2 => 
							if(falling_point = '1') then
								if(sda_in = '0') then
									state <= SET_CTL;
								else
									state <= S_ERROR;
								end if;
 							end if;
						
						when SET_CTL => 
							state <= INIT;
							
						when S_ERROR =>
							state <= INIT;
							
						end case;
					
				else
					state <= Init;
				
				end if;  -- if rst = '1'
			end if;		-- if clk_ena
		end if;		-- if clk
	end process P_transition_and_storages;
	
	
	P_statactions: process(state) is
	
	
	begin
	
		case state is
		
		when Init =>
			sda_out <= '1';
			CTL_restart <= '0';
			error_out <= '0';
			
		when L1 =>
			sda_out <= '0';
			CTL_restart <= '0';
			error_out <= '0';
			
		when H =>
			sda_out <= '1';
			CTL_restart <= '0';
			error_out <= '0';
		
		when L2 =>
			sda_out <= '0';
			CTL_restart <= '0';
			error_out <= '0';
		
		when SET_CTL =>
			sda_out <= '1';
			CTL_restart <= '1';
			error_out <= '0';
		
		when S_ERROR =>
			sda_out <= '1';
			CTL_restart <= '0';
			error_out <= '1';
			
			
		end case;
		
	end process P_statactions;


end architecture fsm;