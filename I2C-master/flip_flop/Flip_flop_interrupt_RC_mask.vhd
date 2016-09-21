-------------------------------------------------------
--! @file
--! @brief Flip_flop_interrupt_RC_mask :
--! This entity with synchronization reset is uesd to perform a special port. 
--!	It could be read or cleared by microcontroller and determined by mask value and data_in value. 

-------------------------------------------------------

--! Use standard library
library IEEE;
--! Use logic elements
use IEEE.STD_LOGIC_1164.ALL;

------------------------------------------------------------
--! Flip_flop_RC_S entity brief description
--! Detailed description of this 
--! Flip_flop_RC_S design element.
entity Flip_flop_interrupt_RC_mask is

    Port( 
		clk 			: in  STD_LOGIC;
        clk_ena 		: in  STD_LOGIC;
		sync_rst 		: in  STD_LOGIC;
        clear_in 		: in  STD_LOGIC;
		mask_in 		: in  STD_LOGIC;
		set_in			: in  STD_LOGIC;	
			  
		data_out 		: out  STD_LOGIC
		);
          
end Flip_flop_interrupt_RC_mask;

--! @brief Architecture definition of the Flip_flop_RC_S
--! @details More details about this Flip_flop_RC_S element.
architecture Behavioral of Flip_flop_interrupt_RC_mask is

begin

--! @brief Process combination of the Architecture
--! @details More details about this combination element.
combination: process (clk) is

begin
	if(rising_edge(clk)) then
	
		if(clk_ena = '1') then
			if(sync_rst = '1') then
	
			
				if(clear_in = '1') then
					data_out <= '0';	
				elsif(mask_in = '1') then
					if(set_in = '1') then
						data_out <= '1';
					end if;
				else
					data_out <= '0';
				end if;
				
			else
				data_out <= '0';
			end if;
		end if;
	end if;
	

end process combination;
	
end architecture Behavioral;