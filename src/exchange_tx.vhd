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
        char        : in std_logic_vector(7 downto 0);             -- raw data char
        ExRxTx      : in ExRxExTx_rec;
        char_clk    : out std_logic;
        pc_char     : out std_logic_vector( 9 downto 0)             -- char with parity and control bit
        
--        locked      : in std_logic;             -- indicates when clocks are stable
--        CharTxExA   : in CharTxEx_rec;          -- flags from Character TX pipeline A
--        SigRxExA    : in SigRxEx_rec;           -- flags from Signal RX pipeline A
--        CharRxExA   : in CharRxEx_rec;          -- flags from Char RX pipeline A
--        dtct_nullA  : out std_logic;            -- flag to detect null on link establish         -- flag to indicate char received by sig layaer
--        char_saveA  : out std_logic;            -- flag to save data to rx register in pkt layer
--        rstn_sw      : out std_logic;            -- flag for node reset by software
--        ExTxA       : inout ExTx_rec              -- flags sent to TX pipeline
        
        );
end exchange_tx;

architecture Behavioral of exchange_tx is

    type state_type is (s0_wait, s1_req_data, s2_send_data, s3_send_eop);
    signal current_s, next_s : state_type;

    signal char_clk_latch   : std_logic;

    signal data_parity      : std_logic;                        -- parity of data only
    signal char_reg         : std_logic_vector(9 downto 0);
    --signal cnt_max          : std_logic_vector (3 downto 0);             -- length of current character to count out of shift register
    --signal char_clk_latch   : std_logic;
  --  
    signal send_end_null    : std_logic;
   -- signal buff_empty       : std_logic; 
   signal cnt            : std_logic_vector (3 downto 0);              -- counter for counting 10 bit character out 
   signal cnt_max        : std_logic_vector (3 downto 0);
   signal char_cnt       : std_logic_vector (3 downto 0);             -- for counting out fcc call for  
    
    
begin
    
    process (clk,reset_n)
     
     
        begin
        
            if (reset_n = '0') then                          -- reset all 
                char_clk        <= '0';
                pc_char         <= (others => '0');
                cnt             <= "0001";
                cnt_max         <= "0011";
                char_clk        <= '0';
                char_clk_latch  <= '0';
                char_reg(5 downto 0)        <= "000000";
                current_s       <= s0_wait; 
                                
            else
                if rising_edge(clk) then
                    current_s    <= next_s;
                    cnt <= cnt-1;
                    char_clk <= char_clk_latch;
                    
                    if (cnt = "0011") then
                        char_clk_latch <= '1'; 
                    else
                        char_clk_latch <= '0'; 
                    end if;
                    
                    if (cnt = "0010") then
                        pc_char <= char_reg;      
                    end if;
                    
                    if (cnt = "0000") then
                        cnt <= cnt_max;
                    end if;
                end if;      
            end if;           
        end process;
        
-- State machine for tx exchange layer sending data
    process (reset_n, char_clk_latch,cnt, current_s)
        begin
            if (reset_n = '0') then                          -- reset all 
                data_parity     <= '0';
                            
            else        
                if rising_edge (char_clk_latch) then
                    if (cnt = "0011") then
                        data_parity <= ((char_reg(7) xor char_reg(6)) xor (char_reg(5) xor char_reg(4))) xor ((char_reg(3) xor char_reg(2)) xor (char_reg(1) xor char_reg(0)));
                    else     
                        if ( (data_parity xor char_reg(8))= '0') then      -- parity calculation of previous data and current control bit
                            char_reg(9) <= '1';
                        else
                            char_reg(9) <= '0';   
                        end if; 
                    end if;   
                    case current_s is
                        when s0_wait        =>
                            if (send_end_null = '1') then
                                char_reg(8 downto 6)  <=  C_CHAR_FCC ;
                                char_reg              <= (others=>'0');         -- send second half of Null Char
                                send_end_null <= '0';
                            else    
                                char_reg(8 downto 6)  <=  C_CHAR_ESC;
                                char_reg(5 downto 0)  <= (others=>'0');         -- send first half of Null Char
                                send_end_null <= '1';
                            end if;
                            cnt_max <= "0011";
                         when s1_req_data   =>
                         
                         when s2_send_data  =>
                         
                         when s3_send_eop   =>  
                         
                       
                    end case;  
                end if; 
            end if;           
        end process;
        
        
        
end Behavioral;
