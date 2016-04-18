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

	port (
	   
		CLK100MHZ		: in    	std_logic;						-- 100Mhz clock
		rst_n			: in    	std_logic;						-- "reset" button input (negative logic)				
		sw				: in 		std_logic_vector(3 downto 0);	-- 4 switches on FPGA board	
		btn             : in        std_logic_vector(3 downto 0);	-- 4 buttons on fpga board		
		jd              : in        std_logic_vector(1 downto 0);    -- 1st 2 pins of pmod header JD  
		led				: out 		std_logic_vector(3 downto 0);	-- 4 LEDs on FPGA board		
		ledb            : out       std_logic_vector(3 downto 0);  -- 4 blue LEDs on FPGA board		
		ja              : out       std_logic_vector(1 downto 0)	-- 1st 2 pins of pmod header JA	

	);
	
end node;

architecture RTL of node is
-- clocks
	signal clk_tx      : std_logic;                            -- transmitter clock
	signal clk_rx      : std_logic;                            -- receiver clock
-- data signals	
    signal display     : std_logic_vector(7 downto 0);         -- output to led's
-- flags
    signal data_flag    : std_logic;                            --  1 = send data
begin

TX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
    generic map (                                       
        PRESCALER 				=> 2            
        )
    port map ( 
        clkin           => CLK100MHZ,
        clkout          => clk_tx,                      
        rst_n           => rst_n
        ); 

RX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
    generic map (                                       
        PRESCALER 				=> 1              
        )
    port map ( 
        clkin           => CLK100MHZ,
        clkout          => clk_rx,                       
        rst_n           => rst_n
        ); 
        
Exchange: entity work.exchange_layer            -- instantiate Ckl prescaler
        
    port map ( 
        clk_rx          => clk_rx,
        clk_tx          => clk_tx,                      
        rst_n           => rst_n,
        --        null_dtcd       => null_dtcd,
        --        time_out        => time_out,
        --        rcvg_data       => rcvg_data,
        --        eop_rcvd        => eop_rcvd,
        --        fcc_sent        => fcc_sent,                    
        --        dtct_null       => dtct_null,
        data_flag       => data_flag 
        --        fcc_flag        => fcc_flag
        );         

TX_pipeline_nd: entity work.TX_pipeline            -- instantiate transmission pipeline

    port map ( 
        clk         => clk_tx,                      
        rst_n       => rst_n,
        sw          => sw,
        btn         => btn,
        data        => ja(0),
        strobe      => ja(1),
        data_flag   => data_flag      
        ); 
	   
RX_pipeline_nd: entity work.RX_pipeline            -- instantiate receiver pipeline
        
    port map ( 
        clk         => clk_rx,                      
        rst_n       => rst_n,
        data        => jd(0),
        strobe      => jd(1),
        display     => display     
        ); 	   
	
	
	led      <= display(7 downto 4);
	ledb      <=  display(3 downto 0);  
	--led(0)  <= data;
	--led(1) 	<= strobe;
	
	  
end RTL;
