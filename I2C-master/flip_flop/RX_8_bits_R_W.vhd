--!@file RX 8-bit register, MicroController Read, I2C engine Write
--!@brief detail used for RX request
--! Created on 09/09/2016 
----------------------------------------------------------------------


--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! RX 8-bit register entity
entity RX_8_bits_R_W is
	
	port(clk: in std_logic;		--! clk input
		 clk_ena: in std_logic;			--! clk enable input
		 sync_rst: in std_logic;		--! synchronous reset input
		 i2c_data_input: in std_logic_vector(7 downto 0);	--! 
		 i2c_data_input_command: in std_logic;				--! i2c renew command, '1' renew output, '0' don't change output
		 data_output: out std_logic_vector(7 downto 0)		--! data_output;
		);	
	
end entity RX_8_bits_R_W;


architecture Behavior of RX_8_bits_R_W is

begin

	P_R_W: process(clk) is
	
	begin
		
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				if(sync_rst = '1') then
				
					if(i2c_data_input_command = '1') then
						data_output <= i2c_data_input;
					else
						-- Nothing
					end if;
					
				else
					data_output <= (others => '0');
				end if;
			
			end if;		-- clk enable
		end if;			-- clk
	
	end process P_R_W;


end architecture Behavior;