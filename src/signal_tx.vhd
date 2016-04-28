
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
        rst_n 	    : in std_logic;
        char_in     : in std_logic_vector(9 downto 0);
        ld_txreg    : in std_logic;
        data        : out std_logic;
        strobe      : out std_logic        
        );
    
end signal_tx;

architecture Behavioral of signal_tx is

   signal st_temp   : std_logic;
   signal data_temp : std_logic;
   signal char      : std_logic_vector(9 downto 0);
   
begin    
    
    process(clk,rst_n)
                        
        begin                   
            if (rst_n = '0') then
                data        <= '0';
                strobe      <= '0';
                st_temp     <= '0';
                data_temp   <= '0';
                char        <= (others => '0');
            else  
                if rising_edge(clk)then
                    data_temp   <=  char(9);
                    data        <= data_temp;
                    st_temp     <=  st_temp xor (data_temp xnor char(9));
                    strobe      <=  st_temp;                     
                 
                    if (ld_txreg = '1') then            
                        char <= char_in;                -- load new char
                    else
                        char(9 downto 1)  <=  char(8 downto 0); 
                        char(0) <= '0';                                   
                    end if;                             -- shift char in                    
                end if;
            end if;          
    end process;       
end Behavioral;