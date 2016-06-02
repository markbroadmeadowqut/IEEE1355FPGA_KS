----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands: 
-- Create Date:         08.05.2016 10:02:27
-- Design Name: 
-- Module Name:         exchange_rx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         exchange layer for receiver.  state machine controlled
-- Dependencies: 
-- Revision:
-- Revision             1
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use work.bus_pkg.all;

entity exchange_rx is

    Port ( 
        clk         : in std_logic;         -- RX clock
        char_valid  : in std_logic;         -- Valid character in incoming register
        reset_n     : in std_logic;         -- Side reset signal
        full        : in std_logic;         -- FIFO full flag
        fcc_sent    : in std_logic;         -- FCC has been sent from transmitter
        pc_char     : in std_logic_vector( 9 downto 0 );    -- in coming character
        parity_err  : out std_logic;        -- parrity error detected
        wr_en       : out std_logic;        -- write enable FIFO in register
        char        : out std_logic_vector( 7 downto 0);    -- FIFO in register
        ExRxTx      : out ExRxExTx_rec      -- Records from this exchange to 
        );                                  -- transmitter exchange
        
end exchange_rx;

architecture Behavioral of exchange_rx is
                                            -- state machine states
    type state_type is (s0_wait, s1_rcvg, s2_lchar, s3_nchar, s4_nodata);
    signal state : state_type;

    -- Flag regester connection to Tx exchange layer
    constant ExRxTx_rst : ExRxExTx_rec := (
        link_est    => '0',
        fcc_rcvd    => '0',             -- Reset signals prototype used for 
        send_fcc    => '0',             -- resetting all flags in record
        eop1_rcvd   => '0',
        eop2_rcvd   => '0',
        esc_rcvd    => '0',
        data_rcvd   => '0'
        );
        
    constant ExRxTx_clr : ExRxExTx_rec := (
        link_est    => '1',
        fcc_rcvd    => '0',             -- Clear all flags in register 
        send_fcc    => '0',             -- with exception to link 
        eop1_rcvd   => '0',             -- runnin indicator
        eop2_rcvd   => '0',
        esc_rcvd    => '0',
        data_rcvd   => '0'
        );        

    signal data_parity      : std_logic;    -- saves data parity of current char
    signal total_parity     : std_logic;    -- total parity calculation
    signal half_null_dtcd   : std_logic;    -- first half of null detected
    signal char_req_cnt     : std_logic_vector(4 downto 0);  -- records fcc cnt sent
    signal send_fcc         : std_logic;    -- tells tx to send FCC
    signal Q                : std_logic;    -- SR latch output
    signal notQ             : std_logic;    -- SR latch not output
    
begin
    
    process ( clk, reset_n )
        begin
            if (reset_n  = '0') then            -- reset all internal and out
                state           <= s0_wait;     -- signals
                ExRxTx          <= ExRxTx_rst;  
                parity_err      <= '0';
                char            <= (others => '0');
                data_parity     <= '0';
                total_parity    <= '0';    
                half_null_dtcd  <= '0'; 
                wr_en           <= '0';
                char_req_cnt     <= (others => '0');
                send_fcc        <= '0';
                Q               <= '0';
                notQ            <= '1';        
                            
            else
                ExRxTx.send_fcc <= Q;       -- SR latch for ordering FCC's
                Q           <= fcc_sent nor notQ;   -- needed to cross bounds of
                notQ        <= send_fcc nor Q;      -- rx and tx pipelines
            
                if rising_edge(clk) then
                                  
                   case state is       
                        -- this is a waiting state for a valid character to arrive.  
                        when s0_wait =>         --  waiting for valid character
                            if (char_valid = '1') then
                                state               <= s1_rcvg;
                                ExRxTx.link_est     <= '1';
                            else
                                state <= s0_wait;
                                total_parity <= '1';    
                            end if;
                            
                        -- this state accepts a char and determines its integrity    
                        when s1_rcvg =>         -- receiving character into register
                            send_fcc <= '0';    -- don't send FCC
                            total_parity <= data_parity xor pc_char(1) xor pc_char(0);
                                                            -- parity calculation
                            if (total_parity = '0') then    -- detect parity error     
                                parity_err <= '1';  
                            else
                                parity_err <= '0';          -- no parity error detected
                                ExRxTx     <= ExRxTx_clr; 
                                if ( pc_char(1) = '1') then -- detect control char or
                                    state <= s2_lchar;      
                                else
                                    state <= s3_nchar;      -- detect data char
                                    char_req_cnt <= char_req_cnt - 1;
                                end if;                     -- keep track of FCC's
                            end if;                         -- sent and chars rcvd
                            
                        -- This state handles control chars    
                        when s2_lchar =>
                            data_parity <= pc_char(2) xor pc_char(3);
                                            -- calculate data parity for next
                                            -- parity calculation
                            if ( pc_char(3 downto 1) = C_CHAR_FCC ) then
                                if ( half_null_dtcd = '1') then     -- null char 
                                    half_null_dtcd      <= '0';     -- received                                                                            
                                else
                                    ExRxTx.fcc_rcvd   <=  '1';      -- flag fcc received
                                end if;   
                            else
                                if ( pc_char(3 downto 1) = C_CHAR_ESC ) then
                                    half_null_dtcd  <=  '1';        -- flag first half                 
                                else                                -- null detected    
                                    if ( pc_char(3 downto 1) = C_CHAR_EOP1 ) then
                                        ExRxTx.eop1_rcvd   <=  '1'; -- flag EOP1 received    
                                    end if;                   -- pass to tx exc.
            
                                    if ( pc_char(3 downto 1) = C_CHAR_EOP2 ) then
                                        ExRxTx.eop2_rcvd   <=  '1'; -- flag EOP2
                                    end if;
                                            
                                    if (half_null_dtcd = '1') then 
                                        ExRxTx.esc_rcvd   <=  '1';  
                                    end if;             -- flagging ESC may be
                                end if;                 -- useless
                            end if;    
                            state  <= s4_nodata;  
                            
                        -- this state handles data chars.  passes to FIFO                          
                        when s3_nchar => 
                            data_parity <= ((pc_char(9) xor pc_char(8)) xor (pc_char(7)xor pc_char(6))) 
                                      xor ((pc_char(5) xor pc_char(4)) xor (pc_char(3) xor pc_char(2)));
                            char  <=  pc_char(9 downto 2);
                            wr_en <= '1'; 
                            state <= s4_nodata;
                             
                        -- This state waits for next character and resets some flags  
                        when s4_nodata =>
                            wr_en <= '0';
                            ExRxTx.fcc_rcvd   <=  '0'; 
                            if (char_valid = '1') then
                                state  <= s1_rcvg;      -- request to send FCC from TX
                                if (char_req_cnt < 8) then 
                                    char_req_cnt <= char_req_cnt + 8;
                                    send_fcc <= '1';  
                                end if;                      
                            end if;     
                    end case;
                end if;      
            end if;              
        end process;      
end Behavioral;
