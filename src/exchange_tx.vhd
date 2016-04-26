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

entity exchange_tx is

    generic(
        char_width  : integer
        );
    Port ( 
        clk         : in std_logic;             -- receiver clock
        rst_n       : in std_logic;             -- reset
        CharTxExA   : in CharTxEx_reg;          -- flags from Character TX pipeline A
        SigRxExA    : in SigRxEx_reg;           -- flags from Signal RX pipeline A
        CharRxExA   : in CharRxEx_reg;          -- flags from Char RX pipeline A
        dtct_nullA  : out std_logic;            -- flag to detect null on link establish
        char_rcvdA  : out std_logic;            -- flag to indicate char received by sig layaer
        char_saveA  : out std_logic;            -- flag to save data to rx register in pkt layer
        ExTxA       : out ExTx_reg              -- flags sent to TX pipeline
        
        );
end exchange_tx;

architecture Behavioral of exchange_tx is

    -- TX pipeline register reset
    constant ExTx_rst: ExTx_reg := (
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
    
begin

    process (clk,rst_n,SigRxExA)
        begin
            if (rst_n = '0') then                          -- reset all 
                ExTXA       <= ExTx_rst;
                cnt1        <= "0100"; 
                dtct_nullA  <= '1';
                char_rcvdA  <= '0';
                char_saveA  <= '0';
                
            else
                char_rcvdA  <= SigRxExA.char_rcvd;
                
                if rising_edge(clk) then
                    cnt1 <= cnt1 - '1';
                    
                    if  (SigRxExA.null_dtcd = '1') then
                        ExTxA.data_flag <= '1';
                        dtct_nullA <= '0';
                    end if;
                    
                    if (cnt1 = 0) then
                         cnt1 <= CharTxExA.cnt_max ;    
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
            end if;           
        end process;
 
--    process (clk_tx, rst_n)
--        begin
                        
--            if (rst_n = '0') or (time_out = '1') then
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
