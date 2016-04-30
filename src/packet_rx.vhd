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

entity packet_rx is
    generic(
        char_width  : integer
        );
    Port ( 
    clk            : in  std_logic;         -- recovered clock    
    rst  	       : in  std_logic;    
    char_in        : in  std_logic_vector(7 downto 0);    -- character received
    char_save      : in  std_logic;
    display        : out std_logic_vector(7 downto 0)             
);

end packet_rx;

architecture behavioral of packet_rx is
    
    signal data_sv      : std_logic_vector(7 downto 0);    
    
begin

process(clk,rst )  
    begin
        if (rst  = '0') then
            display <= (others => '0');
            data_sv <= (others => '0');
        else
             if rising_edge(clk) then
                if (char_save = '1') then                 
                    data_sv <= char_in;
                else
                    data_sv <= (others => '0');
                end if;     
             end if;
             display <= char_in;  
        end if;           
    end process;              
end behavioral;