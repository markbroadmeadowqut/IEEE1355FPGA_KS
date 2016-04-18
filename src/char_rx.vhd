
----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         10.04.2016 09:37:06
-- Design Name: 
-- Module Name:         char_rx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         Receive character layer of DS bus.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity char_rx is
    Port ( 
        clk             : in STD_LOGIC;  
        rst_n 	        : in  std_logic;
        pc_char         : in STD_LOGIC_VECTOR(9 downto 0);
        char_rec        : in STD_LOGIC;
        char_rx         : out STD_LOGIC_VECTOR(7 downto 0);
        char_save       : out STD_LOGIC
              
    );
    
end char_rx;

architecture Behavioral of char_rx is

begin
    process(clk)
        begin
            if (rst_n = '0') then
                char_rx <= "00000000";
                char_save  <= '0';
            else
                if (char_rec = '1') then
                    char_rx  <=  pc_char(7 downto 0);
                    char_save <= '1';
                end if;
            end if;      
        end process;
end Behavioral;                  


