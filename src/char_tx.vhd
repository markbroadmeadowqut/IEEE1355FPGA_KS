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
-- Dependencies: 
-- Revision:
-- Revision             1
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
library UNISIM;    
    use UNISIM.VComponents.all;
library WORK;
    use work.bus_pkg.all;

entity char_tx is

    Port ( 
        clk         : in std_logic;     -- transmission clock
        char_valid  : in std_logic;     -- valid character signal    
        reset_n     : in std_logic;     -- side reset signal       
        char_in     : in std_logic_vector(9 downto 0);  -- character from exchange layer
        d_out       : out std_logic;     -- data stream out
        debugr      : out std_logic_vector(35 downto 0) -- debug chanel
    );
        
end char_tx;

architecture Behavioral of char_tx is

    signal shft_reg     : std_logic_vector(9 downto 0); -- Shift register for streaming data
           
begin
    process(clk, reset_n )
        begin 
            if (reset_n  = '0') then            -- reset out signal and internal register
                d_out       <= '0';
                shft_reg    <= (others => '0');
            else
                if rising_edge(clk) then        
                    d_out   <= shft_reg(0);     -- shift bit out
                    if (char_valid = '1') then  -- when shift regester is empty fill it
                        shft_reg    <= char_in;
                    else
                        shft_reg(8 downto 0) <= shft_reg(9 downto 1);
                        shft_reg(9) <= '0';     -- shift bits along register
                    end if;         
                end if;  
            end if;                                
        end process;
        
        debugr(0)           <= clk;
        debugr(1)           <= reset_n;
        debugr(2)           <= char_valid;
        debugr(12 downto 3) <= char_in(9 downto 0);
        debugr(22 downto 13)<= shft_reg(9 downto 0);
        debugr(35 downto 23)<= (others => '0');
                    
end Behavioral;