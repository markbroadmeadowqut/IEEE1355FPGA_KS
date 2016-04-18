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

entity signal_rx is

    Port ( 
        clk             : in  std_logic;         -- rx clock        
        rst_n 	        : in  std_logic;         -- reset signal      
        data_in         : in  std_logic;         -- data vit in               
        strobe_in       : in  std_logic;         -- strobe in on upstream connection.        
        dtct_null       : in std_logic;          -- implement detection of a null character on in stream  
        eop_rcvd        : inout std_logic;       -- end of packet received at signal_rx
        pc_char         : out std_logic_vector(9 downto 0);    -- 10 bit rx character          
        char_rec        : out std_logic;         -- flag for received character
        null_dtcd       : out std_logic;         -- flag for detection of null character in stream
        time_out        : out std_logic;         -- high if no data received for time out duration.
        rcvg_data       : out std_logic         -- receiving data at signal_rx        
    );
end signal_rx;

architecture behavioral of signal_rx is

    signal d_ff1       : std_logic;            -- input sampling flip flops
    signal d_ff2       : std_logic;            -- di = data in-- ff = flipflop
    signal s_ff1       : std_logic;            -- ff = flipflop
    signal s_ff2       : std_logic;            -- 1st/2nd bit     stage a/b
    signal s_latch     : std_logic;                     -- latch previous strobe bit
    signal data        : std_logic_vector(9 downto 0);  -- data bit in    
    signal enable      : std_logic;                     -- detect valid bit in
    signal cnt         : std_logic_vector(3 downto 0);  -- count bits in character
    signal timer       : std_logic_vector(9 downto 0);  --counter for time out
begin
 
    process(clk)  
        begin   
                     
            if rising_edge(clk) then  
                 if (rst_n = '0') then
                    pc_char     <= "0000000000";   -- character received 
                    char_rec    <= '0';
                    null_dtcd   <= '0';
                    time_out    <= '0';
                    rcvg_data   <= '0';          
                    char_rec    <= '0';
                    d_ff1       <= '0';
                    d_ff2       <= '0';
                    s_ff1       <= '0';
                    s_ff2       <= '0';
                    s_latch     <= '0';
                    data        <= "0000000000";
                    enable      <= '0';
                    cnt         <= "0000";
                else                        
                    d_ff1      <=  data_in;        -- use two stage Flip Flops
                    s_ff1      <=  strobe_in;      -- to stabilise signal
                    d_ff2      <=  d_ff1;
                    s_ff2      <=  s_ff1;  
                
                    if (enable = '1') then          -- select bit for character
                        data(0)    <=  d_ff2;
                        data(9 downto 1) <= data(8 downto 0);
                        s_latch <=  s_ff2;
                        cnt <= cnt + 1;
                        timer <= "0000000000";
                                               
                        if (dtct_null = '1') then
                            if (data(6 downto 0) = "1110100") then
                                cnt <= "0000";
                                null_dtcd <= '1';
                                rcvg_data <= '1';                                
                            end if;     
                        else                                 
                            if (cnt = 9) then       -- if eop rcvd then send fcc
                               pc_char <= data;
                               char_rec <= '1';
                               cnt <= "0000";                                  
                            else
                                char_rec <= '0';   
                            end if; 
                        end if;     
                    else
                        timer <= timer+1;
                        if (timer >= "1111111100") then
                            time_out <= '1';
                        end if; 
                    end if;    
                end if;
            end if;
            enable  <=  d_ff2 xor s_ff2 xor data(0) xor s_latch;        -- Edge detection of TX clock
        end process;   
end behavioral;
