----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.04.2016 11:29:57
-- Design Name: 
-- Module Name: RST_manager - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RST_manager is
    Port ( 
    rst_n   : in std_logic;
    rst_sw  : in std_logic;
    rst     : out std_logic
    );
    
end RST_manager;

architecture Behavioral of RST_manager is

begin

reset : process(rst_n, rst_sw)

    begin
        if (rst_n = '0') or (rst_sw = '0') then
                rst <= '0';
        else
                rst <= '1';
        end if;
end process reset;

end Behavioral;
