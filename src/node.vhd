----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- Create Date:         29.03.2016 12:01:16
-- Design Name:         Node
-- Module Name:         Top Design
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Top end of node design.  
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
        -- this field indicates the type of node that is generated.
        -- it alters the packet layer according to following inputs.
        -- "pkt_slave" produces a general node for the use in the field.
        -- "pkt_master produces a terminal node with pushbutton inputs.
        packet      : node_type := pkt_slave
    );

	port (
		clk_pad 	    : in    	std_logic;						-- System clock
        rst_n           : in        std_logic;                      -- "reset" button input (negative logic)                
        sw              : in        std_logic_vector(3 downto 0);   -- 4 switches on FPGA board    
        btn             : in        std_logic_vector(3 downto 0);   -- 4 buttons on fpga board        
        d_inA           : in        std_logic;                      -- Side A data in pin
        s_inA           : in        std_logic;                      -- Side A strobe in pin  
        d_inB           : in        std_logic;                      -- Side B data in pin
        s_inB           : in        std_logic;                      -- Side B strobe in pin          
        led             : out       std_logic_vector(3 downto 0);   -- 4 LEDs on FPGA board        
        ledb            : out       std_logic_vector(3 downto 0);   -- 4 blue LEDs on FPGA board        
        d_outA          : out       std_logic;                      -- Side A data out pin
        s_outA          : out       std_logic;                      -- Side A strobe out pin
        d_outB          : out       std_logic;                      -- Side B data out pin
        s_outB          : out       std_logic                       -- Side B strobe out pin
	);
end node;

architecture RTL of node is

    -- clocks
	signal clk_tx       : std_logic;               -- transmitter clock 
	signal clk_rx       : std_logic;               -- receiver clock must be 
	                                               -- 1.5 times faster than tx clock
    -- data signals
    signal display          : std_logic_vector(7 downto 0);     -- output to led's for debugging
            
    -- Records
    signal ExPktA          : ExPkt_rec;             -- Exchange layer to packet layer records
    signal ExPktB          : ExPkt_rec;                 -- Side A and B
    signal PktExA          : PktEx_rec;             -- Packet layer to exchange layer records
    signal PktExB          : PktEx_rec;                 -- Side A and B
    
    -- components
    component pll                                   -- pll clock creation component
        port (
            sys_clk         : in     std_logic;     -- Clock in ports
            clk_tx          : out    std_logic;     -- Clock out ports
            clk_rx          : out    std_logic
         );
        end component;        
begin

 
TXRX_clks : pll                                 -- Instantiation of PLL (from IP library
    port map ( 
        sys_clk => clk_pad,       
        clk_tx  => clk_tx,          
        clk_rx  => clk_rx              
    );
              
Side_A: entity work.side                      -- instantiate Side A of node     
        
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
        
Side_B: entity work.side                      -- instantiate Side B of node
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
    port map (                              -- This packet layer forms a normal    
        wr_clk          => clk_rx,          -- node as outlined by the project 
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
    pkt_master_ins: entity work.pkt_master      -- instantiate common packet layer                                                 
    port map (                                  -- This packet layer forms a terminal 
        wr_clk          => clk_rx,              -- for testing purposes, it establishes  
        rd_clk          => clk_tx,              -- links and fills a register from on 
        rst_n           => rst_n,               -- board buttons and switches to simulate
        sw              => sw,                  -- the transmission of data.
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