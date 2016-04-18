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
    Port ( 
        clk         : in std_logic;                       -- transmission clock        
        rst_n 	    : in std_logic;
        sw          : in std_logic_vector(3 downto 0);
        btn         : in std_logic_vector(3 downto 0);                          
        req_pkt     : in std_logic;                         -- packet request flag 

        char_pkt    : out std_logic_vector(7 downto 0)    -- out register    
    );
end packet_tx;

architecture Behavioral of packet_tx is
                                                            -- dummy packet for test
    signal data     : std_logic_vector(7 downto 0);
   
    
begin

    process (clk,rst_n,req_pkt)
       
        begin
             if (rst_n = '0') then                          -- reset all 
                char_pkt    <= "00000000";                  
             else
                if rising_edge(clk) and (req_pkt = '1') then
                    data(0)     <= btn(0);
                    data(1)     <= btn(1);
                    data(2)     <= btn(2);
                    data(3)     <= btn(3);
                    data(4)     <= sw(0);
                    data(5)     <= sw(1);
                    data(6)     <= sw(2);
                    data(7)     <= sw(3);
                    char_pkt    <= data;                   
                end if;
            end if;       
        end process;

end Behavioral;

