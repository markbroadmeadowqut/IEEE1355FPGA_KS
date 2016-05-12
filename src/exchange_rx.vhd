----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands: 
-- 
-- Create Date:         08.05.2016 10:02:27
-- Design Name: 
-- Module Name:         exchange_rx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         exchange layer for receiver
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

entity exchange_rx is
    generic(
        char_width  : integer
        );
    Port ( 
        clk         : in std_logic;
        char_valid  : in std_logic;
        reset_n     : in std_logic;
        null_dtcd   : in std_logic;
        pc_char     : in std_logic_vector( 9 downto 0 );
        char        : out std_logic_vector( 7 downto 0);
        ExRxTx      : out ExRxExTx_rec;
        ExRxRst     : out ExRxRst_rec 
        );
        
end exchange_rx;

architecture Behavioral of exchange_rx is

    type state_type is (s0_wait, s1_rcvg, s2_lchar, s3_nchar, s4_nodata);
    signal current_s, next_s : state_type;

    -- Flag regester connection to Tx exchange layer
    constant ExRxTx_rst : ExRxExTx_rec := (
        fcc_rcvd    => '0',
        eop1_rcvd   => '0',
        eop2_rcvd   => '0',
        esc_rcvd    => '0',
        null_rcvd   => '0',
        send_fcc    => '0'
        );
    
    constant ExRxRst_rst : ExRxRst_rec := (
        parity_err  => '0',
        timeout     => '0'
        );    

    signal data_parity      : std_logic; 
    signal total_parity     : std_logic; 
    signal half_null_dtcd   : std_logic;
    signal to_cnt           : std_logic_vector( 7 downto 0 );
    
    
begin
    
    process ( clk, reset_n, current_s )
        begin
            if (reset_n  = '0') then
                current_s  <= s0_wait;
                to_cnt     <= (others => '0');                
            else
                if rising_edge(clk) then
                    current_s <= next_s;
                    if (current_s = s4_nodata) then
                        to_cnt <= to_cnt + 1;
                    else
                        to_cnt  <= (others => '0');                           
                    end if;                   
                end if;                   
            end if;      
    end process;
                    
                    
    process( reset_n, char_valid, pc_char )
        begin
            if (reset_n  = '0') then
                ExRxTx          <= ExRxTx_rst;
                ExRxRst         <= ExRxRst_rst;
                char            <= (others => '0');
                data_parity     <= '0';
                total_parity    <= '0';    
                half_null_dtcd  <= '0'; 
                  
                             
            else  
                case current_s is
                    when s0_wait =>
                        if (char_valid = '1') then
                            next_s              <= s1_rcvg;
                            ExRxTx.null_rcvd    <= '1';
                        else
                            next_s <= s0_wait;    
                        end if;
                        
                    when s1_rcvg => 
                        total_parity <= data_parity xor pc_char(8) xor pc_char(9);
                        if (total_parity = '0') then
                            ExRxRst.parity_err <= '1';
                        else
                            ExRxRst.parity_err <= '0';
                            if ( pc_char(8) = '1') then
                                next_s <= s2_lchar;
                            else
                                next_s <= s3_nchar;
                            end if;                             
                        end if;
                        
                    when s2_lchar =>
                        data_parity <= pc_char(7) xor pc_char(6);
                        if ( pc_char(8 downto 6) = C_CHAR_FCC ) then
                            if ( half_null_dtcd = '1') then
                                ExRxTx.null_rcvd   <=  '1'; 
                                half_null_dtcd      <= '0';                                                                                 
                            else
                                ExRxTx.fcc_rcvd   <=  '1'; 
                            end if;   
                        else
                            if ( pc_char(8 downto 6) = C_CHAR_ESC ) then
                                half_null_dtcd  <=  '1';                         
                            else
                                if ( pc_char(8 downto 6) = C_CHAR_EOP1 ) then
                                    ExRxTx.eop1_rcvd   <=  '1';
                                end if;
        
                                if ( pc_char(8 downto 6) = C_CHAR_EOP2 ) then
                                    ExRxTx.eop2_rcvd   <=  '1';
                                end if; 
                            
                                if (half_null_dtcd = '1') then 
                                    ExRxTx.esc_rcvd   <=  '1';  
                                end if;
                            end if;
                        end if;    
                        next_s  <= s1_rcvg;  --s1_rcvg; --
                                              
                    when s3_nchar => 
                        data_parity <= ((pc_char(7) xor pc_char(6)) xor (pc_char(5) xor pc_char(4))) xor ((pc_char(3) xor pc_char(2)) xor (pc_char(1) xor pc_char(0)));
                        char  <=  pc_char(0)& pc_char(1)& pc_char(2)& pc_char(3)& pc_char(4)& pc_char(5)& pc_char(6)& pc_char(7); 
                        next_s <= s1_rcvg; --s1_rcvg;
                        
                    when s4_nodata =>
                        if (char_valid = '1') then
                            next_s  <= s1_rcvg;
                        else
                            if (to_cnt > "11111000") then
                                ExRxRst.timeout <= '1';
                            else
                                ExRxRst.timeout <= '0';    
                            end if;                       
                        end if;     
                end case;
            end if;              
        end process;      
end Behavioral;
