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
        reset_n     : in std_logic;
        d_in        : in std_logic;
        s_in        : in std_logic;
        char_out    : out std_logic_vector(7 downto 0);
        ExRxTx      : out ExRxExTx_rec;
        ExRxRst     : out ExRxRst_rec
        --dtct_null   : in std_logic;
        --char_rcvd   : in std_logic;
        --char_save   : in std_logic;
       -- SigRxEx     : out SigRxEx_rec;
        --CharRxEx    : out CharRxEx_rec;
        --display     : out std_logic_vector(7 downto 0);
        --data_fwd    : out std_logic_vector(7 downto 0)
        );
        
end RX_pipeline;

architecture Behavioral of RX_pipeline is
    
    signal bit_valid    : std_logic;
    signal char_valid   : std_logic;
    
    -- data signals	
    signal data         : std_logic;
    signal pc_char      : std_logic_vector(9 downto 0);         -- char from signal_rx layer
 
    --signal char_rx      : std_logic_vector(7 downto 0);         -- char from char_rx layer 
	-- flags
    signal null_dtcd        : std_logic;
    --signal rd_char_parity   : std_logic;
    --signal char_rcvd        : std_logic;
    --signal SigChar          : SigChar_rec;
    

begin

signal_rx_inst: entity work.signal_rx           -- Instantiate receiver controller.

    generic map(
        char_width      => char_width
        )          
    port map (
        clk             => clk,
        reset_n         => reset_n,
        d_in            => d_in,           
        s_in            => s_in,
        d_out           => data,
        bit_valid       => bit_valid
        );
	   
char_rx_ins: entity work.char_rx                -- instantiate character layer upstream

    generic map(
        char_width      => char_width
        )                         
    port map (
        clk             => clk,
        reset_n         => reset_n,
        d_in            => data,
        bit_valid       => bit_valid,
        null_dtcd       => null_dtcd,
        char_valid      => char_valid,
        pc_char         => pc_char     
        );    	
	
Exchange_rx: entity work.exchange_rx            -- instantiate Ckl prescaler
    
    generic map(
        char_width      => char_width
        )  
    port map ( 
        clk             => clk,
        char_valid      => char_valid,                    
        reset_n         => reset_n,
        null_dtcd       => null_dtcd,
        pc_char         => pc_char, 
        char            => char_out,
        ExRxTx          => ExRxTx,
        ExRxRst         => ExRxRst       
        );  	
	


end Behavioral;
