----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands: 
-- 
-- Create Date:         11.04.2016 18:16:56
-- Design Name: 
-- Module Name:         exchange_layer - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Exchange layer for transmitter 
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
use work.bus_pkg.all;

entity exchange_tx is

    generic(
        char_width  : integer
        );
    Port ( 
        clk         : in std_logic;             -- receiver clock
        reset_n     : in std_logic;             -- reset
        empty       : in std_logic;
        char        : in std_logic_vector(7 downto 0);             -- raw data char
        ExRxTx      : in ExRxExTx_rec;
        char_valid  : out std_logic;
        rd_en       : out std_logic;
        pc_char     : out std_logic_vector( 9 downto 0)             -- char with parity and control bit
        );
end exchange_tx;

architecture Behavioral of exchange_tx is

    type state_type is (s0, s1, s2, s3);
    signal state : state_type;

    signal data_parity      : std_logic;                        -- parity of data only
    signal char_reg         : std_logic_vector(9 downto 0);
    signal send_end_null    : std_logic; 

        signal char_cnt       : std_logic_vector (3 downto 0);              -- for counting out fcc call for characters
        signal cnt            : std_logic_vector (3 downto 0);         -- counter for counting 10 bit character out 
        signal cnt_max        : std_logic_vector (3 downto 0);
    
    
begin       
    process (clk,reset_n)
       -- variable char_cnt       : integer range 0 to 10;             -- for counting out fcc call for characters
       -- variable cnt            : integer range 0 to 3;              -- counter for counting 10 bit character out 
       -- variable cnt_max        : integer range 0 to 3; --signal char_cnt       : integer range 0 to 3;             -- for counting out fcc call for  
       
        
        begin
            if (reset_n = '0') then                          -- reset all 
                    cnt             <= "0100"; 
                    state           <= s0;                                  
                    cnt_max         <= "0011";
                    pc_char         <= (others => '0');
                    char_reg        <= (others => '0');
                    data_parity     <= '0';
                    send_end_null   <= '0';
                    char_cnt        <= "0000";
                    char_valid      <= '0';
                    rd_en           <= '0'; 
            elsif rising_edge(clk) then  
            
                if (cnt > 0) then
                    cnt <= cnt - 1;
                else
                    cnt <= cnt_max ;   
                end if;     
                             
                case state is
                     when s0 =>
                            state <= s3;
                            char_valid <= '1';
                            
                        if (send_end_null = '1') then
                            char_reg(3 downto 1)  <=  C_CHAR_FCC;            -- send second half of Null Char
                            char_reg(9 downto 4)  <= "000000"; 
                            cnt_max <= "0011";         
                            send_end_null <= '0';                            
                            
                        elsif (char_cnt = "0010") then                 -- send FCC
                            char_reg(3 downto 1)  <= C_CHAR_FCC;
                            char_reg(9 downto 4)  <= "000000";
                            cnt_max <= "0011";
                            char_cnt <=  "0001";
                        elsif ( char_cnt = "0001") then
                            char_reg(3 downto 1)  <= C_CHAR_EOP1;
                            char_reg(9 downto 4)  <= "000000";                               -- send EOP 1 
                            cnt_max <= "0011";
                            char_cnt <= "1010";                                                                                              
                        
                        elsif ( char_cnt >= "0011") then                                         -- send data
                             if (empty = '1') then
                                char_reg(3 downto 1)  <=  C_CHAR_ESC;            -- send first half of Null Char
                                char_reg(9 downto 4)  <= "000000";
                                cnt_max <= "0011";
                                send_end_null <= '1';
                             else
                                char_reg(9 downto 2) <= char;
                                rd_en <= '1';
                                char_reg(1) <= '0';  
                                cnt_max <= "1001";                          
                                char_cnt <= char_cnt - 1;
                             end if;             
                        else
                            if (ExRxTx.null_rcvd = '1') then
                                char_reg(3 downto 1)  <=  C_CHAR_FCC;
                                cnt_max <= "0011";
                                char_cnt <= "1010";
                            else
                                char_reg(3 downto 1)  <=  C_CHAR_ESC;            -- send first half of Null Char
                                send_end_null <= '1';
                            end if;
                            char_reg(9 downto 4)  <= "000000";
                            cnt_max <= "0011";   
                        end if;                            
                               
                     when s1 =>                                              -- calcuate the parity of data in previous character
                            data_parity <= ((char_reg(9) xor char_reg(8)) xor (char_reg(7) xor char_reg(6))) xor ((char_reg(5) xor char_reg(4)) xor (char_reg(3) xor char_reg(2)));       
                            state <= s0;
                            pc_char <= char_reg;
                            char_valid <= '0';     
                            
                     when s2 => 
                        if ( (data_parity xor char_reg(1))= '0') then      -- parity calculation of previous data and current control bit
                            char_reg(0) <= '1';
                        else
                            char_reg(0) <= '0';   
                        end if;                              
                        state <= s1;
                        char_valid <= '0';
                            
                     when s3 =>  
                        char_valid <= '0';
                          
                        if (cnt > 3) then
                            rd_en <= '0';
                            state <= s3;                                        
                        else
                            rd_en <= '0';
                            state <= s2;
                        end if; 
                end case;
            end if;                      
        end process;
end Behavioral;
