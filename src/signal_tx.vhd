
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

    Port ( 
        clk         : in STD_LOGIC;
        rst_n 	    : in  STD_LOGIC;
        char_in     : in STD_LOGIC_VECTOR(9 downto 0);
        parity      : inout STD_LOGIC ;
        data        : out STD_LOGIC;
        strobe      : out STD_LOGIC;        
        req_pkt     : inout STD_LOGIC
        );
    
end signal_tx;

architecture Behavioral of signal_tx is
       
   signal cnt       : std_logic_vector(3 downto 0);
   signal st_temp   : std_logic;
   signal data_temp : std_logic;
   signal par_temp  : std_logic;
   signal char      : std_logic_vector(9 downto 0);
   
begin    
    
    process(clk,rst_n)
                        
        begin                   
           if rising_edge(clk)then
                if (rst_n = '0') then
                          data        <= '0';
                          parity      <= '0';
                          req_pkt     <= '0';
                          strobe      <= '0';
                          cnt         <= "0000";
                          st_temp     <= '0';
                          data_temp   <= '0';
                          par_temp    <= '0';
                          char        <= "0000000000";
                else          
                    cnt <= cnt + 1;
                
                    if (cnt >= "1001") then
                        cnt <= (others=>'0');
                    end if;                  
                
                    data_temp   <=  char(9);
                    data        <= data_temp;
                 
                    if (cnt = "1000") then
                        char <= char_in;
                    else
                        char(9 downto 1)  <=  char(8 downto 0);                                    
                    end if;
                
                    st_temp   <=  st_temp xor (data_temp xnor char(9));
                    strobe    <=  st_temp;  
                    parity  <=  '0';  -- parity xor bit_out;
                                
                    if (cnt = "0111") then
                        req_pkt <= '1';
                    else
                        req_pkt <= '0';
                    end if;                          
                end if;
            end if;          
    end process;       
end Behavioral;