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
use work.bus_pkg.all;

entity RX_pipeline is
    generic(
        char_width  : integer
        );
    Port ( 
        clk         : in std_logic;
        rst_n       : in std_logic;
        data        : in std_logic;
        strobe      : in std_logic;
        dtct_null   : in std_logic;
        char_rcvd   : in std_logic;
        char_save   : in std_logic;
        ctrl_chars  : in control_chars;
        SigRxEx     : out SigRxEx_reg;
        CharRxEx    : out CharRxEx_reg;
        display     : out std_logic_vector(7 downto 0)
        );
        
end RX_pipeline;

architecture Behavioral of RX_pipeline is

    -- data signals	
    signal pc_char      : std_logic_vector(9 downto 0);         -- char from signal_rx layer
    signal char_rx      : std_logic_vector(7 downto 0);         -- char from char_rx layer 
	-- flags
    signal rd_parity        : std_logic;
    signal rd_char_parity   : std_logic;
    

begin

signal_rx_inst: entity work.signal_rx           -- Instantiate receiver controller.

    generic map(
        char_width      => char_width
        )          
    port map (
        clk             => clk,
        rst_n           => rst_n,
        data_in         => data,           
        strobe_in       => strobe,
        dtct_null       => dtct_null,
        null_char       => ctrl_chars.null_char,
        ctrl_chars      => ctrl_chars,
        rd_parity       => rd_parity,
        rd_char_parity  => rd_char_parity,     
        pc_char         => pc_char,
        SigRxEx         => SigRxEx          
        );
	   
char_rx_ins: entity work.char_rx                -- instantiate character layer upstream

    generic map(
        char_width      => char_width
        )                         
    port map ( 
        clk             => clk,
        rst_n           => rst_n,
        char_rcvd       => char_rcvd,
        rd_parity       => rd_parity,
        rd_char_parity  => rd_char_parity,
        pc_char         => pc_char,
        ctrl_chars      => ctrl_chars,
        char_rx         => char_rx,
        CharRxEx        => CharRxEx        
        );    	
	
packet_rx_ins: entity work.packet_rx            -- instantiate packet layer upstream

    generic map(
        char_width      => char_width
        )          
    port map ( 
        clk             => clk,
        rst_n           => rst_n,
        char_in         => char_rx,
        char_save       => char_save,
        display         => display
        );	

end Behavioral;
