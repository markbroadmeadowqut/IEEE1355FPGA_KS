----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- Create Date:         10.04.2016 09:37:06
-- Design Name: 
-- Module Name:         char_rx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         Receiver character layer of DS bus.  Shift Register and
--                      character detection.
-- Dependencies: 
-- Revision:
-- Revision             1
-- Additional Comments:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use work.bus_pkg.all;

entity char_rx is

    Port (  
        clk             : in std_logic;
        reset_n         : in std_logic;             -- universal reset
        d_in            : in std_logic;             -- data bit from signal layer
        bit_valid       : in std_logic;             -- bit clk from signal layer indicates valid bit
        char_valid      : out std_logic;            -- indicates valid character in register;
        link_actv       : out std_logic;
        pc_char         : out std_logic_vector(9 downto 0)  -- character out with parity           
    );                                                      -- and control bits
    
end char_rx;

architecture Behavioral of char_rx is
    
    signal shft_reg     : std_logic_vector(9 downto 0);     -- 10 bit shift register
    signal cnt          : std_logic_vector(3 downto 0);     -- counter 0 to 9 for timing       
    signal dtct_null    : std_logic;                        -- if 1 look for null char 
    
begin
    process(clk, reset_n  )
        begin
            if (reset_n  = '0') then                        -- reset registers for link reset 
                char_valid  <= '0';
                pc_char     <= (others => '0');
                shft_reg    <= (others => '0');
                cnt         <= (others => '0');
                dtct_null   <= '1';
                link_actv   <= '0';
            elsif rising_edge(clk) then                   
                if (bit_valid = '1') then                   
                    shft_reg(9)  <= d_in;                   -- Shift valid bit into register
                    shft_reg(8 downto 0) <= shft_reg(9 downto 1); 
                    cnt <= cnt - 1;
                        
                    if (dtct_null = '1') then               -- detect null char in shift register
                        if (shft_reg(7 downto 1) = C_CHAR_NULL) then
                            pc_char(3 downto 0) <= shft_reg(3 downto 0);
                            pc_char(9 downto 4) <= "000000";-- zero pad register 
                            cnt <= "0011";                  -- reset clock to count out character
                            dtct_null <= '0';               -- don't enter this segment unless
                            char_valid <= '1';              -- link reset
                            link_actv <= '1';               -- indicate the link is active
                                                        
                        end if;     
                    else                    
                        if (cnt = 0) then                      
                            if (shft_reg(1) = '1') then         -- detect control char
                                pc_char(3 downto 0) <= shft_reg(3 downto 0);  -- send to exchange layer
                                pc_char(9 downto 4) <= "000000";-- zero pad register
                                cnt <= "0011";                  -- set counter to count out current 
                            else                                -- control char bits
                                pc_char <= shft_reg;            -- send data char to exchange layer
                                cnt <= "1001";                                   
                            end if;
                            if (bit_valid = '1') then
                                char_valid <= '1';              --  flag to indicate char is 
                            end if;                             -- in register
                        else                                                            
                            char_valid <= '0';                  -- no character in register
                        end if;                    
                    end if; 
                end if;                   
            end if;      
        end process;
end Behavioral;                  


