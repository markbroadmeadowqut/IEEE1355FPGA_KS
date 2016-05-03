----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         04.04.2016 19:20:33
-- Design Name: 
-- Module Name:         packet - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Packet layer for transmitter 
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
    

entity packet_tx is
    generic (
        char_width  : in integer
        );
    Port ( 
        clk         : in std_logic;                       -- transmission clock        
        rst_n  	    : in std_logic;
        sw          : in std_logic_vector(3 downto 0);
        btn         : in std_logic_vector(3 downto 0);                          
        req_pkt     : in std_logic;
        data_fwd    : in std_logic_vector(7 downto 0);                        
        char_pkt    : out std_logic_vector(7 downto 0)    -- out register    
    );
end packet_tx;

architecture Behavioral of packet_tx is
                                                            -- dummy packet for test
   
begin

    process (clk,rst_n,req_pkt)
       
        begin
             if (rst_n = '0') then                          -- reset all 
                char_pkt    <= (others => '0');                  
             else
                if rising_edge(clk) then
                    char_pkt   <= data_fwd; 
                    --char_pkt(3 downto 0)    <= btn;
                    --char_pkt(7 downto 4)    <= sw;                 
                end if;
            end if;       
        end process;

end Behavioral;

