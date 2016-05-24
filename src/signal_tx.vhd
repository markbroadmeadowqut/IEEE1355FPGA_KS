
----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date: 06.04.2016 09:45:00
-- Design Name: 
-- Module Name: signal_tx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         Signal transmit layer of DS bus.
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
use IEEE.std_logic_unsigned.all;


entity signal_tx is
    generic (
        char_width  : in integer
        );
    Port ( 
        clk         : in std_logic;
        reset_n   	: in std_logic;
        d_in        : in std_logic;
        d_out       : out std_logic;
        s_out       : out std_logic       
        );
    
end signal_tx;

architecture Behavioral of signal_tx is

   signal d_hold   : std_logic;
   signal s_hold   : std_logic;
   
begin    
    
    process(clk,reset_n )
                        
        begin                   
            if (reset_n  = '0') then
                d_out       <= '0';
                s_out       <= '0';
                d_hold      <= '0';
                s_hold      <= '0';
            else  
                if rising_edge(clk)then
                    d_hold      <= d_in;
                    s_hold      <= s_hold  xor (d_in xnor d_hold );
                    d_out       <= d_hold; 
                    s_out       <= s_hold;                               
                end if;
            end if;          
    end process;       
end Behavioral;