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
library UNISIM;    
    use UNISIM.VComponents.all;
library WORK;
    use work.bus_pkg.all;
    
    
entity pkt_master is

    Port ( 
    wr_clk          : in  std_logic;                         -- RX clock 
    rd_clk          : in  std_logic;        
    rst_n     	    : in  std_logic;
    sw              : in  std_logic_vector(3 downto 0);
    btn             : in  std_logic_vector(3 downto 0);
    ExPktA          : in  ExPkt_rec;        
    ExPktB          : in  ExPkt_rec;         
    display         : out std_logic_vector(7 downto 0);
    PktExA          : out PktEx_rec; 
    PktExB          : out PktEx_rec 
    );

end pkt_master;

architecture behavioral of pkt_master is  

    signal rst : std_logic;

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
    
    
fifo_BtoA : fifo_generator_0
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

process(rd_clk,rst_n)  
    begin
    
        rst <= not rst_n;
    
        if (rst_n  = '0') then
            PktExA.full     <= '0';
            PktExB.empty    <= '0';
            PktExB.dout     <= (others => '0');
            display         <= (others => '0');
            
            
        else
             if rising_edge(rd_clk) then 
                PktExB.dout(3 downto 0)    <= btn;
                PktExB.dout(7 downto 4)    <= sw;  
                display <= ExPktA.din;                   
             end if;              
        end if;           
    end process;              
end behavioral;