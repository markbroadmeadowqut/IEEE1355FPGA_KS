----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands: 
-- 
-- Create Date:         11.04.2016 18:16:56
-- Design Name: 
-- Module Name:         exchange_layer - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Exchange layer for bus  
-- Dependencies:
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

entity exchange is

    generic(
        char_width  : integer
        );
    Port ( 
        clk         : in std_logic;             -- receiver clock
        rst_n       : in std_logic;             -- reset
        locked      : in std_logic;             -- indicates when clocks are stable
        CharTxExA   : in CharTxEx_rec;          -- flags from Character TX pipeline A
        SigRxExA    : in SigRxEx_rec;           -- flags from Signal RX pipeline A
        CharRxExA   : in CharRxEx_rec;          -- flags from Char RX pipeline A
        dtct_nullA  : out std_logic;            -- flag to detect null on link establish         -- flag to indicate char received by sig layaer
        char_saveA  : out std_logic;            -- flag to save data to rx register in pkt layer
        rstn_sw      : out std_logic;            -- flag for node reset by software
        ExTxA       : inout ExTx_rec              -- flags sent to TX pipeline
        
        );
end exchange;

architecture Behavioral of exchange is

    -- TX pipeline register reset
    constant ExTx_rst: ExTx_rec := (
        req_pkt     => '0',             -- don't request char from packet layer
        fcc_flag    => '0',             -- don't send fcc from char Tx layer
        eop1_flag   => '0',             -- don't send eop1 from char Tx layer
        eop2_flag   => '0',             -- don't send eop2 from char Tx layer
        esc_flag    => '0',             -- don't send escape from char Tx layer
        data_flag   => '0',             -- don't send data from char_tx from char Tx layer
        ld_txreg    => '0'              -- don't load character into signal_tx out reg
                     
        );
   
--    type state_type is (s0_ready, s1_null_sent, s2_null_rcvd, s3_rcvg_data, s4_error);
--    signal state : state_type;

    signal cnt1         : std_logic_vector(3 downto 0);
    signal df_latch    : std_logic;
    
begin

    process (clk,rst_n,SigRxExA)
        begin
            if (rst_n = '0') then                          -- reset all 
                ExTxA       <= ExTx_rst;
                cnt1        <= "0100"; 
                dtct_nullA  <= '1';
                char_saveA  <= '0';
                rstn_sw     <= '1';
                df_latch    <= '0';
                
            else
                --if ( locked = '1') then 
                    if rising_edge(clk) then
                        cnt1 <= cnt1 - '1';
                        
                        --  If data being rcvd set data flag
                        if (SigRxExA.d_char_rcvd = '1')  then
                            ExTxA.data_flag <= '1';
                        else
                            ExTxA.data_flag <= '0';
                        end if;
                        
                        df_latch <= ExTxA.data_flag;
                        
                        if (df_latch = '1') and (SigRxExA.d_char_rcvd = '0') then
                            ExTxA.eop1_flag <= '1';
                        else
                           if ( cnt1 = 0 ) then
                                ExTxA.eop1_flag <= '0'; 
                           end if;      
                        end if; 
                        
                        --  If data being rcvd set data flag
--                        if (CharTxExA.cnt_max = 9)  then
--                            ExTxA.data_flag <= '1';
--                            data_temp <= '1';
--                       else
--                            data_temp <= '0';
--                        end if;
                        
                        
                        
---                        if (data_temp = '1') and (ExTxA.data_flag = '0') then
--                            ExTxA.eop1_flag <= '1';
--                        else
--                           if ( cnt1 = 0 ) then
--                                ExTxA.eop1_flag <= '0'; 
--                           end if;      
--                        end if;                         
                        
                        if  (CharRxExA.parity_error = '1') or (SigRxExA.time_out = '1') then
                            rstn_sw <= '0';                    
                        else
                            rstn_sw <= '1'; 
                        end if;
                        
                        
                                           
                        if  (SigRxExA.null_dtcd = '1') then
                            dtct_nullA <= '0';
                        end if;
                        
                        
                        
                        if (cnt1 = 0) then
                            cnt1 <= CharTxExA.cnt_max ;
                            --ExTxA <= ExTx_rst;   
                        end if;  
                        
                        
                        
                        if (cnt1 = 3) then      -- request a char from pkt
                            ExTxA.req_pkt <= '1';
                        else
                            ExTxA.req_pkt <= '0';
                        end if; 
                        
                        
                        
                        if (cnt1 = 1) then      -- request a char from pkt
                            ExTxA.ld_txreg <= '1';
                        else
                            ExTxA.ld_txreg <= '0';
                        end if;
                        
                                                    
                    end if;
                --end if;     
            end if;           
        end process;
 
--    process (clk_tx, rst)
--        begin
                        
--            if (rst = '0') or (time_out = '1') then
--               state <= s4_error;
--            else if rising_edge(clk_tx) then
--                case state is
--                    when s0_ready =>
--                        state <= s1_null_sent;    
--                    when s1_null_sent=>
--                        if (null_dtcd = '1') then
--                            --dtct_null  <= '0';
--                            state <= s2_null_rcvd;
--                        end if;    
--                    when s2_null_rcvd =>
--                        if (rcvg_data = '1') then
--                            state <= s3_rcvg_data;                            
--                        end if;                                                                
--                    when s3_rcvg_data =>
--                        if (eop_rcvd = '1') then
--                            state <= s2_null_rcvd;
--                       end if;
--                    when s4_error =>
--                        state <= s0_ready;    
--                end case;
--                end if;                         
 --           end if;
--        end process;
        
--    process(state)
--        begin
--            case state is
--                when s0_ready =>
--                    dtct_null  <= '1';
--                when s1_null_sent =>
--                    dtct_null <= '1'; 
--                when s2_null_rcvd =>
--                    dtct_null <= '0';
--                    if (fcc_sent = '1')then
--                        fcc_flag  <= '0';
--                    else
--                        fcc_flag  <= '1';
--                    end if;        
--                when s3_rcvg_data =>
--                            
--                when s4_error =>
--                    dtct_null  <= '0';  
--                    data_flag  <= '0'; 
--                    fcc_flag   <= '0';
--                end case;                     
--        end process;
        
 
end Behavioral;
