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
        bit_valid       : out std_logic;
        time_out        : out std_logic   
    );
end signal_rx;

architecture behavioral of signal_rx is
    
    signal d_ff1        : std_logic;                    -- input sampling flip flops
    signal d_ff2        : std_logic;                    -- di = data in-- ff = flipflop
    signal s_ff1        : std_logic;                    -- ff = flipflop
    signal s_ff2        : std_logic;                    -- 1st/2nd bit     stage a/b
    signal d_hold       : std_logic;                    -- latch previous bit    
    signal s_hold       : std_logic;                    -- latch previous strobe bit
    signal enable       : std_logic;                    -- bit clock latched for use
    signal to_cnt       : std_logic_vector(6 downto 0); -- counter for time out detection.
    

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
                s_hold      <= '0';
                d_hold      <= '0';
                enable      <= '0';
                to_cnt      <= (others => '0');
                time_out    <= '0';
                
            else
                
                if rising_edge(clk) then
                               
                    if (enable = '1') then
                        bit_valid   <=  '1';
                        to_cnt <= (others => '0');
                    else
                        bit_valid   <= '0';
                        to_cnt <= to_cnt + 1;      
                    end if;                  
                        
                    d_ff1       <=  d_in;       -- use two stage Flip Flops
                    s_ff1       <=  s_in;       -- to stabilise signal
                    d_ff2       <=  d_ff1;
                    s_ff2       <=  s_ff1;
                           
                    if (enable = '1') then    -- select bit for character (edge detector of bit from DS signal)
                        d_out       <=  d_ff2;
                        d_hold      <=  d_ff2;
                        s_hold      <=  s_ff2;
                        --bit_clk     <=  d_latch xor s_latch;        -- Edge detection of TX clock
                        
                    end if;
                    
                    if (to_cnt > "111100") then
                        time_out <= '1';
                    else
                        time_out <= '0';    
                    end if;                     
                        
                end if;
                enable    <=  (d_ff2 xor s_ff2) xor (d_hold xor s_hold);        -- bit clock latched for use in next statement 
                                                                                   -- Edge detection of TX clock
            end if;
        end process;   
end behavioral;
