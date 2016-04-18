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


entity exchange_layer is
    Port ( 
        clk_rx      : in std_logic;             -- receiver clock
        clk_tx      : in std_logic;             -- transmitter clock
        rst_n       : in std_logic;             -- reset
--        null_dtcd   : in std_logic;             -- null character detected by signal_rx
--        time_out    : in std_logic;             -- connection has timed out.  
--        rcvg_data   : in std_logic;             -- receiving data at signal_rx
--        eop_rcvd    : in std_logic;             -- end of packet received at signal_rx
--        fcc_sent    : in std_logic;             -- used to toggle fcc_flag.
--        dtct_null   : out std_logic;          -- detect null character at signal_rx
        data_flag   : out std_logic            -- send data from char_tx
--        fcc_flag    : out std_logic            -- send fcc call
        );
end exchange_layer;

architecture Behavioral of exchange_layer is
--    type state_type is (s0_ready, s1_null_sent, s2_null_rcvd, s3_rcvg_data, s4_error);
--    signal state : state_type;
begin

    data_flag <= '1';
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