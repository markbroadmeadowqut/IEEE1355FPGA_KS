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
use work.bus_pkg.all;

entity node is
    generic ( 
        char_width  : integer := 8                               -- character width       
    );

	port (
	   
		clk_pad		    : in    	std_logic;						-- 100Mhz clock
        rst_n           : in        std_logic;                      -- "reset" button input (negative logic)                
        sw              : in        std_logic_vector(3 downto 0);   -- 4 switches on FPGA board    
        btn             : in        std_logic_vector(3 downto 0);   -- 4 buttons on fpga board        
        d_inA           : in        std_logic;                      -- Data in pin
        s_inA           : in        std_logic;                      -- Strobe in pin  
        led             : out       std_logic_vector(3 downto 0);   -- 4 LEDs on FPGA board        
        ledb            : out       std_logic_vector(3 downto 0);   -- 4 blue LEDs on FPGA board        
        d_outA          : out       std_logic;                      -- Data out pin
        s_outA          : out       std_logic                       -- strobe out pin

	);
	
end node;

architecture RTL of node is

    -- clocks
	signal clk_tx       : std_logic;                            -- transmitter clock
	signal clk_rx       : std_logic;                            -- receiver clock
	signal locked       : std_logic;                            -- if '1' clocks stable and usable
    -- data signals	
    signal display      : std_logic_vector(7 downto 0);         -- output to led's
    --flags
    signal ExTxA        : ExTx_reg;
    signal CharTxExA    : CharTxEx_REG;
    signal SigRxExA     : SigRxEx_reg;
    signal CharRxExA    : CharRxEx_reg;
    signal dtct_nullA   : std_logic;
    signal char_rcvdA   : std_logic;
    signal char_saveA   : std_logic;
    signal rst          : std_logic;
    signal rst_sw       : std_logic;
    signal rst_rev      : std_logic;
begin

rst_rev <= rst xor '1';

RST_man: entity work.RST_manager                -- instantiate reset manager
    port map (
        rst_n       => rst_n,
        rst_sw      => rst_sw,
        rst         => rst
    );
        

TXRX_clock: entity work.clk_wiz_0

    port map (
        clk_in1     => clk_pad,
        clk_tx      => clk_tx,
        clk_rx      => clk_rx,
        reset       => rst_rev,
        locked      => locked
        );

--TX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
--    generic map (                                       
--        PRESCALER 				=> 2            
--        )
--    port map ( 
--        clkin           => clk_pad,
--        clkout          => clk_tx,                      
--        rst             => rst
--        );    

--RX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
--    generic map (                                       
--        PRESCALER 				=> 1              
--        )
--    port map ( 
--        clkin           => clk_pad,
--        clkout          => clk_rx,                       
--       rst             => rst
--        ); 
        
        
        
                
Exchange_tx: entity work.exchange_tx            -- instantiate Ckl prescaler
    generic map(
        char_width      => char_width
        )  
    port map ( 
        clk             => clk_tx,                    
        rst             => rst,
        CharTxExA       => CharTxExA,
        SigRxExA        => SigRxExA,
        CharRxExA       => CharRxExA,
        dtct_nullA      => dtct_nullA,
        char_rcvdA      => char_rcvdA,
        char_saveA      => char_saveA,
        rst_sw          => rst_sw,
        ExTxA           => ExTxA                
        );  

	   
RX1_pipeline_nd: entity work.RX_pipeline            -- instantiate receiver pipeline

    generic map(
        char_width      => char_width
        )          
    port map ( 
        clk         => clk_rx,--pad,                      
        rst         => rst,
        data        => d_inA,
        strobe      => s_inA,
        dtct_null   => dtct_nullA,
        char_rcvd   => char_rcvdA,
        char_save   => char_saveA,
        SigRxEx     => SigRxExA,
        CharRxEx    => CharRxExA,
        display     => display     
        ); 	   

TX1_pipeline_nd: entity work.TX_pipeline            -- instantiate transmission pipeline
    generic map(
        char_width      => char_width
        )  
    port map ( 
        clk         => clk_tx,                      
        rst         => rst,
        sw          => sw,
        btn         => btn,
        ExTx        => ExTxA,
        data        => d_outA,
        strobe      => s_outA,
        CharTxEx    => CharTxExA       
        );	
   	
	
	led      <= display(7 downto 4);
	ledb      <=  display(3 downto 0);  
	--led(0)  <= data;
	--led(1) 	<= strobe;
	
	  
end RTL;
