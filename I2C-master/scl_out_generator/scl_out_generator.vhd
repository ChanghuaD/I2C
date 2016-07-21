---------------------------------------------------------
--! @file
--! @brief To Generate the SCL signal
--! Updated 05/07/2016
--! Changhua DING
-----------------------------------------------------------


--! use standard library
library ieee;
--! use logic elements
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--! scl_out_generator entity
entity scl_out_generator is 

	generic(max_state: positive := 10;		--! maximum number of states, that means the number of ticks per SCL cycle, it should be at least 10.
			critical_state: positive := 5	--! the critical state, that means at that state, the SCL change from 0 to 1, if we want to change in the middle of SCL cycle, this number should be (max_state/2).
			);
	
	port(clk: in std_logic;			--! clock input
		 rst: in std_logic;			--! '0' active synchronous reset input
		 scl_tick: in std_logic;	--! scl ticks input
		 scl_in: in std_logic;		--! scl_in input
		 scl_out: out std_logic		--! scl_out output
		);	
		 
end entity scl_out_generator;

--! Finite State Machine
architecture fsm of scl_out_generator is

	signal state: integer;
	--constant critical_state: positive := 5;   -- !!!!! at this constant, the scl_out change from 0 to 1 (rising_edge)

begin

	--! Transition and Storage
	P_transition_and_storage: process(clk) is			
	variable var_state: integer range 0 to max_state;
	begin
	
--		if(rising_edge(scl_tick)) then
		if(rising_edge(clk)) then
			if(rst = '0')then
				var_state := 0;
			else
				if((scl_tick) = '1') then
					if(var_state < (max_state - 1)) then
					
						if(var_state = (critical_state)) then			-- Critical state = 4 
							
							if(scl_in = '1') then						-- Change the state until we get a '1' on scl_in
								var_state := var_state + 1;
							else
							-- Nothing
							end if;
							
						else
							var_state := var_state + 1;
						end if;
					else
						var_state := 0;									-- Change from "max_count-1" to '0'
					end if;
					
				else
				-- Nothing	
				end if;
			end if;
		end if;
	state <= var_state;
	end process P_transition_and_storage;
	
	
	--! State Actions
	-- 2. P_statactions
	-- the output scl_out depends on current state.
	P_statactions: process(scl_in, state) is
	variable var_scl_out: std_logic;
	begin
		if(state < critical_state) then
			var_scl_out := '0';
		else
			var_scl_out := '1';
		end if;
	scl_out <= var_scl_out;
	end process P_statactions;


end architecture fsm;