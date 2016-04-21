----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         29.03.2016 12:01:16
-- Design Name:         Bus_Top
-- Module Name:         Top Design
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Top end of initial bus design
-- 
-- Dependencies: 
-- 
-- Revision:            1
-- Additional Comments:
 
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;


entity node is
    generic (
        char_width : integer := 8
    );

	port (
	   
		clk_pad		    : in    	std_logic;						-- 100Mhz clock
        rst_n           : in        std_logic;                      -- "reset" button input (negative logic)                
        sw              : in        std_logic_vector(3 downto 0);   -- 4 switches on FPGA board    
        btn             : in        std_logic_vector(3 downto 0);   -- 4 buttons on fpga board        
        d_in            : in        std_logic;                      -- Data in pin
        s_in            : in        std_logic;                      -- Strobe in pin  
        led             : out       std_logic_vector(3 downto 0);   -- 4 LEDs on FPGA board        
        ledb            : out       std_logic_vector(3 downto 0);   -- 4 blue LEDs on FPGA board        
        d_out           : out       std_logic;                      -- Data out pin
        s_out           : out       std_logic                       -- strobe out pin

	);
	
end node;

architecture RTL of node is
    -- clocks
	signal clk_tx      : std_logic;                            -- transmitter clock
	signal clk_rx      : std_logic;                            -- receiver clock
    -- data signals	
    signal display     : std_logic_vector(7 downto 0);         -- output to led's
 
begin

TX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
    generic map (                                       
        PRESCALER 				=> 1            
        )
    port map ( 
        clkin           => clk_pad,
        clkout          => clk_tx,                      
        rst_n           => rst_n
        ); 

--RX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
--    generic map (                                       
--        PRESCALER 				=> 1              
--        )
--    port map ( 
--        clkin           => clk_pad,
--        clkout          => clk_rx,                       
--        rst_n           => rst_n
--        ); 
        

TX_pipeline_nd: entity work.TX_pipeline            -- instantiate transmission pipeline
    generic map(
        char_width      => char_width
    )  
    port map ( 
        clk         => clk_tx,                      
        rst_n       => rst_n,
        sw          => sw,
        btn         => btn,
        data        => d_out,
        strobe      => s_out       
        ); 
	   
RX_pipeline_nd: entity work.RX_pipeline            -- instantiate receiver pipeline
        
    port map ( 
        clk         => clk_pad,                      
        rst_n       => rst_n,
        data        => d_in,
        strobe      => s_in,
        display     => display     
        ); 	   
	
--    process (clk_pad,rst_n)
--        begin
            --if rising_edge(clk_pad) then
--                if (rst_n = '0') then                          -- reset all 
--                    led         <= "0000";        
--                    ledb        <= "0000"; 
--                    display     <= "00000000";          
--                end if; 
            --end if;           
--        end process;    	
	
	led      <= display(7 downto 4);
	ledb      <=  display(3 downto 0);  
	--led(0)  <= data;
	--led(1) 	<= strobe;
	
	  
end RTL;
