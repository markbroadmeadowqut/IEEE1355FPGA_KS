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

entity packet is
    generic(
        char_width  : integer
        );
    Port ( 
    clk            : in  std_logic;                         -- TX clock    
    reset_n  	   : in  std_logic;
    sw             : in  std_logic_vector(3 downto 0);
    btn            : in  std_logic_vector(3 downto 0);        
    char_in        : in  std_logic_vector(7 downto 0);      -- character received
    char_out       : out std_logic_vector(7 downto 0);      -- character out register
    display        : out std_logic_vector(7 downto 0) 
    );

end packet;

architecture behavioral of packet is
       
begin

process(clk,reset_n )  
    begin
        if (reset_n  = '0') then
            display     <= (others => '0');
            char_out    <= (others => '0');
        else
             if rising_edge(clk) then
                --char_out <= char_in;
                char_out(3 downto 0)    <= btn;
                char_out(7 downto 4)    <= sw;                       
             end if;
             display <= char_in;  
        end if;           
    end process;              
end behavioral;