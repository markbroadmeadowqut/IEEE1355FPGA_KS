----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- Create Date:         07.05.2016 07:12:23
-- Design Name: 
-- Module Name:         Side - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7 
-- Tool Versions: 
-- Description:         Half of node containing RX and TX pipeline
-- Dependencies: 
-- Revision:
-- Revision             1
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use work.bus_pkg.all;

entity Side is

    Port ( 
        clk_tx      : in std_logic;
        clk_rx      : in std_logic;
        rst_n       : in std_logic;
        d_in        : in std_logic;
        s_in        : in std_logic;
        PktEx       : in PktEx_rec;
        d_out       : out std_logic;
        s_out       : out std_logic;
        ExPkt       : out ExPkt_rec;
        debug       : out std_logic_vector(35 downto 0) -- debug chanel
        );
end Side;

architecture Behavioral of Side is

    signal ExRxTx       : ExRxExTx_rec;
    signal RxRst        : RxRst_rec;
    signal reset_n      : std_logic;
    signal ExTxRx       : ExTxExRx_rec;
    
begin

    ExPkt.eop1_rcvd <= ExRxTx.eop1_rcvd;

RST_man: entity work.RST_manager            -- instantiate reset manager
    port map (                              -- each side has RST manager
        clk         => clk_rx,              -- so they can shut down
        rstn_hw     => rst_n,               -- independantly
        RxRst       => RxRst,
        reset_n     => reset_n,
        debug       => open
    );

RX_pipeline: entity work.RX_pipeline        -- instantiate receiver pipeline
                                            -- consisting of signal, 
    port map (                              -- character and exchange layers
        clk         => clk_rx,                      
        reset_n     => reset_n,
        d_in        => d_in,                -- data signal in
        s_in        => s_in,                -- data signal out
        ExTxRx     =>  ExTxRx,
        PktEx       => PktEx,               -- signals from packet layer
        wr_en       => ExPkt.wr_en,         -- signals to packet layer
        char        => ExPkt.din,
        ExRxTx      => ExRxTx,              -- signals between exchange layers
        RxRst       => RxRst,                -- parity and time out flags to rst man
        debug       => open
        ); 	
        
TX_pipeline: entity work.TX_pipeline        -- instantiate transmitter pipeline
                                            -- consisting of signal, 
    port map (                              -- character and exchange layers
         clk         => clk_tx,                      
         reset_n     => reset_n,
         PktEx       => PktEx,               
         ExRxTx      => ExRxTx,
         rd_en       => ExPkt.rd_en,
         d_out       => d_out,              -- data signal out
         s_out       => s_out,              -- strobe signal out
         ExTxRx      =>  ExTxRx,
         debug       =>  debug
         ); 
                   
end Behavioral;
