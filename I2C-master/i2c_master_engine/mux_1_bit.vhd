----------------------------------------------------------
--! @file
--! @brief 8-bit mux
--! Updated 05/09/2016
--! Changhua DING
----------------------------------------------------------


--! use standard library
library ieee;
--! use logic elements
use ieee.std_logic_1164.all;

--! mux entity
entity mux_1_bit is

port(SEL: in std_logic;								--! SELECT '0' or '1' 
	 input_0: in  std_logic;  	--! input '0'
	 input_1: in std_logic;   	--! input '1'
	 output: out std_logic;	 	--! ouput
	 error: out std_logic							--! error
);

end entity mux_1_bit;

architecture behavioral of mux_1_bit is

begin

	P_process: process(SEL, input_0, input_1) is

	begin
	
		case (SEL) is
		
		when '0' => 
			output <= input_0;
			error <= '0';
			
		when '1' =>
			output <= input_1;
			error <= '0';
		
		when others => 
			error <= '1';
		
		end case;

	end process P_process;
	
end architecture behavioral;