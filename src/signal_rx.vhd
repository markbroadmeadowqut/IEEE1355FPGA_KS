----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.04.2016 06:34:35
-- Design Name: 
-- Module Name: signal_rx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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
use IEEE.std_logic_unsigned.all;
use work.bus_pkg.all;

entity signal_rx is
    generic(
        char_width  : integer
        );
    Port ( 
        clk             : in  std_logic;        -- rx clock        
        rst_n  	        : in  std_logic;        -- reset signal      
        data_in         : in  std_logic;        -- data vit in               
        strobe_in       : in  std_logic;        -- strobe in on upstream connection.        
        dtct_null       : in  std_logic;        -- implement detection of a null character on in stream 
        pc_char         : out std_logic_vector(9 downto 0);    -- 10 bit rx character
        SigChar         : out SigChar_rec;  -- signal to char layer record          
        SigRxEx         : out SigRxEx_rec       -- signal Rx to exchange layer record    
    );
end signal_rx;

architecture behavioral of signal_rx is
    
    -- signal to exchange record reset
    constant SigRxEx_rst: SigRxEx_rec := (
        d_char_rcvd => '0',           -- data char received  
        null_dtcd   => '0',           -- send data from char_tx
        time_out    => '0'            -- send fcc call
        );
        
    -- signal to character record reset
        constant SigChar_rst: SigChar_rec := (
            rd_tot_parity   => '0',           -- read parity of previous char and control and parity bit  
            rd_char_parity  => '0',           -- read parity of previous character
            char_rcvd       => '0'            -- acknowledge char has been received into register
            );        

    signal d_ff1       : std_logic;                     -- input sampling flip flops
    signal d_ff2       : std_logic;                     -- di = data in-- ff = flipflop
    signal s_ff1       : std_logic;                     -- ff = flipflop
    signal s_ff2       : std_logic;                     -- 1st/2nd bit     stage a/b
    signal s_latch     : std_logic;                     -- latch previous strobe bit
    signal data        : std_logic_vector(9 downto 0);  -- data bit in    
    signal enable      : std_logic;                     -- detect valid bit in                     
    signal cnt         : std_logic_vector(3 downto 0);  -- count bits in character
    signal timer       : std_logic_vector(9 downto 0);  --counter for time out

begin
 
    process(clk,rst_n )  
        begin   
            if (rst_n  = '0') then
                pc_char     <= (others => '0');   -- character received 
                SigRxEx     <= SigRxEx_rst; 
                SigChar     <= SigChar_rst;
                d_ff1       <= '0';
                d_ff2       <= '0';
                s_ff1       <= '0';
                s_ff2       <= '0';
                s_latch     <= '0';
                data        <= (others => '0');
                enable      <= '0';
                cnt         <= (others => '0');
                timer       <= (others => '0');
                pc_char(9)  <= '1';
                
            else
                if rising_edge(clk) then                          
                    d_ff1      <=  data_in;        -- use two stage Flip Flops
                    s_ff1      <=  strobe_in;      -- to stabilise signal
                    d_ff2      <=  d_ff1;
                    s_ff2      <=  s_ff1;  
                
                    if (enable = '1') then          -- select bit for character (edge detector of bit from DS signal)
                        data(0)    <=  d_ff2;
                        data(9 downto 1) <= data(8 downto 0);
                        s_latch <=  s_ff2;
                       -- cnt <= cnt + 1;
                        timer <= (others => '0');
                        
                        if (dtct_null = '1') then
                            if (data(8 downto 2) = C_CHAR_NULL) then
                                pc_char(9 downto 6) <= data(9 downto 6);
                                pc_char(5 downto 0) <= "000000"; 
                                cnt <= "0110";
                                SigRxEx.null_dtcd <= '1';
                                pc_char(9)  <= '0';                               
                            end if;     
                        else
                            cnt <= cnt + 1;
                            if (cnt = 9) then                      
                                if (data(8) = '1') then                         -- detect control char
                                    pc_char(9 downto 6) <= data(9 downto 6);  
                                    pc_char(5 downto 0) <= "000000";
                                    SigRxEx.d_char_rcvd <= '0';
                                    cnt <= "0110";
                                else
                                    pc_char <= data;      
                                    SigRxEx.d_char_rcvd <= '1';
                                    cnt <= "0000";                                   
                                end if; 
                                SigChar.char_rcvd <= '1';                       --  flag to indicate full char is in register
                            else
                                SigChar.char_rcvd <= '0';    
                            end if;
                            
                            if (cnt = 6) then                                   -- calcuate parity bit 
                                SigChar.rd_tot_parity <='1';    
                            else    
                                SigChar.rd_tot_parity <='0';
                            end if;
                            
                            if (cnt = 7) then                                   -- calcuate previous data parity
                                SigChar.rd_char_parity <='1';    
                            else    
                                SigChar.rd_char_parity <='0';
                            end if;                        
                        end if; 
                    else                                                        -- measure time of inactive line
                        timer <= timer+1;
                        if (timer >= "1111111100") then     
                            SigRxEx.time_out <= '1';
                        end if;  
                    end if;    
                end if;    
                enable  <=  d_ff2 xor s_ff2 xor data(0) xor s_latch;             -- Edge detection of TX clock
            end if;
        end process;   
end behavioral;
