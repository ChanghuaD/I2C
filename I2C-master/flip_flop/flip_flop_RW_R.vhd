-----------------------------------------------------------------------------
--! @file
--! @brief a microcontroller Read_Write and I2C engine Read_only flip flop
--! Updated on 21/07/2016
--! Changhua DING
-----------------------------------------------------------------------------


--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! Read_Write & Read_only flip flop entity
entity	flip_flop_RW_R is

	port(clk: in std_logic;						--! clock input
		 clk_ena: in std_logic;					--! clock enable input
		 sync_rst: in std_logic;				--! '0' active synchronous reset input
		 uc_data_in: in std_logic;				--! microcontroller data input
		 uc_write_command: in std_logic;		--! '1' active microcontroller write command input
		 data_out: out std_logic				--! data_out output
	);

end entity flip_flop_RW_R;


--! behavior architecture
architecture behavior of flip_flop_RW_R is

begin
	
	-- Process -----------------
	
	--! microcontroller Read_Write and i2c read only process
	P_RW_R: process(clk) is
	
	begin
		
		if(rising_edge(clk)) then
			if(clk_ena = '1') then
				if(sync_rst = '1') then
				
					if(uc_write_command = '1')then
						data_out <= uc_data_in;
					else	
						-- Nothing
					end if;
					
				else
					data_out <= '0';
				end if;
				
			end if;
		end if;
	end process P_RW_R;


end architecture behavior;