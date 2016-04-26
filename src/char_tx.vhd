
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
use work.bus_pkg.all;

entity char_tx is
    generic (
        char_width  : in integer
        );
    Port ( 
        clk         : in std_logic;        
        rst_n       : in std_logic;        
        char_in     : in std_logic_vector(7 downto 0);
        ExTx        : in ExTx_reg;
        CharTxEx    : out CharTxEx_reg;
        cnt_max     : out std_logic;
        char_out    : inout std_logic_vector(9 downto 0)
        );
        
end char_tx;

architecture Behavioral of char_tx is
       
    -- Char to Exchange register reset
constant CharTxEx_rst: CharTxEx_reg := (
    fcc_sent    => '0',             -- don't request char from packet layer
    eop1_sent   => '0',             -- don't send fcc from char Tx layer
    eop2_sent   => '0',             -- don't send eop1 from char Tx layer
    esc_sent    => '0',             -- don't send eop2 from char Tx layer
    data_sent   => '0',             -- don't send escape from char Tx layer
    cnt_max     => "0000"          -- max countdown value of null_char
    );
    
    signal prev_data_parity     : std_logic;
    signal cnt_max_delay        : std_logic_vector(3 downto 0); 
           
begin
    process(clk, rst_n)
        begin 
            if (rst_n = '0') then                  -- set char out to 0 if reset
                char_out    <= (others => '0');
                CharTxEx    <= CharTxEx_rst; 
                cnt_max_delay <= "0111";
                   
            else 
                if rising_edge(clk) then
                
                    if ( (prev_data_parity xor char_out(8))= '0') then
                        char_out(9) <= '1';
                    else
                        char_out(9) <= '0';   
                    end if;
                    
                    if (ExTx.ld_txreg = '1') then 
                        prev_data_parity <= ((char_out(7) xor char_out(6)) xor (char_out(5) xor char_out(4))) xor ((char_out(3) xor char_out(2)) xor (char_out(1) xor char_out(0)));
                    end if;
                    
                    if (ExTx.fcc_flag = '1') then
                        char_out(8 downto 6)  <= C_CHAR_FCC;
                        CharTxEx.fcc_sent <= '1'; 
                        cnt_max_delay   <= "0011";                       
                    else 
                        if (ExTx.eop1_flag = '1') then
                            char_out(8 downto 6)  <= C_CHAR_EOP1;
                            CharTxEx.eop1_sent <= '1'; 
                            cnt_max_delay   <= "0011";                                              
                        else 
                            if (ExTx.eop2_flag = '1') then
                                char_out(8 downto 6)  <= C_CHAR_EOP2;
                                CharTxEx.eop2_sent <= '1';
                                cnt_max_delay   <= "0011";                        
                            else 
                                if (ExTx.esc_flag = '1') then
                                    char_out(8 downto 6)  <= C_CHAR_ESC;
                                    CharTxEx.esc_sent <= '1';  
                                    cnt_max_delay   <= "0011";                                                     
                                else 
                                    if (ExTx.data_flag = '1') then           -- send data
                                        char_out(7 downto 0) <= char_in;
                                        char_out(8) <= '0'; 
                                        CharTxEx.data_sent <= '1'; 
                                        cnt_max_delay   <= "1001";                    
                                    else   
                                        char_out(8 downto 2)  <=  C_CHAR_NULL;
                                       cnt_max_delay   <= "0111";
                                    end if;          
                                end if;
                            end if;
                            CharTxEx.cnt_max    <=  cnt_max_delay;
                        end if;                        
                    end if; 
                end if;  
            end if;                                
        end process; 
end Behavioral;