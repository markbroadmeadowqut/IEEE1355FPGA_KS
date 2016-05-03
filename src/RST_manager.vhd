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
    rstn_hw     : in std_logic;
    rstn_sw     : in std_logic;
    reset_n     : out std_logic
    );
    
end RST_manager;

architecture Behavioral of RST_manager is

begin

reset : process(rstn_hw, rstn_sw)

    begin
        if (rstn_hw = '0') or (rstn_sw = '0') then
                reset_n <= '0';
        else
                reset_n <= '1';
        end if;
end process reset;

end Behavioral;
