----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- Create Date:         17.04.2016 13:38:07
-- Design Name: 
-- Module Name:         RX_pipeline - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         RX pipeline of initial bus design.  Contains exchange
--                      character and signal layers.                    
-- Dependencies: 
-- Revision:            1    
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bus_pkg.all;

entity RX_pipeline is

    Port ( 
        clk         : in std_logic;     -- RX clock
        reset_n     : in std_logic;     -- side reset signal
        d_in        : in std_logic;     -- data stream received
        s_in        : in std_logic;     -- strobe stream received
        ExTxRx      : in ExTxExRx_rec;  -- flags to same side exchange layer
        PktEx       : in PktEx_rec;     -- Packet to exchange layer record
        wr_en       : out std_logic;    -- write enable to packet layer    
        char        : out std_logic_vector(7 downto 0); -- character received
        ExRxTx      : out ExRxExTx_rec; -- flags to same side exchange layer
        RxRst       : out RxRst_rec;    -- flags to reset manager
        debug      : out std_logic_vector(35 downto 0) -- debug chanel
        );
        
end RX_pipeline;

architecture Behavioral of RX_pipeline is    
    -- data signals	
    signal data         : std_logic;                        -- data bit signal
    signal pc_char      : std_logic_vector(9 downto 0);     -- char from signal_rx layer
	-- flags   
    signal bit_valid    : std_logic;    -- indicates valid bit in register
    signal char_valid   : std_logic;    -- indicates valid character in register
begin
    
signal_rx_inst: entity work.signal_rx           -- Instantiate receiver signal layer.     
    port map (
        clk             => clk,
        reset_n         => reset_n,
        d_in            => d_in,           
        s_in            => s_in,
        d_out           => data,                -- data stream captured
        bit_valid       => bit_valid,           -- valid bit in stream
        time_out        => RxRst.timeout,        -- timeout flag for reset manager
        debug          =>  open
        );
	   
char_rx_ins: entity work.char_rx                -- instantiate receiver character layer                      
    port map (                                      
        clk             => clk,
        reset_n         => reset_n,
        d_in            => data,
        bit_valid       => bit_valid,
        char_valid      => char_valid,          -- valid character in register
        link_actv       => RxRst.link_actv,     -- two nodes have an active link
        pc_char         => pc_char,              -- ten bit character with parity and control bits
        debug          => open 
        );    	
	
Exchange_rx: entity work.exchange_rx            -- instantiate receiver exchange layer    
    port map (                                  
        clk             => clk,
        char_valid      => char_valid,                    
        reset_n         => reset_n,
        full            => PktEx.full,          -- FIFO if full flag if ='1'
        ExTxRx          => ExTxRx,              -- fcc has been sent by TX layer
        pc_char         => pc_char,             
        parity_err      => RxRst.parity_err,    -- parity error detected flag for reset manager    
        wr_en           => wr_en,               -- write enable to write to FIFO
        char            => char,                -- 8 bit character to write to FIFO
        ExRxTx          => ExRxTx,
        debug           => open    
        );  	
        
end Behavioral;
