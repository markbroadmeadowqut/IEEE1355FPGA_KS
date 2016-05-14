
----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         10.04.2016 09:37:06
-- Design Name: 
-- Module Name:         char_rx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions: 
-- Description:         Receive character layer of DS bus.
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

entity char_rx is
    generic(
        char_width  : integer
        );
    Port (  
        clk             : in std_logic;
        reset_n         : in std_logic;             -- universal reset
        d_in            : in std_logic;             -- data bit from signal layer
        bit_valid       : in std_logic;             -- bit clk from signal layer indicates valid bit
        null_dtcd       : out std_logic;
        char_valid      : out std_logic;            -- indicates valid character in register;
        pc_char         : out std_logic_vector(9 downto 0)      -- character out           
    );
    
end char_rx;

architecture Behavioral of char_rx is
    
    signal shft_reg     : std_logic_vector(9 downto 0);     -- 10 bit shift register
    signal cnt          : std_logic_vector(3 downto 0);     -- counter 0 to 9     
    signal dtct_null    : std_logic;                        -- if 1 look for null char 
    
begin
    process(clk, reset_n  )
        begin
            if (reset_n  = '0') then                        -- reset procedure
                char_valid  <= '0';
                pc_char     <= (others => '0');
                shft_reg    <= (others => '0');
                cnt         <= (others => '0');
                dtct_null   <= '1';
                null_dtcd   <= '0';
            elsif rising_edge(clk) then                   -- Shift valid bit into register
                if (bit_valid = '1') then
                    shft_reg(0)  <= d_in;
                    shft_reg(9 downto 1) <= shft_reg(8 downto 0); 
                    cnt <= cnt - 1;
                        
                    if (dtct_null = '1') then               -- detect null char in shift register
                        if (shft_reg(8 downto 2) = C_CHAR_NULL) then
                            pc_char(9 downto 6) <= shft_reg(9 downto 6);
                            pc_char(5 downto 0) <= "000000"; 
                            cnt <= "0011";                  -- reset clock to count out character
                              --  null_dtcd <= '1';
                            dtct_null <= '0';
                            char_valid <= '1'; 
                            null_dtcd <= '1';
                                                        
                        end if;     
                    else                    
                        if (cnt = 0) then                      
                            if (shft_reg(8) = '1') then         -- detect control char
                                pc_char(9 downto 6) <= shft_reg(9 downto 6);  -- send to exchange layer
                                pc_char(5 downto 0) <= "000000";
                                cnt <= "0011";                  -- set counter to count out current control char bits
                            else
                                pc_char <= shft_reg;                -- send data char to exchange layer
                                cnt <= "1001";                                   
                            end if;
                            if (bit_valid = '1') then
                                char_valid <= '1';                    --  flag to indicate full char is in register
                            end if; 
                        else                                    -- if you swap 0 and 1 on char clock you increase latency by 6 clock cycles                        
                            char_valid <= '0';
                        end if;                    
                    end if; 
                end if;                   
            end if;      
        end process;
end Behavioral;                  


