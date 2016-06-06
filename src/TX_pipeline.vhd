----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         16.04.2016 12:41:12
-- Design Name: 
-- Module Name:         TX_pipeline - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         TX pipeline of initial bus design
-- Dependencies: 
-- Revision:
-- Revision             1
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bus_pkg.all;

entity TX_pipeline is

    Port ( 
        clk         : in std_logic;         -- TX clock
        reset_n     : in std_logic;         -- side reset signal
        PktEx       : in PktEx_rec;         -- signals from packet layer
        ExRxTx      : in ExRxExTx_rec;      -- flags from RX exchange
        rd_en       : out std_logic;        -- read from FIFO enable signal
        d_out       : out std_logic;        -- data stream out
        s_out       : out std_logic;        -- strobe stream out
        ExTxRx      : out ExTxExRx_rec;        -- fcc sent flag for rx exchange layer
        debugr      : out std_logic_vector(35 downto 0) -- debug chanel
        );
        
end TX_pipeline;

architecture Behavioral of TX_pipeline is

    -- data signals
    signal pc_char      : std_logic_vector(9 downto 0);     -- char from char_tx layer	
    signal data         : std_logic;                        -- data bit stream 
    -- clocks
    signal char_valid     : std_logic;              -- valid character in register
    
begin

Exchange_tx: entity work.exchange_tx            -- instantiate Exchange layer 

    port map ( 
        clk             => clk,                    
        reset_n         => reset_n,
        PktEx           => PktEx,
        ExRxTx          => ExRxTx,
        char_valid      => char_valid,
        rd_en           => rd_en,
        ExTxRx          => ExTxRx,
        pc_char         => pc_char, 
        debugr          => open           
        );  	
        
char_tx_ins: entity work.char_tx                -- instantiate character layer
                         
    port map ( 
        clk             => clk,
        char_valid      => char_valid,
        reset_n         => reset_n,
        char_in         => pc_char,
        d_out           => data,
        debugr          => open
        );            

signal_tx_ins: entity work.signal_tx            -- instantiate signal layer 
         
    port map ( 
        clk             => clk,
        reset_n         => reset_n,
        d_in            => data,
        d_out           => d_out,
        s_out           => s_out,
        debugr          => open
        );  
          
end Behavioral;
