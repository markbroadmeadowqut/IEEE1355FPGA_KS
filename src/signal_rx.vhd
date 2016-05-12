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
        reset_n  	    : in  std_logic;        -- reset signal      
        d_in            : in  std_logic;        -- data vit in               
        s_in            : in  std_logic;        -- strobe in on upstream connection. 
        d_out           : out std_logic; 
        bit_valid       : out std_logic   
    );
end signal_rx;

architecture behavioral of signal_rx is
    
    signal d_ff1        : std_logic;                    -- input sampling flip flops
    signal d_ff2        : std_logic;                    -- di = data in-- ff = flipflop
    signal s_ff1        : std_logic;                    -- ff = flipflop
    signal s_ff2        : std_logic;                    -- 1st/2nd bit     stage a/b
    signal d_latch      : std_logic;                    -- latch previous bit    
    signal s_latch      : std_logic;                    -- latch previous strobe bit
    signal enable       : std_logic;                    -- bit clock latched for use
    

begin 
    process(clk,reset_n )  
        begin   
            if (reset_n  = '0') then
                d_out       <= '0';
                bit_valid   <= '0';            
                d_ff1       <= '0';
                d_ff2       <= '0';
                s_ff1       <= '0';
                s_ff2       <= '0';
                s_latch     <= '0';
                d_latch     <= '0';
                enable      <= '0';

                
            else
                
                enable    <=  (d_ff2 xor s_ff2) xor (d_latch xor s_latch);        -- bit clock latched for use in next statement 
                                      -- Edge detection of TX clock
                if rising_edge(clk) then
                               
                if (enable = '1') then
                    bit_valid   <=  '1';
                else
                    bit_valid   <= '0';      
                end if;                  
                        
                    d_ff1       <=  d_in;       -- use two stage Flip Flops
                    s_ff1       <=  s_in;       -- to stabilise signal
                    d_ff2       <=  d_ff1;
                    s_ff2       <=  s_ff1;
                           
                    if (enable = '1') then    -- select bit for character (edge detector of bit from DS signal)
                        d_out       <=  d_ff2;
                        d_latch     <=  d_ff2;
                        s_latch     <=  s_ff2;
                        --bit_clk     <=  d_latch xor s_latch;        -- Edge detection of TX clock
                        
                    end if;    
                end if;
            end if;
        end process;   
end behavioral;
