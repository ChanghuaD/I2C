--!@file i2c_global_engine
--!@brief the global i2c engine including the registers, i2c master engine and i2c slave engine.
--! 20/09/2016

--! Use IEEE library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_global_engine is

	port(clk: in std_logic;						-- clk input
		 clk_ena: in std_logic;					-- clk_ena input
		 sync_rst: in std_logic; 				-- synchronous reset input	
		
		 -- AVALON INPUT PORTS
		 -- AVALON MM SIGNALS
		 AVALON_address: in unsigned (3 downto 0);		
		 AVALON_read: in std_logic;
		 AVALON_write: in std_logic;
		 AVALON_writedata: in std_logic_vector (7 downto 0);
		 
		 -- I2C INPUT PORTS
		 SCL_IN: in std_logic;			--! SCL input
		 SDA_IN: in std_logic;			--! SDA input
		 
		 
		 -- AVALON OUTPUT PORTS
		 -- interrupt IRQ SIGNALS
		 -- Control
		 AVALON_irq_ctl_0: out std_logic;
		 AVALON_irq_ctl_1: out std_logic;
		 AVALON_irq_ctl_2: out std_logic;
		 AVALON_irq_ctl_3: out std_logic;
		 AVALON_irq_ctl_4: out std_logic;
		 AVALON_irq_ctl_5: out std_logic;
		 AVALON_irq_ctl_6: out std_logic;
		-- AVALON_irq_ctl_7: out std_logic;			--reserved
		 
		 -- Status
		 AVALON_irq_st_0: out std_logic;
		 AVALON_irq_st_1: out std_logic;
		 AVALON_irq_st_2: out std_logic;
		 AVALON_irq_st_3: out std_logic;
		 AVALON_irq_st_4: out std_logic;
		 AVALON_irq_st_5: out std_logic;
		 AVALON_irq_st_6: out std_logic;		--! irq_st_6 = '1' --> Microcontroller must compare the SLAVE_ADDR and OWN_ADDR and write the correspond value into CTL_ACK BIT immediately. 
		 AVALON_irq_st_7: out std_logic;
		 
		 
		 -- I2C OUTPUT PORTS
		 SCL_OUT: out std_logic;				--! SCL output
		 SDA_OUT: out std_logic 				--! SDA output

	);
end entity i2c_global_engine;



architecture Behavioral of i2c_global_engine is

begin


end architecture Behavioral;