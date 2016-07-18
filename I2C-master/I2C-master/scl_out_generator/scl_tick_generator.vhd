--
-- max_cycles VHDL with cascadable counter
-- FSM generate SCL 
-- Baud Rate divisor frequency = 8x I²C frequency 
-- Baud Rate divisor 
-- inputs: clk, ena, casc_in, sync_rst
-- outputs: count, casc_out
-- 
-- 20/06/2016

library ieee;
use ieee.std_logic_1164.all;

-- entity
-- rst: synchronous and low level active
entity scl_tick_generator is
	generic( max_count: positive := 8);
	
	port(   clk_50MHz: in std_logic;
			sync_rst: in std_logic;
			ena: in std_logic;
			--casc_in: in std_logic;
			--count: out integer range 0 to (max_count-1);
			scl_tick: out std_logic);
end scl_tick_generator;

-- architecture fsm
architecture fsm of scl_tick_generator is

	-- signal: current count state
	signal count_state: integer range 0 to (max_count-1);
	--signal scl_state: std_logic;
begin

	-- Mealy State Machine 
	-- with low level active synchronous reset, enable, clock
	

	-- transitions_and_strorage
	transitions_and_strorage: process(clk_50MHz) is
	variable var_count_state: integer range 0 to (max_count-1);
	begin
--		scl_tick <= '0';
	-- if(rising_edge(clk_50mhz)) then
	if(rising_edge(clk_50mhz)) then
		if((sync_rst = '1') )then
			if(ena = '1') then
				if(var_count_state = (max_count-1)) then
					var_count_state := 0;
				else
--					if (var_count_state = 0) then
--						scl_tick <= '1';
--					end if;
					var_count_state := var_count_state + 1;
				end if;
			end if;
		else
			var_count_state := 0;	
		end if;
		count_state <= var_count_state;
		-- count <= var_count_state;
	end if;
	
	--	count <= count_state;    -- A delay to the falling edge of clock
	end process transitions_and_strorage;
	
	-- transitactions of Mealy Machine
	-- Output depends on the inputs and current state
	-- The output conditions:
	-- To have output an '1', we have to get a '1' on "casc_in" input pin and sync_rst in inactive status
	-- the output: scl_tick will be reset at '0' when sync_rst is active(at '0')
	-- output signal: scl_tick should keep at a clock period
	transitactions: process (count_state, ena, sync_rst) is
	begin
		scl_tick <= '0';
	  if((count_state = 0) and ((ena = '1') and (sync_rst = '1')) )then 
			scl_tick <= '1';						
	  end if;

	end process transitactions;
end fsm;

