----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- Create Date:         10.04.2016 06:34:35
-- Design Name: 
-- Module Name:         signal_rx - Behavioral
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Tool Versions:       Vivado 2015.4  
-- Description:         Receiver signal layer of initial bus design.
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

entity signal_rx is
    Port ( 
        clk             : in  std_logic;        -- receiver clock        
        reset_n  	    : in  std_logic;        -- side reset signal      
        d_in            : in  std_logic;        -- data bit in               
        s_in            : in  std_logic;        -- strobe bit in . 
        d_out           : out std_logic;        -- data bit to character layer
        bit_valid       : out std_logic;        -- valid bit on stream
        time_out        : out std_logic;         -- timeout flag for reset manager
        debug          : out std_logic_vector(35 downto 0) -- debug chanel
    );
end signal_rx;

architecture behavioral of signal_rx is
    
    signal d_ff1        : std_logic;                    -- input sampling flip flops
    signal d_ff2        : std_logic;                    -- di = data in
    signal s_ff1        : std_logic;                    -- ff = flipflop
    signal s_ff2        : std_logic;                    -- 1st/2nd denoted by 1 or 2
    signal d_hold       : std_logic;                    -- keep data for one extra clk cycle   
    signal s_hold       : std_logic;                    -- also hold previous strobe bit
    signal enable       : std_logic;                    -- sample correct bit from stream.
    --signal to_cnt       : std_logic_vector(6 downto 0); -- counter for time out detection.
    signal fst_d_rcvd   : std_logic;                    -- first null char detected.
    
begin 

    process(clk, reset_n ) 
        
        variable to_cnt : integer range 0 to 63;
                     
        begin   
            if (reset_n  = '0') then            -- reset all signals
                d_out       <= '0';
                bit_valid   <= '0';            -- valid bit in register d_ff2
                d_ff1       <= '0';
                d_ff2       <= '0';
                s_ff1       <= '0';
                s_ff2       <= '0';             
                s_hold      <= '0';             -- strobe held for character determination
                d_hold      <= '0';             -- held data for character determination
                enable      <= '0';             -- select a bit
                to_cnt      := 0;               -- timeout counter
                time_out    <= '0';             -- flag to send to rst manager to indicated time out
                fst_d_rcvd  <= '0';             -- stops resetting new link attempt before anything has started.
                
            elsif rising_edge(clk) then
                               
                if (enable = '1') then              -- found a valid bit in data stream
                    bit_valid   <=  '1';            -- flag a valid bit
                    to_cnt := 0;                    -- reset counter if bit detected
                    fst_d_rcvd <= '1';              -- flag the first character received
                else
                    bit_valid   <= '0';             
                    if (fst_d_rcvd = '1') then      -- if it doesn't sample a bit of data
                        to_cnt := to_cnt + 1;       -- count every clock cycle  
                    end if;          
                end if;                  
                        
                d_ff1       <=  d_in;                   -- use two stage Flip Flops
                s_ff1       <=  s_in;                   -- to stabilise signal 
                d_ff2       <=  d_ff1;                  -- counter acts metastability
                s_ff2       <=  s_ff1;

                if (enable = '1') then              -- select a bit to build a character 
                    d_out       <=  d_ff2;          -- samples when an edge is detected
                    d_hold      <=  d_ff2;
                    s_hold      <=  s_ff2;
                        
                end if;
                    
                if (to_cnt > 40) then         -- flag set if timeout of link has occurred
                        time_out <= '1';
                        to_cnt := 0;--(others => '0');
                        fst_d_rcvd <= '0';
                else
                        time_out <= '0';    
                end if;                     
                        
            end if;
        enable    <=  (d_ff2 xor s_ff2) xor (d_hold xor s_hold);  -- TX clock latched in DS signal  
    end process;  
    
    debug(0)           <= clk;
    debug(1)           <= reset_n;
    debug(2)           <= d_in;
    debug(3)           <= s_in;
    debug(4)           <= d_ff1;
    debug(5)           <= d_ff2;    
    debug(6)           <= s_ff1;
    debug(7)           <= s_ff2;    
    debug(8)           <= d_hold;
    debug(9)           <= s_hold;
    debug(10)          <= enable;
    debug(11)          <= fst_d_rcvd;
    debug(35 downto 12)    <= (others => '0');          
     
end behavioral;
