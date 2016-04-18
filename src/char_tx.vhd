
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
        parity      : in std_logic;
        char_out    : out std_logic_vector(9 downto 0);
        fcc_sent    : out std_logic          -- used to toggle fcc_flag to 0   
              
    );
end char_tx;

architecture Behavioral of char_tx is
        signal ctrl_char: std_logic;
        signal fcc      : std_logic_vector(3 downto 0):=  "0100";
        signal eop_1    : std_logic_vector(3 downto 0):=  "0101";
        signal eop_2    : std_logic_vector(3 downto 0):=  "0110";
        signal esc      : std_logic_vector(3 downto 0):=  "0111";
        signal null_char: std_logic_vector(7 downto 0):=  "01110100";        
begin
     process(clk, rst_n)
        begin 
            if rising_edge(clk) then
                if (rst_n = '0') then                  -- set char out to 0 if reset
                    char_out <= "0000000000";
                    ctrl_char <= '0';
                    fcc_sent <= '0';
                else 
                    if (fcc_flag = '1') then
                        fcc(3) <= parity;
                        char_out(9 downto 6)  <= fcc;
                        fcc_sent <= '1';
                    else
                        if (data_flag = '1') then           -- send data
                            char_out <=  parity & ctrl_char & char_in;
                            fcc_sent <= '0';                      
                        else   
                            null_char(7)    <=  parity;     -- send nulls    
                            char_out(9 downto 2)  <=  null_char;
                            fcc_sent <= '0'; 
                        end if;
                    end if;          
                end if;
            end if;     
        end process;        
       
end Behavioral;
