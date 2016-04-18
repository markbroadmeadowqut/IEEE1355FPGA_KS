----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         17.04.2016 13:38:07
-- Design Name: 
-- Module Name:         RX_pipeline - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         RX pipeline of initial bus design
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

entity RX_pipeline is

    Port ( 
        clk     : in std_logic;
        rst_n   : in std_logic;
        data    : in std_logic;
        strobe  : in std_logic;
        display : out std_logic_vector(7 downto 0)
        );
        
end RX_pipeline;

architecture Behavioral of RX_pipeline is

    -- data signals	
    signal pc_char     : std_logic_vector(9 downto 0);         -- char from signal_rx layer
    signal char_rx     : std_logic_vector(7 downto 0);         -- char from char_rx layer 
	-- flags
    signal dtct_null   : std_logic;             --  1 = detect null char in signal_rx  
    signal eop_rcvd    : std_logic;             --  1 = end of packet received at signal_rx    
    signal char_rec    : std_logic;             --  1 = char received in signal_rx
    signal null_dtcd   : std_logic;             --  1 = null char detected in signal_rx to exchange layer
    signal time_out    : std_logic;             --  1 = conection has timed out 
    signal rcvg_data   : std_logic;             --  1 = data entering signal_rx 
    signal char_save   : std_logic;                            --  1 = save char in char_rx 
    

begin

signal_rx_inst: entity work.signal_rx           -- Instantiate receiver controller.
        
    port map (
        clk             => clk,
        rst_n           => rst_n,
        data_in         => data,           
        strobe_in       => strobe,
        dtct_null       => dtct_null,
        eop_rcvd        => eop_rcvd,         
        pc_char        => pc_char,
        char_rec        => char_rec,        
        null_dtcd       => null_dtcd,
        time_out        => time_out,
        rcvg_data       => rcvg_data              
        );
	   
char_rx_ins: entity work.char_rx                -- instantiate character layer upstream
                       
    port map ( 
        clk             => clk,
        rst_n           => rst_n,
        pc_char         => pc_char,
        char_rec        => char_rec,
        char_rx         => char_rx,
        char_save       => char_save
        );    	
	
packet_rx_ins: entity work.packet_rx            -- instantiate packet layer upstream
         
    port map ( 
        clk             => clk,
        rst_n           => rst_n,
        char_in         => char_rx,
        char_save       => char_save,
        display         => display
        );	

end Behavioral;
