----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         07.05.2016 07:12:23
-- Design Name: 
-- Module Name:         Side - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7 
-- Tool Versions: 
-- Description:         Half of node consisting of RX and TX pipeline
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

entity Side is

    generic(
        char_width  : integer
        );
    Port ( 
        clk_tx      : in std_logic;
        clk_rx      : in std_logic;
        reset_n     : in std_logic;
        d_in        : in std_logic;
        s_in        : in std_logic;
        char_in     : in std_logic_vector(7 downto 0);
        d_out       : out std_logic;
        s_out       : out std_logic;
        char_out    : out std_logic_vector(7 downto 0);
        ExRxRst     : out ExRxRst_rec        
        );
end Side;

architecture Behavioral of Side is

    signal ExRxTx      : ExRxExTx_rec;

begin

RX_pipeline: entity work.RX_pipeline        -- instantiate receiver pipeline

    generic map(
        char_width      => char_width
        )          
    port map ( 
        clk         => clk_rx,                      
        reset_n     => reset_n,
        d_in        => d_in,
        s_in        => s_in,
        char_out    => char_out,
        ExRxTx      => ExRxTx,
        ExRxRst     => ExRxRst
        ); 	
        
TX_pipeline: entity work.TX_pipeline        -- instantiate transmission pipeline
    generic map(
        char_width      => char_width
         )  
    port map ( 
         clk         => clk_tx,                      
         reset_n     => reset_n,
         char_in     => char_in,
         ExRxTx      => ExRxTx,
         d_out       => d_out,
         s_out       => s_out       
         );   
 
end Behavioral;
