
----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         10.04.2016 09:37:06
-- Design Name: 
-- Module Name:         char_rx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         Receive character layer of DS bus.
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
use IEEE.NUMERIC_STD.ALL;
use work.bus_pkg.all;

entity char_rx is
    generic(
        char_width  : integer
        );
    Port ( 
        clk             : in std_logic;  
        rst_n 	        : in std_logic;
        char_rcvd       : in std_logic;
        rd_parity       : in std_logic;
        rd_char_parity  : in std_logic;
        pc_char         : in std_logic_vector(9 downto 0);
        char_rx         : out std_logic_vector(7 downto 0);
        CharRxEx        : out CharRxEx_reg
              
    );
    
end char_rx;

architecture Behavioral of char_rx is

    -- signal to exchange register reset
    constant CharRxEx_rst: CharRxEx_reg := (
        fcc_rcvd    => '0',
        eop1_rcvd   => '0',
        eop2_rcvd   => '0',
        esc_rcvd    => '0',
        null_rcvd   => '0',
        parity_error=> '0'
        );
        
    signal char_parity      : std_logic; 
    signal total_parity     : std_logic;     
    
begin
    process(clk,rst_n,char_rcvd)
        begin
            if (rst_n = '0') then
                char_rx         <= (others => '0');
                CharRxEx        <= CharRxEx_rst;
                char_parity     <= '0';
                total_parity    <= '1';
                
            else
                if rising_edge(clk) and (char_rcvd = '1') then
                    if (pc_char(8) = '1') then
                    
                        if ( pc_char(8 downto 6) = C_CHAR_FCC ) then
                            CharRxEx.fcc_rcvd   <=  '1';  
                        end if;
                            
                        if ( pc_char(8 downto 6) = C_CHAR_EOP1 ) then
                            CharRxEx.eop1_rcvd   <=  '1'; 
                        end if;
    
                        if ( pc_char(8 downto 6) = C_CHAR_EOP2 ) then
                            CharRxEx.eop2_rcvd   <=  '1';
                        end if; 
                        
                        if ( pc_char(8 downto 6) = C_CHAR_ESC ) then
                            if ( pc_char(8 downto 2) = C_CHAR_NULL) then
                                CharRxEx.null_rcvd   <=  '1';                                                      
                            else
                                CharRxEx.esc_rcvd   <=  '1';
                            end if;                            
                        end if;
                    else    
                        char_rx  <=  pc_char(7 downto 0);                        
                    end if;      
                end if;
                
                if (rd_char_parity = '1') then 
                    char_parity <= ((pc_char(7) xor pc_char(6)) xor (pc_char(5) xor pc_char(4))) xor ((pc_char(3) xor pc_char(2)) xor (pc_char(1) xor pc_char(0))); 
                end if;

                if (rd_parity = '1') then 
                    total_parity <= char_parity xor pc_char(8) xor pc_char(9); 
                end if;
                                
                if (total_parity = '0') then
                    CharRxEx.parity_error <= '1';
                end if;                 
            end if;      
        end process;
end Behavioral;                  


