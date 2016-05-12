----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands: 
-- 
-- Create Date:         22.04.2016 09:05:51
-- Design Name: 
-- Module Name:         bus_pkg - Package
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         templates for records containing signals to modules
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


package bus_pkg is

    constant C_CHAR_FCC     : std_logic_vector(2 downto 0) := "100";
    constant C_CHAR_EOP1    : std_logic_vector(2 downto 0) := "101";
    constant C_CHAR_EOP2    : std_logic_vector(2 downto 0) := "110";
    constant C_CHAR_ESC     : std_logic_vector(2 downto 0) := "111";
    constant C_CHAR_NULL    : std_logic_vector(6 downto 0) := "1110100";

    -- RX char record for flags indicating status of received character
    type ExRxExTx_rec is record
        fcc_rcvd        : std_logic;            -- when = 1 fcc received
        eop1_rcvd       : std_logic;            -- when = 1 eop1 received
        eop2_rcvd       : std_logic;            -- when = 1 eop2 received
        esc_rcvd        : std_logic;            -- when = 1 exc received
        null_rcvd       : std_logic;            -- when = 1 null received
        send_fcc        : std_logic;            -- when = 1 request data from other node
    end record;
    
    --Rx Exchange layer record for flags to reset manager
    type ExRxRst_rec is record
        parity_err    : std_logic;            -- parity error detected flag
        timeout       : std_logic;            -- Timeout flag for reset manager
    end record; 

    -- Exchange layer record for flags to control TX pipeline
--    type ExTx_rec is record
--        req_pkt     : std_logic;            -- request char from packet layer
--        fcc_flag    : std_logic;            -- send fcc from char_tx
--        eop1_flag   : std_logic;            -- send eop1 from char_tx
--        eop2_flag   : std_logic;            -- send eop2 from char_tx
--        esc_flag    : std_logic;            -- send data from char_tx
--        data_flag   : std_logic;            -- send data from char_tx
--        ld_txreg    : std_logic;            -- load character into signal_tx out reg
--    end record; 
    
    -- Exchange layer record for flags to control TX pipeline
--    type CharTxEx_rec is record
       -- fcc_sent        : std_logic;            -- send fcc from char_tx
       -- eop1_sent       : std_logic;            -- send eop1 from char_tx
       -- eop2_sent       : std_logic;            -- send eop2 from char_tx
      --  esc_sent        : std_logic;            -- send data from char_tx
      -- data_sent       : std_logic;            -- send data from char_tx
--        cnt_max         : std_logic_vector(3 downto 0);            -- send length of character being sent
--    end record;    
    
    -- RX signal record for flags indicating status of signal
--    type SigRxEx_rec is record
--        d_char_rcvd     : std_logic;            -- data char received on signal incoming 
--        null_dtcd       : std_logic;            -- null detected on signal incoming 
--        time_out        : std_logic;            -- connection timed out              
--    end record;
    
    

    
    -- RX char record for flags indicating status of received character
--    type SigChar_rec is record
--        rd_tot_parity   : std_logic;            -- fcc detected in char layer
--        rd_char_parity  : std_logic;            -- eop1 detected in char layer
--        char_rcvd       : std_logic;            -- eop2 detected in char layer
--    end record;    
    
end package;
