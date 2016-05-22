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

entity packet is
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

end packet;

architecture behavioral of packet is
       
COMPONENT fifo_generator_0
    PORT (
        rst     : IN STD_LOGIC;
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

fifo_AtoB : fifo_generator_0
    PORT MAP (
        rst     => not rst_n,
        wr_clk  => wr_clk,
        rd_clk  => rd_clk,
        din     => ExPkgB.din,
        wr_en   => ExPkgB.wr_en,
        rd_en   => ExPkgA.rd_en,
        dout    => PkgExA.dout,
        full    => PkgExB.full,
        empty   => PkgExA.empty
    );
  
fifo_BtoA : fifo_generator_0
    PORT MAP (
        rst     => not rst_n,
        wr_clk  => wr_clk,
        rd_clk  => rd_clk,
        din     => ExPkgA.din,
        wr_en   => ExPkgA.wr_en,
        rd_en   => ExPkgB.rd_en,
        dout    => PkgExB.dout,
        full    => PkgExA.full,
        empty   => PkgExB.empty
    );  

process(rst_n)  
    begin
        if (rst_n  = '0') then
            display     <= (others => '0');
           -- char_out    <= (others => '0');
        else
             --if rising_edge(clk) then
                --char_out <= char_in;
                --char_out(3 downto 0)    <= btn;
                --char_out(7 downto 4)    <= sw;                       
             --end if;
             display <= ExPkgA.din;  
        end if;           
    end process;              
end behavioral;