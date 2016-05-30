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

library WORK;
	use work.bus_pkg.all;

entity node is
    generic ( 
        char_width  : integer := 8;                               -- character width       
        
        
        -- this field indicates the type of node that is generated.
        -- it alters the packet layer according to following inputs.
        -- "pkt_slave" produces a general node for the use in the field.
        -- "pkt_master produces a terminal node with pushbutton inputs.
        -- "pkt_counter produces a testing device that sends two counter signals for testing reliability of node.
        packet      : node_type := pkt_slave
    );

	port (
	   
		clk_pad		    : in    	std_logic;						-- 100Mhz clock
        rst_n           : in        std_logic;                      -- "reset" button input (negative logic)                
        sw              : in        std_logic_vector(3 downto 0);   -- 4 switches on FPGA board    
        btn             : in        std_logic_vector(3 downto 0);   -- 4 buttons on fpga board        
        d_inA           : in        std_logic;                      -- Data in pin
        s_inA           : in        std_logic;                      -- Strobe in pin  
        d_inB           : in        std_logic;                      -- Data in pin
        s_inB           : in        std_logic;                      -- Strobe in pin          
        led             : out       std_logic_vector(3 downto 0);   -- 4 LEDs on FPGA board        
        ledb            : out       std_logic_vector(3 downto 0);   -- 4 blue LEDs on FPGA board        
        d_outA          : out       std_logic;                      -- Data out pin
        s_outA          : out       std_logic;                       -- strobe out pin
        d_outB          : out       std_logic;                      -- Data out pin
        s_outB          : out       std_logic                       -- strobe out pin
	);

	
end node;

architecture RTL of node is

    -- clocks
	signal clk_tx       : std_logic;                            -- transmitter clock
	signal clk_rx       : std_logic;                            -- receiver clockdata

    -- data signals
    signal display          : std_logic_vector(7 downto 0);         -- output to led's
    
    --signal d_ab : std_logic;
    --signal s_ab : std_logic;
    --signal d_ba : std_logic;
    --signal s_ba : std_logic;
            
    -- Records
    signal ExPktA          : ExPkt_rec;        
    signal ExPktB          : ExPkt_rec; 
    signal PktExA          : PktEx_rec; 
    signal PktExB          : PktEx_rec;   
    
    -- components
    component pll
        port (
            clk_pad         : in     std_logic;     -- Clock in ports
            clk_tx          : out    std_logic;     -- Clock out ports
            clk_rx          : out    std_logic
         );
        end component;        
begin

 
TXRX_clks : pll
    port map ( 
        clk_pad => clk_pad,     -- Clock in ports
        clk_tx => clk_tx,        -- Clock out ports  
        clk_rx => clk_rx              
    );
        
--TX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
--    generic map (                                       
--       PRESCALER 				=> 2      
--        )
--    port map ( 
--        clkin           => clk_pad,
--        clkout          => clk_tx,                      
--        rst_n           => rst_n
--        );    
--RX_clock: entity work.clk_prescaler             -- instantiate Ckl prescaler
--    generic map (                                       
--        PRESCALER 				=> 1           
--      )
--    port map ( 
--        clkin           => clk_pad,
--        clkout          => clk_rx,                       
--        rst_n           => rst_n
--   ); 

       
Side_A: entity work.side                      -- instantiate Ckl prescaler
    generic map (                                       
        char_width      => char_width              
        )
    port map ( 
        clk_tx          => clk_tx,
        clk_rx          => clk_rx,                       
        rst_n           => rst_n,
        d_in            => d_inA,
        s_in            => s_inA,
        PktEx           => PktExA,
        d_out           => d_outA,
        s_out           => s_outA,
        ExPkt           => ExPktA        
        );        
        
Side_B: entity work.side                      -- instantiate Ckl prescaler
    generic map (                                       
        char_width      => char_width              
        )
    port map ( 
        clk_tx          => clk_tx,
        clk_rx          => clk_rx,                       
        rst_n           => rst_n,
        d_in            => d_inB,
        s_in            => s_inB,
        PktEx           => PktExB,
        d_out           => d_outB,
        s_out           => s_outB,
        ExPkt           => ExPktB        
        );         

packet_sel0: if packet = pkt_slave generate
    pkt_slave_ins: entity work.packet       -- instantiate common packet layer 
                
    generic map(
        char_width      => char_width
         )          
    port map ( 
        wr_clk          => clk_rx,
        rd_clk          => clk_tx,
        rst_n           => rst_n,
        sw              => sw,
        btn             => btn,
        ExPktA          => ExPktA,        
        ExPktB          => ExPktB,          
        display         => display,
        PktExA          => PktExA, 
        PktExB          => PktExB         
        );
end generate;               

packet_sel1: if packet = pkt_master generate
    pkt_master_ins: entity work.pkt_master       -- instantiate common packet layer 
                
    generic map(
        char_width      => char_width
         )          
    port map ( 
        wr_clk          => clk_rx,
        rd_clk          => clk_tx,
        rst_n           => rst_n,
        sw              => sw,
        btn             => btn,
        ExPktA          => ExPktA,        
        ExPktB          => ExPktB,          
        display         => display,
        PktExA          => PktExA, 
        PktExB          => PktExB         
        );
end generate;                          	
	
	led       <= display(7 downto 4);
	ledb      <= display(3 downto 0);  
	  
end RTL;
