----------------------------------------------------------
--! @file
--! @brief Two-in-one 1-bit mux
--! Updated 08/09/2016
--! Changhua DING
----------------------------------------------------------


--! use standard library
library ieee;
--! use logic elements
use ieee.std_logic_1164.all;

--! 1-bit mux entity
entity demux_1_bit is

port(SEL: in std_logic;					--! SELECT '0' or '1' 
	 input: in  std_logic;  			--! input '0'
	 output_0: out std_logic;   			--! input '1'
	 output_1: out std_logic;	 			--! ouput
	 error: out std_logic				--! error
);

end entity demux_1_bit;

architecture Behavior of demux_1_bit is

begin

	P_process: process(SEL, input) is
	
	begin
		
		case(SEL) is
		
			when '0' =>
				output_0 <= input;
				error <= '0';
			when '1' =>
				output_1 <= input;
				error <= '0';
			when others =>
				output_0 <= input;
				error <= '1';
			
		end case;
	
	end process P_process;

end architecture Behavior;