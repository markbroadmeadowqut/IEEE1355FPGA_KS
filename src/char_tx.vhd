
----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         05.04.2016 10:43:06
-- Design Name:         
-- Module Name:         char_tx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         transmission character layer of DS bus.
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
use work.bus_pkg.all;

entity char_tx is
    generic (
        char_width  : in integer
        );
    Port ( 
        clk         : in std_logic; 
        char_valid  : in std_logic;       
        reset_n     : in std_logic;        
        char_in     : in std_logic_vector(9 downto 0);
        d_out       : out std_logic
        );
        
end char_tx;

architecture Behavioral of char_tx is

    signal shft_reg     : std_logic_vector(9 downto 0);
           
begin
    process(clk, reset_n )
        begin 
            if (reset_n  = '0') then                  -- set char out to 0 if reset
                d_out       <= '0';
                shft_reg    <= (others => '0');
            else
                if rising_edge(clk) then
                    d_out   <= shft_reg(0);
                    if (char_valid = '1') then
                        shft_reg    <= char_in;
                    else
                        shft_reg(8 downto 0) <= shft_reg(9 downto 1);
                        shft_reg(9) <= '0';
                    end if;         
                end if;  
            end if;                                
        end process; 
end Behavioral;