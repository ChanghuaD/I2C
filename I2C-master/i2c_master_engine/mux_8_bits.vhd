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
entity mux_8_bits is

port(SEL: in std_logic;								--! SELECT '0' or '1' 
	 input_0: in  std_logic_vector(7 downto 0);  	--! input '0'
	 input_1: in std_logic_vector(7 downto 0);   	--! input '1'
	 output: out std_logic_vector(7 downto 0);	 	--! ouput
	 error: out std_logic							--! error
);

end entity mux_8_bits;

architecture behavioral of mux_8_bits is

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