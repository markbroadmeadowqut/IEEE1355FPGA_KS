
----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         05.04.2016 10:43:06
-- Design Name:         
-- Module Name:         char_tx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         transmission character layer of DS bus.
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

entity char_tx is
    Port ( 
        clk         : in std_logic;        
        rst_n       : in std_logic;        
        char_in     : in std_logic_vector(7 downto 0);                
        data_flag   : in std_logic; 
        fcc_flag    : in std_logic;
        char_out    : out std_logic_vector(9 downto 0);
        fcc_sent    : out std_logic          -- used to toggle fcc_flag to 0   
              
    );
end char_tx;

architecture Behavioral of char_tx is
       
        constant fcc            : std_logic_vector(8 downto 0):=  "100000000";
        constant eop_1          : std_logic_vector(8 downto 0):=  "101000000";
        constant eop_2          : std_logic_vector(8 downto 0):=  "110000000";
        constant esc            : std_logic_vector(8 downto 0):=  "111000000";
        constant null_char      : std_logic_vector(8 downto 0):=  "111010000"; 
        
begin
    process(clk, rst_n)
        begin 
            if (rst_n = '0') then                  -- set char out to 0 if reset
                char_out    <= "0000000000";
                fcc_sent    <= '0';
                   
            else 
                if rising_edge(clk) then
                
                    if ((char_in(7) xor char_in(6) xor char_in(5) xor char_in(4) xor char_in(3) xor char_in(2) xor char_in(1) xor char_in(0))= '0') then
                        char_out(9) <= '1';
                    else
                        char_out(9) <= '0';   
                    end if;
                    if (fcc_flag = '1') then
                        char_out(8 downto 0)  <= fcc;
                        fcc_sent <= '1';
                    else
                        if (data_flag = '1') then           -- send data
                            char_out(7 downto 0) <= char_in;
                            char_out(8) <= '0';
                            fcc_sent <= '0';                      
                        else   
                            char_out(8 downto 0)  <=  null_char;
                            fcc_sent <= '0'; 
                        end if;
                    end if;          
                end if;
            end if;     
        end process;        
       
end Behavioral;
