----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         10.04.2016 10:51:32
-- Design Name: 
-- Module Name:         packet_rx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Packet layer for receiver 
-- Dependencies:
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 -      File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bus_pkg.all;

entity pkt_master is
    generic(
        char_width  : integer
        );
    Port ( 
    wr_clk          : in  std_logic;                         -- RX clock 
    rd_clk          : in  std_logic;        
    rst_n     	    : in  std_logic;
    sw              : in  std_logic_vector(3 downto 0);
    btn             : in  std_logic_vector(3 downto 0);
    ExPkgA          : in  ExPkg_rec;        
    ExPkgB          : in  ExPkg_rec;         
    display         : out std_logic_vector(7 downto 0);
    PkgExA          : out PkgEx_rec; 
    PkgExB          : out PkgEx_rec 
    );

end pkt_master;

architecture behavioral of pkt_master is  

    constant PkgEx_rst : PkgEx_rec := (
        dout        => (others => '0'),
        full        => '0',
        empty       => '0',
        eop1_rcvd   => '0'
        ); 
       
begin

--    PkgExB.eop1_rcvd <= ExPkgA.eop1_rcvd;
--    PkgExA.eop1_rcvd <= ExPkgB.eop1_rcvd;  


process(rd_clk,rst_n)  
    begin
        if (rst_n  = '0') then
            display     <= (others => '0');
            PkgExA      <= PkgEx_rst;
            PkgExB      <= PkgEx_rst;
            
        else
             if rising_edge(rd_clk) then
                PkgExA.empty <= '1';
                PkgExB.empty <= '0';  
                PkgExB.dout(3 downto 0)    <= btn;
                PkgExB.dout(7 downto 4)    <= sw;  
                display <= ExPkgA.din;                      
             end if;              
        end if;           
    end process;              
end behavioral;