
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
        ExTx        : in ExTx_rec;
        CharTxEx    : out CharTxEx_rec;
        char_out    : inout std_logic_vector(9 downto 0)
        );
        
end char_tx;

architecture Behavioral of char_tx is
       
    -- Char to Exchange register reset
constant CharTxEx_rst: CharTxEx_rec := (
    --fcc_sent    => '0',             -- don't request char from packet layer
    --eop1_sent   => '0',             -- don't send fcc from char Tx layer
    --eop2_sent   => '0',             -- don't send eop1 from char Tx layer
   -- esc_sent    => '0',             -- don't send eop2 from char Tx layer
   -- data_sent   => '0',             -- don't send escape from char Tx layer
    cnt_max     => "0011"           -- max countdown value of ctrl_char
    );
    
    signal prev_data_parity     : std_logic;
    --signal cnt_max_delay        : std_logic_vector(3 downto 0); 
    signal send_end_null        : std_logic;
           
begin
    process(clk, rst_n )
        begin 
            if (rst_n  = '0') then                  -- set char out to 0 if reset
                char_out            <= (others => '0');
                CharTxEx            <= CharTxEx_rst; 
                send_end_null       <= '0';
                prev_data_parity    <= '0';
            else
                if rising_edge(clk) then
                    if ( (prev_data_parity xor char_out(8))= '0') then      -- parity calculation of previous data and current control bit
                        char_out(9) <= '1';
                    else
                        char_out(9) <= '0';   
                    end if;                                           -- calculation of previous data parity  
                    
                    if (EXTX.ld_txreg = '1') then
                        prev_data_parity <= ((char_out(7) xor char_out(6)) xor (char_out(5) xor char_out(4))) xor ((char_out(3) xor char_out(2)) xor (char_out(1) xor char_out(0)));
                                                                                 
                        if (ExTx.fcc_flag = '1') then                           -- send FCC 
                            char_out(8 downto 6)  <= C_CHAR_FCC;
                            char_out(5 downto 0)  <= "000000";
                            CharTxEx.cnt_max  <= "0011";                     
                        else 
                            if (ExTx.eop1_flag = '1') then                          -- send EOP 1
                                char_out(8 downto 6)  <= C_CHAR_EOP1;
                                char_out(5 downto 0)  <= "000000";
                                CharTxEx.cnt_max  <= "0011";                                           
                            else 
                                if (ExTx.eop2_flag = '1') then
                                    char_out(8 downto 6)  <= C_CHAR_EOP2;
                                    char_out(5 downto 0)  <= "000000";               -- send EOP 2    
                                    CharTxEx.cnt_max  <= "0011";                       
                                else 
                                    if (ExTx.esc_flag = '1') then                           -- send ESC
                                        char_out(8 downto 6)  <= C_CHAR_ESC;
                                        char_out(5 downto 0)  <= "000000";
                                        CharTxEx.cnt_max  <= "0011";                                                 
                                    else 
                                        if (ExTx.data_flag = '1') and (send_end_null = '0')then                          -- send data as little endian
                                            char_out(7 downto 0) <= char_in(0)&char_in(1)&char_in(2)&char_in(3)&char_in(4)&char_in(5)&char_in(6)&char_in(7);
                                            char_out(8) <= '0'; 
                                            CharTxEx.cnt_max  <= "1001";                   
                                        else  
                                            if (send_end_null = '1') then
                                                char_out(8 downto 6)  <=  C_CHAR_FCC;
                                                char_out(5 downto 0)  <= "000000";               -- send second half of Null Char
                                                send_end_null <= '0';
                                            else    
                                                char_out(8 downto 6)  <=  C_CHAR_ESC;
                                                char_out(5 downto 0)  <= "000000";               -- send first half of Null Char
                                                send_end_null <= '1';
                                            end if;
                                            CharTxEx.cnt_max  <= "0011";
                                        end if;          
                                    end if;
                                end if;
                            end if;                        
                        end if;
                    end if;
                end if;  
            end if;                                
        end process; 
end Behavioral;