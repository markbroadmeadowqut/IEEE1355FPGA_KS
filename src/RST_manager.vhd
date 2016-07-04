----------------------------------------------------------------------------------
-- Project              Final Year Project 
-- Engineer:            Ken Sands
-- Create Date:         29.04.2016 11:29:57
-- Design Name: 
-- Module Name:         RST_manager - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         Reset manager for controling individual side reset
-- Dependencies
-- Revision:
-- Revision             1
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;       -- wasn't used before
library UNISIM;    
    use UNISIM.VComponents.all;
library WORK;
    use work.bus_pkg.all;
--use IEEE.std_logic_unsigned.all;

entity RST_manager is
    Port (
    clk         : in std_logic;      
    rstn_hw     : in std_logic;         -- reset from physical button on Arty
    RxRst       : in RxRst_rec;         -- Record from side carying error flags
    reset_n     : out std_logic;         -- Reset signal to all components
    debug       : out std_logic_vector(35 downto 0)
    );
    
end RST_manager;

architecture Behavioral of RST_manager is
    --signal cnt      : std_logic_vector(5 downto 0);     --resetting counter
    signal rsting   : std_logic;                        -- resetting process in operation 
    signal reset_n_hold : std_logic;                        
                                                        
begin    

reset : process(rstn_hw, clk)
    
    variable cnt    : integer range 0 to 63;
    
    begin
        if (rstn_hw = '0') then             --physical reset   
            reset_n <= '0';
            reset_n_hold <= '0';
            rsting  <= '1';
            cnt := 0;--(others => '0');
        end if;           
            
        if rising_edge(clk) then 
            if (rsting = '1') then          -- counter to keep reset occuring
                cnt := cnt + 1;             -- continues for a count of 60 
                if (cnt > 60) then         -- causes connected node to reset
                    reset_n <= '1';         -- 60 is nominal and will later
                    reset_n_hold <= '1';
                    rsting  <= '0';         -- align with standard
                    cnt := 0;
                end if;
                
            elsif (RxRst.link_actv = '1')then   -- reset if parity or timeout error
                if(RxRst.parity_err = '1')or (RxRst.timeout = '1')  then
                    reset_n <= '0';
                    reset_n_hold <= '0';
                    rsting  <= '1';
                    cnt := 0; --(others => '0'); 
                end if;                          
            end if; 
                
        end if; 
            
end process reset;

    debug(0)           <= clk;
    debug(1)           <= rstn_hw; 
    debug(2)           <= reset_n_hold;
    debug(3)           <= RxRst.parity_err;
    debug(4)           <= RxRst.timeout;
    debug(5)           <= RxRst.link_actv;
    debug(6)           <= rsting;


end Behavioral;
