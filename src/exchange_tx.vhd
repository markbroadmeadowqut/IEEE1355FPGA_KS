----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands: 
-- Create Date:         11.04.2016 18:16:56
-- Design Name: 
-- Module Name:         exchange_layer - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Exchange layer for transmitter 
-- Dependencies: 
-- Revision:
-- Revision             1
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
library UNISIM;    
    use UNISIM.VComponents.all;
library WORK;
    use work.bus_pkg.all;
--use IEEE.std_logic_unsigned.all;

entity exchange_tx is

    Port ( 
        clk         : in std_logic;                     -- receiver clock
        reset_n     : in std_logic;                     -- side reset signal 
        PktEx       : in PktEx_rec;                     -- signals from packet layer
        ExRxTx      : in ExRxExTx_rec;                  -- flags from rx exchange
        char_valid  : out std_logic;                    -- valid char in register
        rd_en       : out std_logic;                    -- read from FIFO enable
        ExTxRx      : out ExTxExRx_rec;                 -- FCC sent from TX flag for RX exchange layer
        pc_char     : out std_logic_vector( 9 downto 0);-- char with parity and control bit
        debugr      : out std_logic_vector(35 downto 0) -- debug chanel
        );
end exchange_tx;

architecture Behavioral of exchange_tx is

    type state_type is (s0, s1, s2, s3);    -- states of finite state machine
    signal state : state_type;
    
    constant ExTxRx_rst : ExTxExRx_rec := (
        fcc_sent        => '0',
        fcc_rcvd_ack    => '0'             -- Clear all flags in register 
        );     

    signal data_parity      : std_logic;                -- parity of data only
    signal send_end_null    : std_logic;                -- sends end of null char flag       
    signal char_reg         : std_logic_vector(9 downto 0);     -- holding register for character
    signal send_eop1        : std_logic;                -- flag to send EOP1
    signal temp_char_cnt_out: std_logic_vector(3 downto 0);
    signal temp_cnt         : std_logic_vector(3 downto 0);
    signal temp_cnt_max     : std_logic_vector(3 downto 0); 
           
begin   
        
    process (clk,reset_n)
 
        variable char_cnt_out   : integer range 0 to 15;
        variable cnt            : integer range 0 to 9;
        variable cnt_max        : integer range 0 to 9;   
          
        begin
            if (reset_n = '0') then               -- reset all out and internal signals 
                    cnt             := 4; 
                    state           <= s0;                                  
                    cnt_max         := 3;
                    pc_char         <= (others => '0');
                    char_reg        <= (others => '0');
                    data_parity     <= '0';
                    send_end_null   <= '0';
                    char_cnt_out    := 0;
                    char_valid      <= '0';
                    rd_en           <= '0'; 
                    send_eop1       <= '0';
                    ExTxRx          <= ExTxRx_rst;
                    
            elsif rising_edge(clk) then 
                                
                if (ExRxTx.fcc_rcvd = '1') then
                    char_cnt_out := char_cnt_out + 8;
                    ExTxRx.fcc_rcvd_ack <= '1';
                else 
                    ExTxRx.fcc_rcvd_ack <= '0';   
                end if; 
            
                if (cnt > 0) then           -- decrement stat counter
                    cnt := cnt - 1;
                else                        -- reset counter to length of 
                    cnt := cnt_max ;        -- current character
                end if; 
                
                if (PktEx.eop1_rcvd = '1') then
                    send_eop1 <= '1';       -- send EOP
                end if;
                
               case state is
                    -- This state decides which character the transmitter is
                    -- to send
                     when s0 =>
                        state <= s3;
                        char_valid <= '1';
                                    
                        if (send_end_null = '1') then    -- send second half of Null Char
                            char_reg(3 downto 1)  <=  C_CHAR_FCC;   -- this is priority to all           
                            char_reg(9 downto 4)  <= "000000";      -- zero pad
                            cnt_max := 3;                      -- length of current char
                            send_end_null <= '0';
                        
                        elsif  (ExRxTx.link_est = '1') then     -- when the link is established
                                                       
                            if (ExRxTx.send_fcc = '1') then     -- if rx exchange flags to send an fcc
                                char_reg(3 downto 1)  <=  C_CHAR_FCC;   -- send FCC 
                                char_reg(9 downto 4)  <= "000000"; 
                                cnt_max := 3;
                                ExTxRx.fcc_sent <= '1';                -- flag to say fcc sent for rx exchange
                                                                                            
                            elsif (PktEx.empty = '0') and (char_cnt_out > 0) then 
                                char_reg(9 downto 2) <= PktEx.dout;     -- send data from packet layer
                                rd_en <= '1';                           -- read enable the FIFO
                                char_reg(1) <= '0';  
                                cnt_max := 9; --"1001";                          
                                char_cnt_out := char_cnt_out - 1;       -- decrement N_chars to send                       
                            else
                                if (send_eop1 = '1') then                   -- end of packet detected
                                    char_reg(3 downto 1)  <=  C_CHAR_EOP1;  -- Send EOP1
                                    char_reg(9 downto 4)  <= "000000";
                                    cnt_max := 3;
                                    send_eop1 <= '0';
                                else
                                    char_reg(3 downto 1)  <=  C_CHAR_ESC;   -- send first half of Null Char
                                    char_reg(9 downto 4)  <= "000000";      
                                    cnt_max := 3;
                                    send_end_null <= '1';
                                end if;               
                            end if;
                            
                        else
                            char_reg(3 downto 1)  <=  C_CHAR_ESC;       -- send first half of Null Char
                            send_end_null <= '1';                       -- before link established
                            char_reg(9 downto 4)  <= "000000";
                             ExTxRx.fcc_sent <= '0';
                        end if;   
                        
                     --This state calculates the data parity for next character and stores it   
                     when s1 =>                                             
                            data_parity <= ((char_reg(9) xor char_reg(8)) xor (char_reg(7) xor char_reg(6))) 
                                            xor ((char_reg(5) xor char_reg(4)) xor (char_reg(3) xor char_reg(2)));       
                            state <= s0;
                            pc_char(9 downto 0) <= char_reg(9 downto 0);
                            char_valid <= '0';
                             
                        
                     -- This state calculates the parity bit of the current character       
                     when s2 => 
                        if ( (data_parity xor char_reg(1))= '0') then         
                            char_reg(0) <= '1';
                        else
                            char_reg(0) <= '0';   
                        end if;                              
                        state <= s1;
                        char_valid <= '0';
                        
                     -- Blank state to reset signals  and to prepare for L or N_char.       
                     when s3 =>  
                        char_valid <= '0';
                        rd_en <= '0';
                        ExTxRx.fcc_sent <= '0';
                          
                        if (cnt > 2) then                            
                            state <= s3;                                        
                        else
                            state <= s2;
                        end if; 
                end case;  
            end if; 
           
           temp_char_cnt_out    <= std_logic_vector(to_unsigned(char_cnt_out,4));
           temp_cnt             <= std_logic_vector(to_unsigned(cnt,4));
           temp_cnt_max         <= std_logic_vector(to_unsigned(cnt_max,4));
                                 
        end process;  
        debugr(0)           <= clk;
        debugr(1)           <= reset_n;
        debugr(9 downto 2)  <= PktEx.dout (7 downto 0);
        debugr(10)          <= PktEx.empty;
        debugr(11)          <= ExRxTx. link_est;
        debugr(12)          <= ExRxTx.fcc_rcvd;
        debugr(13)          <= ExRxTx.send_fcc;
        debugr(14)          <= ExRxTx.data_rcvd;
        debugr(15)          <= data_parity;
        debugr(16)          <= send_end_null;
        debugr(26 downto 17)    <= char_reg(9 downto 0);
        debugr(35 downto 31)    <= (others => '0');
        debugr(30 downto 27)    <= temp_char_cnt_out;
        --debugr(34 downto 31)    <= std_logic_vector(cnt(3 downto 0));
        --debugr(35)          <= (std_logic_vector(cnt_max))(1);      
end Behavioral;
