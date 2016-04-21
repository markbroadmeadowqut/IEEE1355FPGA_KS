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
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision             0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TX_pipeline is
   
    generic(
        char_width  : integer
        );
    Port ( 
        clk         : in std_logic;
        rst_n       : in std_logic;
        sw          : in std_logic_vector(3 downto 0);
        btn         : in std_logic_vector(3 downto 0);
        data        : out std_logic;
        strobe      : out std_logic
        );
        
end TX_pipeline;

architecture Behavioral of TX_pipeline is

    -- data signals
	signal char_pkt     : std_logic_vector(7 downto 0);         -- char from packet_tx layer 
	signal parity       : std_logic;
    signal pc_char      : std_logic_vector(9 downto 0);         -- char from char_tx layer	   
    -- flags
    signal req_pkt      : std_logic;                            --  1 = request char from packet_tx
    signal data_flag    : std_logic;
    signal fcc_flag     : std_logic;                            --  1 = send fcc (flow control token)
    signal fcc_sent     : std_logic;                            --  1 = used to toggle fcc_flag back to 0 
    signal ld_txreg     : std_logic;

begin

packet_tx_ins: entity work.packet_tx            -- instantiate packet layer TX
     
    port map ( 
        clk             => clk,
        rst_n           => rst_n,
        sw              => sw,
        btn             => btn, 
        req_pkt         => req_pkt,       
        char_pkt        => char_pkt
        );           
                
Exchange_tx: entity work.exchange_tx            -- instantiate Ckl prescaler
        
    port map ( 
        clk             => clk,                    
        rst_n           => rst_n,
        --        null_dtcd       => null_dtcd,
        --        time_out        => time_out,
        --        rcvg_data       => rcvg_data,
        --        eop_rcvd        => eop_rcvd,
        --        fcc_sent        => fcc_sent,                    
        --        dtct_null       => dtct_null,
        data_flag       => data_flag, 
        ld_txreg        => ld_txreg,
        req_pkt         => req_pkt,
        fcc_flag        => fcc_flag
        --        fcc_flag        => fcc_flag
        );   
        
char_tx_ins: entity work.char_tx                -- instantiate character layer TX
                       
    port map ( 
        clk             => clk,
        rst_n           => rst_n,
        char_in         => char_pkt,
        char_out        => pc_char,  
        data_flag       => data_flag,
        fcc_flag        => fcc_flag, 
        fcc_sent        => fcc_sent
        );            

signal_tx_ins: entity work.signal_tx            -- instantiate signal layer TX
             
    port map ( 
        clk             => clk,
        rst_n           => rst_n,
        char_in         => pc_char,
        ld_txreg        => ld_txreg,
        data            => data,
        strobe          => strobe
        );   
        
end Behavioral;
