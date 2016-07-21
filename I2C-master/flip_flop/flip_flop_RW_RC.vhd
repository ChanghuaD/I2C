---------------------------------------------------------------------------
--! @file
--! @brief a microcontroller Read_Write and I2C engine Read_Clear flip flop
--! Updated 21/07/2016
--! Changhua DING
---------------------------------------------------------------------------

--! Use standard library
library ieee;
--!	Use logic elements
use ieee.std_logic_1164.all;


--! Read_Write & Read_Clear Flip Flop Entity
entity flip_flop_RW_RC is

begin
	port(clk: in std_logic;					--! clock input
		 clk_ena: in std_logic;				--! clock enable input
		 sync_rst: in std_logic;			--! '0' active synchronous reset input
		 uc_data_in: in std_logic;			--! microcontroller data input
		 uc_write_command: in std_logic;	--! '1' active microcontroller write command input
		 i2c_clear_command: in std_logic;	--! '1' active I2C clear command input
		 data_out: out std_logic			--! data_out output
	);
	
end entity flip_flop_RW_RC;

--! Behavioral architecture of flip_flop_RW_RC
architecture behavior of flip_flop_RW_RC is


begin
	
	-- Process ---------------------
	
	-- 
	--! microcontroller Write and i2c clear Process
	--! microcontroller's uc_write_command has higher priority level than i2c_clear_command
	P_RW_RC: process(clk) is
	
	begin
		
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				if(sync_rst = '1') then
				
					if(uc_write_command = '1') then
						data_out <= uc_data_in;
					else
						if(i2c_clear_command = '1') then
							data_out <= '0';
						else
						-- Nothing
						end if;
					end if;
					
				else
					data <= '0';
				end if;
			end if;
		end if;
	end process P_RW_RC;
	

end architecture behavior;
