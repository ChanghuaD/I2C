--!@file Testbench for I2C global engine
--!@brief Simulate a avalon master(Microcontroller) which control the register via avalon interface
--!@details 

entity tb_i2c_global_engine is

end entity tb_i2c_global_engine;

architecture Behaviroal of tb_i2c_global_engine is


	component i2c_global_engine is

	generic (N: positive := 3);

	port(AVALON_clk: in std_logic;						-- clk input
		 --clk_ena: in std_logic;					-- clk_ena input
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
		 -- 
		 AVALON_irq: out std_logic;
		 
		 -- readdata
		 AVALON_readdata: out std_logic;
		 AVALON_readvalid: out std_logic;
		 
		 -- waitrequest
		 AVALON_waitrequest: out std_logic;
		 
		 
		 -- I2C OUTPUT PORTS
		 SCL_OUT: out std_logic;				--! SCL output
		 SDA_OUT: out std_logic 				--! SDA output

	);
	end component i2c_global_engine;

	------------ SIGNALS -------------------
	signal clk_50MHz: std_logic;
	signal sync_rst: std_logic;
	
begin

	------------------ Map	-----------------------
	uut: i2c_global_engine
	port(AVALON_clk: in std_logic;						-- clk input
		 --clk_ena: in std_logic;					-- clk_ena input
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
		 -- 
		 AVALON_irq: out std_logic;
		 
		 -- readdata
		 AVALON_readdata: out std_logic;
		 AVALON_readvalid: out std_logic;
		 
		 -- waitrequest
		 AVALON_waitrequest: out std_logic;
		 
		 
		 -- I2C OUTPUT PORTS
		 SCL_OUT: out std_logic;				--! SCL output
		 SDA_OUT: out std_logic 				--! SDA output

	);
	
	
	
end architecture;