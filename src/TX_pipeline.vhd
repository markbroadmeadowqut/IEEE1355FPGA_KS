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
use work.bus_pkg.all;

entity TX_pipeline is
   
    generic(
        char_width  : integer
        );
    Port ( 
        clk         : in std_logic;
        rst         : in std_logic;
        sw          : in std_logic_vector(3 downto 0);
        btn         : in std_logic_vector(3 downto 0);
        ExTx        : in ExTx_reg;
        data        : out std_logic;
        strobe      : out std_logic;
        CharTxEx    : out CharTxEx_reg
        );
        
end TX_pipeline;

architecture Behavioral of TX_pipeline is


    -- data signals
	signal char_pkt     : std_logic_vector(7 downto 0);         -- char from packet_tx layer 
    signal pc_char      : std_logic_vector(9 downto 0);         -- char from char_tx layer	   
    
begin

packet_tx_ins: entity work.packet_tx            -- instantiate packet layer TX
    generic map (
        char_width      => char_width
        ) 
    port map ( 
        clk             => clk,
        rst             => rst ,
        sw              => sw,
        btn             => btn, 
        req_pkt         => ExTx.req_pkt,      
        char_pkt        => char_pkt
        );           
 
        
char_tx_ins: entity work.char_tx                -- instantiate character layer TX
    generic map (
        char_width      => char_width
        )                          
    port map ( 
        clk             => clk,
        rst             => rst,
        char_in         => char_pkt,
        ExTx            => ExTx,
        CharTxEx        => CharTxEx,
        char_out        => pc_char  
        );            

signal_tx_ins: entity work.signal_tx            -- instantiate signal layer TX
    generic map (
        char_width      => char_width
        )       
    port map ( 
        clk             => clk,
        rst             => rst,
        char_in         => pc_char,
        ld_txreg        => ExTx.ld_txreg,
        data            => data,
        strobe          => strobe
        );   
        
end Behavioral;
