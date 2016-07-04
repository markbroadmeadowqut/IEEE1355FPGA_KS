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
-- Dependencies: 
-- Revision:
-- Revision             1
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package bus_pkg is

    -- Indicates a configuration for the node.
    type node_type is ( slave, master );
    
    -- control chars last three bits without parity bit in little endian form 
    -- MSB is on ritht of character
    constant C_CHAR_FCC     : std_logic_vector(2 downto 0) := "001";
    constant C_CHAR_EOP1    : std_logic_vector(2 downto 0) := "101";
    constant C_CHAR_EOP2    : std_logic_vector(2 downto 0) := "011";
    constant C_CHAR_ESC     : std_logic_vector(2 downto 0) := "111";
    constant C_CHAR_NULL    : std_logic_vector(6 downto 0) := "0010111";

   
    -- Flags to be passed between exchange layers from RX to TX.
    type ExRxExTx_rec is record
        link_est        : std_logic;            -- when = 1 first null received and link established    
        fcc_rcvd        : std_logic;            -- when = 1 fcc received
        send_fcc        : std_logic;            -- when = 1 send fcc
        eop1_rcvd       : std_logic;            -- when = 1 eop1 received
        eop2_rcvd       : std_logic;            -- when = 1 eop2 received
        esc_rcvd        : std_logic;            -- when = 1 exc received        
        data_rcvd       : std_logic;            -- when = 1 request data from other node
    end record;
    
    -- Flags to be passed between exchange layers from TX to RX.
    type ExTxExRx_rec is record
        fcc_sent        : std_logic;            -- when = 1 data being ordered   
        fcc_rcvd_ack    : std_logic;            -- when = 1 fcc received acknowledged
    end record;    
   
    --Rx Exchange layer record for flags to reset manager
    type RxRst_rec is record
        parity_err    : std_logic;            -- parity error detected flag
        timeout       : std_logic;            -- Timeout flag for reset manager
        link_actv     : std_logic;            -- first null detected in Rx char layer
    end record; 
    
   
    -- record from both exchage layers to fifo in ackage layer
    type ExPkt_rec is record
        din         : std_logic_vector(7 downto 0); -- received character byte
        wr_en       : std_logic;                    -- write enable to FIFO
        rd_en       : std_logic;                    -- read enable from FIFO
        eop1_rcvd   : std_logic;                    -- end of packet received
    end record;
        
   
    -- record from fifo in pkg layer to both exchange layers
    type PktEx_rec is record
        dout        : std_logic_vector(7 downto 0); -- data byte from FIFO
        full        : std_logic;                    -- FIFO is full
        empty       : std_logic;                    -- FIFO is empty
        eop1_rcvd   : std_logic;                    -- end of packet received
    end record;
       
end package;
