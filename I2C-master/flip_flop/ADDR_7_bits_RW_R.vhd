----------------------------------------------------------------------
--!@file TX 8-bit register, MicroController Write, I2C engine Read
--!@brief detail used for TX transmission
--! Created on 09/09/2016 
----------------------------------------------------------------------


--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! ADDR_7_bits_W_R entity
entity ADDR_7_bits_RW_R is

	port(clk: in std_logic;			--! clk input
		 clk_ena: in std_logic; 	--! clk enable input
		 sync_rst: in std_logic; 	--! synchronous reset input
		 uc_data_input: in std_logic_vector(6 downto 0);		--! MicroController 7-bit input
		 uc_data_input_command: in std_logic;				--! input command, '1' register renew data from uc_input, '0' register won't modify the content.
		 data_output: out std_logic_vector(6 downto 0)		--! output 7-bit 
		);

end entity ADDR_7_bits_RW_R;

architecture Behavior of ADDR_7_bits_RW_R is

begin

	P_RW_R: process(clk) is
	
	begin
		
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				if(sync_rst = '1') then
					if(uc_data_input_command = '1') then
						data_output <= uc_data_input;
					else
						-- Nothing, don't renew output 
					end if;
				else
					data_output <= (others => '0');
				end if;
			end if;		-- clk_ena
		end if;		-- rising_edge(clk)
	
	end process P_RW_R;


end architecture Behavior;