----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- Create Date:         06.04.2016 09:45:00
-- Design Name: 
-- Module Name:         signal_tx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         Signal transmit layer of DS bus.
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
--use IEEE.std_logic_unsigned.all;


entity signal_tx is

    Port ( 
        clk         : in std_logic;     -- TX clock
        reset_n   	: in std_logic;     -- Side reset signal
        d_in        : in std_logic;     -- data stream in      
        d_out       : out std_logic;    -- data stream out
        s_out       : out std_logic;     -- strobe stream out 
        debugr      : out std_logic_vector(35 downto 0) -- debug chanel   
        );
    
end signal_tx;

architecture Behavioral of signal_tx is

   signal d_hold   : std_logic;     -- temporary data signal
   signal s_hold   : std_logic;     -- temporary strobe signal
   
begin    
    
    process(clk,reset_n )
                        
        begin                   
            if (reset_n  = '0') then
                d_out       <= '0';   -- reset all signals
                s_out       <= '0';
                d_hold      <= '0';
                s_hold      <= '0';
            else  
                if rising_edge(clk)then
                    d_hold      <= d_in;    --stream data through
                    s_hold      <= s_hold  xor (d_in xnor d_hold );
                    d_out       <= d_hold;  -- calculate strobe
                    s_out       <= s_hold;                               
                end if;
            end if;          
    end process;       
end Behavioral;