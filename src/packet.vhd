----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands-- 
-- Create Date:         10.04.2016 10:51:32
-- Design Name: 
-- Module Name:         packet - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Common Packet layer 
-- Dependencies:
-- Dependencies: 
-- Revision:
-- Revision 0.01 -      File Created
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use work.bus_pkg.all;

entity packet is

    Port ( 
    wr_clk          : in  std_logic;                        -- RX clock 
    rd_clk          : in  std_logic;                        -- TX clock
    rst_n     	    : in  std_logic;
    sw              : in  std_logic_vector(3 downto 0);
    btn             : in  std_logic_vector(3 downto 0);
    ExPktA          : in  ExPkt_rec;                        -- records - exchange
    ExPktB          : in  ExPkt_rec;                        --   to packet layers
    display         : out std_logic_vector(7 downto 0);
    PktExA          : out PktEx_rec;                        -- records - packet to 
    PktExB          : out PktEx_rec                         --      exchange layer
    );

end packet;

architecture behavioral of packet is

    signal rst : std_logic;                             
                                            
    COMPONENT fifo_generator_0                  -- FIFO generated from IP catalog     
        PORT (                                  -- has upper limit of 500 MHz
            rst     : IN STD_LOGIC;             -- operating speed                
            wr_clk  : IN STD_LOGIC;                         
            rd_clk  : IN STD_LOGIC;
            din     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en   : IN STD_LOGIC;
            rd_en   : IN STD_LOGIC;
            dout    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full    : OUT STD_LOGIC;
            empty   : OUT STD_LOGIC
        );
    END COMPONENT;      
       
begin

    PktExB.eop1_rcvd <= ExPktA.eop1_rcvd;       -- EOP pass from TX to RX.  unable    
    PktExA.eop1_rcvd <= ExPktB.eop1_rcvd;       -- to pass through FIFO (no control
                                                -- chars
fifo_AtoB : fifo_generator_0        -- FIFO connecting RX side A to TX side B
    PORT MAP (                              
        rst     => rst,                 -- active high reset
        wr_clk  => wr_clk,              -- two clock inputs (clk_rx)
        rd_clk  => rd_clk,              --                  (clk_tx)
        din     => ExPktA.din,          -- 8 bit character in
        wr_en   => ExPktA.wr_en,        -- write enable flag
        rd_en   => ExPktB.rd_en,        -- read enable flag
        dout    => PktExB.dout,         -- 8 bit character out
        full    => PktExA.full,         -- FIFO full flag
        empty   => PktExB.empty         -- FIFO empty flag
    ); 
    
fifo_BtoA : fifo_generator_0        -- FIFO connecting RX side B to TX side A
    PORT MAP (
        rst     => rst,
        wr_clk  => wr_clk,
        rd_clk  => rd_clk,
        din     => ExPktB.din,
        wr_en   => ExPktB.wr_en,
        rd_en   => ExPktA.rd_en,
        dout    => PktExA.dout,
        full    => PktExB.full,
        empty   => PktExA.empty
    );     

process(rst_n,rd_clk)       --This process displays the received character
                            -- on the onboard LED's
    begin
    
        rst <= not rst_n;
    
        if (rst_n  = '0') then
            display     <= (others => '0');
        else
           display <= ExPktA.din;  
        end if;           
    end process;              
end behavioral;