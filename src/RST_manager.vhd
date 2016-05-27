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
use IEEE.std_logic_unsigned.all;
use work.bus_pkg.all;

entity RST_manager is
    Port (
    clk         : in std_logic; 
    rstn_hw     : in std_logic;
    RxRst       : in RxRst_rec;
    reset_n     : out std_logic
    );
    
end RST_manager;

architecture Behavioral of RST_manager is
    signal cnt      : std_logic_vector(5 downto 0); 
    signal rsting   : std_logic; 
begin

reset : process(rstn_hw, clk)

    begin
        if (rstn_hw = '0') or (RxRst.parity_err = '1')or (RxRst.timeout = '1')  then
            reset_n <= '0';
            rsting  <= '1';
            cnt <= (others => '0');
        end if;    
       
            
        if rising_edge(clk) then 
            if (rsting = '1') then
            cnt <= cnt + 1;
                if (cnt >= "111110") then
                    reset_n <= '1';
                    rsting  <= '0';   
                end if;
            end if;     
        end if;      
end process reset;

end Behavioral;
