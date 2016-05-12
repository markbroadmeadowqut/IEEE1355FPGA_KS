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
    signal pkt_char_inA     : std_logic_vector(7 downto 0);         -- character received and to be saved to packet layer
    signal pkt_char_outA    : std_logic_vector(7 downto 0);         -- character to be sent by TX pipeline
    signal display          : std_logic_vector(7 downto 0);         -- output to led's
    --flags
    --signal ExTxA        : ExTx_rec;
    signal ExRxRstA      : ExRxRst_rec;
--    signal SigRxExA     : SigRxEx_rec;
--    signal CharRxExA    : CharRxEx_rec;
--    signal dtct_nullA   : std_logic;
--    signal char_saveA   : std_logic;
    signal reset_n      : std_logic;
    signal rstn_sw      : std_logic;
--    signal data_fwd     : std_logic_vector(7 downto 0);
begin



RST_man: entity work.RST_manager                -- instantiate reset manager
    port map (
        clk         => clk_pad,
        rstn_hw     => rst_n,
        ExRxRstA    => ExRxRstA,
        reset_n     => reset_n
    );
 
--TXRX_clock: entity work.clk_wiz_0
    
--        port map (
--            clk_in1     => clk_pad,
--            clk_tx      => clk_tx,
--            clk_rx      => clk_rx,
--            resetn      => rst_n,
--            locked      => locked
--            ); 
        
TX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
    generic map (                                       
        PRESCALER 				=> 2           
        )
    port map ( 
        clkin           => clk_pad,
        clkout          => clk_tx,                      
        rst_n           => rst_n
        );    

RX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
    generic map (                                       
        PRESCALER 				=> 1             
      )
    port map ( 
        clkin           => clk_pad,
        clkout          => clk_rx,                       
        rst_n           => rst_n
   ); 
       
Side_A: entity work.side                      -- instantiate Ckl prescaler
    generic map (                                       
        char_width      => char_width              
        )
    port map ( 
        clk_tx          => clk_tx,
        clk_rx          => clk_rx,                       
        reset_n         => reset_n,
        d_in            => d_inA,
        s_in            => s_inA,
        char_in         => pkt_char_outA,
        d_out           => d_outA,
        s_out           => s_outA,
        char_out        => pkt_char_inA,
        ExRxRst         => ExRxRstA
        );        

packet_ins: entity work.packet       -- instantiate common packet layer 
                
    generic map(
        char_width      => char_width
         )          
    port map ( 
         clk             => clk_tx,
         reset_n         => reset_n,
         sw              => sw,
         btn             => btn,
         char_in         => pkt_char_inA,
         char_out        => Pkt_char_outA,
         display         => display
         );                	
	
	led       <= display(7 downto 4);
	ledb      <= display(3 downto 0);  
	  
end RTL;
