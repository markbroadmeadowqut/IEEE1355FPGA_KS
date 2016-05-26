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
    --signal err_cnt  : integer; 
begin

reset : process(rstn_hw, clk)

    begin
        if (rstn_hw = '0') then
            reset_n <= '0';
        else 
            reset_n <= '1';
        end if;
            
        if rising_edge(clk) then  
            if (RxRst.parity_err = '1') then --or (RxRst.timeout = '1') then
                reset_n <= '0';
            else
                 reset_n <= '1';       
            end if;
        end if;      
end process reset;

end Behavioral;
