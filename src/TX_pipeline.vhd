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
        reset_n     : in std_logic;
        PkgEx       : in PkgEx_rec;
        ExRxTx      : in ExRxExTx_rec;
        rd_en       : out std_logic;
        d_out       : out std_logic;
        s_out       : out std_logic
        );
        
end TX_pipeline;

architecture Behavioral of TX_pipeline is

    -- data signals
	signal char_pkt     : std_logic_vector(7 downto 0);         -- char from packet_tx layer 
    signal pc_char      : std_logic_vector(9 downto 0);         -- char from char_tx layer	
    signal data         : std_logic;
    -- clocks
    signal char_valid     : std_logic;
    
      
    
begin

Exchange_tx: entity work.exchange_tx            -- instantiate Ckl prescaler
    generic map(
        char_width      => char_width
        )  
    port map ( 
        clk             => clk,                    
        reset_n         => reset_n,
        empty           => PkgEx.empty,
        char            => PkgEx.dout,
        ExRxTx          => ExRxTx,
        char_valid      => char_valid,
        rd_en           => rd_en,
        pc_char         => pc_char            
        );  	
        
char_tx_ins: entity work.char_tx                -- instantiate character layer TX
   
    generic map (
        char_width      => char_width
        )                          
    port map ( 
        clk             => clk,
        char_valid      => char_valid,
        reset_n         => reset_n,
        char_in         => pc_char,
        d_out           => data  
        );            

signal_tx_ins: entity work.signal_tx            -- instantiate signal layer TX
    generic map (
        char_width      => char_width
        )       
    port map ( 
        clk             => clk,
        reset_n         => reset_n,
        d_in            => data,
        d_out           => d_out,
        s_out           => s_out
        );   
        
end Behavioral;
