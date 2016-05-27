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
        rst_n       : in std_logic;
        d_in        : in std_logic;
        s_in        : in std_logic;
        PkgEx       : in PkgEx_rec;
        d_out       : out std_logic;
        s_out       : out std_logic;
        ExPkg       : out ExPkg_rec
        );
end Side;

architecture Behavioral of Side is

    signal ExRxTx       : ExRxExTx_rec;
    signal RxRst        : RxRst_rec;
    signal reset_n      : std_logic;

begin

    ExPkg.eop1_rcvd <= ExRxTx.eop1_rcvd;

RST_man: entity work.RST_manager                -- instantiate reset manager
    port map (
        clk         => clk_rx,
        rstn_hw     => rst_n,
        RxRst       => RxRst,
        reset_n     => reset_n
    );

RX_pipeline: entity work.RX_pipeline        -- instantiate receiver pipeline

    generic map(
        char_width      => char_width
        )          
    port map ( 
        clk         => clk_rx,                      
        reset_n     => reset_n,
        d_in        => d_in,
        s_in        => s_in,
        PkgEx       => PkgEx,        
        wr_en       => ExPkg.wr_en,
        char        => ExPkg.din,
        ExRxTx      => ExRxTx,
        RxRst       => RxRst
        ); 	
        
TX_pipeline: entity work.TX_pipeline        -- instantiate transmission pipeline
    generic map(
        char_width      => char_width
         )  
    port map ( 
         clk         => clk_tx,                      
         reset_n     => reset_n,
         PkgEx       => PkgEx,         
         ExRxTx      => ExRxTx,
         rd_en       => ExPkg.rd_en,
         d_out       => d_out,
         s_out       => s_out       
         );   
 
end Behavioral;
