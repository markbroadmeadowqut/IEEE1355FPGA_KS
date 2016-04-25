----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- 
-- Create Date:         29.03.2016 12:01:16
-- Design Name:         Bus_Top
-- Module Name:         Top Design
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Top end of initial bus design
-- 
-- Dependencies: 
-- 
-- Revision:            1
-- Additional Comments:
 
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.bus_pkg.all;

entity node is
    generic ( 
        char_width  : integer := 8;                               -- character width
        fcc         : std_logic_vector(2 downto 0):=  "100";        -- control characters
        eop_1       : std_logic_vector(2 downto 0):=  "101";
        eop_2       : std_logic_vector(2 downto 0):=  "110";
        esc         : std_logic_vector(2 downto 0):=  "111";
        null_char   : std_logic_vector(6 downto 0):=  "1110100"         
    );

	port (
	   
		clk_pad		    : in    	std_logic;						-- 100Mhz clock
        rst_n           : in        std_logic;                      -- "reset" button input (negative logic)                
        sw              : in        std_logic_vector(3 downto 0);   -- 4 switches on FPGA board    
        btn             : in        std_logic_vector(3 downto 0);   -- 4 buttons on fpga board        
        d_inA           : in        std_logic;                      -- Data in pin
        s_inA           : in        std_logic;                      -- Strobe in pin  
        led             : out       std_logic_vector(3 downto 0);   -- 4 LEDs on FPGA board        
        ledb            : out       std_logic_vector(3 downto 0);   -- 4 blue LEDs on FPGA board        
        d_outA          : out       std_logic;                      -- Data out pin
        s_outA          : out       std_logic                       -- strobe out pin

	);
	
end node;

architecture RTL of node is

    -- ctrl chars and char width
    constant ctrl_chars : control_chars := (
        fcc         => fcc,            
        eop_1       => eop_1,
        eop_2       => eop_2,
        esc         => esc,
        null_char   => null_char
    );
   
    -- clocks
	signal clk_tx       : std_logic;                            -- transmitter clock
	signal clk_rx       : std_logic;                            -- receiver clock
    -- data signals	
    signal display      : std_logic_vector(7 downto 0);         -- output to led's
    --flags
    signal ExTxA        : ExTx_reg;
    signal CharTxExA    :CharTxEx_REG;
    signal SigRxExA     : SigRxEx_reg;
    signal CharRxExA    : CharRxEx_reg;
    signal dtct_nullA   : std_logic;
    signal char_rcvdA   : std_logic;
    signal char_saveA   : std_logic;
    
begin

TX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
    generic map (                                       
        PRESCALER 				=> 1            
        )
    port map ( 
        clkin           => clk_pad,
        clkout          => clk_tx,                      
        rst_n           => rst_n
        ); 

--RX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
--    generic map (                                       
--        PRESCALER 				=> 1              
--        )
--    port map ( 
--        clkin           => clk_pad,
--        clkout          => clk_rx,                       
--        rst_n           => rst_n
--        ); 
        
                
Exchange_tx: entity work.exchange_tx            -- instantiate Ckl prescaler
    generic map(
        char_width      => char_width
        )  
    port map ( 
        clk             => clk_tx,                    
        rst_n           => rst_n,
        CharTxExA       => CharTxExA,
        SigRxExA        => SigRxExA,
        CharRxExA       => CharRxExA,
        dtct_nullA      => dtct_nullA,
        char_rcvdA      => char_rcvdA,
        char_saveA      => char_saveA,
        ExTxA           => ExTxA
                
        );  

TX1_pipeline_nd: entity work.TX_pipeline            -- instantiate transmission pipeline
    generic map(
        char_width      => char_width
        )  
    port map ( 
        clk         => clk_tx,                      
        rst_n       => rst_n,
        sw          => sw,
        btn         => btn,
        ExTx        => ExTxA,
        ctrl_chars  => ctrl_chars,
        data        => d_outA,
        strobe      => s_outA,
        CharTxEx    => CharTxExA       
        ); 
	   
RX1_pipeline_nd: entity work.RX_pipeline            -- instantiate receiver pipeline

    generic map(
        char_width      => char_width
        )          
    port map ( 
        clk         => clk_pad,                      
        rst_n       => rst_n,
        data        => d_inA,
        strobe      => s_inA,
        dtct_null   => dtct_nullA,
        char_rcvd   => char_rcvdA,
        char_save   => char_saveA,
        ctrl_chars  => ctrl_chars,
        SigRxEx     => SigRxExA,
        CharRxEx    => CharRxExA,
        display     => display     
        ); 	   
	
--    process (clk_pad,rst_n)
--        begin
            --if rising_edge(clk_pad) then
--                if (rst_n = '0') then                          -- reset all 
--                    led         <= "0000";        
--                    ledb        <= "0000"; 
--                    display     <= "00000000";          
--                end if; 
            --end if;           
--        end process;    	
	
	led      <= display(7 downto 4);
	ledb      <=  display(3 downto 0);  
	--led(0)  <= data;
	--led(1) 	<= strobe;
	
	  
end RTL;
